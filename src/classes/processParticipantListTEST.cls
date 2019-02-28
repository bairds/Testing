/**
 * Created by Baird on 9/14/2018.
 */


    @istest
            private class processParticipantListTEST {

    @testsetup static void setup(){
    createCustomSettings.createCustomSettings();
}

static testMethod void test() {

Create_Test_Variables ctv = new Create_Test_Variables();

// Testcontact is signed up for TestCampaign
Campaign Testcampaign = ctv.fetchTestCampaign();
Contact co = ctv.fetchTestContact();
CampaignMember cm = ctv.fetchTestCM();
cm.Status='Responded Yes';
update cm;
PageReference pageRef = Page.processParticipantListPage;
Test.setCurrentPage(pageRef);
ApexPages.currentPage().getParameters().put('cid', Testcampaign.Id);

processParticipantList PPL = new processParticipantList(new ApexPages.StandardController(cm));
system.assertEquals(1,PPL.UnprocessedCMs.size());
// These two fire when the AutoComplete chooses a person
PPL.attendee.Id = co.Id;
PPL.attendee.preAddToList();
PPL.attendee.addToList();

//Now run page to show all AttendeesRSVPed

//Give this attendee hours
PPL.attendee.Hours = 4.00;
    PPL.setCM(PPL.attendee);
    system.debug('After inserting 4 hours for attendee, AttendeesRSVPed is now ' + PPL.UnprocessedCMs);

PPL.processSelected();
    System.assertEquals(true, PPL.addToAttendedList(PPL.attendee));
system.assertEquals(1,PPL.UnprocessedAttendees.size());
system.debug('After processing list with one attendee with 4 hours, AttendeesAttended is ' + PPL.UnprocessedAttendees);

// PPL.setCM(PPL.AttendeesAttended[0]);
PPL.submitData();
List<Opportunity> ConfirmOpps = [select id, hours_actual__c from Opportunity where campaignId =: Testcampaign.Id];
system.assertEquals(4,ConfirmOpps[0].Hours_Actual__c,'PLP failed to create opportunity with 4 hours for existing campaign member');




///////////////////////////////////////////////
Opportunity opp;
List<Opportunity> Opps;
Lead l = ctv.fetchTestLead();

PPL.attendee.Id = l.Id;
PPL.attendee.Hours = 4;

PPL.attendee.addToList();

PPL.all.cm.Status = 'Attended';
PPL.all.Hours = 5;

PPL.setAllStatus();
PPL.setAllHours();

PPL.all.Hours = 0;
PPL.setAllHours();

PPL.createContribution(PPL.attendee);

///////////////////////////////////////////////

PPL.attendee = new processParticipantList.Attendee(PPL);
PPL.attendee.Id = co.Id;

PPL.attendee.addToList();
PPL.attendee.addToList();

//////////////////////////////////////////////////////////////

PPL.account.addNewContact();

//Normally a user would have to insert a recordType in order to use the EnterAccountContact page
//But we reprogrammed the controller to guard against recordTypeId == null

PPL.account.newContact.firstName = 'TestFN';
PPL.account.newContact.lastName = 'TestLN';

PPL.account.SaveContact();

/////////////////////////////////////////////////////////////////////////

PPL.processSelected();

List<SelectOption> stati = PPL.getStati();

}

// PPL.submitData();
/*
         ////////////////////////////////////
        // Baird Specific Requested Tests //
       ////////////////////////////////////

       // 1) If a user changes only status, then the campaignMember record is updated, but no opportunity is created.

        PPL.attendee = createTestAttendee(PPL);

        System.assertEquals('Attended', PPL.attendee.CM.Status);

        PPL.attendee.CM.Status = 'Contributed';

        PPL.setCM(PPL.attendee);

        update PPL.attendee.CM;

        Opp = PPL.createContribution(PPL.attendee);

        CampaignMember cmTest = [SELECT Id, Status FROM CampaignMember WHERE Id = :PPL.attendee.CM.Id];
        // Opportunity[] opps = [SELECT Id, account.addressee__c FROM Opportunity WHERE Contact__c = :PPL.attendee.Id AND CampaignId = :PPL.Camp.Id];

        System.assertEquals('CONTRIBUTED', cmTest.Status.TOUPPERCASE());	// Updated Status
        System.assertEquals(0, opps.size());	// No Contribution Created

        // 2) Controller is changing the CM status from attended to "responded yes" in all cases.  Test that this isn't happening.

        PPL.attendee = createTestAttendee(PPL);
        PPL.attendee.hours = 2;

        System.assertEquals('Attended', PPL.attendee.CM.Status);

        PPL.setCM(PPL.attendee);

        update PPL.attendee.CM;

        opp = PPL.createContribution(PPL.attendee);

        insert opp;

        cmTest = [SELECT Id, Status FROM CampaignMember WHERE Id = :PPL.attendee.CM.Id];
        System.assertEquals('Attended', cmTest.Status);	// Status remains the same

        // 3) If a user adds only a comment, then the comment is added to campaignmember record, but no opportunity is created.

        PPL.attendee = createTestAttendee(PPL);

        PPL.attendee.comments = 'Testing comments';

        System.assertEquals('Testing comments', PPL.attendee.comments);

        PPL.setCM(PPL.attendee);

        update PPL.attendee.CM;

        opp = PPL.createContribution(PPL.attendee);

        cmTest = [SELECT Id, Comments__c FROM CampaignMember WHERE Id = :PPL.attendee.CM.Id];
        opps = [SELECT Id FROM Opportunity WHERE Contact__c = :PPL.attendee.Id AND CampaignId = :PPL.Camp.Id];

        System.assertEquals('Testing comments', cmTest.Comments__c);	// Updated Comments
        System.assertEquals(0, opps.size());	// No Contribution Created

        // 4) If a user changes hours, or adds a comment, or changes supervisor rating, then the campaignMember is added to the Attended list.

        PPL.attendee = createTestAttendee(PPL);
        PPL.setCM(PPL.attendee);
        System.assertEquals(false, PPL.addToAttendedList(PPL.attendee));

        PPL.attendee = createTestAttendee(PPL);
        PPL.attendee.hours = 4;
        PPL.setCM(PPL.attendee);
        System.assertEquals(true, PPL.addToAttendedList(PPL.attendee));

        PPL.attendee = createTestAttendee(PPL);
        PPL.attendee.comments = 'Testing comments';
        PPL.setCM(PPL.attendee);
        System.assertEquals(true, PPL.addToAttendedList(PPL.attendee));

        PPL.attendee = createTestAttendee(PPL);
        PPL.attendee.Contribution.Supervisor_Satisfaction__c = '5 - Amazing!';
        PPL.setCM(PPL.attendee);
        System.assertEquals(true, PPL.addToAttendedList(PPL.attendee));
        PPL.exitToWaterGrass();
        PPL.returnToEditList();
 */
// 5) Does account.addressee__c and dear__c get set?

@istest static void test2(){
Create_Test_Variables ctv = new Create_Test_Variables();
Campaign c = ctv.fetchTestCampaign();
Contact co = ctv.fetchTestContact();
    CampaignMember cm = ctv.fetchTestCM();

ApexPages.currentPage().getParameters().put('cid', c.Id);

processParticipantList PPL = new processParticipantList(new ApexPages.StandardController(cm));

List<SelectOption> stati = PPL.getStati();
// Create attendee
processParticipantList.Attendee attendee = new processParticipantList.Attendee(PPL);

attendee.Id = co.Id;

attendee.addToList();

attendee.Comments = '';
attendee.OriginalStatus = attendee.CM.Status;
attendee.Contribution.Supervisor_Satisfaction__c = '3 - Good';
// PPL.attendee = createTestAttendee(PPL);
PPL.attendee.hours = 4;
PPL.processSelected();

PPL.setCM(PPL.attendee);
    system.debug('After setCM attendee is ' + PPL.attendee);
System.assertEquals(true, PPL.addToAttendedList(PPL.attendee));
    system.debug('After inserting 4 hours for attendee, AttendeesRSVPed is now ' + PPL.UnprocessedCMs);
    system.debug('After processing list with one attendee with 4 hours, AttendeesAttended is ' + PPL.UnprocessedAttendees);

update PPL.attendee.CM;

Opportunity opp = PPL.createContribution(PPL.attendee);
PPL.submitData();

List<Opportunity> Opps = [SELECT Id, account.addressee__c, account.name, account.dear__c FROM Opportunity WHERE CampaignId = :PPL.Camp.Id];

System.assertEquals(1, opps.size(), 'Either none or more than one opportunity came through.  Should be 1.');
System.assertEquals('null TestContact', Opps[0].account.addressee__c,'No addressee for '+ Opps[0].account.name);
System.assertEquals(null, Opps[0].account.dear__c,'No dear for '+ Opps[0].account.name);

}

static private processParticipantList.Attendee createTestAttendee(processParticipantList PPL) {
Create_Test_Variables ctv = new Create_Test_Variables();

Contact co = ctv.fetchTestContact();

system.assertEquals('null TestContact', co.firstname + ' ' + co.lastname);
processParticipantList.Attendee attendee = new processParticipantList.Attendee(PPL);

attendee.Id = co.Id;

attendee.addToList();

attendee.Comments = '';
attendee.OriginalStatus = attendee.CM.Status;
attendee.Contribution.Supervisor_Satisfaction__c = '3 - Good';

return attendee;
}
}