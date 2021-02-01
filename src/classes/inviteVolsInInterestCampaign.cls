/**
 * Created by Baird on 8/7/2020.
 */

public with sharing class inviteVolsInInterestCampaign {
    // User calls the method from a button on a campaign detail page.
    // Find the related Vol_Interest campaign, if it exists, pull its campaign members, email them.
    public Campaign camp;
    public List<CMExtended> CmpMmbrs {get;set;}
    public Campaign VolIntCamp {get;set;}
    public Integer numberMembers {get;set;}
    Public String campaignName { get; set; }
    public Messaging.SendEmailResult results;
    public String FinishedStatus {get; set;}
    Integer TotalEmailsSent {get; set;}
    Integer TotalEmailsArrived {get; set;}

    public inviteVolsInInterestCampaign(ApexPages.StandardController stdController){
        camp = (Campaign)stdController.getRecord();
        camp = [SELECT Vol_Interest_Campaign__c, Description_Long__c, Description,
                Event_Date_Time__c, Name from Campaign where Id =: camp.Id];
        VolIntCamp = [
                SELECT Name, Event_Date_Time__c, Description, Description_Long__c,
                Id, (SELECT FirstName, LastName, Email, ContactId, Contact.Account.Name, LeadId, Status,
                        Lead.Company from CampaignMembers)
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
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        TotalEmailsSent = CmpMmbrs.size();
        For (CMExtended cmx : CmpMmbrs) {
            // from https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_objects_emailmessage.htm
            // if EnhancedEmail Perm is not enabled, continue logging the email as a task
            // if EnhancedEmail Perm is enabled, create an EmailMessage object


            // Alternative using SingleEmailMessage
            //vMessaging.SingleEmailMessage eMessage = new Messaging.SingleEmailMessage();
            // EmailMessage eMessage = new EmailMessage();
            // eMessage.setTemplateId(eT.Id);
            // eMessage.status = '3'; // email was sent
            // eMessage.setWhatId(cmx.cm.Id); // related to record e.g. an opportunity
//            eMessage.setReplyTo(UserInfo.getUserEmail()); // from address
//            eMessage.setSenderDisplayName(UserInfo.getUserName()); // from name
//            string subjectstring = 'New Volunteer Opportunity with '; // + {!$Organization.Name};
//            eMessage.subject = subjectstring; // email subject
            // eMessage.setTargetObjectId(TargetObjectId);
            // insert eMessage;
            // system.debug('eMessage is ' + eMessage);
            // eMessage.saveAsActivity = false;
            Id TargetObjectId = cmx.cm.contactId == null ? cmx.cm.LeadId : cmx.cm.ContactId;
            Messaging.SingleEmailMessage em =
                    Messaging.renderStoredEmailTemplate(eT.Id,TargetObjectId,cmx.cm.Id);
            em.saveAsActivity = false;
            system.debug('em is ' + em);
            messages.add(em);
        }

        List<Messaging.SendEmailResult> results = Messaging.sendEmail(messages,false);
        TotalEmailsArrived = 0;
        For (Messaging.SendEmailResult ser : results) {
            if (ser.success) {
                System.debug('The email was sent successfully.');
                TotalEmailsArrived += 1;
            } else {
                System.debug('The email failed to send: '
                        + results[0].errors[0].message);
            }
        }
            Task EmailSent = new Task(
                    WhatId = camp.Id,
                    TaskSubtype = 'ListEmail',
                    Type = 'Email',
                    Subject = messages[0].getTemplateName() + ' via List Email',
                    Status = 'Completed',
                    OwnerId = UserInfo.getUserId(),
                    Description = 'Sent ' + TotalEmailsSent + ' of which ' + TotalEmailsArrived + ' arrived.');
            insert EmailSent;

            FinishedStatus = 'All Done';
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
    // Alternative using SingleEmailMessage
    /*           Messaging.SingleEmailMessage eMessage = new Messaging.SingleEmailMessage();
            // EmailMessage eMessage = new EmailMessage();
            eMessage.setTemplateId(eT.Id);
            // eMessage.status = '3'; // email was sent
            eMessage.setWhatId(cmx.cm.Id); // related to record e.g. an opportunity
            eMessage.setReplyTo(UserInfo.getUserEmail()); // from address
            eMessage.setSenderDisplayName(UserInfo.getUserName()); // from name
            string subjectstring = 'New Volunteer Opportunity with '; // + {!$Organization.Name};
            eMessage.subject = subjectstring; // email subject
            eMessage.setTargetObjectId(cmx.cm.contactId == null ? cmx.cm.LeadId : cmx.cm.ContactId);
            // insert eMessage;
            system.debug('eMessage is ' + eMessage);
            eMessage.saveAsActivity = false;
            messages.add(eMessage);
            */