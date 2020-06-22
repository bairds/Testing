/**
 * Created by Baird on 6/16/2020.
 */

@IsTest
private class approveGuestUserEditTEST {
@TestSetup static void CreateTestVariables() {
Create_Test_Variables CTV = new Create_Test_Variables();
Contact Testcontact = CTV.fetchTestContact();
Testcontact.FirstName = 'Test';
Testcontact.HomePhone = '333 333 3333';
Testcontact.MailingCity = 'Test City';
Testcontact.MailingStreet = '123 Test St.';
Testcontact.MailingState = 'TX';
Testcontact.MailingPostalCode = '55555';
Testcontact.MobilePhone = '444 444 44444';
Testcontact.Phone = '555 555 55555';
update TestContact;
GuestUserUpdate__c GUU = new GuestUserUpdate__c(
FirstName__C = 'Spouse of',
LastName__c = 'TestContact2',
HomePhone__c = '666 6666',
MailingCity__c = 'Second City',
MailingStreet__c = '234 Test St.',
MailingState__c = 'TX',
MobilePhone__c = '777 7777',
Phone__c = '888 888 8888',
RelatedContact__c = TestContact.Id
);
Insert GUU;
}

@IsTest
static void UpdateContactWithGUU() {
// Get GuestUserUpdate
GuestUserUpdate__c GUU = [SELECT Id FROM GuestUserUpdate__c LIMIT 1];
System.currentPageReference().getParameters().put('guuid', GUU.Id);
ApproveGuestUserEdit AGUE = new approveGuestUserEdit();
System.debug('AGUE is ' + AGUE);
system.debug('Contact is ' + AGUE.Ctct);
System.assertEquals('TestContact', AGUE.Ctct.LastName, 'Failed to find TestContact from GUU.RelatedContact__c');

// Approve changes
AGUE.approveEdits();
System.assertEquals('Spouse of',AGUE.Ctct.Firstname);
System.assertEquals('TestContact2',AGUE.Ctct.Lastname);
System.assertEquals('666 6666',AGUE.Ctct.HomePhone);
System.assertEquals('Second City',AGUE.Ctct.MailingCity);
System.assertEquals('234 Test St.',AGUE.Ctct.MailingStreet);
// GUU was missing PostalCode, so it was left intact
System.assertEquals('55555',AGUE.Ctct.MailingPostalCode);
System.assertEquals('TX',AGUE.Ctct.MailingState);
System.assertEquals('777 7777',AGUE.Ctct.MobilePhone);
}

@IsTest
static void MissingGUUId() {
// Get GuestUserUpdate
GuestUserUpdate__c GUU = [SELECT Id FROM GuestUserUpdate__c LIMIT 1];
// System.currentPageReference().getParameters().put('guuid', GUU.Id);
ApproveGuestUserEdit AGUE = new approveGuestUserEdit();
System.assertEquals('Found no Guest User Update Id in URL.',String.ValueOf(ApexPages.getMessages()[0].getSummary()));
}
@IsTest
static void BadGUUId() {
// Get GuestUserUpdate
GuestUserUpdate__c GUU = [SELECT Id FROM GuestUserUpdate__c LIMIT 1];
System.currentPageReference().getParameters().put('guuid', '00O2K000006I1OJUA0');
ApproveGuestUserEdit AGUE = new approveGuestUserEdit();
System.assert(String.ValueOf(ApexPages.getMessages()[0].getSummary()).CONTAINS('Found bad Guest User Update Id in URL'));
}
}