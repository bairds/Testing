/**
 * Created by Baird on 1/25/2021.
 */

@IsTest
private class insertiATSTEST {
    @IsTest
    // Create an iATS donation, without a primary contributor and insert it.
    // Does this create an error?
    static void insertiATSDonation() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        Contact TestCtct = ctv.fetchTestContact();
        Campaign TestCamp = ctv.fetchTestCampaign();
        Opportunity TestOpp = new Opportunity(
          CloseDate = date.today(),
                Amount = 1.11,
                StageName = 'Payment Received',
                AccountId = TestAcct.Id,
                CampaignId = TestCamp.Id,
                Name = 'Test Opportunity'
        );
        insert TestOpp;
        system.assertEquals(1,[SELECT Id from Opportunity].size(),'Should have been one Opportunity created.');
        OpportunityContactRole ocr = new OpportunityContactRole(
                IsPrimary = true,
                OpportunityId = TestOpp.Id,
                ContactId = TestCtct.Id
        );
        insert ocr;
        Opportunity result = [SELECT Id,Contact__c from Opportunity
                    WHERE Id =: TestOpp.Id];
        system.assertEquals(null,result.Contact__c,'There should be no Primary Contact for the Opportunity yet.');
    }
}