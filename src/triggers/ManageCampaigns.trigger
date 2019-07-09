/**
 * Created by Baird on 7/4/2019.
 */

trigger ManageCampaigns on Campaign (after insert) {
    if(Trigger.isAfter && (Trigger.isUpdate || Trigger.IsInsert)) {
        List<Id> CampIds = new List<Id>();
        For (Campaign c : Trigger.New) CampIds.add(c.Id);
        createCampaignMemberStati.createCampaignMemberStati(CampIds);
    }
}