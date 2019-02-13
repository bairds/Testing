@isTest
private class ContributionHistoryControllerTests {

 
    static testMethod void myUnitTest() {
//Test for an individual insertion      
        Account a = new Account(Name = 'testaccountfromContribHistoryControllertest');
        insert a;
        Contact c = new Contact(LastName='test', accountID = a.id);
        insert c;
        Campaign camp = new Campaign(Name='test');
        insert camp; 
        Opportunity o = new Opportunity(Name='Test',accountID = a.id, CloseDate=System.today(),
        Amount=100,Contact__c=c.id,StageName='Payment Received',CampaignId=camp.Id, Recordtypeid = [select id from recordType where name = 'Donation'].id);
        insert o;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        ContributionHistoryController controller = new ContributionHistoryController(sc);
        
        controller.initContributionHistory();
           
        //try calling methods/properties of the controller in all possible scenarios
        Integer cContribCount = controller.getContribCount();       
        String sLastContribDate = controller.getLastContribDate();
        String sMaxAmount = controller.getMaxAmount();
        Double sTotalContribAmount = controller.getTotalContribAmount();
        
        System.assertEquals(100,stotalContribAmount);
        
//Test for multiple insertions
        Opportunity[] oppsToCreate = new Opportunity[]{};
        for(Integer x=0; x<20;x++){
            Opportunity opp = new Opportunity (AccountId=a.Id,name='testing apex', Amount=100, Contact__c = c.id, CloseDate = System.today(), StageName='Prospecting',CampaignID=camp.Id);
            oppsToCreate.add(opp);
        }
        
        //Now insert data causing an contact trigger to fire. 
        Test.startTest();
        insert oppsToCreate;
        Test.stopTest();
        
        ApexPages.StandardController sclist = new ApexPages.StandardController(c);
        ContributionHistoryController controllerlist = new ContributionHistoryController(sclist);
        
        controller.initContributionHistory();
           
        //try calling methods/properties of the controller in all possible scenarios
        cContribCount = controllerlist.getContribCount();       
        sLastContribDate = controllerlist.getLastContribDate();
        sMaxAmount = controllerlist.getMaxAmount();
        sTotalContribAmount = controllerlist.getTotalContribAmount();       
        
        //System.assertEquals(2100,sTotalContribAmount);
    }
}