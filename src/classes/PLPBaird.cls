// Jan 31 Jose revises so users can add campaign members without refreshing whole page and erasing data they've already input.
// Nov 10 2016 Baird makes sure this inserts addressee and dear.
public class PLPBaird
{
    public List<Attendee> UnprocessedAttendees {get; set;}
    public List<AttendeeWrapper> UnprocessedAttWrapped {get; set;}
    public List<Attendee> UpdateAttendees {get; set;}
    List<CampaignMember> ListCMs {get; set;}
    public List<CampaignMember> UpdateCMs;
    public Campaign Camp {get; set;}
    public Boolean review {get; set;} // Value to render review pageBlock;
    public Boolean newContactForm {get; set;}
    public Id VolContribId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Volunteer Task').getRecordTypeId();
    public Decimal TotalHours {get; set;}
    public LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
    public Id cid {get; set;}
    // Is FamilyRTID used anywhere?
    public Id FamilyRTID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Family').getRecordTypeId();
    public integer AttendeeToDeleteIndex {get; set;}
    public CampaignMember CMToDelete { get; set; }

    static public String DefaultRating = '3 - Good';
    static public List<Schema.PicklistEntry> LeadershipLevels {get;set;}
    static public String DefaultLeadership {get; set;}

    public Attendee attendee { get; set; }
    // public Attendee all { get; set; }
    public Contact NewContact {get; set;}
    public Id PersonId {get; set;}
    public Decimal allHours {get;set;}
    public string allStatus {get;set;}

    public PLPBaird(ApexPages.StandardController stdController) {
        LeadershipLevels = Opportunity.Leadership_Level__c.getDescribe().getPicklistValues();
        DefaultLeadership = getDefaultValue(Opportunity.Leadership_Level__c.getDescribe(), 0);
        CMToDelete = new CampaignMember();
        review = false;
        cid = System.currentPageReference().getParameters().get('cid');
        system.debug('At top of constructor, cid is ' + cid);
        if (cid==null) {
            DisplayNoCAmpaignWarning();
        } else {
            try {
                Camp = [select Id, campaign.Name, Event_Date_Time__c from Campaign where Id = :cid];
                attendee = new Attendee(Camp);
                // all = new Attendee(Camp);
                newContactForm = false;
                // NewContact = new Contact();
                PersonId = null;
                ListCMs = [
                        select Id, Name, ContactId, Contact.FirstName, Contact.LastName, Contact.Email, Contact.AccountId, LeadId, Lead.FirstName,
                                Lead.LastName, Lead.IsConverted, Hours__c, Status, Role__c, Processed__c
                        from CampaignMember
                        where Campaign.Id = :Camp.Id and Processed__c <> true
                        order by Contact.FirstName, Lead.FirstName
                        limit 1000
                ];
                UnprocessedAttendees = new List<Attendee>();
                UnprocessedAttWrapped = new List<AttendeeWrapper>();
                FOR (CampaignMember cm : ListCMs) {
                    UnprocessedAttendees.add(new Attendee(cm));
                }
                UpdateAttendees = new List<Attendee>();
            } catch(QueryException e){
                DisplayBadCampIdWarning();
            }
            Integer counter = 0;
            if (UnprocessedAttendees != null) {
                for (Attendee at : UnprocessedAttendees) {
                    // add the wrapper to the collection
                    UnprocessedAttWrapped.add(new AttendeeWrapper(at, counter));
                    counter = counter + 1;
                }
            }
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
        string passedParam1 = Apexpages.currentPage().getParameters().get('allStatus');
        system.debug('Passed in myParam ' + passedParam1);
        for(Attendee a : UnprocessedAttendees) {
            if(String.isNotBlank(passedParam1))
                a.CM.Status = passedParam1;

            if(a.Hours == 0)
                a.Hours = null;
        }

        if(allHours == 0)
            allHours = null;
    }

    public void setAllHours()
    {
        system.debug('Passed in allHours ' + allHours);
        for(Attendee a : UnprocessedAttendees) {
            a.Hours =  allHours;

            if(a.Hours == 0)
                a.Hours = null;
        }

        if(allHours == 0)
            allHours = null;
    }

    public void formatsRSVPedList(){
        for(Attendee a: UnprocessedAttendees) {
            if(a.Hours == 0)
                a.Hours = null;
        }
    }


    public void processSelected() {
        newContactForm = false;
        UpdateCMs = new List<CampaignMember>();
        TotalHours = 0;

        for (Attendee a : UnprocessedAttendees) {
            System.debug('Going through UnprocessedCMs to add to UpdateAttendees');
            // MAKE SURE HOURS ARE NULL RATHER THAN 0
            if (a.Hours == 0)
                a.Hours = null;

            // If user has changed hours, comments, rating, or status

            if (a.Hours != null || a.Comments != '' || a.Contribution.Supervisor_Satisfaction__c != PLPBaird.DefaultRating || a.OriginalStatus != a.CM.Status) {
                /*system.debug('a.Hours != blank? ' + string.ValueOf(a.Hours != null) + 'a.Comments != blank? ' +  string.ValueOf(a.Comments != '') + 'a.Contribution.Supervisor_Satisfaction__c != DefaultRating? '+  string.ValueOf(a.Contribution.Supervisor_Satisfaction__c != DefaultRating) +'a.OriginalStatus != a.CM.Status?' +  string.ValueOf(a.OriginalStatus != a.CM.Status));
                SYSTEM.debug('a.Hours are ' + a.Hours + 'and a.Supervisor_Satisfaction is '+ a.Contribution.Supervisor_Satisfaction__c + ' and Default RAting is ' + DefaultRating);*/
                UpdateAttendees.add(a);
                if (a.Hours != null)
                    TotalHours += a.Hours;

                if (UpdateAttendees.size() == 0)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No members were processed'));

                if (!ApexPages.hasMessages())
                    system.debug('Error messages are ' + ApexPages.getMessages());
                    review = true;
            }
        }
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
        UpdateAttendees.clear();
        return null;
    }

    public void addToList(){
        system.debug('PersonId is ' + personId);
        if(string.IsNotBlank(personId))
        addToList(PersonId);
    }

    public void addToList(Id PersonId) {
        system.debug('Beginning AddToList(), UnprocessedAttendees number ' + UnprocessedAttendees.size());
        // CREATE LIST OF EXISTING CAMPAIGN MEMBERS
        Map<Id,CampaignMember> MapCMs = new Map<Id,CampaignMember>();
       For (CampaignMember cm : ListCMs) {
           If (cm.contactId != null) {
               MapCMs.put(cm.contactId, cm);
           } else {
               MapCMs.put(cm.leadId, cm);
           }
       }
        // COMPARE NEW CM TO LIST TO MAKE SURE IT'S REALLY NEW
        if (MapCMs.containsKey(PersonId)) {
            if(MapCMs.get(PersonId).Processed__c) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'That campaign member has already been processed. If you want to process them again, or un-process them, go to the campaign member list, edit them, and remove the check in the "Processed" check box.'));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Campaign Member is already in this list.'));
            }
        } else // CREATE NEW CAMPAIGNMEMBER FROM EXISTING CONTACT OR LEAD
        {
            CampaignMember newcm = new CampaignMember(
                    LeadId = string.valueOf(PersonId).startswith('003') ? null : PersonId,
                    ContactId = string.valueOf(PersonId).startswith('003') ? PersonId : null,
                    CampaignId = Camp.Id,
                    Status = 'Attended'
            );
            insert newcm;
            system.debug('After inserting new campaignMember, does it have a name? ' + newcm.Name);
            // newcm.lastname = newcm.contact.lastname == null ? newcm.lead.lastname : newcm.contact.lastname;
            ListCMs.add(newcm);

            UnprocessedAttendees.add(new Attendee(newcm));
            system.debug('After AddToList(), UnprocessedAttendees number ' + UnprocessedAttendees.size());
            integer j = UnprocessedAttWrapped.size();
            UnprocessedAttWrapped = new List<AttendeeWrapper>();
            FOR (Attendee at : UnprocessedAttendees) {
                UnprocessedAttWrapped .add(new AttendeeWrapper(at,j));
            }
        }
        // requery list; refresh screen;
        formatsRSVPedList();
        system.debug('Finished addToList, should now rerender PeopleWhoRSVPed section.');
    }

        public void addNewContact() {
            newContact = new Contact();
            newContactForm = true;
        }

        public void cancelContact() {
            newContactForm = false;
        }

    public void savePerson() {
        // If this is a new contact in an existing account, save it;
        system.debug('just before SavePerson(), newContact is ' + newContact);
        if (newContact.AccountId != null) {
            Insert NewContact;
            personId = newContact.Id;
        }
        // else create a lead
        else {
            List<string> results = identifyOrCreatePerson.identifyorCreatePerson(newContact);
            personId = results[0];
            system.debug('IOCR results are' + results);
        }
        addToList(personId);
        newContactForm=false;
    }

//Submit Data
    public PageReference submitData(){
        List<Opportunity> InsertOpps = new List<Opportunity>();

        if(Camp.Event_Date_Time__c == null) {
            Camp.Event_Date_Time__c = attendee.Contribution.CloseDate;
            update Camp;
        }

        // TRANSFER ATTENDEE INFO INTO THE PROPER CAMPAIGNMEMBER FIELDS
        system.debug('UpdateAttendees create the Opps; they include ' + UpdateAttendees);
        For (Attendee a : UpdateAttendees) {
            // SAVE ATTENDEE INFO INTO CAMPAIGN MEMBER
            a.CM.Hours__c = a.Hours;
            a.CM.Supervisor_Satisfaction__c = a.Contribution.Supervisor_Satisfaction__c;
            a.CM.Comments__c = a.Comments;
            a.CM.Leadership_Level__c = a.Contribution.Leadership_Level__c;
            a.CM.Processed__c = true;
            UpdateCMs.add(a.CM);
            Opportunity opp = createContribution(a);

            if (opp != null)
                InsertOpps.add(opp);
        }

        SYSTEM.DEBUG('After updating CMs from Attendee data, the UpdateCMs list is ' + UpdateCMs);
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


    public Opportunity createContribution(Attendee a)
    {
        if(a.Hours > 0) {
            Opportunity opp = new Opportunity(
                    Name = 'autofill',
                    CloseDate = a.Contribution.CloseDate==null ? Camp.Event_Date_Time__c.date() : a.Contribution.CloseDate,
                    Hours_Actual__c = a.Hours,
                    CampaignId = Camp.Id,
                    RecordTypeId = VolContribId,
                    Description = a.Comments,
                    Leadership_Level__c = a.Contribution.Leadership_Level__c,
                    StageName = 'Completed',
                    Supervisor_Satisfaction__c = a.Contribution.Supervisor_Satisfaction__c
            );

            system.debug('a.CM.Lead.LastName is ' + a.CM.Lead.LastName + ' and a.CM.Lead.IsConverted is ' + a.CM.Lead.IsConverted);
            if (a.CM.LeadId != null && a.CM.Lead.IsConverted != true) {
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
                system.debug('Just set contact__c and accountid for opp, which is now is ' + opp);
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

    public void deleteCM() {
        UnprocessedAttendees.remove(AttendeeToDeleteIndex);
        delete CMToDelete;
        UnprocessedAttWrapped = new List<AttendeeWrapper>();
        Integer counter = 0;
        for (Attendee at : UnprocessedAttendees) {
// add the wrapper to the collection
            UnprocessedAttWrapped.add(new AttendeeWrapper(at, counter));
            counter = counter + 1;
        }

//                ListCMs = [select Id, ContactId, Contact.FirstName, Contact.LastName, Contact.Email, Contact.AccountId, LeadId, Lead.FirstName,
//                        Lead.LastName, Lead.IsConverted, Hours__c, Status, Role__c, Processed__c from CampaignMember
//                where Campaign.Id = :Camp.Id and Processed__c <> true order by Contact.FirstName, Lead.FirstName limit 1000];
    }


    //Wrapper Class
    public class Attendee {
        public Id PersonId {get;set;}
        public CampaignMember CM { get; set; }
        public Decimal Hours { get; set; }
        public String Comments { get; set; }
        public String OriginalStatus { get; set; }
        // public CampaignMember selected { get; set; }
        public Opportunity Contribution { get; set; }

        public Attendee(CampaignMember campmmbr) {
            CM = campmmbr;
            OriginalStatus = CM.Status;
            Contribution = new Opportunity();
            Contribution.Supervisor_Satisfaction__c = DefaultRating;
            Contribution.Leadership_Level__c = DefaultLeadership;
        }

        public Attendee(Campaign Camp) {
            CM = new CampaignMember(CampaignId = Camp.Id);
            OriginalStatus = CM.Status;
            Contribution = new Opportunity();
            Contribution.Supervisor_Satisfaction__c = DefaultRating;
            Contribution.Leadership_Level__c = DefaultLeadership;
        }
    }

    class AttendeeWrapper{
        public Attendee at {get; set;}
        public Integer counter {get; set;}

        public AttendeeWrapper(Attendee at, Integer counter){
            this.at = at;
            this.counter = counter;
        }
    }

    public PageReference DisplayNoCAmpaignWarning() {
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Error: Not sure which Campaign to use.  Did you start from the campaign detail page?  Please send a copy of this message to support@watergrass.org.');
        ApexPages.addMessage(myMsg);
        return null;
    }

    public PageReference DisplayBadCampIdWarning() {
    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'That Campaign Id is not correct.  Please send a copy of this message to support@watergrass.org.');
    ApexPages.addMessage(myMsg);
    return null;
}

}