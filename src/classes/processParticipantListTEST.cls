/**
 * Created by Baird on 4/19/2019.
 */

@IsTest
private class processParticipantListTEST {

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
        PageReference pageRef = Page.ProcessParticipantListPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('cid', Testcampaign.Id);

        ProcessParticipantList PLPC = new ProcessParticipantList(new ApexPages.StandardController(Testcampaign));
        system.assertEquals(1, PLPC.UnprocessedAttendees.size());
        PLPC.getStati();
        PLPC.getRoles();

// These two fire when the AutoComplete chooses a person
        PLPC.newContactForm = false;


//        //Give attendee hours
        PLPC.UnprocessedAttendees[0].Hours = 4;
        PLPC.UnprocessedAttendees[0].Contribution.Supervisor_Satisfaction__c = '4';
        PLPC.UnprocessedAttendees[0].Contribution.Location_of_Task__c = 'Location 1';

        PLPC.processSelected();
        system.assertEquals(1, PLPC.UpdateAttendees.size());
        system.debug('After processing list with one attendee with 4 hours, AttendeesAttended is ' + PLPC.UpdateAttendees);

// PLPC.setCM(PLPC.AttendeesAttended[0]);
        PLPC.submitData();
        List<Opportunity> ConfirmOpps = [select id, hours_actual__c, Location_of_Task__c, Supervisor_Satisfaction__c from Opportunity where campaignId = :Testcampaign.Id];
        system.assertEquals(4, ConfirmOpps[0].Hours_Actual__c, 'PLP failed to create opportunity with 4 hours for existing campaign member');
        // Test whether fieldset values are saved only if the fields are included in the field set;
        // Because cannot create fieldsets or add fields to them in apex
        Map<string, Schema.FieldSetMember> MSFSM = new Map<string, Schema.FieldSetMember>();
        List<Schema.FieldSetMember> pPLFieldSetMembers = SObjectType.Opportunity.fieldSets.ParticipantListFieldset.getFields();
        system.debug('pPLFieldSetMembers ' + pPLFieldSetMembers);
        for (Schema.FieldSetMember ppf : pPLFieldSetMembers) {
            MSFSM.put(ppf.getFieldPath(), ppf);
        }
        if (MSFSM.containsKey('Supervisor_Satisfaction__c')) system.assertEquals('4', ConfirmOpps[0].Supervisor_Satisfaction__c, 'PLP failed to transfer Supervisor Satisfaction from Page to Opp');
        if (MSFSM.containsKey('Location_of_Task__c')) system.assertEquals('Location 1', ConfirmOpps[0].Location_of_Task__c, 'PLP failed to transfer Location of Task from Page to Opp');

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
        PageReference pageRef = Page.ProcessParticipantListPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('cid', Testcampaign.Id);

        ProcessParticipantList PLPC = new ProcessParticipantList(new ApexPages.StandardController(Testcampaign));

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
        PLPC.allRoles = 'Volunteer';

        PLPC.setAllStatus();
        PLPC.setAllHours();
        PLPC.setAllRoles();

// GO TO REVIEW PAGE
        PLPC.processSelected();
        system.assertEquals(2, PLPC.UpdateAttendees.size());

//AFTER REVIEW SUBMIT DATA
        PLPC.submitData();
        List<Opportunity> ConfirmOpps = [select id, hours_actual__c from Opportunity where campaignId = :Testcampaign.Id];
        system.assertEquals(5, ConfirmOpps[0].Hours_Actual__c, 'PLP failed to create opportunity with 5 hours for existing lead in campaign.');
        List<CampaignMember> ConfirmCMs = [select id, role__c from CampaignMember where campaignId = :Testcampaign.Id];
        system.assertEquals('Volunteer', ConfirmCMs[0].Role__c, 'PLP failed to create campaign member with role Volunteer for existing lead in campaign.');
        PLPC.returnToEditList();
    }

    @istest static void AddExistingContactToCampaign() {

        Create_Test_Variables ctv = new Create_Test_Variables();

// Testcontact is signed up for TestCampaign
        Campaign Testcampaign = ctv.fetchTestCampaign();
        Contact co = ctv.fetchTestContact();

        string DefaultLeadershipTest;
        Schema.DescribeFieldResult F = Opportunity.Leadership_Level__c.getDescribe();
        List<Schema.PicklistEntry> pickVals = f.getPicklistValues();
        For (Schema.PicklistEntry pv : pickVals) {
            if (pv.isDefaultValue()) DefaultLeadershipTest = pv.getValue();
        }
        system.debug('DefaultLeadership is ' + DefaultLeadershipTest);

        PageReference pageRef = Page.ProcessParticipantListPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('cid', Testcampaign.Id);

        ProcessParticipantList PLPC = new ProcessParticipantList(new ApexPages.StandardController(Testcampaign));
        system.assertEquals(0, PLPC.UnprocessedAttendees.size());
// These two fire when the AutoComplete chooses a person
        PLPC.newContactForm = false;
        PLPC.addToList(co.Id);
        system.assertEquals(1, PLPC.UnprocessedAttendees.size());
        system.assertEquals(1, PLPC.UnprocessedAttWrapped.size());
        system.assertEquals(DefaultLeadershipTest, PLPC.UNprocessedAttendees[0].Contribution.Leadership_Level__c);
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

        PageReference pageRef = Page.ProcessParticipantListPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('cid', Testcampaign.Id);

        ProcessParticipantList PLPC = new ProcessParticipantList(new ApexPages.StandardController(Testcampaign));
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
        PageReference pageRef = Page.ProcessParticipantListPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('cid', null);

        ProcessParticipantList PLPC = new ProcessParticipantList(new ApexPages.StandardController(Testcampaign));
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
        PageReference pageRef = Page.ProcessParticipantListPage;
        Test.setCurrentPage(pageRef);
        string idstring = string.valueOf(Testcampaign.Id);
        ApexPages.currentPage().getParameters().put('cid', idstring.left(idstring.length() - 1) + '6');

        ProcessParticipantList PLPC = new ProcessParticipantList(new ApexPages.StandardController(Testcampaign));
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
        for (integer i = 0; i < 10; i++) {
            Contact co = new Contact(
                    accountId = Testacct.Id,
                    lastname = 'Testcontact' + i
            );
            ListCtcts.add(co);
        }
        insert ListCtcts;
        For (Contact c : ListCtcts) {
            CampaignMember TestCM = new CampaignMember(
                    ContactId = c.Id,
                    CampaignId = Testcampaign.Id,
                    Status = 'Responded Yes'
            );
            ListCMs.add(TestCM);
        }
        insert ListCMs;

        PageReference pageRef = Page.ProcessParticipantListPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('cid', Testcampaign.Id);

        system.debug('TestCampaign is ' + TestCampaign);
        ProcessParticipantList PLPC = new ProcessParticipantList(new ApexPages.StandardController(Testcampaign));
        system.assertEquals(10, PLPC.UnprocessedAttendees.size());
        CampaignMember DeleteCM = [select id, contact.lastname from CampaignMember where contact.lastname = 'Testcontact4' LIMIT 1];
// This should be index 5 in the AttendeeWrapper
        PLPC.CMToDelete.Id = DeleteCM.Id;
        PLPC.AttendeeToDeleteIndex = 5;
        PLPC.deleteCM();

        system.assertEquals(9, PLPC.UnProcessedAttendees.size());
        Boolean CorrectCMDeleted = true;
        For (ProcessParticipantList.Attendee a : PLPC.UnProcessedAttendees) {
            if (a.cm.name.CONTAINS('TestContact4')) CorrectCMDeleted = false;
        }
        System.assertEquals(true, CorrectCMDeleted, 'DeleteCM() deleted an attendee but not the right one.');

    }

}