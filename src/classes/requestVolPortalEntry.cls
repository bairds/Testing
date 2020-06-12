/**
 * Created by Baird on 6/12/2020.
 */

public without sharing class requestVolPortalEntry {

public Contact Ctct {get;set;}
public Contact Volunteer {get;set;}
public string VolunteerFound {get;set;}

public requestVolPortalEntry(){
Ctct = new Contact();
}

public PageReference submit(){
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
Try{
    OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress limit 1];

// Results[0] is the id of the person identified.
WGHelpers.sendTemplatedEmail(ToAddresses,null,'Volunteer_Portal_Link',results[0],null,owa.id,true,null);
// Messaging.reserveSingleEmailCapacity(2);
} catch(queryException qe){
    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Must set an Organization-Wide Email Address before the volunteer portal can be requested.');
    ApexPages.addMessage(myMsg);
}
} else {
VolunteerFound = 'NotFound';
}
return null;
}
}