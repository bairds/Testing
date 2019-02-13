trigger ManageCnPDataTrigger on CnP_PaaS_Bridge__CnPData__c (before insert, after insert, before delete) {
//enums declared in separate class - 
 
//     if(Trigger.isInsert && Trigger.isBefore){
//            ManageCnPDataController.BeforeInsert(Trigger.New,Trigger.Old); 
//        }
    if(Trigger.isInsert && Trigger.isAfter){
        ManageCnPData MCD = new ManageCnPData();
        MCD.AfterInsert(Trigger.New,Trigger.Old); 
    }

}