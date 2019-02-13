@isTest
private class AddresseeUpdateTest {
	static testMethod void AccountNoContact() {
		Account testacct = new Account(
		name = 'Test Account'); 
		
		insert testacct;
		Set<account> testSet = new Set<account>();
		testSet.add(testacct);
		
	ApexPages.StandardController sc = new ApexPages.StandardController(testacct);
	AddresseeUpdateController AUC1 = new AddresseeUpdateController(sc);
	AUC1.updateAddressee(testSet);
	System.assertEquals('Test Account', [select addressee__c from Account where id = :testacct.id].addressee__c);	
	}
	
static testMethod void AccountOneContact() {
		Account testacct = new Account(
		name = 'Test Account'); 		
		insert testacct;
		Contact testctct = new Contact(
			lastname = 'Contact',
			firstname = 'Test',
			accountid = testacct.Id);
		insert testctct;
		Set<account> testSet = new Set<account>();
		testSet.add(testacct);
		
	ApexPages.StandardController sc = new ApexPages.StandardController(testacct);
	AddresseeUpdateController AUC2 = new AddresseeUpdateController(sc);
	AUC2.updateAddressee(testSet);
	System.assertEquals('Test Contact', [select addressee__c from Account where id = :testacct.id].addressee__c);	
	}

static testMethod void FamilyAccountTwoContacts(){
		Account testacct = new Account(
		name = 'Test Account',
		recordTypeid = [select id from recordType where name = 'Family'][0].id); 		
		insert testacct;
		Contact testctct1 = new Contact(
			lastname = 'Contact1',
			firstname = 'Test',
			accountid = testacct.Id);
		insert testctct1;
		Contact testctct2 = new Contact(
			lastname = 'Contact2',
			firstname = 'Test',
			accountid = testacct.Id);
		insert testctct2;
		AccountContactRole ACR2 = new AccountContactRole(
			contactid = testctct2.Id,
			role = 'Second',
			isPrimary = false,
			accountid = testacct.Id);
		insert ACR2;
		Set<account> testSet = new Set<account>();
		testSet.add(testacct);
		
	ApexPages.StandardController sc = new ApexPages.StandardController(testacct);
	AddresseeUpdateController AUC3 = new AddresseeUpdateController(sc);
	AUC3.updateAddressee(testSet);
	System.assertEquals('Test Contact1 and Test Contact2', [select addressee__c from Account where id = :testacct.id].addressee__c);	
	}

static testMethod void OtherAccountTwoContacts(){
		Account testacct = new Account(
		name = 'Test Account',
		recordTypeid = [select id from recordType where name = 'Business'][0].id); 		
		insert testacct;
		Contact testctct1 = new Contact(
			lastname = 'Contact1',
			firstname = 'Test',
			accountid = testacct.Id);
		insert testctct1;
		Contact testctct2 = new Contact(
			lastname = 'Contact2',
			firstname = 'Test',
			accountid = testacct.Id);
		insert testctct2;
		AccountContactRole ACR2 = new AccountContactRole(
			contactid = testctct2.Id,
			role = 'Second',
			isPrimary = false,
			accountid = testacct.Id);
		insert ACR2;
		Set<account> testSet = new Set<account>();
		testSet.add(testacct);
		
	ApexPages.StandardController sc = new ApexPages.StandardController(testacct);
	AddresseeUpdateController AUC3 = new AddresseeUpdateController(sc);
	AUC3.updateAddressee(testSet);
	System.assertEquals('Test Contact1', [select addressee__c from Account where id = :testacct.id].addressee__c);	
	}
}