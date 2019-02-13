global with sharing class AccountCustom 
{   
    public  List<Account> accounts;   
    public	String query;
    public	String message;
//    public  Counter count;
    private List<AccountCustom> processedAccounts;
    private List<Account> updatedAccounts;    
    
    private Account account;
    private AccountCustom ac;
/*
    public HUCCustom hc;
    private HUCCustom billingHUC;
    private HUCCustom shippingHUC;
*/
    private Account accountOld;
    public List<Account> accountsOld;
    
    public AccountCustom()
    {           
    }
/*    public AccountCustom(Counter c)
    {           
        this.count = c;
    }
*/
    public AccountCustom(Account a)
    {
        this.account = a;        
    }
    
    public AccountCustom(List<Account> al)
    {
        this.accounts = al;        
    }
/*
    private Boolean billingAddressHasChanged()
    {
        if(this.account.BillingStreet != null && (this.accountOld == null || this.account.BillingStreet != this.accountOld.BillingStreet))
            return true;
        
        return false;
    }
    
    private Boolean shippingAddressHasChanged()
    {
        if(this.account.ShippingStreet != null && (this.accountOld == null || this.account.ShippingStreet != this.accountOld.ShippingStreet))
            return true;
        
        return false;
    }
    
    public void processTrigger() 
    {        

        if(this.accounts.size() > 0) {
            Account a;
        	Boolean updated;
            this.updatedAccounts = new List<Account>();
            
            for(Integer i = 0; i < this.accounts.size(); i++) {
                this.account = this.accounts[i];
                
                if(this.accountsOld != null)
            		this.accountOld = this.accountsOld[i];                             
               
                a = new Account(Id = this.Account.Id);
                updated = false;   
                
                if(this.billingAddresshasChanged() || this.shippingAddresshasChanged()) {
                    updated = true; 
                    
                	if(this.billingAddresshasChanged())
                    	a.Billing_HUC__c = HUCCustom.getHUCId('Needs processing');
                    
                    if(this.shippingAddresshasChanged())
                    	a.Shipping_HUC__c = HUCCustom.getHUCId('Needs processing');
                }
                
                if(updated)
                	this.updatedAccounts.add(a);
            }
            
            if(this.updatedAccounts.size() > 0)
            	update this.updatedAccounts;
        }
    }
    
    webservice static String updateHUC(Id id)
    {
        if(String.isNotEmpty(id)) {
            AccountCustom acl = AccountCustom.getUpdatedHUCAccounts(id); 
            acl.setHUCURL();
            acl.processUpdatedHUCAccounts();  
            
            return acl.message;
        }
        
        return null;
    }
    
    public static AccountCustom getUpdatedHUCAccounts(Id id)
    {
        AccountCustom acl = new AccountCustom(Counter.resetRequest());
        
        String fields = 'Id, Name, BillingLatitude, BillingLongitude, ShippingLatitude, ShippingLongitude';
        String conditions = '(Billing_HUC__r.Code__c = null AND BillingLatitude != null AND BillingLongitude != null) OR ' +
            			    '(Shipping_HUC__r.Code__c = null AND ShippingLatitude != null AND ShippingLongitude != null)';
        
        if(String.isEmpty(id)) {
            acl.count.remaining = Database.countQuery('SELECT count() FROM Account WHERE ' + conditions);
            acl.query = 'SELECT ' + fields + ' FROM Account WHERE ' + conditions + ' ORDER BY LastModifiedDate DESC LIMIT 1000';
        }
        else
            acl.query = 'SELECT ' + fields + ' FROM Account WHERE (' + conditions + ') AND Id =\'' + id + '\'';
        
    	acl.accounts = Database.query(acl.query);
        
        if(acl.accounts.size() == 0)
        	acl.message = 'All HUCs up to date.';
        else {
            acl.message = '';
            acl.count.processed = acl.accounts.size();
    	}
        
        return acl;
    }
    
    public void setHUCURL()
    {
        this.hc = new HUCCustom();
        this.hc.setURL();
    }   
    
    public void processUpdatedHUCAccounts()
    {        
        this.processedAccounts = new List<AccountCustom>();
        this.updatedAccounts = new List<Account>();  
        
    	for(Account a : this.accounts)
            this.getHUC(a);
        
        for(AccountCustom ac : this.processedAccounts) {
            ac.account.Billing_HUC__c = ac.billingHUC.getHUCId();
            ac.account.Shipping_HUC__c = ac.shippingHUC.getHUCId();
            
            this.updatedAccounts.add(ac.account);
        }
        
        update this.updatedAccounts;
        update this.hc.hu;
    }
    
    private void getHUC(Account a)
    {   
        this.ac = new AccountCustom(a);
        this.ac.billingHUC = this.hc.getHUC(this.ac.account.BillingLatitude, this.ac.account.BillingLongitude);
        this.ac.shippingHUC = this.hc.getHUC(this.ac.account.ShippingLatitude, this.ac.account.ShippingLongitude);
        
        this.processedAccounts.add(this.ac);     
        
        if(String.isEmpty(this.ac.billingHUC.huc.Code__c) || String.isEmpty(this.ac.shippingHUC.huc.Code__c)) {
            this.count.failed++;  
            
            if(this.accounts.size() > 1) {
                this.message += '<p> Account: ' + this.ac.account.Name + '(' + this.ac.account.Id + ')';
                
                if(String.isEmpty(this.ac.billingHUC.huc.Code__c))
                    this.message += '<br /> Billing HUC: ' + this.ac.billingHUC.huc.Status__c;
                
                if(String.isEmpty(this.ac.shippingHUC.huc.Code__c))
                    this.message += '<br /> Shipping HUC: ' + this.ac.shippingHUC.huc.Status__c;
                
                this.message += '</p>';
            }
            else
                 this.message += '\n Billing HUC: ' + this.ac.billingHUC.huc.Status__c +
                				 '\n Shipping HUC: ' + this.ac.shippingHUC.huc.Status__c;                
        }
    }

    public void sendEmail()
    {
        this.count.succeeded = this.count.processed - this.count.failed;
        this.count.remaining = this.count.remaining - this.count.succeeded;
        
        String[] to = new String[] { System.UserInfo.getUserEmail() };      
            
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setBccSender(false);                        
        mail.setUseSignature(false);
        
        mail.setSenderDisplayName('WaterGrass');
        mail.setReplyTo('baird@watergrass.org');    
        mail.setToAddresses(to);
        mail.setSubject('Batch Account Watershed Update Results');
        
        mail.setHtmlBody('<h1> Accounts HUC Update Summary </h1>' +
                         '<p> Processed: ' + this.count.processed + '</p>' +
                         '<p> Succeded: ' + this.count.succeeded + '</p>' +
                         '<p> Failed: ' + this.count.failed + '</p>' +
                         '<p> Remaining: ' + this.count.remaining + '</p>' + 
                         this.message);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
*/
    webservice static String createContract(Id id)
    {  
        if(String.isNotEmpty(id)) {            
            Lead l = [ SELECT Id, Special_Request__c FROM Lead WHERE Id =: id ];
            Contact co = [ SELECT Id, AccountId, Account.Name FROM Contact WHERE Id =: ConvertLeadToContact.ConvertLeadToContact(id) ];
            
            Contract c = new Contract();
            c.AccountId = co.AccountId;
            
            insert c;
            
            return c.Id;
           
        }
        
        return null;
    }
}