public class requestHUCValues {
    public Map<String, String> HUCValues;
    private string bracket = '';
    public integer level;
    public Account acct {get; set;}
    public string URLInfo;
    public string URL;
    public Map<string, string> HUCURLMap;
    List<ErrorHolder> ListErrors;
    private boolean GotLatestURL;
    public boolean FailedWLatestURL;
    
    public requestHUCValues(ApexPages.StandardController sc)
    { HUCValues = new Map<string, string>();  
     Acct = (Account) sc.getRecord();
     Acct = [SELECT HUC_Watershed__c, HUC_Subwatershed__c, AcctLongitude__c, AcctLatitude__c from Account where id =: acct.Id];
     system.debug('Account is ' + acct);
     URLInfo = HUCURL__c.getInstance().URL__c;
     HUCURLMap = new Map<string,string>();
     ListErrors = new List<ErrorHolder>();
     GotLatestURL = false;
    }
    
    public Account requestHUC(Account a){  
        acct = a;
        HUCValues.put('HUC12', NULL);
        HUCValues.put('HUC10', NULL);
        HUCValues.put('HUC14', NULL);
        HUCValues.put('NAME', NULL);   
        HUCValues.put('Status', NULL);   
        HUCValues.put('ERROR', NULL);    
        if (a.AcctLatitude__c != null && a.AcctLongitude__c != null) {      
            Map<string,integer> HUCPairs = new Map<String,integer>();
            HUCPairs.put('10',5);
            HUCPairs.put('12',6);
            // Add the HUC14 pairs and variables below if USGS ever produces HUC14 info
            // HUCPairs.put('14',7);
            
            For (string s : HUCPairs.keyset()){
                if (FailedWLatestURL!=true) {
                string level = s;
                integer bracket = HUCPairs.get(s);
                
                HTTPResponse resp = getResp(URLInfo, level, bracket);
                
                system.debug('Using the endpoint from the HUCURL__c setting, response is ' + resp);
                If (resp.getStatusCode() != 200 && GotLatestURL != true) {
                    //For the remainder of this controller, it will use the Latest URL from WGCorporate.
                    if(Test.isRunningTest()){
                        system.debug('Is this running? ' + Test.isRunningTest());
                        URLInfo = 'https://services.nationalmap.gov/arcgis/rest/services/wbd/MapServer/[1]/query?where=&geometry=[2]%2C[3]&geometryType=esriGeometryPoint&outFields=HUC[4]%2C+NAME&returnGeometry=false&f=pjson&inSR=4326|5|6';
                    } else {
                        URLInfo = getLatestURL(); 
                        system.debug('Just returned from Corporate instance with new URL: ' + URLInfo);
                    }
                } else {                                
                    String JSONContent = resp.getBody();   
                    system.debug('Response Body is ' + JSONContent);
                    system.debug('Response Body contains error? ' + JSONContent.TOUPPERCASE().CONTAINS('ERROR'));
                    if (JSONContent.TOUPPERCASE().CONTAINS('ERROR')) {
                        //Log WGErrorLog report
                        Map<string,Object> sMapRoot  = new Map<string,Object>();
                        try{
                            sMapRoot = (Map<String, Object>)json.deserializeUntyped(JSONContent);
                            system.debug(sMapRoot);
                            system.debug('sMapRoot.get(code) is ' + sMapRoot.get('code'));
                            Map<String, Object> sMapError = (Map<String, Object>)sMapRoot.get('error');
                            String Code = string.valueOf(sMapError.get('code'));
                            system.debug('Code ' + Code);
                            String Message = string.valueOf(sMapError.get('message'));
                            system.debug('Message ' + Message);
                            String Details = string.valueOf(sMapError.get('details'));
                            system.debug('Details' + Details);
                            system.debug('Message' + sMapError.get('message')); 
                            Message = GotLatestURL ?'Error w latest URL__c string. ':'Error w local HUCURL__c' + Message;
                            ErrorHolder EH = new ErrorHolder(Code,Details,Message);
                            system.debug('EH is ' + EH);
                            ListErrors.add(EH);
                        	system.debug('Listerrors is ' + ListErrors);
                        }
                        catch(Exception Ex){ 
                            
                            ErrorHolder EH = new ErrorHolder('999', 'Could not deserialize response into Code, Message and Details', GotLatestURL ?'Error w latest URL__c string. ':'Error w local HUCURL__c ' + 'From requestHUCValues line 74');
                            ListErrors.add(EH);
                            system.debug('EH is ' + EH);
                        	system.debug('Listerrors is ' + ListErrors);
                        }
                        //If there were errors, reset the URLInfo to the string from WGCorporate    
                        If (GotLatestURL != true) URLInfo = getLatestURL();
                    } 
                }
                resp = getResp(URLInfo,level,bracket);
                // We set the URLInfo to one that works, hopefully.
                
                
                system.debug('Begin parsing on line 86, resp is ' + resp);
                if(resp.getStatusCode() == 200) {
                    string JSONContent = resp.getBody();   
                    // system.debug('Response Body is ' + JSONContent);
                    Map<string,Object> sMapRoot  = new Map<string,Object>();
                    try{
                        sMapRoot = (Map<String, Object>)json.deserializeUntyped(JSONContent);
                        system.debug(sMapRoot);
                        List<Object> sFeatures = (List<object>)sMapRoot.get('features');
                        system.debug('sFeatures = ' + sFeatures ); // 'which means sFeatures is ' + sFeatures == null?'null':'not null'
                        if (sFeatures != null && string.valueOf(sFeatures) != '()') {
                            for (Object oTemp: sFeatures) {
                                Map<String, Object> sMapAttributes = (Map<String, Object>)oTemp;   
                                if (sMapAttributes.containsKey('attributes')) {
                                    Map<String, Object> sMapFeatures = (Map<String, Object>)sMapAttributes.get('attributes');
                                    system.debug('sMapFeatures is ' + sMapFeatures);
                                    for (String s2: sMapFeatures.KeySet()) {
                                        system.debug('s2 is ' + s2 + ' and HUCValues is ' + HUCValues);
                                        if (HUCValues.containsKey(s2.ToUpperCase())) {
                                            If (s2.toUpperCase() == 'NAME' && s=='10') HUCValues.put('Watershed', (String)sMapFeatures.get(s2));
                                            If (s2.toUpperCase() == 'HUC10' && sMapFeatures.get(S2) != null) HUCValues.put('HUC10',(String)sMapFeatures.get(S2));
                                            If (s2.toUpperCase() == 'NAME' && s=='12') HUCValues.put('Subwatershed', (String)sMapFeatures.get(s2));
                                            If (s2.toUpperCase() == 'HUC12' && sMapFeatures.get(S2) != null) HUCValues.put('HUC12',(String)sMapFeatures.get(S2));
                                        }
                                    }
                                    HUCVALUES.put('Status','Current');
                                    FailedWLatestURL = false;
                                }   
                            }
                            
                        } // end of sFeatures != null                        
                        else {
                            HUCVALUES.put('Status','4 No USGS HUC found for geocode');
                            ErrorHolder EH = new ErrorHolder('999', 'No features returned', GotLatestURL ?'Error w latest URL__c string. ':'Error w local HUCURL__c' + 'URL was ' + URL);
                            system.debug('EH is ' + EH);
                            ListErrors.add(EH);
                        }
                    } catch(Exception e) {
                        HUCValues.put('Error','Could not deserialize JSON response: ' + e.getMessage());
                        HUCValues.put('Status','3 Undeserializable response from USGS');
                            ErrorHolder EH = new ErrorHolder('999', 'Undeserializable response from USGS', GotLatestURL ?'Error w latest URL__c string. ':'Error w local HUCURL__c' + 'URL was ' + URL);
                            ListErrors.add(EH);
                        	system.debug('Listerrors is ' + ListErrors);
                        // apex.pagemessage
                    } 
                }// end ReponseCode = '200'
                else {
                    HUCValues.put('Status','7 Incorrect URL');    
                    system.debug('Response is ' + resp);
                    HUCVALUES.put('Error','Error ' + string.valueOf(resp.getStatusCode() + ' Error message was: ' + resp.getBody()).LEFT(150)); 
                    // Now try code from WGCorporate                   
                }
                } // End if(FailedWLatestURL!=true)
            } // End loop through different HUC levels         
            system.debug(HUCValues);   
        } // End check that a.billinglat and a.billinglong are populated
        
        else {
            HUCValues.put('Status','5 No geocode in WaterGrass for this address');
        }
        insertHUCValues();
        if (avoidDMLDuringHUC.CallingOut()==false) {
            LogError LE = new LogError();
            LE.LogHUCErrors(ListErrors);
        } else {
            
        }
        return acct;
    }
    
    
    
    private void insertHUCValues(){
        if (HUCValues.get('HUC14') != null) {
            acct.HUC_CODE__c = HUCValues.get('HUC14');
        } else {            
            if (HUCValues.get('HUC12') != null) {
                acct.HUC_CODE__c = HUCValues.get('HUC12');
            } else {                    
                if (HUCValues.get('HUC10') != null) {
                    acct.HUC_CODE__c = HUCValues.get('HUC10');
                }
            }
        }
        if (HUCValues.get('Watershed') != null) acct.HUC_Watershed__c = HUCValues.get('Watershed');
        if (HUCValues.get('Subwatershed') != null) acct.HUC_Subwatershed__c = HUCValues.get('Subwatershed');
        if (HUCValues.get('Subsubwatershed') != null) acct.HUC_Subsubwatershed__c = HUCValues.get('SubSubwatershed');
        if (HUCValues.get('Status') != null) acct.HUC_Status__c = HUCValues.get('Status');
        acct.HUC_Errors__c = HUCValues.get('Error');   
        system.debug('After InsertHUCValues, Acct is now ' + acct);
    } 
    
    public PageReference callFromVFPage(){
        Acct = requestHUC(Acct);
        system.debug('After returning to callFromVFPage, Acct is ' + Acct);
        update Acct;
        return null;
    }
    
    public PageReference returnToAcctDetailPage(){
        PageReference pageRef = new PageReference('/'+Acct.Id);
        pageRef.setRedirect(true);
        return pageRef; 
    }
    
    public string getLatestURL(){
        string LatestURL;
        Map<string,string> HUCURLMap = new Map<string,string>();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setTimeout(20000);
        req.setEndpoint('http://watergrass.force.com/settings?id=a0QA000000Fhi3kMAB&sn&sn2');
        
        Http http = new Http();
        
        If (Test.isRunningTest()){
            LatestURL = 'https://services.nationalmap.gov/arcgis/rest/services/wbd/MapServer/[1]/query?where=&geometry=[2]%2C[3]&geometryType=esriGeometryPoint&outFields=HUC[4]%2C+NAME&returnGeometry=false&f=pjson&inSR=4326|5|6';
        } else {
            try {            
                HttpResponse resp = http.send(req);
                
                if(resp.getStatusCode() == 200) {
                    LatestURL = resp.getBody();               
                    //  if(String.isNotBlank(url)) {
                    //      String[] urlParts = url.split('\\|', 6);
                    //      HUCURLMap.put('URL',urlParts[0]);
                    //      HUCURLMap.put('HUC10',urlParts[1]);
                    //      HUCURLMap.put('HUC12',urlParts[2]);    
                    //  }                    
                }
            } 
            catch (CalloutException e) {
            }
        }       
        GotLatestURL = true;
        FailedWLatestURL = true;
        return LatestURL;  
    }
/*
    public list<Decimal> getHUCTolerance(){
            List<Decimal> GHT = new List<Decimal>();
            String HUCTolString = WGHelpers.getWGSettings().HUCTolerance__c;
            if (HUCTolString == null) HUCTolString = '5.67546681849675499509185629536401E-13';
            Decimal HUCTol = Decimal.valueOf(HUCTolString);
            GHT.add(1/HUCTol);
            GHT.add(1/system.now().getTime());
        return GHT;
            }
*/
    public HTTPResponse getResp(string URLINfo, string level, integer bracket){
        String[] urlParts = URLInfo.split('\\|', 6);
        system.debug('URLParts is ' + URLParts);
        HUCURLMap.put('URL',urlParts[0]);
        HUCURLMap.put('HUC10',urlParts[1]);
        HUCURLMap.put('HUC12',urlParts[2]);  
        system.debug('HUCURLMap is ' + HUCURLMap);
        
        string URL = HUCURLMap.get('URL').replace('[1]', string.valueOf(bracket)).replace('[2]', String.valueOf(acct.AcctLongitude__c)).replace('[3]', String.valueOf(acct.AcctLatitude__c)).replace('[4]', string.ValueOf(level));
        SYSTEM.debug('URLInfo is ' + urlInfo);        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setTimeout(20000);
        req.setEndpoint(url);
        Http http = new Http();
        system.debug('Sent request to URL ' + URL);
        
        HttpResponse resp = http.send(req);
        return resp;
    }

public class AccountAndErrors{
   Account acc;
   List<ErrorHolder> ListEH;
}
    
    
}