@isTest
private class ACRPrimaryContactTriggerTests {

    static testMethod void contactInsertTestAddUpdateRemoveContactRole() {
        // Create test data
        Account a = new Account(Name='Test XX 1');
        insert a;
        Contact c = new Contact(LastName='Test', AccountId=a.Id,email='testcontact@dontbotherme.org');
        insert c;
        //Since this isn't a list, it will fail the test if more than one row returned
        AccountContactRole testacr1 = [Select ContactId, IsPrimary, Role from AccountContactRole where AccountId = :a.Id];
        system.assertequals(c.Id,testacr1.ContactId);
        system.assertequals(TRUE,testacr1.IsPrimary);
        system.assertequals('Decision Maker',testacr1.Role);
        Contact c2 = new Contact(LastName='Test2', AccountId=a.Id);
        insert c2;
        LIST<AccountContactRole> countACR = [select Id from AccountContactRole where accountid = :a.id];
		System.assertEquals(1,countACR.size());
        //Since this isn't a list, it will fail the test if more than one row returned
        AccountContactRole testacr2 = [Select ContactId, IsPrimary, Role from AccountContactRole where AccountId = :a.Id];
        //And Check still first Contact as Primary
        system.assertequals(c.Id,testacr2.ContactId);
        try
        {
        //try to delete contact set as priamry
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
        List<Contact> testctcts = [select id, Contact.Account.name from Contact where lastname = 'TestContact'];
        system.assertEquals(1,testctcts.size(),'ManageContacts trigger did not create just one new contact after insertion of a contact without account.');
        system.assertEquals('TestContact, Test Household',testctcts[0].account.name,'ManageContacts trigger got name wrong for new contact without account.');
    }
        }