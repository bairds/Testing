global with sharing class OpportunityBatch implements Database.Batchable<Opportunity>, 
	Database.Stateful
{
    global List<Opportunity> os;
    
    global OpportunityBatch(List<Opportunity> os)
    {
        this.os = os;
    }
    
    global Iterable<Opportunity> start(Database.BatchableContext BC)
    {       
        return this.os;
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope)
    {
        insert scope;
    }
    
    global void finish(Database.BatchableContext BC)
    {
           
    }
    
    webservice static void test()
    {        
        List<Opportunity> opps = new List<Opportunity>();
        
        for(Integer i = 6; i < 12; i++) {
         Opportunity o = new Opportunity();
        o.Name = 'Test' + i;
		o.CampaignId='70150000000epO2';
        o.StageName = 'Closed';
		o.CloseDate = Date.today();
        

        opps.add(o);
    	}
        
        Id batchId = Database.executeBatch(new OpportunityBatch(opps), 2);
    }
}