/**
 * Created by Baird on 8/7/2020.
 */

public with sharing class emailVolsInInterestCampaign {
    // User calls the method from a button on a campaign detail page.
    // Find the related Vol_Interest campaign, if it exists, pull its campaign members, email them.
    private final Campaign camp;
    public List<CMExtended> CmpMmbrs {get;set;}
    public Campaign VolIntCamp {get;set;}
    public Integer numberMembers {get;set;}
    Public String campaignName { get; set; }

    public emailVolsInInterestCampaign(ApexPages.StandardController stdController){
        camp = (Campaign)stdController.getRecord();
        VolIntCamp = [
                SELECT Name, Event_Date_Time__c, Description, Description_Long__c,
                Id, (SELECT FirstName, LastName from CampaignMembers)
                FROM Campaign
                WHERE Id = :Camp.Vol_Interest_Campaign__c
        ];
        numberMembers = VolIntCamp.CampaignMembers.size();
        campaignName = VolIntCamp.Name;
        CmpMmbrs = new List<CMExtended>();
        for (CampaignMember cm1 : VolIntCamp.CampaignMembers) CmpMmbrs.add(new CMExtended(cm1));
    }

    public PageReference deleteRefresh() {
        List<CampaignMember> deleteList = new List<CampaignMember>();
        for (integer i=0;i<CmpMmbrs.size();i++) {
            if (CmpMmbrs[i].ToDelete== true) {
                deleteList.add(CmpMmbrs[i].cm);
                CmpMmbrs.remove(i);
            }
        }
        try {
            delete deleteList;
        } catch (System.Exception e) {
            System.debug('ERROR: ' + e);
        }
        PageReference return_to_list = new PageReference('/apex/listCampaignMembersPage?id='+camp.Id);
        return_to_list.setRedirect(true);
        return return_to_list;
    }

    public PageReference sendInvitationEmails() {
        emailTemplate eT = [SELECT Id from EmailTemplate WHERE Name like '%Invite_Interested_Vols%' LIMIT 1];
        if (eT == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Could not find an email Template with the name Invite_Interested_Vols, so cannot send emails.'));
            return null;
        }
        // Load Subcamp values into Campaign so they are available to the email template
        VolIntCamp.SubCamp_Description_Long__c = camp.Description_Long__c;
        VolIntCamp.SubCamp_Date_Time__c = camp.Event_Date_Time__c;
        VolIntCamp.SubCamp_Description__c = camp.Description;
        VolIntCamp.SubCamp_Name__c = camp.Name;
        VolIntCamp.SubCamp_Id__c = camp.Id;
        update VolIntCamp;
        For (CMExtended cmx : CmpMmbrs) {
            // from https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_objects_emailmessage.htm
            // if EnhancedEmail Perm is not enabled, continue logging the email as a task
            // if EnhancedEmail Perm is enabled, create an EmailMessage object
            EmailMessage emailMessage = new EmailMessage();
            emailMessage.EmailTemplateId = eT.Id;
            emailMessage.status = '3'; // email was sent
            emailMessage.relatedToId = cmx.cm.Id; // related to record e.g. an opportunity
            emailMessage.fromAddress = UserInfo.getUserEmail(); // from address
            emailMessage.fromName = UserInfo.getUserName(); // from name
            string subjectstring = 'New Volunteer Opportunity with '; // + {!$Organization.Name};
            emailMessage.subject = subjectstring; // email subject
            String[] RecipientIds = new List<String>();
            RecipientIds.add(cmx.cm.Id);
            emailMessage.toIds = RecipientIds;
// additional recipients who don’t have a corresponding contact, lead or user id in the Salesforce org (optional)
            insert emailMessage; // insert
        }
        return null;
    }

    public class CMExtended {
        public CampaignMember cm {get; set;}
        public Boolean ToDelete {get; set;}

        public CMExtended(CampaignMember cm1) {
            this.cm = cm1;
            this.ToDelete = false;
        }
    }
}