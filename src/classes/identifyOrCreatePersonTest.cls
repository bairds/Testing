// Baird checked May 2015, it filters out email = null
// Sept 29 2016 Baird updates to set Lead.Addressee__c and Dear__c
@isTest
private class identifyOrCreatePersonTest {

    static testMethod void NewPerson() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account Testacct = ctv.fetchTestAccount();
		
	IdentifyOrCreatePerson IOCP1 = new identifyOrCreatePerson();
	Contact pcontact = new Contact(
		accountid = Testacct.Id,
		firstname = 'Test',
		lastname = 'Tester',
		Email = 'Test@tester.org',
		MailingPostalCode = '33333');
	List<string> results = identifyOrCreatePerson.identifyOrCreatePerson(pcontact);
		System.debug('results is ' + results);
	List<lead> checkResult = [select id, lastname, PostalCode, Dear__c, Addressee__c from Lead
		where id = :results[0]];
	System.assertEquals('Tester',checkResult[0].lastname);
	System.assertEquals('33333',checkResult[0].PostalCode);
	System.assertEquals('Test',checkResult[0].Dear__c);
	System.assertEquals('Test Tester',checkResult[0].Addressee__c);
    }
	
    static testMethod void ExistingContactbyEmail() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account Testacct = ctv.fetchTestAccount();
		Contact Testctct = ctv.fetchTestContact();
		
	IdentifyOrCreatePerson IOCP1 = new identifyOrCreatePerson();
	Contact pcontact = new Contact(
		accountid = Testacct.Id,
		firstname = 'Test',
		lastname = 'TestContact',
		Email = 'testcontact@dontbotherme.org',
		MailingPostalCode = '33333');
	List<string> results = identifyOrCreatePerson.identifyOrCreatePerson(pcontact);
		System.debug('results is ' + results);
	List<Contact> checkResult = [select id, lastname, MailingPostalCode from Contact
		where id = :results[0]];
	System.assertEquals('TestContact',checkResult[0].lastname);
		// does it update the postal code?
	System.assertEquals('33333',checkResult[0].MailingPostalCode);
    }
	
    static testMethod void ExistingContactbyNameAndZip() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account Testacct = ctv.fetchTestAccount();
		Contact Testctct = ctv.fetchTestContact();
		Testctct.MailingPostalCode = '33333';
		Testctct.FirstName = 'Test';
		update Testctct;
		
	IdentifyOrCreatePerson IOCP1 = new identifyOrCreatePerson();
	Contact pcontact = new Contact(
		accountid = Testacct.Id,
		firstname = 'Test',
		lastname = 'TestContact',
		Email = 'nottestcontact@dontbotherme.org',
		MailingStreet = 'Test Street',
		MailingPostalCode = '33333');
	List<string> results = identifyOrCreatePerson.identifyOrCreatePerson(pcontact);
		System.debug('results is ' + results);
	List<Contact> checkResult = [select id, lastname, MailingStreet from Contact
		where id = :results[0]];
	System.assertEquals('TestContact',checkResult[0].lastname);
		// does it update the postal code?
	System.assertEquals('Test Street',checkResult[0].MailingStreet);
    }

	static testMethod void ExistingLeadbyEmail() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account Testacct = ctv.fetchTestAccount();
		Lead Testlead = ctv.fetchTestLead();
		
	IdentifyOrCreatePerson IOCP1 = new identifyOrCreatePerson();
	Contact pcontact = new Contact(
		accountid = Testacct.Id,
		firstname = 'Test',
		lastname = 'TestLead',
		Email = 'testlead@dontbotherme.org',
		MailingPostalCode = '33333');
	List<string> results = identifyOrCreatePerson.identifyOrCreatePerson(pcontact);
		System.debug('results is ' + results);
	List<Lead> checkResult = [select id, lastname, PostalCode from Lead
		where id = :results[0]];
	System.assertEquals('TestLead',checkResult[0].lastname);
		// does it update the postal code?
	System.assertEquals('33333',checkResult[0].PostalCode);
    }

	static testMethod void ExistingLeadbNameAndZip() {
	Create_Test_Variables ctv = new Create_Test_Variables();
	Account Testacct = ctv.fetchTestAccount();
	Lead Testlead = ctv.fetchTestLead();
	TestLead.PostalCode = '33333';
	TestLead.Firstname = 'Test';
    TestLead.Email = null;
	update TestLead;
		
	IdentifyOrCreatePerson IOCP1 = new identifyOrCreatePerson();
	Contact pcontact = new Contact(
		accountid = Testacct.Id,
		firstname = 'Test',
		lastname = 'TestLead',
		Email = 'nottestlead@dontbotherme.org',
		MailingStreet = 'Test Street',
		MailingPostalCode = '33333');
	List<string> results = identifyOrCreatePerson.identifyOrCreatePerson(pcontact);
		System.debug('results is ' + results);
	List<Lead> checkResult = [select id, lastname, Street, Dear__c, Addressee__c from Lead
		where id = :results[0]];
	System.assertEquals('TestLead',checkResult[0].lastname);
		// does it update the postal code?
	System.assertEquals('Test Street',checkResult[0].Street);
        // Does it update Lead.Dear__c and ADdressee__c
	System.assertEquals('Test',checkResult[0].Dear__c);
	System.assertEquals('Test TestLead',checkResult[0].Addressee__c);
    }

    // In case of no email, should not match against other contact with no email.
    // It should continue on and match against firstlastzip.
	static testMethod void ExistingCtctNameAndZipNoEmail() {
	Create_Test_Variables ctv = new Create_Test_Variables();
	Account Testacct = ctv.fetchTestAccount();
	Contact TestCtct1 = ctv.fetchTestContact();
	TestCtct1.MailingPostalCode = '33332';
	TestCtct1.Firstname = 'Test';
    TestCtct1.Lastname = '[No Last Name]';
    TestCtct1.Email = null;
    TestCtct1.Accountid = Testacct.id;
	update TestCtct1;
        system.debug('FirstLastZip1 is ' + TestCtct1.Firstname+TestCtct1.Lastname+TestCtct1.MailingPostalCode);
    Contact TestCtct2 = ctv.fetchTestContact();
	TestCtct2.MailingPostalCode = '33333';
	TestCtct2.Firstname = 'Test';
	TestCtct2.LastName = 'TestCtct';
	TestCtct2.Accountid = Testacct.id;
    TestCtct2.Phone = '444-4444';
    TestCtct2.Email = 'test2@test.com';
	update TestCtct2;
        system.debug('FirstLastZip2 is ' + TestCtct2.Firstname+TestCtct2.Lastname+TestCtct2.MailingPostalCode);
		
	IdentifyOrCreatePerson IOCP2 = new identifyOrCreatePerson();
	Contact pcontact = new Contact(
		accountid = Testacct.Id,
        Email = null,
		firstname = 'Test',
		lastname = 'TestCtct',
		MailingStreet = 'Test Street',
		MailingPostalCode = '33333');
        system.debug('FirstLastZip of new contact is ' + pcontact.Firstname+pcontact.Lastname+pcontact.MailingPostalCode);
	List<string> results = identifyOrCreatePerson.identifyOrCreatePerson(pcontact);
		System.debug('results is ' + results);
	List<Contact> checkResult = [select id, lastname, Accountid, Phone from Contact
		where id = :results[0]];
	System.assertEquals('TestCtct',checkResult[0].lastname);
		// does it update the postal code from TestLead2, skipping TestLead1?
        System.assertEquals('444-4444',checkResult[0].phone);
        System.assertEquals(TestAcct.id,checkResult[0].Accountid);
    }
  // In case of no email, should not match against other lead with no email.
    // It should continue on and match against firstlastzip.
  static testMethod void ExistingLeadNameAndZipNoEmail() {
  Create_Test_Variables ctv = new Create_Test_Variables();
  Account Testacct = ctv.fetchTestAccount();
  Lead Testlead1 = ctv.fetchTestLead();
  TestLead1.PostalCode = '33332';
  TestLead1.Firstname = 'Test';
    TestLead1.Lastname = '[No Last Name]';
    TestLead1.Email = '';
  update TestLead1;
        system.debug('FirstLastZip1 is ' + TestLead1.Firstname+TestLead1.Lastname+TestLead1.PostalCode);
    Lead Testlead2 = ctv.fetchTestLead();
  TestLead2.PostalCode = '33333';
  TestLead2.Firstname = 'Test';
  TestLead2.LastName = 'TestLead';
  TestLead2.Company = 'TestCompany';
    TestLead2.Phone = '444-4444';
    TestLead2.Email = 'test2@test.com';
  update TestLead2;
        system.debug('FirstLastZip2 is ' + TestLead2.Firstname+TestLead2.Lastname+TestLead2.PostalCode);
    
  IdentifyOrCreatePerson IOCP2 = new identifyOrCreatePerson();
  Contact pcontact = new Contact(
    accountid = Testacct.Id,
        Email = null,
    firstname = 'Test',
    lastname = 'TestLead',
    MailingStreet = 'Test Street',
    MailingPostalCode = '33333');
        system.debug('FirstLastZip of new contact is ' + pcontact.Firstname+pcontact.Lastname+pcontact.MailingPostalCode);
  List<string> results = identifyOrCreatePerson.identifyOrCreatePerson(pcontact);
    System.debug('results is ' + results);
  List<Lead> checkResult = [select id, lastname, Company, Phone from Lead
    where id = :results[0]];
  System.assertEquals('TestLead',checkResult[0].lastname);
    // does it update the postal code from TestLead2, skipping TestLead1?
        System.assertEquals('444-4444',checkResult[0].phone);
        System.assertEquals('TestCompany',checkResult[0].company);
    }
	
}