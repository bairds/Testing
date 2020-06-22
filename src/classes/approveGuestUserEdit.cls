/**
 * Created by Baird on 6/16/2020.
 */

public with sharing class approveGuestUserEdit {

Public Id GuuId;
Public GuestUserUpdate__c GUU {get;set;}
Public Contact Ctct {get;set;}
Public Boolean NoGUUFound { get; set; }
Public Boolean NoContactFound { get; set; }
Public Boolean ContactProcessed {get; set;}

public approveGuestUserEdit() {
if (ApexPages.currentPage().getParameters().get('guuid') != null) {
GuuId = ApexPages.currentPage().getParameters().get('guuid');
Try {
GUU = [
SELECT Id, Email__c, FirstName__c,Processed_By__c,
LastName__c,HomePhone__c,MailingCity__c,MailingStreet__c,MailingState__c,
MailingPostalCode__c,MobilePhone__c,OwnerId,Phone__c,RelatedContact__c,
State__c,Status__c,GUUOwner__c
FROM GuestUserUpdate__c
where Id = :GuuId
];
Try {
if (GUU.RelatedContact__c != null) {
Ctct = [
SELECT Id, Email, FirstName, LastName, HomePhone,MobilePhone,OwnerId,
MailingCity,MailingStreet,MailingState,MailingPostalCode,Phone
FROM Contact
where Id = :GUU.RelatedContact__c
];
system.debug('Ctct is ' + Ctct);
}
} catch(QueryException ex){
NoContactFound = true;
ApexPages.Message NoCtct = new ApexPages.Message(ApexPages.Severity.Warning, 'Found no linked contact, error message is '+ex);
ApexPages.addMessage(NoCtct);
}
} catch(QueryException ex) {
NoGUUFound = true;
ApexPages.Message NoGUU = new ApexPages.Message(ApexPages.Severity.Warning, 'Found bad Guest User Update Id in URL, error message is '+ex);
ApexPages.addMessage(NoGUU);
}
} else {
NoGUUFound = true;
ApexPages.Message NoGUU = new ApexPages.Message(ApexPages.Severity.Warning, 'Found no Guest User Update Id in URL.');
ApexPages.addMessage(NoGUU);
}
ContactProcessed=false;
}

public PageReference approveEdits(){
GUU.Processed_By__c = UserInfo.getUserId();
GUU.Status__c = 'Processed';
GUU.GUUOwner__c = Ctct.OwnerId;
Ctct.Email = GUU.Email__c != null ? GUU.Email__c : Ctct.Email;
Ctct.FirstName = GUU.FirstName__c != null ? GUU.FirstName__c : Ctct.FirstName;
Ctct.LastName = GUU.LastName__c != null ? GUU.LastName__c : Ctct.LastName;
Ctct.HomePhone = GUU.HomePhone__c != null ? GUU.HomePhone__c : Ctct.HomePhone;
Ctct.MailingCity = GUU.MailingCity__c != null ? GUU.MailingCity__c : Ctct.MailingCity;
Ctct.MailingStreet = GUU.MailingStreet__c != null ? GUU.MailingStreet__c : Ctct.MailingStreet;
Ctct.MailingState = GUU.MailingState__c != null ? GUU.MailingState__c : Ctct.MailingState;
Ctct.MailingPostalCode = GUU.MailingPostalCode__c != null ? GUU.MailingPostalCode__c : Ctct.MailingPostalCode;
Ctct.MobilePhone = GUU.MobilePhone__c != null ? GUU.MobilePhone__c : Ctct.MobilePhone;
Ctct.Phone = GUU.Phone__c != null ? GUU.Phone__c : Ctct.Phone;
Update Ctct;
Update GUU;
ContactProcessed = true;
return null;
}

public PageReference cancelEdits(){
GUU.Processed_By__c = UserInfo.getUserId();
GUU.Status__c = 'Rejected';
Update GUU;
ContactProcessed = true;
PageReference ref = new PageReference('/003');
return null;
}
}