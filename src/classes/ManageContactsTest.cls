@isTest
private class ManageContactsTest {

    static testMethod void contactInsertTestAddUpdateRemoveContactRole() {
        // Create test data
        Account a = new Account(Name='Test XX 1');
        insert a;
        Contact c = new Contact(LastName='Test', AccountId=a.Id,email='testcontact@dontbotherme.org', Active__c='Active');
        insert c;
        //Since this isn't a list, it will fail the test if more than one row returned
        AccountContactRole testacr1 = [Select ContactId, IsPrimary, Role, Account.Nr_Contacts_In_Acct__c from AccountContactRole where AccountId = :a.Id];
        system.assertequals(c.Id,testacr1.ContactId);
        system.assertequals(TRUE,testacr1.IsPrimary);
        system.assertequals('Decision Maker',testacr1.Role);
        system.assertequals(1,testacr1.account.Nr_Contacts_In_Acct__c);
        Contact c2 = new Contact(LastName='Test2', AccountId=a.Id, Active__c='Active');
        insert c2;
        testacr1 = [Select ContactId, IsPrimary, Role, Account.Nr_Contacts_In_Acct__c from AccountContactRole where AccountId = :a.Id];
        system.assertequals(2,testacr1.account.Nr_Contacts_In_Acct__c);
        LIST<AccountContactRole> countACR = [select Id from AccountContactRole where accountid = :a.id];
		System.assertEquals(1,countACR.size());
        //Since this isn't a list, it will fail the test if more than one row returned
        AccountContactRole testacr2 = [Select ContactId, IsPrimary, Role, Account.Nr_Contacts_In_Acct__c from AccountContactRole where AccountId = :a.Id];
        system.assertequals(2,testacr2.account.Nr_Contacts_In_Acct__c);        
        //And Check still first Contact as Primary
        system.assertequals(c.Id,testacr2.ContactId);
        try
        {
        //try to delete contact set as primary
        delete c;
        }
        Catch (DmlException e)
        {
        //Check error message is displayed
        System.assert(e.getMessage().contains('Contact is the Primary Contact Role on an Account!  Please make another Contact Primary before deleting this one.'), e.getMessage() );
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
        system.assertEquals(1,confirmAcct.contacts.size());
        // Was the account.Nr_Contacts_In_Acct__c updated?
        system.assertEquals(1,confirmAcct.Nr_Contacts_In_Acct__c);        

        //but not now c2        
        try
        {
        //try to delete contact set as priamry
        delete c2;
        }
        Catch (DmlException e)
        {
        //Check error message is displayed
        System.assert(e.getMessage().contains('Contact is the Primary Contact Role on an Account!  Please make another Contact Primary before deleting this one.'), e.getMessage() );
        }              
        }
    
        static testMethod void contactInsertTestBulkAddUpdateRemoveContactRole() {
       // Test bulk insert
        
        List<Account> a2 = new List<Account>();
        List<Contact> conl2 = new List<Contact>();
        for(integer i=0; i<99; i++) {
            a2.add(new Account(Name='Test Account' + i));
        }
        insert a2;
test.starttest();
        for(integer i=0; i<99; i++) {
            conl2.add( new Contact(LastName='Test Con' + i, AccountId = a2[i].Id));
            conl2.add( new Contact(LastName='Test Con' + 100 + i, AccountId = a2[i].Id));
        }
        insert conl2;
test.stoptest();
        //Check an insert only inserted one Primary, and was frst one - select will fail if count > 1
        AccountContactRole testacr1 = [Select Contact.LastName, IsPrimary, Role from AccountContactRole where AccountId = :a2[50].Id];
        system.assertequals('Test Con50',testacr1.Contact.LastName);
        system.assertequals(TRUE,testacr1.IsPrimary);
        system.assertequals('Decision Maker',testacr1.Role);
        try
        {
        //try to delete contact set as priamry
        delete conl2;
        }
        Catch (DmlException e)
        {
        //Check error message is displayed
        System.assert(e.getMessage().contains('Contact is the Primary Contact Role on an Account!  Please make another Contact Primary before deleting this one.'), e.getMessage() );
        }      

        }
    
    static testmethod void insertContactNoAccount(){
		Contact NewCtct = new Contact(
                    firstname = 'Test',
                    lastname = 'TestContact',
                    email='testcontact@dontbotherme.org');
                // insert contact into ContactCustom method;
                List<Contact> ctctlist = new List<Contact>();
                ctctlist.add(newCtct);
        		insert ctctlist;
        List<Contact> testctcts = [select id, Account.name, Account.is_Dummy__c from Contact where lastname = 'TestContact'];
        system.assertEquals(1,testctcts.size(),'ManageContacts trigger did not create just one new contact after insertion of a contact without account.');
        system.assertEquals('TestContact, Test Household',testctcts[0].account.name,'ManageContacts trigger got name wrong for new contact without account.');
        system.assertEquals(true,testctcts[0].Account.is_Dummy__c,'ManageContacts trigger created Account but is_Dummy__c not set to true.');
    }

    static testmethod void insertContactNoAccountBulk(){
List<Contact> ctctlist = new List<Contact>();
    for (integer i=0;i<100;i++) {
		Contact NewCtct = new Contact(
                    firstname = 'Test',
                    lastname = 'TestContact'+i,
                    email='testcontact@dontbotherme.org');
                // insert contact into ContactCustom method;
                ctctlist.add(newCtct);
    }
    system.assertEquals(100,ctctlist.size());
        List<Contact> ConfirmList = ManageContacts.beforeInsert(ctctlist);
        system.assertEquals(100,ConfirmList.size(),'Should have returned a list of 100 contacts.');
        // List<Contact> testctcts = [select id, Account.name from Contact where lastname like 'TestContact%' ORDER BY Lastname];
        // system.assertEquals(100,testctcts.size(),'ManageContacts trigger did not create just one new contact after insertion of a contact without account.');
        // system.assertEquals('TestContact99, Test Household',testctcts[99].account.name,'ManageContacts trigger got name wrong for new contact without account.');
    }

    // Converting a lead should not trigger the beforeInsert method
    // because by converting the new contact will also receive an accountId
    static testmethod void convertLead(){
		Lead NewLead = new Lead(
                    firstname = 'Test',
                    lastname = 'TestLead',
            		company = 'none',
                    email='testcontact@dontbotherme.org');
        			insert NewLead;
                // Convert lead
                List<Id> results = ConvertLeadToContact.ConvertLeadToContact(NewLead.Id);
        		system.assertEquals(1,[select id from Account where name like 'TestLead%'].size(),'Converting lead but more than one account created probably because of error in ManageCcontacts');
    }
    
    static testmethod void insertContactNoAccountMatchExists(){
        Account a = new Account(Name='Test XX 1');
        insert a;
        Contact c = new Contact(LastName='Test', AccountId=a.Id,email='testcontact@dontbotherme.org');
        insert c;
        		Contact NewCtct = new Contact(
                    firstname = 'Test',
                    lastname = 'TestContact',
                    email='testcontact@dontbotherme.org');
                // insert contact into ContactCustom method;
        List<Contact> ctctlist = new List<Contact>();
        ctctlist.add(newCtct);
        insert ctctlist;
        List<Contact> testctcts = [select id, lastname, Account.name, Account.is_Dummy__c from Contact where lastname = 'TestContact'];
        system.assertEquals(1,testctcts.size(),'ManageContacts trigger did not create just one new contact after insertion of a contact without account.');
        system.assertEquals('Test XX 1',testctcts[0].account.name,'ManageContacts trigger got name wrong for new contact without account.');
        system.assertEquals(false,testctcts[0].Account.is_Dummy__c,'ManageContacts trigger created Account but is_Dummy__c set to true.');
    }

    
    static testmethod void insertContactNoAccountNoMatchExists(){
        Account a = new Account(Name='Test XX 1');
        insert a;
        Contact c = new Contact(LastName='Test', AccountId=a.Id,email='testcontact@dontbotherme.org');
        insert c;
        		Contact NewCtct = new Contact(
                    firstname = 'Test',
                    lastname = 'TestContact',
                    email='testcontact@dontbotherme2.org');
                // insert contact into ContactCustom method;
        List<Contact> ctctlist = new List<Contact>();
        ctctlist.add(newCtct);
        insert ctctlist;
        List<Contact> testctcts = [select id, lastname, Account.name, Account.is_Dummy__c, Account.Dear__c, Account.Active__c from Contact where lastname = 'TestContact'];
        system.assertEquals(1,testctcts.size(),'ManageContacts trigger did not create just one new contact after insertion of a contact without account.');
        system.assertEquals('TestContact, Test Household',testctcts[0].account.name,'ManageContacts trigger got name wrong for new account created for contact.');
        system.assertEquals(true,testctcts[0].Account.is_Dummy__c,'ManageContacts trigger created Account but is_Dummy__c not set to true.');
        system.assertEquals('Active',testctcts[0].Account.Active__c,'ManageContacts trigger created Account but Account.Active__c not set to Active.');
        system.assertEquals('Test',testctcts[0].Account.Dear__c,'ManageContacts trigger created Account but Account.Dear__c not set to Test.');
    }    
   
        }