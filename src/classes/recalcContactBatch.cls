global class recalcContactBatch implements Database.Batchable<sObject>{
public String query;
	
global database.querylocator start(Database.BatchableContext BC){
	return Database.getQueryLocator(query);
	}

global void execute(Database.BatchableContext BC, List<sObject> scope){
// List<account> accountResults = new List<Account>();

Set<ID> CtctIDs = new Set<ID>();
	for (sObject s : scope) {
		CtctIDs.add(s.id);
		}
    ManageContributions.recalcContactMethod(CtctIDs);
}

global void finish(Database.BatchableContext BC){
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setTargetObjectId(UserInfo.getUserId());
    mail.setReplyTo('baird@leadgreen.org');
    mail.setSenderDisplayName('WaterGrass');
    mail.setSubject('Account and Contact giving fields have been recalculated');
    mail.setPlainTextBody('Account and contact giving totals have been recalculated for the ' + UserInfo.getOrganizationName() + '. They will be accurate unless you have added new contributions since you clicked the Recalculate Contact Giving button.');
    mail.saveAsActivity = false;
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
    
/*    Not sure why Joses created this.
    webservice static void recalcGiving()
    { 
         recalcContactBatch RCB = new recalcContactBatch();
          RCB.query = 'select id from Contact';
        
        Id batchId = Database.executeBatch(RCB);
    }*/
}