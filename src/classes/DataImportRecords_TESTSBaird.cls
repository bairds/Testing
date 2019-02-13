/**
 * Created by PeterChurchill on 5/10/2018.
 */

@isTest
private with sharing class DataImportRecords_TESTSBaird {

    @testSetup
    private static void setupData() {
        createTestLeads();
    }

    /*Test scenarios
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
        for (Integer i=100;i<200;i++) {

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
        system.assertEquals(100,ConfirmAccts.size(),'Should have found 200 accounts created');

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