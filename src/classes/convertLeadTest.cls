//Revised to test convertLeadToContact instead of the old convertLead
@istest
private class convertLeadTest {
        
    static testMethod void createLeadAndConvertIt() {  
        Create_Test_Variables ctv = new Create_Test_Variables();
        Lead ld = ctv.fetchTestLead();
        ld.company = 'none';
        update ld;
        database.LeadConvertResult LCR = convertLead.convertLead(ld);
        List<Contact> Results = [select id, LastName, Firstname, accountid, account.Addressee__c, 
                account.Dear__c, account.Name from Contact where id = :LCR.getContactId()];
        system.assertEquals(1,results.size(),'Results should have returned one contact with lastname Testlead.');
        system.assertEquals('Lead TestLead',Results[0].account.Addressee__c,'Account.Addressee__c not properly updated by convertLead class');
        system.assertEquals('Lead',Results[0].account.Dear__c,'Account.Dear__c not properly updated by convertLead class');
        system.assertEquals('TestLead, Lead Household',Results[0].account.Name,'Account.Name not properly updated by convertLead class');
    }

    static testMethod void createLeadwCompanyAndConvertIt() {  
        Create_Test_Variables ctv = new Create_Test_Variables();
        Lead l = ctv.fetchTestLead();
        // fetchTestLead brings back a lead with company=TestCompany
		List<ID> resultIds = convertLeadToContact.convertLeadToContact(l.Id);
        List<Contact> Results = [select id, LastName, Firstname, accountid, account.Addressee__c, 
                      account.Dear__c, account.Name from Contact where id = :resultIds[0]];
        system.assertEquals(1,results.size(),'Results should have returned one contact with lastname Testlead.');
        system.assertEquals('Lead TestLead',Results[0].account.Addressee__c,'Account.Addressee__c not properly updated by convertLead class');
        system.assertEquals('Lead',Results[0].account.Dear__c,'Account.Dear__c not properly updated by convertLead class');
        system.assertEquals('TestCompany',Results[0].account.Name,'Account.Name not properly updated by convertLead class');
    }

}