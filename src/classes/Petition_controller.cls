// This controller requires a ?cid=campaignid in the URL.
// It handles people signing up for the 'Updates on Organization', which I should move into its own controller in the future.

public with sharing class Petition_controller {

        
Public boolean Yes {get; set;}
Public boolean SignMeUp {get; set;}
// Public boolean Volunteer {get; set;}
Public boolean Membership {get; set;}
Public boolean IssueUpdate {get; set;}
Public boolean OrgUpdates {get; set;}
Public contact signer;
public lead newLead;
public lead tempLead;
public contact tempContact;
public List<String> results {get; set;}
public campaignMember campmmbr {get; set;}
public boolean campmmbralready {get; set;}
public campaign camp {get; set;}
public id campaignid;
public Boolean WrongCampaignID {get; Set;}

public Petition_controller(){
    System.debug('Right now cid is ' + apexPages.currentPage().getParameters().get('cid'));
    LIST<campaign> campaigns = [select id, name from Campaign where id = :apexPages.currentPage().getParameters().get('cid')];
    if (campaigns.size() == 0) {
        WrongCampaignID = true; //
    }
    else camp = campaigns[0];  
} // end of constructor

public Contact getSigner(){
if (signer == null) {
    signer = new Contact();}
    return signer;}

//ClosePage
public PageReference ClosePage() {
    PageReference ClosePage = page.ClosePage;
    return ClosePage;
}

//GoBack
public PageReference goBack() {   
    PageReference goBack = new PageReference('http://www.wvrivers.org/');
    return goBack;
    }
    
//Submit
public PageReference submit() {
    IdentifySigner();
    // identify whether they're already signed up
    InsertCampaignMember(results[0], results[1]);
    system.debug('Here in submit(), campmmbr.contactid is ' + campmmbr.contactid);
    PageReference submit = page.Petition_Page2;
    return submit;
    }


//Identify Contact or Lead
public String [] IdentifySigner() { 
        //declare a list to store results
        results = new String[2];
        results = identifyorCreatePerson.identifyorCreatePerson(signer);
        return results;
}
        
public void InsertCampaignMember(id memberID, string mtype) {
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
            campmmbr.status = 'Signed e-petition';
            update campmmbr;
            return;
            } // END IF campmmbr exists based on contact id
                else {
                        system.debug('Passed insertCampaignMember, else insert campmmbr');
                campmmbr.contactid = memberID;
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
                campmmbr.status = 'Signed e-petition';
                update campmmbr;
                return;
                } // END IF campmmbr exists based on lead id
                    // IF NO EXISTING CAMPMMBR
                    else {
                    campmmbr.leadid = memberID;
                    insert campmmbr;
                    }       
                    } // END else assume mtype == lead
                } // END method

    public PageReference OrgUpdates() {
        if (campmmbr.contactid != null) 
            {
             tempContact = [select id, mailing_lists__c from Contact where id = :campmmbr.contactid ];
            if (tempContact.Mailing_Lists__c == null) tempContact.Mailing_Lists__c = ' Updates on Organization';
            else {
                if (tempContact.Mailing_Lists__c.contains(' Updates on Organization')) return null;
                    else {tempContact.Mailing_Lists__c += '; Updates on Organization';}                
                }
                update tempContact;
               } // end if contact
        else
        if (results[1] == 'Lead' ) {
            tempLead = [select id, mailing_lists__c from Lead where id = :results[0]];
            if (templead.Mailing_Lists__c == null) templead.Mailing_Lists__c = 'Updates on Organization';
            else {
                if (templead.Mailing_Lists__c.contains('Updates on Organization')) return null;
                    else {templead.Mailing_Lists__c += '; Updates on Organization';}                
                }
                update tempLead;
                 } // END else
        return null;
    } // END OrgUpdates
} //end controller