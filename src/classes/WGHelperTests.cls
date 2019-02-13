@IsTest
public class WGHelperTests {

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

}