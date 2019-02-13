@isTest
private class Thanks_List_Test {

    static testMethod void Thanks_List_Test() {
        //CREATE TEST VARIABLES
        // Create a campaign with slots_remaining__c = 1
            Campaign TestCamp = new Campaign(
            name = 'TestCampaign',
            capacity__c = 2,
            event_date_time__c = datetime.newInstance(2050, 12, 1, 12, 30, 2),
            description = 'description',
            event_cost__c = 20.00,
            RecordtypeID = [select id from recordtype where name = 'Public Event'].id);
            insert Testcamp; 
            Account TestAcc = new Account (name='TestAccount');
            insert testAcc;
            Contact TestContact = new Contact (lastname='TestContact', email='testcontact@dontbotherme.org', accountID = TestAcc.ID);
            insert testcontact; 
            Opportunity TestOpp = new Opportunity (Contact__c = TestContact.id,
            AccountID = TestAcc.id,
            CampaignID = TestCamp.id,
            Name = 'autofill',
            StageName = 'Closed/Won',
            CloseDate = system.today(),
            Amount = 100);
            insert TestOpp;
        
        PageReference pageRef = Page.Thank_You_Templates_List;
        Test.setCurrentPage(pageRef);
        system.debug('TestOpp.ID is ' + TestOpp.ID);
        ApexPages.currentPage().getParameters().put('id', TestOpp.ID);
        
        // Count the number of existing templates
        Integer Num_Templates = [select count() from ApexPage where 
            name like 'Thanks%'];
        ApexPage Thanks_Page_Test = new ApexPage(
            Name = 'Thanks_Page_Test',
            Markup = '<apex:page>This is a test thanks page.</apex:page>',
            controllerType = 'Standard'
            // controllerKey = 'Thank_You_Controller'
        );

                // Also add a template with the word "Thanks" not at the beginningof the name.
                // This should NOT be selected.
        ApexPage Thanks_Page_Test2 = new ApexPage(
                Name = 'Not_Thanks_Page_Test',
                Markup = '<apex:page>This is a test thanks page.</apex:page>',
                controllerType = 'Standard'

		);
        // insert Thanks_Page_Test;
        ApexPages.StandardController sc = new ApexPages.StandardController(testOpp);
        Thanks_List_Controller TLC = new Thanks_List_Controller(sc); 
		Integer testNr = TLC.thanks_Templates.size();
		system.assertEquals(Num_Templates,testNr);
        // assert the number of templates has grown by one
        system.assertEquals(Num_Templates, TLC.Thanks_Templates.size());
        system.assertEquals(100,TLC.Op.amount);
        
        //Test saveAttach()
        List<Attachment> List_Attach1 = [select id from Attachment where attachment.ParentId = :TestOpp.Id];
        string nextPage = TLC.saveAttach().getURL();
        List<Attachment> List_Attach2 = [select id from Attachment where attachment.ParentId = :TestOpp.Id];
        system.assertEquals(List_Attach2.size(),List_Attach1.size()+1);
        
        
        List<Opportunity> ResultOpps = [select id, Date_Acknowledged__c, StageName from Opportunity where id = :Testopp.id];
        System.assertEquals(1,ResultOpps.size());
        system.debug('ResultOpps[0] is ' + ResultOpps[0]);
        System.assertEquals('THANK YOU MAILED',ResultOpps[0].stageName.TOUPPERCASE(),'Thanks_List_Controller did not insert Thank You Mailed');
        System.assertEquals(system.Today(),ResultOpps[0].Date_Acknowledged__c);        
    }
}