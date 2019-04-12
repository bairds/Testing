public class Public_Event_Signin_Controller {


public Public_Event_Signin_Controller(ApexPages.StandardController stdController) {
    createNewLead = false;
	 interestselection = new List<String>{};
}

//DECLARE VARIABLES 
Public campaign camp;
Public Contact pcontact;
public List<String> results {get; set;}
public List<String> person {get; Set;}
Public Lead newlead {get; set;} // Do I still need this?
Public Contact newcontact {get; Set;}
Public Account newAccount {get; Set;}
Public Campaignmember pcampmmbr; // Preliminary campmmbr to hold value of How_heard_about__c
Public Campaignmember campmmbr;
campaignMember CMcheck = new campaignMember();
public List<campaignmember> CMchecks {get; Set;}
Public Opportunity Op;
Public contact TempContact;
Public lead tempLead;
Public boolean paidevent;
Id leadrt = [select Id from Recordtype where name = 'Online Signup' AND SobjectType ='Lead'].Id;
Public boolean createnewlead {get; set;}
Public boolean Agreed_To_Waiver {get; set;}
Public boolean Must_Sign_Waiver {get; set;}
Public boolean enewsletters {get; set;}
Boolean CampmmbrExists = false;
Public string companyString {get; set;}
//Public Boolean RSVPed {get; Set;}
//Public boolean RSVPedAndAttended {get; set;}
Public string returnURL {get; Set;}
public List<campaignmember> signins;
public integer signinsNumber {get; Set;}
public Boolean showSignins {get; Set;}
public List<campaignmember> notYetHere;
public integer notYetHereNumber {get; Set;}
public Boolean showNotYetHere {get; Set;}
public List<String> interestselection {get; Set;}
    
//PASS IN DATA ABOUT THIS PARTICULAR CAMPAIGN
public Campaign getCamp() {
            system.debug('id is ' + ApexPages.currentPage().getParameters().get('id'));
		// IF CAMP ALREADY EXISTS, USE THAT
		if (camp == null) {
        Camp = [SELECT Id ,Name, Description, Description_Long__c, Event_Cost__c, capacity__c,
            Event_Location__c, Event_Date_time__c, Waiver_Required__c, Slots_Remaining__c FROM Campaign 
            WHERE id = :ApexPages.currentPage().getParameters().get('id') limit 1];
        //if (camp.slots_remaining__c < 1) isEventFull = true;
        system.debug('Camp.ID is now ' + Camp.ID);
		returnURL = '/apex/public_event_signin_page?id=' + (ApexPages.currentPage().getParameters().get('id'));
		} // end if (camp== null)
return camp;
}       
 
//CONTACT VARIABLE TO HOLD CONTACT FIELDS
public Contact getpContact(){
if (pcontact == null) {
pcontact = new Contact();
}
return pcontact;   
}

//CAMPMMBR VARIABLE TO HOLD campaignmember FIELDS
public CampaignMember getpcampmmbr(){
if (pcampmmbr == null) {
pcampmmbr = new CampaignMember();
}
return pcampmmbr;   
}

//Calculate totals when Admin Page called
public void calculateTotals() {
	signins = [select id,status,lead.firstname,contact.firstname,lead.lastname,contact.lastname,lead.company,
		contact.account.name,lead.phone,contact.phone,Agreed_To_Waiver__c 
		from campaignmember where campaignid = :camp.id and (status = 'Attended' or status = 'RSVPed and Attended')
		order by lead.lastname];
		signinsNumber = signins.size();
	notYetHere = [select id,status,lead.firstname,contact.firstname,lead.lastname,contact.lastname,lead.company,
		contact.account.name,lead.phone,contact.phone,Agreed_To_Waiver__c 
		from campaignmember where (campaignid = :camp.id and status = 'Responded Yes') order by lead.lastname];
		notYetHereNumber = notYetHere.size();
	}

public List<campaignmember> getSignIns() {
	return signins;
}

public List<campaignmember> getNotYetHere() {
	return notYetHere;
	}

public PageReference returnToSignin() {
	PageReference returnPage = new PageReference(returnURL);
	returnPage.setRedirect(true);
	return returnPage;
	}


//SignMeIn Function
public PageReference signMeIn() {
	// Are they in the database?
    if (results == null ) results = identifyPerson.IdentifyPerson(pcontact);
    if (results == null || results[2] == 'match on email not name') {
				Agreed_To_Waiver = false;
                pageReference page2 = Page.public_event_signin_page2;
		// apexpages.set parameter for page2 at id = currentpage.getid()
				page2.setredirect(false);
				return page2;
                }
    else {
		// They're in the database, are they already signed up?
		// If they're a contact and have already signed up ...
        if (results[1]=='Contact') {
			CMchecks = [select status, id, contact.lastname, contact.firstname, contact.email from campaignMember where contactid = :results[0]];
			IF (CMchecks.size() > 0) {
				CMcheck = CMchecks[0];
			 	if(CMcheck.Status == 'Responded Yes') {
					CMcheck.status = 'RSVPed and Attended';
				 	} else {
					CMcheck.Status = 'Attended';}
				 Agreed_To_Waiver = CMcheck.Agreed_to_Waiver__c;
		         Update CMcheck;
				} // end if CMchecks.size() > 0
					else {
					Agreed_To_Waiver = false;
					}
			} // end if rsults[1] = Contact 
		else {
			// If they're a lead and have already signed up ...
				CMchecks = [select status, id, contact.lastname, contact.firstname, contact.email from campaignMember where leadid = :results[0]];
				IF (CMchecks.size() > 0) {
					CMcheck = CMchecks[0];
					if(CMcheck.Status == 'Responded Yes') {
						CMcheck.status = 'RSVPed and Attended';
					 	} else {
						CMcheck.Status = 'Attended';}
					 Agreed_To_Waiver = CMcheck.Agreed_to_Waiver__c;
			         Update CMcheck;
					} else { 
					// They're in the database but haven't yet signed up ...
					Agreed_To_Waiver = false;
					CMcheck = insertCampaignMember(results[0], results[1]);
						} // end of else They're in the database but haven't signed up ...
					//Convert any leads to contacts
					if (results[1] == 'Lead') {
						results = ConvertLeadToContact.ConvertLeadToContact(results[0]);
						results[1] = 'Contact';
						} 
					} // end of else If they're a lead ..
			} // end of else They're in the database

		// SEND THEM TO WAIVER IF REQUIRED; ELSE RETURN TO SIGNIN PAGE AND REFRESH
		if(camp.Waiver_Required__c == true && Agreed_to_Waiver == false) {
				PageReference Waiver_Page = Page.Public_Event_Signin_Waiver_Page;
			    Waiver_Page.setRedirect(false);
			    return Waiver_Page;
        		} else {
					PageReference returnPage = new PageReference(returnURL);
				    returnPage.setRedirect(true);
				    return returnPage;
						}
	} // end of Signin Function

//Submit1 FUNCTION
public PageReference submit1(){
	// DOES CONTACT EXIST?
	if (results == null || results[2] == 'match on Email not name') {
		// INSERT NEW CONTACT
		if (results == null) results = new List<String> {'new', 'new', 'new'};
		contact newContact = createContact(results);
		newContact.volunteer_interests__c = String.join(interestselection,';');
		update newContact;
		Account newAccount = [select id from account where id = :newContact.accountid];
		results[0] = newContact.id;
		results[1] = 'Contact';
		}
	    IF(camp.Waiver_Required__c != true || Agreed_To_Waiver) {
			CMcheck = insertCampaignMember(results[0], results[1]);
		    //REDIRECT TO THANKYOU PAGE
			PageReference returnPage = new PageReference(returnURL);
		    returnPage.setRedirect(true);
		    return returnPage;
	    } // END IF WAIVER_REQUIRED != TRUE
	else {        // ELSE send to waiver page
	PageReference Waiver_Page = Page.Public_Event_Signin_Waiver_Page;
    Waiver_Page.setRedirect(false);
	Waiver_Page.getParameters().put('id',camp.id); 
    return Waiver_Page;
		} // END ELSE 
    }  //END SUBMIT1

// Submit 2 function for the Waiver page
public PageReference submit2() {
	system.debug('Agreed_to_Waiver is '+ Agreed_to_Waiver);
    system.debug('Waiver Required '+ camp.Waiver_Required__c);
	if (Agreed_to_Waiver == false && camp.Waiver_Required__c == true) {
        Must_Sign_Waiver = true;
        return null;}
    CMcheck = insertCampaignMember(results[0],'Contact');
	CMcheck.Agreed_to_Waiver__c = true;
	System.debug('Line 193 CMcheck.status is ' + CMcheck.Status);
					if(CMcheck.Status == 'Responded Yes' || CMcheck.Status == 'RSVPed and Attended') {
						CMcheck.status = 'RSVPed and Attended';
					 	} else {
						CMcheck.Status = 'Attended';}
		update CMcheck;
    if (pcontact.over_18__c == true)  SetOver18();
         // END SETOVER18
    if (enewsletters == true) {
			pcontact.mailing_lists__c = signUpNewsletter.SignUpNewsLetter(results);
	} // end newsletter signup
	PageReference returnPage = new PageReference(returnURL);
    returnPage.setRedirect(true);
    return returnPage;
} // END SUBMIT2

//Link to Admin Page
public PageReference adminPage() {
	PageReference adminPage = Page.public_event_admin_page;
	AdminPage.setRedirect(false);
	return AdminPage;
}	

//Create contact; shared account if shared email
public Contact createContact(List<String> createContactInput) {
	if (results[0] == 'new') {
		if (pcontact.Description == null) newAccount = new Account(name = pcontact.LastName + ', ' + pcontact.FirstName + ' Household',
			recordTypeid = [select id from recordType where name = 'Family'].id);
			else {
				newAccount = new Account(name = pcontact.Description,
				recordTypeid = [select id from recordType where name = 'Business'].id);
				} // end else	
		if (pContact.MailingStreet <> null) newAccount.BillingStreet = pContact.MailingStreet;	
		if (pContact.MailingCity <> null) newAccount.BillingCity = pContact.MailingCity;	
		if (pContact.MailingState <> null) newAccount.BillingState = pContact.MailingState;	
		if (pContact.MailingPostalCode <> null) newAccount.BillingPostalCode = pContact.MailingPostalCode;
		if (pContact.FirstName <> null) newAccount.Dear__c = pContact.FirstName;
		if (pContact.FirstName <> null) newAccount.Addressee__c = pContact.FirstName + ' ' + pContact.Lastname;
		
		insert newAccount;
		} else {
			if (results[2] == 'match on email not name') {newAccount = [select id from account where id = :[select id, accountid from contact where id = :results[0]].accountid];}
				else {apexPages.Message mymsg = new ApexPages.Message (ApexPages.Severity.FATAL, 'Error: caught in createContact where results[2] != match on email not name');
					return null;}
				} // end 
		//assign this new contact to the email.contact.account
		newcontact = new Contact(accountid = newAccount.id,
		firstname=pcontact.firstname,
		lastname=pcontact.LastName,
	    email=pcontact.email, 
	    MailingStreet=pcontact.MailingStreet,
	    MailingCity=pcontact.MailingCity,
	    MailingState=pcontact.MailingState,
	    MailingPostalCode=pcontact.MailingPostalCode,
	    Phone=pcontact.Phone,
	    volunteer_interests__c=pcontact.Volunteer_Interests__c,
	    leadsource='Online Event Signup'); 
		Agreed_To_Waiver = false;
    	insert newcontact;
		return newcontact;
} // end createContact



public campaignMember InsertCampaignMember(id memberID, string mtype) {
    //getcamp();
    getpcampmmbr();
    // Instantiate CampMmbr to hold data
    campmmbr = new CampaignMember(
        campaignid = camp.id,
        status = 'Added to Campaign');
    // Does campmmbr already exist?
    if (mtype == 'Contact') {
        system.debug('Passed insertCampaignMember, mtype = contact');
        CampaignMember[] ccheck = [select id, contactid, campaignid, status from CampaignMember where 
                contactid = :memberid and campaignid = :camp.id];
        if (ccheck.size() > 0) {	
                system.debug('Passed insertCampaignMember, ccheck.size() > 0');
            campmmbr = ccheck[0];
            system.debug('Just set campmmbr to ' + campmmbr + ' with status ' + campmmbr.status);
            system.debug('campmmbr.contactid is now ' + campmmbr.contactid);
			if (campmmbr.Status == 'Responded Yes' || campmmbr.Status == 'RSVPed and Attended') {
				campmmbr.status = 'RSVPed and Attended';
				} else {
				campmmbr.Status = 'Attended';
				} // end set status
            campmmbr.How_heard_about_event__c = pcampmmbr.How_heard_about_event__c;
            update campmmbr;
            return campmmbr;
            } // END IF campmmbr exists based on contact id
                else {
                        system.debug('Passed insertCampaignMember, else insert campmmbr');
                campmmbr.contactid = memberID;
                campmmbr.status = 'Attended';
                campmmbr.How_heard_about_event__c = pcampmmbr.How_heard_about_event__c;
                campmmbr.campaign_member_source__c = 'Web signup';
            	campmmbr.status = 'Attended';          
                insert campmmbr;        
                return campmmbr;}
                        }
        else {
            //assume mtype == lead
                system.debug('Passed else insertCampaignMember, mtype = lead');
            CampaignMember[] lcheck = [select id, status, leadid from CampaignMember where leadid = :memberid
                        and campaignid = :camp.id];
            if (lcheck.size() > 0){
                        system.debug('Passed insertCampaignMember, lcheck.size() > 0');
                    campmmbr = lcheck[0];
                    system.debug('Just set campmmbr to ' + campmmbr.id);
                    system.debug('campmmbr.leadid is now ' + campmmbr.leadid);
			if (campmmbr.Status == 'Responded Yes' || campmmbr.Status == 'RSVPed and Attended') {
				campmmbr.status = 'RSVPed and Attended';
				} else {
				campmmbr.Status = 'Attended';
				} // end set status
                campmmbr.How_heard_about_event__c = pcampmmbr.How_heard_about_event__c;
                //if (camp.waiver_required__c) 
                //    campmmbr.Agreed_to_Waiver__c = Agreed_To_Waiver;
                update campmmbr;
                return campmmbr;
                } // END IF campmmbr exists based on lead id
                    // IF NO EXISTING CAMPMMBR
                    else {
                    system.debug('Passed else INSERT NEW CAMPMMBR, right now memberid is ' + memberID);
                    campmmbr.leadid = memberID;
                    campmmbr.status = 'Attended';
                    campmmbr.How_heard_about_event__c = pcampmmbr.How_heard_about_event__c;
                        campmmbr.campaign_member_source__c = 'Web signup';
						/*
                    if (camp.waiver_required__c) 
                        campmmbr.Agreed_to_Waiver__c = Agreed_To_Waiver;
						*/
                    system.debug('Campmmbr values now are ' + campmmbr);
                    system.debug('campaign is ' + [select id from Campaign where id = :camp.id]);
                    system.debug('Lead is ' + [select id from Lead where id = :memberID]);
                    insert campmmbr;
                    system.debug('Just inserted campmmbr ' + campmmbr.id);
                    system.debug('campmmbr.leadid is now ' + campmmbr.leadid);
                    system.debug('campmmbr.status is now ' + campmmbr.status);
					return campmmbr;
                    }       
                    } // END else assume mtype == lead
                } // END method
   
public void SetOver18() {
    if (results[1] == 'Lead') {
        Lead tempLead = [select id from Lead where id = :results[0]];
        tempLead.Over_18__c = true;
        update templead;        
    } // end if Lead
    else {
        tempContact = [select id from Contact where id = :campmmbr.contactid ];
        tempContact.Over_18__c = true;
        update tempcontact;
    }
    return; 
}

    public List<SelectOption> getInterests() {
       List<SelectOption> options = new List<SelectOption>();
       for( Schema.PicklistEntry f : Contact.Volunteer_Interests__c.getDescribe().getPicklistValues()) {
         options.add(new SelectOption(f.getValue(), f.getLabel()));
        } 
       return options;
	} // end getInterests
	
} //END CONTROLLER