@istest
private class ParticipantListProcessingTest {

    @testsetup static void setup(){
        createCustomSettings.createCustomSettings();
    }

    static testMethod void test() {
/*
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
        
        processParticipantList PLPC = new processParticipantList(new ApexPages.StandardController(cm));
        system.assertEquals(1,PLPC.UnprocessedCMs.size());
        // These two fire when the AutoComplete chooses a person
        PLPC.attendee.Id = co.Id;
        PLPC.attendee.preAddToList(); 
        PLPC.attendee.addToList();

        //Now run page to show all AttendeesRSVPed
        //Give attendee hours
        PLPC.attendee.Hours = 4;

        PLPC.processSelected();
        system.assertEquals(1,PLPC.UnprocessedAttendees.size());
        system.debug('After processing list with one attendee with 4 hours, AttendeesAttended is ' + PLPC.UnprocessedAttendees);

        // PLPC.setCM(PLPC.AttendeesAttended[0]);
        PLPC.submitData();
        List<Opportunity> ConfirmOpps = [select id, hours_actual__c from Opportunity where campaignId =: Testcampaign.Id];
        system.assertEquals(4,ConfirmOpps[0].Hours_Actual__c,'PLP failed to create opportunity with 4 hours for existing campaign member');




        ///////////////////////////////////////////////
        Opportunity opp;
        List<Opportunity> Opps;
        Lead l = ctv.fetchTestLead();

        PLPC.attendee.Id = l.Id;
        PLPC.attendee.Hours = 4;

        PLPC.attendee.addToList();

        PLPC.all.cm.Status = 'Attended';
        PLPC.all.Hours = 5;

        PLPC.setAllStatus();
        PLPC.setAllHours();

        PLPC.all.Hours = 0;
        PLPC.setAllHours();

        PLPC.createContribution(PLPC.attendee);

        ///////////////////////////////////////////////

        PLPC.attendee = new processParticipantList.Attendee(PLPC);
        PLPC.attendee.Id = co.Id;

        PLPC.attendee.addToList();
        PLPC.attendee.addToList();

        //////////////////////////////////////////////////////////////

        PLPC.account.addNewContact();

        //Normally a user would have to insert a recordType in order to use the EnterAccountContact page
        //But we reprogrammed the controller to guard against recordTypeId == null

        PLPC.account.newContact.firstName = 'TestFN';
        PLPC.account.newContact.lastName = 'TestLN';

        PLPC.account.SaveContact();

        /////////////////////////////////////////////////////////////////////////

        PLPC.processSelected();

        List<SelectOption> stati = PLPC.getStati();

    }

    @istest static void test2(){
        Create_Test_Variables ctv = new Create_Test_Variables();
        Campaign c = ctv.fetchTestCampaign();
        Contact co = ctv.fetchTestContact();

        ApexPages.currentPage().getParameters().put('cid', c.Id);

        processParticipantList PLPC = new processParticipantList(new ApexPages.StandardController(new CampaignMember()));

        List<SelectOption> stati = PLPC.getStati();
        // Create attendee
        processParticipantList.Attendee attendee = new processParticipantList.Attendee(PLPC);

        attendee.Id = co.Id;

        attendee.addToList();

        attendee.Comments = '';
        attendee.OriginalStatus = attendee.CM.Status;
        attendee.Contribution.Supervisor_Satisfaction__c = '3 - Good';
        //PLPC.attendee = createTestAttendee(PLPC);
        PLPC.attendee.hours = 4;
        PLPC.processSelected();

        PLPC.setCM(PLPC.attendee);
        System.assertEquals(true, PLPC.addToAttendedList(PLPC.attendee));

        update PLPC.attendee.CM;

        Opportunity opp = PLPC.createContribution(PLPC.attendee);
        PLPC.submitData();

        List<Opportunity> Opps = [SELECT Id, account.addressee__c, account.name, account.dear__c FROM Opportunity WHERE CampaignId = :PLPC.Camp.Id];

        System.assertEquals(1, opps.size(), 'Either none or more than one opportunity came through.  Should be 1.');
        System.assertEquals('null TestContact', Opps[0].account.addressee__c,'No addressee for '+ Opps[0].account.name);
        System.assertEquals(null, Opps[0].account.dear__c,'No dear for '+ Opps[0].account.name);
    }

    static private processParticipantList.Attendee createTestAttendee(processParticipantList PLPC) {
        Create_Test_Variables ctv = new Create_Test_Variables();

        Contact co = ctv.fetchTestContact();

        system.assertEquals('null TestContact', co.firstname + ' ' + co.lastname);
        processParticipantList.Attendee attendee = new processParticipantList.Attendee(PLPC);

        attendee.Id = co.Id;

        attendee.addToList();

        attendee.Comments = '';
        attendee.OriginalStatus = attendee.CM.Status;
        attendee.Contribution.Supervisor_Satisfaction__c = '3 - Good';

        return attendee;
        
 */
    }
}