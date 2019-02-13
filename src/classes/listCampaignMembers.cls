/**
 * Created by Baird on 10/31/2018.
 */

public class listCampaignMembers {
    Public String campaignName { get; set; }
    Public Campaign camp { get; set; }
    Integer numberMembers {get; set;}
    public List<CampaignMember> listcms;
    public List<CMExtended> CmpMmbrs;

    public listCampaignMembers(ApexPages.StandardController controller) {
        if(camp==null) camp = (Campaign) controller.getRecord();
        system.debug('Beginning Constructor, CAmpaignId is '+ Camp.Id);
        listcms = [
                select Id, CampaignMember.FirstName, ContactId, To_Delete__c, LastName, Status, Email, Contact.Phone, Contact.LastName, PostalCode,
                        Contact.Account.Name, LeadId, Lead.Company
                from CampaignMember
                where CampaignId = :Camp.Id
                order by Lead.LastName, Contact.LastName
        ];
        numberMembers = listcms.size();
        system.debug('Before searching for name, Camp.Id is '+ Camp.Id);
        campaignName = [select Id, Name from Campaign where Id = :Camp.Id limit 1].Name;
        CmpMmbrs = new List<CMExtended>();
        for (CampaignMember cm1 : listcms) CmpMmbrs.add(new CMExtended(cm1));
    }

    public Integer getnumberMembers(){
        return numberMembers;
    }

    public List<CMExtended> getCmpMmbrs() {
        system.debug('In get statement, CmpMmbrs is ' + CmpMmbrs);
        // CmpMmbrs = new List<CMExtended>();
        // for (CampaignMember cm1 : listcms) CmpMmbrs.add(new CMExtended(cm1));
        return CmpMmbrs;
    }

    public PageReference deleteRefresh() {
        List<CampaignMember> deleteList = new List<CampaignMember>();

        for (CMExtended cmx : CmpMmbrs) {
            if (cmx.ToDelete== true) {
                deleteList.add(cmx.cm);
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

    public class CMExtended {
        public CampaignMember cm {get; set;}
        public Boolean ToDelete {get; set;}

        public CMExtended(CampaignMember cm1) {
            this.cm = cm1;
            this.ToDelete = false;
        }
    }
}