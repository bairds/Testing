/**
 * Created by Baird on 6/17/2020.
 */

public with sharing class morph1EmailTo3InvokeBatchForContacts {

public pageReference invokeBatch() {
// Get the names of al the record types
string querystring = 'select id from Contact';
morph1EmailTo3Batch m1E3B = new morph1EmailTo3Batch();
m1E3B.query = querystring;
System.debug('Query is ' + m1E3B.query);

// Invoke the batch job.

ID batchprocessid = Database.executeBatch(m1E3B);
System.debug('Returned batch process ID: ' + batchProcessId);
return null;
}

public PageReference Finished(){
pagereference pr = new pagereference('/003/o');
return pr;
}

}