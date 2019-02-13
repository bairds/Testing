public class fillMissingACRs {
    Public List<Account> AccountsWithoutACR;
    
    public fillMissingACRs(){
    }

    public Set<Account> findAccountsWithoutACR(){
        system.debug('Beginning findAccountsWithoutACR all ACRs are ' + [select id, accountId, ContactId, isPrimary from AccountContactRole]);
        List<Account> AccountsWACR = [select id from Account where id in (select accountId from AccountContactRole
                                      where isPrimary=true)];
        system.debug('AccountsWACR is ' + AccountsWACR);
        system.debug('Found ' + AccountsWACR.size() + ' accounts with Primary ACRs.');
        // This pulls only Accounts with PrimaryACR but with Contacts
        AccountsWithoutACR = [select id, (select id, CreatedDate from Contacts ORDER BY CreatedDate), (select id, CreatedDate from AccountContactRoles ORDER BY CreatedDate) FROM Account where id NOT IN :AccountsWACR];
        system.debug('Found ' + AccountsWithoutACR.size() + ' accounts without ACRs.');
        // Remove accounts without Contacts
        List<Account> AccountsWithoutACR2 = new List<Account>();
        for (Account a : AccountsWithoutACR) {
            if (a.Contacts != null) AccountsWithoutACR2.add(a);
        }
        if (AccountsWithoutACR2.size() < 1) {
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Found no Accounts with Contacts and without Primary AccountContactRole.'));
        }
		set<Account> AccountsWithoutACRSet = new Set<Account>();
        AccountsWithoutACRSet.addAll(AccountsWithoutACR2);
        return AccountsWithoutACRSet;
    }
    
    public Integer fillMissingACRs(Set<Account> AccountsWithoutACRPrep){
        AccountsWithoutACR = [select id, (select id, CreatedDate from Contacts ORDER BY CreatedDate), (select id, CreatedDate from AccountContactRoles ORDER BY CreatedDate) FROM Account where id IN :AccountsWithoutACRPrep];
        List<AccountContactRole> UpdateACRs = new List<AccountContactRole>();
        For (Account a : AccountsWithoutACR) { 
            // If ACRs already exist take the oldest one and make it primary
            if (a.AccountContactRoles.size() > 0){
                a.AccountContactRoles[0].isPrimary = true;
                UpdateACRs.add(a.AccountContactRoles[0]);
            } else {
                //Find oldest contact
                Contact OldestContact = new Contact();
                if (a.Contacts.size() != 0) {
                    system.debug('Just before error on 42, a.Contacts is ' + a.Contacts);
                    OldestContact = a.Contacts[0];
                    UpdateACRs.add(new AccountContactRole(ContactId=OldestContact.Id,AccountId=a.Id,isPrimary=true, Role='Decision Maker'));
                }
            }           
        }
        if (UpdateACRs.size() > 0) {
            upsert UpdateACRs;
    		return UpdateACRs.size();
        } else {
            return 0;
        }
}
}