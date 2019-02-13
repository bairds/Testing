@isTest
private class enterAccountContactContributionTest {
    
    static testMethod void test() 
    {
        Create_Test_Variables ctv = new Create_Test_Variables();     
        
        enterAccountContactContribution eacc = new enterAccountContactContribution();
        eacc.setEnterContrib();
        
        // Tests Leads
        
        eacc.personId = ctv.TestLead.Id;
        
        eacc.selectPerson(); 
        
        System.currentPageReference().getParameters().put('l', eacc.personId);
        
        eacc.setEnterContrib();
        
        eacc.updatePerson();        
        eacc.savePerson();
        
        eacc.enterContribution();
                
        System.currentPageReference().getParameters().remove('l');
        
        eacc.l = null;
        
        // Test Accounts
        
        eacc.a = '2';
        eacc.step = '2';
        eacc.setEnterContrib();
        
        eacc.acct.RecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Family').getRecordTypeId();
        
        eacc.acct.Name = 'Test';
        eacc.ContactsInAccount = '2';
        
        eacc.addContact();
        
        eacc.a2 = '1';
            
        eacc.setContacts();
        
        // Test Contacts
                        
        eacc.co.FirstName = 'Test';
        eacc.co.LastName = 'Test';
        eacc.co.Email = 'baird@watergrass.org';
        
        eacc.co2.FirstName = 'Test';
        eacc.co2.LastName = 'Test';
        
        eacc.saveAccountContacts();
        
        eacc.acct.Id = null;
        eacc.acct.Name = null;        
        eacc.ContactsInAccount = '1';
        
        eacc.co.Id = null;
        
        eacc.saveAccountContacts();
        
        eacc.a = '1';
                
        eacc.personId = eacc.co.Id;
        eacc.selectPerson();
        
        System.currentPageReference().getParameters().put('co', eacc.personId);
        
        eacc.setEnterContrib();
       	eacc.a = '3';
        eacc.savePerson();
        
        eacc.selectAccount();
        eacc.selectContact();
        
        eacc.enterContribution();
                
        System.currentPageReference().getParameters().remove('co');
                        
        System.currentPageReference().getParameters().put('pc', eacc.co.Id);
        System.currentPageReference().getParameters().put('ac', eacc.co.AccountId);
        
        eacc.setEnterContrib();
                
        System.currentPageReference().getParameters().put('rt', [ SELECT Id FROM RecordType WHERE Name = 'Pledge' ].Id);
        
        eacc.setEnterContrib();
        eacc.o.CampaignId = ctv.TestCampaign.Id;
        eacc.oc.thankYouLetter = eacc.oc.thankYouLetters[1].getValue();
        
        eacc.cm.Membership_Start_Date__c = Date.today();
        eacc.cm.Membership_End_Date__c = Date.today().addYears(1);
        
        eacc.submitContribution();
        
        eacc.sendEmail();
        eacc.attachLetter();
        eacc.next();
        eacc.exit();
        
        eacc.co = null;
        
        eacc.personId = ctv.TestAccount.Id;
        eacc.selectPerson();
                
        eacc.setEnterContrib();
        
        System.currentPageReference().getParameters().remove('ac');
        
        eacc.acct = null;
    }

    testmethod static void TestEnteringContacts(){
        Create_Test_Variables ctv = new Create_Test_Variables();  
        Account TestAcct = ctv.fetchTestAccount();
        Pagereference Testpage = Page.EnterAccountContactContributionPage;
        Test.setCurrentPage(Testpage);         
        System.currentPageReference().getParameters().put('2', 'a2');
        enterAccountContactContribution eacc = new enterAccountContactContribution();
        System.currentPageReference().getParameters().put('ac', TestAcct.Id);

        eacc.a = '2';
        eacc.step = '2';
        eacc.setEnterContrib();
        system.debug('After first setEnterContrib(), acct.id is ' + eacc.acct.id);
        
        eacc.acct.RecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Family').getRecordTypeId();
        
        eacc.acct.Name = 'Test';
        eacc.ContactsInAccount = '2';
        update eacc.acct;
        
        eacc.addContact();
        eacc.a2 = '2';
        system.debug('After accContact, acct.id is ' + eacc.acct.id + ' and ContactsInAccount is ' + eacc.ContactsInAccount);
        eacc.setEnterContrib();
        system.debug('After second setEnterContrib, acct.id is ' + eacc.acct.id + ' and ContactsInAccount is ' + eacc.ContactsInAccount);           
        eacc.setContacts();
        system.debug('After setcontacts, acct.id is ' + eacc.acct.id + ' and ContactsInAccount is ' + eacc.ContactsInAccount);
    }
    
    testmethod static void TestEnteringAccountAndContacts(){
        Create_Test_Variables ctv = new Create_Test_Variables();  
        Account TestAcct = ctv.fetchTestAccount();
        TestAcct.BillingPostalCode = '22222';
        Pagereference Testpage = Page.EnterAccountContactContributionPage;
        Test.setCurrentPage(Testpage);
        enterAccountContactContribution eacc = new enterAccountContactContribution();
        System.currentPageReference().getParameters().put('a', '2');
        eacc.setEnterContrib();
        eacc.ContactsInAccount = '2';
        eacc.setContacts();
        
        // Test Contacts
        
        eacc.co.FirstName = 'Test';
        eacc.co.LastName = 'Test';
        eacc.co.Email = 'baird@watergrass.org';
        
        eacc.co2.FirstName = 'Testa';
        eacc.co2.LastName = 'Test';
        eacc.saveAccountContacts();
        
        Account ConfirmAcct = [select id, name, (select firstname, lastname from Contacts) from Account
                              where name = 'Test, Test and Testa Household'];
        system.debug('ConfirmAcct.name is ' + ConfirmAcct.name);
        system.assertEquals(2,ConfirmAcct.Contacts.size(),'Should have saved a new acct with two contacts');
        system.assertEquals('Test',ConfirmAcct.Contacts[0].FirstName);
        
        eacc.acct.Id = null;
        eacc.acct.Name = null;        
        eacc.ContactsInAccount = '1';
        
        eacc.co.Id = null;
        
        eacc.saveAccountContacts();
        
        eacc.a = '1';
                
        eacc.personId = eacc.co.Id;
        eacc.selectPerson();
        
        System.currentPageReference().getParameters().put('co', eacc.personId);
        
        eacc.setEnterContrib();
       	eacc.a = '3';
        eacc.savePerson();
        
        eacc.selectAccount();
        eacc.selectContact();
        
        eacc.enterContribution();
                
        System.currentPageReference().getParameters().remove('co');
                        
        System.currentPageReference().getParameters().put('pc', eacc.co.Id);
        System.currentPageReference().getParameters().put('ac', eacc.co.AccountId);
        
        eacc.setEnterContrib();
                
        System.currentPageReference().getParameters().put('rt', [ SELECT Id FROM RecordType WHERE Name = 'Pledge' ].Id);
        
        eacc.setEnterContrib();
        eacc.o.CampaignId = ctv.TestCampaign.Id;
        eacc.oc.thankYouLetter = eacc.oc.thankYouLetters[1].getValue();
        
        eacc.cm.Membership_Start_Date__c = Date.today();
        eacc.cm.Membership_End_Date__c = Date.today().addYears(1);
        
        eacc.submitContribution();
        
        eacc.sendEmail();
        eacc.attachLetter();
        eacc.next();
        eacc.exit();
        
        eacc.co = null;
        
        eacc.personId = ctv.TestAccount.Id;
        eacc.selectPerson();
                
        eacc.setEnterContrib();
        
        System.currentPageReference().getParameters().remove('ac');
        
        eacc.acct = null;
        
        list<selectOption> ConfirmSO = eacc.getNrContacts();
        system.assertEquals(3,ConfirmSO.size(),'getNrContacts should have return 0,1,2 as options for the nr of contacts to add');
        
    }     
}