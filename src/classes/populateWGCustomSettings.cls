// Sept 3 2016 Created this to make deployment easier.
// Updated July 2018
public class populateWGCustomSettings {

    public static void populateAllSettings(){
        populateWGSettings();
        populateIndividualContribTypes();
        populateCampaignStati();
    }
    
    public static void populateWGSettings(){
        WG_Settings__c wgs = new WG_Settings__c(
            name='newsletter',
            FinalDonationCampaignStatus__c='Donation',
            FinalVolunteerCampaignStatus__c = 'Completed',
            ManageContribsTrigger__c = true,
            Online_signup_newsletter__c = 'e-newsletter',
        	LeadSource_QuestionCnP__c = 'If this is your first donation or payment to our organization, please tell us how you first heard about us.',
        	FamilyAccountThreshhold__c = 70.00,
        	AccountAfterInsertTrigger__c = true,
        	ContactBeforeAfterInsertTrigger__c = true,
                HourlyVolunteerRate__c = 24.14,
        	Membership_Grace_Period__c = 90);
        insert wgs;
    }
    
    public static void populateIndividualContribTypes(){
        List<Individual_Contrib_Types__c> LICT = new List<Individual_Contrib_Types__c>();
        List<string> ICTNames = new List<string>();
        ICTNames.add('Challenge');
        ICTNames.add('Donation');
        ICTNames.add('Major Donation');
        ICTNames.add('Membership');
        For (string ICTName : ICTNames) {
            Individual_Contrib_Types__c ict = new Individual_Contrib_Types__c(
                name=ICTName,
                Contrib_Record_Type__c=ICTName);
            LICT.add(ict);
        }
        insert LICT;
    } // end method

    
    public static void populateCampaignStati(){
        List<CampaignStati__c> LCS = new List<CampaignStati__c>();
        List<string> CSNames = new List<string>();
        CSNames.add('Attended');
        CSNames.add('Contributed');
        CSNames.add('Donated');
        CSNames.add('NoShow');
        CSNames.add('Responded No');
        CSNames.add('RSVPed and Attended');
        CSNames.add('Signed e-petition');
        CSNames.add('Took action');
        For (string CSName : CSNames) {
            CampaignStati__c cs = new CampaignStati__c(
                name= CSName,
                HasResponded__c=true);
            LCS.add(cs);
        }
        // Now add names for Responded No;
        CSNames.clear();
        CSNames.add('Communication sent');
        For (string CSName : CSNames) {
            CampaignStati__c cs = new CampaignStati__c(
                name= CSName,
                HasResponded__c=false);
            LCS.add(cs);
        }
        insert LCS;
    } // end method
     
}