// Older version from 2017 which still works
public class ContactCustom 
{
    public String id { get; set; }
    public String name { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }    
    public String company {get; set; }
    public String email { get; set; }
    public String phone { get; set; }
    public String zip { get; set; }
    public String street { get; set; }
    public String city { get; set; }
    public String state { get; set; }   
    public Boolean over18 { get; set; }
    public Boolean newsletter { get; set; }
    public AccountContactRole acr { get; set; }
    public Boolean flag { get; set; }
    
    public String[] volunteerInterests { get; set; }
    public List<SelectOption> volunteerInterestsList { get; set; }
    public String howHeard { get; set; }
    public String[] mailingLists { get; set; }   
    
    public List<Contact> cs;
    private Contact c;
    private Lead l;
    public List<Task> ts;
    
    public ContactCustom()
    {
        this.newsletter = true;
    }
    
    public ContactCustom(List<Contact> cs)
    {
        this.cs = cs;
    }
    
    public void setVolunteerInterests()
    {
        this.volunteerInterests = new String[]{};
        this.volunteerInterestsList = new List<SelectOption>();

        for(Schema.PicklistEntry ll : Contact.Volunteer_Interests__c.getDescribe().getPicklistValues())
            this.volunteerInterestsList.add(new SelectOption(ll.getValue(), ll.getLabel()));
    }
    
    public void processBeforeInsert()
    {    
        Account a;
        Lead l;        
        Id FamilyRTID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Family').getRecordTypeId();
       
        this.ts = new List<Task>();
        
        ContactCustom cc;
        
        for(Contact c : this.cs) {
            this.c = new Contact();
            this.c.Email = c.Email;
            
            this.l = new Lead();
            
            this.setPerson();
            
            if(this.c.Id != null || this.l.Id != null) {
                Contact convertedLead;
                
                if(this.l.Id != null)                    
                    convertedLead = [ SELECT Id, AccountId FROM Contact WHERE Id =: ConvertLeadToContact.ConvertLeadToContact(this.l.Id) ];
                
                if(this.c.Id != null) {
                	c.AccountId = this.c.AccountId;
                	c.Original__c = this.c.Id;
                }
                else {
                    c.AccountId = convertedLead.AccountId;
                    c.Original__c = convertedLead.Id;
                }
                
                if(this.l.Id == null)
                	this.setTask(c, 'Merge with Existing Contact');  
                else if(this.c.Id == null)
                    this.setTask(c, 'Merge with Converted Lead');  
                else
                    this.setTask(c, 'Merge with Existing Contact and Converted Lead');  
            }
            else if(c.AccountId == null) {     
                a = new Account();
                a.RecordTypeId = FamilyRTID;
                a.Name = c.LastName + ', ' + c.FirstName + ' Household';
                a.Is_Dummy__c = true;
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
                
                this.setTask(c, 'Review New Account/Contact');                
            }
        }
        
        if(ts.size() > 0) {
            insert ts;
            
            this.sendEmail();
        }
    }
    
    public void processAfterInsert()
    {
        
    }
    
    private void setPerson()
    {
        if(this.c.Email != null) {
            List<Contact> cs = [ SELECT Id, Email, AccountId FROM Contact WHERE Email =: this.c.Email ];
            
            if(cs.size() > 0)
                this.c = cs[0];            
           
            List<Lead> ls = [ SELECT Id FROM Lead WHERE Email =: this.c.Email AND IsConverted = false ];
            
            if(ls.size() > 0)
                this.l = ls[0];      
        }
    }
    
    private void setTask(Contact c, String s)
    {
        Task t = new Task();
        t.OwnerId = c.OwnerId;
        t.WhatId = c.AccountId;
        t.Subject = s;   

        this.ts.add(t);
    }
    
    private void sendEmail()
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
        mail.setTreatTargetObjectAsRecipient(true);
        mail.saveAsActivity = false;
        
        for(Task t : this.ts) {
            body += '<table>';
            body += '<tr> <td> # </td> <td> ' + count + '</td> </tr>';
            body += '<tr> <td> task </td> <td> <a href="' + System.URL.getSalesforceBaseURL().toExternalForm() + '/' + t.id + '">' + t.Subject + '</a> </td> </tr>';
            body += '</table>';
            
            count++;
        }
        
        mail.setHtmlBody(body);
        mail.setPlainTextBody(body.stripHtmlTags());
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
    }
}


// Newer version which needs to be bulkified
//public class ContactCustom 
/*
{
    public String id { get; set; }
    public String name { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }    
    public String company {get; set; }
    public String email { get; set; }
    public String phone { get; set; }
    public String zip { get; set; }
    public String street { get; set; }
    public String city { get; set; }
    public String state { get; set; }   
    public Boolean over18 { get; set; }
    public Boolean newsletter { get; set; }
    public AccountContactRole acr { get; set; }
    public Boolean flag { get; set; }
    
    public String[] volunteerInterests { get; set; }
    public List<SelectOption> volunteerInterestsList { get; set; }
    public String howHeard { get; set; }
    public String[] mailingLists { get; set; }   
    
    public List<Contact> cs;
    private Contact c;
    private Lead l;
    public List<Task> ts;
    
    public ContactCustom()
    {
        this.newsletter = true;
    }
    
    public ContactCustom(List<Contact> cs)
    {
        this.cs = cs;
    }
    
    public void setVolunteerInterests()
    {
        this.volunteerInterests = new String[]{};
        this.volunteerInterestsList = new List<SelectOption>();

        for(Schema.PicklistEntry ll : Contact.Volunteer_Interests__c.getDescribe().getPicklistValues())
            this.volunteerInterestsList.add(new SelectOption(ll.getValue(), ll.getLabel()));
    }
    
    public void processBeforeInsert(List<Contact> cs)
    {    
        Account a;
        Lead l;        
        RecordType rt = [ SELECT Id FROM RecordType WHERE Name = 'Family' ];
       
        ts = new List<Task>();
        
        ContactCustom cc;
        
        for(Contact c : this.cs) {
            this.c = new Contact();
            Contact ca = new Contact();
            ca.Email = c.Email;
            
            l = new Lead();
            
            this.setPerson();
            
            if(c.Id != null || l.Id != null) {
                Contact convertedLead;
                
                if(l.Id != null)                    
                    convertedLead = [ SELECT Id, AccountId FROM Contact WHERE Id =: ConvertLeadToContact.ConvertLeadToContact(this.l.Id) ];
                
                if(this.c.Id != null) {
                	c.AccountId = this.c.AccountId;
                	c.Original__c = this.c.Id;
                }
                else {
                    c.AccountId = convertedLead.AccountId;
                    c.Original__c = convertedLead.Id;
                }
                
                if(this.l.Id == null)
                	this.setTask(c, 'Merge with Existing Contact');  
                else if(this.c.Id == null)
                    this.setTask(c, 'Merge with Converted Lead');  
                else
                    this.setTask(c, 'Merge with Existing Contact and Converted Lead');  
            }
            else if(c.AccountId == null) {     
                a = new Account();
                a.RecordTypeId = rt.Id;
                a.Name = c.LastName + ', ' + c.FirstName + ' Household';
                a.Is_Dummy__c = true;
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
                
                this.setTask(c, 'Review New Account/Contact');                
            }
        }
        
        if(ts.size() > 0) {
            insert ts;
            
            this.sendEmail();
        }
    }
    
    public void processAfterInsert()
    {
        
    }
   
    private List<SObject> setPerson(List<Contact> cs)
    {
        List<Sobject> ReturnsLdsCtcts = new List<SObject>();
        for (List<Contact> c : cs) {
        if(c.Email != null) {
            List<Contact> cs = [ SELECT Id, Email, AccountId FROM Contact WHERE Email =:c.Email ];
            
            if(cs.size() > 0)
                c = cs[0];            
           
            List<Lead> ls = [ SELECT Id FROM Lead WHERE Email =: this.c.Email AND IsConverted = false ];
            
            if(ls.size() > 0)
                l = ls[0];   
        }
        }
    }
    
    private void setTask(Contact c, String s)
    {
        Task t = new Task();
        t.OwnerId = c.OwnerId;
        t.WhatId = c.AccountId;
        t.Subject = s;   

        this.ts.add(t);
    }
    
    private void sendEmail()
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
        mail.setTreatTargetObjectAsRecipient(true);
        mail.saveAsActivity = false;
        
        for(Task t : this.ts) {
            body += '<table>';
            body += '<tr> <td> # </td> <td> ' + count + '</td> </tr>';
            body += '<tr> <td> task </td> <td> <a href="' + System.URL.getSalesforceBaseURL().toExternalForm() + '/' + t.id + '">' + t.Subject + '</a> </td> </tr>';
            body += '</table>';
            
            count++;
        }
        
        mail.setHtmlBody(body);
        mail.setPlainTextBody(body.stripHtmlTags());
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
    }

}
*/