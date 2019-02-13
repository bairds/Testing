@istest
private class moveHUCToAccountBatchTest {
    
        @testsetup static void CreateAccountsAndHUC(){                        
        HUC__c h = new HUC__c(
        Code__c = '123123123123',
        Status__c = 'Current',
        Errors__c = 'Text in error field for test purposes',
        Watershed__c = 'Potomac',
        Subwatershed__c = 'Lower Rock Creek');
        Insert h;
        
            
        List<Account> ListAcct = new List<Account>();
        Account a = new Account();
        a.Name = 'test huc address 1';         
        a.BillingStreet = '1100 N. Main, Suite 210';
        a.BillingCity = 'Ann Arbor';
        a.BillingState = 'MI';
        a.BillingPostalCode = '48104';  
        a.BillingLatitude = 42.29382;
        a.BillingLongitude = -83.746775; 
            a.Billing_HUC__c = h.Id;
        a.ShippingStreet = '1100 N. Main, Suite 210';
        a.ShippingCity = 'Ann Arbor';
        a.ShippingState = 'MI';
        a.ShippingPostalCode = '48104';  
        a.ShippingLatitude = 42.29382;
        a.ShippingLongitude = -83.746775;   
        ListAcct.add(a);
        
        Account b = new Account();
        b.Name = 'test huc address 2';         
        b.BillingStreet = '111 Church St Se';
        b.BillingCity = 'Minneapolis';
        b.BillingState = 'MN';
        b.BillingPostalCode = '55455';  
        b.BillingLatitude = 44.29382;
        b.BillingLongitude = -84.746775;     
            b.Billing_HUC__c = h.Id;      
        b.ShippingStreet = '111 Church St Se';
        b.ShippingCity = 'Minneapolis';
        b.ShippingState = 'MN';
        b.ShippingPostalCode = '55455';  
        ListAcct.add(b);
        
        Account c = new Account();
        c.Name = 'test huc address 3';         
        c.BillingStreet = '112 Church St Se';
        c.BillingCity = 'Minneapolis';
        c.BillingState = 'MN';
        c.BillingPostalCode = '55455';  
        c.BillingLatitude = 44.29382;
        c.BillingLongitude = -84.746775;     
            c.Billing_HUC__c = h.Id;      
        c.ShippingStreet = '112 Church St Se';
        c.ShippingCity = 'Minneapolis';
        c.ShippingState = 'MN';
        c.ShippingPostalCode = '55455';  
        ListAcct.add(c);        
        insert ListAcct;

    }
    
    @istest private static void MoveHUCs(){
        List<Id> AcctIdList = new List<Id>();
    List<Account> AccountsToProcess= [SELECT Id from Account];
    For (Account a: AccountsToProcess) AcctIdList.add(a.Id);
    system.assertEquals(3,AccountsToProcess.size(),'Testsetup should have created three accounts.');
    
    moveHUCToAccountInvokeBatch MHAIB = new moveHUCToAccountInvokeBatch();
    Test.startTest();
    MHAIB.invokeBatch();
    Test.stopTest();            
    
    List<Account> ConfirmAccts = [select name, HUC_Code__c, HUC_Status__c, HUC_Errors__c, HUC_Watershed__c, HUC_SubWatershed__c 
                                 FROM Account WHERE Id in: AcctIDList];
    For (Account a : ConfirmAccts){
        system.assertEquals('123123123123',a.HUC_Code__c,'moveHUCToAccountBatch failed to bring over Billing_HUC into HUC_Code__c.'); 
        system.assertEquals('Current',a.HUC_Status__c,'moveHUCToAccountBatch failed to bring over Billing_Status__c into HUC_Code__c.'); 
        system.assertEquals('Text in error field for test purposes',a.HUC_Errors__c,'moveHUCToAccountBatch failed to bring over HUC_Errors__c into HUC_Code__c.'); 
        system.assertEquals('Potomac',a.HUC_Watershed__c,'moveHUCToAccountBatch failed to bring over Watershed into HUC_Watershed__c.');  
        system.assertEquals('Lower Rock Creek',a.HUC_Watershed__c,'moveHUCToAccountBatch failed to bring over Watershed into HUC_SubWatershed__c.');  
    }       
    }

    // Does method handle null values?
    @istest private static void MoveHUCsNullValues(){
    HUC__c TestHUC = [SELECT Code__c, Status__c, Errors__c, Watershed__c, Subwatershed__c from HUC__c where Code__c = '123123123123' LIMIT 1];
    TestHUC.Errors__c=null;
    TestHUC.Watershed__c=null;
    update TEstHUC;
        
        List<Id> AcctIdList = new List<Id>();
    List<Account> AccountsToProcess= [SELECT Id from Account];
    For (Account a: AccountsToProcess) AcctIdList.add(a.Id);
    system.assertEquals(3,AccountsToProcess.size(),'Testsetup should have created three accounts.');
    
    moveHUCToAccountInvokeBatch MHAIB = new moveHUCToAccountInvokeBatch();
    Test.startTest();
    MHAIB.invokeBatch();
    Test.stopTest();            
    
    List<Account> ConfirmAccts = [select name, HUC_Code__c, HUC_Status__c, HUC_Errors__c, HUC_Watershed__c, HUC_SubWatershed__c 
                                 FROM Account WHERE Id in: AcctIDList];
    For (Account a : ConfirmAccts){
        system.assertEquals('123123123123',a.HUC_Code__c,'moveHUCToAccountBatch failed to bring over Billing_HUC into HUC_Code__c.'); 
        system.assertEquals('Current',a.HUC_Status__c,'moveHUCToAccountBatch failed to bring over Billing_Status__c into HUC_Code__c.'); 
        system.assertEquals(null,a.HUC_Errors__c,'moveHUCToAccountBatch failed to bring over null value for HUC_Errors__c into HUC_Code__c.'); 
        system.assertEquals(null,a.HUC_Watershed__c,'moveHUCToAccountBatch failed to bring over null value for Watershed into HUC_Watershed__c.');  
        system.assertEquals('Lower Rock Creek',a.HUC_Watershed__c,'moveHUCToAccountBatch failed to bring over Watershed into HUC_SubWatershed__c.');  
    }       
    }    
    
}