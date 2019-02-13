global class fillMissingACRsBatch implements Database.Batchable<sObject>, Database.Stateful{
public String query;
    Integer UpdatedRecords = 0;
	
global database.querylocator start(Database.BatchableContext BC){
	return Database.getQueryLocator(query);
	}

global void execute(Database.BatchableContext BC, List<sObject> scope){
List<Account> Accts = (List<Account>) scope;
Set<Account> AcctsSet = new Set<Account>(Accts);
//// Accts = [select id from Account];
	FillMissingACRS FMA = new FillMissingACRS();
    UpdatedRecords += FMA.FillMissingACRs(AcctsSet);
}

global void finish(Database.BatchableContext BC){
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setTargetObjectId(UserInfo.getUserId());
    mail.setReplyTo('baird@leadgreen.org');
    mail.setSenderDisplayName('WaterGrass');
    mail.setSubject('Accounts with contacts but no Primary Contact Role been recalculated');
    mail.setPlainTextBody('Primary Contact Roles have been set for the ' + UserInfo.getOrganizationName() + '.  WaterGrass updated ' + UpdatedRecords + ' AccountContactRoles. They were set to the oldest contact in each Account which was missing a Primary Contact.');
    mail.saveAsActivity = false;
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
    
webservice static void recalcACRs()
    { 
         recalcAccountBatch RAB = new recalcAccountBatch();
          RAB.query = 'select id from Account';
        
        Id batchId = Database.executeBatch(RAB);
    }
}