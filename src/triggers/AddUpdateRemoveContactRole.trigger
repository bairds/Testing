trigger AddUpdateRemoveContactRole on Opportunity (after insert, after update) {
    
    // New opportunity contact role inserts
    List<OpportunityContactRole> ocrInsertList = new List<OpportunityContactRole>();
        
    // Opportunity contact role removals
    List<OpportunityContactRole> ocrRemoveList = new List<OpportunityContactRole>();
    List<String> opportunityRemoveIds = new List<String>(); 
 
    
    if(trigger.isInsert) {
        for(Opportunity o : trigger.new) {
            if(o.Contact__c!=NULL){
                OpportunityContactRole ocr = new OpportunityContactRole();
                ocr.ContactId = o.Contact__c;
                ocr.IsPrimary=TRUE;
                ocr.OpportunityId=o.id;
                ocr.Role='Contributor';
                
                ocrInsertList.add(ocr);
            }
        }

    }
    
    else {
        for (Integer x=0; x < trigger.size; x++) {
            if(trigger.old[x].Contact__c==NULL && trigger.new[x].Contact__c!=NULL) {
                // No primary contributor on previous save.  Insert a new contact record for new primary contributor.
                OpportunityContactRole ocr = new OpportunityContactRole();
                ocr.ContactId = trigger.new[x].Contact__c;
                ocr.IsPrimary=TRUE;
                ocr.OpportunityId=trigger.new[x].id;
                ocr.Role='Contributor';
                
                ocrInsertList.add(ocr);
            }
            
            else if (trigger.old[x].Contact__c != trigger.new[x].Contact__c) {
                if(trigger.new[x].Contact__c==NULL) {
                    // Primary contributor has been removed from the opportunity
                    opportunityRemoveIds.add(trigger.new[x].id);
                }
                else {
                    // Primary contributor has changed on an existing opportunity to a different primary contributor
                    // Remove the existing primary opportunity contact role
                    opportunityRemoveIds.add(trigger.new[x].id);
                    
                    // Add a new contact role for the updated primary contributor
                    OpportunityContactRole ocr = new OpportunityContactRole();
                    ocr.ContactId = trigger.new[x].Contact__c;
                    ocr.IsPrimary=TRUE;
                    ocr.OpportunityId=trigger.new[x].id;
                    ocr.Role='Contributor';
                    
                    ocrInsertList.add(ocr);                                     
                }

            }
        }
        
    }
    
    // Remove opportunity contact roles for all opportunity id's in opportunityRemoveIds list
    if(opportunityRemoveIds.size()>0) {
        OpportunityContactRole[] ocrToRemove = [select Id from OpportunityContactRole where OpportunityId in : opportunityRemoveIds and IsPrimary=TRUE];
        for(OpportunityContactRole ocrRemove : ocrToRemove) {
            ocrRemoveList.add(ocrRemove);
        }
            
        if(ocrRemoveList.size()>0) {
            delete ocrRemoveList;   
        }
    }

    // Insert new contact roles
    if(ocrInsertList.size()>0) {
        insert ocrInsertList;
    }
}