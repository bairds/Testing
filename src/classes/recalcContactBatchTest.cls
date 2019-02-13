@istest
private class recalcContactBatchTest {

static testMethod void recalcContactBatchTest()   {
    
//INSERT Donations for TestContact
    Opportunity[] CYOps;
    Opportunity[] LYOps;
    Opportunity[] YBLOps;
    Opportunity[] AncientOps;
    Opportunity Grant;
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
        closeDate = system.today().adddays(-I));
        }
        insert CYOps;
// Insert grant, which should not appear in totals
    Grant = new Opportunity(
        name = 'TestGrant',
        amount = 100000,
        campaignID = Testcampaign.ID,
        accountID = Testaccount.ID,
        contact__c = TestContact.ID,
        recordTypeID = [select id from RecordType where name = 'Grant'].id,
        stageName = 'Closed Won',
        closeDate = system.today());
    insert Grant;        
//insert last year donations
    LYOps = new Opportunity[2];
    for (Integer I = 0; I < 2; I++) {
        LYOps[I] = new Opportunity(name = 'Test ' + I,
        amount = 101,
        campaignID = Testcampaign.ID,
        accountID = Testaccount.ID,
        contact__c = TestContact.ID,
        recordTypeID = [select id from RecordType where name = 'Membership'].id,
        stageName = 'Closed Won',
        closeDate = system.today()-365-i);
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
        recordTypeID = [select id from RecordType where name = 'Donation'].id,
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
        recordTypeID = [select id from RecordType where name = 'Major Donation'].id,
        stageName = 'Closed Won',
        closeDate = system.today()-1200);
        }   
    insert AncientOps;


    Contact c = [select id, last_donate_amt__c, last_contrib_Amt__c, first_contrib_source__c, first_contrib_cat__c
    from Contact where id = :TestContact.id];

    system.assertEquals(100.00,c.last_donate_amt__c);
    system.assertEquals(100000.00,c.Last_Contrib_Amt__c);
    system.assertEquals('Testcampaign',c.first_contrib_source__c);
    system.assertEquals('Major Donation',c.first_contrib_cat__c);

    //Now erase the derived fields on Contact c
    c.last_donate_amt__c=null;
    c.last_contrib_amt__c=null;
    c.first_contrib_source__c=null;
    c.first_contrib_cat__c=null;


    recalcContactInvokeBatch rCIB = new recalcContactInvokeBatch();
    Test.startTest();
    rCIB.invokeBatch();
    Test.stopTest();
    rCIB.Finished();
    
    
/*  
        recalcAccountBatch rAB = new recalcAccountBatch();
        rAB.query = 'select id from Account limit 200'; 
        Test.startTest();
        Database.executeBatch(rAB, 200);
        Test.stopTest();            
*/
    
//PUT ALL THESE IN ONE SINGLE QUERY.
//test to see whether contact giving fields are updated
    
c = [select id, last_donate_amt__c, last_contrib_Amt__c, first_contrib_source__c, first_contrib_cat__c
    from Contact where id = :TestContact.id];   
    
    system.assertEquals(100.00,c.last_donate_amt__c);
    system.assertEquals(100000.00,c.Last_Contrib_Amt__c);
    system.assertEquals('Testcampaign',c.first_contrib_source__c);
    system.assertEquals('Major Donation',c.first_contrib_cat__c);
    }
}