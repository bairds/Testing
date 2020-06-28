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
    Public GuestUserUpdate__c guu { get; set; }
    public string editmode { get; set; }
    public Boolean URLCorrect { get; set; }
    public string VToken { get; set; }
    public string OrgName {get; set;}
    public List<Campaign> VolInterestCamps {get; set;}
    public List<CampEx> VolInterestCampExs {get; set;}
    public string JSONVICExs {get; set;}
    public Map<Id,CampEx> CampToExtendedCampMap {get; set;}
    public string JSONCTECs {get; set;}

    public displayVolPortal() {
        OrgName = UserInfo.getOrganizationName();
        id cid = ApexPages.currentPage().getParameters().get('cid');
        VToken = apexPages.currentPage().getParameters().get('VToken');
        ctct = [SELECT id, firstname, lastname, mailingstreet, mailingPostalCode, mailingcity,
                mailingstate, mailingcountry,email,MobilePhone,HomePhone,Phone,VolToken__c from Contact where id = :cid];
        if (VToken != ctct.VolToken__c) {
            URLCorrect = false;
        } else {
            URLCorrect = true;
        }
        guu = new GuestUserUpdate__c(
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
                phone__c = ctct.phone
        );
        // VolTasks = new List<Opportunity>();
        ListOfOne = new List<String>();
        ListOfOne.add('Only one item');
        VolHoursAll = 0;
        VolHoursThisYear = 0;
        VolMilesAll = 0;
        VolMilesThisYear = 0;
        Id VolTaskRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Volunteer Task').getRecordTypeId();
        VolTasks = [
                SELECT id, name,Hours_Actual__c,Miles_Driven__c,CloseDate,RecordTypeId,Description,Supervisor_Satisfaction__c
                from Opportunity
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
        // Query for Volunteer Interest Signup Campaigns
        VolInterestCampExs = new List<CampEx>();
        Id SignupRTID = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Signup').getRecordTypeId();
        system.debug('Line 71 Campaigns are ' + [SELECT Name, Type, RecordType.Name from Campaign]);
        VolInterestCamps = [SELECT Id, Description, Name, Type, (SELECT Unsubscribed__c,Id from CampaignMembers
                WHERE ContactId =: cid) from Campaign where RecordTypeId =: SignupRTID AND
                Type = 'Volunteer Interest'];
        System.debug('VolInterestCamps includes ' + VolInterestCamps);
        CampToExtendedCampMap = new Map<Id,CampEx>();
        For (Campaign c: VolInterestCamps) {
            If (c.CampaignMembers.size()==0){
                CampEx cex = new CampEx(c,null,null);
                VolInterestCampExs.add(Cex);
                CampToExtendedCampMap.put(c.Id,Cex);
            } else {
                CampEx cex = new CampEx(
                        c,
                        c.CampaignMembers[0].Id,
                        c.CampaignMembers[0].Unsubscribed__c==true ? 'Unsubscribed' : 'Registered');
                VolInterestCampExs.add(Cex);
                CampToExtendedCampMap.put(c.Id,Cex);
            }
                }
        JSONVICExs=json.SERIALIZE(VolInterestCampExs);
        system.debug('JSONVICExs is ' + JSONVICExs);
        JSONCTECs=json.SERIALIZE(CampToExtendedCampMap);

    }


    public pageReference editContactInfo() {
        editmode = 'editContactInfo';
        return null;
    }

    public pageReference submit() {
        guu.PageSource__c = 'UpdateContactInfo';
        guu.RelatedContact__c = ctct.Id;
        upsert guu;
        editMode = 'display';
        return null;
    }

    public pageReference cancelEditContactInfo() {
        editMode = 'display';
        return null;
    }


    public class CampEx {
        public campaign camp;
        Id CMId;
        String InitialStatus;
        String FinalStatus;

        public CampEx(Campaign c, Id CampMmbrId, String InitStatus) {
            camp = c;
            InitialStatus = InitStatus;
        }
    }
}