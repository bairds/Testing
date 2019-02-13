/**
 * Created by Baird on 11/27/2018.
 */
global class CreateUserExamValuesPostCopy implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
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
    }
}