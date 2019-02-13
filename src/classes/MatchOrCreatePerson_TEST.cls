/**
 * Created by PeterChurchill on 2/6/2018.
 */
@isTest
private with sharing class MatchOrCreatePerson_TEST {

    @testSetup
    private static void setDatatoMatch() {
        Account testHoldingAccount = new Account(Name = 'Holding');
        insert testHoldingAccount ;

        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = testHoldingAccount .Id, LastName = 'TestLN0', FirstName = 'TestFN0', Email = 'test0@example.com', Legacy_Contact_ID__c = 'X1234567'));
        contacts.add(new Contact(AccountId = testHoldingAccount .Id, LastName = 'TestLN1', FirstName = 'TestFN1', Email = 'test1@example.com', MailingPostalCode = '22206'));
        contacts.add(new Contact(AccountId = testHoldingAccount .Id, LastName = 'TestLN2', FirstName = 'TestFN2', MailingPostalCode = '22206'));
        contacts.add(new Contact(AccountId = testHoldingAccount .Id, LastName = 'TestLN3', FirstName = 'TestFN3', Email = 'test3@example.com', MailingPostalCode = '22206'));
        insert contacts;
    }

    @isTest
    private static void matchOrCreatePerson_OneContact() {
        List<ImportObject__c> iotests = new List<ImportObject__c>();
//Should match on Legacy even though other details do not match
        iotests.add(new ImportObject__c(
                Person_FirstName__c = 'Test0',
                Person_LastName__c = 'Test0',
                Person_EmailPersonal__c = NULL,
                Person_EmailWork__c = 'test0@nomatch.com',
                Person_LegacyID__c = 'X1234567',
                Person_PhoneHome__c = NULL));
//Should match on Email even though other details do not match
        iotests.add(new ImportObject__c(
                Person_FirstName__c = 'TestFN1A',
                Person_LastName__c = 'TestLN1A',
                Person_EmailPersonal__c = 'test1@example.com',
                Person_EmailWork__c = 'test2@example.com'
        ));
//Should match on Fn + LN + Zip
        iotests.add(new ImportObject__c(
                Person_FirstName__c = 'TestFN2',
                Person_LastName__c = 'TestLN2',
                Person_EmailPersonal__c = 'nomatch@example.com',
                Address_ZipCode__c = '22206'));
//Should match on Fn + LN + Zip even though email has no match
        iotests.add(new ImportObject__c(
                Person_FirstName__c = 'TestFN3',
                Person_LastName__c = 'TestLN3',
                Person_EmailPersonal__c = 'nomatch@example.com',
                Address_ZipCode__c = '22206'));
//Should be not match so create new Lead
        iotests.add(new ImportObject__c(
                Person_FirstName__c = 'TestFNNEW',
                Person_LastName__c = 'TestLNNEW',
                Person_EmailPersonal__c = 'nomatch@example.com',
                Address_ZipCode__c = '22206'));

        //Should now match previously created new Lead
        iotests.add(new ImportObject__c(
                Person_FirstName__c = 'TestFNNEW2',
                Person_LastName__c = 'TestLNNEW2',
                Person_EmailPersonal__c = 'nomatch@example.com',
                Address_ZipCode__c = '22206'));

//Should be not match so create new Contact
        iotests.add(new ImportObject__c(
                Person_FirstName__c = 'TestFNNEW',
                Person_LastName__c = 'TestLNNEW',
                Person_EmailPersonal__c = 'nomatchc@example.com',
                Address_ZipCode__c = '22207',
                Contribution_Amount__c = 123
        ));
        insert iotests;
//Get Matching Contact
        List<Contact> contacts = [Select Id, LastName from Contact Order By LastName ASC];
        matchOrCreatePerson matchtests = new matchOrCreatePerson();
        matchtests.matchRecordsToPeople(iotests);
        system.assertequals('Match on Legacy Id', matchtests.NewEnhancedIOs[0].MatchReliability);
        system.assertequals(contacts[0].Id, matchtests.NewEnhancedIOs[0].matchedsObject.Id);

        system.assertequals('Match on Email only', matchtests.NewEnhancedIOs[1].MatchReliability);
        system.assertequals(contacts[1].Id, matchtests.NewEnhancedIOs[1].matchedsObject.Id);

        system.assertequals('Match on Lastname Firstname Zip', matchtests.NewEnhancedIOs[2].MatchReliability);
        system.assertequals(contacts[2].Id, matchtests.NewEnhancedIOs[2].matchedsObject.Id);

        system.assertequals('Match on Lastname Firstname Zip', matchtests.NewEnhancedIOs[3].MatchReliability);
        system.assertequals(contacts[3].Id, matchtests.NewEnhancedIOs[3].matchedsObject.Id);

        system.debug(matchtests.NewEnhancedIOs[4].matchedsObject.Id);
        system.debug(matchtests.NewEnhancedIOs[5].matchedsObject.Id);
        system.debug(matchtests.NewEnhancedIOs[6].matchedsObject.Id);



    }
}