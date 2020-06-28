/**
 * Created by Baird on 6/12/2020.
 */

@IsTest
private class displayVolPortalTEST {
    @testSetup
    static void createTestData() {
        Create_Test_Variables CTV = new Create_Test_Variables();
        Contact Testcontact = CTV.fetchTestContact();

    // Add three Signup Campaigns of Type "Volunteer Interest"
    List<Campaign> SignupCamps = new List<Campaign>();
    Id SignupRTID = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Signup').getRecordTypeId();
    For (integer i = 0; i < 3; i++) {
        Campaign c = new Campaign(
                Type = 'Volunteer Interest',
                RecordTypeId = SignupRTID,
                Name = 'SignupCampaign' + i,
                IsActive = true);
        SignupCamps.add(c);
    }
    insert SignupCamps;

    // Make Testcontact a member of the first two campaigns;
    List<CampaignMember> SignupCMs = new List<CampaignMember>();
    For (integer i = 0; i < 2; i++) {
        CampaignMember cm = new CampaignMember(
                ContactId = Testcontact.Id,
                CampaignId = SignupCamps[i].Id,
                Status = 'Responded Yes');
        SignupCMs.add(cm);
    }
    insert SignupCMs;
//Create Volunteer Tasks
// First Volunteer Task has no miles driven to see if the null value errors out
List<Opportunity> ListVTs = new List<Opportunity>();
For (integer i = 0; i < 9; i++) {
    Opportunity opp = new Opportunity(
            name = 'Volunteer Task ' + i,
            campaignId = SignupCamps[0].Id,
            Hours_Actual__c = 1.00,
            STageName = 'Completed',
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Volunteer Task').getRecordTypeId(),
            Contact__c = Testcontact.Id,
            CloseDate = system.today().addDays(-i)
    );
    ListVTs.add(opp);
}
// Add one Volunteer Task two years ago
    Opportunity opp = new Opportunity(
            name = 'Volunteer Task 10',
           campaignId = SignupCamps[0].Id,
            Hours_Actual__c = 1.00,
            STageName = 'Completed',
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Volunteer Task').getRecordTypeId(),
            MIles_Driven__c = 10.00,
            Contact__c = Testcontact.Id,
            CloseDate = system.today().addDays(-730)
    );
    ListVTs.add(opp);
    insert ListVTs;
}


@IsTest
static void NineVTs() {
PageReference pageRef = Page.VolPortal;
Test.setCurrentPage(pageRef);
Contact TestContact = [SELECT id, firstname, lastname from Contact where lastname = 'TestContact' limit 1];
ApexPages.currentPage().getParameters().put('cid', TestContact.Id);
displayVolPortal dVP = new displayVolPortal();
system.assertEquals(9, dVP.VolHoursThisYear, 'displayVolPortal should have summed to 9 hours');
system.assertEquals(0, dVP.VolMilesThisYear, 'displayVolPortal should have summed to 0 miles');
system.assertEquals(10, dVP.VolHoursAll, 'displayVolPortal should have summed to 10 hours');
system.assertEquals(10, dVP.VolMilesAll, 'displayVolPortal should have summed to 10 miles');
//Test edit functions
dVP.editContactInfo();
dVP.guu.email__C = 'ChangedTestContact@dontbotherme.org';
dVP.Submit();
GuestUserUpdate__c GUUResult = [SELECT Id,RelatedContact__c,PageSource__c FROM GuestUserUpdate__c
LIMIT 1];
system.assertEquals(TestContact.Id,GUUResult.RelatedContact__c,'Submit function should have inserted RelatedContact.Id');
system.assertEquals('UpdateContactInfo',GUUResult.PageSource__c,'Submit action failed to insert correct PageSource__c field in GuestUserUpdate');

dVP.cancelEditContactInfo();
}

@IsTest
static void ThreeCampaignsTest(){
        PageReference pageRef = Page.VolPortal;
        Test.setCurrentPage(pageRef);
    Contact TestContact = [SELECT id, firstname, lastname from Contact where lastname = 'TestContact' limit 1];
    ApexPages.currentPage().getParameters().put('cid', TestContact.Id);
        displayVolPortal dVP = new displayVolPortal();
        system.assertEquals(3,dVP.VolInterestCampExs.size());
        }

}