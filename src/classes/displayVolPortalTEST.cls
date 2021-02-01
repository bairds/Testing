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
    dVP.GUU.email__C = 'ChangedTestContact@dontbotherme.org';
    dVP.GUU.MailingStreet__c = 'Changed Street 111';
    dVP.GUU.MailingCity__c = 'Annapolis';
    dVP.GUU.MailingState__c = 'MD';
    dVP.GUU.MailingPostalCode__c = 'Changed Street 111';
dVP.submitContactInfo();
GuestUserUpdate__c GUUResult = [SELECT Id,RelatedContact__c,PageSource__c FROM GuestUserUpdate__c
LIMIT 1];
system.assertEquals(TestContact.Id,GUUResult.RelatedContact__c,'Submit function should have inserted RelatedContact.Id');
system.assertEquals('UpdateContactInfo',GUUResult.PageSource__c,'Submit action failed to insert correct PageSource__c field in GuestUserUpdate');

dVP.cancelEditContactInfo();
}

@IsTest
static void ThreeCampaignsTest(){
    Contact TestContact = [SELECT id, firstname, lastname from Contact where lastname = 'TestContact' limit 1];
        PageReference pageRef = Page.VolPortal;
        Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('cid', TestContact.Id);
        displayVolPortal dVP = new displayVolPortal();
        system.assertEquals(3,dVP.VolInterestCampExs.size());

    // Contact is signed up for Campaigns 1 &2;
    // Unsubscribe contact from Campaign 1, create new Subscription to Campaign 3
    dVP.VolInterestCampExs[0].FinalStatus = 'Unsubscribed';
    dVP.VolInterestCampExs[2].FinalStatus = 'Registered';
    string testString = JSON.serialize(dVP.CampToExtendedCampMap);
    apexpages.currentPage().getParameters().put('firstParam',testString);
    system.debug('String sent to page is ' + testString);
    dVP.setCMStatus();
    List<CampaignMember> ResultCMs = [SELECT Id, CampaignId, Campaign.Name,Status, Unsubscribed__c from CampaignMember WHERE
    contactId =: TestContact.Id];
    For (CampaignMember cm : ResultCMs){
        if (cm.Campaign.Name=='SignupCampaign0') {
            system.assertEquals(true, cm.Unsubscribed__c, 'Campaign Member was registered, should have unsubscribed.');
            system.assertEquals('Unsubscribed',cm.Status, 'Campaign Member was unregistered, Status should be Unsubscribed.');
        }
        if (cm.Campaign.Name=='SignupCampaign2'){
            system.assertEquals('Responded Yes',cm.Status,'Contact was not initially registered, but should have registered.');
            system.assertEquals(false,cm.Unsubscribed__c, 'Contact was registered and status should have been Subscribed.');
        }
    }
    // Resubscribe contact to Campaign 1, Unsubscribe them from Campaign 3
    dVP.CampToExtendedCampMap.get(dVP.VolInterestCampExs[0].camp.Id).FinalStatus = 'Registered';
    dVP.CampToExtendedCampMap.get(dVP.VolInterestCampExs[2].camp.Id).FinalStatus = 'Unsubscribed';
    system.assert(dVP.CampToExtendedCampMap.get(dvP.VolInterestCampExs[0].camp.Id).FinalStatus!=null);
    testString = JSON.serialize(dVP.CampToExtendedCampMap);
    apexpages.currentPage().getParameters().put('firstParam',testString);
    system.debug('String sent to page is ' + testString);
    dVP.setCMStatus();
    ResultCMs = [SELECT Id, CampaignId, Campaign.Name,Status, Unsubscribed__c from CampaignMember WHERE
            contactId =: TestContact.Id];
    For (CampaignMember cm : ResultCMs) {
        if (cm.Campaign.Name == 'SignupCampaign0') {
           system.assertEquals(false, cm.Unsubscribed__c, 'Campaign Member was registered, should have unsubscribed.');
           system.assertEquals('Responded Yes', cm.Status, 'Campaign Member was unregistered, Status should be Unsubscribed.');
        }
        if (cm.Campaign.Name == 'SignupCampaign2') {
            system.assertEquals('Unsubscribed', cm.Status, 'Contact was initially registered, but should have unsubscribed.');
            system.assertEquals(true, cm.Unsubscribed__c, 'Contact was initially registered and status should have been changed to unsubscribed.');
        }
    }
}

    @IsTest
    static void InsertVolunteerTask(){
        PageReference pageRef = Page.VolPortal;
        Test.setCurrentPage(pageRef);
        Contact TestContact = [SELECT id, firstname, lastname from Contact where lastname = 'TestContact' limit 1];
        ApexPages.currentPage().getParameters().put('cid', TestContact.Id);
        displayVolPortal dVP = new displayVolPortal();

        //Submit new Volunteer Task before submitting any other changes
        Campaign TestCampaign = [select Id, Name from campaign where Name = 'TestCampaign'];
        dVP.Opp.CampaignId=TestCampaign.Id;
        dVP.Opp.Hours_Actual__c = 3;
        dvP.Opp.Description = 'Helped Gregg monitor Dark Branch.';
        dVP.Opp.Date_and_Time_Start__c = Datetime.newInstance(2020,2,22,3,0,0);
        dVP.Opp.Date_and_Time_End__c = Datetime.newInstance(2020,2,22,5,0,0);
        dVP.SubmitVolTask();
        List<Opportunity> ResultsList = dVP.SubmittedTasks;

        System.assertEquals(true,dVP.HasSubmittedTasks,'Should have set HasSubmittedTasks flag to true so that Submitted Task List will show.');
        system.debug('In test, list of Submitted TAsks is now ' + ResultsList);
        System.assertEquals(1,ResultsList.size(),'Should have found one submitted task.');
        // Has the Opportunity record been cleared for the next Volunteer Task?
        System.assertEquals(null,dVP.Opp.Id,'Opportunity record Opp should have been cleared for next entry.');
    }

}