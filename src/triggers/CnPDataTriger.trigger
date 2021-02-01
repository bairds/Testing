/**
 * Created by Baird on 10/28/2020.
 */

trigger CnPDataTrigger on CnPData__c (before insert, before delete, after insert) {

//     if(Trigger.isInsert && Trigger.isBefore){
//            ManageCnPDataController.BeforeInsert(Trigger.New,Trigger.Old);
//        }
    if(Trigger.isInsert && Trigger.isAfter){
        ManageCnPData MCD = new ManageCnPData();
        MCD.AfterInsert(Trigger.New,Trigger.Old);
    }
}