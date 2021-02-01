/**
 * Created by Baird on 10/15/2020.
 */

global without sharing class MyOrgURL {
    public final string MyOrgURLString;

    public MyOrgURL(){
        myOrgURLString = URL.getSalesforceBaseUrl().toExternalForm();
    }

    public string getMyOrgURL() {
        return MyOrgURLString;
    }
}