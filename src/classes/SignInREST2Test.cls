/**
 * Created by Baird on 9/20/2018.
 */
@isTest
private class SignInREST2Test {

    @testsetup static void SetupTest(){
        User thisUser = [ select Id, Phone, Email from User where Id = :UserInfo.getUserId() ];
        System.debug ('thisUser is ' + thisUser);
        thisUser.Phone = '333-3333';
        System.runAs ( thisUser ) {

            populateWGCustomSettings.populateAllSettings();
        }
        CreateCustomSettings.createCustomSettings();
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        System.assertEquals('TestAccount', TestAcct.Name);
        Contact TestCtct = ctv.fetchTestContact();
        System.assertEquals('TestContact', TestCtct.LastName);
        Campaign TestCamp = ctv.fetchTestCampaign();
        System.assertEquals('Testcampaign', TestCamp.Name);
        CampaignMember cm = new CampaignMember(
                CampaignId=TestCamp.Id,
                ContactId=TestCtct.Id);
        insert cm;
        List<Opportunity> ListOpps = new List<Opportunity>();
        Schema.DescribeSObjectResult d = Schema.SObjectType.Opportunity;
        Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
        Id DonationId = rtMapByName.get('Donation').getRecordTypeId();
        Id VolTaskId = rtMapByName.get('Volunteer Task').getRecordTypeId();
        Id MembershipId = rtMapByName.get('Membership').getRecordTypeId();
        Id MembershipRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();
        System.assertEquals(MembershipId, MembershipRTID);

        Opportunity TestDonation = new Opportunity(
                Name = 'autofill',
                CloseDate = System.now().date(),
                RecordTypeId = VolTaskId,
                Hours_Actual__c = 2,
                AccountId = TestAcct.Id,
                Contact__c = TestCtct.Id,
                StageName = 'Closed/Won',
                CampaignId=TestCamp.Id
        );
        ListOpps.add(TestDonation);

        Opportunity TestVolTask = new Opportunity(
                Name = 'autofill',
                CloseDate = System.now().date(),
                RecordTypeId = VolTaskId,
                Hours_Actual__c = 2,
                AccountId = TestAcct.Id,
                Contact__c = TestCtct.Id,
                StageName = 'Closed/Won',
                CampaignId=TestCamp.Id
        );
        ListOpps.add(TestVolTask);

        Opportunity TestMembership = new Opportunity(
                Name = 'autofill',
                CloseDate = System.now().date().addMonths(-1),
                Membership_Start_Date__c = System.now().date().addMonths(-1),
                Membership_End_Date__c = System.now().date().addMonths(11),
                RecordTypeId = MembershipId,
                Amount = 50,
                AccountId = TestAcct.Id,
                Contact__c = TestCtct.Id,
                StageName = 'Closed/Won',
                CampaignId=TestCamp.Id
        );
        ListOpps.add(TestMembership);
        insert ListOpps;

        Account resultsAcct = [SELECT Id, Account_Membership_Expires__c from Account where Id =: TestAcct.Id];
        System.assertEquals(resultsAcct.Account_Membership_Expires__c, System.now().date().addMonths(11));
    }

    @istest static void blanktest(){
        System.debug(System.now());

        Account TestResAcct = [select Id, Name, First_Member_Date__c, Account_Membership_Expires__c, Last_Contrib_Date__c from Account where Name = 'TestAccount' LIMIT 1];
        System.debug('TestResAcct is ' + TestResAcct);
    }

    static testMethod void testGetCampaigns() {
        //build request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/CampaignsAPI';

        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        SignInREST2.getCampaigns();
        System.debug('Response is ' + res);
        // Test whether	 CampaignMember returned has DonorLevel = 'donor'
    }



    static testMethod void testGetCampaignsById() {

        Id TestCampId = [SELECT Id FROM Campaign where Name =: 'Testcampaign' LIMIT 1].Id;
        System.assert(TestCampId!=null,'TestCamp not found by the test.');

//build request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/SignInREST2API';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        req.addParameter('campaignId', TestCampId);
        req.addParameter('Org_Id',UserInfo.getOrganizationId());
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SignInREST2.getCampaigns();
        Test.stopTest();

        System.debug('responseString is ' + res);
        String testResResult = res.responseBody.toString();
        SignInREST2.CampaignResponse CR = (SignInREST2.CampaignResponse)JSON.deserialize(testResResult, SignInREST2.CampaignResponse.class);
        System.assertEquals('donor',CR.CMWs[0].DonorLevel);
        System.assertEquals('TestContact',CR.CMWs[0].lastName,'Failed to find right campaignmember.contact.lastname');
        System.assertEquals(System.today().addMonths(-1),CR.CMWs[0].MemberSince,'Wrong account.first_member_date');
        // system.assertEquals(system.now().date().addMonths(-1),CR.CMWs[0].MemberSince,'Wrong account.first_member_date__c);

        System.assertEquals(CR.CMWs[0].status,'Added to campaign');
        // system.debug('CampaignResponse is ' + CR);
        //system.debug('CR.CMExtendeds is ' + CR.CMExtendeds);
        //List<SignInREST2.CMExtended> ListCME = CR.CMExtendeds;
        //system.assertEquals(1,ListCME.size());
    }

    static testMethod void testGetCampaignsById2() {

        Campaign TestCamp = [SELECT Id, Event_Location__c FROM Campaign where Name =: 'Testcampaign' LIMIT 1];
        System.assertEquals(true,TestCamp != null,'cannot run testGetCampaignsById2 without a campaign');

//build request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/SignInREST2API?campaignId='+TestCamp.Id;
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        req.addParameter('campaignId',TestCamp.Id);
        req.addParameter('Org_Id',UserInfo.getOrganizationId());
        RestContext.request = req;
        RestContext.response = res;
        // Test here for the case that req.Org_Id is blank - should return an error

        System.debug('Request is ' + req);
        System.assertEquals(TestCamp.Id,req.params.get('campaignId'));

        Test.startTest();
        SignInREST2.getCampaigns();
        Test.stopTest();
        System.debug('After running getCampaigns RestContext.response is ' + res);
        String testResResult = res.responseBody.toString();
        System.debug('restResResult is ' + testResResult);
        SignInREST2.CampaignResponse CR = (SignInREST2.CampaignResponse)JSON.deserialize(testResResult, SignInREST2.CampaignResponse.class);
        System.debug('JSON.deserializeUnited(testResResult) results in ' + JSON.deserializeUntyped(testResResult));
        System.debug('JSON.deserialize(testResResult, SignInREST2.CMExtended.class) results in ' + JSON.deserialize(testResResult, SignInREST2.CMExtended.class));
        System.debug('CR.CampMemberWrapper CMWs donorlevel is ' + CR.CMWs[0].DonorLevel);
        System.assertEquals('donor',CR.CMWs[0].DonorLevel);
        System.assertEquals('TestContact',CR.CMWs[0].lastName,'Failed to find right campaignmember.contact.lastname');
        System.assertEquals(CR.CMWs[0].status,'Added to campaign');
        Create_Test_Variables ctv = new Create_Test_Variables();
        System.assertEquals(CR.EventLocation,ctv.TestCampaign.Event_Location__c);
        System.assertEquals(CR.EventStartTime,ctv.TestCampaign.Event_Date_Time__c);
        System.assertEquals(CR.EventEndTime,ctv.TestCampaign.Event_End_Time__c);
        System.assertEquals(CR.OrganizerName,System.UserInfo.getName());
    }

    static testMethod void testCreateCampaignMember() {
        Campaign cgn = new Campaign();
        cgn.Type = 'Public Event';
        cgn.Name = 'Test Create Member Activity';
        cgn.Status = 'Planned';
        insert cgn;

        String localtime = 'localtime' + System.currentTimeMillis() / 1000;

        SignInREST2.CampaignMemberWrapper cmw = new SignInREST2.CampaignMemberWrapper ();
        cmw.campaignId = cgn.Id;
        cmw.tempId = localtime;
        cmw.firstName = 'Test first';
        cmw.lastName = 'Test last';
        cmw.email = 'test@yahoo.com';
        cmw.phone = '8872201201';
        cmw.street = 'some street';
        cmw.city = 'some city';
        cmw.zip = '92128';
        cmw.status = 'Attended';

        List<SignInREST2.CampaignMemberWrapper> rl = new List<SignInREST2.CampaignMemberWrapper>();
        rl.add(cmw);

        String input = JSON.serialize(rl);

        //build request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addParameter('Org_Id',UserInfo.getOrganizationId());

        req.requestURI = '/services/apexrest/CampaignsAPI';
        req.requestBody = Blob.valueOf(input);

        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        SignInREST2.Response result = SignInREST2.upsertCampaignMembers();
        System.assertEquals(result.statusCode, 200, 'Contact creation failed!');
    }

    static testMethod void testCreateCampaignMemberFromContact() {
        Campaign cgn = new Campaign();
        cgn.Type = 'Public Event';
        cgn.Name = 'Test Create Member Activity';
        cgn.Status = 'Planned';
        insert cgn;

        Account acc = new Account();
        acc.Name = 'Test account';
        insert acc;

        Contact ct = new Contact();
        ct.AccountId = acc.Id;
        ct.FirstName = 'Test first';
        ct.LastName = 'Test last';
        ct.Email = 'test@yahoo.com';
        ct.Phone = '8872201201';
        ct.MailingStreet = 'some street';
        ct.MailingCity = 'some city';
        ct.MailingPostalCode = '92128';
        insert ct;

        String localtime = 'localtime' + System.currentTimeMillis() / 1000;

        SignInREST2.CampaignMemberWrapper cmw = new SignInREST2.CampaignMemberWrapper ();
        cmw.campaignId = cgn.Id;
        cmw.tempId = localtime;
        cmw.firstName = 'Test first';
        cmw.lastName = 'Test last';
        cmw.email = 'test@yahoo.com';
        cmw.phone = '8872201201';
        cmw.street = 'some street';
        cmw.city = 'some city';
        cmw.zip = '92128';
        cmw.status = 'Attended';

        List<SignInREST2.CampaignMemberWrapper> rl = new List<SignInREST2.CampaignMemberWrapper>();
        rl.add(cmw);

        String input = JSON.serialize(rl);

        //build request
        RestRequest req = new RestRequest();
        req.addParameter('Org_Id',UserInfo.getOrganizationId());
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/CampaignsAPI';
        req.requestBody = Blob.valueOf(input);

        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        SignInREST2.Response result = SignInREST2.upsertCampaignMembers();
        System.assertEquals(result.statusCode, 200, 'Contact creation failed!');
        List<CampaignMember> TestResult = [select Id, Status from CampaignMember where CampaignId=:cgn.Id];
        System.assertEquals(1,TestResult.size());
        System.debug('result.cmrMap is now ' + result.cmrMap);
        System.assertEquals('Attended',result.cmrMap.get(TestResult[0].Id).Status);
    }

    static testMethod void upsertCampaignMemberStatusForContact() {

        Campaign cgn = new Campaign();
        cgn.Type = 'Public Event';
        cgn.Name = 'Test Update Member Activity';
        cgn.Status = 'Planned';
        cgn.Event_Date_Time__c = Datetime.newInstance(2018,3,12,0,0,0);
        insert cgn;

        Account acc = new Account();
        acc.Name = 'Test account';
        insert acc;

        Contact ct = new Contact();
        ct.AccountId = acc.Id;
        ct.FirstName = 'Test first';
        ct.LastName = 'Test last';
        ct.Email = 'bdstraughan@gmail.com';
        ct.Phone = '8872301302';
        ct.MailingStreet = 'some street';
        ct.MailingCity = 'some city';
        ct.MailingState = 'CO';
        ct.MailingPostalCode = '92128';
        insert ct;

        CampaignMember cm = new CampaignMember();
        cm.ContactId = ct.Id;
        cm.CampaignId = cgn.Id;
        cm.Status = 'Added to campaign';
        insert cm;

        String input = '[{\"memberId\":\"'+ cm.Id +'\",\"recordId\":\"'+ ct.Id +'\", \"campaignId\":\"'+ cgn.Id +'\", \"tempId\":\"123123123", \"recordType\":\"Contact\", \"InviteNextLevel\":true, \"VolunteerHours\":\"2\", \"AutosendTY\":true, \"status\":\"Attended\"}]';

        //build request
        RestRequest req = new RestRequest();
        req.addParameter('Org_Id',UserInfo.getOrganizationId());
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/CampaignsAPI';
        req.requestBody = Blob.valueOf(input);

        req.httpMethod = 'POST';
        RestContext.request = req;
        System.debug('RestContext.request= '+req);
        RestContext.response = res;
        System.debug('RestContext.response= '+res);

        SignInREST2.Response result = SignInREST2.upsertCampaignMembers();
        System.debug('CampaignMembers are now ' + [select Id, Status from CampaignMember]);
        CampaignMember cm2 = [SELECT Id, Status, AutosendTY__c, HoursValue__c, Invite_to_Next_Level__c, Nr_in_Group__c FROM CampaignMember WHERE Id =: cm.Id];
        System.assertEquals('Attended', cm2.Status, 'Status update failed!');
        System.assertEquals(48.28, cm2.HoursValue__c, 'Value of hours not calculated corrrectly.');
        System.assertEquals(true, cm2.Invite_to_Next_Level__c, 'InviteNextLevel not updated in database.');
        System.assertEquals(1, cm2.Nr_in_Group__c, 'Nr_in_Group__c should be one for every entry.');
        System.debug('On update rest response is ' + res.responseBody);
        // Map<string,string> responseMap = (string)json.deserialize(res.responsebody);
        // system.assertEquals('123123123',responseMap.get('tempId'),'Response did not include tempId correctly');
        // Was opportunity created?
        List<Opportunity> resultOpps = [select Name, Hours_Actual__c from Opportunity where CampaignId =: cgn.Id];
        System.assertEquals(1,resultOpps.size());

        // Now submit a request string with a bad memberId

        input = '[{\"memberId\":\"'+ String.valueOf(cm.Id).left(8) +'\",\"recordId\":\"'+ ct.Id +'\", \"campaignId\":\"'+ cgn.Id +'\", \"tempId\":\"123123123", \"recordType\":\"Contact\", \"VolunteerHours\":\"2\", \"status\":\"Attended\"}]';

        //build request
        req = new RestRequest();
        req.addParameter('Org_Id',UserInfo.getOrganizationId());
        res = new RestResponse();

        req.requestURI = '/services/apexrest/CampaignsAPI';
        req.requestBody = Blob.valueOf(input);

        req.httpMethod = 'POST';
        RestContext.request = req;
        System.debug('RestContext.request= '+req);
        RestContext.response = res;
        System.debug('RestContext.response= '+res);

        result = SignInREST2.upsertCampaignMembers();
        System.assertEquals(result.statusCode, 500, 'Should have been 500 DML error because of invalid memberId!');


        // Now insert when the AutosendTY message has already been sent;
        //
        cm2.AutosendTY__c = 'sent';
        update cm2;

        input = '[{\"memberId\":\"'+ cm.Id +'\",\"recordId\":\"'+ ct.Id +'\", \"campaignId\":\"'+ cgn.Id +'\", \"tempId\":\"123123123", \"recordType\":\"Contact\", \"AutosendTY\":true, \"VolunteerHours\":\"2\", \"status\":\"Attended\"}]';

        //build request
        req = new RestRequest();
        req.addParameter('Org_Id',UserInfo.getOrganizationId());
        res = new RestResponse();

        req.requestURI = '/services/apexrest/CampaignsAPI';
        req.requestBody = Blob.valueOf(input);

        req.httpMethod = 'POST';
        RestContext.request = req;
        System.debug('RestContext.request= '+req);
        RestContext.response = res;
        System.debug('RestContext.response= '+res);
        result = SignInREST2.upsertCampaignMembers();
        System.debug('CampaignMembers are now ' + [select Id, AutosendTY__c, Status from CampaignMember]);
        cm2 = [SELECT Id, Status, AutosendTY__c, HoursValue__c, Hours__c FROM CampaignMember WHERE Id =: cm.Id];
        System.assertEquals('Attended', cm2.Status, 'Status update failed!');
        // This depends on the Process, which can't be deployed, so should not be included in the test.
        // System.assertEquals('sent', cm2.AutosendTY__c, 'AutosendTY update failed!');
    }

    static testMethod void updateCampaignMemberStatusForLead() {
        Campaign cgn = [select Id, Type, Name, Status from Campaign LIMIT 1];
        System.assert(cgn.Id != null);

        Lead ld = new Lead();
        ld.FirstName = 'Testfirst';
        ld.LastName = 'Testlast';
        ld.Company = 'Test company';
        ld.Email = 'test@yahoo.com';
        ld.Phone = '8872301302';
        ld.Street = 'some street';
        ld.City = 'some city';
        ld.State = 'CO';
        ld.PostalCode = '92128';
        insert ld;

        CampaignMember cm = new CampaignMember();
        cm.LeadId = ld.Id;
        cm.CampaignId = cgn.Id;
        cm.Status = 'Added to campaign';
        insert cm;

        String input = '[{\"memberId\":\"'+ cm.Id +'\", \"campaignId\":\"'+ cgn.Id +'\", \"recordId\":\"'+ ld.Id +'\", \"recordType\":\"Lead\", \"VolunteerHours\":2.0, \"status\":\"Attended\"}]';

        //build request
        RestRequest req = new RestRequest();
        req.addParameter('Org_Id',UserInfo.getOrganizationId());
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/CampaignsAPI';
        req.requestBody = Blob.valueOf(input);

        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        SignInREST2.Response result = SignInREST2.upsertCampaignMembers();

        //Lead should be converted to Contact
        List<CampaignMember> cm2 = [SELECT Id, LeadId, Lead.IsConverted, Hours__c, ContactId, Status, LastName FROM CampaignMember where LastName='Testlast'];
        System.debug('CMs are ' + cm2);
        System.assertEquals(1,cm2.size(),'Failed to find just one campaign member with last name Testlast.');
        System.assertEquals('Testlast',cm2[0].LastName,'Last name was not the lastname from the original lead which was converted.');
        System.assertEquals(2.0,cm2[0].Hours__c,'Should have 2.0 hours.');

        //Update the campaign member again, using the MemberId which should now find the Contact.
        //The need for this test only arises when there are multiple updates to a lead.

        input = '[{\"memberId\":\"'+ cm.Id +'\", \"campaignId\":\"'+ cgn.Id +'\", \"recordId\":\"'+ cm2[0].ContactId +'\", \"recordType\":\"Lead\", \"VolunteerHours\":4.0, \"status\":\"Attended\"}]';

        //build request
        RestRequest req2 = new RestRequest();
        req.addParameter('Org_Id',UserInfo.getOrganizationId());
        RestResponse res2 = new RestResponse();

        req.requestURI = '/services/apexrest/CampaignsAPI';
        req.requestBody = Blob.valueOf(input);

        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        result = SignInREST2.upsertCampaignMembers();
        CampaignMember TestResultCM = [SELECT Id, LeadId, Lead.IsConverted, ContactId, Hours__c, Status, LastName FROM CampaignMember where Id=: cm.Id];
        System.debug('CMs are ' + TestResultCM);
        System.assertEquals(true,TestResultCM.Lead.IsConverted,'Lead.IsConverted should be true.');
        System.assertEquals(4.0,TestResultCM.Hours__c,'Hours should have been updated to 4.0');
    }
}