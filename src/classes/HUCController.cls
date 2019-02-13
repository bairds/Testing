public class HUCController {
    private Account a;
    
    public String body {get; set;}
    
    public HUCController(){
		a = new Account();
        a.Name = 'test huc address ';
         
         a.BillingStreet = '1100 N. Main, Suite 210';
         a.BillingCity = 'Ann Arbor';
         a.BillingState = 'MI';
         a.BillingPostalCode = '48104';         
    }
    
     public void insertAccount() {      	
	       
        insert a;
    }
    
    public void insertAccounts() {      
        List<Account> accs = new List<Account>();
        
        accs.add(a);
        
    	Account a2 = new Account();
        a2.Name = 'test huc address 2';
         
         a2.BillingStreet = '1595 Continental St';
         a2.BillingCity = 'Beaumont';
         a2.BillingState = 'TX';
         a2.BillingPostalCode = '77706';                
      
        
        accs.add(a2);
        insert accs;
    }
}