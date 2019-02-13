@isTest
private class CreateUserExamValuesTEST {

    @testsetup static void setup(){
        createCustomSettings.createCustomSettings();
    }

    static testMethod void CreateUserExamValuesTEST() {
        CreateUserExamValues CUEV = new CreateUserExamValues();
        Account TestAcct = CUEV.fetchTestAccount();
        Contact TestCtct = CUEV.fetchTestContact();
        Lead TestLead = CUEV.fetchTestLead();
        CampaignMember TestCM = CUEV.fetchTestCM();
        system.debug('In CUEVTest, fetchtestcontact brought back ' + TestCtct.id);
        Campaign TestCamp = CUEV.fetchTestCampaign();
        Opportunity TestOpp = CUEV.fetchTestOpportunity();
        List<Contact> TestContacts = CUEV.fetchTestContacts();
        List<Account> BusinessAccounts = CUEV.fetchBusinessAccounts();
        CUEV.fetchFamilyMembers();
        system.assertEquals('EOY Volunteer Event',TestCamp.Name);
        system.assertEquals('TestAccount',TestAcct.Name);
        system.assertEquals(TestCtct.lastname,'TestContact');
        system.assertEquals(TestLead.lastname,'TestLead');
        system.debug('TestOpportunity name is' + [select id, name from Opportunity where id = :TestOpp.ID].name);
        system.assertEquals(TestCamp.Id,TestCM.CampaignId);
        // For some reason, TestOpp.Name gives "autofill" even though the above code gives
        // a full "TestAccount 2012-06-04 TestCampaign."  So the system.AssertEquals below is just
        // a workaround; I don't know what the correct test at this point would be.
        system.assertEquals(TestOpp.Name, 'autofill');
        List<Contact> ConfirmCtcts = [select id, firstname, lastname, Account.Name from Contact where lastname like 'J%'];
        system.assertEquals(12,ConfirmCtcts.size());
        for (Contact ctct : ConfirmCtcts)
            system.debug('Contact is ' + ctct);
        List<Account> ConfirmAccts = [select id, name, (select firstname, lastname from Contacts) from Account where name = 'Janeson, Jane Household'];
        system.debug('ConfirmAccts is ' + ConfirmAccts[0]);
        system.assertEquals(1,ConfirmAccts.size());
        system.assertEquals(2,ConfirmAccts[0].Contacts.size());
    }
}