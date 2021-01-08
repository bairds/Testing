@isTest
private class ManageContactsTEST {

    @IsTest
    static void IsAccountDefaultSetToFamily() {
        Schema.DescribeSObjectResult dsr = Account.SObjectType.getDescribe();
        Schema.RecordTypeInfo defaultRecordType;
        for (Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
            if (rti.isDefaultRecordTypeMapping()) {
                defaultRecordType = rti;
            }
        }
        system.debug('default account.recordType is ' + defaultRecordType.getName());
        system.assertEquals('Family', defaultRecordType.getName(), 'Default Account RecordType not set to Family, causes errors in email mgmt.');
    }

    @isTest
    static void contactInsertTestAddUpdateRemoveContactRoleF() {
        //Settings UseAcctCtctRelations__c to false
        WGHelpers.BUseACRelations = false;
        // Create test data
        Account a = new Account(Name = 'Test XX 1');
        insert a;
        Contact c = new Contact(LastName = 'Test', AccountId = a.Id, email = 'testcontact@dontbotherme.org', Active__c = 'Active');
        insert c;
        //Since this isn't a list, it will fail the test if more than one row returned
        AccountContactRole testacr1 = [Select ContactId, IsPrimary, Role, Account.Nr_Contacts_In_Acct__c from AccountContactRole where AccountId = :a.Id];
        system.assertequals(c.Id, testacr1.ContactId);
        system.assertequals(TRUE, testacr1.IsPrimary);
        system.assertequals('Decision Maker', testacr1.Role);
        system.assertequals(1, testacr1.account.Nr_Contacts_In_Acct__c);
        Contact c2 = new Contact(LastName = 'Test2', AccountId = a.Id, Active__c = 'Active');
        insert c2;
        testacr1 = [Select ContactId, IsPrimary, Role, Account.Nr_Contacts_In_Acct__c from AccountContactRole where AccountId = :a.Id];
        system.assertequals(2, testacr1.account.Nr_Contacts_In_Acct__c);
        LIST<AccountContactRole> countACR = [select Id from AccountContactRole where accountid = :a.id];
        System.assertEquals(1, countACR.size());
        //Since this isn't a list, it will fail the test if more than one row returned
        AccountContactRole testacr2 = [Select ContactId, IsPrimary, Role, Account.Nr_Contacts_In_Acct__c from AccountContactRole where AccountId = :a.Id];
        system.assertequals(2, testacr2.account.Nr_Contacts_In_Acct__c);
        //And Check still first Contact as Primary
        system.assertequals(c.Id, testacr2.ContactId);
        try {
            //try to delete contact set as primary
            delete c;
        } Catch (DmlException e) {
            //Check error message is displayed
            System.assert(e.getMessage().contains('Contact is the Primary Contact Role on an Account!  Please make another Contact Primary before deleting this one.'), e.getMessage());
        }
        //Change the primary to c2 - Created the following 2 lines when Peter's code began throwing errors, "DUPLICATE_VALUE, Contact has already been added in that Contact Role: [ContactId, Role]"
        testacr1.ContactId = c2.Id;
        update testacr1;
        //I eliminated the following two lines, which Peter wrote originally:
        //AccountContactRole acru = new AccountContactRole (AccountId  = a.Id, ContactId = c2.Id, IsPrimary = TRUE, Role = 'Decision Maker');
        //insert acru;
        //now check we can delete c
        delete c;
        //Is Number of contacts now 1?
        Account confirmAcct = [Select id, Nr_Contacts_In_Acct__c, (select id from Contacts) from Account where Id = :a.Id];
        // Was one contact deleted?
        system.assertEquals(1, confirmAcct.contacts.size());
        // Was the account.Nr_Contacts_In_Acct__c updated?
        system.assertEquals(1, confirmAcct.Nr_Contacts_In_Acct__c);

        //but not now c2
        try {
            //try to delete contact set as priamry
            delete c2;
        } Catch (DmlException e) {
            //Check error message is displayed
            System.assert(e.getMessage().contains('Contact is the Primary Contact Role on an Account!  Please make another Contact Primary before deleting this one.'), e.getMessage());
        }
    }

    @isTest
    static void contactInsertTestAddUpdateRemoveContactRoleT() {
        //Settings UseAcctCtctRelations__c to true and test using ACRelations instead of ACRoles
        WGHelpers.BUseACRelations = true;
        // Create test data
        Account a = new Account(Name = 'Test XX 1');
        insert a;
        Contact c = new Contact(LastName = 'Test', AccountId = a.Id, email = 'testcontact@dontbotherme.org', Active__c = 'Active');
        insert c;
        //Since this isn't a list, it will fail the test if more than one row returned
        AccountContactRelation testacr1 = [Select ContactId, IsPrimary__c, Roles, Account.Nr_Contacts_In_Acct__c from AccountContactRelation where AccountId = :a.Id];
        system.assertequals(c.Id, testacr1.ContactId);
        system.assertequals(TRUE, testacr1.IsPrimary__c);
        system.assertequals('Decision Maker', testacr1.Roles);
        system.assertequals(1, testacr1.account.Nr_Contacts_In_Acct__c);
        Contact c2 = new Contact(LastName = 'Test2', AccountId = a.Id, Active__c = 'Active');
        insert c2;
        List<AccountContactRelation > testacrelats = [Select ContactId, IsPrimary__c, Roles,
                Account.Nr_Contacts_In_Acct__c from AccountContactRelation where AccountId = :a.Id];
        system.assertequals(2, testacrelats[0].account.Nr_Contacts_In_Acct__c);
        LIST<AccountContactRelation> countACR = [select Id from AccountContactRelation where accountid = :a.id];
        System.assertEquals(2, countACR.size());
        //Since this isn't a list, it will fail the test if more than one row returned
        // AccountContactRelation testacr2 = [Select ContactId, IsPrimary__c, Roles, Account.Nr_Contacts_In_Acct__c from AccountContactRelation where AccountId = :a.Id];
        system.assertequals(2, testacrelats[0].account.Nr_Contacts_In_Acct__c);
        //And Check still first Contact as Primary
        system.assertequals(true, testacrelats[0].IsPrimary__c);
        system.assertequals(false, testacrelats[1].IsPrimary__c);
        try {
            //try to delete contact set as primary
            delete c;
        } Catch (DmlException e) {
            //Check error message is displayed
            System.assert(e.getMessage().contains('Contact is the Primary Contact Relation on an Account!'), e.getMessage());
        }
        // Switch the Primary to the second contact, then delete the first.
        testacrelats[0].IsPrimary__c = false;
        testacrelats[1].IsPrimary__c = true;
        update testacrelats[0];
        update testacrelats[1];

        delete c;
        //Is Number of contacts now 1?
        Account confirmAcct = [Select id, Nr_Contacts_In_Acct__c, (select id from Contacts) from Account where Id = :a.Id];
        // Was one contact deleted?
        system.assertEquals(1, confirmAcct.contacts.size());
        // Was the account.Nr_Contacts_In_Acct__c updated?
        system.assertEquals(1, confirmAcct.Nr_Contacts_In_Acct__c);

        //but not now c2
        try {
            //try to delete contact set as priamry
            delete c2;
        } Catch (DmlException e) {
            //Check error message is displayed
            System.assert(e.getMessage().contains('Contact is the Primary Contact Relation on an Account!'), e.getMessage());
        }
    }

    @isTest
    static void contactInsertTestAddUpdateRemoveContactRelation() {
        //Settings UseAcctCtctRelations__c to true
        WGHelpers.BUseACRelations = true;
        // Create test data
        Account a = new Account(Name = 'Test XX 1');
        insert a;
        Contact c = new Contact(LastName = 'Test', AccountId = a.Id, email = 'testcontact@dontbotherme.org', Active__c = 'Active');
        insert c;
        //Since this isn't a list, it will fail the test if more than one row returned
        AccountContactRelation testacr1 = [Select ContactId, IsPrimary__c, Roles, Account.Nr_Contacts_In_Acct__c from AccountContactRelation where AccountId = :a.Id];
        system.assertEquals(c.Id, testacr1.ContactId);
        system.assertequals(true, testacr1.IsPrimary__c);
        system.assertequals(1, testacr1.account.Nr_Contacts_In_Acct__c);
        //Insert a second contact
        Contact c2 = new Contact(LastName = 'Test2', AccountId = a.Id, Active__c = 'Active');
        insert c2;

        List<AccountContactRelation> resultACR = [
                Select ContactId, IsPrimary__c, Roles, Account.Nr_Contacts_In_Acct__c
                from AccountContactRelation
                where AccountId = :a.Id
        ];
        system.assertequals(2, resultACR[0].account.Nr_Contacts_In_Acct__c);
        LIST<AccountContactRelation> countACR = [select Id from AccountContactRelation where accountid = :a.id];
        System.assertEquals(2, countACR.size());
        //Since this isn't a list, it will fail the test if more than one row returned
        AccountContactRelation testacr2 = [
                Select ContactId, IsPrimary__c, Roles, Account.Nr_Contacts_In_Acct__c
                from AccountContactRelation WHERE AccountId = :a.Id AND IsPrimary__c = TRUE
        ];
        system.assertequals(2, testacr2.account.Nr_Contacts_In_Acct__c);
        //And Check still first Contact as Primary
        system.assertequals(c.Id, testacr2.ContactId);
        try {
            //try to delete contact set as primary
            delete c;
        } Catch (DmlException e) {
            //Check error message is displayed
            System.assert(e.getMessage().contains('Contact is the Primary Contact Relation on an Account!'), e.getMessage());
        }
    }

    @isTest
    static void contactInsertTestBulkAddUpdateRemoveContactRole() {
        // Set UseACRelations to true
        WGHelpers.BUseACRelations = false;

        List<Account> a2 = new List<Account>();
        List<Contact> conl2 = new List<Contact>();
        for (integer i = 0; i < 25; i++) {
            a2.add(new Account(Name = 'Test Account' + i));
        }
        insert a2;
        test.starttest();
        for (integer i = 0; i < 25; i++) {
            conl2.add(new Contact(LastName = 'Test Con' + i, AccountId = a2[i].Id));
            conl2.add(new Contact(LastName = 'Test Con' + 100 + i, AccountId = a2[i].Id));
        }
        insert conl2;
        test.stoptest();
        //Check an insert only inserted one Primary, and was frst one - select will fail if count > 1
        AccountContactRole testacr1 = [Select Contact.LastName, IsPrimary, Role from AccountContactRole where AccountId = :a2[20].Id];
        system.assertequals('Test Con20', testacr1.Contact.LastName);
        system.assertequals(TRUE, testacr1.IsPrimary);
        system.assertequals('Decision Maker', testacr1.Role);
        try {
            //try to delete contact set as priamry
            delete conl2;
        } Catch (DmlException e) {
            //Check error message is displayed
            System.assert(e.getMessage().contains('Contact is the Primary Contact Role on an Account!'), e.getMessage());
        }

    }

    @isTest
    static void insertContactNoAccount() {
        WGHelpers.BManageContacts = true;
        Contact NewCtct = new Contact(
                firstname = 'Test',
                lastname = 'TestContact',
                email = 'testcontact@dontbotherme.org');
        // insert contact into ContactCustom method;
        List<Contact> ctctlist = new List<Contact>();
        ctctlist.add(newCtct);
        insert ctctlist;
        List<Contact> testctcts = [select id, Account.name, Account.is_Dummy__c from Contact where lastname = 'TestContact'];
        system.assertEquals(1, testctcts.size(), 'ManageContacts trigger did not create just one new contact after insertion of a contact without account.');
        system.assertEquals('TestContact, Test Household', testctcts[0].account.name, 'ManageContacts trigger got name wrong for new contact without account.');
        system.assertEquals(true, testctcts[0].Account.is_Dummy__c, 'ManageContacts trigger created Account but is_Dummy__c not set to true.');
    }

    @isTest
    static void insertContactNoAccountBulk() {
        WGHelpers.BManageContacts = true;
        List<Contact> ctctlist = new List<Contact>();
        for (integer i = 0; i < 100; i++) {
            Contact NewCtct = new Contact(
                    firstname = 'Test',
                    lastname = 'TestContact' + i,
                    email = 'testcontact@dontbotherme.org');
            // insert contact into ContactCustom method;
            ctctlist.add(newCtct);
        }
        system.assertEquals(100, ctctlist.size());
        List<Contact> ConfirmList = ManageContacts.beforeInsert(ctctlist);
        system.assertEquals(100, ConfirmList.size(), 'Should have returned a list of 100 contacts.');
        // List<Contact> testctcts = [select id, Account.name from Contact where lastname like 'TestContact%' ORDER BY Lastname];
        // system.assertEquals(100,testctcts.size(),'ManageContacts trigger did not create just one new contact after insertion of a contact without account.');
        // system.assertEquals('TestContact99, Test Household',testctcts[99].account.name,'ManageContacts trigger got name wrong for new contact without account.');
    }

    // Converting a lead should not trigger the beforeInsert method
    // because by converting the new contact will also receive an accountId
    @isTest
    static void convertLead() {
        WGHelpers.BManageContacts = true;
        Lead NewLead = new Lead(
                firstname = 'Test',
                lastname = 'TestLead',
                company = 'none',
                email = 'testcontact@dontbotherme.org');
        insert NewLead;
        // Convert lead
        List<Id> results = ConvertLeadToContact.ConvertLeadToContact(NewLead.Id);
        system.assertEquals(1, [select id from Account where name like 'TestLead%'].size(), 'Converting lead but more than one account created probably because of error in ManageCcontacts');
    }

    @isTest
    static void insertContactNoAccountMatchExists() {
        WGHelpers.BManageContacts = true;
        Account a = new Account(Name = 'Test XX 1');
        insert a;
        Contact c = new Contact(LastName = 'Test', AccountId = a.Id, email = 'testcontact@dontbotherme.org');
        insert c;
        Contact NewCtct = new Contact(
                firstname = 'Test',
                lastname = 'TestContact',
                email = 'testcontact@dontbotherme.org');
        // insert contact into ContactCustom method;
        List<Contact> ctctlist = new List<Contact>();
        ctctlist.add(newCtct);
        insert ctctlist;
        List<Contact> testctcts = [select id, lastname, Account.name, Account.is_Dummy__c from Contact where lastname = 'TestContact'];
        system.assertEquals(1, testctcts.size(), 'ManageContacts trigger did not create just one new contact after insertion of a contact without account.');
        system.assertEquals('Test XX 1', testctcts[0].account.name, 'ManageContacts trigger got name wrong for new contact without account.');
        system.assertEquals(false, testctcts[0].Account.is_Dummy__c, 'ManageContacts trigger created Account but is_Dummy__c set to true.');
    }


    @isTest
    static void insertContactNoAccountNoMatchExists() {
        WGHelpers.BManageContacts = true;
        Account a = new Account(Name = 'Test XX 1');
        insert a;
        Contact c = new Contact(LastName = 'Test', AccountId = a.Id, email = 'testcontact@dontbotherme.org');
        insert c;
        Contact NewCtct = new Contact(
                firstname = 'Test',
                lastname = 'TestContact',
                email = 'testcontact@dontbotherme2.org');
        // insert contact into ContactCustom method;
        List<Contact> ctctlist = new List<Contact>();
        ctctlist.add(newCtct);
        insert ctctlist;
        List<Contact> testctcts = [select id, lastname, Account.name, Account.is_Dummy__c, Account.Dear__c, Account.Active__c from Contact where lastname = 'TestContact'];
        system.assertEquals(1, testctcts.size(), 'ManageContacts trigger did not create just one new contact after insertion of a contact without account.');
        system.assertEquals('TestContact, Test Household', testctcts[0].account.name, 'ManageContacts trigger got name wrong for new account created for contact.');
        system.assertEquals(true, testctcts[0].Account.is_Dummy__c, 'ManageContacts trigger created Account but is_Dummy__c not set to true.');
        system.assertEquals('Active', testctcts[0].Account.Active__c, 'ManageContacts trigger created Account but Account.Active__c not set to Active.');
        system.assertEquals('Test', testctcts[0].Account.Dear__c, 'ManageContacts trigger created Account but Account.Dear__c not set to Test.');
    }

    @IsTest
    static void ChangePreferredEmail() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAccount = ctv.fetchTestAccount();
        TestAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        update TestAccount;
        Contact ctct = CTV.TestContact;
        List<Contact> LContacts = new List<Contact>();
        LContacts.add(ctct);
        List<Id> AccountIds = new List<Id>();
        For (Contact c : LContacts) AccountIds.add(c.AccountId);
        Map<Id, Id> RecordTypeMap = new Map<id, Id>();
        List<Account> Accounts = [SELECT Id, RecordTypeId from Account where Id IN:AccountIds];
        For (Account a : Accounts) RecordTypeMap.put(a.Id, a.RecordTypeId);
        Map<Id, Id> CtctRTypeMap = new Map<Id, Id>();
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        List<Contact> ResultContacts = ManageContacts.arrangeEmails(LContacts, CtctRTypeMap);
        system.debug('ResultContacts is ' + ResultContacts);
        system.assertEquals('Work', ResultContacts[0].Preferred_Email__c, 'Should have set Preferred Email to Personal because Account was Family');
    }

    @IsTest
    static void OneSFEmailPersonal() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Contact TestFamilyContact = ctv.fetchTestFamilyContact();
        system.debug('Account RT is ' + TestFamilyContact.Account.RecordTypeId);

        List<Contact> LContacts = new List<Contact>();
        LContacts.add(TestFamilyContact);
        system.debug('LContacts is ' + LContacts);
        List<Id> AccountIds = new List<Id>();
        For (Contact c : LContacts) AccountIds.add(c.AccountId);
        Map<Id, Id> RTIdMap = new Map<id, Id>();
        List<Account> Accounts = [SELECT Id, RecordTypeId from Account where Id IN:AccountIds];
        For (Account a : Accounts) RTIdMap.put(a.Id, a.RecordTypeId);

        List<Contact> ResultContacts = ManageContacts.arrangeEmails(LContacts, RTIdMap);
        system.debug('ResultContacts is ' + ResultContacts);
        For (Contact c : ResultContacts) {
            system.assertEquals('testfamilycontact@dontbotherme.org', c.Email);
            system.assertEquals('testfamilycontact@dontbotherme.org', c.Personal_Email__c);
            system.assertEquals(null, c.Work_Email__c);
            system.assertEquals(null, c.Other_Email__c);
            system.assertEquals('Personal', c.Preferred_Email__c);
        }
    }


    @IsTest
    static void OneSFEmailWork() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Contact TestContact = ctv.fetchTestContact();
        Account TestAccount = ctv.fetchTestAccount();
        TestAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        update TestAccount;

        List<Contact> LContacts = new List<Contact>();
        LContacts.add(TestContact);
        system.debug('LContacts is ' + LContacts);
        List<Id> AccountIds = new List<Id>();
        For (Contact c : LContacts) AccountIds.add(c.AccountId);
        Map<Id, Id> RecordTypeMap = new Map<id, Id>();
        List<Account> Accounts = [SELECT Id, Name, RecordTypeId from Account where Id IN:AccountIds];
        For (Account a : Accounts) {
            RecordTypeMap.put(a.Id, a.RecordTypeId);
            system.debug('For account ' + a + ' recordTypeId is ' + a.RecordTypeId);
        }
        Map<Id, Id> CtctRTypeMap = new Map<Id, Id>();
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        List<Contact> ResultContacts = ManageContacts.arrangeEmails(LContacts, CtctRTypeMap);
        system.debug('ResultContacts is ' + ResultContacts);
        For (Contact c : ResultContacts) {
            system.assertEquals('testcontact@dontbotherme.org', c.Email);
            system.assertEquals('testcontact@dontbotherme.org', c.Work_Email__c);
            system.assertEquals(null, c.Personal_Email__c);
            system.assertEquals(null, c.Other_Email__c);
            system.assertEquals('Work', c.Preferred_Email__c);
        }
    }

    @IsTest
    static void SFEmailWGEmailNoPreferred1() {
        WGHelpers.BManageContactEmails = true;
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAccount = ctv.fetchTestAccount();
        TestAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        update TestAccount;
        Contact TestContact = ctv.fetchTestContact();
        Testcontact.Personal_Email__c = 'personal@dontbotherme.org';
        update Testcontact;
        system.debug('Testcontact is ' + Testcontact);

        List<Contact> LContacts = new List<Contact>();
        LContacts.add(TestContact);
        system.debug('LContacts is ' + LContacts);
        List<Id> AccountIds = new List<Id>();
        For (Contact c : LContacts) AccountIds.add(c.AccountId);
        Map<Id, Id> RecordTypeMap = new Map<id, Id>();
        List<Account> Accounts = [SELECT Id, Name, RecordTypeId from Account where Id IN:AccountIds];
        For (Account a : Accounts) {
            RecordTypeMap.put(a.Id, a.RecordTypeId);
            system.debug('For account ' + a + ' recordTypeId is ' + a.RecordTypeId);
        }
        Map<Id, Id> CtctRTypeMap = new Map<Id, Id>();
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        List<Contact> ResultContacts = ManageContacts.arrangeEmails(LContacts, CtctRTypeMap);
        system.debug('ResultContacts is ' + ResultContacts);
        For (Contact c : ResultContacts) {
            system.assertEquals('testcontact@dontbotherme.org', c.Email);
            system.assertEquals('personal@dontbotherme.org', c.Personal_Email__c);
            system.assertEquals('testcontact@dontbotherme.org', c.Work_Email__c);
            system.assertEquals(null, c.Other_Email__c);
            system.assertEquals('Work', c.Preferred_Email__c);
        }
    }

    // One SFEmail, two WGEmail (Personal_Email__c and Work_Email__c). Does SFEmail go into Other_Email__c?
    // and Is Preferred is set to Other?
    @IsTest
    static void SFEmailWGEmailNoPreferred2() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAccount = ctv.fetchTestAccount();
        TestAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        update TestAccount;
        Contact TestContact = ctv.fetchTestContact();
        Testcontact.Personal_Email__c = 'personal@dontbotherme.org';
        Testcontact.Work_Email__c = 'work@dontbotherme.org';
        update Testcontact;

        List<Contact> LContacts = new List<Contact>();
        LContacts.add(TestContact);
        system.debug('LContacts is ' + LContacts);
        List<Id> AccountIds = new List<Id>();
        For (Contact c : LContacts) AccountIds.add(c.AccountId);
        Map<Id, Id> RecordTypeMap = new Map<id, Id>();
        List<Account> Accounts = [SELECT Id, Name, RecordTypeId from Account where Id IN:AccountIds];
        For (Account a : Accounts) {
            RecordTypeMap.put(a.Id, a.RecordTypeId);
        }
        Map<Id, Id> CtctRTypeMap = new Map<Id, Id>();
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        List<Contact> ResultContacts = ManageContacts.arrangeEmails(LContacts, CtctRTypeMap);
        system.debug('ResultContacts is ' + ResultContacts);
        For (Contact c : ResultContacts) {
            system.assertEquals('testcontact@dontbotherme.org', c.Email);
            system.assertEquals('personal@dontbotherme.org', c.Personal_Email__c);
            system.assertEquals('work@dontbotherme.org', c.Work_Email__c);
            system.assertEquals('testcontact@dontbotherme.org', c.Other_Email__c);
            system.assertEquals('Other', c.Preferred_Email__c);
        }
    }


    // One SFEmail, two WGEmail (Personal_Email__c and Work_Email__c). Does SFEmail go into Other_Email__c?
    // and Is Preferred is set to Other?
    @IsTest
    static void SFEmailAllWGEmailsNoPreferred() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAccount = ctv.fetchTestAccount();
        TestAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        update TestAccount;
        Contact TestContact = ctv.fetchTestContact();
        Testcontact.Personal_Email__c = 'personal@dontbotherme.org';
        Testcontact.Work_Email__c = 'work@dontbotherme.org';
        Testcontact.Other_Email__c = 'other@dontbotherme.org';
        update Testcontact;

        List<Contact> LContacts = new List<Contact>();
        LContacts.add(TestContact);
        system.debug('LContacts is ' + LContacts);
        List<Id> AccountIds = new List<Id>();
        For (Contact c : LContacts) AccountIds.add(c.AccountId);
        Map<Id, Id> RecordTypeMap = new Map<id, Id>();
        List<Account> Accounts = [SELECT Id, Name, RecordTypeId from Account where Id IN:AccountIds];
        For (Account a : Accounts) {
            RecordTypeMap.put(a.Id, a.RecordTypeId);
        }
        Map<Id, Id> CtctRTypeMap = new Map<Id, Id>();
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        List<Contact> ResultContacts = ManageContacts.arrangeEmails(LContacts, CtctRTypeMap);
        system.debug('ResultContacts is ' + ResultContacts);
        For (Contact c : ResultContacts) {
            system.assertEquals('testcontact@dontbotherme.org', c.Email);
            system.assertEquals('personal@dontbotherme.org', c.Personal_Email__c);
            system.assertEquals('work@dontbotherme.org', c.Work_Email__c);
            system.assertEquals('other@dontbotherme.org', c.Other_Email__c);
            system.assertEquals(null, c.Preferred_Email__c);
        }
    }

    @IsTest
    static void NoSFEmailWGEmailNoPreferred1() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAccount = ctv.fetchTestAccount();
        TestAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        update TestAccount;
        Contact TestContact = ctv.fetchTestContact();
        Testcontact.Email = null;
        Testcontact.Work_Email__c = 'work@dontbotherme.org';
        update Testcontact;

        List<Contact> LContacts = new List<Contact>();
        LContacts.add(TestContact);
        system.debug('LContacts is ' + LContacts);
        List<Id> AccountIds = new List<Id>();
        For (Contact c : LContacts) AccountIds.add(c.AccountId);
        Map<Id, Id> RecordTypeMap = new Map<id, Id>();
        List<Account> Accounts = [SELECT Id, Name, RecordTypeId from Account where Id IN:AccountIds];
        For (Account a : Accounts) {
            RecordTypeMap.put(a.Id, a.RecordTypeId);
        }
        Map<Id, Id> CtctRTypeMap = new Map<Id, Id>();
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        List<Contact> ResultContacts = ManageContacts.arrangeEmails(LContacts, CtctRTypeMap);
        system.debug('ResultContacts is ' + ResultContacts);
        For (Contact c : ResultContacts) {
            system.assertEquals('work@dontbotherme.org', c.Email);
            system.assertEquals(null, c.Personal_Email__c);
            system.assertEquals('work@dontbotherme.org', c.Work_Email__c);
            system.assertEquals(null, c.Other_Email__c);
            system.assertEquals('Work', c.Preferred_Email__c);
        }
    }

    @IsTest
    static void NoSFEmailWGEmailNoPreferred2() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAccount = ctv.fetchTestAccount();
        TestAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        update TestAccount;
        Contact TestContact = ctv.fetchTestContact();
        Testcontact.Email = null;
        Testcontact.Other_Email__c = 'other@dontbotherme.org';
        update Testcontact;

        List<Contact> LContacts = new List<Contact>();
        LContacts.add(TestContact);
        system.debug('LContacts is ' + LContacts);
        List<Id> AccountIds = new List<Id>();
        For (Contact c : LContacts) AccountIds.add(c.AccountId);
        Map<Id, Id> RecordTypeMap = new Map<id, Id>();
        List<Account> Accounts = [SELECT Id, Name, RecordTypeId from Account where Id IN:AccountIds];
        For (Account a : Accounts) {
            RecordTypeMap.put(a.Id, a.RecordTypeId);
        }
        Map<Id, Id> CtctRTypeMap = new Map<Id, Id>();
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        List<Contact> ResultContacts = ManageContacts.arrangeEmails(LContacts, CtctRTypeMap);
        system.debug('ResultContacts is ' + ResultContacts);
        For (Contact c : ResultContacts) {
            system.assertEquals('other@dontbotherme.org', c.Email);
            system.assertEquals(null, c.Work_Email__c);
            system.assertEquals('other@dontbotherme.org', c.Other_Email__c);
            system.assertEquals('Other', c.Preferred_Email__c);
        }
    }

    @IsTest
    static void NoSFEmailWGEmailNoPreferredWork() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAccount = ctv.fetchTestAccount();
        TestAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        update TestAccount;
        Contact TestContact = ctv.fetchTestContact();
        Testcontact.Email = null;
        Testcontact.Work_Email__c = 'work@dontbotherme.org';
        update Testcontact;

        List<Contact> LContacts = new List<Contact>();
        LContacts.add(TestContact);
        system.debug('LContacts is ' + LContacts);
        List<Id> AccountIds = new List<Id>();
        For (Contact c : LContacts) AccountIds.add(c.AccountId);
        Map<Id, Id> RecordTypeMap = new Map<id, Id>();
        List<Account> Accounts = [SELECT Id, Name, RecordTypeId from Account where Id IN:AccountIds];
        For (Account a : Accounts) {
            RecordTypeMap.put(a.Id, a.RecordTypeId);
        }
        Map<Id, Id> CtctRTypeMap = new Map<Id, Id>();
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        List<Contact> ResultContacts = ManageContacts.arrangeEmails(LContacts, CtctRTypeMap);
        system.debug('ResultContacts is ' + ResultContacts);
        For (Contact c : ResultContacts) {
            system.assertEquals('work@dontbotherme.org', c.Email);
            system.assertEquals('work@dontbotherme.org', c.Work_Email__c);
            system.assertEquals(null, c.Other_Email__c);
            system.assertEquals('Work', c.Preferred_Email__c);
        }
    }

    @IsTest
    static void SFEmailMatchWGEmailNoPreferred1() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAccount = ctv.fetchTestAccount();
        TestAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        update TestAccount;
        Contact TestContact = ctv.fetchTestContact();
        Testcontact.Email = 'other@dontbotherme.org';
        Testcontact.Other_Email__c = 'other@dontbotherme.org';
        update Testcontact;

        List<Contact> LContacts = new List<Contact>();
        LContacts.add(TestContact);
        system.debug('LContacts is ' + LContacts);
        List<Id> AccountIds = new List<Id>();
        For (Contact c : LContacts) AccountIds.add(c.AccountId);
        Map<Id, Id> RecordTypeMap = new Map<id, Id>();
        List<Account> Accounts = [SELECT Id, Name, RecordTypeId from Account where Id IN:AccountIds];
        For (Account a : Accounts) {
            RecordTypeMap.put(a.Id, a.RecordTypeId);
        }
        Map<Id, Id> CtctRTypeMap = new Map<Id, Id>();
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        List<Contact> ResultContacts = ManageContacts.arrangeEmails(LContacts, CtctRTypeMap);
        system.debug('ResultContacts is ' + ResultContacts);
        For (Contact c : ResultContacts) {
            system.assertEquals('other@dontbotherme.org', c.Email);
            system.assertEquals(null, c.Work_Email__c);
            system.assertEquals('other@dontbotherme.org', c.Other_Email__c);
            system.assertEquals('Other', c.Preferred_Email__c);
        }
    }

    @IsTest
    static void SFEmailMatchWGEmailNoPreferred2() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAccount = ctv.fetchTestAccount();
        TestAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        update TestAccount;
        Contact TestContact = ctv.fetchTestContact();
        Testcontact.Email = 'work@dontbotherme.org';
        Testcontact.Work_Email__c = 'work@dontbotherme.org';
        Testcontact.Other_Email__c = 'other@dontbotherme.org';
        update Testcontact;

        List<Contact> LContacts = new List<Contact>();
        LContacts.add(TestContact);
        system.debug('LContacts is ' + LContacts);
        List<Id> AccountIds = new List<Id>();
        For (Contact c : LContacts) AccountIds.add(c.AccountId);
        Map<Id, Id> RecordTypeMap = new Map<id, Id>();
        List<Account> Accounts = [SELECT Id, Name, RecordTypeId from Account where Id IN:AccountIds];
        For (Account a : Accounts) {
            RecordTypeMap.put(a.Id, a.RecordTypeId);
        }
        Map<Id, Id> CtctRTypeMap = new Map<Id, Id>();
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        List<Contact> ResultContacts = ManageContacts.arrangeEmails(LContacts, CtctRTypeMap);
        system.debug('ResultContacts is ' + ResultContacts);
        For (Contact c : ResultContacts) {
            system.assertEquals('work@dontbotherme.org', c.Email);
            system.assertEquals('work@dontbotherme.org', c.Work_Email__c);
            system.assertEquals('other@dontbotherme.org', c.Other_Email__c);
            system.assertEquals('Work', c.Preferred_Email__c);
        }
    }
/*
    @IsTest
    static void SFEmailWGEmailPreferred() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAccount = ctv.fetchTestAccount();
        TestAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        update TestAccount;
        Contact TestContact = ctv.fetchTestContact();
        Testcontact.Personal_Email__c = 'personal@dontbotherme.org';
        Testcontact.Email = 'testcontact@dontbotherme.org';
        Testcontact.Work_Email__c = 'work@dontbotherme.org';
        Testcontact.Preferred_Email__c = 'Other';
        try {
            update Testcontact;
            System.Assert(1 == 0, 'The update should not have occurred.  This test pointed Preferred Email at an empty Other_Email field, so it should have generated a DMLException.');
        } catch (DmlException e) {
            System.assert(e.getMessage().CONTAINS('Please set Preferred Email field to point to an email field which is not empty.'),
                    'This test pointed Preferred Email at an empty Other_Email field, so it should have generated a DMLException.');
        }
    }
*/
    @IsTest
    static void SFEmailWGEmailMatchesPreferred() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAccount = ctv.fetchTestAccount();
        TestAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        update TestAccount;
        Contact TestContact = ctv.fetchTestContact();
        Testcontact.Personal_Email__c = 'personal@dontbotherme.org';
        Testcontact.Email = 'testcontact@dontbotherme.org';
        Testcontact.Work_Email__c = 'work@dontbotherme.org';
        Testcontact.Other_Email__c = 'other@dontbotherme.org';
        Testcontact.Preferred_Email__c = 'Personal';
        update Testcontact;

        List<Contact> LContacts = new List<Contact>();
        LContacts.add(TestContact);
        system.debug('LContacts is ' + LContacts);
        List<Id> AccountIds = new List<Id>();
        For (Contact c : LContacts) AccountIds.add(c.AccountId);
        Map<Id, Id> RecordTypeMap = new Map<id, Id>();
        List<Account> Accounts = [SELECT Id, Name, RecordTypeId from Account where Id IN:AccountIds];
        For (Account a : Accounts) {
            RecordTypeMap.put(a.Id, a.RecordTypeId);
        }
        Map<Id, Id> CtctRTypeMap = new Map<Id, Id>();
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        List<Contact> ResultContacts = ManageContacts.arrangeEmails(LContacts, CtctRTypeMap);
        system.debug('ResultContacts is ' + ResultContacts);
        For (Contact c : ResultContacts) {
            system.assertEquals('personal@dontbotherme.org', c.Email);
            system.assertEquals('work@dontbotherme.org', c.Work_Email__c);
            system.assertEquals('personal@dontbotherme.org', c.Personal_Email__c);
            system.assertEquals('testcontact@dontbotherme.org', c.Other_Email__c);
            system.assertEquals('Personal', c.Preferred_Email__c);
            system.assertEquals(date.today(), c.Last_Email_Overwrite__c.date());
        }
    }

    @IsTest
    static void SFEmailNotPreferredAllEmailsPopulated() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAccount = ctv.fetchTestAccount();
        TestAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        update TestAccount;
        Contact TestContact = ctv.fetchTestContact();
        Testcontact.Personal_Email__c = 'personal@dontbotherme.org';
        Testcontact.Email = 'testcontact@dontbotherme.org';
        Testcontact.Work_Email__c = 'work@dontbotherme.org';
        Testcontact.Other_Email__c = 'other@dontbotherme.org';
        Testcontact.Preferred_Email__c = 'Personal';
        update Testcontact;

        List<Contact> LContacts = new List<Contact>();
        LContacts.add(TestContact);
        system.debug('LContacts is ' + LContacts);
        List<Id> AccountIds = new List<Id>();
        For (Contact c : LContacts) AccountIds.add(c.AccountId);
        Map<Id, Id> RecordTypeMap = new Map<id, Id>();
        List<Account> Accounts = [SELECT Id, Name, RecordTypeId from Account where Id IN:AccountIds];
        For (Account a : Accounts) {
            RecordTypeMap.put(a.Id, a.RecordTypeId);
        }
        Map<Id, Id> CtctRTypeMap = new Map<Id, Id>();
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        List<Contact> ResultContacts = ManageContacts.arrangeEmails(LContacts, CtctRTypeMap);
        system.debug('ResultContacts is ' + ResultContacts);
        For (Contact c : ResultContacts) {
            system.assertEquals('personal@dontbotherme.org', c.Email);
            system.assertEquals('work@dontbotherme.org', c.Work_Email__c);
            system.assertEquals('personal@dontbotherme.org', c.Personal_Email__c);
            system.assertEquals('other@dontbotherme.org', c.Legacy_Emails__c);
            system.assertEquals('Personal', c.Preferred_Email__c);
            system.assertEquals(date.today(), c.Last_Email_Overwrite__c.date());
            system.debug(c.Last_Email_Overwrite__c);
        }
    }

    @IsTest static void BatchTest() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account a = ctv.fetchTestAccount();
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        update a;
        Account b = new Account(name = 'FamilyAccount',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Family').getRecordTypeId());
        insert b;
        List<Contact> LContacts = new List<Contact>();

        for (Integer i = 0; i < 25; i++) {
            Contact c = new Contact(
                    LastName = 'Testcontact' + i + 'a',
                    Personal_Email__c = 'personal@dontbotherme.org',
                    Email = 'testcontact@dontbotherme.org',
                    Work_Email__c = 'work@dontbotherme.org',
                    Other_Email__c = 'other@dontbotherme.org',
                    Preferred_Email__c = 'Work',
                    AccountId = a.Id);
            LContacts.add(c);
            Contact d = new Contact(
                    LastName = 'Testcontact' + i + 'b',
                    Personal_Email__c = 'personal@dontbotherme.org',
                    Email = 'testcontact@dontbotherme.org',
                    Work_Email__c = 'work@dontbotherme.org',
                    AccountId = b.Id);
            LContacts.add(d);
        }
        system.assertEquals(50, LContacts.size());
        insert LContacts;
        List<Id> AccountIds = new List<Id>();
        For (Contact c : LContacts) AccountIds.add(c.AccountId);
        Map<Id, Id> RecordTypeMap = new Map<id, Id>();
        List<Account> Accounts = [SELECT Id, Name, RecordTypeId from Account where Id IN:AccountIds];
        For (Account acct : Accounts) {
            RecordTypeMap.put(acct.Id, acct.RecordTypeId);
        }
        Map<Id, Id> CtctRTypeMap = new Map<Id, Id>();
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        For (Contact c : LContacts) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }

        Test.startTest();
        List<Contact> ResultContacts = ManageContacts.arrangeEmails(LContacts, CtctRTypeMap);
        Test.stopTest();

        system.debug('ResultContacts is ' + ResultContacts);
        For (Contact c : ResultContacts) {
            system.debug('ResultContact is ' + c);
            // From a Family account
            if (c.LastName.endsWith('b')) {
                system.assertEquals('testcontact@dontbotherme.org', c.Email);
                system.assertEquals('work@dontbotherme.org', c.Work_Email__c);
                system.assertEquals('personal@dontbotherme.org', c.Personal_Email__c);
                system.assertEquals('testcontact@dontbotherme.org', c.Other_Email__c);
                system.assertEquals('Other', c.Preferred_Email__c);
            } else {
                // From a Business Account, overwrites Other
                system.assertEquals('work@dontbotherme.org', c.Email);
                system.assertEquals('work@dontbotherme.org', c.Work_Email__c);
                system.assertEquals('personal@dontbotherme.org', c.Personal_Email__c);
                system.assertEquals('testcontact@dontbotherme.org', c.Other_Email__c);
                system.assertEquals('other@dontbotherme.org', c.Legacy_Emails__c);
                system.assertEquals('Work', c.Preferred_Email__c);
                system.assertEquals(date.today(), c.Last_Email_Overwrite__c.date());
            }
        }
    }


    @IsTest
    static void TestBeforeTrigger() {
        WGHelpers.BManageContacts = true;
        WGHelpers.BManageContactEmails = true;
        Create_Test_Variables CTV = new Create_Test_Variables();
        Account Testaccount = ctv.fetchTestFamilyAccount();
        Contact Testcontact = new Contact(
                firstname = 'Test',
                lastname = 'TestContact',
                email = 'testcontact@dontbotherme.org',
                accountId = Testaccount.Id);
        insert TestContact;
        Contact resultContact = [SELECT Id,Preferred_Email__c from Contact where Id = :TestContact.Id];
        system.assertEquals('Personal', resultContact.Preferred_Email__c, 'Since Account was Family account contact should have had Preferred_Email set to Personal.');
    }


    @isTest
    static void UpdateEmailTests1() {
        WGHelpers.BManageContacts = true;
        WGHelpers.BManageContactEmails = true;
        Account a = new Account(Name = 'Test XX 1');
        insert a;
        Contact c = new Contact(LastName = 'Test', AccountId = a.Id, email = 'testcontact@dontbotherme.org');
        insert c;
        ApexTrigger EETrigger = [Select Id, Status from ApexTrigger where name = 'ManageContacts' LIMIT 1];
        if (EETrigger.Status == 'Inactive') {
            return;
        } else {
            List<Contact> ResultContacts = [SELECT email, Legacy_Emails__c, Preferred_Email__c, Personal_Email__c, Work_Email__c, Other_Email__c from Contact where id = :c.Id];
            system.assertEquals('Personal', ResultContacts[0].Preferred_Email__c);
            system.assertEquals('testcontact@dontbotherme.org', ResultContacts[0].Email);
            system.assertEquals('testcontact@dontbotherme.org', ResultContacts[0].Personal_Email__c);
        }
        c = [SELECT email, Legacy_Emails__c, Preferred_Email__c, Personal_Email__c, Work_Email__c, Other_Email__c from Contact where id = :c.Id];
        // An external program like Salsa injects an email
        c.email = 'changedemail@dontbotherme.org';
        update c;
        System.Debug('Does the contact have different email and personal email? ' + c);
        if (EETrigger.Status == 'Inactive') {
            return;
        } else {
            List<Contact> ResultContacts = [SELECT email, Legacy_Emails__c, Preferred_Email__c, Personal_Email__c, Work_Email__c, Other_Email__c from Contact where id = :c.Id];
            system.assertEquals('Other', ResultContacts[0].Preferred_Email__c);
            system.assertEquals('changedemail@dontbotherme.org', ResultContacts[0].email);
            system.assertEquals('changedemail@dontbotherme.org', ResultContacts[0].Other_Email__c);
            system.assertEquals('testcontact@dontbotherme.org', ResultContacts[0].Personal_Email__c);
            system.assertEquals(null, ResultContacts[0].Legacy_Emails__c);
        }
        c.email = 'changed2email@dontbotherme.org';
        update c;
        if (EETrigger.Status == 'Inactive') {
            return;
        } else {
            List<Contact> ResultContacts = [SELECT email, Legacy_Emails__c, Preferred_Email__c, Personal_Email__c, Work_Email__c, Other_Email__c from Contact where id = :c.Id];
            system.assertEquals('Other', ResultContacts[0].Preferred_Email__c);
            system.assertEquals('changed2email@dontbotherme.org', ResultContacts[0].email);
            system.assertEquals('changed2email@dontbotherme.org', ResultContacts[0].Other_Email__c);
            system.assertEquals('changedemail@dontbotherme.org', ResultContacts[0].Legacy_Emails__c);
        }
        c.Preferred_Email__c = 'Personal';
        c.Personal_Email__c = 'Personal@dontbotherme.org';
        update c;
        if (EETrigger.Status == 'Inactive') {
            return;
        } else {
            List<Contact> ResultContacts = [SELECT email, Legacy_Emails__c, Preferred_Email__c, Personal_Email__c, Work_Email__c, Other_Email__c from Contact where id = :c.Id];
            system.assertEquals('Personal', ResultContacts[0].Preferred_Email__c);
            system.assertEquals('personal@dontbotherme.org', ResultContacts[0].email);
            system.assertEquals('changed2email@dontbotherme.org', ResultContacts[0].Other_Email__c);
            system.assertEquals('testcontact@dontbotherme.org, changedemail@dontbotherme.org', ResultContacts[0].Legacy_Emails__c);
        }
        c.Personal_Email__c = 'personalemail@dontbotherme.org';
        c.Work_Email__c = 'work@dontbotherme.org';
        update c;
        if (EETrigger.Status == 'Inactive') {
            return;
        } else {
            List<Contact> ResultContacts = [SELECT email, Legacy_Emails__c, Preferred_Email__c, Personal_Email__c, Work_Email__c, Other_Email__c from Contact where id = :c.Id];
            system.assertEquals('Other', ResultContacts[0].Preferred_Email__c);
            system.assertEquals('personalemail@dontbotherme.org', ResultContacts[0].Personal_Email__c);
            system.assertEquals('changed2email@dontbotherme.org', ResultContacts[0].Other_Email__c);
            system.assertEquals('testcontact@dontbotherme.org, changedemail@dontbotherme.org', ResultContacts[0].Legacy_Emails__c);
        }
        c.Work_Email__c = 'work2@dontbotherme.org';
        c.Preferred_Email__c = 'Work';
        update c;
        if (EETrigger.Status == 'Inactive') {
            return;
        } else {
            List<Contact> ResultContacts = [SELECT email, Legacy_Emails__c, Preferred_Email__c, Personal_Email__c, Work_Email__c, Other_Email__c from Contact where id = :c.Id];
            system.assertEquals('Work', ResultContacts[0].Preferred_Email__c);
            system.assertEquals('work2@dontbotherme.org', ResultContacts[0].email);
            system.assertEquals('personalemail@dontbotherme.org', ResultContacts[0].Personal_Email__c);
            system.assertEquals('work2@dontbotherme.org', ResultContacts[0].Work_Email__c);
            system.assertEquals('changed2email@dontbotherme.org', ResultContacts[0].Other_Email__c);
            system.assertEquals('work@dontbotherme.org, testcontact@dontbotherme.org, changedemail@dontbotherme.org', ResultContacts[0].Legacy_Emails__c);
        }
    }

    @IsTest
    static void UpdateEmailTests2() {
        WGHelpers.BManageContacts = true;
        WGHelpers.BManageContactEmails = true;
        Account a = new Account(Name = 'Test XX 1');
        insert a;
        Contact c = new Contact(LastName = 'Test', AccountId = a.Id, email = 'testcontact@dontbotherme.org');
        insert c;
        ApexTrigger EETrigger = [Select Id, Status from ApexTrigger where name = 'ManageContacts' LIMIT 1];
        if (EETrigger.Status == 'Inactive') {
            return;
        } else {
            List<Contact> ResultContacts = [SELECT email, Legacy_Emails__c, Preferred_Email__c, Personal_Email__c, Work_Email__c, Other_Email__c from Contact where id = :c.Id];
            system.assertEquals('Personal', ResultContacts[0].Preferred_Email__c);
            system.assertEquals('testcontact@dontbotherme.org', ResultContacts[0].Email);
            system.assertEquals('testcontact@dontbotherme.org', ResultContacts[0].Personal_Email__c);
        }
        c.Preferred_Email__c = 'Other';
        c.Other_Email__c = 'other2@dontbotherme.org';
        update c;
        if (EETrigger.Status == 'Inactive') {
            return;
        } else {
            List<Contact> ResultContacts = [SELECT email, Legacy_Emails__c, Preferred_Email__c, Personal_Email__c, Work_Email__c, Other_Email__c from Contact where id = :c.Id];
            system.debug('ResultContacts is ' + ResultContacts);
            system.assertEquals('Other', ResultContacts[0].Preferred_Email__c);
            system.assertEquals('other2@dontbotherme.org', ResultContacts[0].email);
            system.assertEquals('testcontact@dontbotherme.org', ResultContacts[0].Personal_Email__c);
            system.assertEquals(null, ResultContacts[0].Work_Email__c);
            system.assertEquals('other2@dontbotherme.org', ResultContacts[0].Other_Email__c);
            system.assertEquals(null, ResultContacts[0].Legacy_Emails__c);
        }
    }

    @IsTest
    static void DuplicateLegacyEmail() {
        // Does ManageContacts avoid duplicating an existing LegacyEmail?
        WGHelpers.BManageContacts = true;
        WGHelpers.BManageContactEmails = true;
        Account a = new Account(Name = 'Test XX 1');
        insert a;
        Contact c = new Contact(LastName = 'Test',
                AccountId = a.Id,
                email = 'testcontact@dontbotherme.org',
                Legacy_Emails__c = 'duplicate@dontbotherme.org',
                Other_Email__c = 'duplicate@dontbotherme.org');
        insert c;
        ApexTrigger EETrigger = [Select Id, Status from ApexTrigger where name = 'ManageContacts' LIMIT 1];
        if (EETrigger.Status == 'Inactive') {
            return;
        } else {
            List<Contact> ResultContacts = [SELECT email, Legacy_Emails__c, Preferred_Email__c, Personal_Email__c, Work_Email__c, Other_Email__c from Contact where id = :c.Id];
            system.assertEquals('Personal', ResultContacts[0].Preferred_Email__c);
            system.assertEquals('testcontact@dontbotherme.org', ResultContacts[0].Email);
            system.assertEquals('testcontact@dontbotherme.org', ResultContacts[0].Personal_Email__c);
        }
        c.Email = 'insertedemail@dontbotherme.org';
        update c;
        if (EETrigger.Status == 'Inactive') {
            return;
        } else {
            List<Contact> ResultContacts = [SELECT email, Legacy_Emails__c, Preferred_Email__c, Personal_Email__c, Work_Email__c, Other_Email__c from Contact where id = :c.Id];
            system.debug('ResultContacts is ' + ResultContacts);
            // New Email is inserted into email field
            system.assertEquals('insertedemail@dontbotherme.org', ResultContacts[0].email);
            system.assertEquals('testcontact@dontbotherme.org', ResultContacts[0].Personal_Email__c);
            system.assertEquals(null, ResultContacts[0].Work_Email__c);
            // Also inserted into OtherEmail field, and PreferredEmail set to Other
            system.assertEquals('insertedemail@dontbotherme.org', ResultContacts[0].Other_Email__c);
            system.assertEquals('Other', ResultContacts[0].Preferred_Email__c);
            // Old Other Email was pushed into Legacy, did it create duplicate?
            system.assertEquals('duplicate@dontbotherme.org', ResultContacts[0].Legacy_Emails__c);
        }
    }
}