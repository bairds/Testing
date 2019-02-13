// Jan 2016.  Reprogrammed to guard against AccountRTID == null, which is now possible when this controller called from other controllers and not just the page.
// Oct 2016.  Jose reprograms with javascript, catches user if tries to save account without contact
// 2 Feb 2017 Baird adds line to prevent overwriting Addressee if the user has already entered something manually.
public class enterAccountContact {
    public Contact ctct {get; set;}
    public Contact ctct2 {get; set;}
    public Account acct {get; set;}
    public String aname {get;set;}
    public Boolean enterContact2 {get; set;}
    public Boolean enterDonation {get; set;}
    public Boolean createDummyContact { get; set; }
    
    public enterAccountContact(ApexPages.StandardController controller) {
        acct = new account();   
        acct.Contacts_in_Account__c = '1';
        
        ctct = new contact();
        ctct2 = new contact();
        enterContact2 = false;
        createDummyContact = false;
    }   
    
    public void setContacts()
    {
        if(createDummyContact) {
            ctct.FirstName = 'Sir';
            ctct.LastName = 'Unknown';
            ctct.dear__c = ctct.dear__c == null ? ctct.FirstName : ctct.dear__c;
        }
        else
            ctct = new Contact();
    }

public pageReference submit(){
    //
  	this.setAccount();
    insert acct;
// Only insert contacts if Contacts_in_Account__c = '1' or '2' 
    if (acct.Contacts_in_Account__c <> null) {
        system.debug('After if (ctct2.firstname==null, acct.dear__c is ' + acct.dear__c);
        Ctct.accountid = acct.id;
        ctct.Mailingstreet = acct.BillingStreet;
        ctct.MailingCity = acct.BillingCity;
        ctct.MailingPostalCode = acct.BillingPostalCode;
        ctct.MailingState = acct.BillingState;
        ctct.dear__c = ctct.dear__c == null ? ctct.FirstName : ctct.dear__c;
        if (ctct.Phone == null) ctct.Phone = acct.Phone;
        insert ctct;
        // Account is inserted, account validation tests run, etc.
        if(enterContact2) {
            Ctct2.accountid = acct.id;
            ctct2.Mailingstreet = acct.BillingStreet;
            ctct2.MailingCity = acct.BillingCity;
            ctct2.MailingPostalCode = acct.BillingPostalCode;
            ctct2.MailingState = acct.BillingState;
            ctct2.dear__c = ctct2.dear__c == null ? ctct2.FirstName : ctct2.dear__c;
            if (ctct2.Phone == '') ctct2.Phone = acct.Phone;
            insert ctct2;
            accountContactRole acr = new accountContactRole(
                contactid = ctct2.id,
                accountid = acct.id,
                role = 'Second contact');
                insert acr;
        }
    }
        
        
    PageReference done = Page.enteredAccountContactPage;
    done.setRedirect(false);
    return done;
}
        
    public pageReference setAccount()
    {
      //INSERT ACCOUNT NAME IF RECORDTYPE == HOUSEHOLD
    system.debug('At beginning of submit(), aname is ' + aname);
    system.debug('Is aname blank? '+ aname=='');
    system.debug('Is aname null? '+ aname==null);
    system.debug('At beginning of submit(), acct.RecordTypeID is ' + acct.RecordTypeID);
    enterContact2 = (acct.Contacts_in_Account__c == '2');
    if (String.isBlank(aname)) {
        ID FamilyRTID = [select id from RecordType where name = 'Family'][0].ID;
        if (acct.recordTypeId == null) acct.recordTypeId = FamilyRTID;
        if (acct.recordtypeID == FamilyRTID) {
            system.debug('Just passed aname==null, acct.recordtype==Family');
            if (ctct2.lastname == null) {
                acct.Name=ctct.lastname + ', ' + ctct.firstname + ' Household'; 
                }
                else {
                        if(ctct.lastname == ctct2.lastname) {
                                acct.Name = ctct.lastname + ', ' + ctct.firstname + ' and ' + ctct2.firstname + ' Household';
                        }
                        else {
                                acct.Name=ctct.lastname + ', ' + ctct.firstname + ' and ' + ctct2.firstname + ' ' + ctct2.lastname + ' Household';
                        }
                } // END ELSE
            } // END IF NO CONTACT2 LASTNAME
            else { // if aname==null & not 'Family'
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'If the account type is not Household, you must enter and Account Name.'));
                    system.debug('Just passed error, recordtype <> Household and aname is blank');
                    PageReference tryAgain = Page.EnterAccountContactPage;
                    tryAgain.setRedirect(false);
                    return tryAgain;
                }
            } 
         else { // if aname<>null
            acct.name = aname;           
            }     
        system.debug('After routine to determine acct.name, it is ' + acct.name);
    // ADDRESSEE
        if (acct.addressee__c == null) {
    if (String.isNotBlank(acct.Contacts_in_Account__c)) {
        if (ctct2.lastname == null) {
            acct.addressee__c = ctct.firstname + ' ' + ctct.lastname;}
        else {
            if(ctct2.lastname == ctct.lastname) {
                acct.addressee__c = ctct.firstname + ' and ' + ctct2.firstname + ' ' + ctct.lastname;
            }
            else
            {acct.addressee__c = ctct.firstname + ' ' + ctct.lastname + ' and ' + ctct2.firstname + ' ' + ctct2.lastname;
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
    if (acct.dear__c==null) {
        if (ctct2.firstname==null) {
            acct.dear__c = ctct.Dear__c == null ? ctct.firstname : ctct.Dear__c;
            system.debug('After acct.dear__c==null, acct.dear__c is ' + acct.dear__c);
            } //END IF CTCT2.FIRSTNAME==NULL
        else {
            acct.dear__c = ctct.Dear__c == null ? ctct.firstname : ctct.Dear__c;
            acct.Dear__c += ' and ';
            acct.Dear__c += ctct2.Dear__c == null ? ctct2.firstname : ctct2.Dear__c;
        } // END ELSE 
    } else { // END IF ACCT.DEAR__C==NULL
        acct.dear__c = ctct.dear__c;
    }
        return null;
    }

public pageReference done(){
    PageReference done = new PageReference('/001/o');
    done.setRedirect(true);
    
    
    return done;
}

public pageReference nextEntry(){
        PageReference nextEntry = Page.enterAccountContactPage;
    nextEntry.setRedirect(true);
    return nextEntry;
    } 
}