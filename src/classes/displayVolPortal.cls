/**
 * Created by Baird on 6/12/2020.
 */

public with sharing class displayVolPortal {

    public Contact ctct { get; set; }
    public List<Opportunity> VolTasks { get; set; }
    public List<String> ListOfOne { get; set; }
    public Decimal VolHoursAll { get; set; }
    public Decimal VolHoursThisYear { get; set; }
    Public decimal VolMilesAll { get; set; }
    Public decimal VolMilesThisYear { get; set; }
    Public GuestUserUpdate__c GUU { get; set; }
    public string editmode { get; set; }
    public Boolean URLCorrect { get; set; }
    public string VToken { get; set; }
    public string OrgName { get; set; }
    public List<Campaign> VolInterestCamps { get; set; }
    public List<CampEx> VolInterestCampExs { get; set; }
    public string JSONVICExs { get; set; }
    public Map<Id, CampEx> CampToExtendedCampMap { get; set; }
    public string JSONCTECs { get; set; }
    public Map<Id, CampaignMember> CMMap { get; set; }
    Public string MyString_From_Methode { get; set; }
    Public Opportunity Opp { get; set; }
    Public Boolean HasSubmittedTasks { get; set; }
    Public List<Opportunity> SubmittedTasks { get; set; }
    Public String st;
    Public Map<String, Schema.SObjectField> FieldSetWDescriptionMap { get; set; }
    Public Boolean HasUnprocessedGUUs {get; set;}
    public Id VolTaskRTID;

    public displayVolPortal() {
        Opp = new Opportunity();
        OrgName = UserInfo.getOrganizationName();
        id cid = ApexPages.currentPage().getParameters().get('cid');
        VToken = apexPages.currentPage().getParameters().get('VToken');
        VolTaskRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Volunteer Task').getRecordTypeId();
        ctct = [
                SELECT id, firstname, lastname, mailingstreet, mailingPostalCode, mailingcity,
                        mailingstate, mailingcountry,email,MobilePhone,HomePhone,Phone,VolToken__c, AccountId
                from Contact
                where id = :cid
        ];
        if (VToken != ctct.VolToken__c) {
            URLCorrect = false;
        } else {
            URLCorrect = true;
        }
        // If this is the first submission
        system.debug('In constructor, before testing whether GuU is null, GUU is ' + GUU);
        if (GUU == null) {
            GUU = new GuestUserUpdate__c(
                    firstname__c = ctct.firstname,
                    lastname__c = ctct.lastname,
                    mailingstreet__c = ctct.mailingstreet,
                    mailingcity__c = ctct.mailingcity,
                    mailingstate__c = ctct.mailingstate,
                    mailingpostalcode__c = ctct.mailingpostalcode,
                    mailingcountry__c = ctct.mailingcountry,
                    email__c = ctct.email,
                    mobilephone__c = ctct.mobilephone,
                    homephone__c = ctct.homephone,
                    phone__c = ctct.phone,
                    RelatedContact__c = ctct.Id
            );
        }
        // Otherwise use the existing GUU

        // Are there already unprocessed GUUs?
        List<GuestUserUpdate__c> UnprocessedGUUs = [SELECT Id from GuestUserUpdate__c
        WHERE Processing_Status__c = 'Review' and RelatedContact__c =: ctct.Id];
        If (UnprocessedGUUs.size() > 0) HasUnprocessedGUUs = true;

        // VolTasks = new List<Opportunity>();
        ListOfOne = new List<String>();
        ListOfOne.add('Only one item');
        VolHoursAll = 0;
        VolHoursThisYear = 0;
        VolMilesAll = 0;
        VolMilesThisYear = 0;
        VolTasks = [
                SELECT id, name,Hours_Actual__c,Miles_Driven__c,CloseDate,RecordTypeId,Description,Supervisor_Satisfaction__c,
                        CampaignId, Campaign.Name, Type
                from Opportunity
                where RecordTypeId = :VolTaskRTID AND Contact__c = :cid
                AND IsClosed = TRUE AND IsWon = TRUE
        ];
        system.debug('Found ' + VolTasks.size() + ' volunteer tasks.');
        for (Opportunity o : VolTAsks) {
            if (o.Hours_Actual__c > 0) VolHoursAll += o.Hours_Actual__c;
            if (o.Hours_Actual__c > 0) VolHoursThisYear = o.CloseDate.Year() == system.now().Year() ? VolHoursThisYear + o.Hours_Actual__c : VolHoursThisYear;
            if (o.Miles_Driven__c > 0) VolMilesAll += o.Miles_Driven__c;
            if (o.Miles_Driven__c > 0) VolMilesThisYear = o.CloseDate.Year() == system.now().Year() ? VolMilesThisYear + o.MIles_Driven__c : VolMilesThisYear;
            // VolTasks.add(opp);aaaaaaa
        }
        editMode = 'display';
        // Find tasks that have been submitted but not approved

        SubmittedTasks = [
                SELECT Id, Date_and_Time_Start__c, Date_and_Time_End__c, Description, Campaign_Guess__c,
                        Contact__r.FirstName, Contact__r.LastName,Hours_Actual__c,Contact__c,
                        Type
                from Opportunity
                WHERE (Contact__c = :ctct.Id AND StageName = 'Task Submitted' and Type = 'Self-reported Vol Task')
        ];
        If (SubmittedTasks.size() > 0) HasSubmittedTasks = true;
        // Query for Volunteer Interest Signup Campaigns
        VolInterestCampExs = new List<CampEx>();
        Id SignupRTID = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Signup').getRecordTypeId();
        VolInterestCamps = [
                SELECT Id, Description, Name, Type, Signup_Image__c, Register_Page_Message__c, (
                        SELECT Unsubscribed__c,Id,Status
                        from CampaignMembers
                        WHERE ContactId = :cid
                )
                from Campaign
                where RecordTypeId = :SignupRTID AND
                Type = 'Volunteer Interest' AND IsActive = TRUE
        ];
        System.debug('VolInterestCamps includes ' + VolInterestCamps);
        CMMap = new Map<Id, CampaignMember>();
        CampToExtendedCampMap = new Map<Id, CampEx>();
        For (Campaign c : VolInterestCamps) {
            If (c.CampaignMembers.size() == 0) {
                CampEx cex = new CampEx(c, null, null, null);
                VolInterestCampExs.add(Cex);
                CampToExtendedCampMap.put(c.Id, Cex);
            } else {
                CampEx cex = new CampEx(
                        c,
                        c.CampaignMembers[0].Id,
                        c.CampaignMembers[0].Unsubscribed__c == true ? 'unsubscribed' : 'registered',
                        null);
               VolInterestCampExs.add(Cex);
                CampToExtendedCampMap.put(c.Id, Cex);
                CMMap.put(c.CampaignMembers[0].Id, c.CampaignMembers[0]);
            }
        }
        JSONVICExs = json.SERIALIZE(CampToExtendedCampMap.values());
        JSONCTECs = json.SERIALIZE(CampToExtendedCampMap);

        // List<Schema.FieldSetMember> fields = Schema.SObjectType.GUUTask__c.fieldsets.getMap().get('VolTaskFieldSet').getFields();
        // if (fields.size()>0) FieldSetWDescriptionMap = WgHelpers.FieldSetWDescription('GUUTask__c','VolTaskFieldSet');
    }

    public pageReference editContactInfo() {
        editmode = 'editContactInfo';
        return null;
    }

    public pageReference submitContactInfo() {
        // Only if there's a change made
        if (!(
                GUU.firstname__c == ctct.firstname &&
                        GUU.lastname__c == ctct.lastname &&
                        GUU.mailingstreet__c == ctct.mailingstreet &&
                        GUU.mailingcity__c == ctct.mailingcity &&
                        GUU.mailingstate__c == ctct.mailingstate &&
                        GUU.mailingpostalcode__c == ctct.mailingpostalcode &&
                        GUU.mailingcountry__c == ctct.mailingcountry &&
                        GUU.email__c == ctct.email &&
                        GUU.mobilephone__c == ctct.mobilephone &&
                        GUU.homephone__c == ctct.homephone &&
                        GUU.phone__c == ctct.phone &&
                        GUU.RelatedContact__c == ctct.Id
        )) {
            GUU.PageSource__c = 'UpdateContactInfo';
            GUU.RelatedContact__c = ctct.Id;
            upsert GUU;
            editMode = 'display';
        }
        return null;
    }

    public pageReference cancelEditContactInfo() {
        editMode = 'display';
        return null;
    }

    public pageReference setCMStatus() {
        string st = apexpages.currentPage().getParameters().get('firstParam');
        system.debug('In apex string passed in is ' + st);
        Map<Id, CampEx> CMExMap = (Map<Id, CampEx>) JSON.deserialize(st, Map<Id, CampEx>.class);
        List<CampaignMember> UpdateCMs = new List<CampaignMember>();
        for (CampEx cx : CMExMap.values()) {
            system.debug('CampEx is ' + cx);
            // ONLY PROCESS CX IF FINAL STATUS HAS BEEN SET
            if (cx.FinalStatus != null) {
                If (cx.FinalStatus == 'registered') {
                    If (cx.CMId == null) {
                        CampaignMember newCM = new CampaignMember(
                                status = 'Responded Yes',
                                ContactId = ctct.Id,
                                CampaignId = cx.camp.Id);
                                insert newCm;
                        cx.CMId = newCM.Id;
                        // RESET INITIAL AND FINAL STATUS TO BE READY FOR NEXT CHANGE
                        cx.InitialStatus = 'registered';
                        cx.FinalStatus = null;
                    } else {
                        // Get the campaignMember from the CMExMap, update it
                        CampaignMember newCM = new CampaignMember(
                                status = 'Responded Yes',
                                ContactId = ctct.Id,
                                Id = cx.CMId,
                                Unsubscribed__c = false,
                                CampaignId = cx.camp.Id);
                        // RESET INITIAL AND FINAL STATUS TO BE READY FOR NEXT CHANGE
                        cx.InitialStatus = 'registered';
                        cx.FinalStatus = null;
                        UpdateCMs.add(newCM);
                    }
                } else {
                    if (cx.FinalStatus == 'unregistered'){
                        // Don't add them to the campaign
                        continue;
                    } else {
                        // FinalStatus is Unsubscribed
                        if (cx.FinalStatus == 'unsubscribed') {
                            CampaignMember newCM = new CampaignMember(
                                    status = 'Unsubscribed',
                                    ContactId = ctct.Id,
                                    Id = cx.CMId,
                                    CampaignId = cx.camp.Id,
                                    Unsubscribed__c = true);
                            // RESET INITIAL AND FINAL STATUS TO BE READY FOR NEXT CHANGE
                            cx.InitialStatus = 'unsubscribed';
                            cx.FinalStatus = null;
                            UpdateCMs.add(newCM);
                        }
                    }
                }
            }
            CampToExtendedCampMap.put(cx.camp.Id, Cx);
            system.debug('CampToExtendedCampMap is ' + campToExtendedCampMap);
            system.debug('UpdateCMs is ' + UpdateCMs);
        }
        Upsert UpdateCMs;
        JSONVICExs = json.SERIALIZE(CampToExtendedCampMap.values());
        JSONCTECs = json.SERIALIZE(CMExMap);
        return null;
    }

    public pageReference SubmitVolTask() {
        Opp.RecordTypeId = VolTaskRTId;
        Opp.Contact__c = ctct.Id;
                Opp.AccountId = ctct.AccountId;
                Opp.CampaignId = WGHelpers.getUnknownCampaignId();
                Opp.StageName = 'Task Submitted';
                Opp.Type = 'Self-reported Vol Task';
                Opp.CloseDate = system.today();
                Opp.Name = Ctct.Firstname + ' ' + Ctct.Lastname + ', ' + Opp.Hours_Actual__c + ' hours submitted on ' + Opp.CloseDate.format();
        // Because Im referencing the related contact info, has to save without sharing
        withoutSharingDMLs.SaveOpportunity(Opp);
        // Update SubmittedTasks
        SubmittedTAsks = withoutSharingDMLs.getListSubmittedTasks(Ctct.Id);
/*
        SubmittedTasks = [
                SELECT Id, Date_and_Time_Start__c, Date_and_Time_End__c, Description, Campaign_Guess__c,
                        Contact__r.FirstName, Contact__r.LastName,Hours_Actual__c,Contact__c
                from Opportunity
                WHERE (Contact__c = :ctct.Id AND StageName = 'Task Submitted')
        ];
*/
        If (SubmittedTasks.size() > 0) HasSubmittedTasks = true;
        // Clear the fields for the next Volunteer Task
        Opp.clear();
        return null;
    }

    public class CampEx {
        public campaign camp;
        Id CMId;
        String InitialStatus;
        public String FinalStatus;

        public CampEx(Campaign c, Id CampMmbrId, String InitStatus, String FinStatus) {
            camp = c;
            CMId = CampMmbrId;
            InitialStatus = InitStatus;
            FinalStatus = FinStatus;
        }
    }
}