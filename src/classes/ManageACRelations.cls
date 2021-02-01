/**
 * Created by Baird on 1/27/2021.
 */

public with sharing class ManageACRelations {

    public static void BeforeInsert(List<AccountContactRelation> TriggerNew) {

        // Create TriggerNew AccountMap <id,Boolean>
        Map<Id, String> AccountPrimaryMap = new Map<Id, String>(); // accountid to AccountContactRelationshipId
        For (AccountContactRelation acr : TriggerNew) {
            AccountPrimaryMap.put(acr.accountId, null);
        }
        Map<Id, AccountContactRelation> LACRMap = new Map<Id, AccountContactRelation>([
                SELECT Id, AccountId,ContactId, IsPrimary__c
                from AccountContactRelation
                WHERE AccountId in:AccountPrimaryMap.keyset() AND IsPrimary__c = true
        ]);
        System.debug('LaCRMap is ' + LACRMap);

        For (AccountContactRelation acr : LACRMap.values()) {
            AccountPrimaryMap.put(acr.AccountId, acr.id);
        }
        system.debug('AccountPrimaryMap is ' + AccountPrimaryMap);
        // Is the new record marked as primary?
        For (AccountContactRelation acrel : TriggerNew) {
            If (AccountPrimaryMap.get(acrel.AccountId) == null) {
                system.debug('Line 30, acrel is ' + acrel);
                acrel.IsPrimary__c = true;
                AccountPrimaryMap.put(acrel.accountId, 'ACRUpdatedAlready');
                // If this account was just updated by the clause above, then
                // acrel.IsPrimary__c must have been false fro all, and we should just leave it.
            } else {
                // Else we know one or more ACRelations have IsPrimary__c==true.
                //If IsPrimary__c == true and no other ACRelation has been set to primary
                if (acrel.IsPrimary__c == true && AccountPrimaryMap.get(acrel.AccountId) != 'ACRUpdatedAlready') {
                    // leave acrel.IsPrimary__c as true and set AccountPrimaryMap
                    // so no other AccountContactRelation will be set to Primary
                    AccountPrimaryMap.put(acrel.AccountId, 'ACRUpdatedAlready');
                    // Else if IsPrimary__c == false or there's already a primary
                } else {
                    acrel.IsPrimary__c = false;
                }
            }
        }
    }
}
