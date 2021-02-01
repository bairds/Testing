/**
 * Created by Baird on 1/22/2021.
 */

public with sharing class ManageOppContactRs {

    // Trigger picks out OCRs where isPrimary=true;
    public static void afterInsertRole(OpportunityContactRole [] OCRs) {
        List<Opportunity> UpdateOpps = new List<Opportunity>();
        List<Id> OppIds = new List<Id>();
        Map<Id, Id> OCRMap = new Map<Id, Id>();
        FOR (OpportunityContactRole ocr : OCRs) {
            OCRMap.put(ocr.OpportunityId, ocr.contactId);
        }
        UpdateOpps = [
                SELECT Id,Contact__c
                FROM Opportunity
                WHERE Contact__c = NULL AND Id IN:OCRMap.keySet()
        ];
        for (Opportunity o : UpdateOpps) {
            o.Contact__c = OCRMap.get(o.Id);
        }
        AvoidRecursiveContributionTrigger.setWorking();
        Update UpdateOpps;
        AvoidRecursiveContributionTrigger.setClosed();
    }

    public static void BeforeInsertRelationship(List<OpportunityContactRelation> TriggerNew, List<OpportunityContactRelation> TriggerOld){}
}