/**
 * Created by Baird on 10/29/2020.
 */

@IsTest
private class WGSetupTEST {

@IsTest
static void IsAccountDefaultSetToFamily() {
    Schema.DescribeSObjectResult dsr = Account.SObjectType.getDescribe();
    Schema.RecordTypeInfo defaultRecordType;
    for (Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
        if (rti.isDefaultRecordTypeMapping()) {
            defaultRecordType = rti;
        }
    }
    system.debug('default account.recordType is ' + defaultRecordType.getName());
    system.assertEquals('Family',defaultRecordType.getName(),'Default Account RecordType not set to Family, causes errors in email mgmt.');
}

    @IsTest
    static void CheckOpportunityRTs() {
        List<String> RTNames = new List<String>();
        RTNames.add('Challenge');
        RTNames.add('Donation');
        RTNames.add('Event');
        RTNames.add('Grant');
        RTNames.add('InKind');
        RTNames.add('Major_Donation');
        RTNames.add('Membership');
        RTNames.add('Service');
        RTNames.add('Pledge');
        RTNames.add('Volunteer_Task');

        List<RecordType> RTs = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType='Opportunity'];
        Map<string,RecordType> MapExistingRTs = new Map<String,RecordType>();
        For (RecordType rt : RTs) {
            MapExistingRTs.put(rt.DeveloperName,rt);
        }
        For (string s : RTNames){
            system.assert(MapExistingRTs.keySet().CONTAINS(s),'Opportunity RecordTypes is missing ' + s);
        }
    }

    @IsTest
    static void CheckEmailDeliverability(){
        Boolean EmailDeliverabilityEnabled = true;
        try {
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.reserveMassEmailCapacity(1);
        } catch (System.NoAccessException e) {
            EmailDeliverabilityEnabled = false;
        }
        system.assertEquals(true,EmailDeliverabilityEnabled,'Email Deliverability has not been enabled.');
    }

    @istest static void CheckFields(){
        Schema.DescribeFieldResult dfr = Contact.Active__c.getDescribe();
        system.assertEquals('Active',dfr.defaultvalue,'Contact.Active__c is not set to Active, will cause errors in Nr_Contacts_in_Account__c');
    }
}