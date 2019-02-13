@istest
private class fillMissingACRsTest {
    
    @testSetup static void methodName() {
        Account testAcct = new Account(
            name = 'TestAcct');
        insert testAcct;
        Contact testCtct1 = new Contact(
            firstname = 'Test',
            lastName = 'Tester1',
            AccountId = testAcct.id);
        insert testCtct1;
        Contact testCtct2 = new Contact(
            firstname = 'Test',
            lastName = 'Tester2',
            AccountId = testAcct.id);
        insert testCtct2;
        // If ACRs have been created delete them.
        system.debug('After inserting testdata AccountContactRoles are ' + [select id, isPrimary from AccountContactRole]);
        List<AccountContactRole> CheckACRs = [select id, isPrimary from AccountContactRole];
        if (CheckACRS.size() > 0) {
            For (AccountContactRole acr : CheckACRs) {
                acr.isPrimary = false;
            }
            update CheckACRs;
            delete CheckACRs;
        }
        system.assertEquals(0,[select id from AccountContactRole].size());
        // Make testCtct1 older than testCtct2
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(testCtct1.Id, yesterday);
    }
    
    
    public static testMethod void AssignPrimaryToOldestContact() {      
        fillMissingACRs FMA = new fillMissingACRs();
        Set<Account> AcctsWithoutACRs = FMA.findAccountsWithoutACR();
        system.assertEquals(1,AcctsWithoutACRs.size());
        FMA.fillMissingACRs(AcctsWithoutACRs);
        // Did fillMissingACRs assign the primary role to the first ACR created?
        List<AccountContactRole> resultACRs = [select id, AccountId, CreatedDate, contact.FirstName, contact.Lastname 
                                               from AccountContactRole where isPrimary = true];
        system.debug('After test all ACRs are ' + resultACRs);
        system.assertEquals(1,resultACRs.size());
        Datetime yesterday = Datetime.now().addDays(-1);
        system.assertEquals('Tester1', resultACRs[0].contact.LastName);
        
    }
    
    public static testMethod void AssignPrimaryToOldestACR() {
        // Create two ACRs and make one a day older than the other
        List<Account> AcctList = [select id, (select id, lastName from Contacts) from Account];
        system.AssertEquals(1,AcctList.size(), 'There should be only one Account created by the testsetup.');
        List<AccountContactRole> InsertACRs = new List<AccountContactRole>();
        for (Contact c : AcctList[0].Contacts) {
            InsertACRs.add(new AccountContactRole(accountid=AcctList[0].id, ContactId = c.id, Role = 'Decision Maker'));                    }
        insert InsertACRs;
        AccountContactRole OldestACR = [select id, CreatedDAte from AccountContactRole where contact.lastname = 'Tester1' limit 1];
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(OldestACR.Id,yesterday);
        
        fillMissingACRs FMA = new fillMissingACRs();
        Set<Account> AcctsWithoutACRs = FMA.findAccountsWithoutACR();
        system.assertEquals(1,AcctsWithoutACRs.size());
        Integer ConfirmNr = FMA.fillMissingACRs(AcctsWithoutACRs);
        system.assertEquals(1,ConfirmNr);
        // Did fillMissingACRs assign the primary role to the first ACR created?
        List<AccountContactRole> resultACRs = [select id, AccountId, CreatedDate, contact.FirstName, contact.Lastname 
                                               from AccountContactRole where isPrimary = true];
        system.debug('After test all ACRs are ' + resultACRs);
        system.assertEquals(1,resultACRs.size());
        system.assertEquals('Tester1', resultACRs[0].contact.LastName);

        //Now that all ACRs have been filled, test again.  Are there no updates?

    }
}