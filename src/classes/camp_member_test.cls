@isTest
private class camp_member_test {

/*
    @testSetup static void setup() {
        createCustomSettings.createCustomSettings();
    }
*/

    static testMethod void camp_member_list_test() {
    	// Create test variables
    	Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        Contact TestCtct = ctv.fetchTestContact();
        Campaign TestCamp = ctv.fetchTestCampaign();
        Lead TestLd = ctv.fetchTestLead();
campaignmember cm1;
Campaignmember cm2;
    	cm1 = new campaignmember(
    		campaignid = TestCamp.id,
    		contactid = TestCtct.id,
    		status = 'Added to Campaign');
    		insert cm1;
		cm2 = new campaignmember(
    		campaignid = TestCamp.id,
    		leadid = TestLd.id,
    		status = 'Added to Campaign');
    		insert cm2;
    	    	
  // Test initial state
    PageReference pageRef = Page.camp_member_list_page;
    Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', TestCamp.ID);
    ApexPages.StandardController sc = new ApexPages.StandardController(Testcamp);
    camp_members_list CML = new camp_members_list(sc);
    system.assertEquals(CML.getCampaignName(),TestCamp.name);
    CML.getList_contacts();
    system.assertEquals(CML.getNumberMembers(),2);
    
  //Set one member for deletion, test if deleted
  	system.debug(CML.list_contacts);
  	CML.deleteRefresh();
    CML.getList_contacts();
  	//system.assertEquals(1,CML.getNumberMembers());


    }
}