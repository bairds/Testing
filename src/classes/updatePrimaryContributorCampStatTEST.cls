/**
 * Created by Baird Straughan on 10 Sept 2018.
 */

@isTest
private with sharing class updatePrimaryContributorCampStatTEST {


    @istest static void singleDonation() {
        create_Test_Variables CTV = new create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        Contact TestCtct = ctv.fetchTestContact();
        Campaign TestCamp = ctv.fetchTestCampaign();
        CampaignMember TestCM = ctv.fetchTestCM();
        system.debug('What campaign members exist after fetchTestCM? ' + [select id, status, campaign.name, contact.lastname from CampaignMember]);
        List<Opportunity> ListOpps = new List<Opportunity>();
        Opportunity TestOpp = new Opportunity(
                Name = 'TestOpp',
                StageName = 'Donation Received',
                CampaignId = TestCamp.Id,
                Amount = 100.00,
                CloseDate = system.now().date(),
                AccountId = TestAcct.Id,
                Contact__c = TestCtct.Id
        );
        ListOpps.add(TestOpp);
        updatePrimaryContributorCampaignStatus.UpdateCMStatus(ListOpps);
        // insert Opp;
        // Opportunity ConfirmOpp = [select id, name, amount from Opportunity where id =: TestOpp.Id];
        system.debug('What campaign members exist after inserting Opp? ' + [select id, status, campaign.name, contact.lastname from CampaignMember]);
        CampaignMember ConfirmCM = [select id, status, contact.lastname from CampaignMember where campaignId=:TestCamp.Id and contactId =:TestCtct.Id];
        system.debug('ConfirmCM is ' + ConfirmCM);
        system.assertEquals('Donated',ConfirmCM.status,'UpdatePrimaryContributorCampaignStatus did not update the status to Donated as it should have.');
    }
    
    @istest static void bulkDonation() {
        create_Test_Variables CTV = new create_Test_Variables();
        // ctv.createWGCustomSettings();
        Campaign TestCamp = ctv.fetchTestCampaign();
        List<CampaignMemberStatus> LCMS = [select label from CampaignMemberStatus where campaignId =: TestCamp.Id];
        system.debug('List of available CAmpaignMemberSTati is ' + LCMS);
        List<Contact> Ctcts = createContacts();
        List<CampaignMember> CMs = createCMs(Ctcts);
        List<Opportunity> Contribs = createContribs(Ctcts);
        // Test results;
        List<CampaignMember> ConfirmCMs = [select id, status, contact.lastname from CampaignMember where campaignId =: TestCamp.Id and Contact.Lastname like '%lastname%'];
        system.assertEquals(9,ConfirmCMs.size(),'Should have created 100 opportunities and hence 100 campaignmembers');
        For (CampaignMember cm : ConfirmCMs){
            // system.debug('At end, campaignmember CM is ' + cm);
            system.assertEquals('COMPLETED',cm.status.TOUPPERCASE(),'Should have set status to Completed for this volunteer task');
        }
        
        
    }
    
    public static List<Contact> createContacts(){
        Id AcctId = [select Id from Account where name = 'TestAccount'][0].Id;                
        List<Contact> Ctcts = new List<Contact>();
        For (integer i=0; i<9; i++) {
            Contact Ctct = new Contact(
                Lastname = 'Lastname'+i,
                Firstname = 'Firstname'+i,
                AccountId = AcctId);
                Ctcts.add(Ctct);
        }
            insert Ctcts;
            return Ctcts;
    }
    
    public static List<CampaignMember> createCMs(List<Contact> Ctcts){
        Id TestCampId = [select Id from Campaign where name = 'Testcampaign'][0].Id;
        List<CampaignMember> ListCMs = new List<CampaignMember>();
        For (Contact c : Ctcts) {
        CampaignMember CM = new CampaignMember(
            ContactId = c.Id,
            CampaignId = TestCampId,
            Status = 'Added to campaign');
            ListCMs.add(CM);
        }
        insert ListCMs;
        return ListCMs;
    }
    
    public static List<Opportunity> createContribs(List<Contact> Ctcts){
        Id AcctId = [select Id from Account where name = 'TestAccount'][0].Id;   
        Id TestCampId = [select Id from Campaign where Name = 'Testcampaign'][0].Id;
        Id VolRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Volunteer Task').getRecordTypeId();                                           
        List<Opportunity> Contribs = new List<Opportunity>();
        For (Contact c : Ctcts){
            Opportunity opp = new Opportunity(
                recordTypeId = VolRTID,
                name = 'autofill',
                stageName = 'Completed',
                Contact__c = c.Id,
                AccountId = AcctId,
                Hours_Actual__c = 2.00,
                campaignId = TestCampId,
                closeDate = system.now().date());
                Contribs.add(opp);
        }
        insert Contribs;
        return Contribs;
    }

    
}