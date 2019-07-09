/**
 * Created by Baird on 7/6/2019.
 * If clone, store all existing values;
 * Put all existing values into deleteCMSs, remove IsDEfault as I do;
 * Delete existing values;
 * Insert Added to Campaign and Responded Yes;
 * Recreate existing values in insertCMSs;
 * If WG standard values aren't in the existing values, add them to insertCMSs;
 * insert InsertCMSs;
 */

public with sharing class createCampaignMemberStati {

    public static void createCampaignMemberStati(List<Id> CampIds) {
        // MAP EXISTING CMSs
        list<CampaignMemberStatus> insertCMSs = new list<CampaignMemberStatus>();
        list<CampaignMemberStatus> deleteCMSs = new list<CampaignMemberStatus>();
        list<CampaignMemberStatus> ExistingCMSs = [
                SELECT Id, label, isDefault, CampaignId, SortOrder, HasResponded
                from CampaignMemberStatus
                WHERE
                        CampaignId IN :CampIds
                ORDER BY CampaignId
        ];
        system.debug('After initial query, ExistingCMSs are ' + ExistingCMSs.size());
        Map<id, Map<string, CampaignMemberStatus>> CampCMSMap = new Map<id, Map<string, CampaignMemberStatus>>();
        For (CampaignMemberStatus cms : ExistingCMSs) {
            // Create map of existing CMS by CampaignId
            if (CampCMSMap.get(cms.campaignId) == null) {
                Map<string, CampaignMemberStatus> newMap = new Map<string, CampaignMemberStatus>();
                NewMap.put(cms.label.TOUPPERCASE(), cms);
                CampCMSMap.put(cms.campaignId, newMap);
            } else {
                CampCMSMap.get(cms.campaignId).put(cms.label.TOUPPERCASE(), cms);
            }
            if (cms.IsDefault = false) deleteCMSs.add(cms);
            // Insert Added to Campaign and Responded Yes;
        }
        // Delete existing values;
        system.debug('deleteCMSs include ' + deleteCMSs.size() + ' members.');
        delete deleteCMSs;

        // Loop through the campaignIds
        For (id CampId : CampIds) {
            Map<string, CampaignMemberStatus> ThisCampCMSMap = CampCMSMap.get(campId);
            system.debug('CampCMSMap for this campaign is ' + ThisCampCMSMap);
            // Insert Added to Campaign and Responded Yes;

            CampaignMemberStatus added = new CampaignMemberStatus();
            added.CampaignId = CampId;
            added.HasResponded = FALSE;
            added.IsDefault = TRUE;
            added.Label = 'Added to campaign';
            added.SortOrder = 100;
            insertCMSs.add(added);
            system.debug('Just added CampaignMemberStatus ' + added.Label + ' at SortOrder ' + added.SortOrder);

            CampaignMemberStatus respondYes = new CampaignMemberStatus();
           if (ThisCampCMSMap == null || ThisCampCMSMap.get('RESPONDED YES') == null) {
                respondYes.CampaignId = CampId;
                respondYes.HasResponded = TRUE;
                respondYes.IsDefault = FALSE;
                respondYes.Label = 'Responded Yes';
                respondYes.SortOrder = 101;
                insertCMSs.add(respondYes);
                system.debug('Just added CampaignMemberStatus ' + respondYes.Label + ' at SortOrder ' + respondYes.SortOrder);
            }

            // Use i as the counter in the following loop;
            integer i = 102;
            // If WG standard values aren't in the existing values, add them to insertCMSs;
            List<CampaignStatiMDT__mdt> CSList = WGHelpers.getCampaignStatiMDT();
            Map<string, CampaignStatiMDT__mdt> CSMap = new Map<string, CampaignStatiMDT__mdt>();
            for (CampaignStatiMDT__mdt c : CSList) CSMap.put(c.MasterLabel.TOUPPERCASE(), c);
            system.debug('Map of CampaignStati is ' + CSMap);
            for (string s : CSMap.keyset()) {
                if (ThisCampCMSMap == null || ThisCampCMSMap.get(s.toUpperCase()) == null) {
                    CampaignStatiMDT__mdt CS = CSMap.get(s);
// Add campaign member status for "Communication sent"
                    CampaignMemberStatus CMS = new CampaignMemberStatus();
                    CMS.CampaignId = CampId;
                    CMS.HasResponded = CS.HasResponded__c;
                    CMS.IsDefault = FALSE;
                    CMS.Label = s;
                    CMS.SortOrder = i;
                    system.debug('Just added CampaignMemberStatus ' + cms.Label + ' at SortOrder ' + cms.SortOrder);
                    insertCMSs.add(CMS);
                    i = i + 1;
                }
            }
            system.debug('Before inserting CMS values, insertCMSs are ' + insertCMSs.size() + ' members.');
            for (CampaignMemberStatus cms : insertCMSs) system.debug('InsertCMS is ' + CMS);
            ExistingCMSs = [SELECT Id, label, isDefault, CampaignId, SortOrder from CampaignMemberStatus WHERE CampaignId IN :CampIds ORDER BY CampaignId];
            system.debug('Before inserting CMS values, ExistingCMSs are ' + ExistingCMSs);
        }
        insert insertCMSs;
    }
}