trigger ContactBeforeAfterInsert on Contact (before insert, after insert) 
{    
    /*
    //Only run trigger if setting is true.  Turn setting off for data load.
    Boolean TriggerOn;
    WG_settings__c setting = WG_settings__c.getInstance('newsletter');
    if (setting == null) {TriggerOn = true;
                         } else {
                             TriggerOn = setting.ContactBeforeAfterInsertTrigger__c;
                         }
    if (TriggerOn == true  && AvoidRecursiveContactTrigger.isWorking() != true) 
    {
        ContactCustom cc = new ContactCustom(trigger.new);
        
        if(!ConvertLeadToContact.leadBeingConverted) {
            if(trigger.isBefore)
                cc.processBeforeInsert();
            else
                cc.processAfterInsert();
        }
    }
*/
}