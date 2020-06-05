// Need to also test the case of bulk addition of opportunities.
@isTest
private class OpportunityTriggerTests {
    
    @testsetup static void setUpTestData(){
	create_Test_Variables ctv = new create_Test_Variables();
        
    }

    static testMethod void opportunityInsertTestAddUpdateRemoveContactRole() {
        // Create test data
        Account a = new Account(Name='TestAccount');
        insert a;
        Contact c = new Contact(LastName='Test', AccountID=a.id);
        insert c;
        Contact c2 = new Contact(LastName='Test2', AccountID=a.id);
        insert c2;
        Campaign camp = new Campaign(Name='Test');
        insert camp;
        
        // Test single record insert
        System.debug('Inserting 1 opportunity record... (single record validation)');
        Opportunity o = new Opportunity(Name='Test',CloseDate=System.today(),Amount=100,Contact__c=c.id,AccountID=a.id,StageName='Prospecting',CampaignId=camp.Id);
        insert o;
        
        // Test bulk insert
        System.debug('Inserting 50 opportunity records... (bulk validation)');
        List<Opportunity> o2 = new List<Opportunity>();
        for(integer i=0; i<50; i++) {
            o2.add( new Opportunity(Name='Test',CloseDate=System.today(),Amount=100,Contact__c=c.id,AccountID=a.id,StageName='Prospecting',CampaignId=camp.Id));
         }

        insert o2;
        
        // Test single record primary contributor change
        System.debug('Updating 1 opportunity record, changing primary contributor... (single record validation)');
        o.Contact__c = c2.Id;
        update o;
        
        // Test bulk update primary contributor change
        System.debug('Updating 50 opportunity records, changing primary contributor... (bulk validation)');
        for(integer x=0; x<o2.size();x++) {
            o2[x].Contact__c=c2.Id;
        }
        
        update o2;
        
        // Test single record primary contributor to NULL
        System.debug('Updating 1 opportunity record, primary contributor to NULL... (single record validation)');
        o.Contact__c=NULL;
        update o;
        
        // Test bulk update primary contributor to NULL
        System.debug('Updating 50 opportunity records, primary contributor to NULL... (bulk validation)');
        for(integer x=0; x<o2.size();x++) {
            o2[x].Contact__c=NULL;
        }
        
        update o2;
        
        // Test single record update where primary contributor did not previously exist
        System.debug('Inserting 1 opportunity record, no primary contributor... (single record validation)');
        Opportunity o3 = new Opportunity(Name='Test',CloseDate=System.today(),Amount=100,Account=a,StageName='Prospecting',CampaignId=camp.Id);
        insert o3;
        
        System.debug('Updating 1 opportunity record, primary contributor did not previously exist... (single record validation)');
        o3.Contact__c=c.Id;
        update o3;
    }
    
    static testMethod void opportunityInsertTestUpdatePrimaryContributorCampaignStatus() {
        // Create test data
        Account a = new Account(Name = 'TestAccount');
        insert a;
        Contact c = new Contact(LastName = 'Test', AccountID = a.id);
        insert c;
        Contact c2 = new Contact(LastName = 'Test2', AccountID = a.id);
        insert c2;
        Campaign camp = new Campaign(Name = 'Test');
        insert camp;
        // What campaign stati are allowed now?
        system.debug('The campaign ' + camp.Id + ' allows member stati ' +[SELECT label from
                campaignMemberStatus where campaignId =: camp.Id]);
        CampaignMember cm = new CampaignMember(ContactId = c.Id, CampaignId = camp.Id);
        insert cm;
        CampaignMember cm2 = new CampaignMember(ContactId = c2.Id, CampaignId = camp.Id);
        insert cm2;
        //Test to make sure initial CampaignMember.Status is set correctly
        List<CampaignMember> ListCMs = [select status, id from CAmpaignMember where campaignId = :camp.Id];
        for (CampaignMember campmmbr : ListCMs) {
            system.AssertEquals('Added to campaign', campmmbr.status);
        }

        // Test single record insert of one donation
        System.debug('Inserting 1 opportunity record... (single record validation)');
        Opportunity o = new Opportunity(Name = 'Test', CloseDate = System.today(), Amount = 100, CampaignId = camp.Id, Contact__c = c.id, Account = a, StageName = 'Closed Won');
        insert o;
        //Has the status changed to 'Donated"
        system.debug('After 1st donation CampaignMembers are ' + [select status, contactid, campaignid from CampaignMember where campaignid = :camp.id and contactid = :c.id]);
        system.assertEquals('DONATED', [select status from CampaignMember where id = :cm.id].status.TOUPPERCASE(), 'After inserting $100 contribution status did not changed to Donated.');

        // Test change to a Closed/Won opportunity - Change primary contributor
        o.Contact__c = c2.Id;
        update o;
        //Has the status of cm2 changed to "Donated"?

        // Test change in deal stage from Closed/Won to Prospecting with a change to the primary contributor
        o.Contact__c = c.id;
        o.StageName = 'Prospecting';
        update o;
        // Test to make sure the new value is in the CampaignMember record.

        // Change back to Closed/Won with volunteer hours, no donation.
        o.StageName = 'Closed Won';
        o.amount = 0;
        o.Hours_Actual__c = 2;
        update o;

        // Test delete
        delete o;
        // Test to see if js popup has arisen;
        // Through popup set campaign member to "Added to campaign"
        // Call remote method
    }
    }