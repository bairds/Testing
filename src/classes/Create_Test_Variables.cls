// Testing in Illuminated Cloud
public without sharing class Create_Test_Variables {
    Public Campaign TestCampaign {get; set;}
    Public CampaignMember TestCM {get; set;}
    Public Contact TestContact {get; set;}
    Public Account TestAccount {get; set;}
    Public Opportunity TestOpportunity;
    Public Lead TestLead {get; set;}    
	id DonationRTID = [select id from RecordType where Name = 'Donation'][0].id;

public Create_Test_Variables() {  
    // Create a campaign with slots_remaining__c = 1
    TestCampaign = new Campaign(
    name = 'Testcampaign',
    capacity__c = 2,
    event_date_time__c = datetime.newInstance(2050, 12, 1, 12, 30, 2),
    description = 'description',
    event_cost__c = 20.00,
    isActive = true,
    RecordtypeID = [select id from recordtype where name = 'Public Event'].id);
    insert Testcampaign; 
    Testaccount = new Account (name='TestAccount');
    insert testaccount;
    TestContact = new Contact (lastname='TestContact', email='testcontact@dontbotherme.org', accountID = TestAccount.ID);
    insert testcontact; 
    TestLead = new Lead (firstname = 'Lead', lastname = 'TestLead', email='testlead@dontbotherme.org', company='TestCompany', PostalCode='22222');
    insert TestLead;
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

    public Text_Document__c fetchWaiver(){
        Text_Document__c TD = new Text_Document__c(
                Title__c = 'TestWaiver',
                type__c = 'Waiver',
                body__c = 'This is the waiver body'
        );
        insert TD;
        return TD;
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
    return TestContact;}
    
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