// Added in a switch to turn off ManageContribsTrigger using custom setting Jan 2015

trigger ManageContributions on Opportunity bulk (after insert, after update, before delete, after delete) {

// If ManageContribsTrigger__c is set to true in the newsletter custom setting, then run the trigger
    Boolean TriggerOn;
    WGSettings__mdt Setting = WGHelpers.getWGSettings();
    if (setting.ManageContribsTrigger__c == null) {TriggerOn = true;
                     } else {
                         TriggerOn = setting.ManageContribsTrigger__c;
        system.debug('ManageContribsTrigger__c not null and label is ' + setting.Label);
                     }
    if (TriggerOn == true) {
    
if (trigger.isInsert || trigger.isUpdate) {
    System.debug('IsWorking is now ' + AvoidRecursiveContributionTrigger.IsWorking());  
    if(!AvoidRecursiveContributionTrigger.isWorking()) {    
        ManageContributions.AfterInsert(Trigger.New);
    }
} else if(trigger.isDelete && trigger.isBefore) {
    System.debug('IsWorking is now ' + AvoidRecursiveContributionTrigger.IsWorking());  
    if(!AvoidRecursiveContributionTrigger.isWorking()) {    
        ManageContributions.BeforeDelete(Trigger.Old);
    }
    } else if(trigger.isDelete && trigger.isAfter) {
    System.debug('IsWorking is now ' + AvoidRecursiveContributionTrigger.IsWorking());  
    if(!AvoidRecursiveContributionTrigger.isWorking()) {    
        ManageContributions.AfterDelete();
    }
}
    } // end the if custom setting == true
}