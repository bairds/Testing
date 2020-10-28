// Testing in Illuminated Cloud
public without sharing class Create_Test_Variables {
    Public Campaign TestCampaign {get; set;}
    Public CampaignMember TestCM {get; set;}
    Public Contact TestContact {get; set;}
    Public Contact TestFamilyContact {get; set;}
    Public Account TestAccount {get; set;}
    Public Account TestFamilyAccount {get; set;}
    Public Opportunity TestOpportunity;
    Public Case TestCase;
    Public Lead TestLead {get; set;}
    Public Text_Document__c TestTD {get; set;}
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
    // Non Family Account
    Testaccount = new Account (name='TestAccount');
    insert testaccount;
    TestContact = new Contact (lastname='TestContact', email='testcontact@dontbotherme.org', accountID = TestAccount.ID);
    insert testcontact; 
    TestLead = new Lead (firstname = 'Lead', lastname = 'TestLead', email='testlead@dontbotherme.org', company='TestCompany', PostalCode='22222');
    insert TestLead;
    // Family Account
    TestFamilyAccount = new Account (name='TestFamilyAccount',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Family').getRecordTypeId());
    insert TestFamilyAccount;
    system.debug('TestFamily Account is ' + TestFAmilyAccount);
    TestFamilyContact = new Contact(lastname='FamilyContact',
    FirstName = 'Test',
    email = 'testfamilycontact@dontbotherme.org',
    accountId = TestFamilyAccount.Id);
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


    public Case fetchTestCase(){
        TestCase = new Case(
                AccountId = TestAccount.Id,
                ContactId = TestContact.Id,
                Subject = 'Just testing'
        );
        insert TestCase;
        return TestCase;
    }

    public Account fetchFamilyTestAccount() {
        return TestFamilyAccount;}

    public Contact fetchTestFamilyContact() {
        return TestFamilyContact;}
    
public Lead fetchTestLead() {
    return TestLead;}

}