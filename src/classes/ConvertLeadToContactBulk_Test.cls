/**
 * Created by PeterChurchill on 4/9/2018.
 */

@IsTest
private class ConvertLeadToContactBulk_Test {
    //test when the company name equals an existing account
    @isTest
    private static void ConvertLeadToContactTest1() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        //insert TestAcct;
        Lead TestLead = ctv.fetchTestLead();
        TestLead.Company = 'TestAccount';
        update TestLead;
        ConvertLeadToContactBulk convertinbulk = new ConvertLeadToContactBulk();
        convertinbulk.ConvertLeadToContact(new List<Lead> {TestLead});

        List<Account> aConfirm = [select id,name from account where id = :convertinbulk.AccountToLeadMap.keyset()];
        system.assertEquals(1, aConfirm.size());

        System.assertEquals('TestAccount',aConfirm[0].Name);
    } // end test1

    //test when the company name blank and household created
    @isTest
    private static void ConvertLeadToContactTest2() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        //insert TestAcct;
        Lead TestLead = ctv.fetchTestLead();
        TestLead.Company = 'none';
        update TestLead;
        ConvertLeadToContactBulk convertinbulk = new ConvertLeadToContactBulk();
        convertinbulk.ConvertLeadToContact(new List<Lead> {TestLead});

        system.debug(convertinbulk.LeadtoAccountMap);
        system.debug(convertinbulk.LeadtoContactMap);
        List<Account> aConfirm = [select id,name from account where id = :convertinbulk.AccountToLeadMap.keyset()];
        system.assertEquals(1, aConfirm.size());
        System.assertEquals('TestLead, Lead Household',aConfirm[0].Name);

    } // end test1

    //test when the company name is 'not provided' and should be replaced with household name
    @isTest
    private static void ConvertLeadToContactTest3() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        //insert TestAcct;
        Lead TestLead = ctv.fetchTestLead();
        TestLead.Company = 'not provided';
        update TestLead;
        ConvertLeadToContactBulk convertinbulk = new ConvertLeadToContactBulk();
        convertinbulk.ConvertLeadToContact(new List<Lead> {TestLead});

        system.debug(convertinbulk.LeadtoAccountMap);
        system.debug(convertinbulk.LeadtoContactMap);
        List<Account> aConfirm = [select id,name from account where id = :convertinbulk.AccountToLeadMap.keyset()];
        system.assertEquals(1, aConfirm.size());
        System.assertEquals('TestLead, Lead Household',aConfirm[0].Name);

    } // end test1

    @isTest
    private static void ConvertLeadToContactTestBulk() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 0; i <50; i++) {
            String sEmail = 'testlead' + i + '@dontbotherme.org';
            testLeads.add(new Lead(firstname = 'Lead', lastname = 'TestLead' + i, email = sEmail, company = 'none'));
        }
        insert testLeads;

        ConvertLeadToContactBulk convertinbulk = new ConvertLeadToContactBulk();
        convertinbulk.ConvertLeadToContact(testLeads);

        system.debug(convertinbulk.LeadtoAccountMap);
        system.debug(convertinbulk.LeadtoContactMap);
        //List<Account> aConfirm = [select id,name from account where id = :convertinbulk.LeadtoAccountMap.keyset()];
        //system.assertEquals(1, aConfirm.size());
        //System.assertEquals('TestLead, Lead Household',aConfirm[0].Name);

    } // end test bulk



}