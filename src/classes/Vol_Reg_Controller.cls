public class Vol_Reg_Controller {


public Vol_Reg_Controller(ApexPages.StandardController stdController) {
    WGSettings__mdt Setting = WGHelpers.getWGSettings();
    mailing_list = Setting.online_signup_newsletter__c;
}


//DECLARE VARIABLES 
Public campaign camp;
Public string passCampID {get; set;}
Public Contact pcontact;
public List<String> results {get; set;}
Public Lead newlead {get; set;}
Public Campaignmember pcampmmbr; // Preliminary campmmbr to hold value of how_heard_about_event__c
Public Campaignmember campmmbr;
Public Opportunity Op;
Public contact TempContact;
Public lead tempLead;
Public boolean paidevent;
Public string Comments {get; set;}
Public string Company {get; set;}
Public string HowHeardAbout {get; set;}
// Public string HowFoundOut {get; set;}
Id leadrt = [select Id from Recordtype where name = 'Online Signup' AND SobjectType ='Lead'].Id;
// Public boolean createnewlead {get; set;}
// Public boolean readytosubmit {get; set;}
Public boolean enewsletters {get; set;}
Boolean CampmmbrExists = false;
Public string companyString {get; set;}
private List<Campaign> mCampaign;
Public boolean isEventFull {get; set;} 
Public boolean EventFull {get; set;}
    Public WGSettings__mdt Setting;
public string mailing_list;

public String selectedHearAboutActivity {get; set;}
public String selectedCarPooling {get; set;}
 
//CONTACT VARIABLE TO HOLD CONTACT FIELDS
public Contact getpContact(){
if (pcontact == null) {
pcontact = new Contact();
}
return pcontact;   
}

//CAMPMMBR VARIABLE TO HOLD CONTACT FIELDS
public CampaignMember getpcampmmbr(){
if (pcampmmbr == null) {
pcampmmbr = new CampaignMember();
}
return pcampmmbr;   
}

// RADIO OPTIONS - Volunteer Interests  REDO THIS
public List<SelectOption> getVolInterestOptions() {
    List<SelectOption> options = new List<SelectOption>{};
    Schema.sObjectType sObjType = Contact.getSObjectType();
    Schema.DescribeSObjectResult sObjResult = sObjType.getDescribe();
    Map<String, Schema.SObjectField> sObjFields = sObjResult.fields.getMap();
    List<Schema.PicklistEntry> picklistValues = sObjFields.get('Volunteer_Interests__c').getDescribe().getPickListValues();
    for (Schema.PicklistEntry entry : picklistValues) { 
        options.add(new SelectOption(entry.getLabel(), entry.getValue()));
    }
    return options;
}

// RADIO OPTIONS - Car Pooling  REDO THIS
public List<SelectOption> getCarPoolingOptions() {
    List<SelectOption> options = new List<SelectOption>{};
    Schema.sObjectType sObjType = CampaignMember.getSObjectType();
    Schema.DescribeSObjectResult sObjResult = sObjType.getDescribe();
    Map<String, Schema.SObjectField> sObjFields = sObjResult.fields.getMap();
    List<Schema.PicklistEntry> picklistValues = sObjFields.get('Car_pooling__c').getDescribe().getPickListValues();
    for (Schema.PicklistEntry entry : picklistValues) { 
        options.add(new SelectOption(entry.getLabel(), entry.getValue()));
    }
    return options;
}
  
//RETURN TO LIST FUNCTION
public PageReference ReturnToList(){
PageReference ReturnToList = Page.volunteer_event_select_page;
ReturnToList.setRedirect(true);
return ReturnToList;}

//Submit FUNCTION
public PageReference submit(){   
    system.debug('if results null identifysigner.  results is ' + results);
    identifySigner();
    PageReference Thanks_Page = Page.Volunteer_Reg_Thank_Page;
    Thanks_Page.setRedirect(false);
    return Thanks_Page;
    }  //END submit

//Identify Contact or Lead
public String [] IdentifySigner() { 
//declare a list to store results
results = new String[2];
//If contact exists
    Contact[] pccheck = [Select ID, AccountID from Contact where email = :pcontact.email];
    if (pccheck.size() > 0) {
    pccheck[0].Mailingstreet=pcontact.MailingStreet;
    pccheck[0].Mailingcity=pcontact.MailingCity;
    pccheck[0].Mailingstate=pcontact.MailingState;
    pccheck[0].MailingpostalCode=pcontact.MailingPostalCode;
    pccheck[0].Over_18__c=pcontact.Over_18__c;
    pccheck[0].phone=pcontact.Phone;
    pccheck[0].volunteer_interests__c=pcontact.Volunteer_Interests__c;
    pccheck[0].volunteer_skills__c=pcontact.Volunteer_Skills__c;
    pccheck[0].description+='Comments upon registering as volunteer: ' + Comments + '\n\nHow heard about HRWC? ' + HowHeardAbout;
    update pccheck[0];
    results[0] = pccheck[0].id;
    results[1] = 'Contact';
    return results;
    }
    ELSE {
        //If lead exists
        Lead[] lcheck = [Select Id from Lead where email = :pcontact.email];
        system.debug('pcontact.email is ' + pcontact.email);
        if (lcheck.size() > 0) {
        lcheck[0].street=pcontact.MailingStreet;
        lcheck[0].city=pcontact.MailingCity;
        lcheck[0].state=pcontact.MailingState;
        lcheck[0].postalCode=pcontact.MailingPostalCode;
        lcheck[0].Over_18__c=pcontact.Over_18__c;
        lcheck[0].phone=pcontact.Phone;
        lcheck[0].volunteer_interests__c=pcontact.Volunteer_Interests__c;
        lcheck[0].volunteer_skills__c=pcontact.Volunteer_Skills__c;
        lcheck[0].description+='Comments upon registering as volunteer: ' + Comments + '\n\nHow heard about HRWC? ' + HowHeardAbout;
        update lcheck[0];
        results[0] = lcheck[0].Id;
        results[1] = 'Lead';
        // readyToSubmit = true;
        return results;
        }
        ELSE 
        {
            //does contact exist based on name and zip code?
            pccheck = [Select ID, AccountID from Contact 
                where (firstname = :pcontact.firstname AND lastname = :pcontact.lastname
                AND  MailingPostalCode = :pcontact.MailingPostalCode)];
            if (pccheck.size() > 0) {
            pccheck[0].Mailingstreet=pcontact.MailingStreet;
            pccheck[0].Mailingcity=pcontact.MailingCity;
            pccheck[0].Mailingstate=pcontact.MailingState;
            pccheck[0].MailingpostalCode=pcontact.MailingPostalCode;
            pccheck[0].Over_18__c=pcontact.Over_18__c;
            pccheck[0].phone=pcontact.Phone;
            pccheck[0].volunteer_interests__c=pcontact.Volunteer_Interests__c;
            pccheck[0].volunteer_skills__c=pcontact.Volunteer_Skills__c;
            pccheck[0].description+='Comments upon registering as volunteer: ' + Comments + '\n\nHow heard about HRWC? ' + HowHeardAbout;
            update pccheck[0];
            results[0] = pccheck[0].ID;
            results[1] = 'Contact';
            //    readyToSubmit = true;
            system.debug('Passed: Identified contact by name and zip code');
            return results;
            }
            ELSE {
                //does LEAD exist based on name and zip code?
                lcheck = [Select ID, firstname, lastname, PostalCode from Lead 
                    where (firstname = :pcontact.firstname AND lastname = :pcontact.lastname
                    AND PostalCode = :pcontact.MailingPostalCode)];
                if (lcheck.size() > 0) {
                lcheck[0].street=pcontact.MailingStreet;
                lcheck[0].city=pcontact.MailingCity;
                lcheck[0].state=pcontact.MailingState;
                lcheck[0].postalCode=pcontact.MailingPostalCode;
                lcheck[0].Over_18__c=pcontact.Over_18__c;
                lcheck[0].phone=pcontact.Phone;
                lcheck[0].volunteer_interests__c=pcontact.Volunteer_Interests__c;
                lcheck[0].volunteer_skills__c=pcontact.Volunteer_Skills__c;
                lcheck[0].description+='Comments upon registering as volunteer: ' + Comments + '\n\nHow heard about HRWC? ' + HowHeardAbout;
                update lcheck[0];
                results[0] = lcheck[0].Id;
                results[1] = 'Lead';
                //        readyToSubmit = true;
                system.debug('Passed: Identified lead by name and zip code');
                
                return results;
                } //end does Lead exist based on name and zip code?
                ELSE {  
                        system.debug('companyString is ' + companyString);   
                        lead newlead = new Lead (lastname = pcontact.lastname, 
                        firstname=pcontact.firstname,
                        email=pcontact.email, 
                        company= string.isblank(CompanyString) ? 'none' : CompanyString, 
                        street=pcontact.MailingStreet,
                        city=pcontact.MailingCity,
                        state=pcontact.MailingState,
                        postalCode=pcontact.MailingPostalCode,
                        phone=pcontact.Phone,
                        over_18__c=pcontact.Over_18__c,
                        volunteer_interests__c=pcontact.Volunteer_Interests__c,
                        volunteer_skills__c=pcontact.Volunteer_Skills__c,
                        leadsource='Online Event Signup',
                        description='Comments upon registering as volunteer: ' + Comments + '\n\nHow heard about HRWC? ' + HowHeardAbout,
                        RecordTypeID = [select ID from RecordType where name = 'Online Signup' and 
                        SObjectType = 'Lead'].id); 
                        insert newlead;
                        // createNewLead = false;
                        results[0] = newlead.id;
                        results[1] = 'Lead';
                        system.debug('newlead is ' + newlead);
                        system.debug('newlead firstname is ' + newlead.firstname);  
                        // readyToSubmit = true;            
                        return results;
                        // } // end else create new lead
                    } //end if enternewlead==null go back for more info
               } // end ELSE does lead exist based on zipcode
           } // end ELSE does contact exist based on zipcode
    } // end ELSE does lead exist based on email?
} // end does contact exist based on email?
        
}
       //END CONTROLLER