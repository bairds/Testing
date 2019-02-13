public class createCustomSettings {
    
    public static void createCustomSettings(){
        
    list<Individual_Contrib_Types__c> lstICRs = new list<Individual_Contrib_Types__c>();//bulk List of custom setting object for bulk insert
    Individual_Contrib_Types__c ICRfield1 = new Individual_Contrib_Types__c(Name='Donation', Contrib_Record_Type__c='Donation'); //Custom Setting for ICR Fields
    lstICRs.add(ICRfield1);
    Individual_Contrib_Types__c ICRfield2 = new Individual_Contrib_Types__c(Name='Major Donation', Contrib_Record_Type__c='Major Donation'); //Custom Setting for ICR Fields
    lstICRs.add(ICRfield2);
    Individual_Contrib_Types__c ICRfield3 = new Individual_Contrib_Types__c(Name='Challenge', Contrib_Record_Type__c='Challenge'); //Custom Setting for ICR Fields
    lstICRs.add(ICRfield3); 
    Individual_Contrib_Types__c ICRfield4 = new Individual_Contrib_Types__c(Name='Membership', Contrib_Record_Type__c='Membership'); //Custom Setting for ICR Fields
    lstICRs.add(ICRfield4);
    insert lstICRs;
        /*
    WG_settings__c testSetting = new WG_settings__c(
        name='newsletter',
        ManageContribsTrigger__c = true,
    	FinalVolunteerCampaignStatus__c = 'Completed',
        FinalDonationCampaignStatus__c = 'Donated',
        FamilyAccountThreshhold__c = 70.00,
        Membership_Grace_Period__c = 90,
            HourlyVolunteerRate__c = 24.14,
        LeadSource_QuestionCnP__c='If this is your first donation or payment to our organization, please tell us how you first heard about us.');
        
    insert testsetting;

*/
        list<CampaignStati__c> ListCSs = new list<CampaignStati__c>();
        // List of CampaignStatus values that are HasResponded=true
        list<string> Stati = new list<string>();
        Stati.add('Attended');
        Stati.add('Completed');
        Stati.add('Contributed');
        Stati.add('Donated');
        Stati.add('No Show');
        Stati.add('Responded No');
        Stati.add('RSVPed and Attended');
        Stati.add('Signed e-petition');
        Stati.add('Took action');
        for (string s : stati) {
            CampaignStati__c cs=new CampaignStati__c(
                    name = s,
                    HasResponded__c = true);
            ListCSs.add(cs);
        }
        Stati.clear();
        // List of CampaignStatus values that are HasResponded=false
        Stati.add('Communication sent');
        for (string s : stati) {
            CampaignStati__c cs=new CampaignStati__c(
                    name = s,
                    HasResponded__c = false);
            ListCSs.add(cs);
        }
        insert ListCSs;
        system.debug('Just inserted campaign Stati ' + ListCSs);
    }
}