@IsTest
public class WGHelpersTest {

static testMethod void getNamespaceTest() {

	 String namespace = WGHelpers.getNamespace();
}

    static testMethod void TestTimeZoneOffset() {
      // This code runs as the system user
      Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
      User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/New_York', Username='standarduser@WGtestorg.com');
     
        System.runAs(u){
     		Double offset = WGHelpers.getoffset();
            System.debug('Offset for NY is ' + offset);
            System.assert(offset == -4.0 || offset == -5.0, 'Time offset for NY should be -4 or -5 hours / 24 hours in a day');
        }
    }

    @IsTest static void UnknownCampaign(){
        Campaign ConfirmCampaign = [SELECT Id, Name FROM Campaign WHERE Id =: WGHelpers.getUnknownCampaignId()];
        System.assertEquals('Unknown Campaign',ConfirmCampaign.Name);
    }

    public static string getBaseURL(){
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
            SitioJSON = JSON.serialize(Sitio);
        } catch (QueryException e) {
            System.debug(e.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Sorry, cannot find the site named Signup, which is required for WG signup pages.  Please go to Setup / Sites and rename your default site to Signup.'));
        }
        return BaseURL;
    }

    @IsTest
    static private void TestVolToken() {
        string resultstring = WGHelpers.getVolToken();
        system.debug('resultStringis ' + resultString);
        system.assertEquals(64,resultString.length(),'Should have returned token 64 characters long');
    }

    @IsTest
    static private void TestgetManageOCRs(){
        WGHelpers.BManageOCRs = true;
        Boolean result = WGHelpers.getManageOCRs();
        system.debug(result,true);
    }
}