public class WGHelpers {

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
}