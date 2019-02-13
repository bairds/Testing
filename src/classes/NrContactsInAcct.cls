public class NrContactsInAcct {
    
    public static List<Account> countContacts(List<Id> AcctIds){
        List<Account> Accts = [select id, (select id from Contacts where Deceased__c != true) FROM Account WHERE id in :AcctIds];
        For (Account a : Accts)
        a.Nr_Contacts_In_Acct__c = a.Contacts.size();
        
	return Accts;
        
    }
}