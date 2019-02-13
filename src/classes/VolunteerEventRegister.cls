// Feb 2018 Modified to handle Corporate Signup more clearly
// Feb 2018 added "AcceptWaiver" and "DeclineWaiver"
// Adjusted for timezone and daylight savings
// June 2018 adjusted to catch instances where only x slots are open and the visitor signs up for >x slots
public without sharing class VolunteerEventRegister
{    
    public List<Campaign> cs { get; set; }
    public List<CampaignPlus> cps {get; set;}
    public Campaign c { get; set; }    
    public CampaignCustom cc { get; set; }
    public CampaignMember cm { get; set; }
    public datetime DateTimeStartAdjusted {get; set;}
    public datetime DateTimeEndAdjusted {get; set;}
    public Contact co { get; set; }
    public ContactCustom coc { get; set; }    
    public List<FieldSetCustom> cofs { get; set; }
    public List<FieldSetCustom> cmfs { get; set; }
    public Lead l { get; set; }   
    public Opportunity o { get; set; }
    public List<CampaignMember> checkCM {get; set;}
    public boolean WaiverExists {get; set;}
    public boolean AcceptWaiver {get; set;}
    public boolean DeclineWaiver {get; set;}
    public boolean LastAccepted {get;set;}
    public boolean NoAvailableCampaigns {get; set;}

    
    public String step { get; set; } //step
    public String s {get; set;} // Added this because it's reference somewhere in the page, though it should be gone and replaced by step
    public String query { get; set; }    
    
    public String lo { get; set; } //logo
    public String title { get; set; }
    public String errors { get; set; }
    public double tzoffset {get; set;}
    public timezone tz {get; set;}
    public url initialurl {get; set;}
    
    public VolunteerEventRegister()
    {       
        this.query = '';
        
        this.step = System.currentPageReference().getParameters().get('step');
        
        if(String.isBlank(this.step))
            this.step = '1';
        
        this.lo = 'OrgLogo';  
        tz = UserInfo.getTimeZone();
        this.tzoffset = WGHelpers.getoffset();  
    }
    
    public void setMasterCampaign()
    {  
        cps = new List<CampaignPlus>();
        String mid = System.currentPageReference().getParameters().get('mid');
        
        String query = 'SELECT Id, Name, Description, Event_Date_Time__c, Event_End_Time__c, Event_Location__c, Recordtypeid, Event_Cost__c,  Slots_Remaining__c, Waiver_Required__c, ' +
            'Slots_Reserved__c, Type, Master_Campaign__r.Name, (select id, Role__c from CampaignMembers) FROM Campaign ' +
            'WHERE Event_Date_Time__c >= TODAY AND (recordtype.name = \'Public Event\' OR recordtype.name = \'Volunteer Event\') AND Slots_Remaining__c > 0 AND IsActive = true';
        if (mid!=null) query += ' AND Master_Campaign__c = \'' + mid + '\'';        
        query += ' ORDER BY Event_Date_Time__c, Name';
        
        cs = Database.query(query);
        
        // Remove campaign from list if it's a Corporate volunteer event with a Group Leader
        for (integer i=0;i<cs.size();i++){
            if (cs[i].Type == 'Corporate volunteer event') {
                for (CampaignMember campmmbr : cs[i].CampaignMembers) {
                    if (campmmbr.Role__c == 'Group leader') {
                        cs.remove(i);
                        continue;
                    }
                        
                }
            }
        }
        // Transform campaign list into CampaignPlus list for VF Page       
        For (campaign c : cs) {
            cps.add(new CampaignPlus(c));
        }  
        if (cs.size()==0) NoAvailableCampaigns = true;
    }
    
    public void setSignUp()
    {           
        String cid = System.currentPageReference().getParameters().get('cid');
        String coid = System.currentPageReference().getParameters().get('coid');
        String lid = System.currentPageReference().getParameters().get('lid');        
        
        this.l = new Lead();
        this.coc = new ContactCustom();
        this.cofs = FieldSetCustom.getList(Contact.sObjectType.getDescribe(), 'volunteerEventRegister');  
        this.cc = new CampaignCustom();
        this.cm = new CampaignMember();
        this.cmfs = FieldSetCustom.getList(CampaignMember.sObjectType.getDescribe(), 'volunteerEventRegister');  
        
        this.cc.setSignUpScopeTypes();
        
        if(String.isNotBlank(cid)) {
            this.query += '&cid=' + cid;
            
            this.c = [SELECT Id, Name, Description, Description_Long__c, Event_Cost__c, Event_Location__c, Event_Date_time__c, Event_End_Time__c, Logo__c, Waiver_Required__c, Slots_Remaining__c,
                      Host__c, Waiver__c, Waiver__r.Body__c, Master_Campaign__c, Signup_Questions__c, Type, AllGroupMmbrsRegister__c, CompletionURL__c, Slots_Reserved__c,
                      Custom_Signup_Question__c, Custom_Signup_Question_2__c, Allow_Group_Signup__c
                      FROM Campaign WHERE Id =: cid LIMIT 1];
            
            //Adjust the times for timezone and dst
            CampaignPlus CP = new CampaignPlus(c);
            DateTimeStartAdjusted = cp.datetimelocal;
            DateTimeEndAdjusted = cp.datetimelocalend;
            
            title = 'Sign Up for ' + this.c.Name;

            WaiverExists = (c.Waiver__c != null && c.Waiver__r.Body__c != null);
            
            if(String.isNotEmpty(this.c.Logo__c))
                this.lo = this.c.Logo__c;            
            
            this.cc.MasterCampaign = this.c.Master_Campaign__c;            
            this.cc.sethowHeardAboutEvent();
            this.cc.setShirtSizes();
            
            if(this.c.Type == 'Corporate volunteer event') {            
                this.checkCM = [SELECT Id, Group__c, Nr_Adults__c, Nr_in_Group__c FROM CampaignMember WHERE Campaignid =: this.c.Id AND Role__c = 'Group leader' LIMIT 1 ];     
                //BAIRD: THISIS TOO EARLY TO SET THE NR_IN_GROUP VALUE.
                if(checkCM.size() > 0) {
                    CampaignMember cml = checkCM[0];
                    this.cm.Role__c = 'Volunteer';
                    this.cm.Group__c = cml.Group__c;
                    this.title += ' with ' + this.cm.Group__c;
                }
                else {
                    this.cm.Role__c = 'Group leader'; 
                    this.o = new Opportunity();
                }
            }
            else {
                if(this.c.Slots_Remaining__c <= 0)
                    this.errors = 'This event is full. Please try a different one.';
            }
        } 
        
        if(String.isNotBlank(coid)) {
            this.query += '&coid=' + coid;          
            this.co = this.getContact(coid);
            
            this.coc.firstName = this.co.FirstName;
            this.coc.lastName = this.co.LastName;
            this.coc.email = this.co.Email;
            this.coc.zip = this.co.MailingPostalCode;
            this.coc.phone = this.co.Phone;
        }
        else {
            this.co = new Contact();
            
            if(String.isNotBlank(lid)) {               
                this.query += '&lid=' + lid; 
                this.l = this.getLead(lid);
                
                this.coc.firstName = this.l.FirstName;
                this.coc.lastName = this.l.LastName;
                this.coc.email = this.l.Email;
                this.coc.zip = this.l.PostalCode;
                this.coc.phone = this.l.Phone;
                
                if((String.isBlank(this.l.Street) || String.isBlank(this.l.City) || String.isBlank(this.l.State) ||
                    String.isBlank(this.l.Volunteer_Interests__c) || String.isBlank(this.l.How_Heard__c)) && this.step == '3') {
                        this.step = '2';
                        this.coc.setVolunteerInterests();
                        
                        this.coc.street = this.l.Street;
                        this.coc.city = this.l.City;
                        this.coc.state = this.l.State;
                        
                        if(String.isNotBlank(this.l.Volunteer_Interests__c)) 
                            this.coc.volunteerInterests = this.l.Volunteer_Interests__c.split(';', 0);
                        
                        this.coc.howHeard =  this.l.How_Heard__c;
                    }
            }
        }
    }
    
    private Contact getContact(String i)
    {
        //if (co != null){
        String q =  'SELECT Id, FirstName, LastName, Email, Phone, MailingPostalCode';
        
        for(Schema.FieldSetMember f : SObjectType.Contact.FieldSets.volunteerEventRegister.getFields())
            q += ', ' + f.getFieldPath();
        
        q += ' FROM Contact WHERE Id = \'' + i + '\' LIMIT 1';
        
        co = Database.query(q);
        // }
        return co;
    }
    
    private Lead getLead(String i)
    {
        return [SELECT Id, FirstName, LastName, Email, Phone, PostalCode, Street, City, State, Volunteer_Interests__c, How_Heard__c FROM Lead WHERE IsConverted=false AND Id =: i LIMIT 1];
    }
    
    public PageReference setSignee()
    {      
        String u = '/apex/volunteerEventRegisterPage?cid=' + this.c.Id;
        
        this.co.FirstName = this.coc.FirstName;
        this.co.LastName = this.coc.LastName;
        this.co.Email = this.coc.Email;
        this.co.Phone = this.coc.Phone;
        this.co.MailingPostalCode = this.coc.Zip;
        
        String [] r = identifyorcreatePerson.identifyorCreatePerson(this.co);
        Id i = (Id)r[0];
        
        if(r[1] == 'Lead') {               
            this.l.Id = i;
            
            u += '&lid=' + i;
            
            update this.l;
        }
        else {         
            this.co.Id = i;
            
            u += '&coid=' + i;
            
            update this.co;
        }        
        
        PageReference url = new PageReference(u + '&step=3');    
        url.setRedirect(true);
        
        return url;
    }
    
 public PageReference updateSignee()
    {   
        PageReference url = new PageReference('/apex/volunteerEventRegisterPage?cid=' + this.c.Id + '&lid=' + this.l.Id + '&step=3');    
        url.setRedirect(true);
        
        if(this.coc.volunteerInterests.size() > 0)
            this.l.Volunteer_Interests__c = String.valueOf(this.coc.volunteerInterests).substringBetween('(', ')').replace(',', ';');
        
        if(String.isNotBlank(this.coc.street))
            this.l.Street = this.coc.street;
        
        if(String.isNotBlank(this.coc.city))
            this.l.City = this.coc.city;
        
        if(String.isNotBlank(this.coc.state))
            this.l.State = this.coc.state;
        
        if(String.isNotBlank(this.coc.howHeard))
            this.l.How_Heard__c = this.coc.howHeard;        
        
        update this.l;
        
        return url;
    }
    
    public PageReference signUp()
    {
        String u = '/apex/ConfirmVolunteerEventRegistration?cid=' + this.c.Id;
        system.debug('Beginning signUp, AcceptWaiver is ' + AcceptWaiver + ' and DeclineWaiver is ' + DeclineWaiver);
        if (c.Waiver_Required__c==true&&acceptWaiver!=true) {
            
            PageReference url;
            this.errors = 'You must accept the waiver in order to sign up for this event.';
            
            system.debug('Without signed waiver returning to ' + url);
            return null;
        }
        
        if(String.isNotBlank(this.c.CompletionURL__c))
            u = 'http://' + this.c.CompletionURL__c.replace('http://', '');        
        
        PageReference url = new PageReference(u);    
        url.setRedirect(true);
        
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
        
        this.cm.Status = 'Responded Yes';
        this.cm.Which_Waiver_Agreed__c = this.c.Waiver__c; 
        this.cm.Agreed_to_Waiver__c = AcceptWaiver==true? true: false;       
        this.cm.Campaign_Member_Source__c = 'Web signup';
         
        System.debug('Campaign.Type is ' + c.Type + ' and cm.Role__c is ' + cm.Role__c + '.  Expected Corporate volunteer event.');
        if (c.Type == 'Corporate volunteer event') {
            if (cm.Role__c=='Group leader') {
                if (this.cm.Comments__c == null) {
                this.cm.Comments__c = 'Entered ' + this.cm.Nr_in_Group__c + ' for number in group';
                } else {
                   this.cm.Comments__c += 'Entered ' + this.cm.Nr_in_Group__c + ' for number in group'; 
                }
            }
            this.cm.Nr_in_Group__c = 1;
        } else {
            if (this.cm.Nr_in_Group__c==null) this.cm.Nr_in_Group__c=1;
        }
        
        for(FieldSetCustom fsc : this.cmfs) {
            if(fsc.Type != 'field') {
                if(fsc.Type == 'MULTIPICKLIST') {
                    if(fsc.Value.StrL.size() > 0)
                        this.cm.put(fsc.Name, String.valueOf(fsc.Value.StrL).substringBetween('(', ')').replace(',', ';'));
                    else
                        this.cm.put(fsc.Name, null);
                }
                else
                    this.cm.put(fsc.Name, fsc.Value.Str);
            }
        }
        
        List<CampaignMember> cmCheck;
        
        if(this.l.Id != null) {
            this.cm.LeadId = this.l.Id;
            
            if(this.coc.Newsletter)
                this.l.HasOptedOutOfEmail = false;
            else
                this.l.HasOptedOutOfEmail = true;
            
            Set<String> lf = SObjectType.Lead.fields.getMap().keySet();
            
            List<FieldSetMember> fs = SObjectType.Contact.FieldSets.volunteerEventRegister.getFields();
            
            String n;
            
            for(FieldSetMember f : fs) {
                n = f.getFieldPath();       
                
                if(lf.contains(n.toLowerCase()))
                    this.l.put(n, this.co.get(n));        
            }
            
            update this.l;
            
            cmCheck= [SELECT Id FROM CampaignMember WHERE LeadId =: this.l.Id AND CampaignId =: this.c.Id];
        }
        else {
            system.debug('cm is ' + cm + ' co is ' + co);
            this.cm.ContactId = this.co.Id;
            
            if(this.coc.Newsletter)
                this.co.HasOptedOutOfEmail = false;
            else
                this.co.HasOptedOutOfEmail = true;
            
            update this.co;
            
            cmCheck= [SELECT Id FROM CampaignMember WHERE ContactId =: this.co.Id AND CampaignId =: this.c.Id];
        }

        
        // INSERT DONATION ONLY FOR FIRST SIGNUP IN A CORPORATE VOLUNTEER EVENT
        if (cm.role__c == 'Group leader' && c.Type == 'Corporate volunteer event') {
           
            Recordtype rt = [SELECT Id FROM RecordType WHERE Name = 'Donation'];
            this.o.CampaignId = this.c.Id;
            this.o.Name = cm.Group__c + ' at ' + c.name + ' Corporate';
            this.o.StageName = 'Unpaid';
            this.o.CloseDate = Date.today();
            this.o.RecordTypeId = rt.Id;
            insert this.o; 
            
            //STORE NR_IN_GROUP IN COMMENTS FIELD AND SET NR_IN_GROUP TO 1 ONLY FOR FIRST SIGNUP IN A CORPORATE VOLUNTEER EVENT
            
        }
        
        
        if(cmCheck.size() == 0) {        
            this.cm.CampaignId = this.c.Id;           
            insert this.cm;
            system.debug('At insertion this.cm is ' + this.cm);
            }
        else {
            this.cm.Id = cmCheck[0].Id;
            
            update this.cm;
        }        
        return url;
    }

   
    public PageReference toggleAccept() {
        system.debug('toggleAccept begun, AcceptWaiveris ' + AcceptWaiver + ' and DeclineWaiver is ' + DeclineWaiver);
    if (AcceptWaiver==true && LastAccepted!=true) {
    DeclineWaiver=false;
    LastAccepted=true;
    } else {
    if (DeclineWaiver==true){   
    AcceptWaiver=false;
    LastAccepted=false;
    } else {
    AcceptWaiver=false;
    DeclineWaiver=true;
    }
    }
        system.debug('toggleAccept ended, AcceptWaiveris ' + AcceptWaiver + ' and DeclineWaiver is ' + DeclineWaiver);
    return null;
    }
    
    public class CampaignPlus{
        public campaign camp {get; set;}
        // This is the datetime adjusted for time zone and DST;
        public datetime datetimelocal {get; set;}
        public datetime datetimelocalend {get; set;}
        public CampaignPlus(campaign cmp){
            if (cmp.Event_Date_Time__c!=null) 
            datetimelocal = cmp.Event_Date_Time__c.addSeconds(UserInfo.getTimeZone().getOffset(cmp.Event_Date_Time__c)/1000);
            system.debug('At line 422, cmp.Event_End_Time__c is ' + cmp.Event_End_Time__c);
            if (cmp.Event_End_Time__c!=null) 
            datetimelocalend = cmp.Event_End_Time__c.addSeconds(UserInfo.getTimeZone().getOffset(cmp.Event_End_Time__c)/1000);
            camp = cmp;
        }        
    }
}