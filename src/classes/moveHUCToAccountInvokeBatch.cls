// PULLS FROM CUSTOM SETTING THE LIST OF OPPORTUNITY RECORD TYPES WHICH SHOULD BE INCLUDED
// IN THE CONTACT GIVING TOTALS;  CREATES SOQL QUERY TO CREATE A LIST OF THOSE RECORD TYPE NAMES;
// CREATES QUERY RGB BATCH

// PETER RECOMMENDS QUERYING FOR THE NUMBER OF BATCHES ALREADY RUNNING
// AND POSTPONING THIS BATCH IF 5 ARE ALREADY RUNNING.  AND POLLING.
// HE'LL SEND ME THAT CODE.

public class moveHUCToAccountInvokeBatch {
    public String querystring;
        
        public pageReference invokeBatch() {
            querystring = 'select id from Account LIMIT 100';
                moveHUCToAccountBatch MHAB = new moveHUCToAccountBatch();
                MHAB.query = querystring;
                System.debug('query is ' + MHAB.query); 
            
// Invoke the batch job. 
    
        ID batchprocessid = Database.executeBatch(MHAB);
        System.debug('Returned batch process ID: ' + batchProcessId);
        return null;
        }
        
public PageReference Finished(){
         pagereference pr = new pagereference('/001/o');
        return pr;
 }       

}