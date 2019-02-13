// Baird 23 Feb 2015.  Updated so that first and lastname always update
// the lead.first and lead.lastname.  But leaves contact.name alone.
// 31 August 2016.  Add code and WGHelpers class to handle namespaces.
// Apr 2017.  Add ability to use multiple waivers in TextDocument__c.

public class Volunteer_Event_Controller {

    public Volunteer_Event_Controller(ApexPages.StandardController stdController) {
        createnewlead = false;
        showNextPage = false;
        pcampmmbr = new CampaignMember();
        selectedVolunteerInterests = new List<String>();
        NameSpaceString = String.isEmpty(WGHelpers.getNamespace()) ? null : WGHelpers.getNamespace() + '__';
        AgreedToWaiver = false;
        Agreed_To_Waiver = false;
        tzoffset = WGHelpers.getoffset();

        WGSettings__mdt Setting = WGHelpers.getWGSettings();
        mailing_list = Setting.Online_signup_newsletter__c;
    }

//DECLARE VARIABLES
    public double tzoffset { get; set; }
    public timezone tz { get; set; }
    Public Campaign camp;
    Public String passCampID { get; set; }
    Public Contact pcontact;
    public List<String> results { get; set; }
    Public Lead newlead { get; set; }
    Public CampaignMember pcampmmbr; // Preliminary campmmbr to hold value of how_heard_about_event__c
    Public CampaignMember campmmbr;
    Public Opportunity Op;
    Public Contact TempContact;
    Public Lead tempLead;
    Public Boolean showNextPage { get; set; }
    Id leadrt = [select Id from RecordType where Name = 'Online Signup' AND SobjectType = 'Lead'].Id;
    Public Boolean createnewlead { get; set; }
    Public Boolean readytosubmit { get; set; }
    Public Boolean AgreedToWaiver { get; set; }
    Public Boolean Agreed_To_Waiver { get; set; } // This is somewhere on the page.  cant find it.
    Public Boolean Must_Sign_Waiver { get; set; }
    Public Boolean enewsletters { get; set; }
    Boolean CampmmbrExists = false;
    Public String companyString { get; set; }
    private List<Campaign> mCampaign;
    Public Boolean isEventFull { get; set; }
    Public Boolean EventFull { get; set; }
    Public String mailing_list;
    Public String MasterCampTitle { get; set; }

    public String selectedHearAboutActivity { get; set; }
    public String selectedCarPooling { get; set; }
    public String selectedSignupForGroup { get; set; }
    public String selectedShirtSize { get; set; }
    public List<String> selectedVolunteerInterests { get; set; }
    public Id cid { get; set; }
    public String NameSpaceString { get; set; }
    public List<Campaign> getCampaign() {
        if (null == mCampaign) {
            if (ApexPages.currentPage().getParameters().get('mid') != null) {
                String masterCampID = ApexPages.currentPage().getParameters().get('mid');
                MasterCampTitle = [select Name from Master_Campaign__c where Id = :masterCampID].Name;
                mCampaign = [
                        select campaign.Name, Id, Description, Event_Location__c, Event_Date_Time__c,
                                RecordTypeId, Event_Cost__c, Slots_Remaining__c, Waiver_Required__c, Campaign_Webpage__c, Type
                        from Campaign
                        where
                        (Event_Date_Time__c >= Today and Master_Campaign__c = :masterCampID and (RecordType.Name = 'Public Event'
                        or RecordType.Name = 'Volunteer Event'))
                        ORDER BY Event_Date_Time__c ASC
                ];
            } else // select all public events or volunteer events
            {
                mCampaign = [
                        select campaign.Name, Id, Description, Event_Location__c, Event_Date_Time__c,
                                RecordTypeId, Event_Cost__c, Slots_Remaining__c, Waiver_Required__c, Campaign_Webpage__c, Type
                        from Campaign
                        where
                        (Event_Date_Time__c >= Today and (RecordType.Name = 'Public Event'
                        or RecordType.Name = 'Volunteer Event'))
                        ORDER BY Event_Date_Time__c ASC
                ];
            }
        }

        return mCampaign;
    }

//PASS IN DATA ABOUT THIS PARTICULAR CAMPAIGN
    public Campaign getCamp() {
        System.debug('cid is ' + ApexPages.currentPage().getParameters().get('cid'));
        camp = [
                SELECT Id,Name, Description, Description_Long__c, Event_Cost__c, Signup_Template__c, Campaign_Webpage__c,
                        Event_Location__c, Event_Date_Time__c, Waiver_Required__c, Waiver__c, Waiver__r.Name, Waiver__r.Body__c, Signup_Questions__c, Allow_Group_Signup__c,
                        Slots_Remaining__c
                FROM Campaign
                WHERE Id = :ApexPages.currentPage().getParameters().get('cid')
                limit 1
        ];
        if (camp.Slots_Remaining__c < 1) isEventFull = true;
        System.debug('Camp.ID is now ' + camp.Id);
        return camp;
    }

//CONTACT VARIABLE TO HOLD CONTACT FIELDS
    public Contact getpContact() {
        if (pcontact == null) {
            pcontact = new Contact();
        }
        return pcontact;
    }

//CAMPMMBR VARIABLE TO HOLD CONTACT FIELDS
    public CampaignMember getpcampmmbr() {
        if (pcampmmbr == null) {
            pcampmmbr = new CampaignMember();
        }
        return pcampmmbr;
    }

// RADIO OPTIONS - Hear About Activity
    public List<SelectOption> getHearAboutActivityOptions() {
        List<SelectOption> options = new List<SelectOption>{
        };
        Schema.SObjectType sObjType = CampaignMember.getSObjectType();
        Schema.DescribeSObjectResult sObjResult = sObjType.getDescribe();
        Map<String, Schema.SObjectField> sObjFields = sObjResult.fields.getMap();
        //if (NameSpaceString != null) {
        List<Schema.PicklistEntry> picklistValues = NameSpaceString == null ?
                sObjFields.get('How_heard_about_event__c').getDescribe().getPicklistValues() :
                sObjFields.get(NameSpaceString + 'How_heard_about_event__c').getDescribe().getPicklistValues();
        for (Schema.PicklistEntry entry : picklistValues) {
            options.add(new SelectOption(entry.getValue(), entry.getLabel()));
        }
        return options;
    }

// RADIO OPTIONS - Leadsource added for Huron River
    public List<SelectOption> getLeadSourceOptions() {
        List<SelectOption> options = new List<SelectOption>{
        };
        Schema.sObjectType sObjType = Contact.getSObjectType();
        Schema.DescribeSObjectResult sObjResult = sObjType.getDescribe();
        Map<String, Schema.SObjectField> sObjFields = sObjResult.fields.getMap();
        List<Schema.PicklistEntry> picklistValues = sObjFields.get('LeadSource').getDescribe().getPickListValues();
        for (Schema.PicklistEntry entry : picklistValues) {
            options.add(new SelectOption(entry.getLabel(), entry.getValue()));
        }
        return options;
    }
// RADIO OPTIONS - Car Pooling
    public List<SelectOption> getCarPoolingOptions() {
        List<SelectOption> options = new List<SelectOption>{
        };
        Schema.SObjectType sObjType = CampaignMember.getSObjectType();
        Schema.DescribeSObjectResult sObjResult = sObjType.getDescribe();
        Map<String, Schema.SObjectField> sObjFields = sObjResult.fields.getMap();
        List<Schema.PicklistEntry> picklistValues = NameSpaceString == null ?
                sObjFields.get('Car_pooling__c').getDescribe().getPicklistValues() :
                sObjFields.get(NameSpaceString + 'How_heard_about_event__c').getDescribe().getPicklistValues(); for (Schema.PicklistEntry entry : picklistValues) {
            options.add(new SelectOption(entry.getValue(), entry.getLabel()));
        }
        return options;
    }


// RADIO OPTIONS - Signup for Group
    public List<SelectOption> getSignupForGroupOptions() {
        List<SelectOption> options = new List<SelectOption>{
        };
        Schema.SObjectType sObjType = Campaign.getSObjectType();
        Schema.DescribeSObjectResult sObjResult = sObjType.getDescribe();
        Map<String, Schema.SObjectField> sObjFields = sObjResult.fields.getMap();
        List<Schema.PicklistEntry> picklistValues = NameSpaceString == null ?
                sObjFields.get('Signup_for_group__c').getDescribe().getPicklistValues() :
                sObjFields.get(NameSpaceString + 'Signup_for_group__c').getDescribe().getPicklistValues(); for (Schema.PicklistEntry entry : picklistValues) {
            options.add(new SelectOption(entry.getValue(), entry.getLabel()));
        }
        return options;
    }


// RADIO OPTIONS - Shirt Size
    public List<SelectOption> getShirtSizeOptions() {
        List<SelectOption> options = new List<SelectOption>{
        };
        Schema.SObjectType sObjType = CampaignMember.getSObjectType();
        Schema.DescribeSObjectResult sObjResult = sObjType.getDescribe();
        Map<String, Schema.SObjectField> sObjFields = sObjResult.fields.getMap();
        List<Schema.PicklistEntry> picklistValues = NameSpaceString == null ?
                sObjFields.get('Shirt_Size__c').getDescribe().getPicklistValues() :
                sObjFields.get(NameSpaceString + 'Shirt_Size__c').getDescribe().getPicklistValues(); for (Schema.PicklistEntry entry : picklistValues) {
            options.add(new SelectOption(entry.getValue(), entry.getLabel()));
        }
        return options;
    }


// RADIO OPTIONS Volunteer Interests  
    public List<SelectOption> getVolInterestOptions() {
        List<SelectOption> options = new List<SelectOption>{
        };
        Schema.SObjectType sObjType = Contact.getSObjectType();
        Schema.DescribeSObjectResult sObjResult = sObjType.getDescribe();
        Map<String, Schema.SObjectField> sObjFields = sObjResult.fields.getMap();
        List<Schema.PicklistEntry> picklistValues = NameSpaceString == null ?
                sObjFields.get('Volunteer_Interests__c').getDescribe().getPicklistValues() :
                sObjFields.get(NameSpaceString + 'Volunteer_Interests__c').getDescribe().getPicklistValues(); for (Schema.PicklistEntry entry : picklistValues) {
            options.add(new SelectOption(entry.getValue(), entry.getLabel()));
        }
        return options;
    }

//RETURN TO LIST FUNCTION
    public PageReference ReturnToList() {
        PageReference ReturnToList = Page.volunteer_event_select_page;
        ReturnToList.setRedirect(true);
        return ReturnToList;
    }

//CHOOSE TEMPLATE

    public PageReference ChooseTemplate() {
        PageReference VolSignupTemplate = new PageReference('/apex/volunteer_event_signup_page?cid=701q0000000Bfdb');
        VolSignupTemplate.setRedirect(false);
        return VolSignupTemplate;
    }

//Submit FUNCTION
    public PageReference submit() {
//MAKE SURE THEY'VE AGREED TO THE WAIVER
        System.debug('AgreedToWaiver ' + AgreedToWaiver);
        System.debug('Waiver Required ' + camp.Waiver_Required__c);
        if (AgreedToWaiver == false && camp.Waiver_Required__c == true) {
            Must_Sign_Waiver = true;
            return null;
        }
        // Retrieve selectedVolunteerInterests
        if (selectedVolunteerInterests <> null) {
            String ConcatString = '';
            for (String s : selectedVolunteerInterests) {
                ConcatString += s + ';';
            }
            ConcatString = ConcatString.removeEnd(';');
            pcontact.Volunteer_Interests__c = ConcatString;
        }
        //IF NOT ALREADY DONE, CHECK EMAIL, ZIP CODE AGAINST EXISTING LEADS AND CONTACT
        System.debug('if results null identifysigner.  results is ' + results);
        if (results == null) IdentifySigner();
        if (createnewlead == true) {
            return null;
        }
        System.debug('readyToSubmit is ' + readytosubmit);
        if (readytosubmit) {
            InsertCampaignMember(results[0], results[1]);
            // Update contact.over_18__c and Mailing_List__c
            System.debug('Is address populated?  MailingStreet is ' + pcontact.MailingStreet);
            if (pcontact.Over_18__c == true || enewsletters == true || pcontact.MailingStreet != null || pcontact.MailingPostalCode != null) {
                updateContactOrLead();
            } // END SETOVER18
            //REDIRECT TO THANKYOU PAGE
            PageReference Thanks_Page = Page.volunteer_event_thank_page;
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
        Contact[] pccheck = [Select Id, AccountId from Contact where Email = :pcontact.Email];
        if (pccheck.size() > 0) {
            results[0] = pccheck[0].Id;
            results[1] = 'Contact';
            //Update phone and Volunteer_Interests__c
            if (pcontact.Phone != null) {
                Contact updatePhone = new Contact(Id = pccheck[0].Id, Phone = pcontact.Phone, Volunteer_Interests__c = pcontact.Volunteer_Interests__c);
                update updatePhone;
                System.debug('Just updated phone to ' + [select Phone from Contact where Email = :pcontact.Email][0].Phone);
            }
            readytosubmit = true;
            return results;
        } ELSE {
            //If lead exists
            Lead[] lcheck = [Select Id,Phone from Lead where Email = :pcontact.Email];
            System.debug('pcontact.email is ' + pcontact.Email);
            if (lcheck.size() > 0) {
                results[0] = lcheck[0].Id;
                results[1] = 'Lead';
                //Update phone,firstname,lastname,Volunteer_Interests__c
                if (pcontact.Phone != null) {
                    Lead updatePhone = new Lead(Id = lcheck[0].Id, Phone = pcontact.Phone, LastName = pcontact.LastName, FirstName = pcontact.FirstName, Volunteer_Interests__c = pcontact.Volunteer_Interests__c);
                    update updatePhone;
                    System.debug('Just updated phone to ' + lcheck[0].Phone);
                }
                readytosubmit = true;
                return results;
            } ELSE {
                //does contact exist based on name and zip code?
                pccheck = [
                        Select Id, AccountId
                        from Contact
                        where (FirstName = :pcontact.FirstName AND LastName = :pcontact.LastName
                        AND MailingPostalCode = :pcontact.MailingPostalCode)
                ];
                if (pccheck.size() > 0) {
                    results[0] = pccheck[0].Id;
                    results[1] = 'Contact';
                    //Update phone
                    if (pcontact.Phone != null) {
                        Contact updatePhone = new Contact(Id = pccheck[0].Id, Phone = pcontact.Phone, Volunteer_Interests__c = pcontact.Volunteer_Interests__c);
                        update updatePhone;
                        System.debug('Just updated phone to ' + [
                                select Phone
                                from Contact
                                where (FirstName = :pcontact.FirstName AND LastName = :pcontact.LastName
                                AND MailingPostalCode = :pcontact.MailingPostalCode)
                        ][0].Phone);
                    }
                    readytosubmit = true;
                    System.debug('Passed: Identified contact by name and zip code');
                    return results;
                } ELSE {
                    //does LEAD exist based on name and zip code?
                    lcheck = [
                            Select Id, FirstName, LastName, PostalCode
                            from Lead
                            where (FirstName = :pcontact.FirstName AND LastName = :pcontact.LastName
                            AND PostalCode = :pcontact.MailingPostalCode)
                    ];
                    if (lcheck.size() > 0) {
                        results[0] = lcheck[0].Id;
                        results[1] = 'Lead';
                        //Update phone,firstname,lastname
                        if (pcontact.Phone != null) {
                            Lead updatePhone = new Lead(Id = lcheck[0].Id, Phone = pcontact.Phone, LastName = pcontact.LastName, FirstName = pcontact.FirstName, Volunteer_Interests__c = pcontact.Volunteer_Interests__c);
                            update updatePhone;
                            // system.debug('Just updated phone to ' + [select phone from lead where email = :pcontact.email].phone);
                        }
                        readytosubmit = true;
                        System.debug('Passed: Identified lead by name and zip code');

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
                        } else //create new lead
                        {
                            if (String.isEmpty(companyString)) companyString = 'none';
                            Lead newlead = new Lead (LastName = pcontact.LastName,
                                    FirstName = pcontact.FirstName,
                                    Email = pcontact.Email,
                                    Company = companyString,
                                    Street = pcontact.MailingStreet,
                                    City = pcontact.MailingCity,
                                    State = pcontact.MailingState,
                                    PostalCode = pcontact.MailingPostalCode,
                                    Phone = pcontact.Phone,
                                    Volunteer_Interests__c = pcontact.Volunteer_Interests__c,
                                    Volunteer_Skills__c = pcontact.Volunteer_Skills__c,
                                    LeadSource = 'Online Event Signup',
                                    RecordTypeId = [
                                            select Id
                                            from RecordType
                                            where Name = 'Online Signup' and
                                            SobjectType = 'Lead'
                                    ].Id);
                            insert newlead;
                            createnewlead = false;
                            results[0] = newlead.Id;
                            results[1] = 'Lead';
                            System.debug('newlead is ' + newlead);
                            System.debug('newlead firstname is ' + newlead.FirstName);
                            readytosubmit = true;
                            return results;
                        } // end else create new lead
                    } //end if enternewlead==null go back for more info
                } // end ELSE does lead exist based on zipcode
            } // end ELSE does contact exist based on zipcode
        } // end ELSE does lead exist based on email?
    } // end does contact exist based on email?

    public void InsertCampaignMember(Id memberID, String mtype) {
        getCamp();
        //getpcampmmbr();
        // Instantiate CampMmbr to hold data
        campmmbr = new CampaignMember(
                CampaignId = camp.Id);

        // Does campmmbr already exist?
        if (mtype == 'Contact') {
            System.debug('Entered insertCampaignMember, mtype = contact');
            CampaignMember[] ccheck = [
                    select Id, ContactId, CampaignId
                    from CampaignMember
                    where
                    ContactId = :memberID and CampaignId = :camp.Id
            ];
            if (ccheck.size() > 0) {
                System.debug('Passed insertCampaignMember, ccheck.size() > 0');
                campmmbr = ccheck[0];
                System.debug('Just set campmmbr to ' + campmmbr.Id);
                System.debug('campmmbr.contactid is now ' + campmmbr.ContactId);
                campmmbr = insertCampmmbrFields(campmmbr);
                update campmmbr;
                return;
            } // END IF campmmbr exists based on contact id
            // ELSE INSERT NEW CAMPMMBR LINKED
            else {
                System.debug('Passed insertCampaignMember, else insert campmmbr');
                campmmbr.ContactId = memberID;
                campmmbr = insertCampmmbrFields(campmmbr);
                insert campmmbr;

                return;
            } // END ELSE INSERT NEW CAMPMMBR OF TYPE CONTACT
        } // END IF MTYPE = CONTACT
        else {
            //OTHERWISE THE MTYPE = LEAD
            System.debug('Passed else insertCampaignMember, mtype = lead');
            CampaignMember[] lcheck = [
                    select Id, LeadId
                    from CampaignMember
                    where LeadId = :memberID
                    and CampaignId = :camp.Id
            ];
            if (lcheck.size() > 0) {
                System.debug('Passed insertCampaignMember, lcheck.size() > 0');
                campmmbr = lcheck[0];
                System.debug('Just set campmmbr to ' + campmmbr.Id);
                System.debug('campmmbr.leadid is now ' + campmmbr.LeadId);
                campmmbr = insertCampmmbrFields(campmmbr);
                update campmmbr;
                return;
            } // END IF campmmbr exists based on lead id
            // IF NO EXISTING CAMPMMBR based on leadid
            else {
                campmmbr.LeadId = memberID;
                campmmbr = insertCampmmbrFields(campmmbr);
                System.debug('Passed else INSERT NEW CAMPMMBR, right now campmember is ' + campmmbr);
                insert campmmbr;
                System.debug('Just inserted campmmbr ' + campmmbr.Id);
                System.debug('campmmbr.leadid is now ' + campmmbr.LeadId);
                System.debug('campmmbr.status is now ' + campmmbr.Status);
            } // END ELSE CREATE NEW CAMPAIGNMEMBER OF TYPE
        } // END else assume mtype == lead
    } // END method


    public void updateContactOrLead() {
        if (results[1] == 'Lead') {
            Lead tempLead = [select Id, Mailing_Lists__c, Street, City, State, PostalCode, Description from Lead where Id = :results[0]];
            if (pcontact.Over_18__c == true) tempLead.Over_18__c = true;
            if (enewsletters == true) tempLead.Mailing_Lists__c = tempLead.Mailing_Lists__c + ';' + mailing_list;
            //Only insert full address if all fields filled and only insert MailingPostalCode if that's null;
            if (TempLead.Street == null && pcontact.MailingStreet != NULL && pcontact.MailingCity != NULL && pcontact.MailingState != NULL && pcontact.MailingPostalCode != NULL) {
                TempLead.Street = pcontact.MailingStreet;
                TempLead.City = pcontact.MailingCity;
                TempLead.State = pContact.MailingState;
                TempLead.PostalCode = pContact.MailingPostalCode;
            } else {
                if (TempLead.PostalCode == null && pcontact.MailingPostalCode != null && TempLead.PostalCode != pcontact.MailingPostalCode)
                    TempLead.PostalCode = pContact.MailingPostalCode;
                if (TempLead.Street + TempLead.City + TempLead.State + Templead.PostalCode != null)
                    TempLead.Description += 'New address submitted: ' + TempLead.Street + ' ' + TempLead.City + ', ' + TempLead.State + ' ' + Templead.PostalCode;
            }
            update tempLead;
        } // end if Lead
        else {
            TempContact = [
                    select Id, MailingStreet, MailingCity, MailingState, MailingPostalCode, Mailing_Lists__c, AccountId, Description, Account.Description,
                            Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode
                    from Contact
                    where Id = :campmmbr.ContactId
            ];
            if (pcontact.Over_18__c == true) TempContact.Over_18__c = true;
            if (enewsletters == true) {
                TempContact.Mailing_Lists__c =
                        TempContact.Mailing_Lists__c == null ? mailing_list : TempContact.Mailing_Lists__c + ';' + mailing_list;
            }
            system.debug('TempContact mailing street is ' + TempContact.MailingStreet);
            //Only insert full address if all fields filled
            if (TempContact.MailingStreet == null && pcontact.MailingStreet != NULL && pcontact.MailingCity != NULL && pcontact.MailingState != NULL && pcontact.MailingPostalCode != NULL) {
                TempContact.MailingStreet = pcontact.MailingStreet;
                TempContact.MailingCity = pcontact.MailingCity;
                TempContact.MailingState = pContact.MailingState;
                TempContact.MailingPostalCode = pContact.MailingPostalCode;
            } else {
                if (TempContact.MailingPostalCode == null && pcontact.MailingPostalCode != null)
                    TempContact.MailingPostalCode = pContact.MailingPostalCode;
                if (TempContact.MailingStreet + TempContact.MailingCity + TempContact.MailingState + TempContact.MailingPostalCode != null)
                    TempContact.Description += 'New address submitted: ' + pcontact.MailingStreet + ' ' + pcontact.MailingCity + ', ' + pcontact.MailingState + ' ' + pcontact.MailingPostalCode;
            }
            update TempContact;
            //Only insert full address in Account if all fields filled
            If (TempContact.Account.BillingStreet == null && pcontact.MailingStreet != NULL && pcontact.MailingCity != NULL && pcontact.MailingState != NULL && pcontact.MailingPostalCode != NULL) {
                TempContact.Account.BillingStreet = pcontact.MailingStreet;
                TempContact.Account.BillingCity = pcontact.MailingCity;
                TempContact.Account.BillingState = pContact.MailingState;
                TempContact.Account.BillingPostalCode = pContact.MailingPostalCode;
            } else {
                if (TempContact.Account.BillingPostalCode == null && pcontact.MailingPostalCode != null) TempContact.Account.BillingPostalCode = pContact.MailingPostalCode;
                if (TempContact.Account.BillingStreet + TempContact.Account.BillingCity + TempContact.Account.BillingState + TempContact.Account.BillingPostalCode != null)
                    TempContact.Account.Description += 'New address submitted: ' + pcontact.MailingStreet + ' ' + pcontact.MailingCity + ', ' + pcontact.MailingState + ' ' + pcontact.MailingPostalCode;
            }
            update TempContact.Account;
        }
    }

    public CampaignMember insertCampmmbrFields(CampaignMember cm) {
        cm = campmmbr;
        cm.Status = 'Responded Yes';
        cm.Campaign_Member_Source__c = 'Web signup';
        if (selectedHearAboutActivity != null) cm.How_Heard_About_Event__c = selectedHearAboutActivity;
        if (selectedCarPooling != null) cm.Car_pooling__c = selectedCarPooling;
        if (selectedShirtSize != null) cm.Shirt_Size__c = selectedShirtSize;
        if (selectedSignupForGroup != null) cm.Group__c = selectedSignupForGroup;
        if (String.isNotBlank(pcampmmbr.Questions_or_Comments__c))
            cm.Questions_or_Comments__c = pcampmmbr.Questions_or_Comments__c;
        if (String.isNotBlank(pcampmmbr.Availability__c)) cm.Availability__c = pcampmmbr.Availability__c;
        if (String.isNotBlank(pcampmmbr.Boat__c)) cm.Boat__c = pcampmmbr.Boat__c;
        if (String.isNotBlank(pcampmmbr.Pref_Location__c)) cm.Pref_Location__c = pcampmmbr.Pref_Location__c;
        if (pcampmmbr.Special_Location_Preference__c != null) cm.Special_Location_Preference__c = pcampmmbr.Special_Location_Preference__c;
        if (String.isNotBlank(pcampmmbr.Special_Needs__c)) cm.Special_Needs__c = pcampmmbr.Special_Needs__c;
        if (String.isNotBlank(pcampmmbr.Teammates__c))cm.Teammates__c = pcampmmbr.Teammates__c;
        if (String.isNotBlank(pcampmmbr.Waders__c))cm.Waders__c = pcampmmbr.Waders__c;
        if (String.isNotBlank(pcampmmbr.Group__c))cm.Group__c = pcampmmbr.Group__c;
        if (String.isNotBlank(pcampmmbr.Emergency_Contact_Name__c))cm.Emergency_Contact_Name__c = pcampmmbr.Emergency_Contact_Name__c;
        if (String.isNotBlank(pcampmmbr.Emergency_Contact_Phone__c))cm.Emergency_Contact_Phone__c = pcampmmbr.Emergency_Contact_Phone__c;
        cm.Nr_in_Group__c = (pcampmmbr.Nr_in_Group__c == null ? cm.Nr_in_Group__c = 1 : pcampmmbr.Nr_in_Group__c);
        cm.Nr_Adults__c = (pcampmmbr.Nr_Adults__c == null ? cm.Nr_Adults__c = 1 : pcampmmbr.Nr_Adults__c);
        cm.Agreed_to_Waiver__c = AgreedToWaiver;
        cm.Which_Waiver_Agreed__c = camp.Waiver__c;
        System.debug('Just returned from insertCampaignmember with cm ' + cm);
        return cm;
    }

    public PageReference Page1() {
        showNextPage = false;
        return null;
    }

    public PageReference Page2() {
        showNextPage = true;
        return null;
    }

}
//END CONTROLLER