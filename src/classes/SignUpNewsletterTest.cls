@isTest
private class SignUpNewsletterTest {
	static testMethod void SignUpNewsletterContact() {

		Create_Test_Variables ctv = new Create_Test_Variables();
		Account testacct = ctv.fetchTestAccount();
		Contact testctct = ctv.fetchTestContact();
		List<String> person = new List<String>();
		person.add(testctct.Id);
		person.add('Contact');
		person.add('no match');
		SignUpNewsletter.SignUpNewsletter(person);
		System.assertEquals('enewsletter',[select id, mailing_lists__c from contact
			where id = :testctct.Id][0].mailing_lists__c);

	} // end SignupNewsletterContact()
	
	static testMethod void SignupNewsletterLead() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Lead testlead = ctv.fetchTestLead();
		List<String> person = new List<String>();
		person.add(testlead.Id);
		person.add('Lead');
		person.add('no match');
		SignUpNewsletter.SignUpNewsletter(person);
		System.assertEquals('enewsletter',[select id, mailing_lists__c from lead
			where id = :testlead.Id][0].mailing_lists__c);
	

	} // end SignupNewsletterLead()
	
static testMethod void SignUpNewsletterContactExistingList() {

		Create_Test_Variables ctv = new Create_Test_Variables();
		Account testacct = ctv.fetchTestAccount();
		Contact testctct = ctv.fetchTestContact();
		testctct.mailing_lists__c = 'WGWA enewsletter';
		update testctct;
		List<String> person = new List<String>();
		person.add(testctct.Id);
		person.add('Contact');
		person.add('no match');
		SignUpNewsletter.SignUpNewsletter(person);
		System.assertEquals('WGWA enewsletter',[select id, mailing_lists__c from contact
		where id = :testctct.Id][0].mailing_lists__c);

} // end SignupNewsletterContact()
	
	static testMethod void SignupNewsletterLeadExistingList() {
	User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		Create_Test_Variables ctv = new Create_Test_Variables();
		Lead testlead = ctv.fetchTestLead();
		testlead.mailing_lists__c = 'WGWA enewsletter';
		update testlead;
		List<String> person = new List<String>();
		person.add(testlead.Id);
		person.add('Lead');
		person.add('no match');
		SignUpNewsletter.SignUpNewsletter(person);
		System.assertEquals('WGWA enewsletter',[select id, mailing_lists__c from lead
			where id = :testlead.Id][0].mailing_lists__c);

	} // end SignupNewsletterLead()	

	static testMethod void SignUpNewsletterContactNewList() {
	User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
	system.runAs(thisUser) {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account testacct = ctv.fetchTestAccount();
		Contact testctct = ctv.fetchTestContact();
		testctct.mailing_lists__c = 'other enewsletter';
		update testctct;
		List<String> person = new List<String>();
		person.add(testctct.Id);
		person.add('Contact');
		person.add('no match');
		SignUpNewsletter.SignUpNewsletter(person);
		System.assertEquals(true, [
				select id, mailing_lists__c
				from contact
				where id = :testctct.Id
		][0].mailing_lists__c.contains('other enewsletter'));
		System.assertEquals(true, [
				select id, mailing_lists__c
				from contact
				where id = :testctct.Id
		][0].mailing_lists__c.contains('enewsletter'));
	}
	} // end SignupNewsletterContactNewList()
	
	static testMethod void SignupNewsletterLeadNewList() {
	User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
	system.runAs(thisUser) {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Lead testlead = ctv.fetchTestLead();
		testlead.mailing_lists__c = 'other newsletter';
		update testlead;
		List<String> person = new List<String>();
		person.add(testlead.Id);
		person.add('Lead');
		person.add('no match');
		SignUpNewsletter.SignUpNewsletter(person);
		System.assertEquals(true,[select id, mailing_lists__c from lead
			where id = :testlead.Id][0].mailing_lists__c.contains('enewsletter'));
		System.assertEquals(true,[select id, mailing_lists__c from lead
			where id = :testlead.Id][0].mailing_lists__c.contains('other newsletter'));
	
	} // end runas(thisUser)
	} // end SignupNewsletterLeadNewList()
	
	static testMethod void SignupNewsletterNotCtctorLead() {
	User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
	system.runAs(thisUser) {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Lead testlead = ctv.fetchTestLead();
		testlead.mailing_lists__c = 'other enewsletter';
		update testlead;
		List<String> person = new List<String>();
		person.add(testlead.Id);
		person.add('Error');
		person.add('no match');
		system.assertEquals(null,SignUpNewsletter.SignUpNewsletter(person));
	
	} // end runas(thisUser)
	} // end SignupNewsletterLeadNewList()


}