@isTest
private class ConvertLeadToContactTest {

	//test when the company name equals an existing account
	static testMethod void ConvertLeadToContactTest1() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account TestAcct = ctv.fetchTestAccount();
		//insert TestAcct;
		Lead TestLead = ctv.fetchTestLead();
		TestLead.Company = 'TestAccount';
		update TestLead;
		List<Id> Results = ConvertLeadToContact.ConvertLeadToContact(TestLead.Id);
        Id TestCtctid = Results[0];
		System.assertEquals('TestAccount',[SELECT Id,Name from Account where Id = :[select Id,AccountId from Contact where Id = :TestCtctid].AccountId].Name);
	} // end test1

		//test when the company name blank and household created
	static testMethod void ConvertLeadToContactTest2() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account TestAcct = ctv.fetchTestAccount();
		//insert TestAcct;
		Lead TestLead = ctv.fetchTestLead();
		TestLead.Company = 'none';
		update TestLead;
		List<Id> Results = ConvertLeadToContact.ConvertLeadToContact(TestLead.Id);
        Id TestCtctid = Results[0];
		System.assertEquals('TestLead, Lead Household',[select Id,Name from Account where Id = :[select Id,AccountId from Contact where Id = :TestCtctid].AccountId].Name);
	} // end test1

	//test when the company name is 'not provided' and should be replaced with household name
	@isTest
	private static void ConvertLeadToContactTest3() {
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account TestAcct = ctv.fetchTestAccount();
		//insert TestAcct;
		Lead TestLead = ctv.fetchTestLead();
		TestLead.Company = 'not provided';
		update TestLead;
		ConvertLeadToContactBulk convertinbulk = new ConvertLeadToContactBulk();
		convertinbulk.ConvertLeadToContact(new List<Lead> {TestLead});

		System.debug(convertinbulk.LeadtoAccountMap);
		System.debug(convertinbulk.LeadtoContactMap);
		List<Account> aConfirm = [select Id,Name from Account where Id = :convertinbulk.AccountToLeadMap.keySet()];
		System.assertEquals(1, aConfirm.size());
		System.assertEquals('TestLead, Lead Household',aConfirm[0].Name);

	} // end test3

}