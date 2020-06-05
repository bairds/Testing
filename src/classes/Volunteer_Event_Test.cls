// Baird and Jaspreet, 29 Dec 2014
// 6 Apr 2017 Baird add test for mailing_list, waiver
@isTest

private class Volunteer_Event_Test {
 
public static testMethod void Volunteer_Event_Test() {
    WGSettings__mdt Setting = WGHelpers.getWGSettings();
    string mailing_list = Setting.online_signup_newsletter__c;
    PageReference pageRef = Page.volunteer_event_select_page;
    Test.setCurrentPage(pageRef);
    Integer NrCampaignsDisplayed;
    //Set NrCampaignsDisplayed
    NrCampaignsDisplayed = [select count() from Campaign where (Slots_Remaining__c > 0 and Event_Date_Time__c > Today and
        (RecordType.Name = 'Public Event' or RecordType.Name = 'Volunteer Event'))];
    
    //Set up the mailing lists so they're not hard-coded
        Schema.DescribeFieldResult F =Contact.Mailing_lists__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        if (P.size() < 2) {
            apexpages.Message NeedMailingListValues = new
                apexpages.Message(apexpages.Severity.FATAL, 'Aborted test.  Must have at least 2 mailing list values in order to run tests.  Add them to Contact and Lead fields.');
        }
        String mailing_list1 = P[0].getValue();
        String mailing_list2 = P[1].getValue();
        System.debug('mailing_list1 is ' + mailing_list1);
        System.debug('mailing_list2 is ' + mailing_list2);

// Create a waiver document
	Text_Document__c waivertext = new Text_Document__c(
    Body__c = 'I am volunteering for this activity or event and understand that, as a volunteer, I may be involved in activities that have a risk of injury.  I agree that I will only perform volunteer activities that I am comfortable doing and that I am solely responsible for my safety.  I also agree that I will not hold the WaterGrass River Alliance and its officers, directors, employees, or volunteers responsible for any injury to me or my property as a result of my participation in this activity or event.  By providing my email address, I request to be included on the Alliance email list.  I understand that my and/or my child’s name, photograph, voice, or likeness may be used by the Alliance.  I consent to and authorize in advance such use, waive my rights of privacy, agree that such materials shall become the sole and exclusive property of the WaterGrass River Alliance and give up all rights, title, and interest in such property.  This release constitutes a complete release, discharge, and waiver of any and all actions or causes of action against officers, directors. employees, agents, and volunteers of the Alliance.  By registering for this event, I acknowledge that I have carefully read this Liability Waiver in its entirety, fully understand its contents, and voluntarily assume all risks and dangers inherent in participating in this activity or event.',
    Title__c='TestWaiver',
    Type__c ='Waiver');
    insert waivertext;
    
    
// Create a campaign with slots_remaining__c = 2
    Campaign Testcampaign = new Campaign();
    Testcampaign.Name = 'Testcampaign';
    Testcampaign.Capacity__c = 2;
    Testcampaign.Event_Date_Time__c = Datetime.newInstance(2050, 12, 1, 12, 30, 2);
    Testcampaign.Description = 'description';
    Testcampaign.isActive = true;
    Testcampaign.Event_Cost__c = 20.00;
    //Testcampaign.Waiver_Required__c = true;
    Testcampaign.Waiver__c = waivertext.Id;
    Testcampaign.RecordTypeId = [select Id from RecordType where Name = 'Volunteer Event'].Id;
    insert Testcampaign;        

    ApexPages.StandardController sc = new ApexPages.StandardController(Testcampaign);
    Volunteer_Event_Controller PEC = new Volunteer_Event_Controller(sc);
    System.assertEquals(NrCampaignsDisplayed + 1, PEC.getCampaign().size());

        
// Create a second campaign which is part of a master campaign, test that the controller
// selects only it when ?mid= is inserted.  
    Master_Campaign__c mcamp = new Master_Campaign__c(
        Name = 'Master Campaign');
        insert mcamp;
    Campaign Testcampaign2 = new Campaign();
    Testcampaign2.Name = 'Testcampaign2';
    Testcampaign2.Capacity__c = 2;
    Testcampaign2.Event_Date_Time__c = Datetime.newInstance(2050, 12, 1, 12, 30, 2);
    Testcampaign2.Description = 'description';
    Testcampaign2.RecordTypeId = [select Id from RecordType where Name = 'Volunteer Event'].Id;
    Testcampaign2.Master_Campaign__c = mcamp.Id;
    insert Testcampaign2;

    pageRef = Page.volunteer_event_select_page;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('mid', mcamp.Id);
    System.assertEquals(1,PEC.getCampaign().size());
//Since we just added a campaign, increase NrCampaignsDisplayed
        NrCampaignsDisplayed = NrCampaignsDisplayed+1;
        
//  Sign up a contact and a lead to the campaign
        Account Testaccount = new Account (Name='TestAccount');
        insert Testaccount;
        Contact TestContact = new Contact (FirstName='Test', LastName='TestContact', Email='testcontact@dontbotherme.org', AccountId = Testaccount.Id);
        insert TestContact;
        CampaignMember Testcampmmbr = new CampaignMember (ContactId = TestContact.Id, CampaignId = Testcampaign.Id, Nr_in_Group__c = 1);
        Insert Testcampmmbr;
        Lead TestLead = new Lead (LastName = 'Lead', FirstName = 'Test', Company = 'None', Email = 'testlead@dontbotherme.org');
        insert TestLead;    
        CampaignMember Testcampmmbr2 = new CampaignMember (LeadId = TestLead.Id, CampaignId = Testcampaign.Id, Nr_in_Group__c = 1);
        Insert Testcampmmbr2;
      
//  Verify that the controller returns one fewer campaigns now
        Volunteer_Event_Controller PEC6 = new Volunteer_Event_Controller(sc);
        System.debug('Is Testcampaign still in the list?' + [select Name from
        Campaign where(Slots_Remaining__c > 0 and Event_Date_Time__c > Today
        and (RecordType.Name = 'Public Event' or RecordType.Name = 'Volunteer Event'))]);
        System.assertEquals(NrCampaignsDisplayed, [select count() from Campaign where (Slots_Remaining__c > 0 and Event_Date_Time__c > Today and (RecordType.Name = 'Public Event' or RecordType.Name = 'Volunteer Event'))]);
    

        PEC.getHearAboutActivityOptions();
        PEC.getCarPoolingOptions();
    PEC.getSignupForGroupOptions();
    PEC.getShirtSizeOptions();
    PEC.getVolInterestOptions();
    PEC.getLeadSourceOptions();
    }

static testMethod void Volunteer_Signup_Test() {
    //Test coverage for the SignUpOpenEvent page
    WGSettings__mdt Setting = WGHelpers.getWGSettings();
    string mailing_list = Setting.online_signup_newsletter__c;
Account Testaccount = new Account (Name='TestAccount');
insert Testaccount;
Contact TestContact = new Contact (LastName='TestContact', Email='testcontact@dontbotherme.org',
    MailingPostalCode = '11111', AccountId = Testaccount.Id);
insert TestContact;
Lead TestLead = new Lead (LastName = 'Lead', FirstName = 'Test', Company = 'None',
    PostalCode = '11111', Email = 'testlead@dontbotherme.org');
insert TestLead;
    
// Create a waiver document
	Text_Document__c waivertext = new Text_Document__c(
    Body__c = 'I am volunteering for this activity or event and understand that, as a volunteer, I may be involved in activities that have a risk of injury.  I agree that I will only perform volunteer activities that I am comfortable doing and that I am solely responsible for my safety.  I also agree that I will not hold the WaterGrass River Alliance and its officers, directors, employees, or volunteers responsible for any injury to me or my property as a result of my participation in this activity or event.  By providing my email address, I request to be included on the Alliance email list.  I understand that my and/or my child’s name, photograph, voice, or likeness may be used by the Alliance.  I consent to and authorize in advance such use, waive my rights of privacy, agree that such materials shall become the sole and exclusive property of the WaterGrass River Alliance and give up all rights, title, and interest in such property.  This release constitutes a complete release, discharge, and waiver of any and all actions or causes of action against officers, directors. employees, agents, and volunteers of the Alliance.  By registering for this event, I acknowledge that I have carefully read this Liability Waiver in its entirety, fully understand its contents, and voluntarily assume all risks and dangers inherent in participating in this activity or event.',
    Title__c='TestWaiver',
    Type__c ='Waiver');
    insert waivertext;

Campaign Testcamp = new Campaign (Name='TestCampaign', Waiver_Required__c = true, Waiver__c = waivertext.Id, IsActive=TRUE,
                                  RecordType = [select Id from RecordType where Name ='Volunteer Event']);
insert Testcamp;
CampaignMember pcampmmbr = new CampaignMember();

    
// Case 1: Contact exists by email
PageReference pageRef = Page.volunteer_event_select_page;
Test.setCurrentPageReference(pageRef);
ApexPages.currentPage().getParameters().put('cid', Testcamp.Id);
ApexPages.StandardController sc = new ApexPages.StandardController(Testcamp);
Volunteer_Event_Controller PEC = new Volunteer_Event_Controller(sc);
System.assertEquals(false, PEC.createnewlead);
PEC.passCampID = Testcamp.Id;

PEC.getCamp();
System.assertEquals(false,PEC.createnewlead);
System.assertEquals('TestCampaign', PEC.camp.Name);
PEC.getpContact();
PEC.getpcampmmbr();
PEC.pcontact.FirstName ='Test';
PEC.pcontact.LastName = 'TestContact';
PEC.pcontact.Phone = '3013333333';
    PEC.pcontact.MailingStreet = '44 Court Street';
    PEC.pcontact.MailingCity = 'New York';
    PEC.pcontact.MailingState = 'NY';
    PEC.pcontact.MailingPostalCode = '10011';
PEC.pcontact.Email = 'testcontact@dontbotherme.org';
PEC.selectedHearAboutActivity = 'From the website';
PEC.pcampmmbr.Special_Location_Preference__c = true;
PEC.pcampmmbr.Teammates__c = 'Teammates';
PEC.selectedCarPooling = 'My car is full.';
PEC.pcampmmbr.Nr_in_Group__c = 3;
PEC.pcampmmbr.Pref_Location__c = 'Prefered Location';
PEC.pcampmmbr.Questions_or_Comments__c = 'Questions or Comments';
PEC.pcampmmbr.Special_Needs__c = 'Special Needs';
PEC.pcampmmbr.Waders__c = '4.5 mens / 6 womens';
PEC.pcampmmbr.Availability__c = 'Availability';
PEC.pcampmmbr.Boat__c = 'Boat';
PEC.selectedShirtSize = 'L';
PEC.pcampmmbr.Group__c = 'Baird Group';
    PEC.pcampmmbr.Emergency_Contact_Name__c = 'Test Emergency';
    PEC.pcampmmbr.Emergency_Contact_Phone__c = '111 1111';

PEC.Page1();
System.assertEquals(false,PEC.showNextPage);
PEC.Page2();
System.assertEquals(true,PEC.showNextPage);

//TEST TO SEE IF SIGNUP ABORTS BECAUSE HASN'T AGREED TO WAIVER
PEC.AgreedToWaiver = false;
PEC.submit();
System.assertEquals(0,[select count() from CampaignMember where CampaignId=:Testcamp.Id ]);
System.assertEquals(false,PEC.createnewlead);
System.assertEquals(true, PEC.Must_Sign_Waiver);
System.assertEquals(false, PEC.AgreedToWaiver);

//TEST TO SEE IF SIGNUP CONTINUES ONCE AGREES TO WAIVER
PEC.AgreedToWaiver = true;
PEC.submit();
CampaignMember testcampmmbr = [select How_Heard_About_Event__c, Special_Location_Preference__c, Boat__c,
                       Teammates__c, Car_pooling__c, Nr_in_Group__c, Pref_Location__c, Questions_or_Comments__c,
                       Special_Needs__c, Waders__c, Availability__c, Agreed_to_Waiver__c, Which_Waiver_Agreed__c,
						Shirt_Size__c, Group__c, Emergency_Contact_Name__c, Emergency_Contact_Phone__c,
                        Contact.MailingStreet, Contact.MailingCity, Contact.MailingState, Contact.MailingPostalCode
                       from CampaignMember where CampaignId=:Testcamp.Id];
System.debug('No campaign members?  Testcamp is ' + [select Name, Slots_Reserved__c, (select Id, Nr_in_Group__c from CampaignMembers) from Campaign where Id = :Testcamp.Id]);
System.assertEquals(3,[select Id, Slots_Reserved__c from Campaign where Id = :Testcamp.Id][0].Slots_Reserved__c);
System.assertEquals(true,testcampmmbr.Special_Location_Preference__c);
System.assertEquals('Teammates',testcampmmbr.Teammates__c);
System.assertEquals('My car is full.',testcampmmbr.Car_pooling__c);
System.assertEquals('Availability',testcampmmbr.Availability__c);
System.assertEquals(3,testcampmmbr.Nr_in_Group__c);
System.assertEquals('Prefered Location',testcampmmbr.Pref_Location__c);
System.assertEquals('Questions or Comments',testcampmmbr.Questions_or_Comments__c);
System.assertEquals('Special Needs',testcampmmbr.Special_Needs__c);
System.assertEquals('Availability',testcampmmbr.Availability__c);
System.assertEquals('4.5 mens / 6 womens',testcampmmbr.Waders__c);
System.assertEquals('From the website',testcampmmbr.How_Heard_About_Event__c);
System.assertEquals('Boat',testcampmmbr.Boat__c);
System.assertEquals('L',testcampmmbr.Shirt_Size__c);
    System.assertEquals('Baird Group',testcampmmbr.Group__c);
    System.assertEquals('Test Emergency',testcampmmbr.Emergency_Contact_Name__c);
    System.assertEquals('111 1111',testcampmmbr.Emergency_Contact_Phone__c);
System.assertEquals(true,testcampmmbr.Agreed_to_Waiver__c,'Agreed to waiver should now be true');
System.assertEquals(waivertext.Id,testcampmmbr.Which_Waiver_Agreed__c);
    System.assertEquals(testcampmmbr.Contact.MailingStreet,'44 Court Street');

System.assertEquals(false,PEC.createnewlead);
System.assertEquals(true, PEC.Must_Sign_Waiver);	

//Test newsletter signup for contact when Mailing_lists__c = null
PEC.enewsletters = true;

//Test phone,over18 for contact
PEC.pcontact.Over_18__c = true;
PEC.enewsletters = true;
PEC.updateContactOrLead();
Contact Tstctct = [select Id, Phone, Over_18__c, Mailing_Lists__c from Contact where Email = 'testcontact@dontbotherme.org' limit 1];
System.assertEquals(true,Tstctct.Over_18__c);
    System.debug('Tstctct.Mailing_Lists__c is ' + Tstctct.Mailing_Lists__c);
    System.assertEquals(true,Tstctct.Mailing_Lists__c.contains('enewsletter'));
System.assertEquals('3013333333',Tstctct.Phone);

//TEST RETURN TO LIST
       PEC.ReturnToList();
       String NextPage = PEC.ReturnToList().getUrl();
       System.assert(NextPage.contains('volunteer_event_select_page'),'ReturnToList() should have returned us back to the list of events.');
       
          
System.debug('Current User: ' + UserInfo.getUserName());
System.debug('Current Profile: ' + UserInfo.getProfileId());  

// Case 2: Lead exists by email
Volunteer_Event_Controller PEC2 = new Volunteer_Event_Controller(sc);
System.assertEquals(false, PEC2.createnewlead);
PEC2.getCamp();
System.assertEquals(false,PEC2.createnewlead);
PEC2.getCamp();
System.assertEquals('TestCampaign', PEC2.camp.Name);
PEC2.getpContact();
PEC2.getpcampmmbr();
PEC2.pcontact.FirstName = 'Test';
PEC2.pcontact.LastName = 'Lead';
PEC2.pcontact.Phone = '3013333333';
PEC2.pcontact.Email = 'testlead@dontbotherme.org';
PEC2.pcampmmbr.How_Heard_About_Event__c = 'Other';

//TEST TO SEE IF SIGNUP ABORTS BECAUSE HASN'T AGREED TO WAIVER
PEC2.AgreedToWaiver = false;
PEC2.submit();
System.assertEquals(1,[select count() from CampaignMember where CampaignId=:Testcamp.Id ]);
System.assertEquals(false,PEC2.createnewlead);
System.assertEquals(true, PEC2.Must_Sign_Waiver);


//TEST TO SEE IF SIGNUP CONTINUES ONCE AGREES TO WAIVER
PEC2.AgreedToWaiver = true;
PEC2.submit();
System.assertEquals(2,[select count() from CampaignMember where CampaignId=:Testcamp.Id]);
    System.assertEquals(4,[select Slots_Reserved__c from Campaign where Id=:Testcamp.Id][0].Slots_Reserved__c);
System.assertEquals(false,PEC2.createnewlead);

//Test newsletter signup for lead when Mailing_lists__c = null
PEC2.enewsletters = true;

//Was phone updated?
Lead Tstlead = [select Id, Phone, Over_18__c from Lead where Email = 'testlead@dontbotherme.org' limit 1];
System.assertEquals('3013333333',Tstlead.Phone);

// Case 6: Contact exists by zip code
TestContact.Mailing_Lists__c = 'RCC volunteer updates';
update TestContact;

pageRef = Page.volunteer_event_select_page;
Test.setCurrentPageReference(pageRef);
ApexPages.currentPage().getParameters().put('cid', Testcamp.Id);
Volunteer_Event_Controller PEC6 = new Volunteer_Event_Controller(sc);
System.assertEquals(false, PEC6.createnewlead);
PEC6.getCamp();
System.assertEquals(false,PEC6.createnewlead);
System.assertEquals('TestCampaign', PEC6.camp.Name);
PEC6.getpContact();
PEC.pcontact.FirstName ='Test';
PEC6.pcontact.LastName = 'TestContact';
PEC6.pcontact.Email = 'nottestcontact@dontbotherme.org';
PEC6.pcontact.MailingPostalCode = '11111';
PEC6.pcontact.Phone = '3013333333';
PEC6.AgreedToWaiver = true;
PEC6.submit();
System.assertEquals(2,[select count() from CampaignMember where CampaignId=:Testcamp.Id ]);
System.assertEquals(false,PEC6.createnewlead);

//Test newsletter signup for contact when Mailing_lists__c = 'RCC volunteer updates'
PEC6.enewsletters = true;

//Was phone updated?
Tstctct = [select Id, Phone, Over_18__c from Contact where LastName = 'TestContact' and MailingPostalCode = '11111' limit 1];
System.assertEquals('3013333333',Tstctct.Phone);
    
    

// Case 7: Lead exists by zipcode   
TestLead.Mailing_Lists__c = 'RCC volunteer updates';
update TestLead;

Volunteer_Event_Controller PEC7 = new Volunteer_Event_Controller(sc);
System.assertEquals(false,PEC7.createnewlead);
PEC7.getCamp();
System.assertEquals('TestCampaign', PEC7.camp.Name);
PEC7.getpContact();
PEC7.pcontact.FirstName = 'Test';
PEC7.pcontact.LastName = 'Lead';
PEC7.pcontact.Email = 'nottestlead@dontbotherme.org';
PEC7.pcontact.MailingPostalCode = '11111';
PEC7.AgreedToWaiver = true;
PEC7.submit();
System.assertEquals(2,[select count() from CampaignMember where CampaignId=:Testcamp.Id]);

//Test newsletter signup for contact when Mailing_lists__c = 'RCC volunteer updates'
PEC7.enewsletters = true;

// Case 3: Contact already signed up for campaign
Volunteer_Event_Controller PEC3 = new Volunteer_Event_Controller(sc);
System.assertEquals(false, PEC3.createnewlead);
PEC3.getCamp();
System.assertEquals(false,PEC3.createnewlead);
PEC3.getCamp();
System.assertEquals('TestCampaign', PEC3.camp.Name);
PEC3.getpContact();
PEC3.pcontact.LastName = 'TestContact';
PEC3.pcontact.Email = 'testcontact@dontbotherme.org';
PEC3.AgreedToWaiver = true;
PEC3.submit();
System.assertEquals(2,[select count() from CampaignMember where CampaignId=:Testcamp.Id]);
System.assertEquals(false,PEC3.createnewlead);
}
    
static testMethod void Volunteer_Signup_Test_Cont() {
    WGSettings__mdt Setting = WGHelpers.getWGSettings();
    string mailing_list = Setting.online_signup_newsletter__c;
Account Testaccount = new Account (Name='TestAccount');
insert Testaccount;
Contact TestContact = new Contact (LastName='TestContact', Email='testcontact@dontbotherme.org',
    MailingPostalCode = '11111', AccountId = Testaccount.Id);
insert TestContact;
Lead TestLead = new Lead (LastName = 'Lead', FirstName = 'Test', Company = 'None',
    PostalCode = '11111', Email = 'testlead@dontbotherme.org');
insert TestLead;
Campaign Testcamp = new Campaign (Name='TestCampaign', Waiver_Required__c = true, IsActive=TRUE,
                                  RecordType = [select Id from RecordType where Name ='Volunteer Event']);
insert Testcamp;
CampaignMember pcampmmbr = new CampaignMember();    

// Case 4: Lead already signed up for campaign
PageReference pageRef = Page.volunteer_event_select_page;
Test.setCurrentPageReference(pageRef);
ApexPages.currentPage().getParameters().put('cid', Testcamp.Id);
ApexPages.StandardController sc = new ApexPages.StandardController(Testcamp);
Volunteer_Event_Controller PEC4 = new Volunteer_Event_Controller(sc);
System.assertEquals(false, PEC4.createnewlead);
PEC4.getCamp();
System.assertEquals(false,PEC4.createnewlead);
PEC4.getCamp();
System.assertEquals('TestCampaign', PEC4.camp.Name);
PEC4.getpContact();
PEC4.pcontact.FirstName = 'Test';
PEC4.pcontact.LastName = 'Lead';
PEC4.pcontact.Email = 'testlead@dontbotherme.org';
PEC4.AgreedToWaiver = true;
PEC4.submit();
System.assertEquals(1,[select count() from CampaignMember where CampaignId=:Testcamp.Id]);
System.assertEquals(false,PEC4.createnewlead);


// Case 5: No Contact or Lead

System.debug('JUST BEGAN TEST CASE 5, NO CONTACT OR LEAD');
Volunteer_Event_Controller PEC5 = new Volunteer_Event_Controller(sc);
System.assertEquals(false, PEC5.createnewlead);
PEC5.getCamp();
System.assertEquals('TestCampaign', PEC5.camp.Name);
PEC5.getpContact();
PEC5.getpcampmmbr();
PEC5.pcontact.FirstName = 'Test';
PEC5.pcontact.LastName = 'Lead';
PEC5.pcontact.Email = 'testlead2@dontbotherme.org';
PEC5.pcontact.MailingPostalCode = '22222';
PEC5.pcampmmbr.How_Heard_About_Event__c = 'From the email newsletter';
List<String> selectedVolunteerInterests = new List<String>();
selectedVolunteerInterests.add('Rainbarrel');
selectedVolunteerInterests.add('Fundraising');
PEC5.selectedVolunteerInterests = selectedVolunteerInterests;

//NEW TEST TO SEE IF NEWLEAD IS CREATED

//TEST TO SEE IF SIGNUP ABORTS BECAUSE HASN'T AGREED TO WAIVER
PEC5.AgreedToWaiver = false;
PEC5.submit();
System.assertEquals(1,[select count() from CampaignMember where CampaignId=:Testcamp.Id ]);
//System.assertEquals(false,PEC5.createNewLead);
System.assertEquals(true, PEC5.Must_Sign_Waiver);

PEC5.AgreedToWaiver = true;
PEC5.submit();
System.assertEquals(true,PEC5.createnewlead);
System.debug('Before invoking submit(), new lead lastname is ' + PEC5.pcontact.LastName);
PEC5.submit();
List<Lead> checkLeads = [Select Volunteer_Interests__c from Lead where Email = 'testlead2@dontbotherme.org'];
System.assertEquals(1,checkLeads.size());
System.assertEquals(true, String.isNotBlank(checkLeads[0].Volunteer_Interests__c));
System.assert(checkLeads[0].Volunteer_Interests__c.contains('Rainbarrel'));
System.assert(checkLeads[0].Volunteer_Interests__c.contains('Fundraising'));
System.assertEquals(2,[select count() from CampaignMember where CampaignId=:Testcamp.Id]);
System.assertEquals('Responded Yes',PEC5.campmmbr.Status);
Id CheckLeadID = [select Id from Lead where Email = 'testlead2@dontbotherme.org'].Id;

//Test newsletter signup for lead
PEC5.enewsletters = true;
//Test ewsletter signup for lead
PEC5.pcontact.Over_18__c = true;
PEC5.updateContactOrLead();
System.assertEquals(true,[select Id, Over_18__c from Lead
    where Email = 'testlead2@dontbotherme.org'].Over_18__c);
        // }  // END RUNAS       
    

//TEST 6: LIMIT CAMPAIGNS DISPLAYED TO ONLY THOSE IN A CERTAIN MASTER CAMPAIGN.
Master_Campaign__c mastercamp = new Master_Campaign__c(Name = 'TestMasterCampaign');
insert mastercamp;

Campaign Testcampaign2 = new Campaign(Name = 'Testcampaign2',
    Capacity__c = 2,
    Event_Date_Time__c = Datetime.newInstance(2050, 12, 1, 12, 30, 2),
    Description = 'description',
    Event_Cost__c = 20.00,
        isActive = true,
    Waiver_Required__c = true,
    RecordTypeId = [select Id from RecordType where Name = 'Volunteer Event'].Id,
    Master_Campaign__c = mastercamp.Id);
    insert Testcampaign2;        

    String masterCampIDstring = mastercamp.Id;
PageReference pageRef2 = new PageReference('/apex/Volunteer_Event_Signup_page?mid=TestMasterCampaign');
//Test.setCurrentPageReference(PageRef);ApexPages.currentPage().getParameters().put('mid', 'TestMasterCampaign');
Volunteer_Event_Controller PEC8 = new Volunteer_Event_Controller(sc);
// System.assertequals([select id, master_campaign__c from campaign where name ='TestCampaign2' limit 1].id, PEC8.mastercampID);
System.assertEquals(1,PEC8.getCampaign().size());
} // end testmethod

//Test 7: Name of lead contains "Blank" presumably because Carl loaded data this way    
// Create a campaign with slots_remaining__c = 2
    public static testMethod void LeadNamedBlank() {
        WGSettings__mdt Setting = WGHelpers.getWGSettings();
        string mailing_list = Setting.online_signup_newsletter__c;
        Campaign Testcampaign = new Campaign();
        Testcampaign.Name = 'Testcampaign';
        Testcampaign.Capacity__c = 2;
        Testcampaign.Event_Date_Time__c = Datetime.newInstance(2050, 12, 1, 12, 30, 2);
        Testcampaign.Description = 'description';
        Testcampaign.Event_Cost__c = 20.00;
        Testcampaign.Waiver_Required__c = true;
        Testcampaign.RecordTypeId = [select Id from RecordType where Name = 'Volunteer Event'].Id;
        insert Testcampaign;
        Lead TestLead = new Lead (LastName = 'Blank', FirstName = '', Company = 'Blank, Household', Email = 'testlead@dontbotherme.org');
        insert TestLead;
        ApexPages.StandardController sc = new ApexPages.StandardController(Testcampaign);
        Volunteer_Event_Controller PEC = new Volunteer_Event_Controller(sc);
        ApexPages.currentPage().getParameters().put('cid', Testcampaign.Id);
        PEC.getpContact();
        PEC.getpcampmmbr();
        PEC.getCamp();
        PEC.pcontact.FirstName = 'Test';
        PEC.pcontact.LastName = 'TestContact';
        PEC.pcontact.Phone = '3013333333';
        PEC.pcontact.MailingStreet = '44 Court Street';
        PEC.pcontact.MailingCity = 'New York';
        PEC.pcontact.MailingState = 'NY';
        PEC.pcontact.MailingPostalCode = '10011';
        PEC.pcontact.Email = 'testlead@dontbotherme.org';
        PEC.pcampmmbr.How_Heard_About_Event__c = 'From the website';
        PEC.AgreedToWaiver = true;
        PEC.submit();
        Lead checkLead = [select Id, FirstName, Street, LastName, Company from Lead where Email = 'testlead@dontbotherme.org'];
        System.assertEquals('TestContact', checkLead.LastName);
        system.assertEquals('44 Court Street', checkLead.Street);
    }

//Test 7a: Lead has no PostalCode, so new PostalCode should be inserted.
    // Has some fields in address, so those should be added to Description.
// Create a campaign with slots_remaining__c = 2
        public static testMethod void LeadNoPostalCode() {
            WGSettings__mdt Setting = WGHelpers.getWGSettings();
            string mailing_list = Setting.online_signup_newsletter__c;

    Campaign Testcampaign = new Campaign();
    Testcampaign.Name = 'Testcampaign';
    Testcampaign.Capacity__c = 2;
    Testcampaign.Event_Date_Time__c = Datetime.newInstance(2050, 12, 1, 12, 30, 2);
    Testcampaign.Description = 'description';
    Testcampaign.Event_Cost__c = 20.00;
    Testcampaign.Waiver_Required__c = true;
    Testcampaign.RecordTypeId = [select Id from RecordType where Name = 'Volunteer Event'].Id;
    insert Testcampaign;
    Lead TestLead = new Lead (LastName = 'Blank', FirstName = '', Street='44 Court Street', Company = 'Blank, Household', Email = 'testlead@dontbotherme.org');
    insert TestLead;
    ApexPages.StandardController sc = new ApexPages.StandardController(Testcampaign);
    Volunteer_Event_Controller PEC = new Volunteer_Event_Controller(sc);
    ApexPages.currentPage().getParameters().put('cid', Testcampaign.Id);
    PEC.getpContact();
PEC.getpcampmmbr();
PEC.getCamp();
PEC.pcontact.FirstName ='Test';
PEC.pcontact.LastName = 'Blank';
PEC.pcontact.Phone = '3013333333';
PEC.pcontact.MailingStreet = '44 Court Street';
            PEC.pcontact.MailingPostalCode = '10011';
PEC.pcontact.Email = 'testlead@dontbotherme.org';
PEC.pcampmmbr.How_Heard_About_Event__c = 'From the website';
PEC.AgreedToWaiver = true;
PEC.submit();
Lead checkLead = [select Id, FirstName, Street, Description, LastName, PostalCode, Company from Lead where Email = 'testlead@dontbotherme.org'];
System.assertEquals('Blank',checkLead.LastName);
            System.assertEquals('10011',CheckLead.PostalCode);
            System.assert(CheckLead.Description.CONTAINS('44 Court Street'));
system.assertEquals('44 Court Street',checkLead.Street);
} // end testmethod

//Test 7b: Contact has no PostalCode, so new PostalCode should be inserted.
    // Has some fields in address, so those should be added to Description.
// Create a campaign with slots_remaining__c = 2
    public static testMethod void ContactNoPostalCode() {
        WGSettings__mdt Setting = WGHelpers.getWGSettings();
        string mailing_list = Setting.online_signup_newsletter__c;

        Campaign Testcampaign = new Campaign();
        Testcampaign.Name = 'Testcampaign';
        Testcampaign.Capacity__c = 2;
        Testcampaign.Event_Date_Time__c = Datetime.newInstance(2050, 12, 1, 12, 30, 2);
        Testcampaign.Description = 'description';
        Testcampaign.Event_Cost__c = 20.00;
        Testcampaign.Waiver_Required__c = true;
        Testcampaign.RecordTypeId = [select Id from RecordType where Name = 'Volunteer Event'].Id;
        insert Testcampaign;
        Account TestAcct = new Account(Name='Blank Household');
        insert TestAcct;
        Contact TestContact = new Contact (LastName = 'Blank', FirstName = '', MailingStreet='44 Court Street', AccountId=TestAcct.Id, Email = 'testContact@dontbotherme.org');
        insert TestContact;
        ApexPages.StandardController sc = new ApexPages.StandardController(Testcampaign);
        Volunteer_Event_Controller PEC = new Volunteer_Event_Controller(sc);
        ApexPages.currentPage().getParameters().put('cid', Testcampaign.Id);
        PEC.getpContact();
        PEC.getpcampmmbr();
        PEC.getCamp();
        PEC.pcontact.FirstName ='Test';
        PEC.pcontact.LastName = 'Blank';
        PEC.pcontact.Phone = '3013333333';
        PEC.pcontact.MailingStreet = '44 Court Street';
        PEC.pcontact.MailingPostalCode = '10011';
        PEC.pcontact.Email = 'testContact@dontbotherme.org';
        PEC.pcampmmbr.How_Heard_About_Event__c = 'From the website';
        PEC.AgreedToWaiver = true;
        PEC.submit();
        Contact checkContact = [select Id, FirstName, MailingStreet, Description, Account.Description, LastName, MailingPostalCode from Contact where Email = 'testContact@dontbotherme.org'];
        System.assertEquals('Blank',checkContact.LastName);
        System.assertEquals('10011',CheckContact.MailingPostalCode);
        System.assert(CheckContact.Description.CONTAINS('44 Court Street'));
        System.assert(CheckContact.Account.Description.CONTAINS('44 Court Street'));
        system.assertEquals('44 Court Street',checkContact.MailingStreet);
    } // end testmethod

    //Test 9: Create a campaign with slots_remaining__c = 2
    public static testMethod void NoWaiverRequired() {
        WGSettings__mdt Setting = WGHelpers.getWGSettings();
        string mailing_list = Setting.online_signup_newsletter__c;

        Campaign Testcampaign = new Campaign();
        Testcampaign.Name = 'Testcampaign';
        Testcampaign.Capacity__c = 2;
        Testcampaign.Event_Date_Time__c = Datetime.newInstance(2050, 12, 1, 12, 30, 2);
        Testcampaign.Description = 'description';
        Testcampaign.Event_Cost__c = 20.00;
        Testcampaign.Waiver_Required__c = false;
        Testcampaign.RecordTypeId = [select Id from RecordType where Name = 'Volunteer Event'].Id;
        insert Testcampaign;
        Lead TestLead = new Lead (LastName = 'Blank', FirstName = '', Company = 'Blank, Household', Email = 'testlead@dontbotherme.org');
        insert TestLead;
        ApexPages.StandardController sc = new ApexPages.StandardController(Testcampaign);
        Volunteer_Event_Controller PEC = new Volunteer_Event_Controller(sc);
        ApexPages.currentPage().getParameters().put('cid', Testcampaign.Id);
        PEC.getpContact();
        PEC.getpcampmmbr();
        PEC.getCamp();
        PEC.pcontact.FirstName ='Test';
        PEC.pcontact.LastName = 'TestContact';
        PEC.pcontact.Phone = '3013333333';
        PEC.pcontact.Email = 'testlead@dontbotherme.org';
        PEC.pcampmmbr.How_Heard_About_Event__c = 'From the website';
        PEC.AgreedToWaiver = false;
        PEC.submit();
        List<CampaignMember> ConfirmCMs = [select id, lead.firstname from CampaignMember where campaignid =: Testcampaign.Id];
        system.assertEquals(1,ConfirmCMs.size());
        system.assertEquals('Test',ConfirmCMs[0].lead.firstname);



    } // end testmethod
} // end test