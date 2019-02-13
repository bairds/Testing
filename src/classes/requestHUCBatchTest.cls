@isTest
private class requestHUCBatchTest {
    
@testSetup static void methodName() {
	  List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<40;i++) {
            testAccts.add(new Account(Name = 'TestAcct'+i));
        }
        insert testAccts;     
}
     
@istest
static void requestHUCBatchTest(){
	List<Account> accts = [SELECT id, HUC_Status__c, BillingStreet from Account];
    system.assertEquals(40,accts.size());
    For (Account a : accts) a.BillingStreet = 'new street address';
    requestHUCInvokeBatch rHIB = new requestHUCInvokeBatch();
    Test.startTest();
    rHIB.invokeBatch();
    Test.stopTest();
    List<Account> ConfirmAccts = [SELECT id, HUC_Status__c, BillingStreet from Account];
    For (Account a : ConfirmAccts) system.assertEquals('5 No geocode in WaterGrass for this address',a.HUC_Status__c,'Batch should have set one hundnred accounts to 5 No geocode in WaterGrass for this address');
	RHIB.Finished();
}
}