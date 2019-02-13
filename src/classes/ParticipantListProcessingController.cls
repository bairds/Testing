// Jan 31 Jose revises so users can add campaign members without refreshing whole page and erasing data they've already input.
// Nov 10 2016 Baird makes sure this inserts addressee and dear.
public class ParticipantListProcessingController
{
    public List<Attendee> AttendeesRSVPed {get; set;}
    public List<Attendee> AttendeesAttended {get; set;}
    public List<CampaignMember> UpdateCMs;
    public Campaign Camp {get; set;}
    public List<CampaignMember> Campmmbrs {get; set;}
    public Boolean review {get; set;} // Value to render review pageBlock;
    public Id VolContribId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Volunteer Task').getRecordTypeId();
    public Decimal TotalHours {get; set;}
    public LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
    public Id accountToDeleteId {get; set;}
    public Id cid {get; set;}
    public Id FamilyRTID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Family').getRecordTypeId();

    static public String DefaultRating = getDefaultValue(Opportunity.Supervisor_Satisfaction__c.getDescribe(), 2);
    static public List<Schema.PicklistEntry> LeadershipLevels = Opportunity.Leadership_Level__c.getDescribe().getPicklistValues();
    static public String DefaultLeadership = getDefaultValue(Opportunity.Leadership_Level__c.getDescribe(), 0);

    public Attendee attendee { get; set; }
    public Attendee all { get; set; }

    public AccountController account {
        get; set;
    }

    public ParticipantListProcessingController(ApexPages.StandardController controller) {

        review = false;
        //FamilyRTID = [select id from RecordType where Name = 'Family'][0].id;

        cid = System.currentPageReference().getParameters().get('cid');
        if (cid==null) DisplayNoCAmpaignWarning();

        Camp = [select Id, campaign.Name, Event_Date_Time__c from Campaign where Id = :cid];


        attendee = new Attendee(this);
        all = new Attendee(this);
        account = new AccountController(this);
        SetRSVP();
    }

    public void SetRSVP() {
        AttendeesRSVPed = new List<Attendee>();
        for(CampaignMember cm: [select Id, ContactId, Contact.FirstName, Contact.LastName, Contact.Email, Contact.AccountId, LeadId, Lead.FirstName,
                Lead.LastName, Lead.IsConverted, Hours__c, Status, Role__c from CampaignMember
        where Campaign.Id = :Camp.Id and Processed__c <> true order by Contact.FirstName, Lead.FirstName limit 1000]) {
            // As each campaignMember is processed we create a new Attendee object and add it to the AttendeesRSVPed
            AttendeesRSVPed.add(new Attendee(cm));
            // We also capture its status value so that we can check later to see whether the user has changed the status
        }

    }

//Get List of Status Values
    public List<SelectOption> getStati() {
        List<SelectOption> stati = new List<SelectOption>();
        // Baird revised Jose's query to pull the CampaignMemberStati from the campaign itself
        for(CampaignMemberStatus cms : [SELECT Id, Label FROM CampaignMemberStatus WHERE CampaignId = :cid])
            stati.add(new SelectOption(cms.Label, cms.Label));

        return stati;
    }


    static public String getDefaultValue(Schema.DescribeFieldResult field, Integer index) {

        List<Schema.PicklistEntry> sspl = field.getPicklistValues();

        if(index >= sspl.size())
            index = 0;

        return sspl[index].getLabel();
    }
    public void setAllStatus()
    {
        for(Attendee a : AttendeesRSVPed) {
            if(String.isNotBlank(all.CM.Status))
                a.CM.Status = all.CM.Status;

            if(a.Hours == 0)
                a.Hours = null;
        }

        if(all.Hours == 0)
            all.Hours = null;
    }

    public void setAllHours()
    {
        for(Attendee a : AttendeesRSVPed) {
            a.Hours = all.Hours;

            if(a.Hours == 0)
                a.Hours = null;
        }

        if(all.Hours == 0)
            all.Hours = null;
    }


    public void addCMToList(CampaignMember cm) {
        formatsRSVPedList();
        AttendeesRSVPed.add(new Attendee(cm));
    }

    public void formatsRSVPedList(){
        for(Attendee a: AttendeesRSVPed) {
            if(a.Hours == 0)
                a.Hours = null;
        }
    }


    public void processSelected() {
        account.newContactForm = false;

        UpdateCMs = new List<CampaignMember>();
        AttendeesAttended = new List<Attendee>();
        TotalHours = 0;

        for(Attendee a: AttendeesRSVPed) {
            System.debug('Going through AttendeesRSVPed to add to AttendeesAttended');

            if(addToAttendedList(a)){
                if(a.Hours != null)
                    TotalHours += a.Hours;
            }
        }

        if(all.Hours == 0)
            all.Hours = null;

        if(AttendeesAttended.size() == 0)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No members were processed'));

        if(!ApexPages.hasMessages())
            review = true;
    }

    public Boolean addToAttendedList(Attendee a) {

        if(a.Hours == 0)
            a.Hours = null;

        // If user has changed hours, comments, rating, or status

        if(a.Hours != null  || a.Comments != '' || a.Contribution.Supervisor_Satisfaction__c != ParticipantListProcessingController.DefaultRating || a.OriginalStatus != a.CM.Status) {
            AttendeesAttended.add(a);
            return true;
        }

        return false;
    }


//Back to WaterGrass
    public PageReference exitToWaterGrass(){
        PageReference nextPage = new PageReference('/'+Camp.Id);
        nextPage.setRedirect(true);
        return nextPage;
    }


//REturn to Edit List
    public PageReference returnToEditList(){
        review=false;
        AttendeesAttended.clear();
        return null;
    }

//Submit Data
    public PageReference submitData(){
        List<Opportunity> InsertOpps = new List<Opportunity>();

        if(Camp.Event_Date_Time__c == null) {
            Camp.Event_Date_Time__c = attendee.Contribution.CloseDate;

            update Camp;
        }

        system.debug('AttendeesAttended create the Opps; they include ' + AttendeesAttended);
        For (Attendee a : AttendeesAttended) {
            setCM(a);

            UpdateCMs.add(a.CM);

            Opportunity opp = createContribution(a);

            if (opp != null)
                InsertOpps.add(opp);
        }

        if (UpdateCMs.size() > 0) update UpdateCMs; // We set all the CMs in the AttendeeRSVPed list to 'processed' so we won't pull them in the next batch.

        system.debug('InsertOpps is ' + InsertOpps);
        system.debug('UpdateCMs is ' + UpdateCMs);
        if (InsertOpps.size() > 75)
            Id batchId = Database.executeBatch(new OpportunityBatch(InsertOpps), 75);
        else if (InsertOpps.size() > 0) insert InsertOpps;

        PageReference nextPage = new PageReference('/'+Camp.Id);
        nextPage.setRedirect(true);
        return nextPage;
    }

    public void setCM(Attendee a)
    {
        a.CM.Hours__c = a.Hours;
        a.CM.Supervisor_Satisfaction__c = a.Contribution.Supervisor_Satisfaction__c;
        a.CM.Comments__c = a.Comments;
        a.CM.Leadership_Level__c = a.Contribution.Leadership_Level__c;
        a.CM.Processed__c = true;
    }

    public Opportunity createContribution(Attendee a)
    {
        if(a.Hours > 0) {
            Opportunity opp = new Opportunity(
                    Name = 'autofill',
                    CloseDate = attendee.Contribution.CloseDate,
                    Hours_Actual__c = a.Hours,
                    CampaignId = Camp.Id,
                    RecordTypeId = VolContribId,
                    Description = a.Comments,
                    Leadership_Level__c = a.Contribution.Leadership_Level__c,
                    StageName = 'Completed',
                    Supervisor_Satisfaction__c = a.Contribution.Supervisor_Satisfaction__c
            );

            if (a.CM.Lead.LastName != null && a.CM.Lead.IsConverted != true) {
                System.debug('Just found this is a lead, opp is ' + opp);
                Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(a.CM.LeadId);
                lc.setDoNotCreateOpportunity(true);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                lc.setOverwriteLeadSource(true);
                Database.LeadConvertResult lcr = Database.convertLead(lc);
                //Feb 3 - Baird: This values need to get assigned after the lead conversion in order for them to be properly inserted in the opportunity
                // Make sure conversion was successful
                System.assert(lcr.isSuccess());

                opp.Contact__c = lcr.getContactId();
                opp.AccountId = lcr.getAccountId();

                //system.debug('Just set contact__c and accountid for opp, which is now is ' + opp + ' and account is ' + acct);
            }
            else {
                System.debug('Just found this is a contact, opp is ' + opp);
                opp.Contact__c = a.CM.ContactId;
                opp.AccountId = a.CM.Contact.AccountId;
                System.debug('Just set contact__c and accountid for opp, which is now is ' + opp);
            }


            // Add Dear__c and Addressee to account
            Account acct = [select Id, Dear__c, Addressee__c, Name from Account where Id = :opp.AccountId];

            if(String.isBlank(acct.Dear__c) || String.isBlank(acct.Addressee__c)) {
                Contact ctct = [select Id, FirstName, LastName from Contact where Id = :opp.Contact__c];
                if (acct.Name == 'none') acct.Name = ctct.LastName + ', ' + ctct.FirstName + ' Household';

                if(String.isBlank(acct.Dear__c))
                    acct.Dear__c = ctct.FirstName;

                if(String.isBlank(acct.Addressee__c))
                    acct.Addressee__c = ctct.FirstName + ' ' + ctct.LastName;

                System.debug('In lcr, Account Name is ' + acct.Name);
                update acct;

            }
            return opp;
        }
        else
                return null;
    }

//Wrapper Class
    public class Attendee {

        public String Id {
            get; set;
        }

        ParticipantListProcessingController Controller;

        public CampaignMember CM {get; set;}
        public Decimal Hours {get; set;}
        public String Comments {get; set;}
        public String OriginalStatus {get; set;}

        public CampaignMember selected {get; set;}

        public Person Person {
            get; set;
        }

        public Opportunity Contribution {get; set;}

        public Attendee(ParticipantListProcessingController con) {
            Controller = con;
            selected = new CampaignMember();
            CM = new CampaignMember();
            OriginalStatus = CM.Status;
            Contribution = new Opportunity();
            Contribution.Supervisor_Satisfaction__c = ParticipantListProcessingController.DefaultRating;
            Contribution.Leadership_Level__c = ParticipantListProcessingController.DefaultLeadership;
            Contribution.CloseDate = Controller.Camp.Event_Date_Time__c == null ? System.today() : Controller.Camp.Event_Date_Time__c.date();
        }

        public Attendee(CampaignMember campmmbr) {
            CM = campmmbr;
            OriginalStatus = CM.Status;
            Contribution = new Opportunity();
            Contribution.Supervisor_Satisfaction__c = ParticipantListProcessingController.DefaultRating;
            Contribution.Leadership_Level__c = ParticipantListProcessingController.DefaultLeadership;
        }

        public void preAddToList() {
            Controller.account.newContactForm = false;
        }

        public void addToList() {
            if(String.isNotBlank(Id)) {
                Person = new Person(Id, null);

                List<CampaignMember> check = Database.query('SELECT Id, Processed__c FROM CampaignMember WHERE ' + Person.Type + 'Id = \'' + Id + '\' AND ' +
                        'CampaignId = \'' + Controller.Camp.Id + '\'');

                if (check.size() == 0) {
                    CM = new CampaignMember();

                    if(Person.Type == 'Lead')
                        CM.LeadId = Id;
                    else
                            CM.ContactId = Id;

                    CM.CampaignId = Controller.Camp.Id;
                    CM.Status = 'Attended';

                    insert CM;

                    CM = [SELECT Id, Contact.FirstName, Contact.LastName, Contact.AccountId, ContactId, Lead.FirstName, Lead.LastName, Status, Lead.IsConverted, LeadId, Role__c
                    FROM CampaignMember WHERE Id = :CM.Id];

                    Controller.addCMToList(CM);
                }
                else
                {
                    CampaignMember check_cm = check[0];

                    if(check_cm.Processed__c)
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'That campaign member has already been processed. If you want to process them again, or un-process them, go to the campaign member list, edit them, and remove the check in the "Processed" check box.'));
                    else
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Campaign Member is already in this list.'));


                    Controller.formatsRSVPedList();
                }
            }
        }

        public void insertCM(){

        }

        public void deleteCM() {
            delete selected;

            Controller.SetRSVP();
        }
    }

    public class AccountController  {
        ParticipantListProcessingController Controller;

        public String Id {
            get; set;
        }

        public Boolean newContactForm {
            get; set;
        }

        public Contact newContact {
            get; set;
        }

        public AccountController(ParticipantListProcessingController con) {
            Controller = con;
        }

        public void addNewContact() {
            newContact = new Contact();
            newContactForm = true;

            Id = null;
        }

        public void SaveContact() {
            Account a = new Account();

            if(String.isBlank(Id)) { // Create Account
                enterAccountContact eac = new enterAccountContact(new ApexPages.StandardController(new Account()));
                eac.ctct = newContact;
                // JOSE, IS THERE A WAY WE CAN PULL THE FAMILY RECORDTYPE ONCE ABOVE AND REFERENCE IT HERE?
                // I TRIED BUT GET "NO FIELD NAMED FAMILYRTID"
                //eac.acct.recordtypeID = [select id from RecordType where Name = 'Family'][0].id; // Family
                // The eac.setAccount() ought to set the account record type
                eac.setAccount();
                System.debug('eac.acct is ' + eac.acct);
                a = eac.acct;

                insert a;
            }
            else
                    a.Id = Id;

            newContact.AccountId = a.Id;

            insert newContact;

            CampaignMember cm = new CampaignMember();
            cm.ContactId =  newContact.Id;
            cm.CampaignId = Controller.Camp.Id;
            cm.Status = 'Attended';

            insert cm;

            cm.Contact = newContact;

            newContactForm = false;

            Controller.addCMToList(cm);
        }

        public void cancelContact() {
            newContactForm = false;
        }
    }

    public PageReference DisplayNoCAmpaignWarning() {
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Error: Not sure which Campaign to use.  Please send a copy of this message to support@watergrass.org.');
        ApexPages.addMessage(myMsg);
        return null;
    }
}