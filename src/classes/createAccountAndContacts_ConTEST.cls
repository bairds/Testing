/**
 * Created by Baird on 9/17/2018.
 * For the createAccountContact component controller
 */
@istest
private class createAccountAndContacts_ConTEST {

    @istest static void testSingleContact() {
        Test.setCurrentPage(Page.enterAccountContactPage);
        createAccountAndContacts_Con CAAC = new createAccountAndContacts_Con();
        CAAC.setContacts();
        // CAAC.setAccount();
        CAAC.acct.Contacts_in_Account__c = '1';
        CAAC.source = 'default';

        // Enter Account Info
        CAAC.aname = '';
        CAAC.acct.RecordTypeID = schema.SObjectType.Account.getRecordTypeInfosbyName().get('Family').getRecordTypeId();
        CAAC.acct.BillingStreet = '303 Morey Ave';
        CAAC.acct.BillingCity = 'Bellingham';
        CAAC.acct.BillingState = 'WA';
        CAAC.acct.BillingPostalCode = '98225';

        // Enter Contact Info
        CAAC.ctct.firstname = 'Test';
        CAAC.ctct.lastname = 'Tester';
        CAAC.ctct.Title = 'Testers Title';
        CAAC.ctct.Homephone = '3333333';
        CAAC.ctct.MobilePhone = '4444444';

        CAAC.submit();

        List<Account> ConfirmAccts = [SELECT id, addressee__c, dear__c, name from Account WHERE BillingStreet = '303 Morey Ave'];
        system.assertEquals('Tester, Test Household', ConfirmAccts[0].name);
        system.assertEquals('Test Tester', ConfirmAccts[0].addressee__c);
        system.assertEquals('Test', ConfirmAccts[0].dear__c);
    }

    @istest static void testTwoContactsSameName() {
        Test.setCurrentPage(Page.enterAccountContactPage);
        createAccountAndContacts_Con CAAC = new createAccountAndContacts_Con();
        CAAC.setContacts();
        // CAAC.setAccount();
        CAAC.acct.Contacts_in_Account__c = '2';
        CAAC.source = 'enterContrib';

        // Enter Account Info
        CAAC.aname = '';
        CAAC.acct.RecordTypeID = schema.SObjectType.Account.getRecordTypeInfosbyName().get('Family').getRecordTypeId();
        CAAC.acct.BillingStreet = '303 Morey Ave';
        CAAC.acct.BillingCity = 'Bellingham';
        CAAC.acct.BillingState = 'WA';
        CAAC.acct.BillingPostalCode = '98225';

        // Enter Contact Info
        CAAC.ctct.firstname = 'Test';
        CAAC.ctct.lastname = 'Tester';
        CAAC.ctct.Title = 'Testers Title';
        CAAC.ctct.Homephone = '3333333';
        CAAC.ctct.MobilePhone = '4444444';

        // Enter Contact Info
        CAAC.ctct2.firstname = 'Testa';
        CAAC.ctct2.lastname = 'Tester';
        CAAC.ctct2.Title = 'Testas Title';
        CAAC.ctct2.Homephone = '3333333';
        CAAC.ctct2.MobilePhone = '44444445';

        CAAC.submit();

        List<Account> ConfirmAccts = [SELECT id, addressee__c, dear__c, name from Account WHERE BillingStreet = '303 Morey Ave'];
        system.assertEquals('Tester, Test and Testa Household', ConfirmAccts[0].name);
        system.assertEquals('Test and Testa Tester', ConfirmAccts[0].addressee__c);
        system.assertEquals('Test and Testa', ConfirmAccts[0].dear__c);
    }
    @istest static void testTwoContactsDifferentNames() {
        Test.setCurrentPage(Page.enterAccountContactPage);
        createAccountAndContacts_Con CAAC = new createAccountAndContacts_Con();
        CAAC.setContacts();
        //CAAC.setAccount();
        CAAC.acct.Contacts_in_Account__c = '2';

        // Enter Account Info
        CAAC.aname = '';
        CAAC.acct.RecordTypeID = schema.SObjectType.Account.getRecordTypeInfosbyName().get('Family').getRecordTypeId();
        CAAC.acct.BillingStreet = '303 Morey Ave';
        CAAC.acct.BillingCity = 'Bellingham';
        CAAC.acct.BillingState = 'WA';
        CAAC.acct.BillingPostalCode = '98225';

        // Enter Contact Info
        CAAC.ctct.firstname = 'Test';
        CAAC.ctct.lastname = 'Tester';
        CAAC.ctct.Title = 'Testers Title';
        CAAC.ctct.Homephone = '3333333';
        CAAC.ctct.MobilePhone = '4444444';

        // Enter Contact Info
        CAAC.ctct2.firstname = 'Testa';
        CAAC.ctct2.lastname = 'Testeroon';
        CAAC.ctct2.Title = 'Testas Title';
        CAAC.ctct2.Homephone = '3333333';
        CAAC.ctct2.MobilePhone = '44444445';

        CAAC.submit();

        List<Account> ConfirmAccts = [SELECT id, addressee__c, dear__c, name from Account WHERE BillingStreet = '303 Morey Ave'];
        system.assertEquals('Tester, Test and Testa Testeroon Household', ConfirmAccts[0].name);
        system.assertEquals('Test Tester and Testa Testeroon', ConfirmAccts[0].addressee__c);
        system.assertEquals('Test and Testa', ConfirmAccts[0].dear__c);

        CAAC.done();
        CAAC.nextentry();
        CAAC.createDummyContact = true;
        CAAC.setContacts();
        system.assertEquals('Sir',CAAC.ctct.firstname);
    }
    @istest static void testWrongRecordType() {
        Test.setCurrentPage(Page.enterAccountContactPage);
        createAccountAndContacts_Con CAAC = new createAccountAndContacts_Con();
        CAAC.setContacts();
        //CAAC.setAccount();
        CAAC.acct.Contacts_in_Account__c = '2';

        // Enter Account Info
        CAAC.aname = '';
        CAAC.acct.RecordTypeID = schema.SObjectType.Account.getRecordTypeInfosbyName().get('Business').getRecordTypeId();
        CAAC.acct.BillingStreet = '303 Morey Ave';
        CAAC.acct.BillingCity = 'Bellingham';
        CAAC.acct.BillingState = 'WA';
        CAAC.acct.BillingPostalCode = '98225';

        // Enter Contact Info
        CAAC.ctct.firstname = 'Test';
        CAAC.ctct.lastname = 'Tester';
        CAAC.ctct.Title = 'Testers Title';
        CAAC.ctct.Homephone = '3333333';
        CAAC.ctct.MobilePhone = '4444444';

        // Enter Contact Info
        CAAC.ctct2.firstname = 'Testa';
        CAAC.ctct2.lastname = 'Testeroon';
        CAAC.ctct2.Title = 'Testas Title';
        CAAC.ctct2.Homephone = '3333333';
        CAAC.ctct2.MobilePhone = '44444445';

        CAAC.setAccount();
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            system.debug('Message detail is ' + msg.getDetail());
            if (msg.getDetail() == 'If the account type is not Household, you must enter an Account Name.') b = true;
        }
        system.assert(b);
    }
}