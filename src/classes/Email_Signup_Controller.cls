// Added ability to append campaign id so that people can sign up for a campaign.
// When they sign up for a campaign, the name of the campaign is inserted into contact.mailing_lists__c.
// Jan 7 2017 Included the insertEmailListContact so that the Prescott Creeks RESTEmail controller can use this too.
// 23 May 2019 Added code to append new Dsscription to exisitng description field for Lead and Contact
global without sharing class Email_Signup_Controller {
    
    public Contact pcontact;
    WGSettings__mdt Setting;
    public string mailing_list;
    public Campaign camp {get; set;}
    public string OrgName {get; set;}
    public Boolean Thankspage {get; set;}
    public Boolean CampaignExists {get; set;}
    public Boolean SetUpTrial {get; set;}
    public String CustomQuestion1Answer {get;set;}
    public String CustomQuestion2Answer {get;set;}
    public Email_Signup_Controller(ApexPages.StandardController Controller) {
        this.pcontact=(Contact)Controller.getRecord();
        // In the case that the page is signing up a person for a specific campaign
        system.debug('ApexPages.currentPage().getParameters().get(cid) is now ' + ApexPages.currentPage().getParameters().get('cid'));
        if (ApexPages.currentPage().getParameters().get('cid')!=null) {
            string CampID = ApexPages.currentPage().getParameters().get('cid');
            Camp = [select campaign.name, id, Description, Description_Long__c, Event_Location__c, Event_Date_Time__c, 
                    recordtypeid, Event_Cost__c,  Slots_Remaining__c, Waiver_Required__c, RequireAddress__c, Add_New_Mailing_List__c,
                    Register_Page_Message__c, Custom_Signup_Question__c, Custom_Signup_Question_2__c, type from Campaign where
                    id = :CampID];
        }
        if (Camp!=null) {
            CampaignExists = true;
        } else {
            CampaignExists = false;
        }
        mailing_list = WGHelpers.getWGSettings().Online_signup_newsletter__c;
        system.debug('In constructor, mailing_list is ' + mailing_list);
        ThanksPage = false;
    }
    
    // public Email_Signup_Controller(){}
    
    //Public contact pcontact {get; set;}
    Public ID sID {get; set;}
    Public string stype;
    public lead tempLead {get; set;}
    public contact tempContact {get; set;}
    public List<String> results {get; set;}
    
    
    public PageReference submit(){
        String[] sresults = identifyorcreatePerson.IdentifyOrCreatePerson(pContact);
        List<CampaignMember> CMList = new List<CampaignMember>();
        sID = sresults[0];
        stype = sresults[1];
        system.debug('results is ' + sresults);
        system.debug('stype is ' + stype);
        if (stype=='Contact') {
            tempContact = [select id, firstname, lastname, phone, mailingStreet, mailingCity, mailingState, 
                           MailingPostalCode, email, Mailing_Lists__c from contact where id = :sID];
            // Update email
            tempContact.email = pcontact.email;
            tempContact.Description = tempContact.Description==null ? pcontact.Description : tempContact.Description + '; ' + pcontact.Description;
            // If Mailing_Lists__c is blank, send it to the first method.
            if (string.isBlank(tempContact.Mailing_Lists__c) && ((Camp != null && Camp.Add_New_Mailing_List__c) || Camp == null ))
                tempContact.Mailing_Lists__c = getMailingList();
            // If not blank, send to second method
            if (string.isNotBlank(tempContact.Mailing_Lists__c) && ((Camp != null && Camp.Add_New_Mailing_List__c) || Camp == null ))
                tempContact.Mailing_Lists__c = getMailingList(tempContact.Mailing_Lists__c);
            update tempContact;
        }
        else {
            if (stype=='Lead') {
                tempLead = [select id, firstname, lastname, Description, PostalCode, email, Mailing_Lists__c from lead where id = :sID];
                /*if (templead.email == null) */ templead.email = pcontact.email;
                tempLead.LeadSource = 'Online Email Signup';
                tempLead.email=pcontact.email;
                tempLead.Description = tempLead.Description==null ? pcontact.Description : tempLead.Description + '; ' + pcontact.Description;
                if (OrgName!=null) tempLead.Company=OrgName;
                if (string.isBlank(tempLead.Mailing_Lists__c) && ((Camp != null && Camp.Add_New_Mailing_List__c) || Camp == null ))
                    tempLead.Mailing_Lists__c = getMailingList();
                // If not blank, send to second method
                if (string.isNotBlank(tempLead.Mailing_Lists__c) && ((Camp != null && Camp.Add_New_Mailing_List__c) || Camp == null ))
                    tempLead.Mailing_Lists__c = getMailingList(tempLead.Mailing_Lists__c);
                update tempLead;
            }
        }
        if (Camp!=null) {
            CampaignMember cm = new CampaignMember(
                Leadid = stype == 'Lead'?  tempLead.id : null,
                ContactId = stype == 'Contact'?  tempContact.id : null,
                CampaignId = camp.id,
                Questions_or_Comments__c = 'Signed up for ' + OrgName + ' with comments ' + pcontact.Description,
                    SignupQuestionAnswer__c = CustomQuestion1Answer==null ? null : CustomQuestion1Answer,
                    SignupQuestionAnswer2__c = CustomQuestion2Answer==null ? null : CustomQuestion2Answer,
                Status = 'Responded Yes');
            CMList.add(cm);
        }
        if (CMList.size() > 0) {
            Database.saveResult[] LSR = Database.insert(CMList, false);
            for (Database.SaveResult sr : LSR) {
                if (!sr.isSuccess()) {
                    // Error processing here
                }
            }
        }
        if (SetUpTrial==true){
            String Taskname = String.IsEmpty(Orgname) ? 'unidentified organization' : Orgname;
            Task tsk = new Task(
                    Subject = 'Create trial database for ' + Taskname,
                    // WhatId = [select Id from Opportunity Limit 1].Id,
                    ownerId = UserInfo.getUserId(),
                    WhoId = sresults[0],
                    Status = 'New',
                    Type = 'Call',
                    Description = pcontact.description,
                    ActivityDate = system.today().addDays(2),
                    IsReminderSet=true,
                    ReminderDateTime=system.now().addHours(24)
            );
            insert tsk;
        }
        // Right here insert Lead or contact into method call
        // sendAcknowledgementEmail(stype);
        string APString = string.ValueOf(apexPages.currentPage());
        system.debug('APString is ' + APstring);
        PageReference Thanks_Page = Page.Email_Signup_Thank_Page;
        if (APString.TOUPPERCASE().CONTAINS('EMAILSIGNUPPAGEBOOTSTRAP')){
            ThanksPage = true;
            return null;
        } else {
            Thanks_Page = Page.Email_Signup_Thank_Page;
            Thanks_Page.setRedirect(false);
            return Thanks_Page;
        }
    }
    
    //Add Campaign.Name to MailingLists values
    public string getMailingList() {
        if (Camp != null && Camp.Add_New_Mailing_List__c == true) {
            return Camp.Name;
        } else {
            if (mailing_list != null)
                return mailing_list;
        }
        return null;
    }
    
    //Mailing List already exists
    public string getMailingList(string ML){
        if(Camp!=null && Camp.Add_New_Mailing_List__c == true) {
            if (!ML.contains(Camp.Name)) {
                return ML + '; ' + Camp.Name;
            } else {
                return ML;
            }
        } else {
            if (!ML.contains(mailing_list)) {
                           return ML + '; ' + mailing_list;
            } else {
                           return ML;
                       }
        }
    }


    // The following code for a Captcha button
    @RemoteAction
    global static boolean validCaptcha(string challenge, string response)
    {
        boolean correctResponse = false;
        string secret = '6LcoI9kSAAAAAAABNpurbDy8hTEyRi2tW81n4yTz';
        string publicKey = '6LcoI9kSAAAAAJ-eFtBToTbDqT6s8BZ5-QMXMCDJ';
        string baseUrl = 'https://www.google.com/recaptcha/api/verify';

        string body ='privatekey='+ secret +  '&remoteip=' + remoteHost() + '&challenge=' + challenge + '&response=' + response + '&error=incorrect-captcha-sol';

        HttpRequest req = new HttpRequest();
        req.setEndpoint( baseUrl );
        req.setMethod('POST');
        req.setBody (body);
        try
        {
            Http http = new Http();
            HttpResponse captchaResponse = http.send(req);
            System.debug('response: '+ captchaResponse);
            System.debug('body: '+ captchaResponse.getBody());
            if ( captchaResponse != null )
            {
                correctResponse = ( captchaResponse.getBody().contains('true') );
            }

        }
        catch( System.Exception e)
        {
            System.debug('ERROR: '+ e);
        }
        return correctResponse;
    }

public string insertEmailListContact(contact pcontact) {
    system.debug('in insertEmailListContact mailing_list is ' + mailing_list);
    String[] sresults = identifyorcreatePerson.IdentifyOrCreatePerson(pContact);
    sID = sresults[0];
    stype = sresults[1];
    system.debug('results is ' + sresults);
    system.debug('stype is ' + stype);
    if (stype=='Contact') {
        tempContact = [select id, firstname, lastname, phone, mailingStreet, mailingCity, mailingState, 
                MailingPostalCode, email, Mailing_Lists__c from contact where id = :sID];
        /* if (tempContact.email == null) */ tempContact.email = pcontact.email;
        if (tempContact.mailing_lists__c == null) {
                   tempContact.Mailing_Lists__c = mailing_list;
                        }
                        else {
                        tempContact.Mailing_Lists__c += '; ' + mailing_list;   
                        }
        update tempContact;
        }
        else {
            if (stype=='Lead') {
                tempLead = [select id, firstname, lastname, PostalCode, email, Mailing_Lists__c from lead where id = :sID];
                        /*if (templead.email == null) */ templead.email = pcontact.email;
                        if (tempLead.mailing_lists__c == null) {
                                   tempLead.Mailing_Lists__c = mailing_list;
                                        }
                                        else {
                                        tempLead.Mailing_Lists__c += '; ' + mailing_list;
                                        }            
                        update tempLead;
            }
        } // END ELSE CHECK IF 
        return 'Inserted ' + stype + ' with ID ' + sID;
}


    global static string remoteHost()
    {
        string ret = '127.0.0.1';
        // also could use x-original-remote-host
        try
        {
            map<string , string> hdrs = ApexPages.currentPage().getHeaders();
            if ( hdrs.get('x-original-remote-addr') != null)
            {
                ret =  hdrs.get('x-original-remote-addr');
            }
            else if ( hdrs.get('X-Salesforce-SIP') != null)
            {
                ret =  hdrs.get('X-Salesforce-SIP');
            }
        }
        catch(exception e)
        {

        }
        return ret;
    }
}