public class AddresseeUpdateController{
	
// This controller receives a set of accounts.
// For each account orders contacts by primary and then by second and failing that by creation date
// If account type = Household takes primary and second
// Otherwise simply takes primary
// and creates addressee__c

//Set<ID> AcctIDs = new Set<ID>();

    List<AccountContactRole> UpdateACR = new List<AccountContactRole>();
    Set<ID> AcctIDSet = new Set<ID>();

    public AddresseeUpdateController(ApexPages.StandardController controller) {
	}

public List<Account> updateAddressee(Set<Account> updateSet) {
	contact firstAddressee;
	contact secondAddressee;
for (account a : updateSet) {
	AcctIDSet.add(a.id);
}

List<Account> updateAccts = [select account.id, account.name, account.RecordType.name,
      (select accountContactRole.contact.firstname, 
      accountContactRole.contact.lastname, accountContactRole.isPrimary, 
      accountContactRole.role from account.AccountContactRoles order by isPrimary) from account
		where id in :AcctIDSet];
system.debug('Found ' + updateAccts.size() + ' where addressee__c is null');
for (account a : updateAccts) {
    system.debug('Account: ' + a.name + ' has ' + a.AccountContactRoles.size() + ' AccountContactRoles.');
    //If no ACR set addressee equal to account name
    if (a.AccountContactRoles.size() == 0) {
		a.addressee__c = a.name;
		continue;}
    //If just one ACR
    if (a.AccountContactRoles.size() == 1) {
		a.addressee__c = a.AccountContactRoles[0].contact.firstname 
        + ' ' + a.AccountContactRoles[0].contact.lastname;
	// If there's only one ACR and it's not primary, make it primary
	// Note: I can't figure out how to test this, since the ACR trigger 
	// doesn't allow new contacts with setting the first to primary.
		if (a.AccountContactRoles[0].isPrimary != true) {
			a.AccountContactRoles[0].isPrimary = true;
			UpdateACR.add(a.AccountContactRoles[0]);
			} // end if ACRS[0] is false update it
		} // end if ACR.size() == 1
    //If more than one ACR
    if (a.AccountContactRoles.size() > 1) {
    firstAddressee = new contact();
    secondAddressee = new contact();
    for (AccountContactRole acr : a.AccountContactRoles) {
        system.debug('AccountContactRole ' + acr.role + ' ' + acr.contact.firstname + ' ' +
                     acr.contact.lastname + ' ' + acr.isPrimary);
        if (acr.isPrimary == true)
            firstAddressee = new Contact(
                firstname = acr.contact.firstname,
                lastname = acr.contact.lastname);
        if (acr.role == 'Second')
            secondAddressee = new Contact(
                firstname = acr.contact.firstname,
                lastname = acr.contact.lastname);
    } // end of acr loop
    if (secondAddressee  == null) {
        a.addressee__c = firstAddressee.firstname + ' ' + firstAddressee.lastname;
    } else {
        if (a.RecordType.Name == 'Family') {
            a.addressee__c = firstAddressee.firstname + ' ' + firstAddressee.lastname
                + ' and ' + secondAddressee.firstname + ' ' + secondAddressee.lastname;
        } else {
        a.addressee__c = firstAddressee.firstname + ' ' + firstAddressee.lastname;
        }
            
    } // end else secondAddressee not == null
	} // end of AccountContactRoles > 1   
} // end of account loop
if (UpdateACR.size() > 0) update UpdateACR;
update updateAccts;
return updateAccts;
} // end of updateAddressee

} // end of controller