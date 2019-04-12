@isTest
private class Public_Event_Signin_Test {

        private static PageReference pageRef;
    
static testMethod void ContactRegistered() {
    WGSettings__mdt Setting = WGHelpers.getWGSettings();
    string mailing_list = Setting.online_signup_newsletter__c;
        
    //Set up the mailing lists so they're not hard-coded
        Schema.DescribeFieldResult F =Contact.Mailing_lists__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        if (P.size() < 2) {
            apexpages.Message NeedMailingListValues = new
                apexpages.Message(apexpages.Severity.FATAL, 'Aborted test.  Must have at least 2 mailing list values in order to run tests.  Add them to Contact and Lead fields.');
        }
        String mailing_list1 = P[0].getValue();
        String mailing_list2 = P[1].getValue();
        System.debug('mailing_list1 is ' + mailing_list1);
        System.debug('mailing_list2 is ' + mailing_list2);
        
// Create a campaign
    Campaign Testcampaign = new Campaign(Name = 'Testcampaign', Capacity__c = 20,
        Event_Date_Time__c = Datetime.newInstance(2050, 12, 1, 12, 30, 2), Description = 'description',
        Event_Cost__c = 20.00, Waiver_Required__c = true, RecordTypeId = [select Id from RecordType where Name = 'Public Event'].Id);
    insert Testcampaign;

//  Sign up a contact and a lead to the campaign
        Account Testaccount = new Account (Name='TestAccount');
        insert Testaccount;
        Contact TestContact = new Contact (FirstName='Test', LastName='TestContact', Email='testcontact@dontbotherme.org', AccountId = Testaccount.Id,
            Mailing_Lists__c = null);
        insert TestContact;
        Id testcontactid = TestContact.Id;
        CampaignMember Testcampmmbr = new CampaignMember (ContactId = TestContact.Id, CampaignId = Testcampaign.Id, Status = 'Responded yes', Agreed_to_Waiver__c = true);
        Insert Testcampmmbr;
/*      
//TRY TESTING THIS FOR THE WATERGRASS WEB PROFILE
Profile p = [SELECT Id FROM Profile WHERE Name='WaterGrass Web Profile']; 
      user u = new User(Alias = 'WGWeb', Email='WGWebUser@testorg.com', 
      EmailEncodingKey='UTF-8', LastName='WGWebUser', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='WGWebUser@testorg.com');
      insert u;

      System.runAs(u) {
*/      
        
//  Test 1: Person has RSVPed and signs in - does their campaign status change to "RSVPed and Attended"?
    pageRef = Page.Public_Event_Signin_page;
    pageRef.getParameters().put('id', Testcampaign.Id);
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(Testcampaign);
    Public_Event_Signin_Controller PESC = new Public_Event_Signin_Controller(sc);
    PESC.getCamp();
    System.assertEquals(false,PESC.createnewlead);
    System.assertEquals('Testcampaign', PESC.camp.Name);
// Test Admin page - Is the SignIn list empty?  
    PESC.calculateTotals();
    List<CampaignMember> cm = PESC.getSignIns();
    System.assertEquals(0,cm.size());
// Test Admin page - Is one person in the NotYetHere list?  
    cm = PESC.getNotYetHere();
    System.assertEquals(1,cm.size());
    PESC.getpcampmmbr();
    PESC.getpContact();
    PESC.pcontact.FirstName ='Test';
    PESC.pcontact.LastName = 'TestContact';
    PESC.pcontact.Email = 'testcontact@dontbotherme.org';
    PESC.pcontact.MailingPostalCode = '22223';
    PESC.signMeIn();
//  System.assertEquals('RSVPed and Attended',[select status from campaignMember where contactid = :testcontactid][0].status);
// Test Admin page - Is one person in the SignIn list?  
    PESC.calculateTotals();
    cm = PESC.getSignIns();
    //System.assertEquals(1,cm.size());
// Test Admin page - Is the NotYetHere list empty?  
    cm = PESC.getNotYetHere();
    System.assertEquals(0,cm.size());
    String nextPage = PESC.returnToSignin().getUrl();
    System.assertEquals('/apex/public_event_signin_page?id=' + Testcampaign.Id,nextPage);
} // end ContactRegistered


static testmethod void ContactRegisteredNoWaiver() {
    //  Test 2: Person has RSVPed but hasn't signed waiver - are they required to sign waiver?
    //  Test mailing_list insert    
    //Set up the mailing lists so they're not hard-coded
        Schema.DescribeFieldResult F =Contact.Mailing_lists__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        if (P.size() < 2) {
            apexpages.Message NeedMailingListValues = new
                apexpages.Message(apexpages.Severity.FATAL, 'Aborted test.  Must have at least 2 mailing list values in order to run tests.  Add them to Contact and Lead fields.');
        }
        String mailing_list1 = P[0].getValue();
        String mailing_list2 = P[1].getValue();
        System.debug('mailing_list1 is ' + mailing_list1);
        System.debug('mailing_list2 is ' + mailing_list2);

    WGSettings__mdt Setting = WGHelpers.getWGSettings();
    string mailing_list = Setting.online_signup_newsletter__c;
            
// Create campaign, account, contact, campaignmember with Agreed_to_Wavier = false
    Campaign Testcampaign = new Campaign(Name = 'Testcampaign', Capacity__c = 20,
        Event_Date_Time__c = Datetime.newInstance(2050, 12, 1, 12, 30, 2), Description = 'description',
        Event_Cost__c = 20.00, Waiver_Required__c = true, RecordTypeId = [select Id from RecordType where Name = 'Public Event'].Id);
    insert Testcampaign;        
        Account Testaccount = new Account (Name='TestAccount');
        insert Testaccount;
        Contact TestContact = new Contact (FirstName='Test', LastName='TestContact', Email='testcontact@dontbotherme.org', AccountId = Testaccount.Id);
        insert TestContact;
        Id testcontactid = TestContact.Id;
        CampaignMember Testcampmmbr = new CampaignMember (ContactId = TestContact.Id, CampaignId = Testcampaign.Id, Status = 'Responded Yes', Agreed_to_Waiver__c = false);
        Insert Testcampmmbr;
    
    pageRef = Page.Public_Event_Signin_page;
    pageRef.getParameters().put('id',Testcampaign.Id);
        Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(Testcampaign);
    Public_Event_Signin_Controller PESC2 = new Public_Event_Signin_Controller(sc);
    System.assertEquals(false, PESC2.createnewlead);
    PESC2.getCamp();
    System.assertEquals(false,PESC2.createnewlead);
    System.assertEquals('Testcampaign', PESC2.camp.Name);
    PESC2.getpcampmmbr();
    PESC2.getpContact();
    PESC2.pcontact.FirstName ='Test';
    PESC2.pcontact.LastName = 'TestContact';
    PESC2.pcontact.Email = 'testcontact@dontbotherme.org';
    String nextPage = PESC2.signMeIn().getUrl();
    System.assertEquals(PESC2.Agreed_To_Waiver,false);
    System.assertEquals('/apex/public_event_signin_waiver_page', nextPage);
        // Attempt to sign in without accepted waiver
    System.assertEquals(null,PESC2.submit2());
    System.assertEquals(PESC2.Must_Sign_Waiver, true);
    PESC2.Agreed_To_Waiver = true;
    PESC2.pcontact.Over_18__c = true;
    PESC2.enewsletters = true;
    nextPage = PESC2.submit2().getUrl();
    System.assertEquals('/apex/public_event_signin_page?id=' + Testcampaign.Id,nextPage);   
    //System.assertEquals('RSVPed and Attended',[select status from campaignMember where contactid = :testcontactid][0].status);
    List<Contact> ctcts = [select Id, Over_18__c, Mailing_Lists__c from Contact where Email = 'testcontact@dontbotherme.org'];
    System.assertEquals(true,ctcts[0].Over_18__c);
    //No reason to assume that the picklist values from Mailing_Lists__c are the same as the value in the metadata.
    //System.assertEquals(mailing_list1,ctcts[0].Mailing_Lists__c);
} // End ContactRegisteredNoWaiver


static testmethod void ContactNotRegistered() {     

    } // End ContactNotRegistered

// Test 4: Person with new name, shared email = is new contact created in shared email's account?
static testmethod void ContactEmailNotNameInDatabase() {
    WGSettings__mdt Setting = WGHelpers.getWGSettings();
    string mailing_list = Setting.online_signup_newsletter__c;
        
    //Set up the mailing lists so they're not hard-coded
        Schema.DescribeFieldResult F =Contact.Mailing_lists__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        if (P.size() < 2) {
            apexpages.Message NeedMailingListValues = new
                apexpages.Message(apexpages.Severity.FATAL, 'Aborted test.  Must have at least 2 mailing list values in order to run tests.  Add them to Contact and Lead fields.');
        }
        String mailing_list1 = P[0].getValue();
        String mailing_list2 = P[1].getValue();
        System.debug('mailing_list1 is ' + mailing_list1);
        System.debug('mailing_list2 is ' + mailing_list2);

        Campaign Testcampaign = new Campaign(Name = 'Testcampaign', Capacity__c = 20,
        Event_Date_Time__c = Datetime.newInstance(2050, 12, 1, 12, 30, 2), Description = 'description',
        Event_Cost__c = 20.00, Waiver_Required__c = true, RecordTypeId = [select Id from RecordType where Name = 'Public Event'].Id);
    insert Testcampaign;        
        Account Testaccount = new Account (Name='TestAccount');
        insert Testaccount;
        Contact TestContact = new Contact (FirstName='Test', LastName='TestContact', Email='testcontact@dontbotherme.org', AccountId = Testaccount.Id);
        insert TestContact;
        Id testcontactid = TestContact.Id;
        CampaignMember Testcampmmbr = new CampaignMember (ContactId = TestContact.Id, CampaignId = Testcampaign.Id, Status = 'RSVP yes', Agreed_to_Waiver__c = false);
        Insert Testcampmmbr;
    
    pageRef = Page.Public_Event_Signin_page;
    pageRef.getParameters().put('id',Testcampaign.Id);
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(Testcampaign);
    Public_Event_Signin_Controller PESC4 = new Public_Event_Signin_Controller(sc);
    System.assertEquals(false, PESC4.createnewlead);
    Testcampmmbr.Agreed_to_Waiver__c = true;
        update Testcampmmbr;
    PESC4.getCamp();
    System.assertEquals(false,PESC4.createnewlead);
    System.assertEquals('Testcampaign', PESC4.camp.Name);
    PESC4.getpContact();
    PESC4.getpcampmmbr();
    PESC4.pcontact.FirstName ='Test';
    PESC4.pcontact.LastName = 'TestContact2';
    PESC4.pcontact.Email = 'testcontact@dontbotherme.org';
    String nextPage = PESC4.signMeIn().getUrl();
    System.assertEquals('/apex/public_event_signin_page2',nextPage);
    PESC4.pcontact.MailingCity = 'TestCity';
    nextPage = PESC4.submit1().getUrl();
    System.assertEquals('/apex/public_event_signin_waiver_page?id=' + Testcampaign.Id,nextPage);
    PESC4.Agreed_To_Waiver = true;
    nextPage = PESC4.submit2().getUrl();
    System.assertEquals('/apex/public_event_signin_page?id=' + Testcampaign.Id,nextPage);
    List<Contact> checkcontacts = [select Id from Contact where Email = 'testcontact@dontbotherme.org'];
    System.assertEquals(2,checkcontacts.size());
    List<Contact> checkcontact = [select Id from Contact where Email = 'testcontact@dontbotherme.org'
        and LastName = 'TestContact2'];
    String checkStatus = [select Id, Status from CampaignMember where ContactId = :checkcontact[0].Id].Status;
    // System.assertEquals('Attended',checkStatus); 
        
    } // End Person with New Name, Shared Email

static testMethod void LeadRegistered() {
    WGSettings__mdt Setting = WGHelpers.getWGSettings();
    string mailing_list = Setting.online_signup_newsletter__c;
        
    //Set up the mailing lists so they're not hard-coded
        Schema.DescribeFieldResult F =Contact.Mailing_lists__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        if (P.size() < 2) {
            apexpages.Message NeedMailingListValues = new
                apexpages.Message(apexpages.Severity.FATAL, 'Aborted test.  Must have at least 2 mailing list values in order to run tests.  Add them to Contact and Lead fields.');
        }
        String mailing_list1 = P[0].getValue();
        String mailing_list2 = P[1].getValue();
        System.debug('mailing_list1 is ' + mailing_list1);
        System.debug('mailing_list2 is ' + mailing_list2);
        
// Create a campaign
    Campaign Testcampaign = new Campaign(Name = 'Testcampaign', Capacity__c = 20,
        Event_Date_Time__c = Datetime.newInstance(2050, 12, 1, 12, 30, 2), Description = 'description',
        Event_Cost__c = 20.00, Waiver_Required__c = true, RecordTypeId = [select Id from RecordType where Name = 'Public Event'].Id);
    insert Testcampaign;

//  Sign up a contact and a lead to the campaign
        Account Testaccount = new Account (Name='TestAccount');
        insert Testaccount;
        Lead Testlead = new Lead (FirstName='Test', LastName='TestLead', Email='testlead@dontbotherme.org', Company = 'TestLeadCompany');
        insert Testlead;
        Id testleadid = Testlead.Id;
        CampaignMember Testcampmmbr = new CampaignMember (LeadId = Testlead.Id, CampaignId = Testcampaign.Id, Status = 'Responded yes', Agreed_to_Waiver__c = true);
        Insert Testcampmmbr;

//  Test 1: Lead has RSVPed and signs in - does their campaign status change to "RSVPed and Attended"?
    pageRef = Page.Public_Event_Signin_page;
    pageRef.getParameters().put('id', Testcampaign.Id);
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(Testcampaign);
    Public_Event_Signin_Controller PESC5 = new Public_Event_Signin_Controller(sc);
    PESC5.getCamp();
    System.assertEquals(false,PESC5.createnewlead);
    System.assertEquals('Testcampaign', PESC5.camp.Name);
    PESC5.getpcampmmbr();
    PESC5.getpContact();
    PESC5.pcontact.FirstName ='Test';
    PESC5.pcontact.LastName = 'TestLead';
    PESC5.pcontact.Email = 'testlead@dontbotherme.org';
    PESC5.pcontact.MailingPostalCode = '22223';
    PESC5.signMeIn();
    String statuscheck = [select Id,Status from CampaignMember where LeadId = :testleadid][0].Status;
    //System.assertEquals('RSVPed and Attended', statuscheck);
} // end ContactRegistered

static testMethod void LeadRegisterednoWaiver() {
    WGSettings__mdt Setting = WGHelpers.getWGSettings();
    string mailing_list = Setting.online_signup_newsletter__c;
        
    //Set up the mailing lists so they're not hard-coded
        Schema.DescribeFieldResult F =Contact.Mailing_lists__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        if (P.size() < 2) {
            apexpages.Message NeedMailingListValues = new
                apexpages.Message(apexpages.Severity.FATAL, 'Aborted test.  Must have at least 2 mailing list values in order to run tests.  Add them to Contact and Lead fields.');
        }
        String mailing_list1 = P[0].getValue();
        String mailing_list2 = P[1].getValue();
        System.debug('mailing_list1 is ' + mailing_list1);
        System.debug('mailing_list2 is ' + mailing_list2);
        
// Create a campaign
    Campaign Testcampaign = new Campaign(Name = 'Testcampaign', Capacity__c = 20,
        Event_Date_Time__c = Datetime.newInstance(2050, 12, 1, 12, 30, 2), Description = 'description',
        Event_Cost__c = 20.00, Waiver_Required__c = true, RecordTypeId = [select Id from RecordType where Name = 'Public Event'].Id);
    insert Testcampaign;

//  Sign up a contact and a lead to the campaign
        Account Testaccount = new Account (Name='TestAccount');
        insert Testaccount;
        Lead Testlead = new Lead (FirstName='Test', LastName='TestLead', Email='testlead@dontbotherme.org', Company = 'TestLeadCompany');
        insert Testlead;
        Id testleadid = Testlead.Id;
        CampaignMember Testcampmmbr = new CampaignMember (LeadId = Testlead.Id, CampaignId = Testcampaign.Id, Status = 'Responded yes', Agreed_to_Waiver__c = false);
        Insert Testcampmmbr;

//  Test 1: Lead has RSVPed and signs in - does their campaign status change to "RSVPed and Attended"?
    pageRef = Page.Public_Event_Signin_page;
    pageRef.getParameters().put('id', Testcampaign.Id);
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(Testcampaign);
    Public_Event_Signin_Controller PESC6 = new Public_Event_Signin_Controller(sc);
    PESC6.getCamp();
    System.assertEquals(false,PESC6.createnewlead);
    System.assertEquals('Testcampaign', PESC6.camp.Name);
    PESC6.getpcampmmbr();
    PESC6.getpContact();
    PESC6.pcontact.FirstName ='Test';
    PESC6.pcontact.LastName = 'TestLead';
    PESC6.pcontact.Email = 'testlead@dontbotherme.org';
    PESC6.pcontact.MailingPostalCode = '22223';
    String nextPage = PESC6.signMeIn().getUrl();
    System.assertEquals('/apex/public_event_signin_waiver_page',nextPage);
    PESC6.Agreed_To_Waiver = true;
    PESC6.pcontact.Over_18__c = true;
    nextPage = PESC6.submit2().getUrl();
    System.assertEquals('/apex/public_event_signin_page?id=' + Testcampaign.Id,nextPage);
    List<Contact> checkcontacts = [select Id from Contact where Email = 'testlead@dontbotherme.org'];
    System.assertEquals(1,checkcontacts.size());
    String checkStatus = [select Id, Status from CampaignMember where ContactId = :checkcontacts[0].Id].Status;
    //System.assertEquals('RSVPed and Attended',checkStatus);   
    System.assertEquals(true,[select Id, Over_18__c from Contact where Email = 'testlead@dontbotherme.org'][0].Over_18__c);
} // end LeadRegisteredNoWaiver


static testMethod void LeadExistsButNotRegistered() {
    WGSettings__mdt Setting = WGHelpers.getWGSettings();
    string mailing_list = Setting.online_signup_newsletter__c;
        
    //Set up the mailing lists so they're not hard-coded
        Schema.DescribeFieldResult F =Contact.Mailing_lists__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        if (P.size() < 2) {
            apexpages.Message NeedMailingListValues = new
                apexpages.Message(apexpages.Severity.FATAL, 'Aborted test.  Must have at least 2 mailing list values in order to run tests.  Add them to Contact and Lead fields.');
        }
        String mailing_list1 = P[0].getValue();
        String mailing_list2 = P[1].getValue();
        System.debug('mailing_list1 is ' + mailing_list1);
        System.debug('mailing_list2 is ' + mailing_list2);
        
// Create a campaign
    Campaign Testcampaign = new Campaign(Name = 'Testcampaign', Capacity__c = 20,
        Event_Date_Time__c = Datetime.newInstance(2050, 12, 1, 12, 30, 2), Description = 'description',
        Event_Cost__c = 20.00, Waiver_Required__c = true, RecordTypeId = [select Id from RecordType where Name = 'Public Event'].Id);
    insert Testcampaign;

//  Sign up a contact and a lead to the campaign
        Account Testaccount = new Account (Name='TestAccount');
        insert Testaccount;
        Lead Testlead = new Lead (FirstName='Test', LastName='TestLead', Email='testlead@dontbotherme.org', Company = 'TestLeadCompany');
        insert Testlead;
        Id testleadid = Testlead.Id;
        //Campaignmember Testcampmmbr = new Campaignmember (LeadID = TestLead.ID, CampaignID = Testcampaign.ID, Status = 'Responded yes', Agreed_to_Waiver__c = false);
        //Insert Testcampmmbr;

    pageRef = Page.Public_Event_Signin_page;
    pageRef.getParameters().put('id', Testcampaign.Id);
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(Testcampaign);
    Public_Event_Signin_Controller PESC7 = new Public_Event_Signin_Controller(sc);
    PESC7.getCamp();
    System.assertEquals(false,PESC7.createnewlead);
    System.assertEquals('Testcampaign', PESC7.camp.Name);
    PESC7.getpcampmmbr();
    PESC7.getpContact();
    PESC7.pcontact.FirstName ='Test';
    PESC7.pcontact.LastName = 'TestLead';
    PESC7.pcontact.Email = 'testlead@dontbotherme.org';
    PESC7.pcontact.MailingPostalCode = '22223';
    String nextPage = PESC7.signMeIn().getUrl();
    //System.assertEquals('/apex/public_event_signin_page2',nextPage);
    //PESC7.pcontact.MailingCity = 'TestCity';
    //nextPage = PESC7.submit2().getURL();
    System.assertEquals('/apex/public_event_signin_waiver_page',nextPage);
    PESC7.Agreed_To_Waiver = true;
    nextPage = PESC7.submit2().getUrl();
    System.assertEquals('/apex/public_event_signin_page?id=' + Testcampaign.Id,nextPage);
    List<Contact> checkcontacts = [select Id from Contact where Email = 'testlead@dontbotherme.org'];
    System.assertEquals(1,checkcontacts.size());
    String checkStatus = [select Id, Status from CampaignMember where ContactId = :checkcontacts[0].Id].Status;
    //System.assertEquals('Attended',checkStatus);  
} // end LeadExistsButNotRegistered

// Test 8: Person with new name, new email 
static testmethod void ContactNewEmailNewName() {
    WGSettings__mdt Setting = WGHelpers.getWGSettings();
    string mailing_list = Setting.online_signup_newsletter__c;
        
    //Set up the mailing lists so they're not hard-coded
        Schema.DescribeFieldResult F =Contact.Mailing_lists__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        if (P.size() < 2) {
            apexpages.Message NeedMailingListValues = new
                apexpages.Message(apexpages.Severity.FATAL, 'Aborted test.  Must have at least 2 mailing list values in order to run tests.  Add them to Contact and Lead fields.');
        }
        String mailing_list1 = P[0].getValue();
        String mailing_list2 = P[1].getValue();
        System.debug('mailing_list1 is ' + mailing_list1);
        System.debug('mailing_list2 is ' + mailing_list2);

        Campaign Testcampaign = new Campaign(Name = 'Testcampaign', Capacity__c = 20,
        Event_Date_Time__c = Datetime.newInstance(2050, 12, 1, 12, 30, 2), Description = 'description',
        Event_Cost__c = 20.00, Waiver_Required__c = true, RecordTypeId = [select Id from RecordType where Name = 'Public Event'].Id);
    insert Testcampaign;        
    
    pageRef = Page.Public_Event_Signin_page;
    pageRef.getParameters().put('id',Testcampaign.Id);
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(Testcampaign);
    Public_Event_Signin_Controller PESC8 = new Public_Event_Signin_Controller(sc);
    System.assertEquals(false, PESC8.createnewlead);
//  Testcampmmbr.Agreed_to_Waiver__c = true;
//      update Testcampmmbr;
    PESC8.getCamp();
    System.assertEquals(false,PESC8.createnewlead);
    System.assertEquals('Testcampaign', PESC8.camp.Name);
    PESC8.getpContact();
    PESC8.getpcampmmbr();
    PESC8.pcontact.FirstName ='Test';
    PESC8.pcontact.LastName = 'TestContact2';
    PESC8.pcontact.Email = 'testcontact2@dontbotherme.org';
    String nextPage = PESC8.signMeIn().getUrl();
    System.assertEquals('/apex/public_event_signin_page2',nextPage);
    PESC8.pcontact.Description = 'TestOrganization';
    PESC8.pcontact.MailingCity = 'TestCity';
    PESC8.getInterests();
    nextPage = PESC8.submit1().getUrl();
    System.assertEquals('/apex/public_event_signin_waiver_page?id=' + Testcampaign.Id,nextPage);
    PESC8.Agreed_To_Waiver = true;
    nextPage = PESC8.submit2().getUrl();
    System.assertEquals('/apex/public_event_signin_page?id=' + Testcampaign.Id,nextPage);
    List<Contact> checkcontacts = [select Id, Account.Name from Contact where Email = 'testcontact2@dontbotherme.org'];
    System.assertEquals(1,checkcontacts.size());
        System.assertEquals('TestOrganization',checkcontacts[0].Account.Name);
    List<Contact> checkcontact = [select Id, AccountId from Contact where Email = 'testcontact2@dontbotherme.org'
        and LastName = 'TestContact2'];
    String checkStatus = [select Id, Status from CampaignMember where ContactId = :checkcontact[0].Id].Status;
    //System.assertEquals('Attended',checkStatus);  
    Account checkaccount = [select Id, Name, Dear__c, BillingCity from Account where Id = :checkcontact[0].AccountId];
    System.assertEquals('TestOrganization',checkaccount.Name);
    System.assertEquals('Test',checkaccount.Dear__c);
    System.assertEquals('TestCity',checkaccount.BillingCity);
        
        
    } // End Complete New Person


     // } // END RUN AS WATERGRASS WEB PROFILE

}