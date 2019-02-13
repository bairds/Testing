@isTest

private class PrintTest {
    

   static testMethod void PrintTest()
   {
       Test.startTest();
        
        Campaign cmp = new Campaign(Name = 'Tesst');
        insert cmp;
        
       Opportunity opp = new Opportunity(Name = 'Test Contribution',
                               CampaignId = cmp.Id,
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