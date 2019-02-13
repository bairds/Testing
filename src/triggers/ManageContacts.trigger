/*
With reference to Steve Andersen's post:
http://gokubi.com/archives/two-interesting-ways-to-architect-apex-triggers
//PNC 4/12/2010
*/
 
//trigger ManageContacts on Contact (after insert, after update, before insert, before update, after delete) { 
trigger ManageContacts on Contact (before insert, after insert, before delete, after delete) { 
    //enums declared in separate class - 

    if(Trigger.isBefore && Trigger.isInsert) {
             ManageContacts.BeforeInsert(Trigger.New); 
    }
  
   if(Trigger.isBefore && Trigger.isDelete){
      ManageContacts.beforeDelete(Trigger.new,Trigger.old ); 
   }
  
   if(Trigger.isAfter && Trigger.isDelete){
      ManageContacts.afterDelete(Trigger.old); 
}       
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        //Only run trigger if setting is true.  Turn setting off for data load.
        Boolean TriggerOn;
        Boolean LeadNotBeingConverted;
        WGSettings__mdt Setting = WGHelpers.getWGSettings();
        if (setting == null) {TriggerOn = true;
                             } else {
                                 TriggerOn = setting.ContactBeforeAfterInsertTrigger__c;
                             }
        //Only run trigger if this isn't the case of a lead being converted
        //That has its own rules and creates its own ACR - needs verification
        if (ConvertLeadToContact.leadBeingConverted==null) {
            LeadNotBeingConverted=true;
        } else {
            LeadNotBeingConverted=!ConvertLeadToContact.leadBeingConverted;
        }
        if (TriggerOn && LeadNotBeingConverted) { 
            {
                if(Trigger.isInsert && Trigger.isAfter){
                        if(!AvoidRecursiveContactTrigger.isWorking()) { 
                    ManageContacts.AfterInsert(Trigger.New,Trigger.Old); 
                   }
                }
            }
        }
    }

  
/*    if(Trigger.isInsert && Trigger.isAfter){
        ManageContacts.afterInsert(Trigger.New,Trigger.Old); 
    }
     
    if(Trigger.isUpdate && Trigger.isBefore){
        ManageContacts.beforeUpdate(Trigger.new, Trigger.old);
    }  
    
    if(Trigger.isUpdate && Trigger.isAfter){
          ManageContacts.afterUpdate(Trigger.new, Trigger.old);
    }  
    
*/
}