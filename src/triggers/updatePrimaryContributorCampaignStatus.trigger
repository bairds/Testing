trigger updatePrimaryContributorCampaignStatus on Opportunity (after insert, after update) {
    /* Trigger to update the campaign member status to 'Responded Yes' when the primary contributor is a member of the
    campaign defined on the opportunity.  If a new opportunity is created (or updated) and has a primary contributor, a
    defined campaign, and a Closed/Won opportunity stage, chech the campaign to see if the primary contributor is a member.
    If the primary contributor is a member, update the campaign member status to 'Responded Yes'.  If the primary contributor 
    is not a member, do nothing.
    */

    if(trigger.isInsert || trigger.isUpdate) {
        // updatePrimaryContributorCampaignStatus.UpdateCMStatus(trigger.new);
    }
}