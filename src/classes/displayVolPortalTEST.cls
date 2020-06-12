/**
 * Created by Baird on 6/12/2020.
 */

@IsTest
private class displayVolPortalTEST {
@testSetup
static void createContact() {
Create_Test_Variables CTV = new Create_Test_Variables();
Contact Testcontact = CTV.fetchTestContact();
//Create Volunteer Tasks
// First Volunteer Task has no miles driven to see if the null value errors out
List<Opportunity> ListVTs = new List<Opportunity>();
For (integer i = 0; i < 9; i++) {
Opportunity opp = new Opportunity(
name = 'Volunteer Task ' + i,
Hours_Actual__c = 1.00,
STageName = 'Completed',
RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Volunteer Task').getRecordTypeId(),
Contact__c = Testcontact.Id,
CloseDate = system.today().addDays(-i)
);
ListVTs.add(opp);
}
// Add one Volunteer Task two years ago
Opportunity opp = new Opportunity(
name = 'Volunteer Task 10',
Hours_Actual__c = 1.00,
STageName = 'Completed',
RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Volunteer Task').getRecordTypeId(),
MIles_Driven__c = 10.00,
Contact__c = Testcontact.Id,
CloseDate = system.today().addDays(-730)
);
ListVTs.add(opp);
insert ListVTs;
}

@IsTest
static void NineVTs() {
PageReference pageRef = Page.VolPortal;
Test.setCurrentPage(pageRef);
Contact TestContact = [SELECT id, firstname, lastname from Contact where lastname = 'TestContact' limit 1];
ApexPages.currentPage().getParameters().put('cid', TestContact.Id);
// ApexPages.StandardController controller = new ApexPages.StandardController(TestContact);
displayVolPortal dVP = new displayVolPortal();
system.assertEquals(9, dVP.VolHoursThisYear, 'displayVolPortal should have summed to 9 hours');
system.assertEquals(0, dVP.VolMilesThisYear, 'displayVolPortal should have summed to 0 miles');
system.assertEquals(10, dVP.VolHoursAll, 'displayVolPortal should have summed to 10 hours');
system.assertEquals(10, dVP.VolMilesAll, 'displayVolPortal should have summed to 10 miles');
//Test edit functions
dVP.editContactInfo();
dVP.guu.email__C = 'ChangedTestContact@dontbotherme.org';
dVP.Submit();
GuestUserUpdate__c GUUResult = [SELECT Id,RelatedContact__c,PageSource__c FROM GuestUserUpdate__c
LIMIT 1];
system.assertEquals(TestContact.Id,GUUResult.RelatedContact__c,'Submit function should have inserted RelatedContact.Id');
system.assertEquals('UpdateContactInfo',GUUResult.PageSource__c,'Submit action failed to insert correct PageSource__c field in GuestUserUpdate');

dVP.cancelEditContactInfo();
}
}