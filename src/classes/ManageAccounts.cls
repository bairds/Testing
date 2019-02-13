public class ManageAccounts {
    
    public static void CheckForAddressChanges(List<Account> triggernew, List<Account> triggerold){
        List<Account> AcctsToUpdate = new List<Account>();
        Map<id,account> TriggerOldMap = new Map<id,account>(triggerold);

        for (Account a : triggernew){
            system.debug('In triggernew account is ' + a);
            List<String> pickListValuesList= new List<String>();
            Schema.DescribeFieldResult fieldResult = Account.HUC_Status__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
		}     
		system.debug('Picklist values are ' +  pickListValuesList);
            if (a.BillingStreet != TriggerOldMap.get(a.Id).BillingStreet) a.HUC_Status__c = '1 Needs processing';
        }
    }   
}