@istest
private class IdentifyPersonTest{
	static testMethod void ContactEmailAndNameMatch() {
		// Create account, contact, lead
	    Account Testaccount = new Account (name='TestAccount');
        insert Testaccount;
        Contact TestContact = new Contact (firstname='Test', lastname='TestContact', email='testcontact@dontbotherme.org', accountID = TestAccount.ID);
        insert Testcontact;
        Lead TestLead = new Lead (lastname = 'Lead', firstname = 'Test', company = 'None', email = 'testlead@dontbotherme.org');
        insert TestLead;
		List<String> results;
	    Contact signer = new contact(firstname='Test', lastname='TestContact', Email='TestContact@dontbotherme.org');

		IdentifyPerson IP1 = new IdentifyPerson();
		results = identifyperson.identifyperson(signer);
		System.assertEquals(results[0],TestContact.Id);
        System.assertEquals(results[3],TestAccount.Id);
	} // End ContactEmailMatch()
	
	static testMethod void ContactEmailMatchDifferentName() {
		// Create account, contact, lead
	    Account Testaccount = new Account (name='TestAccount');
        insert Testaccount;
        Contact TestContact = new Contact (firstname='Test', lastname='TestContact', email='testcontact@dontbotherme.org', accountID = TestAccount.ID);
        insert Testcontact;
        Lead TestLead = new Lead (lastname = 'Lead', firstname = 'Test', company = 'None', email = 'testlead@dontbotherme.org');
        insert TestLead;
		List<String> results;
	    Contact signer = new contact(firstname='Test1', lastname='TestContact', Email='TestContact@dontbotherme.org');

		IdentifyPerson IP2= new IdentifyPerson();
		results = identifyperson.identifyperson(signer);
		System.assertEquals(results[0],TestContact.Id);
		System.assertEquals(results[2],'match on email not name');
	} // End ContactEmailMatchDifferentName()
	
	static testMethod void LeadEmailAndNameMatch() {
		// Create account, contact, lead
	    Account Testaccount = new Account (name='TestAccount');
        insert Testaccount;
        Contact TestContact = new Contact (firstname='Test', lastname='TestContact', email='testcontact@dontbotherme.org', accountID = TestAccount.ID);
        insert Testcontact;
        Lead TestLead = new Lead (lastname = 'Lead', firstname = 'Test', company = 'None', email = 'testlead@dontbotherme.org');
        insert TestLead;
		List<String> results;
	    Contact signer = new contact(firstname='Test', lastname='Lead', Email='TestLead@dontbotherme.org');

		IdentifyPerson IP3 = new IdentifyPerson();
		results = identifyperson.identifyperson(signer);
		System.assertEquals(results[0],TestLead.Id);
		System.assertEquals(results[2],'match on email and name');
	} // End LeadEmailMatch()	
		
	static testMethod void LeadEmailMatchDifferentName() {
		// Create account, contact, lead
	    Account Testaccount = new Account (name='TestAccount');
        insert Testaccount;
        Contact TestContact = new Contact (firstname='Test', lastname='TestContact', email='testcontact@dontbotherme.org', accountID = TestAccount.ID);
        insert Testcontact;
        Lead TestLead = new Lead (lastname = 'Lead', firstname = 'Test', company = 'None', email = 'testlead@dontbotherme.org');
        insert TestLead;
		List<String> results;
	    Contact signer = new contact(firstname='Test1', lastname='Lead', Email='TestLead@dontbotherme.org');

		IdentifyPerson IP4 = new IdentifyPerson();
		results = identifyperson.identifyperson(signer);
		System.assertEquals(results[0],TestLead.Id);
		System.assertEquals(results[2],'match on email not name');
	} // End LeadEmailMatch()	

	static testMethod void ContactNameAndZipMatch() {
		// Create account, contact, lead
	    Account Testaccount = new Account (name='TestAccount');
        insert Testaccount;
        Contact TestContact = new Contact (firstname='Test', lastname='TestContact', email='testcontact@dontbotherme.org', 
			Mailingpostalcode='22222', accountID = TestAccount.ID);
        insert Testcontact;
        Lead TestLead = new Lead (lastname = 'Lead', firstname = 'Test', company = 'None', email = 'testlead@dontbotherme.org');
        insert TestLead;
		List<String> results;
	    Contact signer = new contact(firstname='Test', lastname='TestContact', Email='TestContact1@dontbotherme.org',
			Mailingpostalcode='22222');

		IdentifyPerson IP5 = new IdentifyPerson();
		results = identifyperson.identifyperson(signer);
		System.assertEquals(results[0],TestContact.Id);
		System.assertEquals(results[1],'Contact');
		System.assertEquals(results[2],'match on name and zip');
	} // End ContactNameAndZipMatch()
	
	
	static testMethod void LeadNameAndZipMatch() {
		// Create account, contact, lead
	    Account Testaccount = new Account (name='TestAccount');
        insert Testaccount;
        Contact TestContact = new Contact (firstname='Test', lastname='TestContact', email='testcontact@dontbotherme.org', 
			MailingPostalcode='22222', accountID = TestAccount.ID);
        insert Testcontact;
        Lead TestLead = new Lead (lastname = 'Lead', firstname = 'Test', company = 'None', Postalcode='22222',
			email = 'testlead@dontbotherme.org');
        insert TestLead;
		List<String> results;
	    Contact signer = new contact(firstname='Test', lastname='Lead', Email='TestContact1@dontbotherme.org',
			MailingPostalcode='22222');

		IdentifyPerson IP6 = new IdentifyPerson();
		results = identifyperson.identifyperson(signer);
		System.assertEquals(results[0],TestLead.Id);
		System.assertEquals(results[1],'Lead');
		System.assertEquals(results[2],'match on name and zip');
	} // End LeadNameAndZipMatch()
	
		static testMethod void NoMatch() {
		// Create account, contact, lead
	    Account Testaccount = new Account (name='TestAccount');
        insert Testaccount;
        Contact TestContact = new Contact (firstname='Test', lastname='TestContact', email='testcontact@dontbotherme.org', 
			MailingPostalcode='22222', accountID = TestAccount.ID);
        insert Testcontact;
        Lead TestLead = new Lead (lastname = 'Lead', firstname = 'Test', company = 'None', Postalcode='22222',
			email = 'testlead@dontbotherme.org');
        insert TestLead;
		List<String> results;
	    Contact signer = new contact(firstname='Test', lastname='Lead', Email='TestContact1@dontbotherme.org',
			MailingPostalcode='22223');

		IdentifyPerson IP7 = new IdentifyPerson();
		results = identifyperson.identifyperson(signer);
		System.assertEquals(results,null);
	} // End NoMatch()
}