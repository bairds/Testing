@istest
private class PLPBairdTEST {

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
        PageReference pageRef = Page.PLPBairdPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('cid', Testcampaign.Id);
        
        PLPBaird PLPC = new PLPBaird(new ApexPages.StandardController(Testcampaign));
        system.assertEquals(1,PLPC.AttendeesRSVPed.size());
        // These two fire when the AutoComplete chooses a person
        PLPC.attendee.PersonId = co.Id;
        PLPC.newContactForm = false;
        PLPC.attendee.addToList();

        //Now run page to show all AttendeesRSVPed
        //Give attendee hours
        PLPC.attendee.Hours = 4;

        PLPC.processSelected();
        system.assertEquals(1,PLPC.AttendeesAttended.size());
        system.debug('After processing list with one attendee with 4 hours, AttendeesAttended is ' + PLPC.AttendeesAttended);

        // PLPC.setCM(PLPC.AttendeesAttended[0]);
        PLPC.submitData();
        List<Opportunity> ConfirmOpps = [select id, hours_actual__c from Opportunity where campaignId =: Testcampaign.Id];
        system.assertEquals(4,ConfirmOpps[0].Hours_Actual__c,'PLP failed to create opportunity with 4 hours for existing campaign member');




        ///////////////////////////////////////////////
        Opportunity opp;
        List<Opportunity> Opps;
        Lead l = ctv.fetchTestLead();

        PLPC.attendee.PersonId = l.Id;
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

        PLPC.attendee = new PLPBaird.Attendee(PLPC);
        PLPC.attendee.PersonId = co.Id;

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

    // PLPC.submitData();
/*
         ////////////////////////////////////
        // Baird Specific Requested Tests //
       ////////////////////////////////////

       // 1) If a user changes only status, then the campaignMember record is updated, but no opportunity is created.

        PLPC.attendee = createTestAttendee(PLPC);

        System.assertEquals('Attended', PLPC.attendee.CM.Status);

        PLPC.attendee.CM.Status = 'Contributed';

        PLPC.setCM(PLPC.attendee);

        update PLPC.attendee.CM;

        Opp = PLPC.createContribution(PLPC.attendee);

        CampaignMember cmTest = [SELECT Id, Status FROM CampaignMember WHERE Id = :PLPC.attendee.CM.Id];
        // Opportunity[] opps = [SELECT Id, account.addressee__c FROM Opportunity WHERE Contact__c = :PLPC.attendee.Id AND CampaignId = :PLPC.Camp.Id];

        System.assertEquals('CONTRIBUTED', cmTest.Status.TOUPPERCASE());	// Updated Status
        System.assertEquals(0, opps.size());	// No Contribution Created

        // 2) Controller is changing the CM status from attended to "responded yes" in all cases.  Test that this isn't happening.

        PLPC.attendee = createTestAttendee(PLPC);
        PLPC.attendee.hours = 2;

        System.assertEquals('Attended', PLPC.attendee.CM.Status);

        PLPC.setCM(PLPC.attendee);

        update PLPC.attendee.CM;

        opp = PLPC.createContribution(PLPC.attendee);

        insert opp;

        cmTest = [SELECT Id, Status FROM CampaignMember WHERE Id = :PLPC.attendee.CM.Id];
        System.assertEquals('Attended', cmTest.Status);	// Status remains the same

        // 3) If a user adds only a comment, then the comment is added to campaignmember record, but no opportunity is created.

        PLPC.attendee = createTestAttendee(PLPC);

        PLPC.attendee.comments = 'Testing comments';

        System.assertEquals('Testing comments', PLPC.attendee.comments);

        PLPC.setCM(PLPC.attendee);

        update PLPC.attendee.CM;

        opp = PLPC.createContribution(PLPC.attendee);

        cmTest = [SELECT Id, Comments__c FROM CampaignMember WHERE Id = :PLPC.attendee.CM.Id];
        opps = [SELECT Id FROM Opportunity WHERE Contact__c = :PLPC.attendee.Id AND CampaignId = :PLPC.Camp.Id];

        System.assertEquals('Testing comments', cmTest.Comments__c);	// Updated Comments
        System.assertEquals(0, opps.size());	// No Contribution Created

        // 4) If a user changes hours, or adds a comment, or changes supervisor rating, then the campaignMember is added to the Attended list.

        PLPC.attendee = createTestAttendee(PLPC);
        PLPC.setCM(PLPC.attendee);
        System.assertEquals(false, PLPC.addToAttendedList(PLPC.attendee));

        PLPC.attendee = createTestAttendee(PLPC);
        PLPC.attendee.hours = 4;
        PLPC.setCM(PLPC.attendee);
        System.assertEquals(true, PLPC.addToAttendedList(PLPC.attendee));

        PLPC.attendee = createTestAttendee(PLPC);
        PLPC.attendee.comments = 'Testing comments';
        PLPC.setCM(PLPC.attendee);
        System.assertEquals(true, PLPC.addToAttendedList(PLPC.attendee));

        PLPC.attendee = createTestAttendee(PLPC);
        PLPC.attendee.Contribution.Supervisor_Satisfaction__c = '5 - Amazing!';
        PLPC.setCM(PLPC.attendee);
        System.assertEquals(true, PLPC.addToAttendedList(PLPC.attendee));
        PLPC.exitToWaterGrass();
        PLPC.returnToEditList();
 */
    // 5) Does account.addressee__c and dear__c get set?

    @istest static void test2(){
        Create_Test_Variables ctv = new Create_Test_Variables();
        Campaign c = ctv.fetchTestCampaign();
        Contact co = ctv.fetchTestContact();

        ApexPages.currentPage().getParameters().put('cid', c.Id);
        system.debug('campaign c is ' + c);

        PLPBaird PLPC = new PLPBaird(new ApexPages.StandardController(new CampaignMember()));

        List<SelectOption> stati = PLPC.getStati();
        // Create attendee
        PLPBaird.Attendee attendee = new PLPBaird.Attendee(PLPC);

        attendee.PersonId = co.Id;
        system.debug('just before error campaign c is ' + c);

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

    static private PLPBaird.Attendee createTestAttendee(PLPBaird PLPC) {
        Create_Test_Variables ctv = new Create_Test_Variables();

        Contact co = ctv.fetchTestContact();

        system.assertEquals('null TestContact', co.firstname + ' ' + co.lastname);
        PLPBaird.Attendee attendee = new PLPBaird.Attendee(PLPC);

        attendee.PersonId = co.Id;

        attendee.addToList();

        attendee.Comments = '';
        attendee.OriginalStatus = attendee.CM.Status;
        attendee.Contribution.Supervisor_Satisfaction__c = '3 - Good';

        return attendee;
    }
}