public class createAccountAndContacts_Con 
{
    public Contact ctct {get; set;}
    public Contact ctct2 {get; set;}
    public Account acct {get; set;}
    public String aname {get;set;}
    public Boolean enterContact2 {get; set;}
    public Boolean enterDonation {get; set;}
    public Boolean createDummyContact { get; set; }  
    public String source { get; set; }
    
    public createAccountAndContacts_Con()
    {
         acct = new Account();
        acct.Contacts_in_Account__c = '1';
        
        ctct = new Contact();
        ctct2 = new Contact();
        enterContact2 = false;
        createDummyContact = false;
    }
    
    public void setContacts()
    {
        if(createDummyContact) {
            ctct.FirstName = 'Sir';
            ctct.LastName = 'Unknown';
            ctct.Dear__c = ctct.Dear__c == null ? ctct.FirstName : ctct.Dear__c;
        }
        else
            ctct = new Contact();
    }

public PageReference submit() {
    //
  	setAccount();
    insert acct;
// Only insert contacts if Contacts_in_Account__c = '1' or '2' 
    if (acct.Contacts_in_Account__c <> null) {
        System.debug('After if (ctct2.firstname==null, acct.dear__c is ' + acct.Dear__c);
        ctct.AccountId = acct.Id;
        ctct.MailingStreet = acct.BillingStreet;
        ctct.MailingCity = acct.BillingCity;
        ctct.MailingPostalCode = acct.BillingPostalCode;
        ctct.MailingState = acct.BillingState;
        ctct.Dear__c = ctct.Dear__c == null ? ctct.FirstName : ctct.Dear__c;
        if (ctct.Phone == null) ctct.Phone = acct.Phone;
        insert ctct;
        // Account is inserted, account validation tests run, etc.
        if(enterContact2) {
            ctct2.AccountId = acct.Id;
            ctct2.MailingStreet = acct.BillingStreet;
            ctct2.MailingCity = acct.BillingCity;
            ctct2.MailingPostalCode = acct.BillingPostalCode;
            ctct2.MailingState = acct.BillingState;
            ctct2.Dear__c = ctct2.Dear__c == null ? ctct2.FirstName : ctct2.Dear__c;
            if (ctct2.Phone == '') ctct2.Phone = acct.Phone;
            insert ctct2;
            AccountContactRole acr = new AccountContactRole(
                ContactId = ctct2.Id,
                AccountId = acct.Id,
                Role = 'Second contact');
                insert acr;
        }
    }
        
        
    PageReference done = null;
   
    if(this.source == 'default') {
    	done = Page.enteredAccountContactPage;
    	done.setRedirect(false);
    }
    else if(this.source == 'enterContrib') {
        done = new PageReference('/apex/enterAccountContactContributionPage?a=1&s=2&ac=' + acct.Id);
    	done.setRedirect(true);
    }
    
    return done;
}
        
    public PageReference setAccount()
    {
      //INSERT ACCOUNT NAME IF RECORDTYPE == HOUSEHOLD
    System.debug('At beginning of submit(), aname is ' + aname);
    System.debug('Is aname blank? '+ aname=='');
    System.debug('Is aname null? '+ aname==null);
    System.debug('At beginning of submit(), acct.RecordTypeID is ' + acct.RecordTypeId);
    enterContact2 = (acct.Contacts_in_Account__c == '2');
    if (String.isBlank(aname)) {
        Id FamilyRTID = [select Id from RecordType where Name = 'Family'][0].Id;
        if (acct.RecordTypeId == null) acct.RecordTypeId = FamilyRTID;
        if (acct.RecordTypeId == FamilyRTID) {
            System.debug('Just passed aname==null, acct.recordtype==Family');
            if (ctct2.LastName == null) {
                acct.Name=ctct.LastName + ', ' + ctct.FirstName + ' Household';
                }
                else {
                        if(ctct.LastName == ctct2.LastName) {
                                acct.Name = ctct.LastName + ', ' + ctct.FirstName + ' and ' + ctct2.FirstName + ' Household';
                        }
                        else {
                                acct.Name=ctct.LastName + ', ' + ctct.FirstName + ' and ' + ctct2.FirstName + ' ' + ctct2.LastName + ' Household';
                        }
                } // END ELSE
            } // END IF NO CONTACT2 LASTNAME
            else { // if aname==null & not 'Family'
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'If the account type is not Household, you must enter an Account Name.'));
                    System.debug('Just passed error, recordtype <> Household and aname is blank');
                    PageReference tryAgain = Page.enterAccountContactPage;
                    tryAgain.setRedirect(false);
                    return tryAgain;
                }
            } 
         else { // if aname<>null
            acct.Name = aname;
            }     
        System.debug('After routine to determine acct.name, it is ' + acct.Name);
    // ADDRESSEE
        if (acct.Addressee__c == null) {
    if (String.isNotBlank(acct.Contacts_in_Account__c)) {
        if (ctct2.LastName == null) {
            acct.Addressee__c = ctct.FirstName + ' ' + ctct.LastName;}
        else {
            if(ctct2.LastName == ctct.LastName) {
                acct.Addressee__c = ctct.FirstName + ' and ' + ctct2.FirstName + ' ' + ctct.LastName;
            }
            else
            {acct.Addressee__c = ctct.FirstName + ' ' + ctct.LastName + ' and ' + ctct2.FirstName + ' ' + ctct2.LastName;
            }
        }
    }
    else
        acct.Addressee__c = '';
    }
            
    acct.ShippingStreet = acct.BillingStreet;
    acct.ShippingCity = acct.BillingCity;
    acct.ShippingPostalCode = acct.BillingPostalCode;
    acct.ShippingState = acct.BillingState;   
    // DEAR__C 
    if (acct.Dear__c==null) {
        if (ctct2.FirstName==null) {
            acct.Dear__c = ctct.Dear__c == null ? ctct.FirstName : ctct.Dear__c;
            System.debug('After acct.dear__c==null, acct.dear__c is ' + acct.Dear__c);
            } //END IF CTCT2.FIRSTNAME==NULL
        else {
            acct.Dear__c = ctct.Dear__c == null ? ctct.FirstName : ctct.Dear__c;
            acct.Dear__c += ' and ';
            acct.Dear__c += ctct2.Dear__c == null ? ctct2.FirstName : ctct2.Dear__c;
        } // END ELSE 
    } else { // END IF ACCT.DEAR__C==NULL
        acct.Dear__c = ctct.Dear__c;
    }
        
        return null;
    }

public PageReference done(){
    PageReference done = new PageReference('/001/o');
    done.setRedirect(true);
    
    
    return done;
}

public PageReference nextEntry(){
        PageReference nextEntry = Page.enterAccountContactPage;
    nextEntry.setRedirect(true);
    return nextEntry;
    }
}