public class moveHUCToAccount {
    
    public moveHUCToAccount(){}
    
    public List<Account> moveDataToAccounts2(List<id> acctIds){
        List<Account> accts = [select Id, Billing_HUC__c, HUC_Code__c, Shipping_HUC__c, HUC_Errors__c, HUC_Status__c, Watershed__c, Subwatershed__c from Account where id in :acctIds
                              	AND (Billing_HUC__c != null OR Shipping_HUC__c != null)];
        system.debug('Beginning MoveHUCToAccount, found accounts ' + accts);
            Map<id,HUC__c> HUCMap = new Map<id,HUC__c>();
            List<id> HList = new List<id>();
        	List<string> HUCErrorStrings = new List<string>();
        	HUcErrorStrings.add('Needs processing');
        	HUCErrorStrings.add('Call to USGS errors');
        For (account acct : accts ){
            if (!HUCErrorStrings.CONTAINS(acct.Billing_HUC__c)) {
            HList.add(acct.Billing_HUC__c);
            } else {
                if (!HUCErrorStrings.CONTAINS(acct.Shipping_HUC__c)) 
            HList.add(acct.Billing_HUC__c);
            }
            system.debug('Found HUCs associated with these account Ids: ' + HList);
        }
        List<HUC__c> HUCList = [SELECT Code__c, Errors__c, Status__c, Watershed__c, Subwatershed__c FROM HUC__c where Id in :HList];
        For (HUC__c h : HUCList) {
            HUCMap.put(h.id,h);
        }
        system.debug('From list of associated Ids created this map: ' + HUCMap);
        For (account acct : accts){
            //If ( String.IsBlank(acct.HUC_Code__c) && (String.isNotBlank(HUCMAP.get(acct.Billing_HUC__c).Code__c) || String.isNotBlank(HUCMAP.get(acct.Shipping_HUC__c).Code__c)) ) 
            //    acct.HUC_Code__c = String.isNotBlank(HUCMAP.get(acct.Billing_HUC__c).Code__c) ? HUCMAP.get(acct.Billing_HUC__c).Code__c : HUCMAP.get(acct.Shipping_HUC__c).Code__c;
            //Transfer HUC_Code
            If ( String.IsBlank(acct.HUC_Code__c)) {
            If (HUCMap.get(acct.Billing_HUC__c)!=null && String.isNotBlank(HUCMAP.get(acct.Billing_HUC__c).Code__c) ) {
                acct.HUC_Code__c =  HUCMAP.get(acct.Billing_HUC__c).Code__c;
            } else
                if (HUCMap.get(acct.Shipping_HUC__c)!=null && String.isNotBlank(HUCMAP.get(acct.Shipping_HUC__c).Code__c) ) {
                   acct.HUC_Code__c =  HUCMAP.get(acct.Shipping_HUC__c).Code__c;
                }
            }
            //Transfer ErrorCode
            If ( String.IsBlank(acct.HUC_Errors__c)) {
            If (HUCMap.get(acct.Billing_HUC__c)!=null && String.isNotBlank(HUCMAP.get(acct.Billing_HUC__c).Errors__c) ) {
                acct.HUC_Errors__c =  HUCMAP.get(acct.Billing_HUC__c).Errors__c;
            } else
                if (HUCMap.get(acct.Shipping_HUC__c)!=null && String.isNotBlank(HUCMAP.get(acct.Shipping_HUC__c).Errors__c) ) {
                   acct.HUC_Errors__c =  HUCMAP.get(acct.Shipping_HUC__c).Errors__c;
                }
            }
            //Transfer Status
            If ( String.IsBlank(acct.HUC_Status__c)) {
            If (HUCMap.get(acct.Billing_HUC__c)!=null && String.isNotBlank(HUCMAP.get(acct.Billing_HUC__c).Status__c) ) {
                acct.HUC_Status__c =  HUCMAP.get(acct.Billing_HUC__c).Status__c;
            } else
                if (HUCMap.get(acct.Shipping_HUC__c)!=null && String.isNotBlank(HUCMAP.get(acct.Shipping_HUC__c).Status__c) ) {
                   acct.HUC_Status__c =  HUCMAP.get(acct.Shipping_HUC__c).Status__c;
                }
            }
            //Transfer Watershed
            If ( String.IsBlank(acct.HUC_Watershed__c)) {
            If (HUCMap.get(acct.Billing_HUC__c)!=null && String.isNotBlank(HUCMAP.get(acct.Billing_HUC__c).Watershed__c) ) {
                acct.HUC_Watershed__c =  HUCMAP.get(acct.Billing_HUC__c).Watershed__c;
            } else
                if (HUCMap.get(acct.Shipping_HUC__c)!=null && String.isNotBlank(HUCMAP.get(acct.Shipping_HUC__c).Watershed__c) ) {
                   acct.HUC_Watershed__c =  HUCMAP.get(acct.Shipping_HUC__c).Watershed__c;
                }
            }
            //Transfer Subwatershed
            If ( String.IsBlank(acct.HUC_Subwatershed__c)) {
            If (HUCMap.get(acct.Billing_HUC__c)!=null && String.isNotBlank(HUCMAP.get(acct.Billing_HUC__c).Subwatershed__c) ) {
                acct.HUC_Subwatershed__c =  HUCMAP.get(acct.Billing_HUC__c).Subwatershed__c;
            } else
                if (HUCMap.get(acct.Shipping_HUC__c)!=null && String.isNotBlank(HUCMAP.get(acct.Shipping_HUC__c).Subwatershed__c) ) {
                   acct.HUC_Subwatershed__c =  HUCMAP.get(acct.Shipping_HUC__c).Subwatershed__c;
                }
            }
            // If ( String.IsBlank(acct.HUC_Status__c) && String.isNotBlank(HUCMAP.get(acct.Billing_HUC__c).Status__c) ) acct.HUC_Status__c = HUCMAP.get(acct.Billing_HUC__c).Status__c;
            // If ( String.IsBlank(acct.Watershed__c) && String.isNotBlank(HUCMAP.get(acct.Billing_HUC__c).Watershed__c) ) acct.Watershed__c = HUCMAP.get(acct.Billing_HUC__c).Watershed__c;
            //If ( String.IsBlank(acct.Subwatershed__c) && String.isNotBlank(HUCMAP.get(acct.Billing_HUC__c).Subwatershed__c) ) acct.Subwatershed__c = HUCMAP.get(acct.Billing_HUC__c).Subwatershed__c;
        }
            
        return accts;
    }
    
/*
    public List<Account> moveHUCDataToAccounts(List<id> acctIds){
        List<Account> accts = new List<Account>();
        Set<Id> HUCIdSet = new set<Id>();
        Map<Id,Map<string,string>> AcctFieldsByHUCIdMap = new Map<Id,Map<string,string>>();
        accts = [select Id, Billing_HUC__c, HUC_Code__c, HUC_Errors__c, HUC_Status__c, Watershed__c, Subwatershed__c from Account where id in :acctIds];
        For (Account acct : accts){
            HUCIdSet.add(acct.Billing_HUC__c);
            Map<string,string> AcctFields = new Map<string,string>();
            AcctFields.put('HUC_Code__c',acct.HUC_Code__c);
            AcctFields.put('HUC_Errors__c',acct.HUC_Errors__c);
            AcctFields.put('HUC_Status__c',acct.HUC_Status__c);
            AcctFields.put('Watershed__c',acct.Watershed__c);
            AcctFields.put('Subwatershed__c',acct.Subwatershed__c);
            AcctFieldsByHUCIdMap.put(acct.Billing_HUC__c,AcctFields);
        }
        system.debug('AcctFieldsByHUCIdMap is ' + AcctFieldsByHUCIdMap);        
        
        List<HUC__c> HUCs = [SELECT Code__c, Errors__c, Status__c, Watershed__c, Subwatershed__c FROM HUC__c where Id in :HUCIdSet];
            For (HUC__c h : HUCs){
            Map<string,string> AcctFields = AcctFieldsByHUCIdMap.get(h.Id);
            if (AcctFields.get('HUC_Code__c') == null)  AcctFields.put('HUC_Code__c',h.Code__c);
            if (AcctFields.get('HUC_Errors__c') == null)  AcctFields.put('HUC_Errors__c',h.Errors__c);
            if (AcctFields.get('HUC_Status__c') == null)  AcctFields.put('HUC_Status__c',h.Status__c);
            if (AcctFields.get('HUC_Watershed__c') == null)  AcctFields.put('Watershed__c',h.Watershed__c);
            if (AcctFields.get('HUC_Subwatershed__c') == null)  AcctFields.put('Subwatershed__c',h.Subwatershed__c);
            AcctFieldsByHUCIdMap.put(h.Id,AcctFields);
            }
        
        For (Account acct : accts){
            acct.HUC_Code__c = AcctFieldsByHUCIdMap.get(acct.Billing_HUC__c).get('HUC_Code__c');
            acct.HUC_Errors__c = AcctFieldsByHUCIdMap.get(acct.Billing_HUC__c).get('HUC_Errors__c');
            acct.HUC_Status__c = AcctFieldsByHUCIdMap.get(acct.Billing_HUC__c).get('HUC_Status__c');
            acct.Watershed__c = AcctFieldsByHUCIdMap.get(acct.Billing_HUC__c).get('Watershed__c');
            acct.Subwatershed__c = AcctFieldsByHUCIdMap.get(acct.Billing_HUC__c).get('Subwatershed__c');
        }
        return accts;
        }
*/
}