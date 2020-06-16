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

@RestResource(urlMapping='/SignInRESTAPI2/*')
global with sharing class SignInREST2 {

    @HttpGet
    global static void getCampaigns() {
        System.debug('Started httpget routine');
        Campaign SelectedCampaign;
        RestContext.response.addHeader('Content-Type', 'application/json');
        // Create the body of the response
        CampaignResponse CR = new CampaignResponse();
        CR.orgName = UserInfo.getOrganizationName();
        System.debug('RestContext.request is ' + RestContext.request);
        System.debug('Org_Id parameter is ' + RestContext.request.params.get('Org_Id'));
        System.debug('UserInfo.getOrganizationId is ' + UserInfo.getOrganizationId());
        if (RestContext.request.params.get('Org_Id') != null && RestContext.request.params.get('Org_Id') == UserInfo.getOrganizationId()) {
            if (RestContext.request.params.get('campaignId')==null) {
                // No ID means that this is the first step and we provide a list of campaigns
                CR.campaigns = [Select Id, Name, Event_Date_Time__c from Campaign where Event_Date_Time__c>=TODAY and IsActive=true ORDER BY Event_Date_Time__c];
            } else {
                if (RestContext.request.params.containsKey('campaignId')) {
                    String campaignId = RestContext.request.params.get('campaignId');
                    SelectedCampaign = [SELECT Id, Name, Campaign.Waiver__c, Campaign.NrHoursToAssign__c, Event_Date_Time__c, Event_End_Time__c, Event_Location__c, OwnerId,
                    (SELECT CampaignMember.Id, CampaignMember.FirstName,
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
                            CampaignMember.Lead.PostalCode FROM Campaign.CampaignMembers)
                    FROM Campaign WHERE IsActive = true AND Id = :campaignId];
                    system.debug('UserId is ' + SelectedCampaign.OwnerId);
                    User Organizer = [Select Phone, Email, FirstName, LastName from User where Id =: SelectedCampaign.OwnerId];
                    List<CampaignMemberWrapper> CMWs = new List<CampaignMemberWrapper>();
                    for (CampaignMember cm : SelectedCampaign.CampaignMembers)
                    {
                        CampaignMemberWrapper cmw = new CampaignMemberWrapper();
                        cmw.campaignId = SelectedCampaign.Id;
                        cmw.recordId = cm.ContactId==null ? cm.LeadId : cm.ContactId;
                        cmw.memberId = cm.Id;
                        cmw.firstName = cm.FirstName;
                        cmw.lastName = cm.LastName;
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
                        cmw.VolEventCount = (Integer)cm.Contact.Vol_Event_Count__c;
                        cmw.MembershipExpires = cm.Contact.Account.Account_Membership_Expires__c;
                        cmw.DonorLevel = cm.Contact.Lifetime_Giving__c > 250 ? 'generousdonor' : 'donor';
                        cmw.MemberSince = cm.Contact.Account.First_Member_Date__c;
                        cmw.EmergencyContactName = cm.Emergency_Contact_Name__c;
                        cmw.EmergencyContactPhone = cm.Emergency_Contact_Phone__c;
                        CMWs.add(cmw);
                    }
                    CR.CMWs = CMWs;
                    CR.Waiver = SelectedCampaign.Waiver__c;
                    CR.EventLocation= SelectedCampaign.Event_Location__c;
                    CR.EventStartTime = SelectedCampaign.Event_Date_Time__c;
                    CR.EventEndTime = SelectedCampaign.Event_End_Time__c;
                    CR.OrganizerName = Organizer.FirstName == null ? Organizer.LastName : Organizer.FirstName + ' ' + Organizer.LastName;
                    CR.OrganizerPhone = Organizer.Phone;
                    CR.OrganizerEmail = Organizer.Email;
                    System.debug('Response is CR ' + CR);
                }
            }
            if (SelectedCampaign != null) {
                CR.CampStatValues = new List<String>();
                List<CampaignMemberStatus> CMSList = [select Label from CampaignMemberStatus where CampaignId = :SelectedCampaign.Id];
                for (CampaignMemberStatus cms : CMSList) CR.CampStatValues.add(cms.Label);
            }
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(CR, false) );
        }
    }

    @HttpPost
    global static Response upsertCampaignMembers() {
        System.debug('Started httppost routine');
        WGSettings__mdt Setting = WGHelpers.getWGSettings();
        CampaignMember checkcm;
        Campaign SelectedCampaign;
        Id ConvertedAccountId;
        List<Opportunity> ListOpps = new List<Opportunity>();
        Response res = new Response();
        if (RestContext.request.params.get('Org_Id') != null && RestContext.request.params.get('Org_Id') == UserInfo.getOrganizationId()) {
            /*try {*/
                String body = RestContext.request.requestBody.toString();
                List<CampaignMemberWrapper> members = (List<CampaignMemberWrapper>) JSON.deserialize(body, List<CampaignMemberWrapper>.class);
                Map<String, ResponseCM> ResponseCMMap = new Map<String, ResponseCM>();
                for(CampaignMemberWrapper member : members) {
                    System.debug('member is ' + member);
                    CampaignMember cm = new CampaignMember();
                    System.debug('CAmpaignMemberWrapper member is ' + member);
                    // fetch campaign
                    If (SelectedCampaign==null) SelectedCampaign = [SELECT Id, Name, Event_Date_Time__c FROM Campaign WHERE Id =: member.campaignId];
                    // Does person already exist in campaign?  If not, identify them and create a campaign member record
                    if (member.memberId!= null) {
                        try {
                            checkcm = [select Id, ContactId, Contact.AccountId, Contact.FirstName, Contact.LastName, LeadId, CampaignId, AutosendTY__c from CampaignMember where Id = :member.memberId];
                        } catch(QueryException qe){
                            checkcm=null;
                        }
                    }
                    if (member.memberId==null || checkcm==null) {
                        Contact ct = new Contact();
                        ct.FirstName = member.firstName;
                        ct.LastName = member.lastName;
                        ct.Email = member.email;
                        ct.Phone = member.phone;
                        ct.MailingStreet = member.street;
                        ct.MailingCity = member.city;
                        ct.MailingState = member.state;
                        ct.MailingPostalCode = member.zip;
                        // identify or create a contact or lead
                        String[] gotResult = identifyOrCreatePerson.identifyorCreatePerson(ct);
                        // If a lead convert to contact
                        if(gotResult[1] == 'Lead') {
                            List<Id> results = ConvertLeadToContact.ConvertLeadToContact(gotResult[0]);
                            gotResult[0] = results[0];
                            ConvertedAccountId = Results[1];
                        }
                        // insert campaignmember
                        system.debug('Line 152, new campaign member Id is ' + gotResult[0]);
                        CampaignMember newcm = new CampaignMember(
                                CampaignId = SelectedCampaign.Id,
                                ContactId = gotResult[0]);
                        insert newcm;
                        cm = newcm;
                    } else {
                        cm = checkcm;
                    }
                    // Update campaign member;
                    // the status will be Attended for new campaign members via App
                    cm.Status = member.status;
                    cm.Nr_in_Group__c = 1; // Each person entered in the SignInApp is just one person, not a group
                    // it is manually added from App
                    cm.TempAndroidId__c = member.tempId;
                    cm.Campaign_Member_Source__c = 'From WG Signin App';
                    // holds the result of member creation
                    if (member.SendMemberInfo!=null) cm.Send_Member_Info__c = member.SendMemberInfo;
                    cm.Follow_Up_Task__c = member.FollowUpTask;
                    cm.Interests__c = member.Interests;
                    cm.Add_To_TY_Message__c = member.AddToTyMessage;
                    if (member.VolunteerHours != null) cm.Hours__c = member.VolunteerHours;
                    system.debug('Setting.HourlyVolunteerRate__c is' + Setting.HourlyVolunteerRate__c);
                    if (member.VolunteerHours != null && Setting.HourlyVolunteerRate__c != null) cm.HoursValue__c = cm.Hours__c*Setting.HourlyVolunteerRate__c;
                    cm.TempAndroidId__c = member.tempId;
                    system.debug('Member.InviteNextLevel is ' + Member.InviteNextLevel);
                    if (member.InviteNextLevel == true) cm.Invite_to_Next_Level__c = member.InviteNextLevel;
                    if (member.AgreedToWaiver != null) cm.Agreed_to_Waiver__c = member.AgreedToWaiver;
                    if (member.AutosendTY == true) cm.AutosendTY__c = 'send';
                    if (member.EmergencyContactName != null) cm.Emergency_Contact_Name__c = member.EmergencyContactName;
                    if (member.EmergencyContactPhone != null) cm.Emergency_Contact_Phone__c = member.EmergencyContactPhone;
                    cm.Request_Body__c = String.valueOf(member);
                    system.debug('Just set cm.Request_Body__c to ' + cm.Request_Body__c);

                    update cm;

                    //Insert contribution
                    if (cm.Hours__c > 0) {
                        // Convert lead if necessary
                        // Id ConvertedAccountId;
                        // SHOULD HAVE BEEN CONVERTED ALREADY
                        if (cm.ContactId == null) {
                            List<Id> Results = ConvertLeadToContact.ConvertLeadToContact(cm.LeadId);
                            // cm.ContactId = Results[0];
                            ConvertedAccountId = Results[1];
                        } // end conversion of lead
                        String Oppname = member.lastName == null ? cm.Contact.FirstName + ' ' + cm.Contact.LastName : member.firstName + ' ' + member.lastName;
                        System.debug('Oppname is ' + Oppname);
                        System.debug('SelectedCampaign.name is ' + SelectedCampaign.Name);
                        System.debug('SelectedCampaign.Event_Date_Time__c.date() is ' + SelectedCampaign.Event_Date_Time__c.date());
                        Opportunity newOpp = new Opportunity(
                                Name = Oppname + ' ' + SelectedCampaign.Event_Date_Time__c.format('yyyy MMM dd') + ' ' + SelectedCampaign.Name,
                                Hours_Actual__c = member.VolunteerHours,
                                CloseDate = SelectedCampaign.Event_Date_Time__c.date(),
                                StageName = 'Completed',
                                Contact__c = cm.ContactId,
                                CampaignId = SelectedCampaign.Id,
                                AccountId = ConvertedAccountId == null ? cm.Contact.AccountId : ConvertedAccountId,
                                RecordTypeId=[select Id from RecordType where Name = 'Volunteer Task'].Id);
                        ListOpps.add(newOpp);
                    }


                    //Prepare response to app
                    ResponseCM cmr = new ResponseCM();
                    cmr.memberId = cm.Id;
                    cmr.recordId = cm.ContactId==null ? cm.LeadId : cm.ContactId;
                    cmr.recordType = 'Contact';
                    cmr.SendMemberInfo = member.SendMemberInfo != null ? member.SendMemberInfo : null ;
                    cmr.AutosendTY = member.AutosendTY != null ? member.AutosendTY : null ;
                    cmr.AgreedToWaiver = member.AgreedToWaiver != null ? member.AgreedToWaiver : null ; // Baird tells Mudit to ignore this field
                    cmr.FollowUpTask = member.FollowUpTask;
                    cmr.Interests = member.Interests;
                    cmr.AddToTyMessage = member.AddToTyMessage;
                    cmr.InviteNextLevel = member.InviteNextLevel;
                    cmr.VolunteerHours = member.VolunteerHours;
                    cmr.tempId = member.tempId;
                    cmr.Status = member.status;
                    cmr.campaignId = SelectedCampaign.Id;
                    ResponseCMMap.put(cm.Id,cmr);

                } // end loop through members
                Insert ListOpps;
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
        public String memberId;
        public String tempId;
        public String firstName;
        public String lastName;
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
    }

}