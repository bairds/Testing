/**
 * Created by Baird on 8/27/2020.
 */

public with sharing class approveVolTasks {
public List<Opportunity> ListOpps {get;set;}
    public String VolTaskRTId;

public approveVolTasks(){
    VolTaskRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Volunteer Task').getRecordTypeId();
ListOpps = [SELECT Name, Hours_Actual__c, Description,
        Date_and_Time_Start__c, Date_and_Time_End__c,CampaignId,Campaign_Guess__c,
StageName, Contact__r.FirstName,
Contact__r.LastName, AccountId
from Opportunity WHERE StageName = 'Task Submitted'];
For (Opportunity o : ListOpps) o.StageName = 'Task Approved';
}

    /*
    The unapproved tasks are listed on the page, and the
    organizer approves them, making changes and inserting the correct campaign.
    When the organizer submits the tasks:
     */

public pageReference submitTasks() {
withoutSharingDMLs.UpdateOppsWoutSharing(ListOpps);
PageReference PageRef = new PageReference('/006');
return PageRef;
}

}