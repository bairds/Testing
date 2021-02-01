/**
 * Created by Baird on 1/27/2021.
 */

trigger ManageACRelations on AccountContactRelation (before insert, before update) {
    system.debug('WGSetting.ManageACRelations is set to ' + WGHelpers.getManageACRelations());
If (WGHelpers.getManageACRelations())
    ManageACRelations.BeforeInsert(Trigger.New);
}