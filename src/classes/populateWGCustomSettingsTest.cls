@isTest
private class populateWGCustomSettingsTest {
    
    static testmethod void TestAll(){
        populateWGCustomSettings.populateAllSettings();
        system.assertEquals('e-newsletter',WG_Settings__c.getInstance('newsletter').Online_signup_newsletter__c);
        system.assertEquals(true,CampaignStati__c.getInstance('Donated').HasResponded__c);
        system.assertEquals('Donation',Individual_Contrib_Types__c.getInstance('Donation').Contrib_Record_Type__c);
    }
}