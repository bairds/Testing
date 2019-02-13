public without sharing class SignIn
{
    public Campaign c { get; set; }
    public CampaignCustom cc { get; set; }
    public VFE__c vfe { get; set; }
    
    public Contact co { get; set; }
    public Lead l { get; set; }
    public CampaignMember cm { get; set; }
    public List<FieldSetCustom> cofs { get; set; }
    public ContactCustom coc { get; set; }
    
    public String s { get; set; }  
    public String a { get; set; }
    
    public List<SelectOption> Picklist { get; set; }
    
    public SignIn()
    {
        this.s = System.currentPageReference().getParameters().get('s');
        
        if(String.isEmpty(this.s))
            this.s = '1';
        
        this.a = System.currentPageReference().getParameters().get('a');
        
        if(String.isEmpty(this.a))
            this.a = '1';
    }  
    
    public void setSignIn()
    {
        this.cc = new CampaignCustom();
        this.cc.Id = System.currentPageReference().getParameters().get('cid');
        
        if(this.s == '1') {
            if(this.a == '2' || String.isNotEmpty(this.cc.Id)) {
                this.vfe = new VFE__c();                
       			this.cc.TopText = 'For more information on our organization, please sign in here. Your information will not be shared with other organizations or businesses.';
                
                this.Picklist = new List<SelectOption>();

        		for(Text_Document__c sw : [SELECT Id, Title__c FROM Text_Document__c ORDER BY Title__c LIMIT 1000])
            		this.Picklist.add(new SelectOption(sw.Id, sw.Title__c)); 
                
                if(this.a == '2')
                    this.c = new Campaign();
                else {
                    this.selectCampaign();
                    this.cc.Name = this.c.Name;        
                    this.cc.CustomQuestion = this.c.Custom_Signup_Question__c;
                    this.cc.CustomQuestion2 = this.c.Custom_Signup_Question_2__c; 
                    this.cc.Waiver = this.c.Waiver__c;
                    this.cc.WaiverBody = this.c.Waiver__r.Body__c;
                    
                    this.vfe.Date__c = this.c.StartDate;
                    
                    this.a = '3';
                }
            }
        }
		else if(this.s == '2') {
            this.selectCampaign(); 
            
            Cookie coo = ApexPages.currentPage().getCookies().get('TopText');
            
            if(coo != null)
                this.cc.TopText = coo.getValue(); 
            
            this.setAttendee();
        }
    }  
   
    public void selectCampaign()
    {   
        this.c = [SELECT Id, Name, StartDate, Custom_Signup_Question__c, Custom_Signup_Question_2__c, Waiver__c, Waiver__r.Body__c FROM Campaign WHERE Id =: this.cc.Id];     
    }
    
    public void submitCampaign()
    {        
        this.c.Name = this.cc.Name;
        this.c.Type = this.cc.Type;
        this.c.Custom_Signup_Question__c = this.cc.CustomQuestion;
        this.c.Custom_Signup_Question_2__c = this.cc.CustomQuestion2;
        this.c.StartDate = this.vfe.Date__c;        
        this.c.IsActive = true;
        this.c.Waiver__c = this.cc.Waiver;
                
        Id rtId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Signup').getRecordTypeId();
        this.c.RecordTypeId = rtId;
        
        if(String.isBlank(this.c.Id)) {
            this.c.Id = null;
            
            insert this.c;
        }
        else
            update this.c;
        
        this.cc.Id = this.c.Id;
                
        ApexPages.currentPage().setCookies(new Cookie[]{ new Cookie('TopText', this.cc.TopText, null, -1, false) });
    }
    
    private void setAttendee()
    {
        this.setPerson('SignInList');
        
        this.cm = new CampaignMember();
        this.l.HasOptedOutOfEmail = true;  
    }
    
    private void setPerson(String fs)
    {
        this.l = new Lead();  
        this.coc = new ContactCustom();
        this.cofs = FieldSetCustom.getList(Contact.sObjectType.getDescribe(), fs);        
                
        this.co = new Contact();        
        this.co.Id = System.currentPageReference().getParameters().get('co');
        
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
    
    public void signIn()
    {
        String [] r = identifyorcreatePerson.identifyorCreatePerson(this.co);
        Id i = (Id)r[0];
                        
        if(r[1] == 'Lead') {
            this.cm.LeadId = i;         
            this.l.Id = i;
            
            if(this.l.HasOptedOutOfEmail)
                this.l.HasOptedOutOfEmail = false;
            else
                this.l.HasOptedOutOfEmail = true;
            
            Set<String> lf = SObjectType.Lead.fields.getMap().keySet();
            
            List<FieldSetMember> fs = SObjectType.Contact.FieldSets.SignInList.getFields();
            
            String n;
            
            for(FieldSetMember f : fs) {
                n = f.getFieldPath();       
                
                if(lf.contains(n.toLowerCase()))
                    this.l.put(n, this.co.get(n));        
            }
            
            update this.l;
        }
        else {
            this.cm.ContactId = i;            
            this.co.Id = i;
            
            if(this.l.HasOptedOutOfEmail)
                this.co.HasOptedOutOfEmail = false;
            else
                this.co.HasOptedOutOfEmail = true;
            
            update this.co;
        }   
        
        this.cm.Status = 'Responded Yes';
        this.cm.Which_Waiver_Agreed__c = this.c.Waiver__c;
        
        List<CampaignMember> cmCheck = [SELECT Id FROM CampaignMember WHERE (LeadId =: i OR ContactId =: i) AND CampaignId =: this.c.Id];
        
        if(cmCheck.size() == 0) {        
            this.cm.CampaignId = this.c.Id;           
                        
            insert this.cm;
        }
        else {
            this.cm.Id = cmCheck[0].Id;
            
            update this.cm;
        }
        
        this.setAttendee();
        this.back();
    }
}