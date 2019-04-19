/**
 * Created by Baird on 4/8/2019.
 */

public with sharing class showPicklistCustomization {
    public List<string> ResultsList {get; set;}
    public Map<string,List<string>> InnerResultsMap {get; set;}
    public Map<string, Map<String,List<String>>> OuterResultsMap {get; set;}
    public showPicklistCustomization() {
        InnerResultsMap = new Map<string,List<string>>();

        OuterResultsMap = new Map<string, Map<String,List<String>>>();
        ResultsList = new List<string>();
        // sObject types to describe
        String[] types = new String[]{
        'Account', 'Campaign', 'CampaignMember', 'Contact', 'Lead', 'Opportunity', 'Affiliation__c'};
// create the object map
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
// Make the describe call
        For (Schema.DescribeSobjectResult res : results) {
            Map<string, List<string>> tempMap = new Map<string,List<string>>();
            Map<String, Schema.SObjectField> fieldMap = res.fields.getMap();
            system.debug('fieldmap is ' + fieldmap);
            For (string fieldname : fieldMap.keyset()) {
                system.debug('fieldname is ' + fieldname + ' and field is ' + fieldMap.get(fieldname) + 'and SObject is ' + res.getName());
                Schema.SObjectField fieldToInterrogate = fieldMap.get(fieldname);
                Schema.DescribeFieldResult dfr = fieldMap.get(fieldname).getDescribe();
                List<string> PVEList = new List<string>();
                if (dfr.getType() == Schema.DisplayType.Picklist) {
                    For (Schema.PicklistEntry pve : dfr.getPicklistValues()) {
                        PVEList.add(pve.getLabel());
                    }
                    PVEList.sort();
                    TempMap.put(fieldname, PVEList);
                }
                system.debug('For ' + fieldname + ' describefieldresult is ' + dfr);
            }
            OuterResultsMap.put(res.getName(),TempMap);
        }
        system.debug('OuterResultsMap is ' + OuterResultsMap);
        ResultsList.addAll(InnerResultsMap.keyset());
        system.debug('ResultsList is ' + ResultsList);
    }
}