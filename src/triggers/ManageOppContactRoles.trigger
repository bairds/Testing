/**
 * Created by Baird on 1/22/2021.
 */

trigger ManageOppContactRoles on OpportunityContactRole (after insert) {

    if (Trigger.isAfter && Trigger.isInsert) {
        if (!Test.IsRunningTest()) {
            if (WGHelpers.getManageOCRs()) {
                ManageOppContactRs.AfterInsert(Trigger.New);
            }
        }
    }
}