public class fillMissingACRsInvokeBatch {
        
        public pageReference invokeBatch() {
            // Get the names of al the record types
            string querystring = 'select id, name from Account where id not in (select accountid from AccountContactRole where isPrimary = true)';
                fillMissingACRsBatch FMAB = new fillMissingACRsBatch();
                FMAB.query = querystring;
                System.debug('Query is ' + FMAB.query);
            
// Invoke the batch job. 
    
        ID batchprocessid = Database.executeBatch(FMAB);
        System.debug('Returned batch process ID: ' + batchProcessId);
        return null;
        }
        
public PageReference Finished(){
         pagereference pr = new pagereference('/001/o');
        return pr;
 }       

}