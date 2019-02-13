@istest
private class DataImportTestBaird
{
    
            
    @testSetup static void setup() {
    CreateCustomSettings CCS = new CreateCustomSettings();
    }

    static testMethod void TestEditCancelNewLead() 
    {
        ImportObject__c io = new ImportObject__c();
        io.Person_FirstName__c = 'Andy';
        io.Person_LastName__c = 'Roddick';
        io.Person_EmailPersonal__c = 'andy@ferl.com';        
        io.Person_PhoneMobile__c = '4323425345';
        io.Company_or_Organization__c = 'Fullerton';
        io.Address_StreetLine1__c = '14th State Drive';
        io.Address_City__c = 'Miami';
        io.Address_State__c = 'FL';
        io.Address_ZipCode__c = '33157';
        io.Address_Country__c = 'US';
        
        insert io;
          
        DataImport di = new DataImport();
        di.setList();
        
        di.records[0].Processed__c = true;
        
        di.edit();
        di.cancel();
        
        di.records[0].Processed__c = true;
        
        di.edit();
        di.save();
        
        di.records[0].Processed__c = true;
        
        di.process(); //Process the first time; creates new lead
        
        io.Processed__c = false;
        io.Contribution_Amount__c = 32;
        io.Contribution_TransactionDate__c = Date.today();
        io.Person_FullName__c = null;
        io.Campaign_Name__c = 'Test123456';
        io.Person_LegacyID__c = '123';
                
        update io;
        
        di.setList();
        
        di.records[0].Processed__c = true;
        
        di.process(); // Process the second time, with contribution, this converts lead to account and contact.
        
        // Is account address correct?
        
        System.AssertEquals('Fullerton', di.a.name,'Did not correctly create Account Name from Company'); // Error because a. is null
        // The lead was converted to account/contact, was account address populated with lead address?
        System.assertEquals(io.Address_StreetLine1__c, di.a.BillingStreet, 'Account Address is not being saved');       
        
        // accs = [ SELECT Id FROM Account WHERE Dear__c != NULL LIMIT 1];
        
        System.assertEquals(io.Person_FirstName__c, di.a.Dear__c, 'Account Dear__c is not being set to first name.');
        System.assertEquals(di.OppRTNameMap.get('Donation').getRecordTypeId(), di.o.RecordTypeId, 'Did not set OppRT to Donation which is default');
        
        io.Processed__c = false;
        io.Campaign_Name__c = 'Test1234567';        
        io.Company_or_Organization__c = 'Johnson';
        
        update io;
        
        di.setList();
        
        di.records[0].Processed__c = true;
        
        di.process();  
        
        io.Processed__c = false;
        io.Contribution_Amount__c = null;
        io.Person_LegacyID__c = '1234';
        io.Person_FirstName__c = 'Andres';
        io.Person_LastName__c = 'Rodditi';
        io.Person_EmailPersonal__c = 'andi@ferl.com';        
        io.Person_EmailWork__c = 'andy@ferl.com';
        io.Account_Name__c = 'General';
        
        update io;
        
        di.setList();
        
        di.records[0].Processed__c = true;
        
        di.process();
        
        System.assertEquals(io.Address_StreetLine1__c, di.a.BillingStreet);
        System.AssertEquals('General', di.a.Name,'Did not correctly create Account Name from Account_Name__c');
    }
/*    
static testMethod void RecordTypeInRecordTypeName() 
    {
        ImportObject__c io = new ImportObject__c();
        io.Person_FirstName__c = 'Andy';
        io.Person_LastName__c = 'Roddick';
        io.Person_EmailPersonal__c = 'andy@ferl.com';        
        io.Person_PhoneMobile__c = '4323425345';
        io.Company_or_Organization__c = 'Fullerton';
        io.Address_StreetLine1__c = '14th State Drive';
        io.Address_City__c = 'Miami';
        io.Address_State__c = 'FL';
        io.Address_ZipCode__c = '33157';
        io.Address_Country__c = 'US';
        
        insert io;
          
        DataImport di = new DataImport();
        di.setList();
        
        di.records[0].Processed__c = true;
        
        di.edit();
        di.cancel();
        
        di.records[0].Processed__c = true;
        
        di.edit();
        di.save();
        
        di.records[0].Processed__c = true;
        
        di.process();
        
        io.Processed__c = false;
        io.Contribution_Amount__c = 32;
        io.Contribution_RecordType__c = 'Service';
        io.Contribution_TransactionDate__c = Date.today();
        io.Person_FullName__c = null;
        io.Campaign_Name__c = 'Test123456';
        io.Person_LegacyID__c = '123';
                
        update io;
        
        di.setList();
        
        di.records[0].Processed__c = true;
        
        di.process();

        System.assertEquals([SELECT id from RecordType where Name = 'Service' limit 1].Id, di.o.RecordTypeId);
    }

static testMethod void RecordTypeInContributionType() 
    {
        ImportObject__c io = new ImportObject__c();
        io.Person_FirstName__c = 'Andy';
        io.Person_LastName__c = 'Roddick';
        io.Person_EmailPersonal__c = 'andy@ferl.com';        
        io.Person_PhoneMobile__c = '4323425345';
        io.Company_or_Organization__c = 'Fullerton';
        io.Address_StreetLine1__c = '14th State Drive';
        io.Address_City__c = 'Miami';
        io.Address_State__c = 'FL';
        io.Address_ZipCode__c = '33157';
        io.Address_Country__c = 'US';
        
        insert io;
          
        DataImport di = new DataImport();
        di.setList();
        
        di.records[0].Processed__c = true;
        
        di.edit();
        di.cancel();
        
        di.records[0].Processed__c = true;
        
        di.edit();
        di.save();
        
        di.records[0].Processed__c = true;
        
        di.process();
        
        io.Processed__c = false;
        io.Contribution_Amount__c = 32;
        io.Contribution_Type__c = 'Inkind for auction';
        io.Contribution_TransactionDate__c = Date.today();
        io.Person_FullName__c = null;
        io.Campaign_Name__c = 'Membership 2017';
        io.Person_LegacyID__c = '123';
                
        update io;
        
        di.setList();
        
        di.records[0].Processed__c = true;
        
        di.process();

        System.assertEquals([SELECT id from RecordType where Name = 'Inkind' limit 1].Id, di.o.RecordTypeId);
    }
    
    static testMethod void RecordTypeInCampaignName() 
    {
        ImportObject__c io = new ImportObject__c();
        io.Person_FirstName__c = 'Andy';
        io.Person_LastName__c = 'Roddick';
        io.Person_EmailPersonal__c = 'andy@ferl.com';        
        io.Person_PhoneMobile__c = '4323425345';
        io.Company_or_Organization__c = 'Fullerton';
        io.Address_StreetLine1__c = '14th State Drive';
        io.Address_City__c = 'Miami';
        io.Address_State__c = 'FL';
        io.Address_ZipCode__c = '33157';
        io.Address_Country__c = 'US';
        
        insert io;
          
        DataImport di = new DataImport();
        di.setList();
        
        di.records[0].Processed__c = true;
        
        di.edit();
        di.cancel();
        
        di.records[0].Processed__c = true;
        
        di.edit();
        di.save();
        
        di.records[0].Processed__c = true;
        
        di.process();
        
        io.Processed__c = false;
        io.Contribution_Amount__c = 32;
        io.Contribution_TransactionDate__c = Date.today();
        io.Person_FullName__c = null;
        io.Campaign_Name__c = 'Membership 2017';
        io.Person_LegacyID__c = '123';
                
        update io;
        
        di.setList();
        
        di.records[0].Processed__c = true;
        
        di.process();

        System.assertEquals([SELECT id from RecordType where Name = 'Membership' limit 1].Id, di.o.RecordTypeId);
    }
    
    static testMethod void ExistingContactUpdateAddress() 
    {
        
    //Create test contact
    Create_Test_Variables CTV = new Create_Test_Variables();
    Contact Testcontact = CTV.fetchTestContact();
        Testcontact.firstname = 'Test';
        Testcontact.mailingStreet = '1 Mailing St.';
        update Testcontact;
        system.debug('Testcontact is ' + Testcontact);
        system.assertEquals(Testcontact.email,'testcontact@dontbotherme.org');
        system.assertEquals(Testcontact.firstname,'Test');
        system.assertEquals(Testcontact.lastname,'TestContact');
        
        ImportObject__c io = new ImportObject__c();
        io.Person_FirstName__c = 'Test';
        io.Person_LastName__c = 'TestContact';
        io.Person_EmailPersonal__c = 'testcontact@dontbotherme.org';        
        io.Person_PhoneMobile__c = '4323425345';
        io.Company_or_Organization__c = '';
        io.Address_StreetLine1__c = '14th State Drive';
        io.Address_City__c = 'Miami';
        io.Address_State__c = 'FL';
        io.Address_ZipCode__c = '33157';
        io.Address_Country__c = 'US';
        
        insert io;
          
        DataImport di = new DataImport();
        di.setList();      
        di.process();
        
        io.Processed__c = false;
        io.Contribution_Amount__c = 32;
        io.Contribution_TransactionDate__c = Date.today();
        io.Contribution_RecordType__c = 'Membership';
        io.Person_FullName__c = null;
        io.Campaign_Name__c = 'Membership 2017';
        io.Person_LegacyID__c = '123';
                
        update io;
        
        di.setList();
        
        di.records[0].Processed__c = true;
        
        di.process();

        System.assertEquals(io.Address_StreetLine1__c, di.c.MailingStreet);
        System.assertEquals(io.Address_StreetLine1__c, di.ExistingAcct.BillingStreet,'When contact already exists, Account address is not updated as it should be.');
    }
    
    static testMethod void CatchNonCapitalizedNames() 
    {
        
    //Create test contact
    Create_Test_Variables CTV = new Create_Test_Variables();
    Contact Testcontact = CTV.fetchTestContact();
        
        ImportObject__c io = new ImportObject__c();
        io.Person_FirstName__c = 'test';
        io.Person_LastName__c = 'TESTCONTACT';
        io.Person_EmailPersonal__c = 'testcontact@dontbotherme.org';        
        io.Person_PhoneMobile__c = '4323425345';
        io.Company_or_Organization__c = '';
        io.Address_StreetLine1__c = '14th State Drive';
        io.Address_City__c = 'Miami';
        io.Address_State__c = 'FL';
        io.Address_ZipCode__c = '33157';
        io.Address_Country__c = 'US';
        
        insert io;
          
        DataImport di = new DataImport();
        di.setList();      
        di.process();
        
        io.Processed__c = false;
        io.Contribution_Amount__c = 32;
        io.Contribution_TransactionDate__c = Date.today();
        io.Contribution_RecordType__c = 'Membership';
        io.Person_FullName__c = null;
        io.Campaign_Name__c = 'Membership 2017';
        io.Person_LegacyID__c = '123';
                
        update io;
        
        di.setList();
        
        di.records[0].Processed__c = true;
        
        di.process();
		system.debug('di.c is ' + di.c);
        Contact resultcontact = [select id, lastname, firstname from Contact where id = :di.c.Id];
        system.assertEquals('Test',resultcontact.firstname);
        system.assertEquals('Testcontact',resultcontact.lastname);
        // Why don't these two lines work?  Error is that I haven't retrieve firstname and lastname via SOQL.  But why?  Would prefer not to rely on SOQL query.
        // System.assertEquals('Test', di.c.Firstname);
        // System.assertEquals('Testcontact', di.c.Lastname);
    }
    
    static testMethod void ProcessMultipleIOs() 
    {
	
//Wrap the test in system.runas so that it doesn't object to mixed DML (from setup and non-setup objects)		
	User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
	System.runAs ( thisUser ) {
        
    //Create test contact
    Create_Test_Variables CTV = new Create_Test_Variables();
    Contact Testcontact = CTV.fetchTestContact();

        
        List<ImportObject__c> ios = new List<ImportObject__c>();
        for (integer i=0;i<3;i++) {
        DateTime ContribDate = system.today().addyears(-1);
        ImportObject__c IO = new ImportObject__c(
        Person_FirstName__c = 'test',
        Person_LastName__c = 'TESTCONTACT',
        Person_EmailPersonal__c = 'testcontact@dontbotherme.org',       
        Person_PhoneMobile__c = '4323425345',
        Company_or_Organization__c = '',
        Address_StreetLine1__c = '14th State Drive',
        Address_City__c = 'Miami',
        Address_State__c = 'FL',
        Address_ZipCode__c = '33157',
        Address_Country__c = 'US',
        // Processed__c = null,
        Contribution_Amount__c = 100,
        Contribution_TransactionDate__c = Date.today().addyears(-i),
        Contribution_RecordType__c = 'Membership',
        Person_FullName__c = null,
        Campaign_Name__c = 'Membership');  
            IOs.add(io);
        }        
        insert ios;
          
        DataImport di = new DataImport();
        di.setList();      
        di.process();
		
        // The next line selects each record for processing
        for (integer i=0; i<3; i++) di.records[i].Processed__c = true;
            
        di.process();
        
        Account resultaccount = [select id, name, (select Amount from Opportunities), Account_Membership_Expires__c from Account limit 1];
        system.debug('resultaccount should have 10 contribs: ' + resultaccount);
        system.assertEquals('TestAccount',resultaccount.name);
        decimal totalAmount = 0.00;
        for (Opportunity o : resultaccount.Opportunities) totalAmount += o.Amount;
        system.assertEquals(300, totalAmount);
    }
    }    
 */    
}