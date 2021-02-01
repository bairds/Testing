/**
 * Created by Baird on 7/4/2019.
 * Revised 5/2020 to avoid errors due to Capitalization or UpperCase    
 */

@IsTest
private class createCampaignMemberStatiTEST {

    @istest static void CreateNewCampaign() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Campaign TestCamp = ctv.fetchTestCampaign();
        // Were all the CampaignStatiMDT values created, plus one for Added to Campaign and one for Donated?
// Find all the values in CampaignStatiMDT
        List<CampaignStatiMDT__mdt> SettingCMs = [select Label from CampaignStatiMDT__mdt];
// Find all the settings for this campaign
        List<CampaignMemberStatus> CMSs = [select cms.Id, cms.Label, cms.isDefault from CampaignMemberStatus cms where cms.CampaignId = :TestCamp.Id];
        system.assertEquals(CMSs.size()-2, SettingCMs.size(), 'Should have found all the CampaignStatiMDT values in the Campaign Member Stati, plus "Added to Campaign" and "Donated."');
        // Make sure all the campaign status values from the CampaignStatiMDT__mdt are here
        Map<string, CampaignMemberStatus> CMSMap = new Map<string, CampaignMemberStatus>();
        For (CampaignMemberStatus c : CMSs) CMSMap.put(c.label.TOUPPERCASE(), c);
        For (CampaignStatiMDT__mdt c : SettingCMs)
            system.assert(CMSMap.CONTAINSKEY(c.label.TOUPPERCASE()));
    }

    @IsTest
    static void campaignInsertTest() {
        // Test single record insert
        System.debug('Inserting 1 campaign record... (single record validation)');
        Campaign c = new Campaign(Name='Test');
        insert c;
        // Add 3 custom CampaignMemberStatus values
        List<CampaignMemberStatus> ListCMS = new List<CampaignMemberStatus>();
        for (integer i = 0 ; i<3; i++){
            CampaignMemberStatus cms = new CampaignMemberStatus(
                    label = 'CustomStatus ' + i,
                    HasResponded = true,
                    IsDefault = false,
                    SortOrder = 10 + i,
                    CampaignId = c.Id
            );
            ListCMS.add(cms);
        }
        insert ListCMS;
        List<CampaignMemberStatus> CMValues = [select id, label, sortorder, isdefault from CampaignMemberStatus where campaignID = :c.id];
        for (CampaignMemberStatus cms : CMValues) {
            system.debug('Campaign Status: ' + cms);
        }
        system.debug('CMValues.size() is ' + CMValues.size());
        // Is this equal to the number of CampaignSTati in the custom metadata + 5?
        List<CampaignStatiMDT__mdt> resultList = [select id from CampaignStatiMDT__mdt];
        system.debug('resultList found ' + resultList.size() + ' values in the Custom metadata for campaignstati.');
        for (CampaignStatiMDT__mdt r : resultList) system.debug('resultList value is ' + resultList);
        system.AssertEquals(resultList.size()+5,CMValues.size());

        Campaign c2 = c.clone(false,false,false,false);
        CMValues = [select id, label, sortorder, isdefault from CampaignMemberStatus where campaignID = :c2.id];
        system.debug('After cloning the campaign, it has ' + CMValues.size() + ' campaign member status values');

        // Add a new custom status
        CampaignMemberStatus cms = new CampaignMemberStatus(
                label = 'CustomStatus4 ',
                HasResponded = true,
                IsDefault = false,
                SortOrder = 14,
                CampaignId = c.Id
        );
        insert cms;

        // Update c
        c.Name = 'TestcampaignUpdated';
        update c;
        CMValues = [select id, label, sortorder, isdefault from CampaignMemberStatus where campaignID = :c.id];
        system.debug('After updating there are ' + CMValues.size() + ' CampaignMemberStatus values');
        // Are the stati values created?
        Boolean foundCustomStatus4;
        // Test for all the stati from the custom metadata
        List<CampaignStatiMDT__mdt> SettingCMs = [select Label from CampaignStatiMDT__mdt];
        system.assertEquals(resultList.size(),SettingCMs.size(),'There should be each CampaignStati in the metadata');
        List<string> Stati = new List<String>();
        For (CampaignStatiMDT__mdt csm : SettingCMs) Stati.add(csm.Label.toUpperCase());
        system.assertEquals(resultList.size(),Stati.size(),'Do we have each campaignstati from meta data?');
        integer StatiFromCustomSetting = 0;
        for (CampaignMemberStatus campmemstat : CMValues) {
            system.debug('Is Campaign Status: ' + campmemstat.Label + ' contained in ' + Stati);
            if (campmemstat.label=='CustomStatus4') foundCustomStatus4 = true;
            if (Stati.contains(campmemstat.Label.ToUpperCase())) StatiFromCustomSetting += 1;
        }
        system.assertEquals(true,foundCustomStatus4);
        system.debug('StatiFromCustomSetting is ' + StatiFromCustomSetting);
        system.assertEquals(SettingCMs.size(),StatiFromCustomSetting,'Did not create all the stati from the meta data.  The stati are ' + CMValues);

    }

    @istest static void ManyNewCampaigns() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Campaign TestCamp = ctv.fetchTestCampaign();
        List<Campaign> ListCamps = new List<Campaign>();
        For (integer i = 0; i < 10; i++) {
            Campaign Camp = new Campaign(
                    name = 'TestCamp' + i
            );
            ListCamps.add(Camp);}
        insert ListCamps;
        List<CampaignMemberStatus> CMSs = [select cms.Id, cms.Label, cms.isDefault from CampaignMemberStatus cms where cms.CampaignId = :ListCamps[9].Id];
        For (CampaignMemberStatus CMS : CMSs) system.debug('CampaignMemberStatus is ' + CMS);
        // system.assertEquals(12,CMSs.size());
        List<CampaignStatiMDT__mdt> SettingCMs = [select Label from CampaignStatiMDT__mdt];
        List<string> Stati = new List<String>();
        For (CampaignStatiMDT__mdt csm : SettingCMs) Stati.add(csm.Label.toUpperCase());
        integer StatiFromCustomSetting = 0;
        for (CampaignMemberStatus campmemstat : CMSs) {
            system.debug('Campaign Status: ' + campmemstat);
            if (Stati.contains(campmemstat.Label.toUpperCase())) StatiFromCustomSetting += 1;
        }
        system.assertEquals(SettingCMs.size(),StatiFromCustomSetting,'Did not create all the stati from the meta data');

// Find all the settings for this campaign
        CMSs = [select cms.Id, cms.Label, cms.isDefault from CampaignMemberStatus cms where cms.CampaignId = :ListCamps[0].Id];
        system.assertEquals(CMSs.size(), SettingCMs.size()+2, 'Should have found all the CampaignStatiMDT values in the Campaign Member Stati, plus "Added to Campaign" and "Donated."');
        Map<string, CampaignMemberStatus> CMSMap = new Map<string, CampaignMemberStatus>();
        For (CampaignMemberStatus c : CMSs) CMSMap.put(c.label.TOUPPERCASE(), c);
        system.debug('CMSMap is ' + CMSMap);
        For (CampaignStatiMDT__mdt c : SettingCMs) {
            system.debug('CMS is ' + c);
            system.assert(CMSMap.CONTAINSKEY(c.Label.TOUPPERCASE()));
        }
    }
}