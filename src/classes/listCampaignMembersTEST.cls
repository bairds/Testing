/**
 * Created by Baird on 11/1/2018.
 */
@IsTest
private class listCampaignMembersTEST {

//    @testSetup static void setup() {
//        createCustomSettings.createCustomSettings();
//    }

    static testMethod void listCampaignMembersTEST() {
// Create test variables
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        Contact TestCtct = ctv.fetchTestContact();
        Campaign TestCamp = ctv.fetchTestCampaign();
        Lead TestLd = ctv.fetchTestLead();
        CampaignMember cm1;
        CampaignMember cm2;
        cm1 = new CampaignMember(
                CampaignId = TestCamp.Id,
                ContactId = TestCtct.Id,
                Status = 'Added to Campaign');
        insert cm1;
        cm2 = new CampaignMember(
                CampaignId = TestCamp.Id,
                LeadId = TestLd.Id,
                Status = 'Added to Campaign');
        insert cm2;

// Test initial state
        PageReference pageRef = Page.listCampaignMembersPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', TestCamp.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(TestCamp);
        listCampaignMembers LCM = new listCampaignMembers(sc);
        LCM.getCmpMmbrs();
        System.assertEquals(LCM.campaignName,TestCamp.Name);
        System.assertEquals(LCM.getnumberMembers(),2);

//Set one member for deletion, test if deleted
        LCM.CmpMmbrs[0].ToDelete=true;
        system.debug('CmpMmbrs[0] should have ToDelete=true ' + LCM.CmpMmbrs[0]);
        LCM.deleteRefresh();
        PageReference return_to_list = new PageReference('/apex/listCampaignMembersPage?id='+LCM.camp.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',LCM.Camp.Id);
        listCampaignMembers LCM1 = new listCampaignMembers(sc);
        System.assertEquals(1,LCM1.getnumberMembers());
    }
}