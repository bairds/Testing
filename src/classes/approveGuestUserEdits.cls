/**
 * Created by Baird on 7/17/2020.
 */

public with sharing class approveGuestUserEdits {

    Public Id GuuId;
    Public List<GuestUserUpdate__c> GUUs { get; set; }
    Public List<Contact> Ctcts { get; set; }
    public Map<Id,Contact> CtctMap {get; set;}
    Public Boolean NoGUUFound { get; set; }
    Public Boolean NoContactFound { get; set; }
    Public Boolean ContactProcessed { get; set; }

    public approveGuestUserEdits() {
        GUUs = [
                SELECT Id, Email__c, FirstName__c,Processed_By__c,
                        LastName__c,HomePhone__c,MailingCity__c,MailingStreet__c,MailingState__c,
                        MailingPostalCode__c,MobilePhone__c,OwnerId,Phone__c,RelatedContact__c,
                        State__c,Processing_Status__c,GUUOwner__c
                FROM GuestUserUpdate__c
                where Processing_Status__c = 'Review'
        ];
        if (GUUs != null) {
            List<Id> CtctIds = new List<Id>();
            for (GuestUserUpdate__c GUU : GUUs) {
                // Set all the Processing_Status to Approved to make it easier for users
                // to simply check off the changes they reject.
                GUU.Processing_Status__c = 'Approved';
                CtctIds.add(GUU.RelatedContact__c);
            }
            CtctMap =  new Map<Id,Contact>([
                    SELECT Id, Email, FirstName, LastName, HomePhone,MobilePhone,OwnerId,
                            MailingCity,MailingStreet,MailingState,MailingPostalCode,Phone
                    FROM Contact
                    where Id = :CtctIds
            ]);
        }
        else {
            NoGUUFound = true;
            ApexPages.Message NoGUU = new ApexPages.Message(ApexPages.Severity.Warning, 'Found no Guest User Updates that need processing.');
            ApexPages.addMessage(NoGUU);
        }
        ContactProcessed = false;
        system.debug('GuestUserUpdate List is ' + GUUs);
        system.debug('CtctMap is ' + CtctMap);
    }

    public PageReference submitEdits() {
        for (GuestUserUpdate__c GUU : GUUs) {
            if (GUU.Processing_Status__c == 'Approved') {
                GUU.Processed_By__c = UserInfo.getUserId();
                GUU.GUUOwner__c = CtctMap.get(GUU.RelatedContact__c).OwnerId;
                CtctMap.get(GUU.RelatedContact__c).Email = GUU.Email__c != null ? GUU.Email__c : CtctMap.get(GUU.RelatedContact__c).Email;
                CtctMap.get(GUU.RelatedContact__c).FirstName = GUU.FirstName__c != null ? GUU.FirstName__c : CtctMap.get(GUU.RelatedContact__c).FirstName;
                CtctMap.get(GUU.RelatedContact__c).LastName = GUU.LastName__c != null ? GUU.LastName__c : CtctMap.get(GUU.RelatedContact__c).LastName;
                CtctMap.get(GUU.RelatedContact__c).HomePhone = GUU.HomePhone__c != null ? GUU.HomePhone__c : CtctMap.get(GUU.RelatedContact__c).HomePhone;
                CtctMap.get(GUU.RelatedContact__c).MailingCity = GUU.MailingCity__c != null ? GUU.MailingCity__c : CtctMap.get(GUU.RelatedContact__c).MailingCity;
                CtctMap.get(GUU.RelatedContact__c).MailingStreet = GUU.MailingStreet__c != null ? GUU.MailingStreet__c : CtctMap.get(GUU.RelatedContact__c).MailingStreet;
                CtctMap.get(GUU.RelatedContact__c).MailingState = GUU.MailingState__c != null ? GUU.MailingState__c : CtctMap.get(GUU.RelatedContact__c).MailingState;
                CtctMap.get(GUU.RelatedContact__c).MailingPostalCode = GUU.MailingPostalCode__c != null ? GUU.MailingPostalCode__c : CtctMap.get(GUU.RelatedContact__c).MailingPostalCode;
                CtctMap.get(GUU.RelatedContact__c).MobilePhone = GUU.MobilePhone__c != null ? GUU.MobilePhone__c : CtctMap.get(GUU.RelatedContact__c).MobilePhone;
                CtctMap.get(GUU.RelatedContact__c).Phone = GUU.Phone__c != null ? GUU.Phone__c : CtctMap.get(GUU.RelatedContact__c).Phone;
                // ContactProcessed = true;
            }
        }
        Ctcts = new List<Contact>();
        For (Id i : CtctMap.keyset()) Ctcts.add(CtctMap.get(i));
        Update Ctcts;
        Update GUUs;
        PageReference ref = new PageReference('/003');
        return null;
    }
/*
    public PageReference ProcessList(){
        return null;
    }

    public PageReference rejectEdits() {
        *//*GUU.Processed_By__c = UserInfo.getUserId();
        GUU.Processing_Status__c = 'Rejected';
        ContactProcessed = true;*//*
        return null;
    }*/
}