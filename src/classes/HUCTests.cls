@istest
private class HUCTests 
{
    /*
	static testMethod void test()
    {
        insert new CampaignStati__c(Name='Attended', HasResponded__c=true);      
        
        insert new HUCURL__c(URL__c = 'https://services.nationalmap.gov/arcgis/rest/services/nhd/MapServer/[1]/query?geometry=[2]%2C[3]&geometryType=esriGeometryPoint&' +
                             			'outFields=HUC[4]%2C+NAME&returnGeometry=false&f=pjson&inSR=4326',                            
                            HUC10__c = '6',
                            HUC12__c = '7');
        
        Account a = HUCTests.CreateAccountA();
        Account b = HUCTests.CreateAccountB();
        Account c = HUCTests.CreateAccountC();
        
        List<Account> al = new List<Account>();  
      	al.add(a);
        al.add(b);
        al.add(c);
	
		insert al;    
        
        HUCTests.updateURL();
                
        HUCTests.updateHUCs(a.Id);
       	AccountBatch.updateHUCs();
        AccountSchedule.updateHUCs();
    }
    
    @future(callout = true)
    static void updateHUCs(Id id)
    {
        Test.setMock(HttpCalloutMock.class, new HUCMockImpl());
        AccountCustom.updateHUC(id);
    }
    
    @future(callout = true)
    static void updateURL()
    {        
        Test.setMock(HttpCalloutMock.class, new HUCURLMockImpl());
        
        AccountCustom ac = new AccountCustom();
        ac.hc = new HUCCustom();
        ac.hc.hu = [SELECT Id, URL__c, HUC10__c, HUC12__c FROM HUCURL__c LIMIT 1];
        ac.hc.getURL();
    }
    
    static Account CreateAccountA()
    {
        Account a = new Account();
 		a.Name = 'test huc address ';         
        a.BillingStreet = '1100 N. Main, Suite 210';
        a.BillingCity = 'Ann Arbor';
        a.BillingState = 'MI';
        a.BillingPostalCode = '48104';  
		a.BillingLatitude = 42.29382;
		a.BillingLongitude = -83.746775;   
        
        a.ShippingStreet = '1100 N. Main, Suite 210';
        a.ShippingCity = 'Ann Arbor';
        a.ShippingState = 'MI';
        a.ShippingPostalCode = '48104';  
		a.ShippingLatitude = 42.29382;
		a.ShippingLongitude = -83.746775;   
        
        return a;
    }
    
     static Account CreateAccountB()
    {
        Account a = new Account();
 		a.Name = 'test huc address 2';         
        a.BillingStreet = '111 Church St Se';
        a.BillingCity = 'Minneapolis';
        a.BillingState = 'MN';
        a.BillingPostalCode = '55455';  
        a.BillingLatitude = 44.29382;
		a.BillingLongitude = -84.746775;   
        
        a.ShippingStreet = '111 Church St Se';
        a.ShippingCity = 'Minneapolis';
        a.ShippingState = 'MN';
        a.ShippingPostalCode = '55455';  
        
        return a;
    }
    
    static Account CreateAccountC()
    {
        Account a = new Account();
 		a.Name = 'test huc address 3';         
        a.BillingStreet = '112 Church St Se';
        a.BillingCity = 'Minneapolis';
        a.BillingState = 'MN';
        a.BillingPostalCode = '55455';  
        a.BillingLatitude = 44.29382;
		a.BillingLongitude = -84.746775;   
        
        a.ShippingStreet = '112 Church St Se';
        a.ShippingCity = 'Minneapolis';
        a.ShippingState = 'MN';
        a.ShippingPostalCode = '55455';  
        
        return a;
    }
*/
}