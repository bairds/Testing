/**
 * Created by Baird on 2/4/2019.
 */

@isTest
private class UpdateCampaignMemberStatusTEST {

    @istest static void CreateNewCampaign() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Campaign TestCamp = ctv.fetchTestCampaign();
        // Were all the CampaignStatiMDT values created, plus one for Added to Campaign and one for Donated?
// Find all the values in CampaignStatiMDT
        List<CampaignStatiMDT__mdt> SettingCMs = [select Label from CampaignStatiMDT__mdt];
// Find all the settings for this campaign
        List<CampaignMemberStatus> CMSs = [select cms.Id, cms.Label, cms.isDefault from CampaignMemberStatus cms where cms.CampaignId = :TestCamp.Id];
        system.assertEquals(CMSs.size() - 2, SettingCMs.size(), 'Should have found all the CampaignStatiMDT values in the Campaign Member Stati, plus "Added to Campaign" and "Donated."');
        // Make sure all the campaign status values from the CampaignStatiMDT__mdt are here
        Map<string, CampaignMemberStatus> CMSMap = new Map<string, CampaignMemberStatus>();
        For (CampaignMemberStatus c : CMSs) CMSMap.put(c.label, c);
         For (CampaignStatiMDT__mdt c : SettingCMs)
             system.assert(CMSMap.keyset().CONTAINS(c.label));
    }
/*

    @istest static void ManyNewCampaigns() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Campaign TestCamp = ctv.fetchTestCampaign();
        List<Campaign> ListCamps = new List<Campaign>();
        For (integer i = 0; i < 50; i++) {
            Campaign Camp = new Campaign(
                    name = 'TestCamp' + i
            );
            ListCamps.add(Camp);
        }
        insert ListCamps;

        List<CampaignStatiMDT__mdt> SettingCMs = [select Label from CampaignStatiMDT__mdt];
// Find all the settings for this campaign
        List<CampaignMemberStatus> CMSs = [select cms.Id, cms.Label, cms.isDefault from CampaignMemberStatus cms where cms.CampaignId = :ListCamps[0].Id];
        system.assertEquals(CMSs.size() - 2, SettingCMs.size(), 'Should have found all the CampaignStatiMDT values in the Campaign Member Stati, plus "Added to Campaign" and "Donated."');
        Map<string, CampaignMemberStatus> CMSMap = new Map<string, CampaignMemberStatus>();
        For (CampaignMemberStatus c : CMSs) CMSMap.put(c.label, c);
        For (CampaignStatiMDT__mdt c : SettingCMs)
            system.assert(CMSMap.keyset().CONTAINS(c.label));
    }
 */
}