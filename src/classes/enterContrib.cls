// Created by Jaspreet and extended by Baird Dec 2014
// Still untested: entering an account and two contacts; 

public class enterContrib {

    public Contact ctct {get; set;}
    public id ContactID {get; set;}
    public Contact ctct2 {get; set;}
    public Lead ld {get; set;}
    public list<contact> ListContacts; 
    public Account acct {get; set;}
    public Opportunity contrib {get; set;}
    public String aName {get;set;}
    public String cName {get; set;}
    public String lName {get; set;}
    public Boolean enterContact2 {get; set;}
    public Boolean enterDonation {get; set;}
    public Boolean NewAcctCtCt {get; set;}
    public Boolean NewCtCt {get; set;}
    // record types for opportunity object
    private transient Map<Id, Schema.RecordTypeInfo> mapOpportunityRT;
    
    public id LastCampaign {get; set;}
    public id LastRT {get; set;}
    public string RTName {get; set;}
    List<SelectOption> options;
    public Boolean readyForContrib {get; set;}
    public Boolean showListContacts {get; set;}
    public ID PrimCtctId {get; set;}
     public List<SelectOption> templates;
     public String templateId {get; set;}
    public String contributorId { get; set; }

    public enterContrib(ApexPages.StandardController controller) {
        acct = new account();
        ctct = new contact();
        ctct2 = new contact();
        ld = new Lead();
        
        
        if(String.isNotEmpty(ApexPages.currentPage().getParameters().get('lastRT')))
            LastRT = Id.valueOf(ApexPages.currentPage().getParameters().get('lastRT'));
        
        if(String.isNotEmpty(ApexPages.currentPage().getParameters().get('lastCampaign')))
            LastCampaign = Id.valueOf(ApexPages.currentPage().getParameters().get('lastCampaign'));
        
        contrib = new Opportunity(
            closedate = system.today(),
            RecordTypeID = LastRT == null ? null : LastRT,
            CampaignID = LastCampaign==null ? null : LastCampaign);
        enterContact2 = false;
        readyForContrib=false;
        newCtct = false;
        ListContacts = new List<contact>{};   
        showListContacts = false;    
    }    
    
    public void selectContributor()
    {
        String oId = this.contributorId.left(3);
        
        if(oId == '001')        
        	this.submitAcct();
        else if(oId == '003')
            this.submitCtct();
        else 
            this.submitLead();
    }
    
    public PageReference cancelnewAcctCtct(){
        newAcctCtct = false;
        acct.ID = null;
        return null;
    }
    
    public PageReference cancelnewCtct(){
        newAcctCtct = false;
        ctct.ID = null;
        newCtct = false;
        return null;
    }
    
    public PageReference cancelnewLead(){
        newAcctCtct = false;
        Ld = new Lead();
        newCtct = false;
        return null;
    }
    
    public PageReference createNewAccountContact() {
        acct=new Account();
        ctct=new Contact();
        ld=new Lead();
        newAcctCtct = true;
        newCtct = false;
        ListContacts = new List<Contact>();
        return null;
    }

    public PageReference createNewContact() {
        system.debug('CreateNewContact was called.');
        system.debug('Acct.id is currently ' + acct.id);
        if (acct.id!=null) {
            newCtct = true;
            ctct = new Contact();
            }
        return null;
    }

    public PageReference cancelNewContact() {
            newCtct = false;
        return null;
    }   
  

    public pageReference submit() {
        if (ListContacts==null) {
            ListContacts = [select id, title, firstname, lastname, dear__c from Contact where Account.name = :aname];
            /* Jaspreet, in the next version I would like this field to be a type-ahead field.  https://github.com/SalesforceFoundation/visualforce-typeahead */
        return null;
        }
        return null;
    }

public pageReference SubmitAcctOrCtct() {
    return null;
    }

//Remove this when I'm done with the original VF Page, which requires it.
public pageReference submitAcct() {
    system.debug('About to set acct.id to ' + ApexPages.CurrentPage().getParameters().get('AccountID'));
    
   // acct.id=ApexPages.CurrentPage().getParameters().get('AccountID');
   // acct.name=ApexPages.CurrentPage().getParameters().get('AccountName');
    acct = [select id, recordTypeID, Phone, BillingStreet, BillingCity, BillingState, BillingPostalCode, Contacts_in_Account__c, Name, (
        select contactId, contact.LastName, contact.FirstName, contact.MailingCity from AccountContactRoles where isPrimary = true)
        from Account where Id =: this.contributorId];
        system.debug('Account and acr are now ' + acct); // ENDED PROGRAMMING HERE
    For (AccountContactRole acr : acct.AccountContactRoles) {
        PrimCtctId = acr.contactid;
    }
    getListContacts(); // ListContacts = [select lastname, firstname, title, dear__c, phone, email, MailingStreet, MailingCity, MailingState, MailingPostalCode from Contact where accountid = :acct.id];
    showListContacts = (ListContacts.size() > 0);
    ld = new Lead();
    return null;
    }
    
public void submitCtct() {
    system.debug('Contact is ' + ctct + ' and contactid is ' + ApexPages.CurrentPage().getParameters().get('ContactID'));
    ctct = [select id, firstname, lastname, MailingStreet, MailingCity, MailingState, MailingPostalCode, Dear__c, accountid, account.name from Contact 
        WHERE Id =: this.contributorId];
    ld= new Lead();
    }
        
public void submitLead() {
    if (ld.id==null) {
       // ld.id=ApexPages.CurrentPage().getParameters().get('leadId');
        system.debug('About to set ld.id to ' + ApexPages.CurrentPage().getParameters().get('LeadID'));
        }
    system.debug('Lead is ' + ld + ' and lead.Id is ' + ApexPages.CurrentPage().getParameters().get('LeadID'));
    ld = [select id, recordTypeID, Company, Phone, Street, City, State, PostalCode, FirstName, LastName from Lead 
            where Id =: this.contributorId];
    acct= new Account();
    ctct= new Contact();
    ctct2=new Contact();
    ListContacts = new List<Contact>();
    newAcctCtct = false;
    }
    
public void ReadyForContrib() {
    if ((acct.id!=null && ctct.id!=null) || ld.id!=null ) readyForContrib=true;
    // return null;
    }
   
public pageReference submitCtctForAcct() {    
    Ctct.accountid = acct.id;
    ctct.Mailingstreet = acct.BillingStreet;
    ctct.MailingCity = acct.BillingCity;
    ctct.MailingPostalCode = acct.BillingPostalCode;
    ctct.MailingState = acct.BillingState;
    if (ctct.Dear__c == null) ctct.dear__c = ctct.FirstName;
    if (ctct.Phone == null) ctct.Phone = acct.Phone;
    newCtct = false;
    insert ctct;
    
    //ListContacts = [select Id, lastname,firstname,MailingCity from Contact where accountid = :acct.id];
    return null;
    }
 
    public PageReference chosePrimaryContributor() {
    System.debug('ContactID'+ ContactID);
    ctct = [select id, firstname, lastname, dear__c, email, title, homephone, mobilePhone, MailingStreet, MailingState, MailingPostalCode, MailingCity from Contact WHERE id=: ContactID];
        return null;
    }    
 
    public PageReference choseAccount() {
    if (acct.id == null) acct.id=ctct.accountid;
    acct = [select id, recordTypeID, Phone, BillingStreet, BillingCity, BillingState, BillingPostalCode, Contacts_in_Account__c, Name from Account 
         where id = :acct.id];
    system.debug('About to set acct.id to ' + ApexPages.CurrentPage().getParameters().get('AccountID'));
    return null;
    }
    
    public List<SelectOption> getItems() {
        options = new List<SelectOption>();
        mapOpportunityRT = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosById();
        Set<Id> keys = mapOpportunityRT.keySet();
        for(Id key : keys) {
            Schema.RecordTypeInfo rt = mapOpportunityRT.get(key);
            string enterContribRTs = 'Challenge, Donation, Event, Grant, InKind, Major Donation, Membership, Pledge, Service, Volunteer Task';
            if(enterContribRTs.contains(rt.getName())) 
                options.add(new SelectOption(String.valueOf(key), rt.getName()));
        }
        return options;
    }  
    
    public List<SelectOption> getTemplates() {
    	List<SelectOption> o = new List<SelectOption>();
        o.add(new SelectOption('', '-- None --'));
        
    	list<apexPage> ts = [SELECT Id, Name FROM apexPage WHERE Name LIKE '%thanks%'];
    
    	for(apexPage t : ts){
    		o.add(new SelectOption(String.valueOf(t.Id), t.Name));
    	}
    	return o;
    	
    }  

public PageReference submitAcctCtcts() {
    //
    //INSERT ACCOUNT NAME IF RECORDTYPE == HOUSEHOLD
    system.debug('At beginning of submit(), aname is ' + aname);
    system.debug('Is aname blank? '+ aname=='');
    system.debug('Is aname null? '+ aname==null);
    system.debug('At beginning of submit(), acct.RecordTypeID is ' + acct.RecordTypeID);
    enterContact2 = (acct.Contacts_in_Account__c == '2');
    if (aname=='') {
        if (acct.recordtypeID == [select id from RecordType where name = 'Family'][0].ID) {
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
    acct.ShippingStreet = acct.BillingStreet;
    acct.ShippingCity = acct.BillingCity;
    acct.ShippingPostalCode = acct.BillingPostalCode;
    acct.ShippingState = acct.BillingState;   
    // DEAR__C 
    if (acct.dear__c==null) {
        if (ctct2.firstname==null) {
            acct.dear__c = ctct.firstname;
            system.debug('After acct.dear__c==null, acct.dear__c is ' + acct.dear__c);
            } //END IF CTCT2.FIRSTNAME==NULL
        else {
            acct.dear__c = ctct.firstname + ' and ' + ctct2.firstname;
        } // END ELSE 
        } // END IF ACCT.DEAR__C==NULL
    insert acct;
// Only insert contacts if Contacts_in_Account__c = '1' or '2' 
    if (acct.Contacts_in_Account__c <> null) {
    system.debug('After if (ctct2.firstname==null, acct.dear__c is ' + acct.dear__c);
    Ctct.accountid = acct.id;
    ctct.Mailingstreet = acct.BillingStreet;
    ctct.MailingCity = acct.BillingCity;
    ctct.MailingPostalCode = acct.BillingPostalCode;
    ctct.MailingState = acct.BillingState;
    ctct.dear__c = ctct.FirstName;
    if (ctct.Phone == null) ctct.Phone = acct.Phone;
    insert ctct;
    // Account is inserted, account validation tests run, etc.
    if(enterContact2) {
        Ctct2.accountid = acct.id;
        ctct2.Mailingstreet = acct.BillingStreet;
        ctct2.MailingCity = acct.BillingCity;
        ctct2.MailingPostalCode = acct.BillingPostalCode;
        ctct2.MailingState = acct.BillingState;
        ctct2.dear__c = ctct2.firstName;
        if (ctct2.Phone == '') ctct2.Phone = acct.Phone;
        insert ctct2;
        accountContactRole acr = new accountContactRole(
            contactid = ctct2.id,
            accountid = acct.id,
            role = 'Second contact');
            insert acr;
    }
    }
    
    return null;
}
    public void submitAndNext() {
         //system.debug('template is ' + templateId);
        /*
         * Originally this line was "new Page.enterContrib" but that gave an error that javascripts
         * were not generated for the controller, and the new page showed but wouldnt' work.
         */
        
        
        saveContrib();
       
        

//
		// string ChosenTemplate = System.currentPageReference().getParameters().get('TemplateName');
       
    //system.debug('ChosenTemplate is now ' + ChosenTemplate);
        
       // if(String.isNotEmpty(templateId)){
        
       	//	PageReference renderLetter = new PageReference('/apex/Print?template=' + templateId + '&contrib=' + contrib.Id);
    	//	return renderLetter;
        //}
        //else
        //{
             // PageReference should refresh Acct, Ctct, Ld, and Contrib but should not erase LastRT and LastCampaign
           // ctct = new Contact();
        //    ctct2 = new Contact(); 
         //   ContactID = null;
          // PrimCtctID = null;
          //  RTName = null;
         //  acct = new Account();
         //  ld = new Lead();
        	//contribId = contrib.Id;
         //  contrib = new Opportunity(
         //  closedate = system.today(),
         ///  RecordTypeID = LastRT == null ? null : LastRT,
         //  CampaignID = LastCampaign==null ? null : LastCampaign);
         //  enterContact2 = false;
          // readyForContrib=false;
         //  ListContacts.clear();
        //   showListContacts = false;
            //
        
        	//PageReference nextContrib = new PageReference('/apex/enterContrib');
        //
        	//nextContrib.setRedirect(false);
        
       		//return nextContrib;
			//}
    }

    public void submitAndExit()
    {
        saveContrib();
        
       

       	//if(String.isNotEmpty(templateId)){
    	//PageReference renderLetter = new PageReference('/apex/Print?template=' + templateId + '&contrib=' + contrib.Id);
        
        
        
    	//	return renderLetter;
        //}
       // else 
      //return Exit();
          //  
        //   return null;
    }

    public PageReference Exit() {
        PageReference done = new PageReference('/006/o');
        done.setRedirect(true);
        return done;
    }
    
    private void saveContrib(){
        if (ld.id!=null) {
        // CConvert Lead to Account/Contact, following Code from ManageCnPController
        Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(ld.id);
                lc.setDoNotCreateOpportunity(true);
                LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE 
                    IsConverted=true and MasterLabel='Closed - Converted' LIMIT 1];
                lc.setConvertedStatus(convertStatus.MasterLabel);
                Database.LeadConvertResult lcr = Database.convertLead(lc);
                // Make sure conversion was successful
                System.assert(lcr.isSuccess());
                ctct = [select id, firstname, lastname from Contact where id = :lcr.getContactID()];
                // Add Dear__c and Addressee to account
                acct = [select Id, Name from account where id = :lcr.getAccountID()];
                if (acct.name == 'none') acct.name = ctct.lastname + ', ' + ctct.firstname + ' Household';
                acct.Dear__c = ctct.firstname;
                acct.Addressee__c = ctct.FirstName + ' ' + ctct.LastName;
                system.debug('In lcr, Account Name is ' + Acct.name);
                update acct;
        } // end conversion of lead
        contrib.contact__c=ctct.id;
        contrib.accountid=acct.id;
        contrib.Name = 'autofill'; 
        contrib.StageName = 'Donation Received';
        contrib.contact__c = ctct.id;
        contrib.accountid = acct.id;
        contrib.recordTypeID = RTName;
        lastCampaign = Contrib.CampaignID;
        lastRT = Contrib.RecordTypeID;  
        system.debug('Contrib Record Type is ' + contrib.recordtypeID);
        system.debug('Contrib campaign name is ' + contrib.campaignId);
            insert contrib;
        System.debug('contrib'+ contrib);
    }
    
    public PageReference updateAcct() {
    update acct;
    return null;
    }
    
    public PageReference updateLead() {
    update ld;
    return null;
    }
        
    public PageReference updateAcct_Ctcts() {
    update acct;
    list<contact> UpdateCtcts = new list<Contact>();
    for (Contact c : ListContacts) {
        c.phone=acct.phone;
        c.MailingStreet=acct.BillingStreet;
        c.MailingCity=acct.BillingCity;
        c.MailingState=acct.BillingState;
        c.MailingPostalCode=acct.BillingPostalCode;
        UpdateCtcts.add(c);
    }
    update UpdateCtcts;
    return null;
    }

    public PageReference BackToStart() {
    ctct = new Contact();
    acct = new Account();
    ld = new Lead();
    contrib = new Opportunity(
            closedate = system.today(),
            RecordTypeID = LastRT == null ? null : LastRT,
            CampaignID = LastCampaign==null ? null : LastCampaign);
    enterContact2 = false;
    readyForContrib=false;
    ListContacts = new List<Contact>();
    return null;
    
    }
    public PageReference BackToAccountsContacts() {
    contrib = new Opportunity(
            closedate = system.today(),
            RecordTypeID = LastRT == null ? null : LastRT,
            CampaignID = LastCampaign==null ? null : LastCampaign);
    enterContact2 = false;
    readyForContrib=false;
    return null;
    }

    public Boolean getCheckingBlock() {
        Boolean result = false;
        String label = '';
        if(options != null) {
            for(SelectOption option : options) {
                if(option.getValue().equals(RTName)) {
                    label = option.getLabel();
                    break;
                }
            }
        }
        if(label.equals('Service') || label.equals('Membership') || label.equals('Challenge') || 
            label.equals('Major Donation') || label.equals('Donation') || label.equals('Grant')) {
            result = true;
        } else {
            result = false;
        }
        return result;
    }

    public Boolean getMembershipBlock() {
        Boolean result = false;
        String label = '';
        if(options != null) {
            for(SelectOption option : options) {
                if(option.getValue().equals(RTName)) {
                    label = option.getLabel();
                    break;
                }
            }
        }
        if(label.equals('Membership')) {
            result = true;
        } else {
            result = false;
        }
        return result;
    }

    public Boolean getInKindBlock() {
        Boolean result = false;
        String label = '';
        if(options != null) {
            for(SelectOption option : options) {
                if(option.getValue().equals(RTName)) {
                    label = option.getLabel();
                    break;
                }
            }
        }
        if(label.equals('InKind')) {
            result = true;
        } else {
            result = false;
        }
        return result;
    }

    public Boolean getEventBlock() {
        Boolean result = false;
        String label = '';
        if(options != null) {
            for(SelectOption option : options) {
                if(option.getValue().equals(RTName)) {
                    label = option.getLabel();
                    break;
                }
            }
        }
        if(label.equals('Event')) {
            result = true;
        } else {
            result = false;
        }
        return result;
    }

    public Boolean getPledgeBlock() {
        Boolean result = false;
        String label = '';
        if(options != null) {
            for(SelectOption option : options) {
                if(option.getValue().equals(RTName)) {
                    label = option.getLabel();
                    break;
                }
            }
        }
        if(label.equals('Pledge')) {
            result = true;
        } else {
            result = false;
        }
        return result;
    }

    public Boolean getTaskBlock() {
        Boolean result = false;
        String label = '';
        if(options != null) {
            for(SelectOption option : options) {
                if(option.getValue().equals(RTName)) {
                    label = option.getLabel();
                    break;
                }
            }
        }
        if(label.equals('Volunteer Task')) {
            result = true;
        } else {
            result = false;
        }
        return result;
    }
    
   
    public List<Contact> getListContacts() {
    ListContacts = [select id, firstname, lastname, dear__c from Contact where (AccountID = :acct.id)];
    List<contact> ListContactsFromACRs = [select id, firstname, lastname, dear__c from Contact where
                   id in (select contactid from AccountContactRole where accountid = :acct.id)];
    set<contact> SetContacts = new set<contact>();
    SetContacts.addAll(ListContacts);
    SetContacts.addAll(ListContactsFromACRs);
    ListContacts.clear();
    ListContacts.addAll(SetContacts);
    ListContacts.sort();
        return ListContacts;
    }
     
} //