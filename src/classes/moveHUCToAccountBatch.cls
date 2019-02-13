public class moveHUCToAccountBatch implements Database.Batchable<sObject>
{
	public string query;
    public integer countToProcess = 0;
    public integer countProcessed = 0;
    public integer countSucceeded = 0;
    public integer countFailed = 0;
        
    public Database.QueryLocator start(Database.BatchableContext BC){   
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope)
    {
	List<ID> AcctIDs = new List<ID>();
	for (sObject s : scope) {
		AcctIDs.add((id)s.get('id'));
		}
        MoveHUCToAccount MHTA = new MoveHUCToAccount();
        List<Account> AccountsProcessed = MHTA.moveDataToAccounts2(AcctIds);
        system.debug('AccountsProcessed by MHA.moveDataToAccounts2 are ' + AccountsProcessed);
        update AccountsProcessed;        
    }
    
    public void finish(Database.BatchableContext BC)
    {      
    }
}