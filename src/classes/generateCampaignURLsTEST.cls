/**
 * Created by Baird on 2/25/2019.
 */

@IsTest
private class generateCampaignURLsTEST {
    @IsTest
    static void testBehavior() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Campaign camp = ctv.fetchTestCampaign();
        PageReference pageRef = Page.CampaignURLsSection;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', camp.Id);

        ApexPages.StandardController sc = new ApexPages.StandardController(camp);
        generateCampaignURLs GCURL = new generateCampaignURLs(sc);
        GCURL.getRegisterOptions();
        GCURL.getSelectCampaignOptions();

        system.assertEquals('Testcampaign',camp.Name);

    }
}