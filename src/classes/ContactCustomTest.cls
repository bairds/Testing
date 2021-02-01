/*
Dec 2020 Stripped out the AccountContactRole references
so that this wouldn not trigger errors when using AccountContactRelationships
instead.
*/

@istest
private class ContactCustomTest {

    testmethod static void ContactCustomTest() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Contact TestContact = ctv.fetchTestContact();
        Account TestAccount = ctv.fetchTestAccount();
        Opportunity TestOpp = ctv.fetchTestOpportunity();

        ContactCustom coc = new ContactCustom();
        coc.setVolunteerInterests();
        // system.assertEquals(true, coc.newsletter, 'Newsletter not set equal to true by ContactCustom constructor');
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
        coc.flag = true;
        coc.mailingLists = new List<String>();
        coc.HowHeard = 'through grapevine';
    }

}