@isTest
private class recalcGivingBatchTest {

   static testMethod void recalcGivingBatchTest()	{
   	
//INSERT Donations for TestContact
  	Opportunity[] CYOps;
    Opportunity[] LYOps;
    Opportunity[] YBLOps;
    Opportunity[] AncientOps;
    Opportunity AncientOp;
    Opportunity AncientOp2;
    Campaign Testcampaign = new Campaign();
    Testcampaign.name = 'Testcampaign';
    //Testcampaign.RecordtypeID = [select id from recordtype where name = 'Fundraising Activity'].id;
    insert Testcampaign;
    Account Testaccount = new Account (name='TestAccount');
    insert Testaccount;
    Contact TestContact = new Contact (firstname='Test', lastname='TestContact', email='testcontact@dontbotherme.org', accountID = TestAccount.ID);
    insert Testcontact;
    
//insert current year donations
    CYOps = new Opportunity[3];
   //CYOCRs = new OpportunityContactRole[3];
    for (Integer I = 0; I < 3; I++) {
    	CYOps[I] = new Opportunity(name = 'Test ' + I,
    	amount = 100,
    	campaignID = Testcampaign.ID,
    	accountID = Testaccount.ID,
    	contact__c = TestContact.ID,
    	recordTypeID = [select id from RecordType where name = 'Donation'].id,
    	stageName = 'Closed Won',
    	closeDate = system.today());
	    }
	    insert CYOps;
/*    for (Integer I = 0; I < 3; I++) {
    	CYOCRs[I] = new OpportunityContactRole(
        ContactId = CYOps[I].Contact__c,
        IsPrimary=TRUE,
        OpportunityId=CYOps[I].id,
        Role='Contributor');
   		} 
	    insert CYOCRs; */
    
//insert last year donations
    LYOps = new Opportunity[2];
    for (Integer I = 0; I < 2; I++) {
    	LYOps[I] = new Opportunity(name = 'Test ' + I,
    	amount = 100,
    	campaignID = Testcampaign.ID,
    	accountID = Testaccount.ID,
    	contact__c = TestContact.ID,
    	recordTypeID = [select id from RecordType where name = 'Donation'].id,
    	stageName = 'Closed Won',
    	closeDate = system.today()-365);
    	}
    	insert LYOps;
    	
//insert year before last donations
    YBLOps = new Opportunity[2];
    for (Integer I = 0; I < 2; I++) {
    	YBLOps[I] = new Opportunity(name = 'Test ' + I,
    	amount = 100,
    	campaignID = Testcampaign.ID,
    	accountID = Testaccount.ID,
    	contact__c = TestContact.ID,
    	stageName = 'Closed Won',
    	closeDate = system.today()-730);
    	}   
    insert YBLOps;
  
//insert ancient donations
	AncientOps = new Opportunity[2];
    for (Integer I = 0; I < 2; I++) {
    	AncientOps[I] = new Opportunity(name = 'Test Ancient ' + I,
    	amount = 500,
    	campaignID = Testcampaign.ID,
    	accountID = Testaccount.ID,
    	contact__c = TestContact.ID,
    	stageName = 'Closed Won',
    	closeDate = system.today()-1500);
    	}   
    insert AncientOps;
/*    

//invoke contribTotals() to see whether the method works
	List<contact> contacts = [Select Id, LastName, (select OpportunityID, Opportunity.CloseDate, Opportunity.Amount from OpportunityContactRoles where Opportunity.IsWon = true Order by Opportunity.CloseDate DESC) from contact WHERE LastName like '%test%' ORDER BY LastName Limit 200];		
	List<contact> contactResults = new List<Contact>();	
	recalcGivingBatch rGB = new recalcGivingBatch();
For (Contact c : contacts) {
    c = rGB.contribTotals(c);
    contactResults.add(c);
    }
    update contactResults;
    //tests for the method
		system.assertEquals(1200,[select id, lifetime_Giving__c from Contact where
	    	lastname = 'TestContact'].lifetime_Giving__c);
	    system.assertEquals(100,[select id, last_Contrib_Amt__c from Contact where
	    	lastname = 'TestContact'].last_Contrib_Amt__c);
	    system.assertEquals(system.today(),[select id, last_Contrib_Date__c from Contact where
	    	lastname = 'TestContact'].last_Contrib_Date__c);
	    system.assertEquals(500, [select id, largest_Contrib_Amt__c from Contact where
	    	lastname = 'TestContact'].largest_Contrib_Amt__c);
	    system.assertEquals(system.today() - 1500, [select id, Largest_Contrib_Date__c from 
	    	Contact where lastname = 'TestContact'].Largest_Contrib_Date__c);
	    system.assertEquals(300, [select id, YeartoDate_Giving__c from 
	    	Contact where lastname = 'TestContact'].YeartoDate_Giving__c);
	    system.assertEquals(200, [select id, Last_Year_Giving__c from 
	    	Contact where lastname = 'TestContact'].Last_Year_Giving__c);
	    system.assertEquals(200, [select id, Year_Before_Last_Giving__c from 
	    	Contact where lastname = 'TestContact'].Year_Before_Last_Giving__c);	
*/	    
//invoke the method via the Batch recalcGivingBatch just for Contacts where lastname contains 'Test'
//in order to make sure we're under the 200 limit and thus we can test the results   	
		recalcGivingBatch rGB = new recalcGivingBatch();
		rGB.query = 'Select Id, LastName, (select OpportunityID, Opportunity.CloseDate, Opportunity.Amount from OpportunityContactRoles where Opportunity.IsWon = true Order by Opportunity.CloseDate DESC) from contact WHERE ID = \'' + TestContact.ID + '\' ORDER BY LastName Limit 200';	
		Test.startTest();
		Database.executeBatch(rGB, 200);
		Test.stopTest();
		
//PUT ALL THESE IN ONE SINGLE QUERY.
//test to see whether giving history for TestContact has been updated		
	system.assertEquals(1700,[select id, lifetime_Giving__c from Contact where
    	id = :TestContact.id].lifetime_Giving__c);
    system.assertEquals(100,[select id, last_Contrib_Amt__c from Contact where
    	lastname = 'TestContact'].last_Contrib_Amt__c);
    system.assertEquals(system.today(),[select id, last_Contrib_Date__c from Contact where
    	lastname = 'TestContact'].last_Contrib_Date__c);
    system.assertEquals(500, [select id, largest_Contrib_Amt__c from Contact where
    	lastname = 'TestContact'].largest_Contrib_Amt__c);
    system.assertEquals(system.today() - 1500, [select id, Largest_Contrib_Date__c from 
    	Contact where lastname = 'TestContact'].Largest_Contrib_Date__c);
    system.assertEquals(300, [select id, YeartoDate_Giving__c from 
    	Contact where lastname = 'TestContact'].YeartoDate_Giving__c);
    system.assertEquals(200, [select id, Last_Year_Giving__c from 
    	Contact where lastname = 'TestContact'].Last_Year_Giving__c);
    system.assertEquals(200, [select id, Year_Before_Last_Giving__c from 
    	Contact where lastname = 'TestContact'].Year_Before_Last_Giving__c);
    }
    
    static testMethod void recalcGivingInvokeBatchTest()	{
    	recalcGivingInvokeBatch rGIBT = new recalcGivingInvokeBatch();
    }
}