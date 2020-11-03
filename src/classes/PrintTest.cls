@isTest

private class PrintTest {
    

   static testMethod void PrintTest()
   {
       Test.startTest();

       Create_Test_Variables CTV = new Create_Test_Variables();
       Account TestAcct = CTV.fetchFamilyTestAccount();
       Contact TestCtct = CTV.fetchTestContact();
       Campaign TestCamp = CTV.fetchTestCampaign();
        
       Opportunity opp = new Opportunity(Name = 'Test Contribution',
               Contact__c = TestCtct.Id,
               AccountId = TestAcct.Id,
               CampaignId = TestCamp.Id,
                               StageName = 'Payment Received',
                               CloseDate = Date.Today() + 5);
        insert opp;
        //System.debug('ddddd' + opp.Id);
        //
        
        ApexPage ap = [SELECT Id FROM ApexPage WHERE Name LIKE 'Thanks_%' LIMIT 1];
        
        ApexPages.currentPage().getParameters().put('template', ap.Id);
        ApexPages.currentPage().getParameters().put('contrib', opp.Id);
        
        Print p = new Print();
        
        Print.saveAttach(opp.Id, ap.Id);
      
        Test.stopTest();
    }
}