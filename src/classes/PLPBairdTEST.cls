@istest
private class PLPBairdTEST {

    @testsetup static void setup() {
        createCustomSettings.createCustomSettings();
    }

    @istest static void TestContactInCampaignAlready() {

        Create_Test_Variables ctv = new Create_Test_Variables();

        // Testcontact is signed up for TestCampaign
        Campaign Testcampaign = ctv.fetchTestCampaign();
        Contact co = ctv.fetchTestContact();
        CampaignMember cm = ctv.fetchTestCM();
        cm.Status = 'Responded Yes';
        update cm;
        PageReference pageRef = Page.PLPBairdPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('cid', Testcampaign.Id);

        PLPBaird PLPC = new PLPBaird(new ApexPages.StandardController(Testcampaign));
        system.assertEquals(1, PLPC.UnprocessedAttendees.size());
        PLPC.getStati();

        // These two fire when the AutoComplete chooses a person
        PLPC.newContactForm = false;


        //        //Give attendee hours
        PLPC.UnprocessedAttendees[0].Hours = 4;

        PLPC.processSelected();
        system.assertEquals(1, PLPC.UpdateAttendees.size());
        system.debug('After processing list with one attendee with 4 hours, AttendeesAttended is ' + PLPC.UpdateAttendees);

        // PLPC.setCM(PLPC.AttendeesAttended[0]);
        PLPC.submitData();
        List<Opportunity> ConfirmOpps = [select id, hours_actual__c from Opportunity where campaignId = :Testcampaign.Id];
        system.assertEquals(4, ConfirmOpps[0].Hours_Actual__c, 'PLP failed to create opportunity with 4 hours for existing campaign member');

        PLPC.exitToWaterGrass();
    }

    @istest static void NewAttendeeAddedToList() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Campaign Testcampaign = ctv.fetchTestCampaign();
        Contact TestCtct = ctv.fetchTestContact();
        CampaignMember TestCM = new CampaignMember(
                campaignId = Testcampaign.Id,
                contactId = Testctct.Id,
                status = 'Responded Yes'
        );
        Insert TestCM;
        PageReference pageRef = Page.PLPBairdPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('cid', Testcampaign.Id);

        PLPBaird PLPC = new PLPBaird(new ApexPages.StandardController(Testcampaign));

        PLPC.addNewContact();
        PLPC.NewContact.firstname = 'LeadFirstName';
        PLPC.NewContact.lastname = 'LeadLastName';
        PLPC.NewContact.email = 'newlead@dontbotherme.org';
        PLPC.NewContact.MailingPostalCode = '22222';
        system.debug('Just before savePerson(), NewContact is ' + PLPC.NewContact);
        system.debug('At this point there should be one contact.  There are: ' + [SELECT ID FROM CONTACT].SIZE());
        PLPC.savePerson();

        system.assertEquals(2, PLPC.UnprocessedAttendees.size());
        system.assertEquals(2, PLPC.UnprocessedAttWrapped.size());

        PLPC.UnprocessedAttendees[0].Hours = 4;

        //PLPC.addToList(PLPC.NewContact.Id);
//        SYSTEM.debug(ApexPages.getMessages());
//        System.assert(STRING.VALUEOF(Apexpages.getMessages()).CONTAINS('Campaign Member is already in this list.'));

        // ADD HOURS, STATUS
        PLPC.allStatus = 'Attended';
        PLPC.allHours = 5;

        PLPC.setAllStatus();
        PLPC.setAllHours();

        // GO TO REVIEW PAGE
        PLPC.processSelected();
        system.assertEquals(2, PLPC.UpdateAttendees.size());

        //AFTER REVIEW SUBMIT DATA
        PLPC.submitData();
        List<Opportunity> ConfirmOpps = [select id, hours_actual__c from Opportunity where campaignId = :Testcampaign.Id];
        system.assertEquals(5, ConfirmOpps[0].Hours_Actual__c, 'PLP failed to create opportunity with 5 hours for existing lead in campaign.');
        PLPC.returnToEditList();
    }

    @istest static void AddExistingContactToCampaign() {

        Create_Test_Variables ctv = new Create_Test_Variables();

        // Testcontact is signed up for TestCampaign
        Campaign Testcampaign = ctv.fetchTestCampaign();
        Contact co = ctv.fetchTestContact();

        PageReference pageRef = Page.PLPBairdPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('cid', Testcampaign.Id);

        PLPBaird PLPC = new PLPBaird(new ApexPages.StandardController(Testcampaign));
        system.assertEquals(0, PLPC.UnprocessedAttendees.size());
        // These two fire when the AutoComplete chooses a person
        PLPC.newContactForm = false;
        PLPC.addToList(co.Id);
        system.assertEquals(1, PLPC.UnprocessedAttendees.size());
        system.assertEquals(1, PLPC.UnprocessedAttWrapped.size());
    }


    @istest static void AddExistingCMToCampaign() {

        Create_Test_Variables ctv = new Create_Test_Variables();

        // Testcontact is signed up for TestCampaign
        Campaign Testcampaign = ctv.fetchTestCampaign();
        Contact co = ctv.fetchTestContact();
        CampaignMember TestCM = new CampaignMember(
                ContactId = co.Id,
                CampaignId = Testcampaign.Id,
                Status = 'Responded Yes'
        );
        insert TestCM;

        PageReference pageRef = Page.PLPBairdPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('cid', Testcampaign.Id);

        PLPBaird PLPC = new PLPBaird(new ApexPages.StandardController(Testcampaign));
        system.assertEquals(1, PLPC.UnprocessedAttendees.size());
        // These two fire when the AutoComplete chooses a person
        PLPC.newContactForm = false;
        PLPC.addToList(co.Id);
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        system.assertEquals('ApexPages.Message["Campaign Member is already in this list."]', STRING.ValueOf(msgs[0]), 'PLP should have said campaign member already in campaign');
    }


    @istest static void MissingCampaignId() {

        Create_Test_Variables ctv = new Create_Test_Variables();

        // Testcontact is signed up for TestCampaign
        Campaign Testcampaign = ctv.fetchTestCampaign();
        Contact co = ctv.fetchTestContact();
        CampaignMember cm = ctv.fetchTestCM();
        cm.Status = 'Responded Yes';
        update cm;
        PageReference pageRef = Page.PLPBairdPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('cid', null);

        PLPBaird PLPC = new PLPBaird(new ApexPages.StandardController(Testcampaign));
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        system.assertEquals('ApexPages.Message["Error: Not sure which Campaign to use.  Did you start from the campaign detail page?  Please send a copy of this message to support@watergrass.org."]', STRING.ValueOf(msgs[0]), 'PLP should have said no campaign Id.  Has the error message string changed?');
    }

    @istest static void BadCampaignId() {

        Create_Test_Variables ctv = new Create_Test_Variables();

        // Testcontact is signed up for TestCampaign
        Campaign Testcampaign = ctv.fetchTestCampaign();
        Contact co = ctv.fetchTestContact();
        CampaignMember cm = ctv.fetchTestCM();
        cm.Status = 'Responded Yes';
        update cm;
        PageReference pageRef = Page.PLPBairdPage;
        Test.setCurrentPage(pageRef);
        string idstring = string.valueOf(Testcampaign.Id);
        ApexPages.currentPage().getParameters().put('cid', idstring.left(idstring.length()-1)+'6');

        PLPBaird PLPC = new PLPBaird(new ApexPages.StandardController(Testcampaign));
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        system.assertEquals('ApexPages.Message["That Campaign Id is not correct.  Please send a copy of this message to support@watergrass.org."]', STRING.ValueOf(msgs[0]), 'PLP should have said bad campaign Id.  Has the error message string changed?');
    }


    @istest static void DeleteExistingCMFromCampaign() {

        Create_Test_Variables ctv = new Create_Test_Variables();

        // Testcontact is signed up for TestCampaign
        Campaign Testcampaign = ctv.fetchTestCampaign();
        Account Testacct = ctv.fetchTestAccount();
        List<CampaignMember> ListCMs = new List<CampaignMember>();
        List<Contact> ListCtcts = new List<Contact>();
        for (integer i=0;i<10;i++) {
            Contact co = new Contact(
                    accountId = Testacct.Id,
                    lastname = 'Testcontact' + i
            );
            ListCtcts.add(co);
        }
        insert ListCtcts;
        For (Contact c : ListCtcts){
            CampaignMember TestCM = new CampaignMember(
                    ContactId = c.Id,
                    CampaignId = Testcampaign.Id,
                    Status = 'Responded Yes'
            );
            ListCMs.add(TestCM);
        }
        insert ListCMs;

        PageReference pageRef = Page.PLPBairdPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('cid', Testcampaign.Id);

        system.debug('TestCampaign is ' + TestCampaign);
        PLPBaird PLPC = new PLPBaird(new ApexPages.StandardController(Testcampaign));
        system.assertEquals(10, PLPC.UnprocessedAttendees.size());
        CampaignMember DeleteCM = [select id, contact.lastname from CampaignMember where contact.lastname = 'Testcontact4' LIMIT 1];
        // This should be index 5 in the AttendeeWrapper
        PLPC.CMToDelete.Id = DeleteCM.Id;
        PLPC.AttendeeToDeleteIndex = 5;
        PLPC.deleteCM();

        system.assertEquals(9,PLPC.UnProcessedAttendees.size());
        Boolean CorrectCMDeleted = true;
        For (PLPBaird.Attendee a : PLPC.UnProcessedAttendees){
            if (a.cm.name.CONTAINS('TestContact4')) CorrectCMDeleted = false;
        }
        System.assertEquals(true,CorrectCMDeleted,'DeleteCM() deleted an attendee but not the right one.');

    }

}