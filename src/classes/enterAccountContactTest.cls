@isTest
private class enterAccountContactTest {
    
    static testMethod void enterAccountContactTest() {
        //INSTANTIATE THE SIGNIN PAGE
        PageReference pageRef = Page.enterAccountContactPage;
        Test.setCurrentPage(pageRef);
        //INSTANTIATE CONTROLLER	
        //Test when account name provided
        Account acct = new Account();
        //ApexPages.StandardController sc = new ApexPages.standardController();
        enterAccountContact eAC = new enterAccountContact(new ApexPages.StandardController(acct));   
        eAC.aname = 'Test Account Name';
        eAC.ctct.lastname = 'TestLastName';
        eAC.ctct.firstname = 'TestFirstName';
        eAC.ctct.email = 'testemail@test.com';
        eAC.acct.Contacts_in_Account__c = '1';
        eAC.acct.recordTypeID=[select id from RecordType where (name = 'Family' and SobjectType = 'Account')][0].id;
        eAC.submit();
        system.Assert('TestFirstName' == [select Firstname from Contact where Lastname = 'TestLastName'][0].firstName);
        system.debug('acct.dear__c is ' + eAC.acct.dear__c);
        system.debug('Contact where Lastname = TestLastName0.dear__c is ' + [select id, dear__c from Contact where Lastname = 'TestLastName'][0].dear__c);
        system.AssertEquals('TestFirstName',[select id, dear__c from Account where name = 'Test Account Name'][0].dear__c);
        system.AssertEquals(null, [select phone from Contact where Lastname = 'TestLastName'][0].phone);
    } // END enterAccountContactTest when account name provided
    
    
    //Test when account name not provided
    static testMethod void enterAccountContactTest2() {
        //INSTANTIATE THE SIGNIN PAGE
        PageReference pageRef = Page.enterAccountContactPage;
        Test.setCurrentPage(pageRef); 
        Account acct = new Account();
        enterAccountContact eAC2 = new enterAccountContact(new ApexPages.StandardController(acct)); 
        eAC2.aname = '';
        eAC2.acct.phone = '3333333';
        eAC2.acct.Contacts_in_Account__c = '1';
        eAC2.acct.recordTypeID=[select id from RecordType where (name = 'Family' and SobjectType = 'Account')][0].id;
        eAC2.ctct.lastname = 'TestLastName';
        eAC2.ctct.firstname = 'TestFirstName';
        eAC2.ctct.Dear__c = 'Testy';
        eAC2.submit();
        system.AssertEquals('TestLastName, TestFirstName Household',eAC2.acct.Name);
        Contact testctct = [select Firstname, lastname, dear__c, phone from Contact where Lastname = 'TestLastName' limit 1];
        system.Assert('TestFirstName' == testctct.firstName);
        system.Assert('Testy' == testctct.dear__c);
        system.AssertEquals('3333333', testctct.phone);
    } // END WHEN ACCOUNT NAME NOT PROVIDED
    
    //Test when Account Name not provided, Contact2 provided
    static testMethod void enterAccountContactTest3() {
        //INSTANTIATE THE SIGNIN PAGE
        PageReference pageRef = Page.enterAccountContactPage;
        Test.setCurrentPage(pageRef); 	
        Account acct = new Account();
        enterAccountContact eAC3 = new enterAccountContact(new ApexPages.StandardController(acct));
        eAC3.aname = '';
        eAC3.acct.recordTypeID=[select id from RecordType where (name = 'Family' and SobjectType = 'Account')][0].id;
        eAC3.ctct.firstname = 'TestFirstName';
        eAC3.ctct.lastname = 'TestLastName';
        eAC3.ctct.Dear__c = 'Testy1';
        eAC3.ctct2.firstname = 'TestFirstName2';
        eAC3.ctct2.lastname = 'TestLastName2';
        eAC3.ctct2.Dear__c = 'Testy2';
        eAC3.acct.Contacts_in_Account__c = '2';
        eAC3.submit();
        system.AssertEquals('TestLastName, TestFirstName and TestFirstName2 TestLastName2 Household', eAC3.acct.Name);
        system.AssertEquals('Testy1 and Testy2', eAC3.acct.Dear__c);
        system.Assert('TestFirstName' == [select Firstname from Contact where Lastname = 'TestLastName'][0].firstName);
        system.Assert('TestFirstName2' == [select Firstname from Contact where Lastname = 'TestLastName2'][0].firstName);
        system.AssertEquals('Testy1 and Testy2',[select Dear__c from Account where name = 'TestLastName, TestFirstName and TestFirstName2 TestLastName2 Household'][0].dear__c);
    } // END ENTERACCOUNTCONTACTTEST3()
    
    
    //Test when Account Name not provided, Contact2 provided with same lastname
    static testMethod void enterAccountContactTest5() {
        //INSTANTIATE THE SIGNIN PAGE
        PageReference pageRef = Page.enterAccountContactPage;
        Test.setCurrentPage(pageRef); 	
        Account acct = new Account();
        enterAccountContact eAC5 = new enterAccountContact(new ApexPages.StandardController(acct));
        eAC5.aname = '';
        eAC5.acct.recordTypeID=[select id from RecordType where (name = 'Family' and SobjectType = 'Account')][0].id;
        eAC5.ctct.firstname = 'TestFirstName';
        eAC5.ctct.lastname = 'TestLastName';
        eAC5.ctct2.firstname = 'TestFirstName2';
        eAC5.ctct2.lastname = 'TestLastName';
        eAC5.acct.Contacts_in_Account__c = '2';
        eAC5.submit();
        system.AssertEquals('TestLastName, TestFirstName and TestFirstName2 Household', eAC5.acct.Name);
        system.Assert('TestFirstName' == [select Firstname from Contact where Lastname = 'TestLastName'][0].firstName);
        system.Assert('TestFirstName2' == [select Firstname from Contact where Lastname = 'TestLastName'][1].firstName);
        system.AssertEquals('TestFirstName and TestFirstName2',[select Dear__c from Account where name = 'TestLastName, TestFirstName and TestFirstName2 Household'][0].dear__c);
    } // END ENTERACCOUNTCONTACTTEST5()
    
    
    //Test when account name not provided and record type set to something other than Household
    static testMethod void enterAccountContactTest4() {
        //INSTANTIATE THE SIGNIN PAGE
        PageReference pageRef = Page.enterAccountContactPage;
        Test.setCurrentPage(pageRef);
        Account acct = new Account();
        //INSTANTIATE CONTROLLER
        enterAccountContact eAC4 = new enterAccountContact(new ApexPages.StandardController(acct));
        eAC4.aname = '';
        id BusinessRTID = [select id from recordType where name = 'Business'][0].id;
        system.debug('recordTypeID for business is ' + BusinessRTID);
        eAC4.acct.RecordTypeid = BusinessRTID; 
        eAC4.acct.BillingCity = 'Annapolis';   
        system.debug('Just after attempting to set Recordtype to Business, acct.RecordType is ' + eAC4.acct.RecordTypeID);
        system.debug('Just after attempting to set acct.BillingCity to Annapolis, it is ' + eAC4.acct.BillingCity);
        eAC4.ctct.lastname = 'TestLastName';
        eAC4.ctct.firstname = 'TestFirstName';
        eAC4.setAccount();
        // get the list of ApexPages.Message
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        // loop over the messages
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            System.assertEquals('If the account type is not Household, you must enter and Account Name.', msg.getSummary());
            System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
        }
        eAC4.acct.name = 'FinallySubmittedAccountName';
        String nextPage = eAC4.submit().getUrl();
        system.debug('Just after submit(), acct.RecordType is ' + eAC4.acct.RecordTypeID);
        system.AssertEquals(BusinessRTID,eAC4.acct.RecordTypeID);
        //system.AssertEquals('TestFirstName',[select Firstname from Contact where Lastname = 'TestLastName'][0].firstName);
        //System.assertEquals('/apex/enterAccountContactPage', nextPage);
        //System.assertEquals(true, apexPages.hasMessages());
        //System.assertEquals('If the account type is not Household, you must enter and Account Name.', apexPages.hasMessages());
        
        //Test nextEntry
        eAC4.nextEntry();
        System.assertEquals(string.valueOf(ApexPages.currentPage()).toUpperCase(),('System.PageReference[/apex/enterAccountContactPage]').toUpperCase());
        //Run done
        eAC4.done();
        
    } // END enterAccountContactTest4 when account name provided    
    
}