/*
 * Written by Baird 17 June 2018
 */
global with sharing class AccountSchedule implements Schedulable 
{
   
    global void execute(SchedulableContext ctx) 
    {   
        requestHUCBatch RHB = new requestHUCBatch();
        RHB.squery = 'SELECT id, HUC_Status__c, AcctLatitude__c, AcctLongitude__c from Account where HUC_Status__c <> \'Current\' ORDER BY HUC_Status__c';

        database.executeBatch(RHB,25);
    }

}