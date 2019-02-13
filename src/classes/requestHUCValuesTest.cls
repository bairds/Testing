@istest
private class requestHUCValuesTest {
    
    @testsetup static void CreateAccounts(){
        List<Account> ListAcct = new List<Account>();
        Account a = new Account();
        a.Name = 'test huc address 1';         
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
        ListAcct.add(a);
        
        Account b = new Account();
        b.Name = 'test huc address 2';         
        b.BillingStreet = '111 Church St Se';
        b.BillingCity = 'Minneapolis';
        b.BillingState = 'MN';
        b.BillingPostalCode = '55455';  
        b.BillingLatitude = 44.29382;
        b.BillingLongitude = -84.746775;           
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
        c.ShippingStreet = '112 Church St Se';
        c.ShippingCity = 'Minneapolis';
        c.ShippingState = 'MN';
        c.ShippingPostalCode = '55455';  
        ListAcct.add(c);        
        insert ListAcct;
    }
        
    @istest static void SingleHUCUpdateFromVGPage(){        
        insert new HUCURL__c(URL__c = 'https://hydro.nationalmap.gov/arcgis/rest/services/wbd/MapServer/[1]/query?where=&geometry=[2],C[3]&geometryType=esriGeometryPoint&returnGeometry=false&f=pjson&inSR=4326&outFields=HUC[4],NAME|5|6',                            
                             HUC10__c = '5',
                             HUC12__c = '6');
        
        system.debug('All accounts are ' + [SELECT id, name from Account]);
        Account acct = [select id, AcctLatitude__c, AcctLongitude__c, HUC_Code__c, HUC_Status__c from Account where name = 'test huc address 1' LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(acct);
        requestHUCValues RHV = new requestHUCValues(sc);
        Test.setMock(HttpCalloutMock.class, new HUCMockImpl());        
        Map<string,string> resultsMap;
        Test.startTest();
        RHV.callFromVFPage();
        Test.stopTest();
        system.debug('In test, Acct is now ' + acct);
        Account ConfirmAcct = [SELECT Id, HUC_Code__c, HUC_Watershed__c from Account where Id =: acct.Id];
        system.assertEquals('020700100102',ConfirmAcct.HUC_Code__c);
        system.assertEquals('Lower Rock Creek',ConfirmAcct.HUC_Watershed__c);
    }
    
    @istest static void SingleHUCUpdate(){        
        insert new HUCURL__c(URL__c = 'https://hydro.nationalmap.gov/arcgis/rest/services/wbd/MapServer/[1]/query?where=&geometry=[2],C[3]&geometryType=esriGeometryPoint&returnGeometry=false&f=pjson&inSR=4326&outFields=HUC[4],NAME|5|6',                            
                             HUC10__c = '5',
                             HUC12__c = '6');
        
        system.debug('All accounts are ' + [SELECT id, name from Account]);
        Account acct = [select id, AcctLatitude__c, AcctLongitude__c, HUC_Code__c, HUC_Status__c from Account where name = 'test huc address 1' LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(acct);
        requestHUCValues RHV = new requestHUCValues(sc);
        Test.setMock(HttpCalloutMock.class, new HUCMockImpl());        
        Map<string,string> resultsMap;
        Test.startTest();
        acct = RHV.requestHUC(acct);
        Test.stopTest();
        system.assertEquals('020700100102',acct.HUC_Code__c);
        
        // return to detail page
        PageReference newPage = RHV.returnToAcctDetailPage();
        system.debug('newpage is ' + newpage);
        system.assert(string.valueOf(newPage).CONTAINS('/001'));
    }
  
    @istest static void SingleHUCUpdate500Error(){        
        insert new HUCURL__c(URL__c = 'https://hydro.nationalmap.gov/arcgis/rest/services/wbd/MapServer/[1]/query?where=&geometry=[2],C[3]&geometryType=esriGeometryPoint&returnGeometry=false&f=pjson&inSR=4326&outFields=HUC[4],NAME|5|6',                            
                             HUC10__c = '5',
                             HUC12__c = '6');
        
        system.debug('All accounts are ' + [SELECT id, name from Account]);
        Account acct = [select id, AcctLatitude__c, AcctLongitude__c, HUC_Code__c, HUC_Status__c from Account where name = 'test huc address 1' LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(acct);
        requestHUCValues RHV = new requestHUCValues(sc);
        Test.setMock(HttpCalloutMock.class, new HUCMock500Error());        
        Map<string,string> resultsMap;
        Test.startTest();
        acct = RHV.requestHUC(acct);
        Test.stopTest();
        system.assertEquals('4 No USGS HUC found for geocode',acct.HUC_Status__c);
    }    
    
    @istest static void SingleHUCNoGeolocation(){        
        insert new HUCURL__c(URL__c = 'https://hydro.nationalmap.gov/arcgis/rest/services/wbd/MapServer/[1]/query?where=&geometry=[2],C[3]&geometryType=esriGeometryPoint&returnGeometry=false&f=pjson&inSR=4326&outFields=HUC[4],NAME|5|6',                            
                             HUC10__c = '5',
                             HUC12__c = '6');
        
        system.debug('All accounts are ' + [SELECT id, name from Account]);
        Account acct = [select id, AcctLatitude__c, AcctLongitude__c, HUC_Code__c, HUC_Status__c from Account where name = 'test huc address 1' LIMIT 1];
        acct.BillingLatitude = null;
        acct.BillingLongitude = null;
        acct.ShippingLatitude = null;
        acct.ShippingLongitude = null;
        update acct;
        system.debug('After updating with Billing and Shipping geocodes=null, Acct.AcctLatitude__c is ' + acct);
        acct = [select id, AcctLatitude__c, AcctLongitude__c, HUC_Code__c, HUC_Status__c from Account where name = 'test huc address 1' LIMIT 1];
        system.debug('After updating with BillingLatitude=null, Acct.AcctLatitude__c is ' + acct);
        system.debug('After requery, Acct.AcctLatitude__c is ' + acct);
        ApexPages.StandardController sc = new ApexPages.StandardController(acct);
        requestHUCValues RHV = new requestHUCValues(sc);
        Test.setMock(HttpCalloutMock.class, new HUCMockImpl());        
        Map<string,string> resultsMap;
        Test.startTest();
        acct = RHV.requestHUC(acct);
        Test.stopTest();
        system.assertEquals('5 No geocode in WaterGrass for this address',acct.HUC_Status__c);
    }
    
    
    @istest static void SingleHUCUpdateNoAttributes(){        
        insert new HUCURL__c(URL__c = 'https://hydro.nationalmap.gov/arcgis/rest/services/wbd/MapServer/[1]/query?where=&geometry=[2],C[3]&geometryType=esriGeometryPoint&returnGeometry=false&f=pjson&inSR=4326&outFields=HUC[4],NAME|5|6',                            
                             HUC10__c = '5',
                             HUC12__c = '6');
        
        system.debug('All accounts are ' + [SELECT id, name from Account]);
        Account acct = [select id, AcctLatitude__c, AcctLongitude__c, HUC_Code__c, HUC_Status__c from Account where name = 'test huc address 1' LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(acct);
        requestHUCValues RHV = new requestHUCValues(sc);
        Test.setMock(HttpCalloutMock.class, new HUCMockImplNoAttributes());        
        Map<string,string> resultsMap;
        Test.startTest();
        acct = RHV.requestHUC(acct);
        Test.stopTest();
        system.assertEquals('4 No USGS HUC found for geocode',acct.HUC_Status__c);
    }
    
    @istest static void SingleHUCUpdateUndeserializableResponse(){        
        insert new HUCURL__c(URL__c = 'https://hydro.nationalmap.gov/arcgis/rest/services/wbd/MapServer/[1]/query?where=&geometry=[2],C[3]&geometryType=esriGeometryPoint&returnGeometry=false&f=pjson&inSR=4326&outFields=HUC[4],NAME|5|6',                            
                             HUC10__c = '5',
                             HUC12__c = '6');
        
        system.debug('All accounts are ' + [SELECT id, name from Account]);
        Account acct = [select id, AcctLatitude__c, AcctLongitude__c, HUC_Code__c, HUC_Status__c from Account where name = 'test huc address 1' LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(acct);
        requestHUCValues RHV = new requestHUCValues(sc);
        Test.setMock(HttpCalloutMock.class, new HUCMockImplError());        
        Map<string,string> resultsMap;
        Test.startTest();
        acct = RHV.requestHUC(acct);
        Test.stopTest();
        system.assertEquals('3 Undeserializable response from USGS',acct.HUC_Status__c);
        LIST<WG_Error_Log__c> WELs = [SELECT id, Status_Code__c, Description__c from WG_Error_Log__c];
        system.debug('List of Errors is ' + WELs);
        system.assertEquals(2,WELs.size(),'Should have created two error messages.');
        system.assertEquals('999',WELs[0].Status_Code__c,'Should have set the error status_code to 999.');
    }
   
    @istest static void SingleHUCBadServerURL(){        
        insert new HUCURL__c(URL__c = 'https://hydro.nationalmap.gov/arcgis/rest/services/wbd/MapServer/[1]/query?where=&geometry=[2],C[3]&geometryType=esriGeometryPoint&returnGeometry=false&f=pjson&inSR=4326&outFields=HUC[4],NAME|5|6',                            
                             HUC10__c = '5',
                             HUC12__c = '6');
        
        system.debug('All accounts are ' + [SELECT id, name from Account]);
        Account acct = [select id, AcctLatitude__c, AcctLongitude__c, HUC_Code__c, HUC_Status__c, HUC_Errors__c from Account where name = 'test huc address 1' LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(acct);
        requestHUCValues RHV = new requestHUCValues(sc);
        Test.setMock(HttpCalloutMock.class, new HUCMockImplBadServerURL());        
        Map<string,string> resultsMap;
        Test.startTest();
        acct = RHV.requestHUC(acct);
        Test.stopTest();
        system.assertEquals('7 Incorrect URL',acct.HUC_Status__c);
        system.assert(acct.HUC_Errors__c.CONTAINS(' 500'), 'Error message should contain 500 Error');
    }
   
    @istest static void SingleHUCCallCorporateForURL(){        
        insert new HUCURL__c(URL__c = 'https://hydro.nationalmap.gov/arcgis/rest/services/wbd/MapServer/[1]/query?where=&geometry=[2],C[3]&geometryType=esriGeometryPoint&returnGeometry=false&f=pjson&inSR=4326&outFields=HUC[4],NAME|5|6',                            
                             HUC10__c = '5',
                             HUC12__c = '6');
        
        system.debug('All accounts are ' + [SELECT id, name from Account]);
        Account acct = [select id, AcctLatitude__c, AcctLongitude__c, HUC_Code__c, HUC_Status__c, HUC_Errors__c from Account where name = 'test huc address 1' LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(acct);
        requestHUCValues RHV = new requestHUCValues(sc);
        Test.setMock(HttpCalloutMock.class, new HUCCallMasterForURL());        
        Map<string,string> resultsMap;
        Test.startTest();
        string ConfirmString = RHV.getLatestURL();
        Test.stopTest();
        system.assertEquals('https://services.nationalmap.gov/arcgis/rest/services/wbd/MapServer/[1]/query?where=&geometry=[2]%2C[3]&geometryType=esriGeometryPoint&outFields=HUC[4]%2C+NAME&returnGeometry=false&f=pjson&inSR=4326|5|6',ConfirmString);
    }    
    
    @istest static void BatchHUCUpdate(){        
        insert new HUCURL__c(URL__c = 'https://hydro.nationalmap.gov/arcgis/rest/services/wbd/MapServer/[1]/query?where=&geometry=[2],C[3]&geometryType=esriGeometryPoint&returnGeometry=false&f=pjson&inSR=4326&outFields=HUC[4],NAME|5|6',                            
                             HUC10__c = '5',
                             HUC12__c = '6');
        
        system.debug('All accounts are ' + [SELECT id, name from Account]);
        Account acct = [select id, AcctLatitude__c, AcctLongitude__c, HUC_Code__c, HUC_Status__c from Account where name = 'test huc address 1' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new HUCMockImpl());        
        Test.startTest();
        requestHUCBatch RHB = new requestHUCBatch();
        RHB.squery = 'select id, AcctLatitude__c, AcctLongitude__c, HUC_Code__c, HUC_Status__c from Account';
        database.executeBatch(RHB);
        Test.stopTest();
        List<Account> resultAccts = [select id, HUC_Code__c from Account];
        system.assertEquals('020700100102',resultAccts[0].HUC_Code__c);    
    }
}