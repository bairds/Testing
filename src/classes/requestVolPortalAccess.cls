/**
 * Created by Baird on 6/12/2020.
 */

public without sharing class requestVolPortalAccess {

public Contact Ctct {get;set;}
public Contact Volunteer {get;set;}
public string VolunteerFound {get;set;}

public requestVolPortalAccess(){
Ctct = new Contact();
}

public PageReference submit(){
    system.debug('Ctct sent to identifyPerson is ' + Ctct);
List<string> results = identifyPerson.identifyPerson(Ctct);
system.debug('results of identifyPerson are ' + results);
if (results!=null) {
Volunteer = [SELECT Id, Email FROM Contact where Id =: results[0]];
VolunteerFound = 'Found';
// Refresh VolToken;
Volunteer.VolToken__c = WGHelpers.getVolToken();
update Volunteer;

// SEND EMAIL
List<EmailTemplate> emailTemplates = [SELECT Id FROM EmailTemplate WHERE DeveloperName='Volunteer_Portal_Link'];
List<String> ToAddresses = new List<String>{Volunteer.Email};
Try {
    OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress limit 1];
    system.debug('OrgWideEmailAddress is ' + owa);
    system.assertNotEquals(owa,null,'OrgWideEmailAddress was not set up, so VolPortal cannot send email.');
    WGHelpers.sendTemplatedEmail(ToAddresses,null,'VolPortalLinkFromOrganizer',results[0],null,owa.id,true,null);
// Messaging.reserveSingleEmailCapacity(2);
}
catch(queryException qe){
    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Must set an Organization-Wide Email Address before the volunteer portal can be requested.');
    ApexPages.addMessage(myMsg);
    return null;
}
// Results[0] is the id of the person identified.

} else {
VolunteerFound = 'NotFound';
}
return null;
}
}