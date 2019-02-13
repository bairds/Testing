// Baird August 2018
// BUILT FROM RECALCACCOUNTINVOKEBATCH

public with sharing class recalcContactInvokeBatch {
    public String querystring;
        
        public pageReference invokeBatch() {
            // Get the names of al the record types
            querystring = 'select id from Account';
                recalcContactBatch RCB = new recalcContactBatch();
                RCB.query = querystring;
                System.debug('Query is ' + RCB.query);
            
// Invoke the batch job. 
    
        ID batchprocessid = Database.executeBatch(RCB);
        System.debug('Returned batch process ID: ' + batchProcessId);
        return null;
        }
        
public PageReference Finished(){
         pagereference pr = new pagereference('/001/o');
        return pr;
 }       

}