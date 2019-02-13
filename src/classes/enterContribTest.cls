@isTest
private class enterContribTest{
    
    private static String strOppRecordTypeId;
    private static String strAccountRecordTypeId;
    private static String strCampaignRecordTypeId;

    @isTest static void enterContribmyTest(){
        Test.startTest();
        getRecordTypeId();
        Campaign cmp = getCampaign(strCampaignRecordTypeId);
        insert cmp;
        Opportunity opp = getOpportunity(strOppRecordTypeId, cmp.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        enterContrib eContrib = new enterContrib(sc);
        eContrib.cancelnewAcctCtct();
        eContrib.cancelnewCtct();
        eContrib.cancelnewLead();
        eContrib.createNewAccountContact();
        eContrib.createNewContact();
        eContrib.cancelNewContact();
        eContrib.SubmitAcctOrCtct();
        eContrib.getTemplates();
              
        Test.stopTest();
    }
    
    @isTest static void submitAndNextTest(){
        Test.startTest();
        getRecordTypeId();
        Account acc = getAccount(strAccountRecordTypeId);
        insert acc;
        Campaign cmp = getCampaign(strCampaignRecordTypeId);
        insert cmp;
        Opportunity opp = getOpportunity(strOppRecordTypeId, cmp.Id);
        insert opp;
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        enterContrib eContrib = new enterContrib(sc);
        List<SelectOption> options = eContrib.getItems();
        eContrib.RTName = strOppRecordTypeId;
        eContrib.getCheckingBlock();
        eContrib.getMembershipBlock();
        eContrib.getEventBlock();
        eContrib.getInKindBlock();
        eContrib.getPledgeBlock();
        eContrib.getTaskBlock();
        eContrib.contrib.CampaignId = cmp.Id ;
        eContrib.submitAndNext();
        Test.stopTest();
    }
    
    @isTest static void submitAndExitTest(){
        Test.startTest();
        getRecordTypeId();
        Account acc = getAccount(strAccountRecordTypeId);
        insert acc;
        Campaign cmp = getCampaign(strCampaignRecordTypeId);
        insert cmp;
        Opportunity opp = getOpportunity(strOppRecordTypeId, cmp.Id);
        insert opp;
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        enterContrib eContrib = new enterContrib(sc);
        List<SelectOption> options = eContrib.getItems();
        eContrib.RTName = strOppRecordTypeId;
        eContrib.contrib.CampaignId = cmp.Id ;
        eContrib.submitAndExit();
        Test.stopTest();
    }
    
    @isTest static void submitAcctTest(){
        Test.startTest();
        getRecordTypeId();
        Account acc = getAccount(strAccountRecordTypeId);
        insert acc;
        Contact con = getContact(acc.Id);
        insert con;
        PageReference pageRef = Page.enterContrib;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('AccountID', acc.Id);
        ApexPages.currentPage().getParameters().put('AccountName', 'Test Company');
        Campaign cmp = getCampaign(strCampaignRecordTypeId);
        insert cmp;
        Opportunity opp = getOpportunity(strOppRecordTypeId, cmp.Id);
        insert opp;
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        enterContrib eContrib = new enterContrib(sc);
        eContrib.contributorId = acc.Id;
        eContrib.submitAcct();
        eContrib.acct = acc;
        eContrib.updateAcct();
        eContrib.ListContacts = null;
        eContrib.submit();
        ApexPages.currentPage().getParameters().put('ContactID', con.Id);
        eContrib.ctct = null;
        eContrib.contributorId = con.Id;
        eContrib.submitCtct();
        eContrib.ContactID = con.Id;
        eContrib.chosePrimaryContributor();
        Test.stopTest();
    }
    
    @isTest static void submitCtctForAcctTest(){
        Test.startTest();
        getRecordTypeId();
        Account acc = getAccount(strAccountRecordTypeId);
        insert acc;
        Contact con = getContact(acc.Id);
        Campaign cmp = getCampaign(strCampaignRecordTypeId);
        insert cmp;
        Opportunity opp = getOpportunity(strOppRecordTypeId, cmp.Id);
        insert opp;
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        enterContrib eContrib = new enterContrib(sc);
        eContrib.ctct = con;
        eContrib.acct = acc;
        eContrib.submitCtctForAcct();
        Test.stopTest();
    }
    
    @isTest static void submitAcctCtctsTest(){
        Test.startTest();
        getRecordTypeId();
        Account acc = getAccount(strAccountRecordTypeId);
        insert acc;
        Contact con = getContact(acc.Id);
        Campaign cmp = getCampaign(strCampaignRecordTypeId);
        insert cmp;
        Opportunity opp = getOpportunity(strOppRecordTypeId, cmp.Id);
        insert opp;
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        enterContrib eContrib = new enterContrib(sc);
        eContrib.aname = 'Test Acc';
        eContrib.acct.RecordTypeId = strAccountRecordTypeId;
        eContrib.acct.Contacts_in_Account__c = '2';
        eContrib.ctct.LastName = 'Test Con Last';
        eContrib.ctct2.LastName = 'Test Con Last 2';
        eContrib.submitAcctCtcts();
        Test.stopTest();
    }

// Case: User finds lead, submits contribution
    @istest private static void ContribFromLeadTest() {
        ID LeadRTID;
        Test.startTest();
        getRecordTypeId();
        Account acc = getAccount(strAccountRecordTypeId);
        insert acc;
        Campaign cmp = getCampaign(strCampaignRecordTypeId);
        insert cmp;
        Opportunity opp = getOpportunity(strOppRecordTypeId, cmp.Id);
        Opp.Amount = 1.11;
        Opp.AccountId = acc.Id;
        Opp.recordtypeID = [select ID from RecordType where SObjectType = 'Opportunity' and Name = 'Donation' limit 1].id;
        insert opp;
        // Challenge Donation
        Opportunity Challenge = getOpportunity(strOppRecordTypeId, cmp.Id);
        Challenge.recordtypeID = [select ID from RecordType where SObjectType = 'Opportunity' and Name = 'Challenge' limit 1].id;
        insert Challenge;
        // Find a Lead Record Type
        LeadRTID = [SELECT Id,Name FROM RecordType WHERE SobjectType='Lead' LIMIT 1].id;
        Lead TestLead = new Lead(
            firstname='New',
            Lastname = 'Lead',
            Company = 'Lead Company',
            RecordTypeid = LeadRTID,
            Street = 'Lead Street 1',
            City = 'Lead City',
            State = 'Massachusetts',
            Country = 'United States',
            PostalCode = '22222',
            Phone = '3333333'            
        );
        insert TestLead;
        PageReference pageRef = Page.enterContrib;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('leadId', testLead.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        enterContrib ECL = new enterContrib(sc);
        ECL.contributorId = testLead.Id;
        ECL.SubmitLead();
        // Try updating lead
        ECL.ld.street='Lead Street Updated';
        ECL.updateLead();
        ECL.readyForContrib();
        system.assertEquals(true,ECL.readyForContrib);
        ECL.submitLead();
        system.assertequals(TestLead.id, ECL.ld.id);
        //system.assertEquals(true, eContribLead.readyForContrib);
        system.assertEquals(null, ECL.acct.id);
        system.assertEquals(null, ECL.ctct.id);
        Campaign cmp1 = getCampaign(strCampaignRecordTypeId);
        insert cmp1;
        ECL.contrib.CampaignId = cmp1.Id ;
        ECL.contrib.AccountId = acc.Id ;
        Opp.Amount = 1.11;
        Opp.campaignId = cmp.id;
        Opp.Check_Num_Text__c = '111';
        Opp.Payment_Type__c = 'Check';
        Opp.Matches_Which_Challenge_or_Pledge__c = Challenge.ID;
        Opp.RecordTypeId = [select id from RecordType where name = 'Donation' Limit 1].id;
        
        ECL.RTName = [select id from RecordType where name = 'Donation' Limit 1].id;
        ECL.submitAndNext();
        
        Opportunity testopp = [select id, amount, contact__c, accountid, Account.Name, Matches_Which_Challenge_or_Pledge__c, Check_Num_Text__c, Payment_Type__c
                              from Opportunity WHERE Account.Name = 'Test Company' LIMIT 1];
        system.assertEquals(1.11, Testopp.Amount );
        
        Test.stopTest();
    }

// Case: User finds account, contact, submits contribution
    @istest private static void ContribFromAcctCtctTest() {
        
        //ID LeadRTID;
        Test.startTest();
        getRecordTypeId();
        Account acc = getAccount(strAccountRecordTypeId);
        insert acc;
        Contact ctct = new Contact(
            lastname = 'TestContact',
            accountid = acc.id);
        insert ctct;
        system.assertEquals(ctct.Id,[select contactId from AccountContactRole where accountId = :acc.Id LIMIT 1].contactId,'Inserted account and contact but accountContactRole not set to contact.');
        Campaign cmp = getCampaign(strCampaignRecordTypeId);
        insert cmp;
        Opportunity opp = getOpportunity(strOppRecordTypeId, cmp.Id);
        Opp.Amount = 1.11;
        Opp.AccountId = acc.Id;
        Opp.recordtypeID = [select ID from RecordType where SObjectType = 'Opportunity' and Name = 'Donation' limit 1].id;
        insert opp;
        // Challenge Donation
        Opportunity Challenge = getOpportunity(strOppRecordTypeId, cmp.Id);
        Challenge.recordtypeID = [select ID from RecordType where SObjectType = 'Opportunity' and Name = 'Challenge' limit 1].id;
        insert Challenge;
        PageReference pageRef = Page.enterContrib;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('accountId', acc.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        enterContrib ECL = new enterContrib(sc);
        ECL.contributorId = acc.Id;
        ECL.SubmitAcct();
        // Did it find the contact?
        system.assertEquals(1,ECL.listContacts.size());
        system.assertEquals(ctct.id, ECL.primCtctId);
        // Try updating account
        ECL.acct.BillingStreet='Account Billing Street Updated';
        ECL.updateAcct_Ctcts();
        system.assertEquals(ECL.acct.BillingStreet,[select id, mailingStreet from Contact where id = :ctct.id].MailingStreet);
        ApexPages.currentPage().getParameters().put('contactId', ctct.id);
        ECL.contactid = ctct.id;
        ECL.chosePrimaryContributor();
        ECL.readyForContrib();
        system.assertEquals(true,ECL.readyForContrib);
        Campaign cmp1 = getCampaign(strCampaignRecordTypeId);
        insert cmp1;
        ECL.contrib.CampaignId = cmp1.Id ;
        ECL.contrib.AccountId = acc.Id ;
        ECL.contrib.contact__c = ctct.Id ;
        Opp.Amount = 1.11;
        Opp.campaignId = cmp.id;
        Opp.Check_Num_Text__c = '111';
        Opp.Payment_Type__c = 'Check';
        Opp.Matches_Which_Challenge_or_Pledge__c = Challenge.ID;
        Opp.RecordTypeId = [select id from RecordType where name = 'Donation' Limit 1].id;
        
        ECL.RTName = [select id from RecordType where name = 'Donation' Limit 1].id;
        ECL.submitAndNext();
        
        Opportunity testopp = [select id, amount, contact__c, accountid, Account.Name, Matches_Which_Challenge_or_Pledge__c, Check_Num_Text__c, Payment_Type__c
                              from Opportunity WHERE Accountid = :acc.id LIMIT 1];
        system.assertEquals(1.11, Testopp.Amount );
        
        //Test BackToStart
        ECL.BackToStart();
        system.assertEquals(null, ECL.acct.id);
       
        Test.stopTest();
    }

    
// Case: User finds contact, does controller find account?
    @istest private static void ContribFromCtctTest() {
        //ID LeadRTID;
        Test.startTest();
        getRecordTypeId();
        Account acc = getAccount(strAccountRecordTypeId);
        insert acc;
        Contact ctct = new Contact(
            lastname = 'TestContact',
            accountid = acc.id);
        insert ctct;
        Campaign cmp = getCampaign(strCampaignRecordTypeId);
        insert cmp;
        Opportunity opp = getOpportunity(strOppRecordTypeId, cmp.Id);
        Opp.Amount = 1.11;
        Opp.AccountId = acc.Id;
        Opp.recordtypeID = [select ID from RecordType where SObjectType = 'Opportunity' and Name = 'Donation' limit 1].id;
        insert opp;
        // Challenge Donation
        Opportunity Challenge = getOpportunity(strOppRecordTypeId, cmp.Id);
        Challenge.recordtypeID = [select ID from RecordType where SObjectType = 'Opportunity' and Name = 'Challenge' limit 1].id;
        insert Challenge;
        PageReference pageRef = Page.enterContrib;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('contactId', ctct.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        enterContrib ECL = new enterContrib(sc);
        ECL.contributorId = ctct.Id;
        ECL.SubmitCtct();
        // User clicks on Account
        ECL.choseAccount();
        // Did it find the account?
        system.assertEquals(acc.id,ECL.acct.id);
    }
   
        private static String getRecordTypeId(){
        List<RecordType> lstRecordType = [SELECT Id, DeveloperName, sObjectType FROM RecordType WHERE (DeveloperName='Donation' 
                                                AND sObjectType='Opportunity') OR (DeveloperName='Family' AND sObjectType='Account')
                                                OR (DeveloperName='FundraisingActivity' AND sObjectType='Campaign')];
        for(RecordType rType : lstRecordType){
            if(rType.sObjectType.equals('Opportunity') ) strOppRecordTypeId = rType.Id;
            else if(rType.sObjectType.equals('Account')) strAccountRecordTypeId = rType.Id;
            else strCampaignRecordTypeId = rType.Id;
        }
        return null;
    }
    
    private static Account getAccount(String sAccountRecordTypeId){
        return new Account( RecordTypeId = sAccountRecordTypeId,
                           Name = 'Test Company');
    }
    
    private static Campaign getCampaign(String sCampaignRecordTypeId){
        return new Campaign(RecordTypeId = sCampaignRecordTypeId,
                            Name = 'Test Campaign');
    }
    
    private static Contact getContact(String accId){
        return new Contact(AccountId = accId,
                           LastName = 'Test Contact');
    }
    
    private static Opportunity getOpportunity(String sOppRecordTypeId, String sCampaignId){
        return new Opportunity(RecordTypeId = sOppRecordTypeId,
                               Name = 'Test Contribution',
                               CampaignId = sCampaignId,
                               StageName = 'Payment Received',
                               CloseDate = Date.Today() + 5);
    }

}