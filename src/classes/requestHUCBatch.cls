public class requestHUCBatch implements Database.Batchable<sObject>, 
	Database.AllowsCallouts
{
	public string squery;
    public integer countToProcess = 0;
    public integer countProcessed = 0;
    public integer countSucceeded = 0;
    public integer countFailed = 0;
    public boolean FailedWLatestURL = false;
        
    public Database.QueryLocator start(Database.BatchableContext BC)
    {     
        return Database.getQueryLocator(squery);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        avoidDMLDuringHUC.setCallingOut();
        List<account> AccountsToProcess = (List<Account>) scope;
        countToProcess = AccountsToProcess.size();
        For (Account a : AccountsToProcess) { 
            countProcessed ++;
        	ApexPages.StandardController sc = new ApexPages.StandardController(a);
            requestHUCValues RHV = new requestHUCValues(sc);
            if (RHV.FailedWLatestURL == true) break;
            a = RHV.requestHUC(a);
            if (a.HUC_Status__c=='Current') {
                countSucceeded ++;
            } else countFailed ++;
        }
        update AccountsToProcess;
        avoidDMLDuringHUC.setDoneCallingOut();
        
    }
    
    public void finish(Database.BatchableContext BC)
    {
        sendEmail();        
    }
    
        
    public void sendEmail()
    {

        String[] to = new String[] { System.UserInfo.getUserEmail() };                  
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setBccSender(false);                        
        mail.setUseSignature(false);
        integer countRemaining = countToProcess - countProcessed;
        
        mail.setSenderDisplayName('WaterGrass');
        mail.setReplyTo('baird@watergrass.org');    
        mail.setToAddresses(to);
        mail.setSubject('Batch Account Watershed Update Results');
        
        mail.setHtmlBody('<h1> Accounts HUC Update Summary </h1>' +
                         '<p> Processed: ' + countProcessed + '</p>' +
                         '<p> Succeded: ' + countSucceeded + '</p>' +
                         '<p> Failed: ' + countFailed + '</p>' +
                         '<p> Remaining to Process: ' + countRemaining );
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }  
}