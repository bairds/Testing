public class ManageContacts {  
    
    public List<Contact> cs;
    public static List<Id> AccountIds;
    private Contact c;
    private Lead l;
    public List<string> VolunteerInterests {get; set;}
    public List<SelectOption> volunteerInterestsList {get; set;}
    // public List<Task> tasks;
    
    
    // Originally written by Peter Churchill
    // With reference to Steve Andersen's post:
    // http://gokubi.com/archives/two-interesting-ways-to-architect-apex-triggers
    // PNC 4/12/2010
    // Revised Baird 3 July 2018 to catch direct injections of contacts without accounts from other applications like EventBrite.
    
    // This method just serves to catch direct injection of contacts without accounts
    public static List<Contact> beforeInsert(Contact [] ctcts){
        system.debug('Triggernew contacts is ' + ctcts);
        List<Task> Tasks = new List<Task>();
        // First, check to see whether there are any such contacts.
        List<Contact> CtctsWoutAcct = new List<Contact>();
        for (Contact ctct: ctcts) {
            If (ctct.AccountId==null) {
                CtctsWoutAcct.add(ctct);
                system.debug('In beforeInsert method added to CtctsWoutAcct contact: ' + ctct);
            }
        }
        // If there are any contacts without accounts
        if (CtctsWoutAcct!=null) {
            List<Contact> CtctsQueuedForNewAcct = new List<Contact>();
            List<Contact> CtctsToLinkToAccts = new List<Contact>();
            List<Account> AcctsToCreate = new List<Account>();
            Map<string,Contact> CtctsWAccts;
            Map<string,Contact> ContactEmailMap = new Map<string,Contact>();
            Boolean LeadNotBeingConverted;
            List<Task> ts = new List<Task>();
            Id FamilyRTID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Family').getRecordTypeId(); 
            //These injected contacts may have emails
            For (Contact c : CtctsWoutAcct){
                If (c.email!=null) 
                {
                    ContactEmailMap.put(c.email,c);
                } else {
                    CtctsQueuedForNewAcct.add(c);
                }
            }
            if (ContactEmailMap.size()>0) {
                CtctsWAccts = new Map<string,Contact>();
                List<Contact> ContactEmailMatches = [SELECT id, firstname, lastname, email, accountId from Contact WHERE Email IN : ContactEmailMap.keyset()];
                system.debug('Does c have id? ' + ContactEmailMatches);
                for (Contact c : ContactEmailMatches) CtctsWAccts.put(c.email,c);
                
                For (Contact c : ctcts) {
                    if (CtctsWAccts.keyset().Contains(c.email)) {
                        c.AccountId = CtctsWAccts.get(c.email).AccountId;
                        // CtctsToLinkToAccts.add(c);
                    } else {
                        CtctsQueuedForNewAcct.add(c);
                    }
                }
            }
            //Update contacts which match contacts with existing accounts
            // update CtctsToLinkToAccts;
            //Create Accounts for the rest
            If (CtctsQueuedForNewAcct.size()>0) {
                for (Contact c : CtctsQueuedForNewAcct) {
                    Account a = new Account(
                        RecordTypeId = FamilyRTId,
                        Name = c.LastName + ', ' + c.FirstName + ' Household',
                        Is_Dummy__c = true,
                        Dear__c = c.Dear__c,
                        Addressee__c = c.FirstName + ' ' + c.LastName,
                        Phone = c.MobilePhone,
                        BillingStreet = c.MailingStreet,
                        BillingCity = c.MailingCity,
                        BillingState = c.MailingState,
                        BillingPostalCode = c.MailingPostalCode,
                        BillingCountry = c.MailingCountry,
                        Description='Created when contact without account was injected directly into database without searching for match & creating account.');
                    AcctsToCreate.add(a);
                    tasks.add(setTask(c,'Review New Account/Contact'));   
                }
                List<Database.saveResult> SRList = database.insert(AcctsToCreate, false);
                for (integer i=0;i<CtctsQueuedForNewAcct.size();i++) {
                    if (SRList[i].isSuccess()) {
                        CtctsQueuedForNewAcct[i].AccountId = AcctsToCreate[i].Id; 
                        system.debug('Success: CtctsQueuedForNewAcct[i] is ' + CtctsQueuedForNewAcct[i]);
                    } else {
                        for(Database.Error err : SRList[i].getErrors()) {
                            System.debug('Attempted to create new account for contact wout account.  The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
        }                    
        if(tasks.size() > 0) {
            insert tasks;
            sendEmail(tasks);
        }
        return ctcts;
    }
    
    
    
    
    
    public static void afterInsert(Contact [] contacts, Contact [] OldContacts) {
        
        //Now make sure that a new primary ACR is created if the Account doesn't already have one
        Set<Id> AllAccounts = new Set<Id> ();
        Set<Id> WithPrimaryAccounts = new Set<Id> ();
        List<AccountContactRole> NewAccountRoleContacts = new List<AccountContactRole>();
        
        for(Contact c : contacts)
        {
            AllAccounts.add(c.AccountId);
        }
        List<Account> UpdateAccts = CountCtctsInAcct(new List<Id>(AllAccounts));
        //Count up the contacts
        /*List<Account> Accts = [select id, (select id from Contacts where Deceased__c<>true AND (Active__c = 'Active' OR Active__c = 'Yes' OR Active__c = null)) FROM Account WHERE Id in :AllAccounts];
        for (Account a : Accts) {
            a.Nr_Contacts_In_Acct__c = a.Contacts.size();
        }*/
        update UpdateAccts;
        
        for (AccountContactRole acr: [Select AccountId from AccountContactRole where AccountId in : AllAccounts AND IsPrimary = TRUE]){
            WithPrimaryAccounts.add(acr.AccountId);
        }
        
        for(Contact c : contacts)
        {
            if (WithPrimaryAccounts.contains(c.AccountId)) {
                //do nothing
            }
            else
            {    
                NewAccountRoleContacts.add(new AccountContactRole (
                    AccountId = c.AccountId, 
                    ContactId = c.Id, 
                    IsPrimary = TRUE, 
                    Role = 'Decision Maker'));
                //and now we've added it, we don't want to add another, so update the list
                WithPrimaryAccounts.add(c.AccountId);                    
            }
        }
        
        if (NewAccountRoleContacts.size() > 0)
        {
            insert NewAccountRoleContacts;
        }
        //end method
    }
    
    public static void beforeDelete(Contact [] contacts, Contact [] oldcontacts) {
        AccountIds = new List<Id>();
        Set<Id> PrimaryOnAccount = new Set<Id> ();
        
        for (AccountContactRole acr: [Select ContactId from AccountContactRole where IsPrimary = TRUE AND ContactId in :oldcontacts]){
            PrimaryOnAccount.add(acr.ContactId);
        }
        
        for(Contact c : oldcontacts)
        {
            if (PrimaryOnAccount.contains(c.Id)) {    
                c.AccountId.adderror('Contact is the Primary Contact Role on an Account!  Please make another Contact Primary before deleting this one.');
            } else {
                AccountIds.add(c.AccountId);
            }
        }
        
    }
    
    public static void afterDelete(Contact[] ctcts) { 
        // Count the contacts in the accounts
        List<Account> UpdateAccounts = CountCtctsInAcct(AccountIds);
        update UpdateAccounts;
    }

    public static List<Account> CountCtctsInAcct(list<Id> AccountIds){
        List<Account> Accts = [select id, (select id from Contacts where Deceased__c<>true AND (Active__c = 'Active' OR Active__c = 'Yes' OR Active__c = null)) FROM Account WHERE Id in :AccountIds];
        for (Account a : Accts) {
            a.Nr_Contacts_In_Acct__c = a.Contacts.size();
        }
        return Accts;
    }
    
    public static Task setTask(Contact c, String s)
    {
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.WhatId = c.AccountId;
        t.Subject = s;   
        return t;
    }
    
    private static void sendEmail(List<Task> tasks)
    {    
        String body = '<h1> Summary of Processed Duplicate/New Contacts/Accounts </h1>';
        Integer count = 1;
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setBccSender(false);                        
        mail.setUseSignature(false);
        
        mail.setSenderDisplayName(System.UserInfo.getOrganizationName());
        mail.setReplyTo(System.UserInfo.getUserEmail());    
        mail.setSubject('Duplicate contacts / leads');  
        mail.setTargetObjectId(System.UserInfo.getUserId());            
        //mail.setTreatTargetObjectAsRecipient(true);
        mail.saveAsActivity = false;
        
        for(Task t : tasks) {
            body += '<table>';
            body += '<tr> <td> # </td> <td> ' + count + '</td> </tr>';
            body += '<tr> <td> task </td> <td> <a href="' + System.URL.getSalesforceBaseURL().toExternalForm() + '/' + t.id + '">' + t.Subject + '</a> </td> </tr>';
            body += '</table>';
            
            count++;
        }
    }
    
    public void setVolunteerInterests()
    {
        volunteerInterests = new String[]{};
            volunteerInterestsList = new List<SelectOption>();
        
        for(Schema.PicklistEntry ll : Contact.Volunteer_Interests__c.getDescribe().getPicklistValues())
            volunteerInterestsList.add(new SelectOption(ll.getValue(), ll.getLabel()));
    }
    
}