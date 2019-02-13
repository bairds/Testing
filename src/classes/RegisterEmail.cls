//The registerEmail class test and page allow registering for the default mailing list,
// or with cid= registering for a particular campaign.

public without sharing class RegisterEmail
{    
    public Contact co { get; set; }
    public Lead l { get; set; }
    public List<FieldSetCustom> cofs { get; set; }
    public ContactCustom coc { get; set; }
    
    public String s { get; set; }  
    public String a { get; set; }
    
    public List<SelectOption> Picklist { get; set; }
    
    private ColorScheme__c cs { get; set; }
    public Style st { get; set; }
    
    private PageReference cpr;
    
    public RegisterEmail()
    {
        this.cpr = System.currentPageReference();
        
        if(this.cpr != null) {
            this.s = this.cpr.getParameters().get('s');
            this.a = this.cpr.getParameters().get('a');
        }
        
        if(String.isEmpty(this.s))
            this.s = '1';
        
        if(String.isEmpty(this.a))
            this.a = '1';
    } 
    
    public void setRegisterEmail()
    {
        this.setPerson('registerEmailList');
        this.coc.MailingLists = new String[]{};
        
        this.Picklist = new List<SelectOption>();         
                
        DescribeFieldResult dfr = Contact.Mailing_Lists__c.getDescribe();
        
        for(PicklistEntry ple : dfr.getPicklistValues())
            this.Picklist.add(new SelectOption(ple.getValue(), ple.getLabel()));        
        
        this.st = new Style();
        
        List<ColorScheme__c> checkCS = [SELECT Id, Background__c, Foreground__c FROM ColorScheme__c WHERE Name = 'Title'];  
                
        if(checkCS.size() > 0) {
            this.cs = checkCS[0];
            
            this.st.title = 'background-color: #' + this.cs.Background__c + '; color: #' + this.cs.Foreground__c;
            this.st.container = 'background-color: #' + this.cs.Foreground__c;
        }
        
        checkCS = [SELECT Id, Background__c, Foreground__c FROM ColorScheme__c WHERE Name = 'Form'];  
        
        if(checkCS.size() > 0) {
            this.cs = checkCS[0];
            
            this.st.form = 'background-color: #' + this.cs.Background__c + '; color: #' + this.cs.Foreground__c;    
        }
    }
    
    private void setPerson(String fs)
    {
        this.l = new Lead();  
        this.coc = new ContactCustom();
        this.cofs = FieldSetCustom.getList(Contact.sObjectType.getDescribe(), fs);        
                
        this.co = new Contact(); 
        
        if(this.cpr != null)
        	this.co.Id = this.cpr.getParameters().get('co');
        
        if(String.isNotEmpty(this.co.Id)) {
            this.co = [ SELECT Id, Birthdate, FirstName, LastName, Email, MailingPostalCode, MailingStreet, MailingCity, MailingState, Phone FROM Contact WHERE Id =: this.co.Id ];
            this.coc.phone = this.co.Phone;
            this.coc.email = this.co.Email;
            this.coc.zip = this.co.MailingPostalCode;        
        }
    }        
        
    public void review()
    {            
        this.co.Phone = this.coc.phone;
        this.co.MailingPostalCode = this.coc.zip;
        
        if(String.isNotEmpty(this.coc.company))
            this.l.Company = this.coc.company;
        
        if(this.coc.MailingLists != null && this.coc.MailingLists.size() > 0)
            this.co.Mailing_Lists__c = String.valueOf(this.coc.MailingLists);
        
        for(FieldSetCustom fsc : this.cofs) {
            if(fsc.Type != 'field') {
                if(fsc.Type == 'MULTIPICKLIST') {
                    if(fsc.Value.StrL.size() > 0)
                        this.co.put(fsc.Name, String.valueOf(fsc.Value.StrL).substringBetween('(', ')').replace(',', ';'));
                    else
                        this.co.put(fsc.Name, null);
                }
                else
                    this.co.put(fsc.Name, fsc.Value.Str);
            }
        }
        
        if(this.s == '1')
            this.s = '2';
        else
            this.s = '3';       
    }
    
    public void back()
    {
        if(this.s == '3')
            this.s = '2';
        else
            this.s = '1'; 
    }
    
    public PageReference registerEmail()
    {
        PageReference url = new PageReference('/apex/registerEmailThankPage');
        
        String [] r = identifyorcreatePerson.identifyorCreatePerson(this.co);
        Id i = (Id)r[0];
                        
        if(r[1] == 'Lead') {      
            this.l.Id = i;
            
            Lead temp = [SELECT Mailing_Lists__c FROM Lead WHERE Id =: this.l.Id LIMIT 1];    
                        
            this.l.Mailing_Lists__c = this.getMailingLists(temp.Mailing_Lists__c);
            
            Set<String> lf = SObjectType.Lead.fields.getMap().keySet();
            
            List<FieldSetMember> fs = SObjectType.Contact.FieldSets.registerEmailList.getFields();
            
            String n;
            
            for(FieldSetMember f : fs) {
                n = f.getFieldPath();       
                
                if(lf.contains(n.toLowerCase()))
                    this.l.put(n, this.co.get(n));        
            }
            
            update this.l;
        }
        else {            
            this.co.Id = i;
            
            Contact temp = [SELECT Mailing_Lists__c FROM Contact WHERE Id =: this.co.Id LIMIT 1];    
                        
            this.co.Mailing_Lists__c = this.getMailingLists(temp.Mailing_Lists__c);
            
            update this.co;            
        }   
        
        for(String interest : this.coc.MailingLists) {            
            List<Campaign> checkC = [SELECT Id FROM Campaign WHERE Name =: interest];
            
            if(checkC.size() > 0) {
                Campaign c = checkC[0];
                
                CampaignMember cm = new CampaignMember();
                List<CampaignMember> checkCM;
                
                if(String.isNotBlank(this.l.Id)) {
                    checkCM = [SELECT Id FROM CampaignMember WHERE LeadId =: this.l.Id AND CampaignId =: c.Id]; 
                    cm.LeadId = this.l.Id;                    
                }
                else {
                    checkCM = [SELECT Id FROM CampaignMember WHERE ContactId =: this.co.Id AND CampaignId =: c.Id]; 
                    cm.ContactId = this.co.Id; 
                }
                
                if(checkCM.size() == 0) {
                    cm.CampaignId = c.Id;
                    cm.Status = 'Added to campaign';
                    
                    insert cm;
                }
            }
        }
        /* In any case, enter this lead or contact as a member in the campaign, if a campaign exists
        if (System.currentPageReference().getParameters().get('cid') != null) {
            CampaignMember cm = new CampaignMember();
            if(String.isNotBlank(this.L.Id)) {
                    cm.LeadId = this.l.Id;                    
                }
                else {
                    cm.ContactId = this.co.Id; 
                }
                    cm.CampaignId = System.currentPageReference().getParameters().get('cid');
                    cm.Status = 'Added to campaign';
            insert cm;
        }*/
        
        
        return url;
    }
    
    public String getMailingLists(String mailingList)
    {
        String[] mailingListsFinal = this.coc.MailingLists;
        
        if(String.isNotBlank(mailingList)) {            
            String[] mailingLists = mailingList.replace('(', '').replace(')', '').replace(',',';').split(', ', 0);           
            
            for(String ml : mailingLists) {
                Boolean exists = false;
                
                for(String ml2 : this.coc.MailingLists) {
                    if(ml == ml2) {
                        exists = true;
                        break;
                    }
                }
                
                if(!exists)
                    mailingListsFinal.add(ml);
            }
        }
        
        return String.valueOf(mailingListsFinal).substringBetween('(', ')').replace(',', ';');
    }
}