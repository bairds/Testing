/**
 * Created by Baird on 9/21/2018.
 */

public with sharing class layoutCustomFieldsSection {
    public string SOType {get; set;}
    private final Account acct;

    public layoutCustomFieldsSection(ApexPages.StandardController controller){
        acct = (Account)controller.getRecord();
    }

    public PageReference submit(){
        update acct;
        return null;
    }

}