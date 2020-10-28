/**
 * Created by Baird on 9/28/2020.
 */

@IsTest
private class approveVolTaskTEST {
    @IsTest
    static void oneSubmittedTask() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        Contact TestCtct = ctv.fetchTestContact();
        Campaign TestCamp = ctv.fetchTestCampaign();
        Opportunity TestVolTask = new Opportunity(
                Name = 'autofill',
                AccountId = TestAcct.Id,
                Contact__c = TestCtct.Id,
                CampaignId = TestCamp.Id,
                StageName = 'Task Submitted',
                Hours_Actual__c = 2.0,
                CloseDate = system.now().Date(),
                RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Volunteer Task').getRecordTypeId()
        );
        insert TestVolTask;
        approveVolTasks aVT = new approveVolTasks();
        system.assertEquals(1,aVT.ListOpps.size());
        system.assertEquals('Task Approved',aVT.ListOpps[0].StageName);
        aVT.ListOpps[0].StageName = 'Task Rejected';

        aVT.submitTasks();
        List<Opportunity> ResultOpps = [SELECT Id, StageName from Opportunity];
        system.assertEquals('Task Rejected',ResultOpps[0].StageName);
    }


}