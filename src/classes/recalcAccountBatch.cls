global class recalcAccountBatch implements Database.Batchable<sObject>{
    // These two values are available to each instance of the batch below.
    // Otherwise values are reset to null at the beginning of every instance of the batch.
    public String query;
    public Id UnknownCampaignId;

    global database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        // Get the variable above and insert it into the batch instance.field
        ManageContributions.UnknownCampaignId = this.UnknownCampaignId;
        Set<ID> AcctIDs = new Set<ID>();
        for (sObject s : scope) {
            AcctIDs.add((id)s.get('id'));
        }
        ManageContributions.recalcAccountMethod(AcctIDs);
    }

    global void finish(Database.BatchableContext BC){
        // Here we invoke the recalcContactBatch after the recalcAccount is done.
        recalcContactBatch RCB = new recalcContactBatch();
        RCB.query = 'select id from Contact';
        System.debug('Query is ' + RCB.query);
        ID batchprocessid = Database.executeBatch(RCB);
        // The email is sent from recalcContactBatch
    }
/*
    webservice static void recalcGiving()
    {
        recalcAccountBatch RAB = new recalcAccountBatch();
        RAB.query = 'select id from Account';

        Id batchId = Database.executeBatch(RAB);
    }
    */
}