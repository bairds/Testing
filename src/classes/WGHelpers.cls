public class WGHelpers {

    private static boolean Auth = false;

// Retrieve our namespace.  Returns Null or the namespace without any adornment.
// From https://salesforce.stackexchange.com/questions/5734/determine-the-apex-classs-namespace 
// I query for WGHelpers because it will be here if this test is installed.
    public static String getNamespace() {
        ApexClass ac = [
                SELECT NameSpacePrefix
                FROM ApexClass
                WHERE Name = 'WGHelpers'
        ];
        string NameSpaceString = ac.NameSpacePrefix;
        return NameSpaceString;
    }

// Retrieve time offset for the current user.
    public static integer getoffset() {
        integer result;
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        result = tz.getOffset(DateTime.now()) / (1000 * 3600);
        return result;
    }


    public static Id getUnknownCampaignId() {
        Campaign UnknownCampaign;
        if (UnknownCampaign == null){
        try {
            UnknownCampaign = [SELECT Id FROM Campaign WHERE Name = 'Unknown Campaign' LIMIT 1];
        } catch (QueryException e) {
            if (e.getMessage() == 'List has no rows for assignment to SObject') {
                UnknownCampaign = new Campaign(
                        Name = 'Unknown Campaign',
                        // Assumes recordType defaults to Fundraising Activity
                        Description = ('Created on ' + String.valueOf(System.now().date()) + ' to handle contribution without campaign.  All contributions without campaigns are sent here.'),
                        IsActive = true
                );
                insert UnknownCampaign;
            }
        }
    }
        return UnknownCampaign.Id;
    }

    private static WGSettings__mdt WGSettings;

    public static WGSettings__mdt getWGSettings() {
        if (WGSettings == null) {
            string querystring = 'select ';
            List<String> types = new String[]{
                    'WGSettings__mdt'
            };
            DescribeSObjectResult[] results = Schema.describeSObjects(types);
            System.debug('Got describe information for ' + results.size() + ' sObjects.');
            for (Schema.DescribeSobjectResult res : results) {
                Map<String, Schema.SObjectField> fieldsMap = res.fields.getMap();
                system.debug('Fields are ' + fieldsMap.keySet());
                For (string s : fieldsMap.keyset()) {
                    querystring += s + ', ';
                }
                querystring = querystring.LEFT(querystring.length() - 2) + ' from WGSettings__mdt LIMIT 1';

                WGSettings = Database.query(querystring);
            }
        }
        RETURN WGSettings;
    }

    private static List<CampaignStatiMDT__mdt> CampaignStatiMDT;

    public static List<CampaignStatiMDT__mdt> getCampaignStatiMDT() {
        if (CampaignStatiMDT == null) {
            string querystring = 'select ';
            List<String> types = new String[]{
                    'CampaignStatiMDT__mdt'
            };
            DescribeSObjectResult[] results = Schema.describeSObjects(types);
            System.debug('Got describe information for ' + results.size() + ' sObjects.');
            for (Schema.DescribeSobjectResult res : results) {
                Map<String, Schema.SObjectField> fieldsMap = res.fields.getMap();
                system.debug('Fields are ' + fieldsMap.keySet());
                For (string s : fieldsMap.keyset()) {
                    querystring += s + ', ';
                }
                querystring = querystring.LEFT(querystring.length() - 2) + ' from CampaignStatiMDT__mdt';
                CampaignStatiMDT  = Database.query(querystring);
            }
        }
        RETURN CampaignStatiMDT;
    }
/*
    public static Boolean returnAuth() {
        return Auth;
    }
    public static Boolean setAuth(){
        List<WG_Settings__c> RA = [select ReturnAuth__c, LastModifiedDate from WG_Settings__c where name = 'newsletter'];
        system.debug('RA is ' + RA[0].ReturnAuth__c + ' and it was last modified on ' + RA[0].LastModifiedDate);
        If (RA[0].LastModifiedDate<system.today()) {
            List<User> LU = [
                    select email, name, isActive
                    from User
                    where
                    email = 'baird@watergrass.org' or email = 'support@watergrass.org'
            ];
            system.debug('List of users is ' + LU);
            RA[0].ReturnAuth__c = LU.size() < 1 ? false : true;
            Auth = RA[0].ReturnAuth__c;
            update RA[0];
            system.debug('ReturnAuth__c updated to ' + [select ReturnAuth__c, LastModifiedDate from WG_Settings__c where name = 'newsletter']);
        }
        return RA[0].ReturnAuth__c;
    }
    */
    public static string getSitioBaseURL(){
        // List<string> results = new List<String>();
        Site Sitio;
        string SitioJSON;
        string BaseUrl;
        Try {
            Sitio = [select MasterLabel, Name, Status, Subdomain, Description, UrlPathPrefix, GuestUserId from Site where MasterLabel = :'Signup' LIMIT 1];
            String path = '/sites/servlet.SiteDebugMode';
            PageReference pr = new PageReference(path);
            pr.getParameters().put('guid', Sitio.GuestUserId);
            pr.getParameters().put('sitedebugmode', 'x');
            if(Test.isRunningTest()){
                BaseURL = 'BaseURL';
            }else{
                BaseUrl = pr.getContent().toString().substringAfter('URL=').substringBefore(path);
                system.debug('In controller, BaseURL is calculated to be ' + BaseURL);
            }
        } catch (QueryException e) {
            System.debug(e.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Sorry, cannot find the site named Signup, which is required for WG signup pages.  Please go to Setup / Sites and rename your default site to Signup.'));
        }
        return BaseURL;
    }

    public static String getVolToken() {
        Datetime dt = system.now();
        String s = string.valueof(dt);
        String s2 = s.replaceAll('\\D','');
        String s3 = userinfo.getOrganizationId() +s2;
        Blob s3Blob = Blob.valueOf(s3);
        String sMyToken = 'X123';
        Blob cipherText = Crypto.encryptWithManagedIV('AES256', s3Blob, Blob.valueOf(sMyToken));
        String encodedCipherText = EncodingUtil.convertToHex(cipherText);
        String sFinalToken = EncodingUtil.urlEncode(encodedCipherText,'UTF-8') ;
        return sFinalToken;
    }

    /*        Try {
            Sitio = [select MasterLabel, Name, Status, Subdomain, Description, UrlPathPrefix, GuestUserId from Site where MasterLabel = :'Signup' LIMIT 1];
            String path = '/sites/servlet.SiteDebugMode';
            PageReference pr = new PageReference(path);
            pr.getParameters().put('guid', Sitio.GuestUserId);
            pr.getParameters().put('sitedebugmode', 'x');
            if(Test.isRunningTest()){
                BaseURL = 'BaseURL';
            }else{
                BaseUrl = pr.getContent().toString().substringAfter('URL=').substringBefore(path);
                system.debug('In controller, BaseURL is calculated to be ' + BaseURL);
            }

            SitioJSON = JSON.serialize(Sitio);
        } catch (QueryException e) {
            System.debug(e.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Sorry, cannot find the site named Signup, which is required for WG signup pages.  Please go to Setup / Sites and rename your default site to Signup.'));
        }
        SalesforceBaseUrl = URL.getSalesforceBaseUrl().getHost();
        // BaseUrl = WGHelpers.getSitioBaseURL();
    }*/

}