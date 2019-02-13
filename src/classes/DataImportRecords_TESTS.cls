/**
 * Created by PeterChurchill on 5/10/2018.
 */

@isTest
private with sharing class DataImportRecords_TESTS {

    @testSetup
    private static void setupData() {
        createTestLeads();
    }
/*
    Test scenarios
    Scenario 1 - New record - no contribution - should create lead
    Scenario 2 - New record with new campaign but no contribution - should create new lead, new campaign and link lead to campaign
    Scenario 3 - New record - bad zipcode - no contribution - should create error in IO Object, no lead

    Scenario 4 - New record with new campaign and contribution - should create new contact _+ account, new campaign and link contact to campaign and contribution
    Scenario 4a - New record with second person  + new campaign and contribution - should create new contact _+ account, new campaign and link contact to campaign and contribution

    Scenario 5 - record matches existing lead with new campaign and contribution  - should convert lead to new contact and create new campaign and link contact to campaign and contribution

    Scenario 6 - record matches existing contact with new campaign and contribution  - should create new campaign and contribution and link existing contact to campaign and contribution
    Scenario 6a - record matches existing contact and existing campaign with new contribution  - should link contact to existing campaign and create contribution and link existing contact to campaign and contribution

    Scenario 7 - record matches two existing leads with different reliability - should identify higher match, and update that lead
    Scenario 7 - record matches two existing contact with different reliability - should identify higher match, and update that contact

	Scenario 8 - bulk, submit 100 records


    New lead with
*/
     

    @isTest
    private static void Scenario1() {

        List<ImportObject__c> testImport = new List<ImportObject__c>();

        ImportObject__c tempImport = new ImportObject__c();
        tempImport.Person_FirstName__c = 'TestFN1_X';
        tempImport.Person_LastName__c =  'TestFL1_X';
        tempImport.Person_LegacyID__c = NULL;
        tempImport.Person_EmailPersonal__c = 'nomatchtest@example.com';
        testImport.add(tempImport);
        insert testImport;

        DataImportRecords dtest1 = new DataImportRecords ();
        for (DataImportRecords.ImportWrapper iotemp : dtest1.iowrappers) {
            iotemp.bSelected = true;
        }

        dtest1.submitListToProcess();
        EnhancedIOProcess EIOPConfirm = dtest1.matchprocess.EIMatches[5][0];
        system.assertequals(NULL, EIOPConfirm.bCreate);
        EnhancedIOProcess.enhancedIOResult ioResultConfirm = EIOPConfirm.eioResults[0];
        system.assertequals('Create New Record', ioResultConfirm.MatchReliability);
        system.assertequals(true, ioResultConfirm.bUseThisRecord);
        system.assertequals(1, ioResultConfirm.iMatchScore);
        system.assertequals('New Lead', ioResultConfirm.sType);

        dtest1.process();

        ImportObject__c ioConfirm = [Select Id, ContactCalculated__c, LeadCalculated__c, Status__c, Processed_Date__c FROM ImportObject__c WHERE Id = :testImport[0].Id];

        system.assertequals('Processed', ioConfirm.Status__c);
        system.assertequals(ioResultConfirm.matchedsObject.Id, ioConfirm.LeadCalculated__c);

        Lead lConfirm = [Select Id, LastName, FirstName,Personal_Email__c FROM Lead WHERE Id = :ioConfirm.LeadCalculated__c];
        system.assertequals('TestFL1_X', lConfirm.LastName);
        system.assertequals('nomatchtest@example.com', lConfirm.Personal_Email__c);
    }

    @isTest
    private static void Scenario2() {

        List<ImportObject__c> testImport = new List<ImportObject__c>();

        ImportObject__c tempImport = new ImportObject__c();
        tempImport.Person_FirstName__c = 'TestFN1_X';
        tempImport.Person_LastName__c =  'TestFL1_X';
        tempImport.Person_LegacyID__c = NULL;
        tempImport.Person_EmailPersonal__c = 'nomatchtest@example.com';

        tempImport.Campaign_IsActive__c = true;
        tempImport.Campaign_Name__c = 'Test Camp Scenario 2';
        testImport.add(tempImport);
        insert testImport;

        DataImportRecords dtest1 = new DataImportRecords ();
        for (DataImportRecords.ImportWrapper iotemp : dtest1.iowrappers) {
            iotemp.bSelected = true;
        }

        dtest1.submitListToProcess();
        EnhancedIOProcess EIOPConfirm = dtest1.matchprocess.EIMatches[5][0];
        system.assertequals(NULL, EIOPConfirm.bCreate);
        EnhancedIOProcess.enhancedIOResult ioResultConfirm = EIOPConfirm.eioResults[0];
        system.assertequals('Create New Record', ioResultConfirm.MatchReliability);
        system.assertequals(true, ioResultConfirm.bUseThisRecord);
        system.assertequals(1, ioResultConfirm.iMatchScore);
        system.assertequals('New Lead', ioResultConfirm.sType);

        dtest1.process();

        ImportObject__c ioConfirm = [Select Id, ContactCalculated__c, LeadCalculated__c, Status__c, Processed_Date__c FROM ImportObject__c WHERE Id = :testImport[0].Id];

        system.assertequals('Processed', ioConfirm.Status__c);
        system.assertequals(ioResultConfirm.matchedsObject.Id, ioConfirm.LeadCalculated__c);

        Lead lConfirm = [Select Id, LastName, FirstName,Personal_Email__c FROM Lead WHERE Id = :ioConfirm.LeadCalculated__c];
            system.assertequals('TestFL1_X', lConfirm.LastName);
            system.assertequals('nomatchtest@example.com', lConfirm.Personal_Email__c);
        Campaign campConfirm = [SELECT Id, Name, (Select Id, LeadId from CampaignMembers) FROM Campaign WHERE Name = 'Test Camp Scenario 2'];
        system.assertequals(1, campConfirm.CampaignMembers.size());
        system.assertequals(lConfirm.Id, campConfirm.CampaignMembers[0].Leadid);

    }


    @isTest
    private static void Scenario3() {

        List<ImportObject__c> testImport = new List<ImportObject__c>();

        ImportObject__c tempImport = new ImportObject__c();
        tempImport.Person_FirstName__c = 'TestFN1_X';
        tempImport.Person_LastName__c =  'TestFL1_X';
        tempImport.Person_LegacyID__c = NULL;
        tempImport.Person_EmailPersonal__c = 'nomatchtest@example.com';
        tempImport.Address_ZipCode__c = '1234567890123456789012';

        testImport.add(tempImport);
        insert testImport;

        DataImportRecords dtest1 = new DataImportRecords ();
        for (DataImportRecords.ImportWrapper iotemp : dtest1.iowrappers) {
            iotemp.bSelected = true;
        }

        dtest1.submitListToProcess();
        EnhancedIOProcess EIOPConfirm = dtest1.matchprocess.EIMatches[5][0];
        system.assertequals(NULL, EIOPConfirm.bCreate);
        EnhancedIOProcess.enhancedIOResult ioResultConfirm = EIOPConfirm.eioResults[0];
        system.assertequals('Create New Record', ioResultConfirm.MatchReliability);
        system.assertequals(true, ioResultConfirm.bUseThisRecord);
        system.assertequals(1, ioResultConfirm.iMatchScore);
        system.assertequals('New Lead', ioResultConfirm.sType);
        Lead leadConfirm = (lead)ioResultConfirm.matchedsObject;

        dtest1.process();
        ImportObject__c ioConfirm = [Select Id, ContactCalculated__c, LeadCalculated__c, Status__c, Processed_Date__c FROM ImportObject__c WHERE Id = :testImport[0].Id];
        system.assertequals('Error with Processing', ioConfirm.Status__c);

    }



    @isTest
    private static void Scenario4() {

        List<ImportObject__c> testImport = new List<ImportObject__c>();

        ImportObject__c tempImport = new ImportObject__c();
        tempImport.Person_FirstName__c = 'TestFN1_X';
        tempImport.Person_LastName__c =  'TestFL1_X';
        tempImport.Person_LegacyID__c = NULL;
        tempImport.Person_EmailPersonal__c = 'nomatchtest@example.com';

        tempImport.Address_StreetLine1__c = '2546 Main Street';
        tempImport.Address_StreetLine2__c = 'Apt 2';
        tempImport.Address_City__c = 'Arlington';
        tempImport.Address_State__c = 'VA';
        tempImport.Address_ZipCode__c = '22206';

        tempImport.Campaign_IsActive__c = true;
        tempImport.Campaign_Name__c = 'Test Camp Scenario 4';

        tempImport.Contribution_Amount__c = 100;
        tempImport.Contribution_Type__c = 'Donation';
        tempImport.Contribution_Stage__c = 'Closed/Won';
        tempImport.Contribution_TransactionDate__c = system.today();

        testImport.add(tempImport);
        insert testImport;
        //Created_Campaign_Member_Record__c
        //Created_Second_Contact__c
        //Processed__c

        DataImportRecords dtest1 = new DataImportRecords ();
        for (DataImportRecords.ImportWrapper iotemp : dtest1.iowrappers) {
            iotemp.bSelected = true;
        }

        dtest1.submitListToProcess();
        EnhancedIOProcess EIOPConfirm = dtest1.matchprocess.EIMatches[5][0];
        system.assertequals(NULL, EIOPConfirm.bCreate);
        EnhancedIOProcess.enhancedIOResult ioResultConfirm = EIOPConfirm.eioResults[0];
        system.assertequals('Create New Record', ioResultConfirm.MatchReliability);
        system.assertequals(true, ioResultConfirm.bUseThisRecord);
        system.assertequals(1, ioResultConfirm.iMatchScore);
        system.assertequals('New Contact', ioResultConfirm.sType);


        dtest1.process();

        ImportObject__c ioConfirm = [Select Id, ContactCalculated__c, LeadCalculated__c, Status__c, Processed_Date__c FROM ImportObject__c WHERE Id = :testImport[0].Id];

        system.assertequals('Processed', ioConfirm.Status__c);
        system.assertequals(ioResultConfirm.matchedsObject.Id, ioConfirm.ContactCalculated__c);

        Contact cConfirm = [Select Id, LastName, FirstName, Personal_Email__c FROM Contact WHERE Id = :ioConfirm.ContactCalculated__c];
        system.assertequals('TestFL1_X', cConfirm.LastName);
        system.assertequals('nomatchtest@example.com', cConfirm.Personal_Email__c);
        Campaign campConfirm = [SELECT Id, Name, (Select Id, ContactId, LeadId from CampaignMembers) FROM Campaign WHERE Name = 'Test Camp Scenario 4'];
        system.assertequals(1, campConfirm.CampaignMembers.size());
        system.assertequals(cConfirm.Id, campConfirm.CampaignMembers[0].ContactId);
        Opportunity oConfirm = [Select Id, CampaignId, Amount, (Select ContactId from OpportunityContactRoles) from Opportunity];
        system.assertequals(campConfirm.Id, oConfirm.CampaignId);
        system.assertequals(100.00, oConfirm.Amount);
        system.assertequals(1, oConfirm.OpportunityContactRoles.size());
        system.assertequals(cConfirm.Id, oConfirm.OpportunityContactRoles[0].ContactId);


    }

    @isTest
    private static void Scenario4A() {

        List<ImportObject__c> testImport = new List<ImportObject__c>();

        ImportObject__c tempImport = new ImportObject__c();
        tempImport.Person_FirstName__c = 'TestFN1_X';
        tempImport.Person_LastName__c =  'TestFL1_X';
        tempImport.Person_LegacyID__c = NULL;
        tempImport.Person_EmailPersonal__c = 'nomatchtest@example.com';

        tempImport.Person2_FirstName__c = 'TestFN2_X';
        tempImport.Person2_LastName__c =  'TestScenario4A';

        tempImport.Address_StreetLine1__c = '2546 Main Street';
        tempImport.Address_StreetLine2__c = 'Apt 2';
        tempImport.Address_City__c = 'Arlington';
        tempImport.Address_State__c = 'VA';
        tempImport.Address_ZipCode__c = '22206';

        tempImport.Campaign_IsActive__c = true;
        tempImport.Campaign_Name__c = 'Test Camp Scenario 4A';

        tempImport.Contribution_Amount__c = 100;
        tempImport.Contribution_Type__c = 'Donation';
        tempImport.Contribution_Stage__c = 'Closed/Won';
        tempImport.Contribution_TransactionDate__c = system.today();

        testImport.add(tempImport);
        insert testImport;
        //Created_Campaign_Member_Record__c
        //Created_Second_Contact__c
        //Processed__c

        DataImportRecords dtest1 = new DataImportRecords ();
        for (DataImportRecords.ImportWrapper iotemp : dtest1.iowrappers) {
            iotemp.bSelected = true;
        }

        dtest1.submitListToProcess();
        EnhancedIOProcess EIOPConfirm = dtest1.matchprocess.EIMatches[5][0];
        system.assertequals(NULL, EIOPConfirm.bCreate);
        EnhancedIOProcess.enhancedIOResult ioResultConfirm = EIOPConfirm.eioResults[0];
        system.assertequals('Create New Record', ioResultConfirm.MatchReliability);
        system.assertequals(true, ioResultConfirm.bUseThisRecord);
        system.assertequals(1, ioResultConfirm.iMatchScore);
        system.assertequals('New Contact', ioResultConfirm.sType);


        dtest1.process();

        ImportObject__c ioConfirm = [Select Id, ContactCalculated__c, LeadCalculated__c, Status__c, Processed_Date__c FROM ImportObject__c WHERE Id = :testImport[0].Id];

        system.assertequals('Processed', ioConfirm.Status__c);
        system.assertequals(ioResultConfirm.matchedsObject.Id, ioConfirm.ContactCalculated__c);

        Contact cConfirm = [Select Id, LastName, FirstName, Personal_Email__c FROM Contact WHERE Id = :ioConfirm.ContactCalculated__c];
        system.assertequals('TestFL1_X', cConfirm.LastName);
        system.assertequals('nomatchtest@example.com', cConfirm.Personal_Email__c);

        Contact [] cConfirm2 = [Select Id, LastName, FirstName, Personal_Email__c FROM Contact WHERE LastName = 'TestScenario4A'];
        system.assertequals(1, cConfirm2.size());

        Campaign campConfirm = [SELECT Id, Name, (Select Id, ContactId, LeadId from CampaignMembers) FROM Campaign WHERE Name = 'Test Camp Scenario 4A'];
        system.assertequals(2, campConfirm.CampaignMembers.size());
        system.assertequals(cConfirm.Id, campConfirm.CampaignMembers[0].ContactId);
        system.assertequals(cConfirm2[0].Id, campConfirm.CampaignMembers[1].ContactId);

        Opportunity oConfirm = [Select Id, CampaignId, Amount, (Select ContactId from OpportunityContactRoles) from Opportunity];
        system.assertequals(campConfirm.Id, oConfirm.CampaignId);
        system.assertequals(100.00, oConfirm.Amount);
        system.assertequals(1, oConfirm.OpportunityContactRoles.size());
        system.assertequals(cConfirm.Id, oConfirm.OpportunityContactRoles[0].ContactId);


    }

    @isTest
    private static void LeadTestEmailOnlyHome() {

        List<ImportObject__c> testImport = new List<ImportObject__c>();

        ImportObject__c tempImport = new ImportObject__c();
        tempImport.Person_FirstName__c = 'TestFN1_X';
        tempImport.Person_LastName__c =  'TestFL1_X';
        tempImport.Person_LegacyID__c = NULL;
        tempImport.Person_EmailPersonal__c = 'emailonly@example.com';

        
        //tempImport.Person_EmailWork__c

        //tempImport.Address_StreetLine1__c
        //tempImport.Address_StreetLine2__c
        //tempImport.Address_City__c
        //tempImport.Address_State__c
        // tempImport.Address_ZipCode__c
        
        tempImport.Campaign_IsActive__c = true;
        tempImport.Campaign_Name__c = 'Test Camp 1';
        testImport.add(tempImport);
        insert testImport;
                //Created_Campaign_Member_Record__c
                //Created_Second_Contact__c
        //Processed__c

        DataImportRecords dtest1 = new DataImportRecords ();
            for (DataImportRecords.ImportWrapper iotemp : dtest1.iowrappers) {
                iotemp.bSelected = true;
            }

        dtest1.submitListToProcess();
        EnhancedIOProcess EIOPConfirm = dtest1.matchprocess.EIMatches[1][0];
        system.assertequals(NULL, EIOPConfirm.bCreate);
        EnhancedIOProcess.enhancedIOResult ioResultConfirm = EIOPConfirm.eioResults[0];
        system.assertequals('Match on Email only', ioResultConfirm.MatchReliability);
        system.assertequals(true, ioResultConfirm.bUseThisRecord);
        system.assertequals(1, ioResultConfirm.iMatchScore);
        system.assertequals('Lead', ioResultConfirm.sType);
        Lead leadConfirm = (lead)ioResultConfirm.matchedsObject;

        dtest1.process();
    }

    @isTest
    private static void MultipleMatchesOnLeadTestEmailOnlyHome() {

        List<ImportObject__c> testImport = new List<ImportObject__c>();

        ImportObject__c tempImport = new ImportObject__c();
        tempImport.Person_FirstName__c = 'TestFN1_X';
        tempImport.Person_LastName__c =  'TestFL1_X';
        tempImport.Person_LegacyID__c = 'X123';

        tempImport.Person_EmailPersonal__c = 'emailonly@example.com';
        tempImport.Person_PhoneHome__c = '202 555 1234';
        tempImport.Campaign_IsActive__c = true;
        tempImport.Campaign_Name__c = 'Test Camp 1';
        testImport.add(tempImport);

        ImportObject__c tempImport2 = new ImportObject__c();
        tempImport2.Person_FirstName__c = 'TestFN1_X';
        tempImport2.Person_LastName__c =  'TestFL1_X';
        tempImport2.Person_LegacyID__c = 'X123';
        tempImport2.Person_EmailPersonal__c = 'emailonly@example.com';
        tempImport.Person_PhoneHome__c = '202 555 1234';
        //tempImport.Person_EmailWork__c

        tempImport2.Address_StreetLine1__c = '2546 Main Street';
        //tempImport2.Address_StreetLine2__c
        tempImport2.Address_City__c = 'Arlington';
        tempImport2.Address_State__c = 'VA';
        tempImport2.Address_ZipCode__c = '22206';

        //tempImport.Campaign_IsActive__c = true;
        //tempImport.Campaign_Name__c = 'Test Camp 1';
        testImport.add(tempImport2);


        insert testImport;
        //Created_Campaign_Member_Record__c
        //Created_Second_Contact__c
        //Processed__c

        DataImportRecords dtest1 = new DataImportRecords ();
        for (DataImportRecords.ImportWrapper iotemp : dtest1.iowrappers) {
            iotemp.bSelected = true;
        }

        dtest1.submitListToProcess();

        dtest1.process();
        Lead lconfirm = [SELECT id, Name, Legacy_Contact_ID__c, email, firstname, lastname, phone, mobilephone,Home_Phone__c,
                Company,Street, City, State,PostalCode, Country,Salutation, Personal_Email__c,Other_Email__c,
                Work_Email__c, Title, Volunteer_Interests__c, Mailing_Lists__c, Do_Not__c
        FROM LEAD WHERE Legacy_Contact_ID__c = 'X123'];
        system.assertequals('202 555 1234', lconfirm.Home_Phone__c);
        system.assertequals('2546 Main Street', lconfirm.Street);
        system.assertequals('22206', lconfirm.PostalCode);

    }

//8
    @isTest
    private static void MultipleMatchesOnLeadWithDonation() {

        List<ImportObject__c> testImport = new List<ImportObject__c>();

        ImportObject__c tempImport = new ImportObject__c();
        tempImport.Person_FirstName__c = 'TestFN1_X';
        tempImport.Person_LastName__c =  'TestFL1_X';
        tempImport.Person_LegacyID__c = 'X123';

        tempImport.Person_EmailPersonal__c = 'emailonly@example.com';
        tempImport.Person_PhoneHome__c = '202 555 1234';
        tempImport.Contribution_Amount__c = 100;
        tempImport.Contribution_Type__c = 'Donation';
        tempImport.Contribution_Stage__c = 'Closed/Won';
        tempImport.Contribution_TransactionDate__c = system.today();
        tempImport.Campaign_IsActive__c = true;
        tempImport.Campaign_Name__c = 'Test Camp 1';
        testImport.add(tempImport);

        ImportObject__c tempImport2 = new ImportObject__c();
        tempImport2.Person_FirstName__c = 'TestFN1_X';
        tempImport2.Person_LastName__c =  'TestFL1_X';
        tempImport2.Person_LegacyID__c = 'X123';
        tempImport2.Person_EmailPersonal__c = 'emailonly@example.com';
        tempImport.Person_PhoneHome__c = '202 555 1234';
        //tempImport.Person_EmailWork__c

        tempImport2.Address_StreetLine1__c = '2546 Main Street';
        //tempImport2.Address_StreetLine2__c
        tempImport2.Address_City__c = 'Arlington';
        tempImport2.Address_State__c = 'VA';
        tempImport2.Address_ZipCode__c = '22206';

        //tempImport.Campaign_IsActive__c = true;
        //tempImport.Campaign_Name__c = 'Test Camp 1';
        testImport.add(tempImport2);


        insert testImport;
        //Created_Campaign_Member_Record__c
        //Created_Second_Contact__c
        //Processed__c

        DataImportRecords dtest1 = new DataImportRecords ();
        for (DataImportRecords.ImportWrapper iotemp : dtest1.iowrappers) {
            iotemp.bSelected = true;
        }

        dtest1.submitListToProcess();

        dtest1.process();
        Lead lconfirm = [SELECT id, Name, IsConverted
        FROM LEAD WHERE Legacy_Contact_ID__c = 'X123'];
        system.assertequals(true, lconfirm.isConverted);
        Contact cConfirm = [SELECT id, Name, Legacy_Contact_ID__c, email, firstname, lastname, MailingStreet, MailingCity, MailingState,MailingPostalCode,
                Volunteer_Interests__c, Mailing_Lists__c, Do_Not__c FROM Contact WHERE Legacy_Contact_ID__c = 'X123'];
        system.assertequals('22206', cConfirm.MailingPostalCode);
        system.assertequals('legacyid@example.com', cConfirm.Email);

    }

    @isTest
    private static void LeadTestEmailwithLNHome() {

        List<ImportObject__c> testImport = new List<ImportObject__c>();

        ImportObject__c tempImport = new ImportObject__c();
        tempImport.Person_FirstName__c = 'Y';
        tempImport.Person_LastName__c =  'TestLN1';
        tempImport.Person_LegacyID__c = NULL;
        tempImport.Person_EmailPersonal__c = 'emailonly@example.com';
        tempImport.Campaign_IsActive__c = true;
        tempImport.Campaign_Name__c = 'Test Camp 1';
        testImport.add(tempImport);
        insert testImport;
        //Created_Campaign_Member_Record__c
        //Created_Second_Contact__c
        //Processed__c

        DataImportRecords dtest1 = new DataImportRecords ();
        for (DataImportRecords.ImportWrapper iotemp : dtest1.iowrappers) {
            iotemp.bSelected = true;
        }

        dtest1.submitListToProcess();
        EnhancedIOProcess EIOPConfirm = dtest1.matchprocess.EIMatches[2][0];
        system.assertequals(NULL, EIOPConfirm.bCreate);
        EnhancedIOProcess.enhancedIOResult ioResultConfirm = EIOPConfirm.eioResults[0];
        system.assertequals('Match on Email LN', ioResultConfirm.MatchReliability);
        system.assertequals(true, ioResultConfirm.bUseThisRecord);
        system.assertequals(2, ioResultConfirm.iMatchScore);
        system.assertequals('Lead', ioResultConfirm.sType);
        Lead leadConfirm = (lead)ioResultConfirm.matchedsObject;

        dtest1.process();
    }

    @isTest
    private static void LeadTestEmailwithLNFNHome() {

        List<ImportObject__c> testImport = new List<ImportObject__c>();

        ImportObject__c tempImport = new ImportObject__c();
        tempImport.Person_FirstName__c = 'Test';
        tempImport.Person_LastName__c =  'TestLN1';
        tempImport.Person_LegacyID__c = NULL;
        tempImport.Person_EmailPersonal__c = 'emailonly@example.com';
        tempImport.Campaign_IsActive__c = true;
        tempImport.Campaign_Name__c = 'Test Camp 1';
        testImport.add(tempImport);
        insert testImport;
        //Created_Campaign_Member_Record__c
        //Created_Second_Contact__c
        //Processed__c

        DataImportRecords dtest1 = new DataImportRecords ();
        for (DataImportRecords.ImportWrapper iotemp : dtest1.iowrappers) {
            iotemp.bSelected = true;
        }

        dtest1.submitListToProcess();
        EnhancedIOProcess EIOPConfirm = dtest1.matchprocess.EIMatches[3][0];
        system.assertequals(NULL, EIOPConfirm.bCreate);
        EnhancedIOProcess.enhancedIOResult ioResultConfirm = EIOPConfirm.eioResults[0];
        system.assertequals('Match on Email LN FN', ioResultConfirm.MatchReliability);
        system.assertequals(true, ioResultConfirm.bUseThisRecord);
        system.assertequals(3, ioResultConfirm.iMatchScore);
        system.assertequals('Lead', ioResultConfirm.sType);
        Lead leadConfirm = (lead)ioResultConfirm.matchedsObject;

        dtest1.process();
    }

    @isTest
    private static void LeadTestEmailwithmultipleMatches1() {

        List<ImportObject__c> testImport = new List<ImportObject__c>();

        ImportObject__c tempImport = new ImportObject__c();
        tempImport.Person_FirstName__c = 'Test';
        tempImport.Person_LastName__c =  'TestLN1F';
        tempImport.Person_LegacyID__c = NULL;
        tempImport.Person_EmailPersonal__c = 'emailonly@example.com';

        tempImport.Campaign_IsActive__c = true;
        tempImport.Campaign_Name__c = 'Test Camp 1';
        testImport.add(tempImport);
        insert testImport;
        //Created_Campaign_Member_Record__c
        //Created_Second_Contact__c
        //Processed__c

        DataImportRecords dtest1 = new DataImportRecords ();
        for (DataImportRecords.ImportWrapper iotemp : dtest1.iowrappers) {
            iotemp.bSelected = true;
        }

        dtest1.submitListToProcess();
        EnhancedIOProcess EIOPConfirm = dtest1.matchprocess.EIMatches[3][0];
        system.assertequals(NULL, EIOPConfirm.bCreate);
        EnhancedIOProcess.enhancedIOResult  ioResultConfirm;
        for (EnhancedIOProcess.enhancedIOResult ioResultTemp : EIOPConfirm.eioResults) {
            if (ioResultTemp.bUseThisRecord == true) {
                ioResultConfirm = ioResultTemp;
            }
        }
        system.assertequals('Match on Email LN FN', ioResultConfirm.MatchReliability);
        system.assertequals(true, ioResultConfirm.bUseThisRecord);
        system.assertequals(3, ioResultConfirm.iMatchScore);
        system.assertequals('Lead', ioResultConfirm.sType);
        Lead leadConfirm = (lead)ioResultConfirm.matchedsObject;

        dtest1.process();
    }

    @isTest
    private static void LeadTestEmailOnlyWork() {

        List<ImportObject__c> testImport = new List<ImportObject__c>();

        ImportObject__c tempImport = new ImportObject__c();
        tempImport.Person_FirstName__c = 'TestFN1_X';
        tempImport.Person_LastName__c =  'TestFL1_X';
        tempImport.Person_LegacyID__c = NULL;
        tempImport.Person_EmailWork__c = 'emailonly@example.com';
        tempImport.Campaign_IsActive__c = true;
        tempImport.Campaign_Name__c = 'Test Camp 1';
        testImport.add(tempImport);
        insert testImport;
        //Created_Campaign_Member_Record__c
        //Created_Second_Contact__c
        //Processed__c

        DataImportRecords dtest1 = new DataImportRecords ();
        for (DataImportRecords.ImportWrapper iotemp : dtest1.iowrappers) {
            iotemp.bSelected = true;
        }

        dtest1.submitListToProcess();
        EnhancedIOProcess EIOPConfirm = dtest1.matchprocess.EIMatches[1][0];
        system.assertequals(NULL, EIOPConfirm.bCreate);
        EnhancedIOProcess.enhancedIOResult ioResultConfirm = EIOPConfirm.eioResults[0];
        system.assertequals('Match on Email only', ioResultConfirm.MatchReliability);
        system.assertequals(true, ioResultConfirm.bUseThisRecord);
        system.assertequals(1, ioResultConfirm.iMatchScore);
        system.assertequals('Lead', ioResultConfirm.sType);
        Lead leadConfirm = (lead)ioResultConfirm.matchedsObject;

        dtest1.process();
    }

    @isTest
    private static void LeadTestEmailwithLNWork() {

        List<ImportObject__c> testImport = new List<ImportObject__c>();

        ImportObject__c tempImport = new ImportObject__c();
        tempImport.Person_FirstName__c = 'Y';
        tempImport.Person_LastName__c =  'TestLN1';
        tempImport.Person_LegacyID__c = NULL;
        tempImport.Person_EmailWork__c = 'emailonly@example.com';
        tempImport.Campaign_IsActive__c = true;
        tempImport.Campaign_Name__c = 'Test Camp 1';
        testImport.add(tempImport);
        insert testImport;
        //Created_Campaign_Member_Record__c
        //Created_Second_Contact__c
        //Processed__c

        DataImportRecords dtest1 = new DataImportRecords ();
        for (DataImportRecords.ImportWrapper iotemp : dtest1.iowrappers) {
            iotemp.bSelected = true;
        }

        dtest1.submitListToProcess();
        EnhancedIOProcess EIOPConfirm = dtest1.matchprocess.EIMatches[2][0];
        system.assertequals(NULL, EIOPConfirm.bCreate);
        EnhancedIOProcess.enhancedIOResult ioResultConfirm = EIOPConfirm.eioResults[0];
        system.assertequals('Match on Email LN', ioResultConfirm.MatchReliability);
        system.assertequals(true, ioResultConfirm.bUseThisRecord);
        system.assertequals(2, ioResultConfirm.iMatchScore);
        system.assertequals('Lead', ioResultConfirm.sType);
        Lead leadConfirm = (lead)ioResultConfirm.matchedsObject;

        dtest1.process();
    }

    @isTest
    private static void LeadTestEmailwithLNFNWork() {

        List<ImportObject__c> testImport = new List<ImportObject__c>();

        ImportObject__c tempImport = new ImportObject__c();
        tempImport.Person_FirstName__c = 'Test';
        tempImport.Person_LastName__c =  'TestLN1';
        tempImport.Person_LegacyID__c = NULL;
        tempImport.Person_EmailWork__c = 'emailonly@example.com';
        tempImport.Campaign_IsActive__c = true;
        tempImport.Campaign_Name__c = 'Test Camp 1';
        testImport.add(tempImport);
        insert testImport;
        //Created_Campaign_Member_Record__c
        //Created_Second_Contact__c
        //Processed__c

        DataImportRecords dtest1 = new DataImportRecords ();
        for (DataImportRecords.ImportWrapper iotemp : dtest1.iowrappers) {
            iotemp.bSelected = true;
        }

        dtest1.submitListToProcess();
        EnhancedIOProcess EIOPConfirm = dtest1.matchprocess.EIMatches[3][0];
        system.assertequals(NULL, EIOPConfirm.bCreate);
        EnhancedIOProcess.enhancedIOResult ioResultConfirm = EIOPConfirm.eioResults[0];
        system.assertequals('Match on Email LN FN', ioResultConfirm.MatchReliability);
        system.assertequals(true, ioResultConfirm.bUseThisRecord);
        system.assertequals(3, ioResultConfirm.iMatchScore);
        system.assertequals('Lead', ioResultConfirm.sType);
        Lead leadConfirm = (lead)ioResultConfirm.matchedsObject;

        dtest1.process();
    }



    @isTest
    private static void LeadTestLegacy() {

        List<ImportObject__c> testImport = new List<ImportObject__c>();

        ImportObject__c tempImport = new ImportObject__c();
        tempImport.Person_FirstName__c = 'TestFN1_X';
        tempImport.Person_LastName__c =  'TestFL1_X';
        tempImport.Person_LegacyID__c = 'X123';
        tempImport.Person_EmailPersonal__c = 'testlegacy@example.com';
        tempImport.Campaign_IsActive__c = true;
        tempImport.Campaign_Name__c = 'Test Camp 1';
        testImport.add(tempImport);
        insert testImport;
        //Created_Campaign_Member_Record__c
        //Created_Second_Contact__c
        //Processed__c

        DataImportRecords dtest1 = new DataImportRecords ();
        for (DataImportRecords.ImportWrapper iotemp : dtest1.iowrappers) {
            iotemp.bSelected = true;
        }


        dtest1.submitListToProcess();
       //Should be matched to first list
        EnhancedIOProcess EIOPConfirm = dtest1.matchprocess.EIMatches[4][0];
        system.assertequals(NULL, EIOPConfirm.bCreate);
        EnhancedIOProcess.enhancedIOResult ioResultConfirm = EIOPConfirm.eioResults[0];
        system.assertequals('Match on Legacy Id', ioResultConfirm.MatchReliability);
        system.assertequals(true, ioResultConfirm.bUseThisRecord);
        system.assertequals(4, ioResultConfirm.iMatchScore);
        system.assertequals('Lead', ioResultConfirm.sType);
        Lead leadConfirm = (lead)ioResultConfirm.matchedsObject;

        dtest1.process();

    }

    @isTest
    private static void LeadTestNameZipMatch() {

        List<ImportObject__c> testImport = new List<ImportObject__c>();

        ImportObject__c tempImport = new ImportObject__c();
        tempImport.Person_FirstName__c = 'TestFN4';
        tempImport.Person_LastName__c =  'TestLN4';
        tempImport.Person_LegacyID__c = 'X 123';
        tempImport.Person_EmailPersonal__c = 'testnamezipmatch@example.com';
        tempImport.Address_ZipCode__c = '22206';
        tempImport.Campaign_IsActive__c = true;
        tempImport.Campaign_Name__c = 'Test Camp 1';
        testImport.add(tempImport);
        insert testImport;
        //Created_Campaign_Member_Record__c
        //Created_Second_Contact__c
        //Processed__c

        DataImportRecords dtest1 = new DataImportRecords ();
        for (DataImportRecords.ImportWrapper iotemp : dtest1.iowrappers) {
            iotemp.bSelected = true;
        }

        dtest1.submitListToProcess();
    }
    
 
    
    @isTest
    private static void BulkSubmit100() {
        List<ImportObject__c> testIOs = new List<ImportObject__c>();       
        for (Integer i=0;i<100;i++){
            ImportObject__c tempImport = new ImportObject__c();
            tempImport.Person_FirstName__c = 'TestFN';
            tempImport.Person_LastName__c =  'TestLN'+i;
            tempImport.Person_LegacyID__c = 'X ' + i;
            tempImport.Person_EmailPersonal__c = string.ValueOf(i)+'testemailmatch@example.com';
            tempImport.Address_ZipCode__c = '22206';
            tempImport.Campaign_IsActive__c = true;
            tempImport.Campaign_Name__c = 'Test Camp 1';
            tempImport.Contribution_Amount__c = 50.00;
            tempImport.Contribution_TransactionDate__c = system.now().date();
            tempImport.Contribution_RecordType__c = 'Membership';
            testIOs.add(tempImport);
            system.debug('testIOs is ' + testIOs);
            system.assertEquals(i+1,testIOs.size());
        }
        system.assertEquals(100,testIOs.size());
        insert testIOs;
                
        List<Lead> testleads = new List<Lead>();     
        for (Integer i=100;i<100;i++) {

            // All these leads will have to be converted
            testleads.add (new Lead(
                    Company = 'Test1',
                    FirstName = 'TestFN',
                    LastName = 'TestLN' + i,
                    Email = string.valueOf(i) + 'testemailmatch@example.com',
                    Legacy_Contact_ID__c = NULL,
                    PostalCode = '22206'
            ));
        }
        insert testleads;

        DataImportRecords dtest1 = new DataImportRecords ();
        for (DataImportRecords.ImportWrapper iotemp : dtest1.iowrappers) {
            iotemp.bSelected = true;
         }
        system.debug('Start Test Run');
        //test.StartTest();
            dtest1.submitListToProcess();
            dtest1.Process();
        //test.StopTest();

        List<Account> ConfirmAccts = [SELECT Id, Name, Account_Membership_Expires__c, Last_Membership_Date__c from Account];
        system.assertEquals(100,ConfirmAccts.size(),'Should have found 100 accounts created');

    }

    private static void createTestLeads() {

        List<Lead> testleads = new List<Lead>();
        testleads.add (new Lead(
                Company = 'Test1',
                LastName = 'TestLN1',
                FirstName = 'TestFN1',
                Email = 'emailonly@example.com',
                Legacy_Contact_ID__c = NULL,
                PostalCode = '22206'
        ));
        testleads.add (new Lead(
                Company = 'Test1',
                LastName = 'TestLN1F',
                FirstName = 'TestFN1F',
                Email = 'emailonly@example.com',
                Legacy_Contact_ID__c = 'X12F',
                PostalCode = '22206'
        ));

        testleads.add (new Lead(
                Company = 'Test2',
                LastName = 'TestLN2',
                FirstName = 'TestFN2',
                Email = 'nameonly@example.com',
                Legacy_Contact_ID__c = NULL,
                PostalCode = '22206'
        ));
        testleads.add (new Lead(
                Company = 'Test3',
                LastName = 'TestLN3',
                FirstName = 'TestFN3',
                Email = 'legacyid@example.com',
                Legacy_Contact_ID__c = 'X123',
                PostalCode = '22206'
        ));
        testleads.add (new Lead(
                Company = 'Test4',
                LastName = 'TestLN4',
                FirstName = 'TestFN4',
                Email = 'namezip@example.com',
                Legacy_Contact_ID__c = NULL,
                PostalCode = '22206'
        ));

        insert testleads;
    }
}