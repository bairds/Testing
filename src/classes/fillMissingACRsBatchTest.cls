@IsTest
private class fillMissingACRsBatchTest {
        
    @TestSetup static void methodName() {
        WGHelpers.BManageContacts = false;
        WGHelpers.BUseACRelations = false;
        List<Account> testAccts = new Account[100];
            for (Integer i=0;i<100;i++) {
            testAccts[i] = new Account(
                Name = 'TestAcct' + i );
        	}
        insert testAccts;
        List<Contact> testCtcts = new Contact[200];
        for (Integer j=0;j<200;j++) {
            testCtcts[j] = new Contact(
                FirstName = 'Test',
                LastName = 'Tester'+j,
                AccountId = testAccts[Integer.valueOf(j/2)].Id);
        }
        insert testCtcts;
        // Make testCtctEven older than testCtctOdd
        Datetime yesterday = Datetime.now().addDays(-1);
        for (Integer j=0;j<200;j++) {
            if (Math.mod(j,2)==0) {
                Test.setCreatedDate(testCtcts[j].Id,yesterday);
                testCtcts[j].LastName += 'Older';
            }
        }
        update testCtcts;
        
        // If ACRs have been created delete them.
        System.debug('After inserting testdata AccountContactRoles are ' + [SELECT Id, IsPrimary FROM AccountContactRole]);
        List<AccountContactRole> CheckACRs = [SELECT Id, IsPrimary FROM AccountContactRole];
        if (CheckACRs.size() > 0) {
            for (AccountContactRole acr : CheckACRs) {
                acr.IsPrimary = false;
            }
            update CheckACRs;
            delete CheckACRs;
        }
    }
    
    public static testMethod void fillMissingACRsBatchTest(){
        WGHelpers.BManageContacts = false;
        WGHelpers.BUseACRelations = false;
        fillMissingACRsInvokeBatch FMAIB = new fillMissingACRsInvokeBatch();
        Test.startTest();
        FMAIB.invokeBatch();
        Test.stopTest();            
        
        List<Account> resultAccts = [SELECT Id, (SELECT Id, Contact.LastName, IsPrimary FROM AccountContactRoles ORDER BY Contact.CreatedDate) FROM Account];
        for (Account a : resultAccts) {
            System.assertEquals(true,a.AccountContactRoles[0].IsPrimary,'IsPrimary should have been true since ACRS were ordered by CreatedDate.');
        }
        
        FMAIB.Finished();
        
    }
}