@isTest
private class Petition_test {
	
    static testMethod void PetitionTestExistingContact() {
		//Create testaccount, campaign, lead and contact
		Account Testaccount = new Account(name = 'TestAccount');
		insert testaccount;
		Contact TestContact = new Contact(FirstName = 'Test', LastName = 'Contact', 
		email='testcontact@dontbotherme.org', MailingPostalCode = '22222', accountid = testaccount.id);
		insert testContact;
		Lead TestLead = new Lead(FirstName = 'Test', LastName = 'Lead', 
		email='testlead@dontbotherme.org', PostalCode = '22222', company = 'Lead, Test Household');
		insert testLead;
		Campaign testCampaign = new Campaign(name = 'TestCampaign');
		insert testCampaign;
		
		//CASE: Existing contact by email
		PageReference pageRef = new PageReference('/apex/petition_page1?MailingListName=Test_Mailing_List&cid=' + testCampaign.ID);
		Test.setCurrentPage(pageRef);
		Petition_Controller PC1 = new Petition_Controller();
		System.assertEquals(testCampaign.Id,PC1.camp.ID);
		PC1.getSigner();
		PC1.signer.FirstName = 'Test';
		PC1.signer.LastName = 'Contact';
		PC1.signer.Email = 'testcontact@dontbotherme.org';
		PC1.signer.MailingPostalCode = '11111';
		//PC1.getCamp();
		PC1.submit();
		system.assertEquals(testcontact.id, PC1.results[0]);
		system.assertEquals('Contact', PC1.results[1]);
		system.assertEquals(PC1.campmmbr.contactid,testcontact.id); 
		//system.assert();    
		pageRef = Page.petition_page2;
		Test.setCurrentPage(pageRef);
		// Mailing Lists is no longer blank
		PC1.OrgUpdates = true;
		PC1.OrgUpdates();
		system.assertEquals('Updates on Organization', PC1.tempContact.mailing_Lists__c.trim());
		
		string nextPage = PC1.goback().getURL();
		System.assertEquals('http://www.', nextPage.substring(0,11));
	}

//CASE 2: Contact signed up twice	
    static testMethod void PetitionTestDuplicateContact() {
		//Create testaccount, campaign, lead and contact
		Account Testaccount = new Account(name = 'TestAccount');
		insert testaccount;
		Contact TestContact = new Contact(FirstName = 'Test', LastName = 'Contact', 
		email='testcontact@dontbotherme.org', MailingPostalCode = '22222', accountid = testaccount.id);
		insert testContact;
		Lead TestLead = new Lead(FirstName = 'Test', LastName = 'Lead', 
		email='testlead@dontbotherme.org', PostalCode = '22222', company = 'Lead, Test Household');
		insert testLead;
		Campaign testCampaign = new Campaign(name = 'TestCampaign');
		insert testCampaign;
		
		//CASE: Existing contact by email
		PageReference pageRef = new PageReference('/apex/petition_page1?MailingListName=Test_Mailing_List&cid=' + testCampaign.ID);
		Test.setCurrentPage(pageRef);
		Petition_Controller PC1 = new Petition_Controller();
		System.assertEquals(testCampaign.Id,PC1.camp.ID);
		PC1.getSigner();
		PC1.signer.FirstName = 'Test';
		PC1.signer.LastName = 'Contact';
		PC1.signer.Email = 'testcontact@dontbotherme.org';
		PC1.signer.MailingPostalCode = '11111';
		//PC1.getCamp();
		PC1.submit();
		system.assertEquals(testcontact.id, PC1.results[0]);
		system.assertEquals('Contact', PC1.results[1]);
		system.assertEquals(PC1.campmmbr.contactid,testcontact.id); 
		//system.assert();    
		pageRef = Page.petition_page2;
		Test.setCurrentPage(pageRef);
		
// Add contact again
	PC1.Signer = new Contact();
		PC1.signer.FirstName = 'Test';
		PC1.signer.LastName = 'Contact';
		PC1.signer.Email = 'testcontact@dontbotherme.org';
		PC1.signer.MailingPostalCode = '11111';
    PC1.submit();
// Still one campaign member
	System.assertEquals(1,[select Id from CampaignMember where campaignID = :testCampaign.ID].size());

		
		
	}

	
	
    //CASE 3: Existing LEAD by email
    //Create testaccount, campaign, lead and contact
	static testMethod void PetitionTestExistingLead() {
    Account Testaccount = new Account(name = 'TestAccount');
	insert testaccount;
	Contact TestContact = new Contact(FirstName = 'Test', LastName = 'Contact', 
		email='testcontact@dontbotherme.org', MailingPostalCode = '22222', accountid = testaccount.id);
	insert testContact;
	Lead TestLead = new Lead(FirstName = 'Test', LastName = 'Lead', 
		email='testlead@dontbotherme.org', PostalCode = '22222', company = 'Lead, Test Household');
	insert testLead;
	Campaign testCampaign = new Campaign(name = 'TestCampaign');
	insert testCampaign;
	
	PageReference pageRef = new PageReference('/apex/petition_page1?MailingListName=Test_Mailing_List&cid=' + testCampaign.ID);
	Test.setCurrentPage(pageRef);
	Petition_Controller PC2 = new Petition_Controller();
	PC2.getSigner();
    PC2.signer.FirstName = 'Test';
    PC2.signer.LastName = 'Lead';
    PC2.signer.Email = 'testlead@dontbotherme.org';
    PC2.signer.MailingPostalCode = '11111';
    PC2.submit();
    system.assertEquals(testlead.id, PC2.results[0]);
    system.assertEquals('Lead', PC2.results[1]); 
    //system.assert();    
    pageRef = Page.petition_page2;
	Test.setCurrentPage(pageRef);
	PC2.OrgUpdates = true;
    PC2.OrgUpdates();
    system.assertEquals('Updates on Organization', [select id, mailing_Lists__c from Lead where email = 'testlead@dontbotherme.org'].mailing_Lists__c.trim());
	} // end PetitionTestExistingLead
		
    //CASE 4: Insert campaign member twice
    //Create testaccount, campaign, lead and contact
	static testMethod void PetitionTestDuplicateCampMmbrs() {
    Account Testaccount = new Account(name = 'TestAccount');
	insert testaccount;
	Contact TestContact = new Contact(FirstName = 'Test', LastName = 'Contact', 
		email='testcontact@dontbotherme.org', MailingPostalCode = '22222', accountid = testaccount.id);
	insert testContact;
	Lead TestLead = new Lead(FirstName = 'Test', LastName = 'Lead', 
		email='testlead@dontbotherme.org', PostalCode = '22222', company = 'Lead, Test Household');
	insert testLead;
	Campaign testCampaign = new Campaign(name = 'TestCampaign');
	insert testCampaign;
	
	PageReference pageRef = new PageReference('/apex/petition_page1?MailingListName=Test_Mailing_List&cid=' + testCampaign.ID);
	Test.setCurrentPage(pageRef);
	Petition_Controller PC3 = new Petition_Controller();
	PC3.getSigner();
    PC3.signer.FirstName = 'Test';
    PC3.signer.LastName = 'Lead';
    PC3.signer.Email = 'testlead@dontbotherme.org';
    PC3.signer.MailingPostalCode = '11111';
    PC3.submit();
    system.assertEquals(testlead.id, PC3.results[0]);
    system.assertEquals('Lead', PC3.results[1]); 
    //system.assert();    
    pageRef = Page.petition_page2;
	Test.setCurrentPage(pageRef);
	PC3.OrgUpdates = true;
    PC3.OrgUpdates();
    system.assertEquals('Updates on Organization', [select id, mailing_Lists__c from Lead where email = 'testlead@dontbotherme.org'].mailing_Lists__c.trim());
	// Find one campaign member
	System.assertEquals(1,[select Id from CampaignMember where campaignID = :testCampaign.ID].size());
	// Add lead again
	PC3.Signer = new Contact();
    PC3.signer.FirstName = 'Test';
    PC3.signer.LastName = 'Lead';
    PC3.signer.Email = 'testlead@dontbotherme.org';
    PC3.signer.MailingPostalCode = '11111';
    PC3.submit();
	// Still one campaign member
	System.assertEquals(1,[select Id from CampaignMember where campaignID = :testCampaign.ID].size());
	} // end PetitionTestExistingLead

    //CASE 5: Incorrect campaignID in URL
    //Create testaccount, campaign, lead and contact
	static testMethod void PetitionTestWrongCampaignID() {
		Account Testaccount = new Account(name = 'TestAccount');
		insert testaccount;
		Contact TestContact = new Contact(FirstName = 'Test', LastName = 'Contact', 
		email='testcontact@dontbotherme.org', MailingPostalCode = '22222', accountid = testaccount.id);
		insert testContact;
		Lead TestLead = new Lead(FirstName = 'Test', LastName = 'Lead', 
		email='testlead@dontbotherme.org', PostalCode = '22222', company = 'Lead, Test Household');
		insert testLead;
		Campaign testCampaign = new Campaign(name = 'TestCampaign');
		insert testCampaign;
		
		//Create an incorrect parameter as if a user had deleted some of the string by mistake
		String stringcampaignID = testCampaign.ID;
		stringcampaignID = stringcampaignID.substring(0,8);
		PageReference pageRef = new PageReference('/apex/petition_page1?MailingListName=Test_Mailing_List&cid=' + stringCampaignID);
		Test.setCurrentPage(pageRef);
		Petition_Controller PC5 = new Petition_Controller();
		PC5.getSigner();
		// Did Controller give error statement?
		System.assertEquals(true,PC5.WrongCampaignID);
	}
	
}