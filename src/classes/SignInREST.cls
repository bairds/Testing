/**
 * Created by Baird on 9/20/2018.
 */
// Jan 2018 Add Event_Date_Time field so app can order by date.  Add Waiver.
// Jan 2018 Add CMStatusValues so that app user can choose more than one.
// Apr 2018 Created map of CMStatusValues, revise Post and Put to accept them into cm.
// Apr 2018 Pull donor level, membership exp date, Agreed_To_Waiver, Member_Since to
// incorporate into app
// May 2018 Refactor, make variable names uniform,
// May 2020 Add EmergencyContactName, Phone to response
// July 2020 "without sharing"
// Oct 2020 bulkify, completely rewrite


@RestResource(urlMapping='/SignInRESTAPI/*')
global without sharing class SignInREST {

    @HttpGet
    global static void getCampaigns() {
        System.debug('Started httpget routine');
        String waiverText;
        Campaign SelectedCampaign;
        RestContext.response.addHeader('Content-Type', 'application/json');
        // Create the body of the response
        CampaignResponse CR = new CampaignResponse();
        CR.orgName = UserInfo.getOrganizationName();
        System.debug('RestContext.request is ' + RestContext.request);
        System.debug('Org_Id parameter is ' + RestContext.request.params.get('Org_Id'));
        System.debug('UserInfo.getOrganizationId is ' + UserInfo.getOrganizationId());
        if (RestContext.request.params.get('Org_Id') != null && RestContext.request.params.get('Org_Id') == UserInfo.getOrganizationId()) {
            if (RestContext.request.params.get('campaignId') == null) {
                // No ID means that this is the first step and we provide a list of campaigns
                CR.campaigns = [Select Id, Name, Event_Date_Time__c from Campaign where Event_Date_Time__c >= TODAY and IsActive = true ORDER BY Event_Date_Time__c];
            } else {
                if (RestContext.request.params.containsKey('campaignId')) {
                    String campaignId = RestContext.request.params.get('campaignId');
                    SelectedCampaign = [
                            SELECT Id, Name, Campaign.Waiver__c, Campaign.NrHoursToAssign__c, Event_Date_Time__c,
                                    Event_End_Time__c, Event_Location__c, OwnerId,Signup_Questions__c, (
                                    SELECT CampaignMember.Id, CampaignMember.FirstName,
                                            CampaignMember.LastName, CampaignMember.Email, CampaignMember.Phone, CampaignMember.Street, CampaignMember.City,
                                            CampaignMember.State, CampaignMember.PostalCode, CampaignMember.Status, CampaignMember.Send_Member_Info__c,
                                            CampaignMember.Follow_Up_Task__c, CampaignMember.Interests__c, CampaignMember.Add_To_TY_Message__c,
                                            CampaignMember.Hours__c, CampaignMember.Agreed_to_Waiver__c, CampaignMember.Invite_to_Next_Level__c,
                                            CampaignMember.Autosend_TY_Msg__c, CampaignMember.Emergency_Contact_Name__c, CampaignMember.Emergency_Contact_Phone__c,
                                            CampaignMember.ContactId, CampaignMember.Contact.FirstName,
                                            CampaignMember.Contact.LastName, CampaignMember.Contact.Email, CampaignMember.Contact.Phone,
                                            CampaignMember.Contact.MailingCity, CampaignMember.Contact.MailingState, CampaignMember.Contact.MailingCountry,
                                            CampaignMember.Contact.MailingPostalCode, CampaignMember.Contact.MailingStreet, CampaignMember.Contact.Account.Account_Membership_Expires__c,
                                            CampaignMember.Contact.Lifetime_Giving__c, CampaignMember.Contact.Account.First_Member_Date__c,
                                            CampaignMember.Contact.Vol_Event_Count__c,
                                            CampaignMember.LeadId, CampaignMember.Lead.FirstName,
                                            CampaignMember.Lead.LastName, CampaignMember.Lead.Email, CampaignMember.Lead.Phone,
                                            CampaignMember.Lead.Street, CampaignMember.Lead.City, CampaignMember.Lead.State, CampaignMember.Lead.Country,
                                            CampaignMember.Lead.PostalCode
                                    FROM Campaign.CampaignMembers
                            )
                            FROM Campaign
                            WHERE IsActive = true AND Id = :campaignId
                    ];
                    system.debug('UserId is ' + SelectedCampaign.OwnerId);
                    User Organizer = [Select Phone, Email, FirstName, LastName from User where Id = :SelectedCampaign.OwnerId];
                    If (SelectedCampaign.Waiver__c != null) WaiverText = [SELECT Body__c from Text_Document__c WHERE Id = :SelectedCampaign.Waiver__c].Body__c;
                    List<CampaignMemberWrapper> CMWs = new List<CampaignMemberWrapper>();
                    for (CampaignMember cm : SelectedCampaign.CampaignMembers) {
                        CampaignMemberWrapper cmw = new CampaignMemberWrapper();
                        cmw.campaignId = SelectedCampaign.Id;
                        cmw.recordId = cm.ContactId == null ? cm.LeadId : cm.ContactId;
                        cmw.memberId = cm.Id;
                        cmw.FirstName = cm.FirstName;
                        cmw.LastName = cm.LastName;
                        cmw.email = cm.Email;
                        cmw.phone = cm.Phone;
                        cmw.street = cm.Street;
                        cmw.city = cm.City;
                        cmw.state = cm.State;
                        cmw.zip = cm.PostalCode;
                        cmw.status = cm.Status;
                        cmw.SendMemberInfo = cm.Send_Member_Info__c;
                        cmw.FollowUpTask = cm.Follow_Up_Task__c;
                        cmw.Interests = cm.Interests__c;
                        cmw.AddToTyMessage = cm.Add_To_TY_Message__c;
                        cmw.VolunteerHours = cm.Hours__c;
                        cmw.AgreedToWaiver = cm.Agreed_to_Waiver__c;
                        cmw.InviteNextLevel = cm.Invite_to_Next_Level__c;
                        cmw.AutosendTY = cm.Autosend_TY_Msg__c;
                        cmw.VolEventCount = (Integer) cm.Contact.Vol_Event_Count__c;
                        cmw.MembershipExpires = cm.Contact.Account.Account_Membership_Expires__c;
                        cmw.DonorLevel = cm.Contact.Lifetime_Giving__c > 250 ? 'generousdonor' : 'donor';
                        cmw.MemberSince = cm.Contact.Account.First_Member_Date__c;
                        cmw.EmergencyContactName = cm.Emergency_Contact_Name__c;
                        cmw.EmergencyContactPhone = cm.Emergency_Contact_Phone__c;
                        CMWs.add(cmw);
                    }
                    CR.CMWs = CMWs;
                    // Add the campaign fields
                    If (WaiverText != null) CR.Waiver = WaiverText;
                    CR.EventLocation = SelectedCampaign.Event_Location__c;
                    CR.EventStartTime = SelectedCampaign.Event_Date_Time__c;
                    CR.EventEndTime = SelectedCampaign.Event_End_Time__c;
                    CR.OrganizerName = Organizer.FirstName == null ? Organizer.LastName : Organizer.FirstName + ' ' + Organizer.LastName;
                    CR.OrganizerPhone = Organizer.Phone;
                    CR.OrganizerEmail = Organizer.Email;
                    if (SelectedCampaign.Signup_Questions__c != null) CR.RequireEmergencyContact = SelectedCampaign.Signup_Questions__c.CONTAINS('Require Emergency Contact Info');
                    System.debug('Response is CR ' + CR);
                }
            }
            if (SelectedCampaign != null) {
                CR.CampStatValues = new List<String>();
                List<CampaignMemberStatus> CMSList = [select Label from CampaignMemberStatus where CampaignId = :SelectedCampaign.Id];
                for (CampaignMemberStatus cms : CMSList) CR.CampStatValues.add(cms.Label);
            }
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(CR, false));
        }
    }

    @HttpPost
    global static Response upsertCampaignMembers() {
        Id VolTaskRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Volunteer Task').getRecordTypeId();
        System.debug('Started httppost routine');
        WGSettings__mdt Setting = WGHelpers.getWGSettings();
        CampaignMember checkcm;
        Campaign SelectedCampaign;
        List<Opportunity> ListOpps = new List<Opportunity>();
        Response res = new Response();
        if (RestContext.request.params.get('Org_Id') != null && RestContext.request.params.get('Org_Id') == UserInfo.getOrganizationId()) {
            /*try {*/
            String body = RestContext.request.requestBody.toString();
            If (body.contains('SendThankYouEmails')) {
                SendTYTrigger STYT = (SendTYTrigger) json.deserialize(body, SendTYTrigger.class);
                if (STYT.SendThankYouEmails == true) {
                    // Process thank you emails.
                    List<CampaignMember> TYEmailRecips = [
                            SELECT ID, Firstname, Lastname, Add_To_TY_Message__c,
                                    Autosend_TY_Msg__c, Dear__c, Email, Event_Date__c, Invite_to_Next_Level__c, Send_Member_Info__c,
                                    Unsubscribed__c, AutosendTY__c
                            from CampaignMember
                            where campaignId = :STYT.CampId AND AutosendTY__c = 'send' and Email != NULL
                    ];
                    if (TYEmailRecips.size() == 0) {
                        res.statusCode = 500;
                        res.message = 'Found no campaign members with Autosend Thank You Email set to Send.  Have you already synced your changes?  Or did you already send the Thank You Emails?';
                    } else {
                        // run sendTYEmails
                        res.statusCode = 200;
                        res.message = 'Sending Thank You Emails';
                    }
                }
            } else {
                // Process all the campaign members
                // Create a list of WGErrorLog records in case they are needed
                List<WG_Error_Log__c> ListWGErrors = new List<WG_Error_Log__c>();
                //Loop through identifying and creating campaignmembers
                List<CampaignMemberWrapper> CMWs = (List<CampaignMemberWrapper>) JSON.deserialize(body, List<CampaignMemberWrapper>.class);
                If (SelectedCampaign == null)
                    SelectedCampaign = [SELECT Id, Name, Event_Date_Time__c FROM Campaign WHERE Id = :CMWs[0].campaignId];
                System.debug('CampaignId is ' + SelectedCampaign.Id);
                List<CampaignMemberWrapper> CMWsWNewContacts = new List<CampaignMemberWrapper>();
                List<Contact> NewContacts = new List<Contact>();
                List<Id> AllCMIds = new List<Id>();
                Map<String, ResponseCM> ResponseCMMap = new Map<String, ResponseCM>();
                for (CampaignMemberWrapper CMW : CMWs) {
                    // Is this a new person?  Assume it is if recordId is blank.
                    if (CMW.recordId == null) {
                        // Create a new contact, assuming this person attended the event so they donated time.
                        // Even if they did not, it won't be a problem in the database.
                        Contact ct = new Contact();
                        ct.FirstName = CMW.FirstName;
                        ct.LastName = CMW.LastName;
                        ct.Email = CMW.email;
                        ct.Phone = CMW.phone;
                        ct.MailingStreet = CMW.street;
                        ct.MailingCity = CMW.city;
                        ct.MailingState = CMW.state;
                        ct.MailingPostalCode = CMW.zip;
                        NewContacts.add(ct);
                        CMWsWNewContacts.add(CMW);
                    }
                }
                if (CMWsWNewContacts.size() > 0) {
                    List<Database.SaveResult> SaveResults = database.insert(NewContacts, false);

                    // Assume that index kept NewContacts and CMWsWNewContacts in sync
                    for (integer i = 0; i < CMWsWNewContacts.size(); i++) {
                        if (SaveResults[i].isSuccess()) {
                            CMWsWNewContacts[i].recordId = NewContacts[i].Id;
                            CMWsWNewContacts[i].AccountId = NewContacts[i].AccountId;
                        } else {
                            for (Database.Error dError : SaveResults[i].getErrors()) {
                                WG_Error_Log__c wel = new WG_Error_Log__c(
                                        Description__c = 'Save error creating New Contact in SignInREST ' + string.valueOf(system.now()) + ' ' + dError.getMessage() + '  Input was ' + CMWsWNewContacts[i],
                                        Category__c = 'Apex Code'
                                );
                                ListWGErrors.add(wel);
                            }
                        }
                    }
                }

                // Assume that all the CMWsWNewContacts also need campaignMemberId added;
                // Because how would they have memberId if they didn't also have recordId;

                List<CampaignMember> NewCMs = new List<CampaignMember>();
                for (integer i = 0; i < CMWsWNewContacts.size(); i++) {
                    CampaignMember newCM = new CampaignMember(
                            ContactId = CMWsWNewContacts[i].recordId,
                            CampaignId = SelectedCampaign.Id,
                            Status = 'Attended'
                    );
                    NewCMs.add(newCM);
                }

                if (NewCMs.size() > 0) {
                    List<Database.SaveResult> SaveResults = database.insert(NewCMs);
                    for (integer i = 0; i < CMWsWNewContacts.size(); i++) {
                        if (SaveResults[i].isSuccess()) {
                            CMWsWNewContacts[i].memberId = NewCMs[i].Id;
                        } else {
                            For (Database.Error de : SaveResults[i].getErrors()) {
                                WG_Error_Log__c wel = new WG_Error_Log__c(
                                        Description__c = 'Error trying to add new campaign member in SignInREST ' + de.getMessage(),
                                        Category__c = 'Apex Code'
                                );
                                ListWGErrors.add(wel);
                            }
                        }
                    }
                }

                // Before creating opportunities, convert any leads to contacts
                List<Id> LeadIdsToConvert = new List<Id>();
                List<CampaignMemberWrapper> CMWLeads = new List<CampaignMemberWrapper>();
                for (CampaignMemberWrapper CMW3 : CMWs) {
                    if (CMW3.VolunteerHours > 0 && CMW3.recordId.startsWith('00Q')) {
                        CMWLeads.add(CMW3);
                        LeadIdsToConvert.add(CMW3.recordId);
                    }
                    if (LeadIdsToConvert.size() > 0) {
                        // Set the convertStatus
                        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true and MasterLabel <> 'Qualified' LIMIT 1];
                        List<Database.LeadConvert> lconverts = new List<Database.LeadConvert>();
                        for (Id lTemp : LeadIdsToConvert) {
                            Database.Leadconvert lc = new Database.Leadconvert();
                            lc.setLeadId(lTemp);
                            lc.setDoNotCreateOpportunity(true);
                            lc.setConvertedStatus(convertStatus.MasterLabel);
                            lconverts.add(lc);
                        }
                        system.debug('Leads to be converted are ' + lconverts);

                        avoidRecursiveContactTrigger.setworking();
                        List<Database.LeadConvertResult> leadcresults = Database.convertLead(lconverts);
                        avoidRecursiveContactTrigger.setclosed();

                        // Loop through results, assign account and contactIds to CMWs
                        // This avoids transfering any errors
                        For (integer i = 0; i < leadcresults.size(); i++) {
                            if (leadcresults[i].isSuccess()) {
                                CMWLeads[i].AccountId = leadcresults[i].getAccountId();
                                CMWLeads[i].recordId = leadcresults[i].getContactId();
                            } else {
                                For (Database.Error de : leadcresults[i].getErrors()) {
                                    WG_Error_Log__c wel = new WG_Error_Log__c(
                                            Description__c = 'Error trying to convertLead ' + de.getMessage(),
                                            Category__c = 'Apex Code'
                                    );
                                    ListWGErrors.add(wel);
                                }
                            }
                        }
                    }
                }

                // Now all CampaignMemberWrappers have memberIds and recordIds;
                for (CampaignMemberWrapper CMW1 : CMWs) {
                    // Now, finally I can create full list of CM.Ids;
                    Try {
                        AllCMIds.add(CMW1.memberId);
                    } catch (Exception e) {
                        WG_Error_Log__c wel = new WG_Error_Log__c(
                                Description__c = 'Error trying to create list of campaignMemberIds ' + string.valueOf(e.getMessage()),
                                Category__c = 'Apex Code'
                        );
                        ListWGErrors.add(wel);
                    }
                }

                Map<id, CampaignMember> CMMap = new Map<id, CampaignMember>([
                        SELECT Id,FirstName,LastName,ContactId,
                                LeadId,Status,Nr_in_Group__c,Campaign_Member_Source__c,Follow_Up_Task__c,Interests__c,
                                Add_To_TY_Message__c,Hours__c,HoursValue__c,TempAndroidId__c,Invite_to_Next_Level__c,
                                Agreed_to_Waiver__c,AutosendTY__c,Autosend_TY_Msg__c,Emergency_Contact_Name__c,
                                Emergency_Contact_Phone__c
                        from CampaignMember
                        where Id IN:AllCMIds
                ]);

                List<CampaignMember> CMsToUpdate = new List<CampaignMember>();
                for (CampaignMemberWrapper CMW2 : CMWs) {
                    if (CMW2.memberID instanceOf Id) {
                        // Update campaign member;
                        // the status will be Attended for new campaign members via App
                        CMMap.get(CMW2.memberId).Status = CMW2.status;
                        CMMap.get(CMW2.memberId).Nr_in_Group__c = 1; // Each person entered in the SignInApp is just one person, not a group
                        // it is manually added from App
                        CMMap.get(CMW2.memberId).Campaign_member_Source__c = 'From WG Signin mobile app';
                        // holds the result of CMW creation
                        if (CMW2.SendMemberInfo != null) CMMap.get(CMW2.memberId).Send_Member_Info__c = CMW2.SendMemberInfo;
                        CMMap.get(CMW2.memberId).Follow_Up_Task__c = CMW2.FollowUpTask;
                        CMMap.get(CMW2.memberId).Interests__c = CMW2.Interests;
                        if (CMW2.AddToTyMessage != null) CMMap.get(CMW2.memberId).Add_To_TY_Message__c = CMW2.AddToTyMessage.capitalize();
                        if (CMW2.VolunteerHours != null) CMMap.get(CMW2.memberId).Hours__c = CMW2.VolunteerHours;
                        system.debug('Setting.HourlyVolunteerRate__c is' + Setting.HourlyVolunteerRate__c);
                        if (CMW2.VolunteerHours != null && Setting.HourlyVolunteerRate__c != null) CMMap.get(CMW2.memberId).HoursValue__c = CMMap.get(CMW2.memberId).Hours__c * Setting.HourlyVolunteerRate__c;
                        if (CMW2.tempId != null) CMMap.get(CMW2.memberId).TempAndroidId__c = CMW2.tempId;
                        system.debug('CMW2.InviteNextLevel is ' + CMW2.InviteNextLevel);
                        if (CMW2.InviteNextLevel == true) CMMap.get(CMW2.memberId).Invite_to_Next_Level__c = CMW2.InviteNextLevel;
                        if (CMW2.AgreedToWaiver != null) CMMap.get(CMW2.memberId).Agreed_to_Waiver__c = CMW2.AgreedToWaiver;
                        if (CMW2.AutosendTY == true) CMMap.get(CMW2.memberId).AutosendTY__c = 'send';
                        if (CMW2.EmergencyContactName != null) CMMap.get(CMW2.memberId).Emergency_Contact_Name__c = CMW2.EmergencyContactName;
                        if (CMW2.EmergencyContactPhone != null) CMMap.get(CMW2.memberId).Emergency_Contact_Phone__c = CMW2.EmergencyContactPhone;
                        CMMap.get(CMW2.memberId).Request_Body__c = String.valueOf(CMW2);
                        system.debug('After loading data cm is now ' + CMMap.get(CMW2.memberId));
                        system.debug('Just set cm.Request_Body__c to ' + CMMap.get(CMW2.memberId).Request_Body__c);
                        CMsToUpdate.add(CMMap.get(CMW2.memberId));
                    }
                }
                Update CMsToUpdate;

                for (CampaignMemberWrapper CMW4 : CMWs) {
                    if (CMW4.VolunteerHours > 0) {
                        // Convert lead if necessary
                        Id ConvertedAccountId;
//                        if (cm.ContactId == null) {
//                            List<Id> Results = ConvertLeadToContact.ConvertLeadToContact(cm.LeadId);
//                            // cm.ContactId = Results[0];
//                            ConvertedAccountId = Results[1];
//                        } // end conversion of lead
                        String Oppname = CMW4.FirstName + ' ' + CMW4.LastName;
                        System.debug('Oppname is ' + Oppname);
                        System.debug('SelectedCampaign.name is ' + SelectedCampaign.Name);
                        System.debug('SelectedCampaign.Event_Date_Time__c.date() is ' + SelectedCampaign.Event_Date_Time__c.date());
                        Opportunity newOpp = new Opportunity(
                                Name = Oppname + ' ' + SelectedCampaign.Event_Date_Time__c.format('yyyy MMM dd') + ' ' + SelectedCampaign.Name,
                                Hours_Actual__c = CMW4.VolunteerHours,
                                CloseDate = SelectedCampaign.Event_Date_Time__c.date(),
                                StageName = 'Completed',
                                Contact__c = CMW4.recordId,
                                CampaignId = SelectedCampaign.Id,
                                AccountId = CMW4.AccountId,
                                RecordTypeId = VolTaskRTID);
                        ListOpps.add(newOpp);
                    }
                    insert ListOpps;

                    //Prepare response to app
                    ResponseCM cmr = new ResponseCM();
                    cmr.memberId = CMW4.memberId;
                    // WHAT SHOULD I DO IF THE MEMBERID FROM THE STRING IS BAD?
                    cmr.recordType = 'Contact';
                    cmr.SendMemberInfo = CMW4.SendMemberInfo != null ? CMW4.SendMemberInfo : null ;
                    cmr.AutosendTY = CMW4.AutosendTY != null ? CMW4.AutosendTY : null ;
                    cmr.AgreedToWaiver = CMW4.AgreedToWaiver != null ? CMW4.AgreedToWaiver : null ;
                    cmr.FollowUpTask = CMW4.FollowUpTask;
                    cmr.Interests = CMW4.Interests;
                    cmr.AddToTyMessage = CMW4.AddToTyMessage;
                    cmr.InviteNextLevel = CMW4.InviteNextLevel;
                    cmr.VolunteerHours = CMW4.VolunteerHours;
                    cmr.tempId = CMW4.tempId;
                    cmr.Status = CMW4.status;
                    cmr.campaignId = SelectedCampaign.Id;
                    if (CMW4.memberID instanceOf Id) {
                        cmr.recordId = CMMap.get(CMW4.memberId).ContactId == null ? CMMap.get(CMW4.memberId).LeadId : CMMap.get(CMW4.memberId).ContactId;
                        ResponseCMMap.put(CMMap.get(CMW4.memberId).Id, cmr);
                    }
                } // end loop through members

                res.statusCode = 200;
                res.message = 'OK';
                res.cmrMap = ResponseCMMap;
                System.debug('Assigning result to map. Results sent back to app is now ' + res);
                /* } catch (DmlException ex) {
            res.statusCode = 500;
            res.message = ex.getMessage();
            System.debug('##### --> ' + ex.getMessage());
        } catch (Exception ex) {
            res.statusCode = 500;
            res.message = ex.getMessage();
            System.debug('##### --> ' + ex.getMessage());
        }*/
                System.debug('POST returns response: ' + res);
                insert ListWGErrors;
            }
        }
        return res;
    }


// generic response wrapper
global class Response {
// status code
public Integer statusCode;
// message
public String message;
// map to wrap result of all create requests
public Map<String, ResponseCM> cmrMap;
}

// holder for result of create request for campaign member
global class ResponseCM {
// id from Android
public String tempId;
// campaign id
public String campaignId;
// contact or lead Id
public String recordId;
// campaignMemberId
public String memberId;
// whether it is lead or contact
public String recordType;
// status
public String Status;
public Boolean SendMemberInfo;
public String FollowUpTask;
public String Interests;
public String AddToTyMessage;
public Double VolunteerHours;
public Boolean AgreedToWaiver;
public Boolean InviteNextLevel;
public Boolean AutosendTY;
}

global class CampaignMemberWrapper {
public String campaignId;
public String recordId; // for contactId or LeadId
public String AccountId;
public String memberId;
public String tempId;
public String FirstName;
public String LastName;
public String email;
public String phone;
public String street;
public String city;
public String state;
public String zip;
public String status;
public Boolean SendMemberInfo;
public String FollowUpTask;
public String Interests;
public String AddToTyMessage;
public Double VolunteerHours;
public Boolean AgreedToWaiver;
public Boolean InviteNextLevel;
public Boolean AutosendTY;
public Integer VolEventCount;
public Date MembershipExpires;
public String DonorLevel;
public Date MemberSince;
public String EmergencyContactName;
public String EmergencyContactPhone;
public String WaiverText;
public String SignaturePDF;
}

global class CampaignResponse {
public String orgName;
public List<Campaign> campaigns;
public List<CampaignMemberWrapper> CMWs;
public String Photo_Service_URL;
public String Waiver;
public List<String> CampStatValues;
public Double NrHoursToAssign;
public Boolean RequestEvaluation;
public String OrganizerName;
public String OrganizerPhone;
public String OrganizerEmail;
Public String EventLocation;
Public Datetime EventStartTime;
Public Datetime EventEndTime;
Public Boolean RequireEmergencyContact;
}

global class SendTYTrigger {
public Boolean SendThankYouEmails;
public String CampId;
}

}