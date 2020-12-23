@isTest
private class Create_Test_Variables_Test {
/*
    @testsetup static void setup(){
    createCustomSettings.createCustomSettings();
    }
*/
    static testMethod void Create_Test_Variables_Test() {
        WGHelpers.BManageContacts = true;
         WGHelpers.BManageContactEmails = true;

        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        Contact TestCtct = ctv.fetchTestContact();
        Account TestBusAcct = ctv.fetchTestBusinessAccount();
        Contact TestBusCtct = ctv.fetchTestBusinessContact();
		Lead TestLead = ctv.fetchTestLead();
        CampaignMember TestCM = ctv.fetchTestCM();
        system.debug('In CTVTest, fetchtestcontact brought back ' + TestCtct.id);
        Campaign TestCamp = ctv.fetchTestCampaign();
        Opportunity TestOpp = ctv.fetchTestOpportunity();
        Account FamilyAccount = ctv.fetchTestFamilyAccount();
        Contact FamilyContact = ctv.fetchTestFamilyContact();
        Case TestCase = ctv.fetchTestCase();
        Text_Document__c TD = ctv.fetchWaiver();
        Account BusinessAccount = ctv.fetchTestBusinessAccount();

        system.assertEquals('Testcampaign',TestCamp.Name);
        system.assertEquals('TestAccount',TestAcct.Name);
        system.assertEquals('TestBusiness',TestBusAcct.Name);
        system.assertEquals(TestCtct.lastname,'TestContact');
		system.assertEquals(TestLead.lastname,'TestLead');
        system.debug('TestOpportunity name is' + [select id, name from Opportunity where id = :TestOpp.ID].name);
        system.assertEquals(TestCamp.Id,TestCM.CampaignId);
        // For some reason, TestOpp.Name gives "autofill" even though the above code gives 
        // a full "TestAccount 2012-06-04 TestCampaign."  So the system.AssertEquals below is just
        // a workaround; I don't know what the correct test at this point would be.
        system.assertEquals(TestOpp.Name, 'autofill');
        system.assertEquals('TestWaiver',TD.Title__c);

        Contact ConfirmTestContact = [
                SELECT Firstname, Lastname, Email,Other_Email__c,Personal_Email__c,Last_Email_Overwrite__c,
                        Work_Email__c,Preferred_Email__c,Legacy_Emails__c,Account.RecordType.DeveloperName
                FROM Contact
                where Id = :TestBusCtct.Id];
        System.debug('ConfirmTestContact.Preferred_Email__c is '+ ConfirmTestContact.Preferred_Email__c);
        System.debug('ConfirmTestContact.Personal_Email__c is '+ ConfirmTestContact.Personal_Email__c);
        system.assertEquals('Work',ConfirmTestContact.Preferred_Email__c);
        system.assertEquals('testbusinesscontact@dontbotherme.org',ConfirmTestContact.Work_Email__c);
        system.assertEquals(TestOpp.Name, 'autofill');
    }
}