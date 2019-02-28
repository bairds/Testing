/**
 * Created by Baird on 2/27/2019.
 */

@IsTest
private class generateMasterCampURLsTEST {
    @IsTest
    static void testBehavior() {
        Master_Campaign__c MasterCamp = new Master_Campaign__c(
                name = 'Test Master Campaign'
        );
        insert MasterCamp;
        List<Campaign>  ListCamp = new List<Campaign>();
        Id VolRT = [select id from RecordType where name = 'Volunteer Event' LIMIT 1].Id;
        for (integer i = 0; i < 3; i++){
            Campaign c = new Campaign(
                    name = 'Campaign' + i,
                    RecordTypeId = volRT,
                    Master_Campaign__c = MasterCamp.Id
            );
        }

        PageReference pageRef = Page.MasterCampURLsSection;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', MasterCamp.Id);

        ApexPages.StandardController sc = new ApexPages.StandardController(MasterCamp);
        generateMasterCampURLs GCURL = new generateMasterCampURLs(sc);
        GCURL.getSelectCampaignOptions();

        system.assertEquals('Test Master Campaign',MasterCamp.Name);
    }
}