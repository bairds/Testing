@isTest
private class ManageContributionsTest_Temp {

 @testSetup static void setup() {
    CreateCustomSettings CCS = new CreateCustomSettings();
     CCS.createCustomSettings();
    }   
    

//Insert the contributions in different order to make sure that doesn't effect result
static testMethod void AddMembership() {
                  
    id DonationRTID = [select id from RecordType where Name = 'Donation'][0].id;
    id ServiceRTID = [select id from RecordType where Name = 'Service'][0].id;
    id MembershipRTID = [select id from RecordType where Name = 'Membership'][0].id;
                
    
//Wrap the test in system.runas so that it doesn't object to mixed DML (from setup and non-setup objects)       
    User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    System.runAs ( thisUser ) {
        
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account testacct = ctv.fetchTestAccount();
        Contact testctct = ctv.fetchTestContact();
        Campaign testcamp = ctv.fetchTestCampaign();
        List<Opportunity> insertOpps = new List<Opportunity>();
        //First Contribution Type Service
        Opportunity TestContrib3 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today(),
        recordTypeID = ServiceRTID,
        Amount = 300);
        insertOpps.add(TestContrib3);
        //Second Contribution Type Membership
        Opportunity TestContrib4 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today()-1,
        recordTypeID = MembershipRTID,
        Amount = 400);
        insertOpps.add(TestContrib4);
        //Third Contribution Type Donation
        Opportunity TestContrib2 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today()-2,
        recordTypeID = DonationRTID,
        Amount = 200);
        insertOpps.add(TestContrib2);
        //Fourth Contribution, Type Donation
        Opportunity TestContrib1 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today()-3,
        recordTypeID = DonationRTID,
        Amount = 100);
        insertOpps.add(TestContrib1);
        //Fifth Contribution, Type Volunteer HOurs      //Fourth Contribution, Type Donation
        Opportunity TestContrib5 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today()-3,
        recordTypeID = [select id from RecordType where name = 'Volunteer Task' LIMIT 1].Id,
        Hours_Actual__c = 5);
        insertOpps.add(TestContrib5);

        insert insertOpps;

        //After inserting this payment for service, the last_contrib_amount should be 300 still, the last
        // donation is now 400 becasue membership is considered individual donation, last membership is 400
        Account checkAcct = [select Last_Contrib_Amount__c, Last_Donate_Amt__c, 
            Last_Member_Amt__c, Last_Membership_Date__c,
            (select amount, ContribOrder__c from opportunities order by ContribOrder__c) 
            from Account where name = 'TestAccount'][0];
        System.assertEquals(1,checkAcct.opportunities[0].ContribOrder__c);
        System.assertEquals(100,checkAcct.opportunities[0].Amount);
        System.assertEquals(2,checkAcct.opportunities[1].ContribOrder__c);
        System.assertEquals(3,checkAcct.opportunities[2].ContribOrder__c);
        System.assertEquals(200,checkAcct.opportunities[2].Amount);
        System.assertEquals(4,checkAcct.opportunities[3].ContribOrder__c);
        System.assertEquals(400,checkAcct.opportunities[3].Amount);
        System.assertEquals(5,checkAcct.opportunities[4].ContribOrder__c);
        System.assertEquals(300,checkAcct.opportunities[4].Amount);
        System.assertEquals(testContrib3.amount, checkAcct.Last_Contrib_Amount__c);
        System.assertEquals(TestContrib4.amount, checkAcct.Last_Donate_Amt__c);
        System.assertEquals(TestContrib4.amount, checkAcct.Last_Member_Amt__c);
        System.assertEquals(TestContrib4.closeDate, checkAcct.Last_Membership_Date__c);
        Contact CheckContact = [select id, LifetimeVolHours__c, Vol_Event_Count__c from Contact
                               where id =: testctct.Id];
        System.assertEquals(5,CheckContact.LifetimeVolhours__c);
        System.assertEquals(1,CheckContact.Vol_Event_Count__c);
        
    } // end of runAs
    } // end of MultipleContributionNew Order
 
}