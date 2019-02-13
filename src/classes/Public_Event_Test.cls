@isTest
private class Public_Event_Test {

    // THIS NEW VERSION DOESN'T GATHER 
    // ADDITIONAL INFORMATION FOR NEW LEADS.  THE VALUE OF SIGNUPNEWLEAD ISN'T
    // IMPORTANT, AND IN SOME PLACES I'VE JUST COMMENTED IT OUT OF THE SYSTEM.ASSERTEQUALS TESTS.
 
public static testMethod void Public_Event_Test() {
   PageReference pageRef = Page.Public_Event_Select_Page;
    Test.setCurrentPage(pageRef);
    Integer NrCampaignsDisplayed;
    //Set NrCampaignsDisplayed
    NrCampaignsDisplayed = [select count() from Campaign where (slots_remaining__c > 0 and Event_Date_Time__c > Today and 
        (recordtype.name = 'Public Event' or recordtype.name = 'Volunteer Event'))];
    
    //Set up the mailing lists so they're not hard-coded
        Schema.DescribeFieldResult F =Contact.Mailing_lists__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        if (P.size() < 2) {
            apexpages.message NeedMailingListValues = new 
                apexpages.message(apexpages.severity.fatal, 'Aborted test.  Must have at least 2 mailing list values in order to run tests.  Add them to Contact and Lead fields.');
        }
        string mailing_list1 = P[0].getvalue();
        string mailing_list2 = P[1].getvalue();
        system.debug('mailing_list1 is ' + mailing_list1);
        system.debug('mailing_list2 is ' + mailing_list2);
        
// Create a campaign with slots_remaining__c = 2
    Campaign Testcampaign = new Campaign();
    Testcampaign.name = 'Testcampaign';
    Testcampaign.capacity__c = 2;
    Testcampaign.event_date_time__c = datetime.newInstance(2050, 12, 1, 12, 30, 2);
    Testcampaign.description = 'description';
    Testcampaign.event_cost__c = 20.00;
    Testcampaign.Waiver_Required__c = true;
    Testcampaign.RecordtypeID = [select id from recordtype where name = 'Public Event'].id;
    insert Testcampaign;        

    ApexPages.StandardController sc = new ApexPages.StandardController(Testcampaign);
    Public_Event_Controller PEC = new Public_Event_Controller(sc);
    System.assertEquals(NrCampaignsDisplayed + 1, PEC.getCampaign().size());

        
// Create a second campaign which is part of a master campaign, test that the controller
// selects only it when ?mid= is inserted.	
	Master_Campaign__c mcamp = new Master_Campaign__c(
		name = 'Master Campaign');
		insert mcamp;
    Campaign Testcampaign2 = new Campaign();
    Testcampaign2.name = 'Testcampaign2';
    Testcampaign2.capacity__c = 2;
    Testcampaign2.event_date_time__c = datetime.newInstance(2050, 12, 1, 12, 30, 2);
    Testcampaign2.description = 'description';
    Testcampaign2.RecordtypeID = [select id from recordtype where name = 'Public Event'].id;
	Testcampaign2.master_campaign__c = mcamp.id;
    insert Testcampaign2;

	pageRef = Page.Public_Event_Select_Page; 
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('mid', mcamp.ID);	
	System.assertEquals(1,PEC.getCampaign().size());
//Since we just added a campaign, increase NrCampaignsDisplayed
		NrCampaignsDisplayed = NrCampaignsDisplayed+1;
		
//  Sign up a contact and a lead to the campaign
        Account Testaccount = new Account (name='TestAccount');
        insert Testaccount;
        Contact TestContact = new Contact (firstname='Test', lastname='TestContact', email='testcontact@dontbotherme.org', accountID = TestAccount.ID);
        insert Testcontact;
        Campaignmember Testcampmmbr = new Campaignmember (ContactID = TestContact.ID, CampaignID = Testcampaign.ID, Nr_in_Group__c = 1);
        Insert Testcampmmbr;
        Lead TestLead = new Lead (lastname = 'Lead', firstname = 'Test', company = 'None', email = 'testlead@dontbotherme.org');
        insert TestLead;    
        Campaignmember Testcampmmbr2 = new Campaignmember (LeadID = TestLead.ID, CampaignID = Testcampaign.ID, Nr_in_Group__c = 1);
        Insert Testcampmmbr2;
      
//  Verify that the controller returns one fewer campaigns now
        Public_Event_Controller PEC6 = new Public_Event_Controller(sc);
        system.Debug('Is Testcampaign still in the list?' + [select name from 
        Campaign where(slots_remaining__c > 0 and Event_Date_Time__c > Today 
        and (recordtype.name = 'Public Event' or recordtype.name = 'Volunteer Event'))]);
        System.assertEquals(NrCampaignsDisplayed, [select count() from Campaign where (slots_remaining__c > 0 and Event_Date_Time__c > Today and (recordtype.name = 'Public Event' or recordtype.name = 'Volunteer Event'))]);
    }

static testMethod void Public_Signup_Test() {
    //Test coverage for the SignUpOpenEvent page
 Account Testaccount = new Account (name='TestAccount');
insert testaccount;
Contact TestContact = new Contact (lastname='TestContact', email='testcontact@dontbotherme.org', 
    mailingPostalCode = '11111', accountID = TestAccount.ID);
insert testcontact;
Lead TestLead = new Lead (lastname = 'Lead', firstname = 'Test', company = 'None', 
    postalCode = '11111', email = 'testlead@dontbotherme.org');
insert TestLead;
Campaign Testcamp = new Campaign (name='TestCampaign', Waiver_Required__c = true, Isactive=TRUE, recordtype = [select id from recordtype where name ='Public Event']);
insert testcamp;
CampaignMember pcampmmbr = new CampaignMember();

    
// Case 1: Contact exists by email
PageReference pageRef = Page.Public_Event_Signup_Page; 
Test.setCurrentPageReference(PageRef);
ApexPages.currentPage().getParameters().put('cid', Testcamp.Id);
ApexPages.StandardController sc = new ApexPages.StandardController(Testcamp);
Public_Event_Controller PEC = new Public_Event_Controller(sc);
System.assertEquals(false, PEC.createNewLead);
PEC.passcampID = Testcamp.id;

PEC.getCamp();
System.assertEquals(false,PEC.createNewLead);
System.assertEquals('TestCampaign', PEC.camp.name);
PEC.getpcontact();
PEC.getpcampmmbr();
PEC.pcontact.firstname ='Test';
PEC.pcontact.lastname = 'TestContact';
PEC.pcontact.email = 'testcontact@dontbotherme.org';
PEC.pcampmmbr.how_heard_about_event__c = 'From the website';

//TEST TO SEE IF SIGNUP ABORTS BECAUSE HASN'T AGREED TO WAIVER
PEC.Agreed_To_Waiver = false;
PEC.submit();
System.assertEquals(0,[select count() from campaignmember where campaignID=:Testcamp.ID /*and contactid=:testContact.ID*/]); 
System.assertEquals(false,PEC.createNewLead);
System.assertEquals(true, PEC.Must_Sign_Waiver);

//TEST TO SEE IF SIGNUP CONTINUES ONCE AGREES TO WAIVER
PEC.Agreed_To_Waiver = true;
PEC.submit();
System.assertEquals(1,[select count() from campaignmember where campaignID=:Testcamp.ID /*and contactid=:testContact.ID*/]); 
    // No longer valid because slots_reserved__c is now calculated differently
// System.assertEquals(1,[select slots_reserved__c from Campaign where ID=:Testcamp.ID][0].slots_reserved__c); 
system.assertEquals('From the website',[select id,how_heard_about_event__c from campaignmember
    where campaignID=:Testcamp.ID][0].how_heard_about_event__c);
System.assertEquals(false,PEC.createNewLead);
System.assertEquals(true, PEC.Must_Sign_Waiver);

//Test newsletter signup for contact when Mailing_lists__c = null
PEC.enewsletters = true;
PEC.SignUpNewsletter();
system.assertEquals(true,PEC.tempContact.mailing_Lists__c.contains(PEC.mailing_list));
//Check SignUpNewsletter again; it shouldn't add to the multipicklist field
//because we're already signed up.
PEC.enewsletters = true;
PEC.SignUpNewsletter();
system.assertEquals(PEC.mailing_list,PEC.tempContact.mailing_Lists__c);

    
//Test over18 for contact
PEC.pcontact.Over_18__c = true;
PEC.SetOver18();
system.assertEquals(true,[select id, Over_18__c from Contact
    where email = 'testcontact@dontbotherme.org'][0].Over_18__c);   

//TEST RETURN TO LIST
       PEC.ReturnToList();
       String NextPage = PEC.ReturnToList().getUrl();
       System.assertEquals('/apex/public_event_select_page', NextPage); 
       
          
System.debug('Current User: ' + UserInfo.getUserName());
System.debug('Current Profile: ' + UserInfo.getProfileId());  

// Case 2: Lead exists by email
Public_Event_Controller PEC2 = new Public_Event_Controller(sc);
System.assertEquals(false, PEC2.createNewLead);
PEC2.getcamp(); 
System.assertEquals(false,PEC2.createNewLead);
PEC2.getCamp();
System.assertEquals('TestCampaign', PEC2.camp.name);
PEC2.getpcontact();
PEC2.getpcampmmbr();
PEC2.pcontact.firstname = 'Test';
PEC2.pcontact.lastname = 'Lead';
PEC2.pcontact.email = 'testlead@dontbotherme.org';
PEC2.pcampmmbr.how_heard_about_event__c = 'Other';

//TEST TO SEE IF SIGNUP ABORTS BECAUSE HASN'T AGREED TO WAIVER
PEC2.Agreed_To_Waiver = false;
PEC2.submit();
System.assertEquals(1,[select count() from campaignmember where campaignID=:Testcamp.ID /*and contactid=:testContact.ID*/]); 
System.assertEquals(false,PEC2.createNewLead);
System.assertEquals(true, PEC2.Must_Sign_Waiver);


//TEST TO SEE IF SIGNUP CONTINUES ONCE AGREES TO WAIVER
PEC2.Agreed_To_Waiver = true;
PEC2.submit();
System.assertEquals(2,[select count() from campaignmember where campaignID=:Testcamp.ID]); 
    // No longer valid because slots_reserved__c is now calculated differently
    // System.assertEquals(2,[select slots_reserved__c from Campaign where ID=:Testcamp.ID][0].slots_reserved__c); 
System.assertEquals(false,PEC2.createNewLead); 
system.assertEquals('Other',[select id,how_heard_about_event__c from campaignmember
    where campaignID=:Testcamp.ID][1].how_heard_about_event__c);

//Test newsletter signup for lead when Mailing_lists__c = null
PEC2.enewsletters = true;
PEC2.SignUpNewsletter();
system.assertEquals(PEC.mailing_list,[select id, mailing_lists__c from Lead where email =
    'testlead@dontbotherme.org'][0].mailing_lists__c);
//Check SignUpNewsletter again; it shouldn't add to the multipicklist field
//because we're already signed up.
PEC2.enewsletters = true;
PEC2.SignUpNewsletter();
system.assertEquals(PEC.mailing_list,[select id, mailing_lists__c from Lead where email =
    'testlead@dontbotherme.org'][0].mailing_lists__c);

/*
PEC2.submit();
System.assertEquals(2,[select count() from campaignmember where campaignID=:Testcamp.ID]); 
System.assertEquals(false,PEC2.createNewLead); 
*/

// Case 6: Contact exists by zip code
Testcontact.mailing_lists__c = 'RCC volunteer updates';
update testcontact;

pageRef = Page.Public_Event_Select_Page;
Test.setCurrentPageReference(PageRef);
ApexPages.currentPage().getParameters().put('cid', Testcamp.Id);
Public_Event_Controller PEC6 = new Public_Event_Controller(sc);
System.assertEquals(false, PEC6.createNewLead);
PEC6.getcamp(); 
System.assertEquals(false,PEC6.createNewLead);
System.assertEquals('TestCampaign', PEC6.camp.name);
PEC6.getpcontact();
PEC.pcontact.firstname ='Test';
PEC6.pcontact.lastname = 'TestContact';
PEC6.pcontact.email = 'nottestcontact@dontbotherme.org';
PEC6.pcontact.MailingPostalCode = '11111';
PEC6.Agreed_To_Waiver = true;
PEC6.submit();
System.assertEquals(2,[select count() from campaignmember where campaignID=:Testcamp.ID /*and contactid=:testContact.ID*/]); 
System.assertEquals(false,PEC6.createNewLead);

//Test newsletter signup for contact when Mailing_lists__c = 'RCC volunteer updates'
PEC.enewsletters = true;
PEC.SignUpNewsletter();
system.assertEquals('RCC volunteer updates, '+ PEC.mailing_list,PEC.tempContact.mailing_Lists__c);

// Case 7: Lead exists by zipcode   
Testlead.mailing_lists__c = 'RCC volunteer updates';
update testlead;

Public_Event_Controller PEC7 = new Public_Event_Controller(sc);
System.assertEquals(false,PEC7.createNewLead);
PEC7.getCamp();
System.assertEquals('TestCampaign', PEC7.camp.name);
PEC7.getpcontact();
PEC7.pcontact.firstname = 'Test';
PEC7.pcontact.lastname = 'Lead';
PEC7.pcontact.email = 'nottestlead@dontbotherme.org';
PEC7.pcontact.MailingPostalCode = '11111';
PEC7.Agreed_To_Waiver = true;
PEC7.submit();
System.assertEquals(2,[select count() from campaignmember where campaignID=:Testcamp.ID]); 

//Test newsletter signup for contact when Mailing_lists__c = 'RCC volunteer updates'
PEC7.enewsletters = true;
PEC7.SignUpNewsletter();
system.assertEquals('RCC volunteer updates, '+PEC.mailing_list,[select id, mailing_lists__c from Lead where email =
    'testlead@dontbotherme.org'][0].mailing_lists__c);

// Case 3: Contact already signed up for campaign
Public_Event_Controller PEC3 = new Public_Event_Controller(sc);
System.assertEquals(false, PEC3.createNewLead);
PEC3.getcamp(); 
System.assertEquals(false,PEC3.createNewLead);
PEC3.getCamp();
System.assertEquals('TestCampaign', PEC3.camp.name);
PEC3.getpcontact();
PEC3.pcontact.lastname = 'TestContact';
PEC3.pcontact.email = 'testcontact@dontbotherme.org';
PEC3.Agreed_To_Waiver = true;
PEC3.submit();
System.assertEquals(2,[select count() from campaignmember where campaignID=:Testcamp.ID]); 
System.assertEquals(false,PEC3.createNewLead);

// Case 4: Lead already signed up for campaign
Public_Event_Controller PEC4 = new Public_Event_Controller(sc);
System.assertEquals(false, PEC4.createNewLead);
PEC4.getcamp(); 
System.assertEquals(false,PEC4.createNewLead);
PEC4.getCamp();
System.assertEquals('TestCampaign', PEC4.camp.name);
PEC4.getpcontact();
PEC4.pcontact.firstname = 'Test';
PEC4.pcontact.lastname = 'Lead';
PEC4.pcontact.email = 'testlead@dontbotherme.org';
PEC4.Agreed_To_Waiver = true;
PEC4.submit();
System.assertEquals(2,[select count() from campaignmember where campaignID=:Testcamp.ID]); 
System.assertEquals(false,PEC4.createNewLead);


// Case 5: No Contact or Lead
// NATE REQUESTS THAT THERE BE NO ADDITIONAL INFO REQUESTED OF NEW CONTACTS OR LEADS.
// SO I MODIFIED THE TEST SCRIPT BELOW.  THE SCRIPT COMMENTED OUT IS THE OLD SCRIPT
// WHICH TESTED WHETHER THE ADDITIONAL INFORMATION WAS REQUESTED AND PROCESSED.

system.debug('JUST BEGAN TEST CASE 5, NO CONTACT OR LEAD');
Public_Event_Controller PEC5 = new Public_Event_Controller(sc);
System.assertEquals(false, PEC5.createNewLead);
PEC5.getcamp();
System.assertEquals('TestCampaign', PEC5.camp.name);
PEC5.getpcontact();
PEC5.getpcampmmbr();
PEC5.pcontact.firstname = 'Test';
PEC5.pcontact.lastname = 'Lead';
PEC5.pcontact.email = 'testlead2@dontbotherme.org';
PEC5.pcontact.MailingPostalCode = '22222';
PEC.pcampmmbr.how_heard_about_event__c = 'From the email newsletter';

//NEW TEST TO SEE IF NEWLEAD IS CREATED

//TEST TO SEE IF SIGNUP ABORTS BECAUSE HASN'T AGREED TO WAIVER
PEC5.Agreed_To_Waiver = false;
PEC5.submit();
System.assertEquals(2,[select count() from campaignmember where campaignID=:Testcamp.ID /*and contactid=:testContact.ID*/]); 
//System.assertEquals(false,PEC5.createNewLead);
System.assertEquals(true, PEC5.Must_Sign_Waiver);

/* TEST TO SEE IF SIGNUP CONTINUES ONCE AGREES TO WAIVER - this is the old signup
PEC5.Agreed_To_Waiver = true;
PEC5.submit();
System.assertEquals(true,PEC5.createNewLead);
system.debug('New lead lastname is ' + PEC5.pcontact.lastname);
PEC5.pcontact.MailingCity = 'TestCity';
PEC5.submit();
System.assertEquals(1,[Select count() from Lead where email = 'testlead2@dontbotherme.org']);
System.assertEquals(3,[select count() from campaignmember where campaignID=:Testcamp.ID]); 
system.assertEquals('TestCity',[select id, city from Lead where email='testlead2@dontbotherme.org'][0].city);
System.assertEquals('Responded Yes',PEC5.campmmbr.status);
*/

//THIS IS THE NEW SIGNUP TEST MODIFIED FOR NATE
PEC5.Agreed_To_Waiver = true;
PEC5.submit();
System.assertEquals(true,PEC5.createNewLead);
system.debug('Before invoking submit(), new lead lastname is ' + PEC5.pcontact.lastname);
PEC5.submit();
System.assertEquals(1,[Select count() from Lead where email = 'testlead2@dontbotherme.org']);
System.assertEquals(3,[select count() from campaignmember where campaignID=:Testcamp.ID]);
System.assertEquals('Responded Yes',PEC5.campmmbr.status);
ID CheckLeadID = [select id from Lead where email = 'testlead2@dontbotherme.org'].id;
//System.assertEquals('From the email newsletter',[select id,how_heard_about_event__c from
//  CampaignMember where leadID = :CheckLeadID][0].how_heard_about_event__c);



//Test newsletter signup for lead
PEC5.enewsletters = true;
PEC5.SignUpNewsletter();
system.assertEquals(PEC.mailing_list,[select id, mailing_lists__c from Lead
    where email = 'testlead2@dontbotherme.org'].mailing_lists__c);
    
//Test ewsletter signup for lead
PEC5.pcontact.Over_18__c = true;
PEC5.SetOver18();
system.assertEquals(true,[select id, Over_18__c from Lead
    where email = 'testlead2@dontbotherme.org'].Over_18__c);    
        // }  // END RUNAS   


//TEST 6: LIMIT CAMPAIGNS DISPLAYED TO ONLY THOSE IN A CERTAIN MASTER CAMPAIGN.
Master_Campaign__c mastercamp = new Master_Campaign__c(name = 'TestMasterCampaign'); 
insert mastercamp;

Campaign Testcampaign2 = new Campaign(name = 'Testcampaign2',
    capacity__c = 2,
    event_date_time__c = datetime.newInstance(2050, 12, 1, 12, 30, 2),
    description = 'description',
    event_cost__c = 20.00,
    Waiver_Required__c = true,
    RecordtypeID = [select id from recordtype where name = 'Public Event'].id,
    Master_Campaign__c = mastercamp.id);
    insert Testcampaign2;        

    String masterCampIDstring = mastercamp.Id;
PageReference pageRef2 = new PageReference('/apex/Public_Event_Signup_page?mid=TestMasterCampaign');
//Test.setCurrentPageReference(PageRef);ApexPages.currentPage().getParameters().put('mid', 'TestMasterCampaign');
Public_Event_Controller PEC8 = new Public_Event_Controller(sc);
// System.assertequals([select id, master_campaign__c from campaign where name ='TestCampaign2' limit 1].id, PEC8.mastercampID);
System.assertEquals(1,PEC8.getCampaign().size());

} // end controller
} // end test