// Controller cleans up any campaign members for which a contribution
// has been submitted but which are still in the HasResponded==false
// category.
// July 2016 Bulkified with second method
// Sept 2018 Remove single trigger; just use bulkified.
// Jan 2019 Upgraded custom settings to custom metadata.
public class updatePrimaryContributorCampaignStatus {
    
    
    public static void UpdateCMStatus(list<Opportunity> newOpps){
        WGSettings__mdt Setting = WGHelpers.getWGSettings();
        ID VolunteerTaskRTID =  Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Volunteer Task').getRecordTypeId();
            //Bulkified trigger
            Map<string, campaignMember> CMMap = new Map<string, CampaignMember>();
            Map<ID,CampaignMember> MapCMs = new Map<ID,CampaignMember>();
            List<CampaignMember> CMs;
            Set<Id> CampIds=new Set<Id>();
            Set<Id> CtctIds=new Set<Id>();
            
            For (Opportunity Opp : NewOpps) {
                CampIds.add(Opp.CampaignId);
                CtctIds.add(Opp.Contact__c);
            }
            
            // Create a map of all the possibly relevant CampaignMembers which have not yet been marked HasResponded.  
            // This may include some campaignMembers which don't have an opportunity assigned to them.
            // We're only updating those CampaignMembers who have a contribution for the campaign but are still marked
            // "Added to campaign" or some other status where HasREsponded=false.
            CMs=[select id, status, contactId, campaignId from CampaignMember where campaignId in :CampIds and ContactId in :CtctIds and HasResponded!=true];
            For (CampaignMember cm : CMs) {
                CMMap.put(cm.campaignId+'-'+cm.contactId,CM);
            }
            
            For (Opportunity Opp : NewOpps) {
                // Check to make sure there's a campaign member that matches this contribution.
                if (CMMap.containsKey(Opp.campaignId+'-'+Opp.contact__c)) {
                    CampaignMember cm = CMMap.get(Opp.campaignId+'-'+Opp.contact__c);
                    if (Opp.RecordTypeId != VolunteerTaskRTID) {
                        cm.status = Setting.FinalDonationCampaignStatus__c;
                        system.debug('Just set cm status to ' + Setting.FinalDonationCampaignStatus__c);
                    } else {
                        cm.status = Setting.FinalVolunteerCampaignStatus__c;
                        system.debug('Just set cm status to ' + Setting.FinalVolunteerCampaignStatus__c);
                    }
                    if (!MapCMs.containsKey(cm.id))                     
                        MapCMs.put(cm.id,cm);
                } //end Check to make sure there's a campaign member that matches this contribution 
            }  // end loop through NewOpps
            system.debug('MapCMs is ' + MapCMs);            
            List<CampaignMember> UpdateCMs = MapCMs.values();
            update UpdateCMs;
        system.debug('UpdateCMs are ' + UpdateCMs);
         // } // end else we need bulk approach
    }  // end method
} // end class