/*
With reference to Steve Andersen's post:
http://gokubi.com/archives/two-interesting-ways-to-architect-apex-triggers
//PNC 4/12/2010
*/
 
//trigger ManageContacts on Contact (after insert, after update, before insert, before update, after delete) {
trigger ManageContacts on Contact (before insert, before update, after update, after insert, before delete, after delete) {
    //enums declared in separate class - 

    if (Trigger.isBefore && Trigger.isInsert) {
        if (WGHelpers.getManageContactsSetting()) {
            ManageContacts.BeforeInsert(Trigger.New);
        }
    }

    if (Trigger.isBefore && Trigger.isUpdate) {
        //  List<WGSettings__mdt> WGSettings = [select ManageContacts__c from WGSettings__mdt WHERE DeveloperName = 'WGDefault' limit 1];
        if (WGHelpers.getManageContactsSetting()) {
            List<Contact> NewContacts = new List<Contact>();
            List<Contact> OldContacts = new List<Contact>();
            for (Contact ctct : Trigger.new) {
                if (Trigger.NewMap.get(ctct.Id).email != Trigger.OldMap.get(ctct.Id).email ||
                        Trigger.NewMap.get(ctct.Id).Preferred_Email__c != Trigger.OldMap.get(ctct.Id).Preferred_Email__c ||
                        Trigger.NewMap.get(ctct.Id).Personal_Email__c != Trigger.OldMap.get(ctct.Id).Personal_Email__c ||
                        Trigger.NewMap.get(ctct.Id).Work_Email__c != Trigger.OldMap.get(ctct.Id).Work_Email__c ||
                        Trigger.NewMap.get(ctct.Id).Other_Email__c != Trigger.OldMap.get(ctct.Id).Other_Email__c) {
                    NewContacts.add(ctct);
                    system.debug('Emails have changed.');
                }
                OldContacts.add(Trigger.oldMap.get(ctct.Id));
            }
            system.debug('NewContacts is ' + NewContacts);
            system.debug('OldContacts is ' + OldContacts);
            ManageContacts.BeforeUpdate(NewContacts, OldContacts);
        }
    }

    if (Trigger.isBefore && Trigger.isDelete) {
        ManageContacts.beforeDelete(Trigger.new, Trigger.old);
    }

    if (Trigger.isAfter && Trigger.isDelete) {
        ManageContacts.afterDelete(Trigger.old);
    }
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        //Only run trigger if setting is true.  Turn setting off for data load.
        Boolean LeadNotBeingConverted;
        system.debug('WGHelpers.getManageContactsSetting() is ' + WGHelpers.getManageContactsSetting());
        if (WGHelpers.getManageContactsSetting()) {
/*        Boolean TriggerOn;
        WGSettings__mdt Setting = WGHelpers.getWGSettings();
        if (setting == null) {TriggerOn = true;
                             } else {
                                 TriggerOn = setting.ManageContacts__c;
                             }

 */
            //Only run trigger if this isn't the case of a lead being converted
            //That has its own rules and creates its own ACR - needs verification
            if (ConvertLeadToContact.leadBeingConverted == null) {
                LeadNotBeingConverted = true;
            } else {
                LeadNotBeingConverted = !ConvertLeadToContact.leadBeingConverted;
            }
            if (LeadNotBeingConverted) {
                {
                    if (Trigger.isInsert && Trigger.isAfter) {
                        if (!AvoidRecursiveContactTrigger.isWorking()) {
                            ManageContacts.AfterInsert(Trigger.New, Trigger.Old);
                        }
                    }
                }
            }
        }

    }
}