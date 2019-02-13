@istest
private class ManageAccountsTest {

@testsetup static void testsetup(){
		Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
    }
    
@istest static void ChangeAddress(){
    // Is there a way to test this without calling the trigger?  If it has to compare triggers old and new?
    List<Account> accts = [select id, name, BillingStreet from Account where Name = 'TestAccount'];
    system.assertEquals(1,accts.size());
    Accts[0].BillingStreet = 'Updated billing street';
    system.debug('In ChangeAddress the account is ' + Accts[0]);	
    update accts[0];	
    Account ConfirmAcct = [select id, HUC_Status__c from Account where Id =: accts[0].Id];
    system.assertEquals('1 Needs processing',ConfirmAcct.HUC_Status__c,'Should have set HUC_Status__c to "1 Needs processing" when address was changed');
    }    
    
}