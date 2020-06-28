/**
 * Created by Baird on 6/12/2020.
 */

@IsTest
private class requestVolPortalAccessTEST {
@IsTest
static void ExistingContact() {
User SignupSiteGuestUser = [SELECT Name, Id from User where Name = :'SignUp Site Guest User'];
system.runas(SignupSiteGuestUser) {
Create_Test_Variables CTV = new Create_Test_Variables();
Contact TestContact = CTV.fetchTestContact();
TestContact.FirstName = 'Test';
update TestContact;
PageReference pageRef = Page.requestVolPortalAccess;
Test.setCurrentPage(pageRef);
ApexPages.currentPage().getParameters().put('cid', TestContact.Id);

requestVolPortalAccess rVPE = new requestVolPortalAccess();
rVPE.Ctct.Firstname = 'Test';
rVPE.Ctct.Lastname = 'Testcontact';
rVPE.Ctct.email = 'testcontact@dontbotherme.org';
rVPE.Ctct.MailingPostalCode = '22222';

rVPE.submit();
system.assertEquals('Found', rVPE.VolunteerFound);
Contact resultsContact = [SELECT Id, VolToken__c from Contact where Id = :rVPE.Volunteer.Id];
system.assertEquals(64, resultsContact.VolToken__c.length(), 'Did not find new Token in Contact.');
// DID THE METHOD CREATE A DUPLICATE CONTACT?
List<Contact> resultContacts = [SELECT Id, Firstname,Lastname from Contact];
system.assertEquals(1, resultContacts.size(), 'requestVolPortalAccess created a duplicate Contact.');


//User loses link to MNPage and has to reset it.
rVPE.submit();
// Token should have changed.
Contact resultsContact2 = [SELECT Id, VolToken__c from Contact where Id = :rVPE.Volunteer.Id];
system.assertEquals(64, resultsContact2.VolToken__c.length(), 'Did not find new Token in Contact.');
system.assert(resultsContact.VolToken__c != resultsContact2.VolToken__c, 'Upon resubmitting, requestMN method should have refreshed token.');
}
}
@IsTest
static void NoExistingContact() {
Create_Test_Variables CTV = new Create_Test_Variables();
Contact TestContact = CTV.fetchTestContact();
PageReference pageRef = Page.requestVolPortalAccess;
Test.setCurrentPage(pageRef);
ApexPages.currentPage().getParameters().put('cid',TestContact.Id);

requestVolPortalAccess rVPE = new requestVolPortalAccess();
rVPE.Ctct.Firstname = 'NotTest';
rVPE.Ctct.Lastname = 'NOtTester';
rVPE.Ctct.email = 'nottest@tester.com';
rVPE.Ctct.MailingPostalCode = '22222';

rVPE.submit();
system.assertEquals('NotFound',rVPE.VolunteerFound);
}
}