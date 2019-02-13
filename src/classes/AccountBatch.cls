global with sharing class AccountBatch implements Database.Batchable<sObject>, 
	Database.AllowsCallouts, Database.Stateful
{
    global AccountCustom acl;
    
    global AccountBatch(AccountCustom acl)
    {
        this.acl = acl;        
        this.acl.setHUCURL();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {       
        return Database.getQueryLocator(this.acl.query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        this.acl.accounts = (List<Account>) scope;
        this.acl.processUpdatedHUCAccounts();
    }
    
    global void finish(Database.BatchableContext BC)
    {
        this.acl.sendEmail();        
    }
    
    webservice static void updateHUCs()
    {        
        Id batchId = Database.executeBatch(new AccountBatch(AccountCustom.getUpdatedHUCAccounts(null)), 25);
    }
}