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
        AVT.submitTasks();
        system.AssertEquals(7,[SELECT Id from Opportunity where StageName = 'Task Approved'].size(),'Should have found 7 opportunities with Task Approved stage.');
    }
}