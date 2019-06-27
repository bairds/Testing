/**
 * Created by Baird on 5/8/2019.
 * Built on a Case standard controller, so that it can be called from the Case page
 */

public with sharing class NewCaseContact {
    private final SObject parent;
    public case theCase;
    public CaseContactRole newCaseContactRole {get; set;}
    public Account newAccount { get; set; }
    public Contact newContact {get; set;}
    public Id personId { get; set; }


    public NewCaseContact(ApexPages.StandardController stdController) {
        parent = stdController.getRecord();
        newAccount = new Account();
        newContact = new Contact();
        newCaseContactRole = new CaseContactRole(
                CasesId = parent.Id
        );
    }


    public void cancelContact() {
    }

    public pageReference savePerson() {
// If this is a new contact in an existing account, save it;
        system.debug('just before SavePerson(), newContact is ' + newContact);
        if (newContact.AccountId != null) {
            try {
                Insert NewContact;
            } catch(Exception ex){
                ApexPages.addMessages(ex);
            }
        }
// else create a lead
        else {
            List<string> results = identifyOrCreatePerson.identifyorCreatePerson(newContact);
            personId = results[0];
        }
        createNewCaseRole();
        return null;
    }

    public void AddToList(Id PersonId) {
        decimal x = 0;
    }

    private void createNewCaseRole() {
        try {
            newCaseContactRole.contactId = NewContact.Id;
            system.debug('newCaseContactRole is ' + newCaseContactRole);
            insert newCaseContactRole;
            newAccount.clear();
            newContact.clear();
        } catch(System.Exception ex){
            ApexPages.addMessages(ex);
        }
    }
}