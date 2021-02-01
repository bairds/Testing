/**
 * Created by Baird on 8/30/2020.
 */
@IsTest
private class approveVolTasksTEST {

    @TestSetup
    static void setupGUUs(){
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAccount = ctv.fetchTestAccount();
        Id UnknownCampId = WGHelpers.getUnknownCampaignId();
        List<Contact> ListCtcts = new List<Contact>();
        For (integer i=0;i<9;i++) {
            Contact Ctct = new Contact(
                    FirstName = 'Test',
                    LastName = 'Tester' + i,
                    Email = 'test' + i + '@tester.com',
                    AccountId = TestAccount.Id
            );
            ListCtcts.add(Ctct);
        }
        Insert ListCtcts;
        List<GuestUserUpdate__c> ListGUUs = new List<GuestUserUpdate__c>();
        For (integer i=0;i<9;i++){
            GuestUserUpdate__c newGUU = new GuestUserUpdate__c(
                    FirstName__c='Test',
                    LastName__c='Tester'+i,
                    Email__c='test'+i+'@tester.com',
                    Processing_Status__c='Review',
                    RelatedContact__c=ListCtcts[i].Id
            );
            ListGUUs.add(newGUU);
        }
        // One of the nine should not appear in the list
        // because it is set to rejected
        ListGUUs[8].Processing_Status__c='Rejected';
        ListGUUs[0].Email__c='ChangedTest8@tester.com';
        insert ListGUUs;
        List<Opportunity> ListOpps = new List<Opportunity>();
        For (integer i=0;i<9;i++){
            Opportunity newOpp = new Opportunity(
                    Contact__c=ListCtcts[i].Id,
                    Description='Description of work',
                    Hours_Actual__c=2,
                    StageName='Task Submitted',
                    CloseDate=system.today(),
                    AccountId = TestAccount.Id,
                    CampaignId = UnknownCampId,
                    Name = 'VolTask'+i
            );
            ListOpps.add(newOpp);
        }
        ListOpps[8].StageName='Task Rejected';
        insert ListOpps;
    }
    @IsTest
    // Processing tasks should be independent of processing GUUs;
    // The order does not matter.
    static void processAllTasks() {
        Opportunity Opp = new Opportunity();
        PageReference pageRef = Page.ApproveVolTaskPage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.StandardController(Opp);
        approveVolTasks AVT = new approveVolTasks();
        system.assertEquals(8,AVT.ListOpps.size());
        // Change one more processing status
        // Only 7 should go into the processing
        AVT.ListOpps[1].StageName = 'Task Rejected';
        // Create the stringified map as in the page js method
        Map<id,string> ResultsMap = new Map<id,string>();
        for (Opportunity o : aVT.ListOpps){
            ResultsMap.put(o.Id,o.StageName);
        }
        String resultsstring = JSON.serialize(ResultsMap);
        apexpages.currentPage().getParameters().put('firstParam',resultsstring);
        // Now run test
        AVT.submitTasks();
        system.AssertEquals(7,[SELECT Id from Opportunity where StageName = 'Task Submitted'].size(),'Should have found 7 opportunities with Task Approved stage.');
    }

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
        // Test getSelectOptions
        List<SelectOption> LSO = aVT.getApprovalOptions();
        For (SelectOption SO : LSO){
            system.assert(String.valueOf(SO.getvalue()) == 'Task Submitted'
                    || String.valueOf(SO.getvalue()) == 'Task Approved'
                    || String.valueOf(SO.getvalue()) == 'Task Rejected',
                    'Wrong Values in ApproveVolTasks.ApprovalOptions');
                    }
        // Should be one more ListOpps than previously
        system.assertEquals(9,aVT.ListOpps.size());
        system.assertEquals('Task Submitted',aVT.ListOpps[8].StageName);
        aVT.ListOpps[8].StageName = 'Task Rejected';
        // Create the stringified map as in the page js method
        Map<id,string> ResultsMap = new Map<id,string>();
        for (Opportunity o : aVT.ListOpps){
            ResultsMap.put(o.Id,o.StageName);
        }
        String resultsstring = JSON.serialize(ResultsMap);
        apexpages.currentPage().getParameters().put('firstParam',resultsstring);
        aVT.submitTasks();
        List<Opportunity> ResultOpps = [SELECT Id, StageName from Opportunity
            WHERE StageName='Task Rejected'];
        // Expect one more Opp with "Task Rejected" than was created in the TestSetup
        system.assertEquals(2,ResultOpps.size());
    }

}