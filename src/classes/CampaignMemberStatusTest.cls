@isTest 
private class CampaignMemberStatusTest {

    static testMethod void campaignInsertTest() {
        // Test single record insert
        System.debug('Inserting 1 campaign record... (single record validation)');
        Campaign c = new Campaign(Name='Test');
        insert c;
        List<CampaignMemberStatus> CMValues = [select id, label, sortorder, isdefault from CampaignMemberStatus where campaignID = :c.id];
        for (CampaignMemberStatus cms : CMValues) {
            system.debug('Campaign Status: ' + cms);
        }
        system.debug('CMValues.size() is ' + CMValues.size());
        //systemAssertEquals(11,CMValues.size());
	}

    static testMethod void campaignCloneTest() {
        Campaign c = new Campaign(Name='Test');
        insert c;
        List<CampaignMemberStatus> CMValues = [select id, label, sortorder, isdefault from CampaignMemberStatus where campaignID = :c.id];
        for (CampaignMemberStatus cms : CMValues) {
            system.debug('Campaign Status: ' + cms);
        }
        system.debug('CMValues.size() is ' + CMValues.size());

		Campaign c2 = c.clone();
        List<CampaignMemberStatus> CMValues2 = [select id, label, sortorder, isdefault from CampaignMemberStatus where campaignID = :c2.id];
		system.assertEquals(CMValues,CMValues2,'After cloning new campaign status values different from old campaign.');             
    }    
    
	static testMethod void bulkCampaignInsertTest() {		
        System.debug('Inserting 3 campaign records... (bulk validation)');
        List<Campaign> c2 = new List<Campaign>();
        for(integer i=0; i<3; i++) {
            c2.add(new Campaign(Name='Test'+i));
         }
        insert c2;
        List<CampaignMemberStatus> CMValues = [select id, label, sortorder, isdefault from CampaignMemberStatus where CampaignId = 
                                               :[select id from Campaign where name = 'Test0'].id];
        System.debug('IN bulk method campaignStatusValues are ' + CMValues);
    }
}