@istest
private class ContactCustomTest {
    
    testmethod static void ContactCustomTest()
    {    
    Create_Test_Variables ctv = new Create_Test_Variables();
    Contact TestContact = ctv.fetchTestContact();
    Account TestAccount = ctv.fetchTestAccount();
    Opportunity TestOpp = ctv.fetchTestOpportunity();
    AccountContactRole TestACR = [select id from AccountContactRole where accountid=:TestAccount.Id];
 
        ContactCustom coc = new ContactCustom();
        coc.setVolunteerInterests();
        system.assertEquals(true,coc.newsletter,'Newsletter not set equal to true by ContactCustom constructor');
        List<contact> Listctcts = new List<contact>();
        Listctcts.add(TestContact);
        ContactCustom coc2 = new ContactCustom(Listctcts);
        
    	coc.id = 'xxxxxxxxxx';
        coc.name = 'Test Contact Custom';
        coc.firstname = 'Test';
        coc.lastname = 'TestContact';
        coc.company = 'none';
        coc.email = 'testcontact@dontbotherme.org';
    coc.phone = '3333333';
    coc.zip = '33333';
    coc.street = '100 Test Street';
    coc.city = 'Testcity';
    coc.state = 'Test state';
    coc.over18 = true;
    coc.newsletter = true;
    coc.acr = TestACR;
    coc.flag = true;
    coc.mailingLists=new List<String>();
    coc.HowHeard='through grapevine';        
    }
/*    
    @testsetup static void SetUpTestVariables(){
    Create_Test_Variables ctv = new Create_Test_Variables();
    Contact TestContact = ctv.fetchTestContact();
    Account TestAccount = ctv.fetchTestAccount();
    Opportunity TestOpp = ctv.fetchTestOpportunity();
        
     Profile p = [SELECT Id FROM Profile WHERE Name='WG User 2016' OR Name='WaterGrass User 2016' limit 1];
      String Username = 'WGTestUser' + organization.Id;
      User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
      LocaleSidKey='en_US', ProfileId = p.Id,
      TimeZoneSidKey='America/Los_Angeles', UserName='WGTestUser@watergrass.com');
      insert u;
    }
    
        @istest static void AcctCtctAlreadyExistTest(){
            User u = [select id from User where Alias = 'standt' limit 1];
            System.runAs(u) {
                Account acct = [SELECT Id FROM Account WHERE Name='TestAccount' LIMIT 1];
                Contact NewCtct = new Contact(
                    firstname = 'Test',
                    lastname = 'TestContact',
                    email='testcontact@dontbotherme.org',
                	OwnerId = u.Id);
                // insert contact into ContactCustom method;
                List<Contact> ctctlist = new List<Contact>();
                ctctlist.add(newCtct);
                ContactCustom cc = new ContactCustom();
                cc.processBeforeInsert(ctctlist);
                system.assertEquals(cc.cs[0].AccountId,acct.Id,'processBeforeInsert did not find matching contact and insert its accountId');
                system.assertEquals(cc.ts[0].Subject,'Merge with Existing Contact','Should have matched contact, inserted accountId, inserted Merge Contacts task');
                // JOSE WHAT TESTS SHOULD WE RUN FOR MAILINGLIST, VOLUNTEER INTEREST LIST, VOLUNTEER LIST, HOW HEARD?
            }
        }
        @istest static void LeadAlreadyExistsTest(){
            User u = [select id from User where Alias = 'standt' limit 1];
            System.runAs(u) {
                Account acct = [SELECT Id FROM Account WHERE Name='TestAccount' LIMIT 1];
                Contact NewCtct = new Contact(
                    firstname = 'Test',
                    lastname = 'TestContact',
                    email='testcontact@dontbotherme.org',
                	OwnerId = u.Id);
                // insert contact into ContactCustom method;
                List<Contact> ctctlist = new List<Contact>();
                ctctlist.add(newCtct);
                ContactCustom cc = new ContactCustom();
                cc.processBeforeInsert(ctctlist);
                system.assertEquals(cc.cs[0].AccountId,acct.Id,'processBeforeInsert did not find matching contact and insert its accountId');
                system.assertEquals(cc.ts[0].Subject,'Merge with Existing Contact','Should have matched contact, inserted accountId, inserted Merge Contacts task');
                // JOSE WHAT TESTS SHOULD WE RUN FOR MAILINGLIST, VOLUNTEER INTEREST LIST, VOLUNTEER LIST, HOW HEARD?
            }
    
        }
    // JOSE PLEASE PROGRAM FROM HERE ON.

     // No matching Email           
            @istest static void NewPersonTest(){
            }
                
                    

*/
}