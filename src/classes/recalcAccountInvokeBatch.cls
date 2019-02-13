// PULLS FROM CUSTOM SETTING THE LIST OF OPPORTUNITY RECORD TYPES WHICH SHOULD BE INCLUDED
// IN THE CONTACT GIVING TOTALS;  CREATES SOQL QUERY TO CREATE A LIST OF THOSE RECORD TYPE NAMES;
// CREATES QUERY RGB BATCH

// PETER RECOMMENDS QUERYING FOR THE NUMBER OF BATCHES ALREADY RUNNING
// AND POSTPONING THIS BATCH IF 5 ARE ALREADY RUNNING.  AND POLLING.
// HE'LL SEND ME THAT CODE.

public with sharing class recalcAccountInvokeBatch {
    public String querystring;

    public pageReference invokeBatch() {
        // Get the names of al the record types
        querystring = 'select id from Account';
        recalcAccountBatch RAB = new recalcAccountBatch();
        RAB.query = querystring;
        //pass UnknownCampaignId into batch using instance name.variablename
        RAB.UnknownCampaignId = WGHelpers.getUnknownCampaignID();
        System.debug('Query is ' + RAB.query);

// Invoke the batch job.

        ID batchprocessid = Database.executeBatch(RAB);
        System.debug('Returned batch process ID: ' + batchProcessId);
        return null;
    }

    public PageReference Finished(){
        pagereference pr = new pagereference('/001/o');
        return pr;
    }

}