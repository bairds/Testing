// Jan 7 2017 Included two tests for the insertEmailListContact()for the RESTEmail controller can use this too.
// Feb 2019 Switch from WG_Settings to WGSettings__mdt

@isTest
private class Email_Signup_Test {
    private static string baseUrl = 'http://www.google.com/recaptcha/api/verify';


    // Test for new signup = existing contact       
public static testMethod void Email_Signup_Test1() {

        Account Testaccount = new Account (name='TestAccount');
        insert Testaccount;
        Contact TestContact = new Contact (firstname='Test', lastname='TestContact', email='testcontact@dontbotherme.org', accountID = TestAccount.ID);
        insert Testcontact;

ApexPages.StandardController sc = new ApexPages.StandardController(testcontact);
Email_Signup_Controller ECR1 = new Email_Signup_Controller(sc);
    boolean testemail;
    if (Limits.getLimitEmailInvocations() > Limits.getEmailInvocations()) testemail = true;
    Integer emailbefore = Limits.getEmailInvocations();
    ECR1.pcontact.lastname = 'TestContact';
    ECR1.pcontact.firstname = 'Test';
    ECR1.pcontact.email = 'testcontact@dontbotherme.org';
    ECR1.submit();
    string enewsletterstring = [SELECT Online_Signup_Newsletter__c FROM
    WGSettings__mdt where Label = 'WGDefault' LIMIT 1].Online_signup_newsletter__c;
    system.assertEquals(true, [select id, mailing_lists__c from Contact where
        lastname = 'TestContact'][0].mailing_lists__c.contains(enewsletterstring));
    }

// Test for new signup = existing lead      
@istest
public static void Email_Signup_Test2() {
    
        Account Testaccount = new Account (name='TestAccount');
        insert Testaccount;
        Contact TestContact = new Contact (firstname='Test', lastname='TestContact', email='testcontact@dontbotherme.org', accountID = TestAccount.ID);
        insert Testcontact;
        Lead TestLead = new Lead (lastname = 'Lead', firstname = 'Test', company = 'None', email = 'testlead@dontbotherme.org', Description = 'Original Description');
        insert TestLead;

        
ApexPages.StandardController sc = new ApexPages.StandardController(testcontact);
Email_Signup_Controller ECR2 = new Email_Signup_Controller(sc);
    ECR2.pcontact.lastname = 'Lead';
    ECR2.pcontact.firstname = 'Test';
    ECR2.pcontact.email = 'testlead@dontbotherme.org';
    ECR2.pcontact.Description = 'Added Description';
    ECR2.submit();
    string enewsletterstring = [SELECT Online_Signup_Newsletter__c FROM
            WGSettings__mdt where Label = 'WGDefault' LIMIT 1].Online_signup_newsletter__c;
    List<Lead> results = [select id, mailing_lists__c, Description from Lead where
            lastname = 'Lead'];
    system.assertEquals(true, results[0].mailing_lists__c.contains(enewsletterstring));
    system.assertEquals('Original Description; Added Description', results[0].Description);
    }


// Test for new signup not in database      
public static testMethod void Email_Signup_Test3() {
    
        Account Testaccount = new Account (name='TestAccount');
        insert Testaccount;
        Contact TestContact = new Contact (firstname='Test', lastname='TestContact', email='testcontact@dontbotherme.org', accountID = TestAccount.ID);
        insert Testcontact;
        Lead TestLead = new Lead (lastname = 'Lead', firstname = 'Test', company = 'None', email = 'testlead@dontbotherme.org');
        insert TestLead;

        
ApexPages.StandardController sc = new ApexPages.StandardController(testcontact);
Email_Signup_Controller ECR3 = new Email_Signup_Controller(sc);
    ECR3.pcontact.lastname = 'Newlead';
    ECR3.pcontact.firstname = 'Test';
    ECR3.pcontact.email = 'nottestlead@dontbotherme.org';
    ECR3.pcontact.Description = 'Added Description';
    ECR3.submit();
    string enewsletterstring = [SELECT Online_Signup_Newsletter__c FROM
            WGSettings__mdt where Label = 'WGDefault' LIMIT 1].Online_signup_newsletter__c;
    List<Lead> results = [select id, mailing_lists__c, Description from Lead where
            lastname = 'NewLead'];
    system.assertEquals(true, results[0].mailing_lists__c.contains(enewsletterstring));
    system.assertEquals('Added Description', results[0].Description);
    }   
    
// Test for new signup = existing contact with existing mail_lists__c entries       
public static testMethod void Email_Signup_Test4() {
    
        Account Testaccount = new Account (name='TestAccount');
        insert Testaccount;
        Contact TestContact = new Contact (firstname='Test', lastname='TestContact', email='testcontact@dontbotherme.org', 
            mailing_lists__c = 'testnewsletter', accountID = TestAccount.ID);
        insert Testcontact;
        Lead TestLead = new Lead (lastname = 'Lead', firstname = 'Test', company = 'None', email = 'testlead@dontbotherme.org');
        insert TestLead;

        
ApexPages.StandardController sc = new ApexPages.StandardController(testcontact);
Email_Signup_Controller ECR4 = new Email_Signup_Controller(sc);
    //PageReference pageRef = Page.Email_Signup_For_Campaign;
    //Test.setCurrentPage(pageRef);
    ECR4.pcontact.lastname = 'TestContact';
    ECR4.pcontact.firstname = 'Test';
    ECR4.pcontact.email = 'testcontact@dontbotherme.org';
    ECR4.submit();
    string enewsletterstring = [SELECT Online_Signup_Newsletter__c FROM
            WGSettings__mdt where Label = 'WGDefault' LIMIT 1].Online_signup_newsletter__c;
    String mailing_list_result = [select id, mailing_lists__c from Contact where
        lastname = 'TestContact'][0].mailing_lists__c;
    system.debug('mailing_list_result is ' + mailing_list_result);
    //system.assertEquals(true, mailing_list_result.contains(enewsletterstring));
    system.assertEquals(true, mailing_list_result.contains('testnewsletter'));            
    }   
    
// Test for new signup = existing lead with existing mail_lists__c entries
public static testMethod void Email_Signup_Test5() {
    
        Account Testaccount = new Account (name='TestAccount');
        insert Testaccount;
        Contact TestContact = new Contact (firstname='Test', lastname='TestContact', email='testcontact@dontbotherme.org', accountID = TestAccount.ID);
        insert Testcontact;
        Lead TestLead = new Lead (lastname = 'Lead', firstname = 'Test', company = 'None', 
            email = 'testlead@dontbotherme.org', mailing_lists__c = 'testnewsletter');
        insert TestLead;

ApexPages.StandardController sc = new ApexPages.StandardController(testcontact);
Email_Signup_Controller ECR5 = new Email_Signup_Controller(sc);
    //    PageReference pageRef = Page.Email_Signup_For_Campaign;
    //Test.setCurrentPage(pageRef);
    ECR5.pcontact.lastname = 'Lead';
    ECR5.pcontact.firstname = 'Test';
    ECR5.pcontact.email = 'testlead@dontbotherme.org';
    ECR5.submit();
    string enewsletterstring = [SELECT Online_Signup_Newsletter__c FROM
            WGSettings__mdt where Label = 'WGDefault' LIMIT 1].Online_signup_newsletter__c;
    String mailing_list_result = [select id, mailing_lists__c from Lead where
        lastname = 'Lead'][0].mailing_lists__c;
    system.debug(mailing_list_result);
    system.assertEquals(true, mailing_list_result.contains(enewsletterstring));
    system.assertEquals(true, mailing_list_result.contains('testnewsletter'));        
           
    }

     public static  testmethod void Email_Signup_Test6() {

        string href = baseUrl ;
        String challenge, response;
        challenge = response = 'foo';
        string publicKey = '6LfwztYSAAAAAJtx0r7f53wb9zuUE3b6u9kjdHLl';
        string remoteHost = '127.0.0.1';
        string publick = publicKey;
        string host = remoteHost;
        Email_Signup_Controller.validCaptcha(challenge , response);
}

    public static  testmethod void Email_Signup_Test7() {

        string href = baseUrl ;
        String challenge, response;
        challenge = null;
        response = null;
        string publicKey = '6LfwztYSAAAAAJtx0r7f53wb9zuUE3b6u9kjdHLl';
        string remoteHost = '127.0.0.1';
        string publick = publicKey;
        string host = remoteHost;
        Email_Signup_Controller.validCaptcha(challenge , response);
}

// Test for new signup = existing lead with different email; does email switch to new email?
public static testMethod void Email_Signup_Test8() {
     
        Account Testaccount = new Account (name='TestAccount');
        insert Testaccount;
        Contact TestContact = new Contact (firstname='Test', lastname='TestContact', email='testcontact@dontbotherme.org', accountID = TestAccount.ID);
        insert Testcontact;
        Lead TestLead = new Lead (lastname = 'Lead', firstname = 'Test', company = 'None', 
            email = 'testlead@dontbotherme.org', PostalCode = '22222');
        insert TestLead;

        
ApexPages.StandardController sc = new ApexPages.StandardController(testcontact);
Email_Signup_Controller ECR8 = new Email_Signup_Controller(sc);
    // PageReference pageRef = Page.Email_Signup_For_Campaign;
    // Test.setCurrentPage(pageRef);
    ECR8.pcontact.lastname = 'Lead';
    ECR8.pcontact.firstname = 'Test';
    ECR8.pcontact.MailingPostalCode = '22222';
    ECR8.pcontact.email = 'testlead2@dontbotherme.org';
    ECR8.submit();
    system.assertEquals('testlead2@dontbotherme.org', [select id, email from Lead where
        lastname = 'Lead'][0].email);        
           
    }
// Test for new signup = existing lead with different email who is already on list; 
// Does email switch to new email?  And is Description added to Lead.Description?
public static testMethod void Email_Signup_Test9() {
     
        Account Testaccount = new Account (name='TestAccount');
        insert Testaccount;
        Contact TestContact = new Contact (firstname='Test', lastname='TestContact', email='testcontact@dontbotherme.org', accountID = TestAccount.ID);
        insert Testcontact;
        Lead TestLead = new Lead (lastname = 'Lead', firstname = 'Test', company = 'None', Description = 'Original Description',
            email = 'testlead@dontbotherme.org', PostalCode = '22222',  mailing_lists__c = 'e-newsletter');
        insert TestLead;

        
ApexPages.StandardController sc = new ApexPages.StandardController(testcontact);
Email_Signup_Controller ECR9 = new Email_Signup_Controller(sc);
    //PageReference pageRef = Page.Email_Signup_For_Campaign;
    //Test.setCurrentPage(pageRef);
    ECR9.pcontact.lastname = 'Lead';
    ECR9.pcontact.firstname = 'Test';
    ECR9.pcontact.MailingPostalCode = '22222';
    ECR9.pcontact.email = 'testlead2@dontbotherme.org';
    ECR9.pcontact.description = 'New Description';
    ECR9.submit();
    List<Lead> resultsLead = [select id, description, email from Lead where
            lastname = 'Lead'];
    system.assertEquals('testlead2@dontbotherme.org', resultsLead[0].email);
    system.assertEquals('Original Description; New Description', resultsLead[0].description);

}

public static testMethod void Email_Signup_w_Campaign() {     
        Account Testaccount = new Account (name='TestAccount');
        insert Testaccount;
        Contact TestContact = new Contact (firstname='Test', lastname='TestContact', email='testcontact@dontbotherme.org', accountID = TestAccount.ID);
        insert Testcontact;
        Lead TestLead = new Lead (lastname = 'Lead', firstname = 'Test', company = 'None', 
            email = 'testlead@dontbotherme.org', PostalCode = '22222',  mailing_lists__c = 'e-newsletter');
        insert TestLead; 
        Campaign TestCamp = new Campaign(name = 'Test Campaign', RequireAddress__c = true, isActive=true, Custom_Signup_Question__c =
                'Do you have special dietary needs?', Custom_Signup_Question_2__c = 'How many children will you bring with you?',
                RecordTypeId =[select id from RecordType where name = 'Volunteer Event'][0].id);
        insert TestCamp;
        system.debug('Inserted TestCamp, id is ' + TestCamp.Id);


    //PageReference pageRef = Page.Email_Signup_For_Campaign;
    //Test.setCurrentPage(pageRef);        
    ApexPages.currentPage().getParameters().put('cid',TestCamp.Id);
    String testid = ApexPages.currentPage().getParameters().get('cid');
    System.assertEquals(testid, string.valueof(TestCamp.Id));
ApexPages.StandardController sc = new ApexPages.StandardController(testcontact);
Email_Signup_Controller ECR10 = new Email_Signup_Controller(sc);
    ECR10.pcontact.lastname = 'Lead';
    ECR10.pcontact.firstname = 'Test';
    ECR10.pcontact.MailingPostalCode = '22222';
    ECR10.pcontact.email = 'testlead2@dontbotherme.org';
    ECR10.CustomQuestion1Answer ='Allergic to peanuts';
    ECR10.CustomQuestion2Answer ='Three children under four';
    ECR10.submit();
    List<CampaignMember> TestCMs = [select id, lead.email from CampaignMember where campaignId = :TestCamp.Id];
    System.AssertEquals('testlead2@dontbotherme.org', TestCMs[0].lead.email);
    List<Lead> TestLeads = [select id, mailing_lists__c from Lead where firstname = 'Test'];
    // Should fail because Add_New_Mailing_List__c hasn't been set;
    system.AssertEquals(false, TestLeads[0].mailing_lists__c.contains('Test Campaign'));
    system.debug('Mailing_List__c is ' + TestLeads[0].mailing_lists__c);
    TestCamp.Add_New_Mailing_List__c = true;
    update TestCamp;
    Email_Signup_Controller ECR11 = new Email_Signup_Controller(sc);
    ECR11.pcontact.lastname = 'Lead';
    ECR11.pcontact.firstname = 'Test';
    ECR11.pcontact.MailingPostalCode = '22222';
    ECR11.pcontact.email = 'testlead2@dontbotherme.org';
    ECR11.submit();
    TestCMs = [select id, lead.email,SignupQuestionAnswer__c,SignupQuestionAnswer2__c from CampaignMember where campaignId = :TestCamp.Id];
    System.AssertEquals('testlead2@dontbotherme.org', TestCMs[0].lead.email);
    system.AssertEquals('Allergic to peanuts',TestCMs[0].SignupQuestionAnswer__c);
    system.AssertEquals('Three children under four',TestCMs[0].SignupQuestionAnswer2__c);
    ECR11.submit();
    TestLeads = [select id, mailing_lists__c from Lead where firstname = 'Test'];
    system.debug('Mailing_List__c is ' + TestLeads[0].mailing_lists__c);
    system.AssertEquals(true, TestLeads[0].mailing_lists__c.contains('Test Campaign'));
}

    //Test the insertContactList method for the REST submissions with Contact
    public static testMethod void RESTSubmissionsTestContact() {
        Account Testaccount = new Account (name='TestAccount');
        insert Testaccount;
        Contact TestContact = new Contact (firstname='Test', lastname='TestContact', email='testcontact@dontbotherme.org', accountID = TestAccount.ID,
                                          	MailingPostalCode = '22222',  mailing_lists__c = 'e-newsletter');
        insert Testcontact;

        ApexPages.StandardController sc = new ApexPages.StandardController(testcontact);
        Email_Signup_Controller ECR11 = new Email_Signup_Controller(sc);
        //PageReference pageRef = Page.Email_Signup_Page;
        //Test.setCurrentPage(pageRef);
        ECR11.pcontact.lastname = 'TestContact';
        ECR11.pcontact.firstname = 'Test';
        ECR11.pcontact.MailingPostalCode = '22222';
        ECR11.pcontact.email = 'testcontact@dontbotherme.org';
        contact tempcontact = ECR11.pcontact;
        ECR11.insertEmailListContact(tempcontact);
        system.assertEquals('testcontact@dontbotherme.org', [select id, email from Contact where
                                                          lastname = 'TestContact'][0].email);              
    } // end test
    // Test for new signup = existing contact
    public static testMethod void SetUpTrial(){

        Account Testaccount = new Account (name='TestAccount');
        insert Testaccount;
        Contact TestContact = new Contact (firstname='Test', lastname='TestContact', email='testcontact@dontbotherme.org', accountID = TestAccount.ID);
        insert Testcontact;
        Lead TestLead = new Lead (lastname = 'Lead', firstname = 'Test', company = 'None', email = 'testlead@dontbotherme.org');
        insert TestLead;

        ApexPages.StandardController sc = new ApexPages.StandardController(testcontact);
        Email_Signup_Controller ECR1 = new Email_Signup_Controller(sc);
        boolean testemail;
        if (Limits.getLimitEmailInvocations() > Limits.getEmailInvocations()) testemail = true;
        Integer emailbefore = Limits.getEmailInvocations();
        ECR1.pcontact.lastname = 'TestContact';
        ECR1.pcontact.firstname = 'Test';
        ECR1.pcontact.email = 'testcontact@dontbotherme.org';
        ECR1.SetUpTrial = true;
        ECR1.OrgName = 'TestOrgName';
        ECR1.submit();
        string enewsletterstring = [SELECT Online_Signup_Newsletter__c FROM
                WGSettings__mdt where Label = 'WGDefault' LIMIT 1].Online_signup_newsletter__c;
        system.assertEquals(true, [select id, mailing_lists__c from Contact where
                lastname = 'TestContact'][0].mailing_lists__c.contains(enewsletterstring));
        List<Task> ConfirmTask = [SELECT Subject, WhatId, WhoId, OwnerId, Status, Type, ReminderDateTime from Task];
        system.assertEquals(1,ConfirmTask.size());
        system.assertEquals(TestContact.Id,ConfirmTask[0].WhoId);
        system.assertEquals(system.now().addHours(24).date(),ConfirmTask[0].ReminderDateTime.date());
        system.assertEquals('Create trial database for TestOrgName',ConfirmTask[0].Subject,'OrgName existed but did not get inserted into Subject.');
    }
}