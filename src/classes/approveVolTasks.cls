/**
 * Created by Baird on 8/27/2020.
 */

global with sharing class approveVolTasks {
    public List<Opportunity> ListOpps { get; set; }
    public Map<id, Opportunity> MapOpps;
    public String VolTaskRTId;
    public String OppApprovalMapString { get; set; }
    public Map<id, string> OppApprovalMap { get; set;}
    public Boolean TasksSubmitted {get;set;}

    public approveVolTasks() {
        VolTaskRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Volunteer Task').getRecordTypeId();
        ListOpps = [
                SELECT Name, Hours_Actual__c, Description,
                        Date_and_Time_Start__c, Date_and_Time_End__c,CampaignId,Campaign_Guess__c,
                        StageName, Contact__r.FirstName,
                        Contact__r.LastName, AccountId
                from Opportunity
                WHERE StageName = 'Task Submitted'
        ];
        OppApprovalMap = new Map<id, string>();
        MapOpps = new Map<id,Opportunity>();
        For (Opportunity o : ListOpps) {
            OppApprovalMap.put(o.Id, o.StageName);
            MapOpps.put(o.Id,o);
        }
        system.debug('OppApprovalMap is ' + OppApprovalMap);
        OppApprovalMapString = json.SERIALIZE(OppApprovalMap);
        system.debug('In controller, OppApprovalMapString is ' + OppApprovalMapString);
    }

    /*
    The unapproved tasks are listed on the page, and the
    organizer approves them, making changes and inserting the correct campaign.
    When the organizer submits the tasks:
     */

    public pageReference submitTasks() {
        system.debug('Parameters are ' + apexpages.currentPage().getParameters());
        string st = apexpages.currentPage().getParameters().get('firstParam');
        system.debug('In apex string passed in is ' + st);
        Map<Id, string> RtrnOppApprovalMap = (Map<Id, string>) JSON.deserialize(st, Map<Id, string>.class);
        List<Opportunity> UpdateOpps = new List<Opportunity>();
        for (Id idstring : RtrnOppApprovalMap.keySet()) {
            // MUST CHANGE THIS TO ITERATE OVER OPPS
            if (RtrnOppApprovalMap.get(idstring) == 'Approved') MapOpps.get(idstring).StageName = 'Task Approved';
            if (RtrnOppApprovalMap.get(idstring) == 'Rejected') MapOpps.get(idstring).StageName = 'Task Rejected';
            if (RtrnOppApprovalMap.get(idstring) == 'Under Review') MapOpps.get(idstring).StageName = 'Task Submitted';
            UpdateOpps.add(MapOpps.get(idstring));
        }
        update UPdateOpps;
        withoutSharingDMLs.UpdateOppsWoutSharing(ListOpps);
        TasksSubmitted=true;
        return null;
        /*
        PageReference OppsPage = new ApexPages.StandardController(opportunity).view();
        OppsPage.setRedirect(true);
        return new ApexPages.Action('{!ListOpps}').invoke();

        PageReference PageRef = new PageReference('/006');
        PageRef.setRedirect(true);
        return PageRef;*/
    }

    public List<SelectOption> getApprovalOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Task Approved', 'Task Approved'));
        options.add(new SelectOption('Task Submitted', 'Task Submitted'));
        options.add(new SelectOption('Task Rejected', 'Task Rejected'));
        return options;
    }

}