// Testing in Illuminated Cloud
public without sharing class CreateUserExamValues {
    Public Campaign TestCampaign {get; set;}
    Public CampaignMember TestCM {get; set;}
    Public Contact TestContact {get; set;}
    Public Account TestAccount {get; set;}
    Public Opportunity TestOpportunity;
    Public Lead TestLead {get; set;}
    id DonationRTID = [select id from RecordType where name = 'Donation'][0].id;
    public list<string> vowels;

    public CreateUserExamValues() {
        // Create a campaign with slots_remaining__c = 1
        List<Campaign> InsertCampaigns = new List<Campaign>();
        TestCampaign = new Campaign(
                name = 'EOY Volunteer Event',
                capacity__c = 2,
                event_date_time__c = datetime.newInstance(2018, 12, 1, 12, 30, 2),
                description = 'Help us prepare for our holiday fundraising event.',
                isActive = true,
                RecordtypeID = [select id from RecordType where name = 'Volunteer Event'][0].id);// Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('VolunteerEvent').getRecordTypeId());
        insert TestCampaign;
        Campaign TestCampaign2 = new Campaign(
                name = 'EOY Appeal Letter',
                description = 'Letter to non-major-donors who have given in the last two years or volunteered or attended an event in the last year',
                isActive = true,
                RecordTypeId = [select id from RecordType where name = 'Fundraising Activity'][0].id);
        InsertCampaigns.add(Testcampaign2);
        insert TestCampaign2;

        Testaccount = new Account (name='TestAccount');
        insert testaccount;
        TestContact = new Contact (lastname='TestContact', email='testcontact@dontbotherme.org', accountID = TestAccount.ID);
        insert testcontact;
        TestLead = new Lead (firstname = 'Lead', lastname = 'TestLead', email='testlead@dontbotherme.org', company='TestCompany');
        insert TestLead;
        vowels = new List<String>();
        vowels.add('a');
        vowels.add('e');
        vowels.add('i');
        vowels.add('o');
        vowels.add('u');
        vowels.add('y');
    }

    public Opportunity fetchTestOpportunity() {
        TestOpportunity = new Opportunity (Contact__c = TestContact.id,
                AccountID = TestAccount.id,
                CampaignID = TestCampaign.id,
                Name = 'autofill',
                StageName = 'Closed/Won',
                CloseDate = system.today(),
                recordTypeID = DonationRTID,
                Amount = 100);
        insert TestOpportunity;
        return TestOpportunity;}

    public List<Account> fetchBusinessAccounts(){
        List<Account> insertAccounts = new List<Account>();
        Account TestBusiness1 = new Account(
                name = 'Janes Place',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId()
        );
        insertAccounts.add(TestBusiness1);
        Account TestBusiness2 = new Account(
                name = 'Junes Gravel',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId()
        );
        insertAccounts.add(TestBusiness2);
        insert insertAccounts;
        return insertAccounts;
    }


    public Campaign fetchTestCampaign() {
        return TestCampaign;}

    public CampaignMember fetchTestCM(){
        CampaignMember TestCM = new CampaignMember(
                contactId = TestContact.Id,
                campaignId = Testcampaign.Id,
                Status = 'Added to campaign'
        );
        Insert TestCM;
        return TestCM;
    }


    public Account fetchTestAccount() {
        return TestAccount;}

    public Contact fetchTestContact() {
        return TestContact;
    }

    public List<Contact> fetchTestContacts() {
        list<Contact> TCs = new list<Contact>();

        For (String vowel : vowels) {
            Contact NewContact = new Contact(
                    lastname = 'J' + vowel + 'neson',
                    firstname = 'J' + vowel + 'ne',
                    email = 'J' + vowel + 'ne@' + 'J' + vowel + 'neson.com');
            TCs.add(NewContact);
        }
            insert TCs;
        return TCs;
    }

    public List<Contact> fetchFamilyMembers(){
        List<Contact> insertContacts = new List<Contact>();
        list<Account> LstAccts = [select id, Name from Account where name like 'J%' ORDER BY name];
        for (integer i=0;i<6;i++){
            Contact newContact = new Contact(
                    lastname = 'J' + vowels[i] + 'neson',
                    firstname = 'J' + vowels[i]+ 'hn',
                    email = 'J' + vowels[i] + 'hn@' + 'J' + vowels[i] + 'neson.com',
                    accountId = LstAccts[i].Id);
                insertContacts.add(NewContact);
                    }


        insert insertContacts;
        return insertContacts;
    }

    public Lead fetchTestLead() {
        return TestLead;}

    public WG_Settings__c createWGCustomSettings() {
        WG_Settings__c newsletter=new WG_Settings__c(
                name = 'newsletter',
                FinalDonationCampaignStatus__c='Donated',
                FinalVolunteerCampaignStatus__c='Completed',
                ManageContribsTrigger__c=true);
        insert newsletter;
        return newsletter;
    }

    public list<CampaignStati__c> createCampaignStati() {
        list<CampaignStati__c> ListCSs = new list<CampaignStati__c>();
        // List of CampaignStatus values that are HasResponded=true
        list<string> Stati = new list<string>();
        Stati.add('Attended');
        Stati.add('Contributed');
        Stati.add('Donated');
        Stati.add('No Show');
        Stati.add('Responded No');
        Stati.add('RSVPed and Attended');
        Stati.add('Signed e-petition');
        Stati.add('Took action');
        for (string s : stati) {
            CampaignStati__c cs=new CampaignStati__c(
                    name = s,
                    HasResponded__c = true);
            ListCSs.add(cs);
        }
        Stati.clear();
        // List of CampaignStatus values that are HasResponded=false
        Stati.add('Communication sent');
        for (string s : stati) {
            CampaignStati__c cs=new CampaignStati__c(
                    name = s,
                    HasResponded__c = false);
            ListCSs.add(cs);
        }
        insert ListCSs;
        system.debug('Just inserted campaign Stati ' + ListCSs);
        return ListCSs;
    }
}