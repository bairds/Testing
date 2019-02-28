public class Public_Event_Controller {

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
Id leadrt = [select Id from Recordtype where name = 'Online Signup' AND SobjectType ='Lead'].Id;
Public boolean createnewlead {get; set;}
Public boolean readytosubmit {get; set;}
Public boolean Agreed_To_Waiver {get; set;}
Public boolean Must_Sign_Waiver {get; set;}
Public boolean enewsletters {get; set;}
Boolean CampmmbrExists = false;
Public string companyString {get; set;}
private List<Campaign> mCampaign;
Public boolean isEventFull {get; set;} 
Public boolean EventFull {get; set;}
Public string mailing_list {get; set;}

    public Public_Event_Controller(ApexPages.StandardController stdController) {
        createNewLead = false;
        WGSettings__mdt Setting = WGHelpers.getWGSettings();
        mailing_list = Setting.Online_signup_newsletter__c;
    }

public List<Campaign> getCampaign() {
    if (null==mCampaign)
    {
     if (ApexPages.currentPage().getParameters().get('mid')!=null) {
        string masterCampID = ApexPages.currentPage().getParameters().get('mid');
        mCampaign= [select campaign.name, id, Description, Event_Date_Time__c,  
        recordtypeid, Event_Cost__c,  Slots_Remaining__c, Waiver_Required__c, type from Campaign where 
        (Event_Date_Time__c >= Today and Master_Campaign__c = :masterCampID and recordtype.name = 'Public Event' AND isActive=true) ORDER BY type ASC];
        }
    else // select all public events or volunteer events
        {
            mCampaign= [select campaign.name, id, Description, Event_Date_Time__c,  
        recordtypeid, Event_Cost__c,  Slots_Remaining__c, Waiver_Required__c, type from Campaign where 
        (Event_Date_Time__c >= Today and recordtype.name = 'Public Event' AND isActive=true) ORDER BY type ASC];
        }
    }
   
    return mCampaign;
}

/*
public void checkisEventFull() {
    isEventFull = true;
} // END checkisEventFull()
*/
    
//PASS IN DATA ABOUT THIS PARTICULAR CAMPAIGN
public Campaign getCamp() {
            system.debug('cid is ' + ApexPages.currentPage().getParameters().get('cid'));
        Camp = [SELECT Id ,Name, Description, Description_Long__c, Event_Cost__c, 
            Event_Location__c, Event_Date_time__c, Waiver_Required__c,
            Slots_Remaining__c FROM Campaign 
            WHERE id = :ApexPages.currentPage().getParameters().get('cid') limit 1];
        if (camp.slots_remaining__c < 1) isEventFull = true;
        system.debug('Camp.ID is now ' + Camp.ID);    
return camp;
}       
 
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
  
//RETURN TO LIST FUNCTION
public PageReference ReturnToList(){
PageReference ReturnToList = Page.Public_Event_Select_Page;
ReturnToList.setRedirect(true);
return ReturnToList;}

//Save funciton, just entered in order to make edits
public PageReference save(){
return null;}

//Submit FUNCTION
public PageReference submit(){
//MAKE SURE THEY'VE AGREED TO THE WAIVER
        system.debug('Agreed_to_Waiver '+ Agreed_to_Waiver);
        system.debug('Waiver Required '+ camp.Waiver_Required__c);
    if (Agreed_to_Waiver == false && camp.Waiver_Required__c == true) {
        Must_Sign_Waiver = true;
        return null;}
    //IF NOT ALREADY DONE, CHECK EMAIL, ZIP CODE AGAINST EXISTING LEADS AND CONTACT        
    system.debug('if results null identifysigner.  results is ' + results);
    if (results == null ) identifySigner();
    if (createNewLead == true) {
                return null;
        } 
    system.debug('readyToSubmit is ' + readyToSubmit);
    if (readyToSubmit) {
    insertCampaignMember(results[0], results[1]);
    if (pcontact.over_18__c == true) {
        system.debug('Just passed pcontact.over_18__c is true, call SetOver18');
        SetOver18();
        } // END SETOVER18
    if (enewsletters == true) SignUpNewsletter();
    //REDIRECT TO THANKYOU PAGE
    PageReference Thanks_Page = Page.Public_Event_Thanks_Page;
    Thanks_Page.setRedirect(false);
    return Thanks_Page;
    } // END IF READYTOSUBMIT
    else return null;
    }  //END SAVE


//Identify Contact or Lead
public String [] IdentifySigner() { 
//declare a list to store results
results = new String[2];
//If contact exists
    Contact[] pccheck = [Select ID, AccountID from Contact where email = :pcontact.email];
    if (pccheck.size() > 0) {
    results[0] = pccheck[0].id;
    results[1] = 'Contact';
    readyToSubmit = true;
    return results;
    }
    ELSE {
        //If lead exists
        Lead[] lcheck = [Select Id from Lead where email = :pcontact.email];
        system.debug('pcontact.email is ' + pcontact.email);
        if (lcheck.size() > 0) {
        results[0] = lcheck[0].Id;
        results[1] = 'Lead';
        readyToSubmit = true;
        return results;
        }
        ELSE 
        {
            //does contact exist based on name and zip code?
            pccheck = [Select ID, AccountID from Contact 
                where (firstname = :pcontact.firstname AND lastname = :pcontact.lastname
                AND  MailingPostalCode = :pcontact.MailingPostalCode)];
            if (pccheck.size() > 0) {
            results[0] = pccheck[0].ID;
            results[1] = 'Contact';
                readyToSubmit = true;
            system.debug('Passed: Identified contact by name and zip code');
            return results;
            }
            ELSE {
                //does LEAD exist based on name and zip code?
                lcheck = [Select ID, firstname, lastname, PostalCode from Lead 
                    where (firstname = :pcontact.firstname AND lastname = :pcontact.lastname
                    AND PostalCode = :pcontact.MailingPostalCode)];
                if (lcheck.size() > 0) {
                results[0] = lcheck[0].Id;
                results[1] = 'Lead';
                        readyToSubmit = true;
                system.debug('Passed: Identified lead by name and zip code');
                
                return results;
                } //end does Lead exist based on name and zip code?
                ELSE {
                    //if enternewlead == null go back for more contact info
                    if (createnewlead == false) {
                        createnewlead = true;
                        results = null;
                        //results[0] = ; //This is just garbage filler so that we can return results.
                        //results[1] = 'Lead';
                        return results;
                    }
                    else //create new lead
                    {       
                        if (pcontact.description == null) {
                            system.debug('passed pontact.description == null');                      
                            companyString = 'none';
                            system.debug('just set companyString to none; did it take?  companyString is ' + companyString);
                            }  
                            else {
                            companyString = pcontact.description;
                            system.debug('just passed else, set companyString to ' + pcontact.description);
                            }
                        system.debug('companyString is ' + companyString);   
                        lead newlead = new Lead (lastname = pcontact.lastname, 
                        firstname=pcontact.firstname,
                        email=pcontact.email, 
                        company=companyString, 
                        street=pcontact.MailingStreet,
                        city=pcontact.MailingCity,
                        state=pcontact.MailingState,
                        postalCode=pcontact.MailingPostalCode,
                        phone=pcontact.Phone,
                        volunteer_interests__c=pcontact.Volunteer_Interests__c,
                        leadsource='Online Event Signup',
                        RecordTypeID = [select ID from RecordType where name = 'Online Signup' and 
                        SObjectType = 'Lead'].id); 
                        insert newlead;
                        createNewLead = false;
                        results[0] = newlead.id;
                        results[1] = 'Lead';
                        system.debug('newlead is ' + newlead);
                        system.debug('newlead firstname is ' + newlead.firstname);  
                        readyToSubmit = true;            
                        return results;
                        } // end else create new lead
                    } //end if enternewlead==null go back for more info
               } // end ELSE does lead exist based on zipcode
           } // end ELSE does contact exist based on zipcode
    } // end ELSE does lead exist based on email?
} // end does contact exist based on email?

public void InsertCampaignMember(id memberID, string mtype) {
    getcamp();
    getpcampmmbr();
    // Instantiate CampMmbr to hold data
    campmmbr = new CampaignMember(
        campaignid = camp.id,
        status = 'Signed e-petition');
    // Does campmmbr already exist?
    if (mtype == 'Contact') {
        system.debug('Passed insertCampaignMember, mtype = contact');
        CampaignMember[] ccheck = [select id, contactid, campaignid from CampaignMember where 
                contactid = :memberid and campaignid = :camp.id];
        if (ccheck.size() > 0) {
                system.debug('Passed insertCampaignMember, ccheck.size() > 0');
            campmmbr = ccheck[0];
            system.debug('Just set campmmbr to ' + campmmbr.id);
            system.debug('campmmbr.contactid is now ' + campmmbr.contactid);
            campmmbr.status = 'Responded Yes';
            campmmbr.How_heard_about_event__c = pcampmmbr.How_heard_about_event__c;
            update campmmbr;
            return;
            } // END IF campmmbr exists based on contact id
                else {
                        system.debug('Passed insertCampaignMember, else insert campmmbr');
                campmmbr.contactid = memberID;
                campmmbr.status = 'Responded Yes';
                campmmbr.How_heard_about_event__c = pcampmmbr.How_heard_about_event__c;
                campmmbr.campaign_member_source__c = 'Web signup';  
                if (campmmbr.Nr_in_Group__c == null) campmmbr.Nr_in_group__c = 1;
                if (camp.waiver_required__c) 
                    campmmbr.Agreed_to_Waiver__c = Agreed_To_Waiver;
                insert campmmbr;        
                return;}
                        }
        else {
            //assume mtype == lead
                system.debug('Passed else insertCampaignMember, mtype = lead');
            CampaignMember[] lcheck = [select id, leadid from CampaignMember where leadid = :memberid
                        and campaignid = :camp.id];
            if (lcheck.size() > 0){
                        system.debug('Passed insertCampaignMember, lcheck.size() > 0');
                    campmmbr = lcheck[0];
                    system.debug('Just set campmmbr to ' + campmmbr.id);
                    system.debug('campmmbr.leadid is now ' + campmmbr.leadid);
                campmmbr.status = 'Responded Yes';
                campmmbr.How_heard_about_event__c = pcampmmbr.How_heard_about_event__c;
                if (campmmbr.Nr_in_Group__c == null) campmmbr.Nr_in_group__c = 1;
                if (camp.waiver_required__c) 
                    campmmbr.Agreed_to_Waiver__c = Agreed_To_Waiver;
                update campmmbr;
                return;
                } // END IF campmmbr exists based on lead id
                    // IF NO EXISTING CAMPMMBR
                    else {
                    system.debug('Passed else INSERT NEW CAMPMMBR, right now memberid is ' + memberID);
                    campmmbr.leadid = memberID;
                    campmmbr.status = 'Responded Yes';
                    campmmbr.How_heard_about_event__c = pcampmmbr.How_heard_about_event__c;
                        campmmbr.campaign_member_source__c = 'Web signup';
                    if (campmmbr.Nr_in_Group__c == null) campmmbr.Nr_in_group__c = 1;
                    if (camp.waiver_required__c) 
                        campmmbr.Agreed_to_Waiver__c = Agreed_To_Waiver;
                    system.debug('Campmmbr values now are ' + campmmbr);
                    system.debug('campaign is ' + [select id from Campaign where id = :camp.id]);
                    system.debug('Lead is ' + [select id from Lead where id = :memberID]);
                    insert campmmbr;
                    system.debug('Just inserted campmmbr ' + campmmbr.id);
                    system.debug('campmmbr.leadid is now ' + campmmbr.leadid);
                    system.debug('campmmbr.status is now ' + campmmbr.status);
                    // system.debug('newlead is now ' + newlead.id);                 
                    }       
                    } // END else assume mtype == lead
                } // END method

public PageReference SignUpNewsLetter() {
        system.debug('starting SignUpNewsletter(), campmmbr.contactid is ' + campmmbr.contactid);
        if (campmmbr.contactid != null) 
        {
        system.debug('SignUpNewsletter() determined campmmbr.contactid !=null, campmmbr.contactid is ' + campmmbr.contactid);
        tempContact = [select id, mailing_lists__c from Contact where id = :campmmbr.contactid ];
        system.debug('Found that tempContact.mailing_lists__c is' + tempContact.Mailing_Lists__c);
        if (tempContact.Mailing_Lists__c == null) {
                tempContact.Mailing_Lists__c = mailing_list;
                system.debug('Passed ïf mailing_lists__c == null, set it to single value'); 
                }
        else {
            if (tempContact.Mailing_Lists__c.contains(mailing_list)) {
                        system.debug('Passed: if mailing_lists__c == mailing_list, returned null');
                return null;
                }
                else {tempContact.Mailing_Lists__c = tempContact.Mailing_Lists__c+ ', ' + mailing_list;
                system.debug('Just added mailing_list to Mailing_lists__c');                  
                }
            update tempContact;
            system.debug('Just updated tempContact'); 
            } // END ELSE                  
        } // end if contact
    else
    
    if (results[1] == 'Lead' ) {
        system.debug('starting SignUpNewsletter(), campmmbr.leadid is ' + campmmbr.leadid);
        Lead tempLead = [select id, mailing_lists__c from Lead where id = :results[0]];
        system.debug('Set templead to ' + templead.id);
        if (templead.Mailing_Lists__c == null) {
            templead.Mailing_Lists__c = mailing_list;
            system.debug('Just set templead.Mailing_Lists_c to ' + mailing_list);
            }
        else {
            if (templead.Mailing_Lists__c.contains(mailing_list)) {
                return null;
                system.debug('Passed: if mailing_lists__c == mailing_list, returned null');
            } else {templead.Mailing_Lists__c += ', ' + mailing_list;}                
                system.debug('Just added default mailing list to Mailing_lists__c');                  
            }
            update tempLead;
            system.debug('Just updated tempLead'); 
        } // END if results[1] = Lead
            else {
                system.debug('In SignupNewsletter, didnt find contact or lead');
            }
    return null;
} // END SignUpNewsletter
   
public void SetOver18() {
    if (results[1] == 'Lead') {
        Lead tempLead = [select id, mailing_lists__c from Lead where id = :results[0]];
        tempLead.Over_18__c = true;
        update templead;        
    } // end if Lead
    else {
        tempContact = [select id, mailing_lists__c from Contact where id = :campmmbr.contactid ];
        tempContact.Over_18__c = true;
        update tempcontact;
    }
    return; 
}   
           
}
       //END CONTROLLER

/* public class Public_Event_Controller {


public Public_Event_Controller(ApexPages.StandardController stdController) {
    createNewLead = false;
	if (ApexPages.currentPage().getURL().contains('mid=')) {
		string masterCampId = ApexPages.currentPage().getParameters().get('mid');
		// MasterCampaign masterCamp = [select id from Master_Campaign__c where Id = :masterCampId limit 1].id;
		}
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
Id leadrt = [select Id from Recordtype where name = 'Online Signup' AND SobjectType ='Lead'].Id;
Public boolean createnewlead {get; set;}
Public boolean readytosubmit {get; set;}
Public boolean Agreed_To_Waiver {get; set;}
Public boolean Must_Sign_Waiver {get; set;}
Public boolean enewsletters {get; set;}
Boolean CampmmbrExists = false;
Public string companyString {get; set;}
private List<Campaign> mCampaign;
Public boolean isEventFull {get; set;} 
Public boolean EventFull {get; set;}
string mailing_list = WG_settings__c.getvalues('newsletter').online_signup_newsletter__c;
public id masterCampID;

public List<Campaign> getCampaign() {
    if (null==mCampaign)
		if (masterCampID == null) // select all public events or volunteer events
		    {
		        mCampaign= [select campaign.name, id, Description, Event_Date_Time__c, 
		    recordtypeid, Event_Cost__c,  Slots_Remaining__c, Waiver_Required__c, type from Campaign where 
		    (Event_Date_Time__c >= Today and (recordtype.name = 'Public Event' 
		    or recordtype.name = 'Volunteer Event')) ORDER BY type ASC];
		    }
		else //select only campaigns in the Master Campaign
			{mCampaign= [select campaign.name, id, Description, Event_Date_Time__c, 
		    recordtypeid, Event_Cost__c,  Slots_Remaining__c, Waiver_Required__c, type from Campaign where 
		    (Event_Date_Time__c >= Today and Master_Campaign__c = :masterCampID and (recordtype.name = 'Public Event' 
		    or recordtype.name = 'Volunteer Event')) ORDER BY type ASC];
			}
	   
    return mCampaign;
}


    
//PASS IN DATA ABOUT THIS PARTICULAR CAMPAIGN
public Campaign getCamp() {
            system.debug('cid is ' + ApexPages.currentPage().getParameters().get('cid'));
        Camp = [SELECT Id ,Name, Description, Description_Long__c, Event_Cost__c, 
            Event_Location__c, Event_Date_time__c, Waiver_Required__c, Type,
            Slots_Remaining__c FROM Campaign 
            WHERE id = :ApexPages.currentPage().getParameters().get('cid') limit 1];
        if (camp.slots_remaining__c < 1) isEventFull = true;
        system.debug('Camp.ID is now ' + Camp.ID);    
return camp;
}       
 
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
  
//RETURN TO LIST FUNCTION
public PageReference ReturnToList(){
PageReference ReturnToList = Page.Public_Event_Select_Page;
ReturnToList.setRedirect(true);
return ReturnToList;}

//Submit FUNCTION
public PageReference submit(){
//MAKE SURE THEY'VE AGREED TO THE WAIVER
        system.debug('Agreed_to_Waiver '+ Agreed_to_Waiver);
        system.debug('Waiver Required '+ camp.Waiver_Required__c);
    if (Agreed_to_Waiver == false && camp.Waiver_Required__c == true) {
        Must_Sign_Waiver = true;
        return null;}
    //IF NOT ALREADY DONE, CHECK EMAIL, ZIP CODE AGAINST EXISTING LEADS AND CONTACT        
    system.debug('if results null identifysigner.  results is ' + results);
    if (results == null ) identifySigner();
    if (createNewLead == true) {
                return null;
        } 
    system.debug('readyToSubmit is ' + readyToSubmit);
    if (readyToSubmit) {
    insertCampaignMember(results[0], results[1]);
    if (pcontact.over_18__c == true) {
        system.debug('Just passed pcontact.over_18__c is true, call SetOver18');
        SetOver18();
        } // END SETOVER18
    if (enewsletters == true) SignUpNewsletter();
    //REDIRECT TO THANKYOU PAGE
    PageReference Thanks_Page = Page.Public_Event_Thanks_Page;
    Thanks_Page.setRedirect(false);
    return Thanks_Page;
    } // END IF READYTOSUBMIT
    else return null;
    }  //END SAVE


//Identify Contact or Lead
public String [] IdentifySigner() { 
//declare a list to store results
results = new String[2];
//If contact exists
    Contact[] pccheck = [Select ID, AccountID from Contact where email = :pcontact.email];
    if (pccheck.size() > 0) {
    results[0] = pccheck[0].id;
    results[1] = 'Contact';
    readyToSubmit = true;
    return results;
    }
    ELSE {
        //If lead exists
        Lead[] lcheck = [Select Id from Lead where email = :pcontact.email];
        system.debug('pcontact.email is ' + pcontact.email);
        if (lcheck.size() > 0) {
        results[0] = lcheck[0].Id;
        results[1] = 'Lead';
        readyToSubmit = true;
        return results;
        }
        ELSE 
        {
            //does contact exist based on name and zip code?
            pccheck = [Select ID, AccountID from Contact 
                where (firstname = :pcontact.firstname AND lastname = :pcontact.lastname
                AND  MailingPostalCode = :pcontact.MailingPostalCode)];
            if (pccheck.size() > 0) {
            results[0] = pccheck[0].ID;
            results[1] = 'Contact';
                readyToSubmit = true;
            system.debug('Passed: Identified contact by name and zip code');
            return results;
            }
            ELSE {
                //does LEAD exist based on name and zip code?
                lcheck = [Select ID, firstname, lastname, PostalCode from Lead 
                    where (firstname = :pcontact.firstname AND lastname = :pcontact.lastname
                    AND PostalCode = :pcontact.MailingPostalCode)];
                if (lcheck.size() > 0) {
                results[0] = lcheck[0].Id;
                results[1] = 'Lead';
                        readyToSubmit = true;
                system.debug('Passed: Identified lead by name and zip code');
                
                return results;
                } //end does Lead exist based on name and zip code?
                ELSE {
                    //if enternewlead == null go back for more contact info
                    if (createnewlead == false) {
                        createnewlead = true;
                        results = null;
                        //results[0] = ; //This is just garbage filler so that we can return results.
                        //results[1] = 'Lead';
                        return results;
                    }
                    else //create new lead
                    {       
                        if (pcontact.description == null) {
                            system.debug('passed pontact.description == null');                      
                            companyString = 'none';
                            system.debug('just set companyString to none; did it take?  companyString is ' + companyString);
                            }  
                            else {
                            companyString = pcontact.description;
                            system.debug('just passed else, set companyString to ' + pcontact.description);
                            }
                        system.debug('companyString is ' + companyString);   
                        lead newlead = new Lead (lastname = pcontact.lastname, 
                        firstname=pcontact.firstname,
                        email=pcontact.email, 
                        company=companyString, 
                        street=pcontact.MailingStreet,
                        city=pcontact.MailingCity,
                        state=pcontact.MailingState,
                        postalCode=pcontact.MailingPostalCode,
                        phone=pcontact.Phone,
                        volunteer_interests__c=pcontact.Volunteer_Interests__c,
                        leadsource='Online Event Signup',
                        RecordTypeID = [select ID from RecordType where name = 'Online Signup' and 
                        SObjectType = 'Lead'].id); 
                        insert newlead;
                        createNewLead = false;
                        results[0] = newlead.id;
                        results[1] = 'Lead';
                        system.debug('newlead is ' + newlead);
                        system.debug('newlead firstname is ' + newlead.firstname);  
                        readyToSubmit = true;            
                        return results;
                        } // end else create new lead
                    } //end if enternewlead==null go back for more info
               } // end ELSE does lead exist based on zipcode
           } // end ELSE does contact exist based on zipcode
    } // end ELSE does lead exist based on email?
} // end does contact exist based on email?

public void InsertCampaignMember(id memberID, string mtype) {
    getcamp();
    getpcampmmbr();
    // Instantiate CampMmbr to hold data
    campmmbr = new CampaignMember(
        campaignid = camp.id,
        status = 'Signed e-petition');
    // Does campmmbr already exist?
    if (mtype == 'Contact') {
        system.debug('Passed insertCampaignMember, mtype = contact');
        CampaignMember[] ccheck = [select id, contactid, campaignid from CampaignMember where 
                contactid = :memberid and campaignid = :camp.id];
        if (ccheck.size() > 0) {
                system.debug('Passed insertCampaignMember, ccheck.size() > 0');
            campmmbr = ccheck[0];
            system.debug('Just set campmmbr to ' + campmmbr.id);
            system.debug('campmmbr.contactid is now ' + campmmbr.contactid);
            campmmbr.status = 'Responded Yes';
            campmmbr.How_heard_about_event__c = pcampmmbr.How_heard_about_event__c;
            update campmmbr;
            return;
            } // END IF campmmbr exists based on contact id
                else {
                        system.debug('Passed insertCampaignMember, else insert campmmbr');
                campmmbr.contactid = memberID;
                campmmbr.status = 'Responded Yes';
                campmmbr.How_heard_about_event__c = pcampmmbr.How_heard_about_event__c;
                campmmbr.campaign_member_source__c = 'Web signup';          
                if (camp.waiver_required__c) 
                    campmmbr.Agreed_to_Waiver__c = Agreed_To_Waiver;
                insert campmmbr;        
                return;}
                        }
        else {
            //assume mtype == lead
                system.debug('Passed else insertCampaignMember, mtype = lead');
            CampaignMember[] lcheck = [select id, leadid from CampaignMember where leadid = :memberid
                        and campaignid = :camp.id];
            if (lcheck.size() > 0){
                        system.debug('Passed insertCampaignMember, lcheck.size() > 0');
                    campmmbr = lcheck[0];
                    system.debug('Just set campmmbr to ' + campmmbr.id);
                    system.debug('campmmbr.leadid is now ' + campmmbr.leadid);
                campmmbr.status = 'Responded Yes';
                campmmbr.How_heard_about_event__c = pcampmmbr.How_heard_about_event__c;
                if (camp.waiver_required__c) 
                    campmmbr.Agreed_to_Waiver__c = Agreed_To_Waiver;
                update campmmbr;
                return;
                } // END IF campmmbr exists based on lead id
                    // IF NO EXISTING CAMPMMBR
                    else {
                    system.debug('Passed else INSERT NEW CAMPMMBR, right now memberid is ' + memberID);
                    campmmbr.leadid = memberID;
                    campmmbr.status = 'Responded Yes';
                    campmmbr.How_heard_about_event__c = pcampmmbr.How_heard_about_event__c;
                        campmmbr.campaign_member_source__c = 'Web signup';
                    if (camp.waiver_required__c) 
                        campmmbr.Agreed_to_Waiver__c = Agreed_To_Waiver;
                    system.debug('Campmmbr values now are ' + campmmbr);
                    system.debug('campaign is ' + [select id from Campaign where id = :camp.id]);
                    system.debug('Lead is ' + [select id from Lead where id = :memberID]);
                    insert campmmbr;
                    system.debug('Just inserted campmmbr ' + campmmbr.id);
                    system.debug('campmmbr.leadid is now ' + campmmbr.leadid);
                    system.debug('campmmbr.status is now ' + campmmbr.status);
                    // system.debug('newlead is now ' + newlead.id);                 
                    }       
                    } // END else assume mtype == lead
                } // END method

public PageReference SignUpNewsLetter() {
        system.debug('starting SignUpNewsletter(), campmmbr.contactid is ' + campmmbr.contactid);
        if (campmmbr.contactid != null) 
        {
        system.debug('SignUpNewsletter() determined campmmbr.contactid !=null, campmmbr.contactid is ' + campmmbr.contactid);
        tempContact = [select id, mailing_lists__c from Contact where id = :campmmbr.contactid ];
        system.debug('Found that tempContact.mailing_lists__c is' + tempContact.Mailing_Lists__c);
        if (tempContact.Mailing_Lists__c == null) {
                tempContact.Mailing_Lists__c = mailing_list;
                system.debug('Passed ïf mailing_lists__c == null, set it to single value'); 
                }
        else {
            if (tempContact.Mailing_Lists__c.contains(mailing_list)) {
                        system.debug('Passed: if mailing_lists__c == mailing_list, returned null');
                return null;
                }
                else {tempContact.Mailing_Lists__c = tempContact.Mailing_Lists__c+ ', ' + mailing_list;
                system.debug('Just added mailing_list to Mailing_lists__c');                  
                }
            update tempContact;
            system.debug('Just updated tempContact'); 
            } // END ELSE                  
        } // end if contact
    else
    
    if (results[1] == 'Lead' ) {
        system.debug('starting SignUpNewsletter(), campmmbr.leadid is ' + campmmbr.leadid);
        Lead tempLead = [select id, mailing_lists__c from Lead where id = :results[0]];
        system.debug('Set templead to ' + templead.id);
        if (templead.Mailing_Lists__c == null) {
            templead.Mailing_Lists__c = mailing_list;
            system.debug('Just set templead.Mailing_Lists_c to default mailing list');
            }
        else {
            if (templead.Mailing_Lists__c.contains(mailing_list)) {
                return null;
                system.debug('Passed: if mailing_lists__c == mailing_list, returned null');
            } else {templead.Mailing_Lists__c += ', ' + mailing_list;}                
                system.debug('Just added default mailing list to Mailing_lists__c');                  
            }
            update tempLead;
            system.debug('Just updated tempLead'); 
        } // END if results[1] = Lead
            else {
                system.debug('In SignupNewsletter, didnt find contact or lead');
            }
    return null;
} // END SignUpNewsletter
   
public void SetOver18() {
    if (results[1] == 'Lead') {
        Lead tempLead = [select id, mailing_lists__c from Lead where id = :results[0]];
        tempLead.Over_18__c = true;
        update templead;        
    } // end if Lead
    else {
        tempContact = [select id, mailing_lists__c from Contact where id = :campmmbr.contactid ];
        tempContact.Over_18__c = true;
        update tempcontact;
    }
    return; 
}   
           
}
*/
       //END CONTROLLER