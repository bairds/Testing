/**
 * Created by Baird on 5/6/2019.
 */

public with sharing class CaseContactSection {
    public List<CaseContactRole> CCRList { get; private set; }

    public CaseContactSection(ApexPages.StandardController stdController) {

        Case cse = (Case) stdController.getRecord();
        CCRList = [SELECT CasesId,ContactId,Role from CaseContactRole where CasesId = :cse.Id];
    }

}