/*
Classes:

- DataImport
- DataImportTest
- IdentifyPerson
- ContactCustom
- ConvertLeadToContact
- ConvertLeadToContactTest
- OpportunityCustom

GlobalPicklist:
- DoNot

CustomField:
- Contact.ImportObjectSource__c

Trigger:
- ContactBeforeAfterInsert 

VF Pages:
- DataImportPage

Static Resources:
- JoseCSS
- JoseJS

Components:
- Loading

Objects:
- Opportunity
- Lead
- Account
- Contact
- ImportObject
- Data_Import_Batch__c
- CampaignMember
- Campaign

// Created by Jose August 2017
// Baird updated to search for contributionRecordType in various places, and to update empty contact and account addresses, and put names in title case, 31 Aug 2017.
// Note that this structure processes each record one by one, and so will run into query limits, etc very quickly.  We need to call it from a batch.
// The advantage of this structure is that if there are multiple importObject records from one contact then each will be checked against the previous.
*/

global with sharing class DataImportBaird 
{
    public List<ImportObject__c> records { get; set; }
    public List<ImportObject__c> selectedRecords { get; set; }
    
    public String StringA { get; set; } 
    // Declare public o, c, a, ExistingAcct so they can be checked from the test.
    Public Opportunity o;
    Public Contact c;
    Public Account a;
    Public Account ExistingAcct;
    public Map<string,Schema.RecordTypeInfo> OppRTNameMap;
    
    public DataImportBaird()
    {
        this.StringA = '1';
        OppRTNameMap = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
    }
    
    public void setList()
    {
        this.setRecords();
    }
    
    private void setRecords()
    {
        String q = 'SELECT ';
        
        for(Schema.sObjectField f : ImportObject__c.sObjectType.getDescribe().fields.getMap().values())
            q += f + ', ';
        
        q = q.removeEnd(', ');
        
        q += ' FROM ImportObject__c WHERE Processed__c = NULL';        
        
        this.records = Database.query(q);
        system.debug('records include ' + records.size());
    }
    
    public void process()
    {
        Contact c2;    
        Lead l;
        Campaign ca;
        RecordType rt;
        CampaignMember cm;
        Boolean contributionExists;
        Set<Account> UpdateAccts = new set<Account>();
        
        // Make sure Unknown Campaign exists just in case        
        List<Campaign> cas = [ SELECT Id FROM Campaign WHERE Name = 'Unknown Campaign' LIMIT 1 ];
        
        if(cas.size() == 0) {
            ca = new Campaign();
            ca.Name = 'Unknown Campaign';
            
            insert ca;
        }
        else
            ca = cas[0];
        // Create map of RecordType Names and IDs
        //Map<string,Schema.RecordTypeInfo> OppRTNameMap = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        
        Data_Import_Batch__c dib = new Data_Import_Batch__c();
        dib.Name = String.valueOf(DateTime.now());
        
        insert dib;
        
        for(ImportObject__c r : this.records) {
            if(r.Processed__c) {
                contributionExists = false;
                
                if(r.Contribution_Amount__c != null || r.Contribution_HoursActual__c != null) contributionExists = true;
                
                r = this.setName(r);
                
                c = new Contact();
                c.ImportObjectSource__c = r.Id;
                c.Email = r.Person_EmailPersonal__c;
                c.FirstName = r.Person_FirstName__c.toLowerCase().Capitalize();
                c.LastName = r.Person_LastName__c.toLowerCase().Capitalize();   
                c.Dear__c = c.FirstName;
                c.MobilePhone = r.Person_PhoneMobile__c;
                c.MailingStreet = r.Address_StreetLine1__c;
                c.MailingCity = r.Address_City__c;
                c.MailingState = r.Address_State__c;            
                c.MailingPostalCode = r.Address_ZipCode__c;
                c.MailingCountry = r.Address_Country__c;
                c.Legacy_Contact_ID__c = r.Person_LegacyID__c;
                
                String[] result = identifyPerson.identifyPerson(c);
                system.debug('Result querying on work email is ' + result);
                
                //if no result check against Person_EmailWork
                if(result == null && r.Person_EmailWork__c != null) {
                    c.Email = r.Person_EmailWork__c;
                    system.debug('Result querying on work email is ' + result);
                    
                    result = identifyPerson.identifyPerson(c);
                }
                
                //if weak match, insert new contact
                if(result != null) {
                    if(result[2] == 'match on email not name' || result[2] == 'match on name and zip') {
                        insert this.createContact(r, c); 
                        system.debug('Weak match on contact');
                    }
                    else {
                        //if strong result, update contact
                        if(result[1] == 'Contact') {  
                            //if strong match, delete info inserted above and update existing contact
                            Contact c = identifyPerson.returnContact;
                            c.id = result[0];
                            if(result[2] == 'match on legacy id and email or name' || result[2] == 'match on email and name') {
                                system.debug('Strong match on contact');
                                system.debug('c has been set equal to matchingContact ' + c);
                                
                                //Update contact address if contact address is empty and importObject has additional info that matches
                                if ((c.MailingStreet==null || c.MailingStreet==r.Address_StreetLine1__c) &&
                                    (c.MailingCity==null || c.MailingCity==r.Address_City__c) &&
                                    (c.MailingState==null || c.MailingState==r.Address_State__c) &&
                                    (c.MailingPostalCode==null || c.MailingPostalCode==r.Address_ZipCode__c)) {
                                        c.MailingStreet=r.Address_StreetLine1__c;
                                        c.MailingCity=r.Address_City__c;
                                        c.MailingState=r.Address_State__c;
                                        c.MailingPostalCode=r.Address_ZipCode__c;
                                        update c;
                                    }
                                
                                //Update account address if its empty
                                if (result[3] == null) {
                                    ApexPages.Message NoAccountIdWarning = new ApexPages.Message(ApexPages.Severity.WARNING,'Strong match on contact which had no account.');
                                } else {
                                    system.debug('About to test whether to update account address, which is ' + result[3]);
                                    a = [select id, BillingStreet, BillingCity, BillingState, BillingPostalCode from Account where id = :result[3]];
                                    if ((a.BillingStreet==null || a.BillingStreet==r.Address_StreetLine1__c) &&
                                        (a.BillingCity==null || a.BillingCity==r.Address_City__c) &&
                                        (a.BillingState==null || a.BillingState==r.Address_State__c) &&
                                        (a.BillingPostalCode==null || a.BillingPostalCode==r.Address_ZipCode__c)) {
                                            system.debug('Passed test to update account address.  Updating account where id is ' + c.AccountId);
                                            a.BillingStreet=r.Address_StreetLine1__c;
                                            a.BillingCity=r.Address_City__c;
                                            a.BillingState=r.Address_State__c;
                                            a.BillingPostalCode=r.Address_ZipCode__c;
                                            UpdateAccts.add(a);
                                        }
                                }
                            }
                        }
                        else {
                            //if strong match on lead, update existing lead
                            if(result[2] == 'match on email and name') {
                                system.debug('Strong match on lead');
                                l = this.createLead(r);
                                l.Id = result[0];
                                update l;                               
                                //if contributionExists, convert to contact
                                if(contributionExists) {
                                    List<Id> ReturnIds = new List<Id>();
                                    ReturnIds = ConvertLeadToContact.ConvertLeadToContact(l.Id);
                                    system.debug('ReturnIds is ' + REturnIds);
                                    c.Id = ReturnIds[0];
                                    a = new Account(Id = ReturnIds[1], Name=l.company);
                                    UpdateAccts.add(a);
                                    system.debug('UpdateAccts is ' + UpdateAccts);
                                    system.debug('After converting lead to contact, account is ' + [select id, account.name from Contact where id = :c.id].account.name);
                                }
                            }
                        }                    
                    }                    
                }
                // if no contact or lead found, create new contact or lead
                else  {
                    
                    system.debug('Create new contact or lead');
                    if(contributionExists)
                        insert this.createContact(r, c);
                    else {
                        l = this.createlead(r);
                        
                        if(String.isNotBlank(r.Company_or_Organization__c))
                            l.Company = r.Company_or_Organization__c;
                        else if(String.isBlank(r.Account_Name__c))
                            l.Company = l.LastName + ', ' + l.FirstName + ' Household';
                        else
                            l.Company = r.Account_Name__c;                        
                        
                        insert l;
                        system.debug('after creating new lead, company is'+l.company);
                    }
                }
                
                cas = new List<Campaign>();
                
                if(String.isNotBlank(r.Campaign_LegacyID__c))
                    cas = [ SELECT Id FROM Campaign WHERE Legacy_Id__c =: r.Campaign_LegacyID__c LIMIT 1 ];
                
                if(cas.size() == 1)
                    ca = cas[0];
                else if(String.isNotBlank(r.Campaign_Name__c)) {
                    cas = [ SELECT Id FROM Campaign WHERE Name =: r.Campaign_Name__c LIMIT 1 ];
                    
                    if(cas.size() == 1)
                        ca = cas[0];
                    else if(String.isNotBlank(r.Campaign_Name__c)) {
                        ca = new Campaign();
                        ca.Name = r.Campaign_Name__c;
                        ca.IsActive = r.Campaign_IsActive__c;
                        ca.Legacy_Id__c = r.Campaign_LegacyID__c;
                        
                        insert ca;
                    }
                }
                
                if(String.isNotBlank(c.Id))
                    c = [ SELECT Id, AccountId, MailingStreet FROM Contact WHERE Id =: c.Id ];   
                
                // Find contribution RecordTypeId by looking in RecordType__c, Contribution_Type__c and in Campaign_Name__c
                if(contributionExists) {
                    id rtid;
                    if(String.isNotBlank(r.Contribution_RecordType__c) && OppRTNameMap.keyset().CONTAINS(r.Contribution_RecordType__c)) {
                        rtid = OppRTNameMap.get(r.Contribution_RecordType__c).getRecordTypeId();
                        ApexPages.Message NotAnRTID = new ApexPages.Message(ApexPages.severity.WARNING,'Not a recognized Contribution Record Type');
                    } else {
                        // Look in Contribution_Type__c
                        if(String.isNotBlank(r.Contribution_Type__c)) {
                            for (string s : OppRTNameMap.keyset()) {
                                if (r.Contribution_Type__c.toLowerCase().CONTAINS(s.toLowerCase())) {
                                    rtid = OppRTNameMap.get(s).getRecordTypeId();
                                    continue;
                                }
                            }
                        } else {
                            // Look for RecordTypeName in Campaign Name
                            if(String.isNotBlank(r.Campaign_Name__c)) {
                                for (string s : OppRTNameMap.keyset()) {
                                    if (r.Campaign_Name__c.toLowerCase().CONTAINS(s.toLowerCase())) {
                                        rtid = OppRTNameMap.get(s).getRecordTypeId();
                                        continue;
                                    }
                                }
                            }
                        }
                    }
                    if (rtid == null && OppRTNameMap.keyset().CONTAINS('Donation')) rtid = OppRTNameMap.get('Donation').getRecordTypeId();
                    
                    
                    if(String.isBlank(r.Contribution_Stage__c)) {
                        if(r.Contribution_Amount__c != null && r.Contribution_Amount__c > 0)
                            r.Contribution_Stage__c = 'Donation Received';
                        else
                            r.Contribution_Stage__c = 'Completed';                            
                    }
                    
                    if(r.Contribution_TransactionDate__c  == null)
                        r.Contribution_TransactionDate__c = Date.today();
                    
                    o = new Opportunity();                    
                    o.ImportObjectSource__c = r.Id;
                    o.Name = 'autofill';
                    o.AccountId = c.AccountId;
                    o.Contact__c = c.Id;
                    o.CampaignId = ca.Id;
                    o.RecordTypeId = rtId;
                    o.Amount = r.Contribution_Amount__c;
                    o.Hours_Actual__c = r.Contribution_HoursActual__c;
                    o.StageName = r.Contribution_Stage__c;
                    o.CloseDate = r.Contribution_TransactionDate__c;
                    o.Type = r.Contribution_Type__c;
                    o.Membership_Start_Date__c = r.Contribution_MmbrStartDate__c;
                    o.Membership_End_Date__c = r.Contribution_MmbrEndDate__c;
                    o.Description = r.Contribution_Description__c;
                    
                    insert o;
                }
                
                if(c != null || l != null) {
                    cm = new CampaignMember();
                    CampaignMember[] cms;
                    
                    if(c.Id != null) {
                        cm.ContactId = c.Id;
                        cms = [ SELECT Id FROM CampaignMember WHERE CampaignId =: ca.Id AND ContactId =: c.Id LIMIT 1 ];
                    }
                    else {
                        cm.LeadId = l.Id;
                        cms = [ SELECT Id FROM CampaignMember WHERE CampaignId =: ca.Id AND LeadId =: l.Id LIMIT 1 ];
                    }                   
                    
                    if(cms.size() == 0) {                         
                        cm.CampaignId = ca.Id;      
                        
                        if(contributionExists) 
                            cm.Status = 'Donated';
                        else
                            cm.Status = 'Responded Yes';
                        
                        insert cm;
                    }
                }
                
                r.Processed_Date__c = Date.today();
                r.Batch__c = dib.Id;
            }
        } // End loop through records
        
        update this.records; 
        list<Account> UpdateAcctsList = new List<Account>();
        system.debug('UpdateAccts is ' + UpdateAccts);
        UpdateAcctsList.addAll(UpdateAccts);
        if (updateAccts != null) update updateAcctsList;
        system.debug('Just updated accounts ' + UpdateAccts);
        this.setRecords();
    }
    
    public ImportObject__c setName(ImportObject__c r)
    {
        if(String.isNotBlank(r.Person_FullName__c)) {
            String[] parts = r.Person_FullName__c.split(' ');
            
            if(String.isBlank(r.Person_FirstName__c))
                r.Person_FirstName__c = parts[0];
            
            if(String.isBlank(r.Person_LastName__c)) {
                if(parts.size() > 1)             
                    r.Person_LastName__c = parts[1];
                else
                    r.Person_LastName__c = 'Unknown';
            }
        }
        else {
            if(String.isBlank(r.Person_FirstName__c))
                r.Person_FirstName__c = 'Unknown';
            
            if(String.isBlank(r.Person_LastName__c))
                r.Person_LastName__c = 'Unknown';
        }
        
        r.Person_FullName__c = r.Person_FirstName__c + ' ' + r.Person_LastName__c;      
        
        return r;
    }
    
    public void edit()
    {
        this.StringA = '3';
        this.selectedRecords = new List<ImportObject__c>();
        
        for(ImportObject__c r : this.records) {
            if(r.Processed__c) {
                r.Processed__c = false;
                
                r = this.setName(r);
                
                this.selectedRecords.add(r);
            }
        }
        
        this.records = this.selectedRecords;
        
        if(this.records.size() == 0)
            this.cancel();
    }
    
    public void save()
    {
        this.StringA = '1';
        
        for(ImportObject__c r : this.records)
            r = this.setName(r);
        
        update this.records;            
        
        this.setRecords();
    }
    
    public void cancel()
    {
        this.StringA = '1';
        this.setRecords();
    }
    
    
    public Contact createContact(ImportObject__c r, Contact c)
    {
        system.debug('contact c is ' + c);
        String accountName;
        
        if(String.isNotBlank(r.Account_Name__c)) {
            accountName = r.Account_Name__c;      
            
            if(String.isBlank(r.Account_Record_Type__c) || r.Account_Record_Type__c.toLowerCase().CONTAINS('family'))
                r.Account_Record_Type__c = 'Family';
        }
        else if(String.isNotBlank(r.Company_or_Organization__c)) {
            accountName = r.Company_or_Organization__c;            
            
            r.Account_Record_Type__c = 'Business';
        }
        
        if(accountName != null) {          
            RecordType rt = [ SELECT Id FROM RecordType WHERE Name =: r.Account_Record_Type__c ]; 
            
            a = new Account();
            a.Name = accountName;
            a.RecordTypeId = rt.Id;
            a.Dear__c = c.Dear__c;
            a.Addressee__c = c.FirstName + ' ' + c.LastName;
            a.Phone = c.MobilePhone;
            a.BillingStreet = c.MailingStreet;
            a.BillingCity = c.MailingCity;
            a.BillingState = c.MailingState;
            a.BillingPostalCode = c.MailingPostalCode;
            a.BillingCountry = c.MailingCountry;
            
            insert a;
            
            c.AccountId = a.Id;
        }
        
        return c;
    }
    
    public Lead createLead(ImportObject__c r) 
    {
        Lead l = new Lead();
        l.Email = r.Person_EmailPersonal__c;
        l.FirstName = r.Person_FirstName__c;
        l.LastName = r.Person_LastName__c;      
        l.Dear__c = l.FirstName;
        l.Addressee__c = r.Person_FullName__c;
        l.MobilePhone = r.Person_PhoneMobile__c;
        l.Street = r.Address_StreetLine1__c;
        l.City = r.Address_City__c;
        l.State = r.Address_State__c;            
        l.PostalCode = r.Address_ZipCode__c;
        l.Country = r.Address_Country__c;  
        l.ImportObjectSource__c = r.Id;
        
        return l;        
    }   
    
    
    // Helper class to create map of all contacts, make sure they aren't duplicates
    // Turn off autorecalculation of account totals
    Public List<ImportObject__c> matchRecordsToPeople(List<ImportObject__c> records) {
        AvoidRecursiveContributionTrigger.setWorking();
        //Loops through Import Objects
        List<EnhancedIO> NewEnhancedIOs = new List<EnhancedIO>();
        set<string> MatchingEmails = new set<string>();
        set<string> MatchingNames = new set<string>();
        for (ImportObject__c IO : records) {
            NewEnhancedIOs.add(new enhancedIO(IO));
            if (IO.Person_EmailPersonal__c!=null) MatchingEmails.add(IO.Person_EmailPersonal__c);
            if (IO.Person_EmailWork__c!=null) MatchingEmails.add(IO.Person_EmailWork__c);
            if (IO.Person_LastName__c!=null) MatchingNames.add(IO.Person_LastName__c);
        }
        
        // Create map Emailsmap of <email,contact> for all contacts which match emails in the list of newRecords
        map<string,contact> ContactEmailsmap = new map<string,contact>();
        List<Contact> MatchingContacts = [select id, email, firstname, lastname, homephone, mobilephone, MailingPostalCode from Contact where email in :MatchingEmails];
        For (Contact c: MatchingContacts) {
            // AT this point revise to list List<contact> instead of single contact;
            contactEmailsMap.put(c.email,c);
        }
        // Create map leadEmailsMap of <email,lead> for all leads with emails in list of NewRecords
        map<string,lead> LeadEmailsMap = new map<string,lead>();
        List<Lead> MatchingLeads = [select id, email, firstname, lastname, phone, mobilephone, PostalCode from Lead where email in :MatchingEmails];
        For (Lead l: MatchingLeads) {
            leadEmailsMap.put(l.email,l);
        }		
        
        // Create map LastNamesMap of <lastname,enhancedImportObject> for all existing records where lastnames match lastnames from the newRecords
        // Create map ContactNamesMap of <lastname,contact> for all contacts which match emails in the list of newRecords
        map<string,contact> ContactNamesmap = new map<string,contact>();
        MatchingContacts = [select id, email, firstname, lastname, homephone, mobilephone, MailingPostalCode from Contact where lastname in :MatchingNames];
        For (Contact c: MatchingContacts) {
            contactNamesMap.put(c.lastname,c);
        }
        // Create map leadNamesMap of <email,lead> for all leads with emails in list of NewRecords
        map<string,lead> LeadNamesMap = new map<string,lead>();
        MatchingLeads = [select id, email, firstname, lastname, phone, mobilephone, PostalCode from Lead where lastname in :MatchingNames];
        For (Lead l: MatchingLeads) {
            leadNamesMap.put(l.lastname,l);
        }
      
        // Loop through new EnhancedIOs
        for (EnhancedIO eio : NewEnhancedIOs) {             
            // if newRecord.email in emailsmap.keyset() 
            if (ContactEmailsmap.keyset().contains(eio.IOemail)) {
                Contact tempContact = ContactEmailsMap.get(eio.IOemail);
                // if match on Contact, ImportObject.contactId = emailsmap.get(email);
                if (eio.IOfirstname == tempContact.firstname && 
                    eio.IOlastname == tempContact.lastname) {
                        eio.io.ContactCalculated__c = tempContact.Id;
                        eio.io.MatchReliability__c = 'Match on Email Lastname Firstname';
                        continue; } 
                else {
                    if (eio.IOlastname == tempContact.lastname) {
                        eio.io.ContactCalculated__c = tempContact.Id;
                        eio.io.MatchReliability__c = 'Match on Email Lastname';
                        continue;
                    } else {
                        eio.io.ContactCalculated__c = tempContact.Id;
                        eio.io.MatchReliability__c = 'Match on Email only';
                        continue;
                    }
                }
            } else {
                // if match on Lead, ImportObject.leadId = emailsmap.get(email);
                if (LeadEmailsmap.keyset().contains(eio.IOemail)) {
                    Lead tempLead = LeadEmailsMap.get(eio.IOemail);
                    // if match on Contact, ImportObject.contactId = emailsmap.get(email);
                    if (eio.IOfirstname == tempLead.firstname && 
                        eio.IOlastname == tempLead.lastname) {
                            eio.io.LeadCalculated__c = tempLead.Id;
                            eio.io.MatchReliability__c = 'Match on Email Lastname Firstname';
                            continue; } 
                    else {
                        if (eio.IOlastname == tempLead.lastname) {
                            eio.io.LeadCalculated__c = tempLead.Id;
                            eio.io.MatchReliability__c = 'Match on Email Lastname';
                            continue;
                        } else {
                            eio.io.LeadCalculated__c = tempLead.Id;
                            eio.io.MatchReliability__c = 'Match on Email only';
                            continue;
                        }
                    }
                } else {
            // If match on firstname+lastname+zip 
            if (ContactNamesMap.keyset().contains(eio.IOlastname)) {
                Contact tempContact = ContactEmailsMap.get(eio.IOlastname);
                // if match on Contact, ImportObject.contactId = namesmap.get(lastname);
                if (eio.IOfirstname == tempContact.firstname && 
                    eio.IOlastname == tempContact.lastname && eio.IOzip == tempContact.MailingPostalCode) {
                        eio.io.ContactCalculated__c = tempContact.Id;
                        eio.io.MatchReliability__c = 'Match on Lastname Firstname Zip';
                        continue; } 
            } else {
                // if match on Lead, ImportObject.leadId = namesmap.get(lastname);
                if (LeadNamesMap.keyset().contains(eio.IOlastname)) {
                    Lead tempLead = LeadNamesMap.get(eio.IOlastname);
                    // if match on Contact, ImportObject.contactId = emailsmap.get(email);
                    if (eio.IOfirstname == tempLead.firstname && 
                        eio.IOlastname == tempLead.lastname && eio.IOzip == tempLead.PostalCode) {
                            eio.io.LeadCalculated__c = tempLead.Id;
                            eio.io.MatchReliability__c = 'Match on Lastname Firstname Zip';
                            continue; } 
                } else {
                   // Create lead 
                }
            
                
                // else 
                // If match on email
                //ImportObject.contactId = emailsmap.get(email);
                // if match on Lead,ImportObject.leadId = emailsmap.get(email);
                // IMportObject.MatchReliability__c = 'Match on email';
                // continue
            }   
}
}
        }

                // For all those without probable matches, we create new leads or contacts
        // We add the new leads or contacts to the DIO.Id,Person.Id map
        // For each DIO we choose the highest probability match
        // We remove all the matched records from the list of records
        // We create a set by email, create the new leads and contacts, return a list of the new 
        // 	In each DIO record insert LeadId or ContactId;
        update records;
        return records;
        AvoidRecursiveContributionTrigger.setClosed();
        // Refresh account totals;
        return null;
    }
    
    public class enhancedIO{
        public ImportObject__c IO {get; set;}
        public string IOemail {get; set;}
        public string IOlastname {get; set;}
        public string IOfirstname {get; set;}
        public string IOphoneHome {get; set;}
        public string IOphoneWork {get; set;}
        public string IOphoneOther {get; set;}
        public string IOmobile {get; set;}
        public string IOzip {get; set;}
        
        public enhancedIO(ImportObject__c IO){
            IOemail = IO.Person_EmailPersonal__c == null ? IOemail = IO.Person_EmailWork__c : IO.Person_EmailPersonal__c;
            IOlastname = IO.Person_LastName__c;
            IOfirstname = IO.Person_FirstName__c;
            IOphoneHome = IO.Person_PhoneHome__c;
            IOphoneWork = IO.Person_PhoneWork__c;
            IOphoneOther = IO.Person_PhoneOther__c;
            IOmobile = IO.Person_PhoneMobile__c;
            IOzip = IO.Address_zipCode__c;
        }
        
    }
}

// Enable DuplicateRule for ImportObject
// New ImportObject triggers MatchingResult
// If certainly a dupe, use the match (DuplicateErrorClass)
// If much uncertainty, ask user if they want the match
// Otherwise create new