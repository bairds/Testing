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
    public Map<Id,CampaignMember> CMMap {get; set;}
    Public string MyString_From_Methode{get;set;}
    Public GUUTask__c GUUT {get; set;}
    Public Boolean HasSubmittedTasks {get; set;}
    Public List<GuUTask__c> SubmittedTasks {get; set;}
    Public String st;

    public displayVolPortal() {
        OrgName = UserInfo.getOrganizationName();
        id cid = ApexPages.currentPage().getParameters().get('cid');
        VToken = apexPages.currentPage().getParameters().get('VToken');
        ctct = [
                SELECT id, firstname, lastname, mailingstreet, mailingPostalCode, mailingcity,
                        mailingstate, mailingcountry,email,MobilePhone,HomePhone,Phone,VolToken__c
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
        if (GUU==null) {
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
        GUUT = new GUUTask__c();

        // VolTasks = new List<Opportunity>();
        ListOfOne = new List<String>();
        ListOfOne.add('Only one item');
        VolHoursAll = 0;
        VolHoursThisYear = 0;
        VolMilesAll = 0;
        VolMilesThisYear = 0;
        Id VolTaskRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Volunteer Task').getRecordTypeId();
        VolTasks = [SELECT id, name,Hours_Actual__c,Miles_Driven__c,CloseDate,RecordTypeId,Description,Supervisor_Satisfaction__c,
                CampaignId, Campaign.Name from Opportunity
                where RecordTypeId = :VolTaskRTID AND Contact__c = :cid
        ];
        system.debug('Found ' + VolTasks.size() + ' volunteer tasks.');
        for (Opportunity opp : VolTAsks) {
            if (opp.Hours_Actual__c > 0) VolHoursAll += opp.Hours_Actual__c;
            if (opp.Hours_Actual__c > 0) VolHoursThisYear = opp.CloseDate.Year() == system.now().Year() ? VolHoursThisYear + opp.Hours_Actual__c : VolHoursThisYear;
            if (opp.Miles_Driven__c > 0) VolMilesAll += opp.Miles_Driven__c;
            if (opp.Miles_Driven__c > 0) VolMilesThisYear = opp.CloseDate.Year() == system.now().Year() ? VolMilesThisYear + opp.MIles_Driven__c : VolMilesThisYear;
            // VolTasks.add(opp);
        }
        editMode = 'display';
        // Find tasks that have been submitted but not approved

        SubmittedTasks= [SELECT Id, Date_and_Time__c, Date_and_Time_Ended__c, Description__c, Campaign_Text__c,
                GuestUserUPdate__c,Hours__c,GuestUserUpdate__r.RelatedContact__c from GUUTask__c
        WHERE GuestUserUpdate__r.RelatedContact__c =: ctct.Id];
        If (SubmittedTasks.size()>0) HasSubmittedTasks=true;
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
                Type = 'Volunteer Interest'
        ];
        System.debug('VolInterestCamps includes ' + VolInterestCamps);
        CMMap = new Map<Id,CampaignMember>();
        CampToExtendedCampMap = new Map<Id, CampEx>();
        For (Campaign c : VolInterestCamps) {
            If (c.CampaignMembers.size() == 0) {
                CampEx cex = new CampEx(c, null, null);
                VolInterestCampExs.add(Cex);
                CampToExtendedCampMap.put(c.Id, Cex);
            } else {
                CampEx cex = new CampEx(
                        c,
                        c.CampaignMembers[0].Id,
                        c.CampaignMembers[0].Unsubscribed__c == true ? 'Unsubscribed' : 'Registered');
                VolInterestCampExs.add(Cex);
                CampToExtendedCampMap.put(c.Id, Cex);
                CMMap.put(c.CampaignMembers[0].Id,c.CampaignMembers[0]);
            }
        }
        JSONVICExs = json.SERIALIZE(VolInterestCampExs);
        system.debug('JSONVICExs is ' + JSONVICExs);
        system.debug('CMMap is ' + CMMap);
        JSONCTECs = json.SERIALIZE(CampToExtendedCampMap);
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

    public void setCMStatus2(){
        MyString_From_Methode='Inserted this string from the controller.';
    }

    public pageReference setCMStatus() {
        string st = apexpages.currentPage().getParameters().get('firstParam');
        system.debug('In apex string passed in is ' + st);
        // Map<Id, CampEx> CMMap = new Map<Id, CampEx>();
        Map<Id, CampEx> CMMap = (Map<Id, CampEx>) JSON.deserialize(st, Map<Id, CampEx>.class);
        List<CampaignMember> UpdateCMs = new List<CampaignMember>();
        for (CampEx cx : CMMap.values()) {
            system.debug('CampEx is ' + cx);
            if (cx.FinalStatus != cx.InitialStatus) {
                If (cx.FinalStatus == 'Registered') {
                    If (cx.CMId == null) {
                        CampaignMember newCM = new CampaignMember(
                                status = 'Responded Yes',
                                ContactId = ctct.Id,
                                CampaignId = cx.camp.Id);
                        UpdateCMs.add(newCM);
                    } else {
                        // Get the campaignMember from the CMMap, update it
                        CampaignMember newCM = new CampaignMember(
                                status = 'Responded Yes',
                                ContactId = ctct.Id,
                                Id = cx.CMId,
                                Unsubscribed__c=false,
                                CampaignId = cx.camp.Id);
                        UpdateCMs.add(newCM);
                    }
                } else {
                    // FinalStatus not Registered
                    if (cx.FinalStatus == 'Unsubscribed'){
                        CampaignMember newCM = new CampaignMember(
                                status = 'Responded No',
                                ContactId = ctct.Id,
                                Id = cx.CMId,
                                CampaignId = cx.camp.Id,
                                Unsubscribed__c = true);
                        UpdateCMs.add(newCM);
                    }
                }
            }
        }
        Upsert UpdateCMs;
        return null;
    }

    public pageReference SubmitVolTask(){
        string GUUId = GUU.Id;
        if (GUU.Id==null) {
            withoutSharingDMLs.saveGUU(GUU);
            GUUId = GUU.Id;
        }
        system.debug('Afterinsert GUUId is ' + GUUId);
        GUUT.GuestUserUpdate__c = GUUId;
        withoutSharingDMLs.SaveGUUTask(GUUT);
        // Clear input for the next volunteer task
        GUUT = new GUUTask__c();
        // Update SubmittedTasks
        SubmittedTasks= [SELECT Id, Date_and_Time__c, Date_and_Time_Ended__c, Description__c, Campaign_Text__c,
                GuestUserUPdate__c,Hours__c,GuestUserUpdate__r.RelatedContact__c from GUUTask__c
        WHERE GuestUserUpdate__r.RelatedContact__c =: ctct.Id];
        If (SubmittedTasks.size()>0) HasSubmittedTasks=true;
        return null;
    }

                public class CampEx {
                public campaign camp;
        Id CMId;
        String InitialStatus;
        public String FinalStatus;

        public CampEx(Campaign c, Id CampMmbrId, String InitStatus) {
        camp = c;
        CMId = CampMmbrId;
        InitialStatus = InitStatus;
    }
}

}