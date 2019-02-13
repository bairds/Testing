//Tests for the existence of all custom settings, triggers, workflows,
//documents and static resources necesssary for the proper functioning of 
//WaterGrass code

@isTest(SeeAllData=true)
private class TestSettings {
    
    static testMethod void AutoFillContribName(){
        // NOTE: I think this one testmethod could hold many of the basic tests
        // for workflows that fire when an account, contact, campaign or opportunity
        // is created.  So let's add here.
        Create_Test_Variables CTV = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        Contact TestCtct = ctv.fetchTestContact();
        Campaign TestCamp = ctv.fetchTestcampaign();
        Opportunity TestOpp = ctv.fetchTestOpportunity();
        Opportunity retrieveOppAgain = [select name, closeDate from Opportunity where Id = :TestOpp.Id LIMIT 1];
        system.assertEquals(retrieveOppAgain.name,TestAcct.name + ' ' + string.valueOf(retrieveOppAgain.CloseDate) + ' ' + Testcamp.name,'Workflow autofill contribution name not as expected.  Check Autofill contribution name.  Does it pull the contact.name rather than account?');                         
		
    }

}