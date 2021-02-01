public class requestHUCInvokeBatch {
        
        public pageReference invokeBatch() {
            // Get the names of al the record types
            string querystring = 'SELECT id, HUC_Status__c, AcctLatitude__c, AcctLongitude__c from Account where HUC_Status__c <> \'Current\' ORDER BY HUC_Status__c';
    		requestHUCBatch rHB = new requestHUCBatch();
                rHB.squery = querystring;
                System.debug('Query is ' + rHB.squery);
            
// Invoke the batch job. 
    
        ID batchprocessid = Database.executeBatch(rHB, 25);
        System.debug('Returned batch process ID: ' + batchProcessId);
        return null;
        }
        
public PageReference Finished(){
         pagereference pr = new pagereference('/001/o');
        return pr;
 }       

}