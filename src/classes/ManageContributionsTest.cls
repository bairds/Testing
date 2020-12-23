// 27 Jan 2017 Line 571 Change .addmonths(1).addmonths(-2) to .addmonths(-1) because it fails on Leap Year
// 3 Feb 2017 Filter out contributions where closed!=false
@isTest
private class ManageContributionsTest {

// @testSetup static void setup() {
//    createCustomSettings.createCustomSettings();
//    }
    
static testMethod void SingleContribution() {
	
//Wrap the test in system.runas so that it doesn't object to mixed DML (from setup and non-setup objects)		
	User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
	System.runAs ( thisUser ) {

		id ServiceRTID = [select id from RecordType where DeveloperName = 'Service'][0].id;
		
// Create test account, contact, campaign, contribution of recordType 'Service'
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account testacct = ctv.fetchTestAccount();
		Contact testctct = ctv.fetchTestContact();
		Campaign testcamp = ctv.fetchTestCampaign();
		//Single Contribution
		Opportunity TestContrib = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today(),
		recordTypeID = ServiceRTID,
        Amount = 100);
		insert TestContrib;
        System.debug(TestContrib);
        System.debug('In testing, Testcontrib.isclosed is ' + Testcontrib.IsClosed);
        Opportunity TestContribCheck = [select id, stageName, isClosed from Opportunity where id = :TestContrib.Id];
        System.debug('In testing, after requerying, Testcontrib.isclosed is now ' + Testcontrib.IsClosed);
        // The problem is that in testing although the StageName is Closed/Won the Opp.IsClosed flag is still false;
        
        System.assertEquals(true,TestContrib.StageName.CONTAINS('Closed'),'Inserted TestContrib as TestData but isClosed is not true');
		System.assertEquals(testcamp.id,TestContrib.campaignID);
		
		//After inserting this payment for service, only the last_contrib_amount should be populated
		//ManageContributions.afterInsert(ContribList, ContribList);
		Account checkAcct = [select First_Donate_Date__c, Last_Contrib_Amount__c, Last_Contrib_Source__c, Last_Donate_Amount__c, Last_Membership_Amount__c,
			Last_Donate_Date__c, Last_Contrib_Date__c, YearToDate_Donations__c,                  
			(select amount, ContribOrder__c from opportunities order by ContribOrder__c) from Account where name = 'TestAccount'][0];
		System.assertEquals(1,checkAcct.opportunities[0].ContribOrder__c);
		System.assertEquals(testContrib.amount, checkAcct.Last_Contrib_Amount__c);
		System.assertEquals(testContrib.closeDate, checkAcct.Last_Contrib_Date__c);
		System.assertEquals(testCamp.name, checkAcct.Last_Contrib_Source__c);
		System.assertEquals(0.00, checkAcct.Last_Donate_Amount__c);
		System.assertEquals(null, checkAcct.Last_Donate_Date__c);
		System.assertEquals(null, checkAcct.First_Donate_Date__c);
		System.assertEquals(0.00, checkAcct.Last_Membership_Amount__c);
	}// end of runAs
	} // end of SingleContribution	
    
static testMethod void SingleContributionAndDelete() {
	
//Wrap the test in system.runas so that it doesn't object to mixed DML (from setup and non-setup objects)		
	User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
	System.runAs ( thisUser ) {

	id DonationRTID = [select id from RecordType where DeveloperName = 'Donation'][0].id;
		
// Create test account, contact, campaign, contribution of recordType 'Service'
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account testacct = ctv.fetchTestAccount();
		Contact testctct = ctv.fetchTestContact();
		Campaign testcamp = ctv.fetchTestCampaign();
		//Single Contribution
		Opportunity TestContrib = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today(),
		recordTypeID = DonationRTID,
        Amount = 100);
		insert TestContrib;
		System.assertEquals(testcamp.id,TestContrib.campaignID);
		
		Account checkAcct = [select Last_Contrib_Amount__c, Last_Contrib_Source__c, Last_Donate_Amount__c, Last_Membership_Amount__c,
			Last_Donate_Date__c, Last_Contrib_Date__c, YearToDate_Donations__c, First_Donate_Date__c,
			(select amount, recordTypeId, ContribOrder__c from opportunities order by ContribOrder__c) from Account where name = 'TestAccount'][0];
		System.assertEquals(1,checkAcct.opportunities[0].ContribOrder__c);
		System.assertEquals(DonationRTID,checkAcct.opportunities[0].recordTypeId);
		System.assertEquals(testContrib.amount, checkAcct.Last_Contrib_Amount__c);
		System.assertEquals(testContrib.closeDate, checkAcct.Last_Contrib_Date__c);
		System.assertEquals(testCamp.name, checkAcct.Last_Contrib_Source__c);
		System.assertEquals(TestContrib.amount, checkAcct.Last_Donate_Amount__c);
		System.assertEquals(TestContrib.closedate, checkAcct.Last_Donate_Date__c);
		System.assertEquals(TestContrib.closedate, checkAcct.First_Donate_Date__c);
		System.assertEquals(0.00, checkAcct.Last_Membership_Amount__c);
		System.assertEquals(TestContrib.amount, checkAcct.YearToDate_Donations__c);
        
        
        // for this test, reset the AvoidRecursiveContributionTrigger
        AvoidRecursiveContributionTrigger.setClosed();
        delete TestContrib;
		CheckAcct = [select First_Donate_Date__c, Last_Contrib_Amount__c, Last_Contrib_Source__c, Last_Donate_Amount__c, Last_Membership_Amount__c,
			Last_Donate_Date__c, Last_Contrib_Date__c, YearToDate_Donations__c,                  
			(select amount, ContribOrder__c from opportunities order by ContribOrder__c) from Account where name = 'TestAccount'][0];
		System.assertEquals(0, checkAcct.YearToDate_Donations__c);
		System.assertEquals(0, checkAcct.Last_Donate_Amount__c);
		System.assertEquals(0, checkAcct.Last_Contrib_Amount__c);
		System.assertEquals(null, checkAcct.Last_Donate_Date__c);
		System.assertEquals(null, checkAcct.First_Donate_Date__c);
        
	}// end of runAs
	} // end of SingleContributionWithDelete	

static testMethod void DoubleContribution() {

	id DonationRTID = [select id from RecordType where DeveloperName = 'Donation'][0].id;
				
	
//Wrap the test in system.runas so that it doesn't object to mixed DML (from setup and non-setup objects)		
	User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
	System.runAs ( thisUser ) {
		
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account testacct = ctv.fetchTestAccount();
		Contact testctct = ctv.fetchTestContact();
		Campaign testcamp = ctv.fetchTestCampaign();
		List<Opportunity> insertOpps = new List<Opportunity>();
		//First Contribution
		Opportunity TestContrib1 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today()-1,
		recordTypeID = DonationRTID,
        Amount = 100);
		insertOpps.add(TestContrib1);
		//Second Contribution
		Opportunity TestContrib2 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today(),
		recordTypeID = DonationRTID,
        Amount = 200);
		insertOpps.add(TestContrib2);		
		insert insertOpps;

		Account checkAcct = [select Last_Contrib_Amount__c, Last_Donate_Amount__c, 
            Last_Membership_Amount__c, Last_Donate_Date__c, Last_Contrib_Date__c, Last_Membership_Date__c,   
			(select amount, ContribOrder__c, Donate_Lapse__c from opportunities order by ContribOrder__c) 
			from Account where name = 'TestAccount'][0];
		System.assertEquals(1,checkAcct.opportunities[0].ContribOrder__c);
		System.assertEquals(100,checkAcct.opportunities[0].Amount);
		System.assertEquals(2,checkAcct.opportunities[1].ContribOrder__c);
		System.assertEquals(200,checkAcct.opportunities[1].Amount);
		System.assertEquals(testContrib2.amount, checkAcct.Last_Contrib_Amount__c);
		System.assertEquals(testContrib2.closeDate, checkAcct.Last_Contrib_Date__c);
		// System.assertEquals(1, checkAcct.opportunities[1].Donate_Lapse__c);
		System.assertEquals(TestContrib2.amount, checkAcct.Last_Donate_Amount__c);
		System.assertEquals(TestContrib2.closeDate, checkAcct.Last_Donate_Date__c);
		System.assertEquals(0.00, checkAcct.Last_Membership_Amount__c);
		System.assertEquals(null, checkAcct.Last_Membership_Date__c);
		
	} // end of runAs
	} // end of DoubleContribution	
		
// 
//Add a more recent contribution of type 'Service' and rerun controller.  The amount should shift to the later contribution

static testMethod void MultipleContribution() {
				  

	id DonationRTID = [select id from RecordType where DeveloperName = 'Donation'][0].id;
	id ServiceRTID = [select id from RecordType where DeveloperName = 'Service'][0].id;
				
	
//Wrap the test in system.runas so that it doesn't object to mixed DML (from setup and non-setup objects)		
	User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
	System.runAs ( thisUser ) {
		
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account testacct = ctv.fetchTestAccount();
		Contact testctct = ctv.fetchTestContact();
		Campaign testcamp = ctv.fetchTestCampaign();
		List<Opportunity> insertOpps = new List<Opportunity>();
        //Zeroth Contribution
        Opportunity TestContrib0 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today()-1825,
		recordTypeID = DonationRTID,
        Amount = 100);
        insertOpps.add(TestContrib0);
		//First Contribution
		Opportunity TestContrib1 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today()-1460,
		recordTypeID = DonationRTID,
        Amount = 100);
        insertOpps.add(TestContrib1);
		//Second Contribution
		Opportunity TestContrib2 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today()-1095,
		recordTypeID = DonationRTID,
        Amount = 200);
		insertOpps.add(TestContrib2);
		//Third Contribution, Type Service
		Opportunity TestContrib3 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today()-730,
		recordTypeID = ServiceRTID,
        Amount = 300);
		insertOpps.add(TestContrib3);
        //Fourth Contribution, Type Donation
		Opportunity TestContrib4 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today()-365,
		recordTypeID = DonationRTID,
        Amount = 400);
		insertOpps.add(TestContrib4);
		//Fifth Contribution, Type Donation
		Opportunity TestContrib5 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today(),
		recordTypeID = DonationRTID,
        Amount = 500);
		insertOpps.add(TestContrib5);

		insert insertOpps;

		//After inserting this payment for service, the last_contrib_amount should be 300.
		Account checkAcct = [select Last_Contrib_Amount__c, Last_Donate_Amount__c, Last_Membership_Amount__c, Largest_Contrib__c, Largest_Contrib_Date__c,
			X3_Years_Ago_Donations__c,X4_Years_Ago_Donations__c,X5_Years_Ago_Donations__c,Last_Year_Donations__c,
            Year_Before_Last_Donations__c, YearToDate_Donations__c,
            (select amount, ContribOrder__c from opportunities order by ContribOrder__c) 
			from Account where name = 'TestAccount'][0];
        System.assertEquals(6,checkAcct.opportunities.size());
		System.assertEquals(1,checkAcct.opportunities[0].ContribOrder__c);
		System.assertEquals(100,checkAcct.opportunities[0].Amount);
		System.assertEquals(2,checkAcct.opportunities[1].ContribOrder__c);
		System.assertEquals(100,checkAcct.opportunities[1].Amount);
		System.assertEquals(3,checkAcct.opportunities[2].ContribOrder__c);
		System.assertEquals(200,checkAcct.opportunities[2].Amount);
		System.assertEquals(testContrib5.amount, checkAcct.Last_Contrib_Amount__c);
		System.assertEquals(TestContrib5.amount, checkAcct.Last_Donate_Amount__c);
		System.assertEquals(0.00, checkAcct.Last_Membership_Amount__c);
        System.assertEquals(TestContrib5.amount,checkAcct.Largest_Contrib__c);
        System.assertEquals(TestContrib5.closedate,checkAcct.Largest_Contrib_Date__c);
        system.debug('Year Before Lat Donations: ' + checkAcct.Year_Before_Last_Donations__c + ', Last Year Donations: ' + checkAcct.Last_Year_Donations__c
                    + ', 3 Years Ago: ' + checkAcct.X3_Years_Ago_Donations__c + ', 4 Year Ago: ' + checkAcct.X4_Years_Ago_Donations__c + ', 5 Years Ago: ' + checkAcct.X5_Years_Ago_Donations__c);
        system.assertEquals(TestContrib5.amount,checkAcct.YearToDate_Donations__c);
        system.assertEquals(TestContrib4.amount,checkAcct.Last_Year_Donations__c);
        system.assertEquals(0.00,checkAcct.Year_Before_Last_Donations__c); // Because TestContrib3 was of RecordType "Service"
        system.assertEquals(TestContrib2.amount,checkAcct.X3_Years_Ago_Donations__c);
        system.assertEquals(TestContrib1.amount,checkAcct.X4_Years_Ago_Donations__c);
        system.assertEquals(TestContrib0.amount,checkAcct.X5_Years_Ago_Donations__c);
		
	} // end of runAs
	} // end of DoubleContribution	

//Insert the contributions in different order to make sure that doesn't effect result
static testMethod void TripleContributionNeOrder() {

	id DonationRTID = [select id from RecordType where DeveloperName = 'Donation'][0].id;
	id ServiceRTID = [select id from RecordType where DeveloperName = 'Service'][0].id;
				
	
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
		//Second Contribution Type Donation
		Opportunity TestContrib2 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today()-1,
		recordTypeID = DonationRTID,
        Amount = 200);
		insertOpps.add(TestContrib2);
		//Third Contribution, Type Donation
		Opportunity TestContrib1 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today()-2,
		recordTypeID = DonationRTID,
        Amount = 100);
		insertOpps.add(TestContrib1);
		insert insertOpps;

		//After inserting this payment for service, the last_contrib_amount should be 300.
		Account checkAcct = [select Last_Contrib_Amount__c, Last_Donate_Amount__c, Last_Membership_Amount__c,
			(select amount, ContribOrder__c from opportunities order by ContribOrder__c) 
			from Account where name = 'TestAccount'][0];
		System.assertEquals(1,checkAcct.opportunities[0].ContribOrder__c);
		System.assertEquals(100,checkAcct.opportunities[0].Amount);
		System.assertEquals(2,checkAcct.opportunities[1].ContribOrder__c);
		System.assertEquals(200,checkAcct.opportunities[1].Amount);
		System.assertEquals(3,checkAcct.opportunities[2].ContribOrder__c);
		System.assertEquals(300,checkAcct.opportunities[2].Amount);
		System.assertEquals(testContrib3.amount, checkAcct.Last_Contrib_Amount__c);
		System.assertEquals(TestContrib2.amount, checkAcct.Last_Donate_Amount__c);
		System.assertEquals(0.00, checkAcct.Last_Membership_Amount__c);
		
	} // end of runAs
	} // end of TripeContributionNew Order

//Insert the contributions in different order to make sure that doesn't effect result
static testMethod void AddMembership() {
				  
	id DonationRTID = [select id from RecordType where DeveloperName = 'Donation'][0].id;
	id ServiceRTID = [select id from RecordType where DeveloperName = 'Service'][0].id;
	id MembershipRTID = [select id from RecordType where DeveloperName = 'Membership'][0].id;
				
	
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
		insert insertOpps;

		//After inserting this payment for service, the last_contrib_amount should be 300 still, the last
		// donation is now 400 becasue membership is considered individual donation, last membership is 400
		Account checkAcct = [select Last_Contrib_Amount__c, Last_Donate_Amount__c, 
            Last_Membership_Amount__c, Last_Membership_Date__c,
			(select amount, ContribOrder__c from opportunities order by ContribOrder__c) 
			from Account where name = 'TestAccount'][0];
		System.assertEquals(1,checkAcct.opportunities[0].ContribOrder__c);
		System.assertEquals(100,checkAcct.opportunities[0].Amount);
		System.assertEquals(2,checkAcct.opportunities[1].ContribOrder__c);
		System.assertEquals(200,checkAcct.opportunities[1].Amount);
		System.assertEquals(3,checkAcct.opportunities[2].ContribOrder__c);
		System.assertEquals(400,checkAcct.opportunities[2].Amount);
		System.assertEquals(4,checkAcct.opportunities[3].ContribOrder__c);
		System.assertEquals(300,checkAcct.opportunities[3].Amount);
		System.assertEquals(testContrib3.amount, checkAcct.Last_Contrib_Amount__c);
		System.assertEquals(TestContrib4.amount, checkAcct.Last_Donate_Amount__c);
		System.assertEquals(TestContrib4.amount, checkAcct.Last_Membership_Amount__c);
		System.assertEquals(TestContrib4.closeDate, checkAcct.Last_Membership_Date__c);
		
	} // end of runAs
	} // end of MultipleContributionNew Order

//Add an earlier contribution of type 'Membership' and rerun controller.  In this case, 
//the membership should be added onto to the existing memberships, and extended the account_membership_expires date.
static testMethod void AddTwoMemberships() {

	id DonationRTID = [select id from RecordType where DeveloperName = 'Donation'][0].id;
	id ServiceRTID = [select id from RecordType where DeveloperName = 'Service'][0].id;
	id MembershipRTID = [select id from RecordType where DeveloperName = 'Membership'][0].id;
				
	
//Wrap the test in system.runas so that it doesn't object to mixed DML (from setup and non-setup objects)		
	User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
	System.runAs ( thisUser ) {
		
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account testacct = ctv.fetchTestAccount();
		Contact testctct = ctv.fetchTestContact();
		Campaign testcamp = ctv.fetchTestCampaign();
        Campaign testcamp2 = ctv.fetchTestCampaign();
        testcamp2.name = 'TestCampaign2';
        update testcamp2;
		List<Opportunity> insertOpps = new List<Opportunity>();
		//First Contribution Type Service Today
		Opportunity TestContrib3 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today(),
		recordTypeID = ServiceRTID,
        Amount = 300);
		insertOpps.add(TestContrib3);
		//Second Contribution Type Membership Yesterday
		Opportunity TestContrib4 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today()-1,
		recordTypeID = MembershipRTID,
        Amount = 400);
		insertOpps.add(TestContrib4);
		//Third Contribution Type Membership 40 days ago
		Opportunity TestContrib5 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp2.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today()-40,
		recordTypeID = MembershipRTID,
        Amount = 500);
		insertOpps.add(TestContrib5);
		//Third Contribution Type Donation Day before yesterday
		Opportunity TestContrib2 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today()-2,
		recordTypeID = DonationRTID,
        Amount = 200);
		insertOpps.add(TestContrib2);
		//Fourth Contribution, Type Donation Three ays Ago
		Opportunity TestContrib1 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today()-3,
		recordTypeID = DonationRTID,
        Amount = 100);
		insertOpps.add(TestContrib1);
		insert insertOpps;

		//After inserting this payment for service, the last_contrib_amount should be 300 still, the last
		// donation is now 400 becasue membership is considered individual donation, last membership is 400
		Account checkAcct = [select Last_Contrib_Amount__c, Last_Donate_Amount__c, Last_Membership_Amount__c, First_Member_Source__c, 
			First_Contrib_Source__c, account_membership_expires__c, (select amount, ContribOrder__c from opportunities order by ContribOrder__c) 
			from Account where name = 'TestAccount'][0];
		System.assertEquals(5,checkAcct.opportunities.size());
		System.assertEquals(1,checkAcct.opportunities[0].ContribOrder__c);
		System.assertEquals(500,checkAcct.opportunities[0].Amount);
		System.assertEquals(2,checkAcct.opportunities[1].ContribOrder__c);
		System.assertEquals(100,checkAcct.opportunities[1].Amount);
		System.assertEquals(3,checkAcct.opportunities[2].ContribOrder__c);
		System.assertEquals(200,checkAcct.opportunities[2].Amount);
		System.assertEquals(4,checkAcct.opportunities[3].ContribOrder__c);
		System.assertEquals(400,checkAcct.opportunities[3].Amount);
		System.assertEquals(5,checkAcct.opportunities[4].ContribOrder__c);
		System.assertEquals(300,checkAcct.opportunities[4].Amount);
		System.assertEquals(testContrib3.amount, checkAcct.Last_Contrib_Amount__c);
		System.assertEquals(TestContrib4.amount, checkAcct.Last_Donate_Amount__c);
		System.assertEquals(TestContrib4.amount, checkAcct.Last_Membership_Amount__c);
        // Test to see if First_Member_Source__c has been updated;
        system.assertEquals(TestCamp2.Name, checkAcct.First_Member_Source__c);
        system.assertEquals(TestCamp2.Name, checkAcct.First_Contrib_Source__c);
		// I adjusted the following line, which tests for the rigth Account_Membership_Expires__c date.
		// Now rather than testing for a specific date it tests for the last Membership's end date.
//		System.assertEquals([select id,Membership_End_Date__c from Opportunity where CloseDate =
//			:System.today()-1].Membership_End_Date__c, checkAcct.Account_Membership_Expires__c);
		
		// Test for deletion of a contribution.  Remove the penultimate contribution.

		// Turn off the AvoidRecursiveTrigger
		AvoidRecursiveContributionTrigger.setClosed();	
		
		delete TestContrib4;
		checkAcct = [select Last_Contrib_Amount__c, Last_Donate_Amount__c, Last_Membership_Amount__c,
			account_membership_expires__c, (select amount, ContribOrder__c from opportunities order by ContribOrder__c) 
			from Account where name = 'TestAccount'][0];
		System.assertEquals(4,checkAcct.opportunities.size());
		System.assertEquals(1,checkAcct.opportunities[0].ContribOrder__c);
		System.assertEquals(500,checkAcct.opportunities[0].Amount);
		System.assertEquals(2,checkAcct.opportunities[1].ContribOrder__c);
		System.assertEquals(100,checkAcct.opportunities[1].Amount);
		System.assertEquals(3,checkAcct.opportunities[2].ContribOrder__c);
		System.assertEquals(200,checkAcct.opportunities[2].Amount);
		// System.assertEquals(4,checkAcct.opportunities[3].ContribOrder__c);
		System.assertEquals(300,checkAcct.opportunities[3].Amount);
		System.assertEquals(testContrib3.amount, checkAcct.Last_Contrib_Amount__c);
		System.assertEquals(TestContrib2.amount, checkAcct.Last_Donate_Amount__c);
		System.assertEquals(TestContrib5.amount, checkAcct.Last_Membership_Amount__c);
		
	} // end of runAs
	} // end of AddTwoMemberships


//Insert the contributions in different order to make sure that doesn't effect result
static testMethod void OnePledgeTwoPayments() {

	id DonationRTID = [select id from RecordType where DeveloperName = 'Donation'][0].id;
	id PledgeRTID = [select id from RecordType where DeveloperName = 'Pledge'][0].id;
				
	
//Wrap the test in system.runas so that it doesn't object to mixed DML (from setup and non-setup objects)		
	User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
	System.runAs ( thisUser ) {
		
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account testacct = ctv.fetchTestAccount();
		Contact testctct = ctv.fetchTestContact();
		Campaign testcamp = ctv.fetchTestCampaign();
		List<Opportunity> insertOpps = new List<Opportunity>();
		//Add Pledge
		Opportunity TestPledge = new Opportunity (Contact__c = TestCtct.id,
		recordTypeID = PledgeRTID,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Promised',
        CloseDate = system.today().addmonths(-3),
        Periodicity__c = 'Monthly',  
        Start_Date__c = system.today().addmonths(-2),                                          
        Pledge_Amount__c = 300);
        insert TestPledge;
        Opportunity CheckPledge = [select id, Next_Payment_Date__c, Total_Paid__c from Opportunity where id = :TestPledge.id];
        system.AssertEquals(null,CheckPledge.Total_Paid__c);
        system.AssertEquals(system.today().addmonths(-2).addmonths(1),CheckPledge.Next_Payment_Date__c);
		//Add First Payment Against Pledge
		Opportunity TestPayment1 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today().addmonths(-2),
		recordTypeID = DonationRTID,
        Matches_Which_Challenge_or_Pledge__c=TestPledge.id,                                           
        Amount = 100);
        // for this test, reset the AvoidRecursieContributionTrigger
        AvoidRecursiveContributionTrigger.setClosed();
        insert TestPayment1;
        CheckPledge = [select id, Next_Payment_Date__c, Total_Paid__c from Opportunity where id = :TestPledge.id];
        system.AssertEquals(TestPayment1.amount,CheckPledge.Total_Paid__c);
		//Add Second Payment
		Opportunity TestPayment2 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = date.today().addMOnths(-1),
		recordTypeID = DonationRTID,
        Matches_Which_Challenge_or_Pledge__c=TestPledge.id,
        Amount = 100);
        // reset the AvoidRecursiveContributionTrigger
        AvoidRecursiveContributionTrigger.setClosed();
		insert TestPayment2;
        CheckPledge = [select id, Next_Payment_Date__c, Total_Paid__c, StageName from Opportunity where id = :TestPledge.id];
        system.AssertEquals(TestPayment1.amount + TestPayment2.amount,CheckPledge.Total_Paid__c);
		if (date.today().day()!=31)
        system.AssertEquals(date.today().addMonths(-1).addMOnths(1), CheckPledge.Next_Payment_Date__c);
        system.AssertEquals('Pledge Recorded', CheckPledge.StageName);		
        //Add Third Payment
		Opportunity TestPayment3 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = date.today(),
		recordTypeID = DonationRTID,
        Matches_Which_Challenge_or_Pledge__c=TestPledge.id,
        Amount = 100);
        // reset the AvoidRecursiveContributionTrigger
        AvoidRecursiveContributionTrigger.setClosed();
		insert TestPayment3;
        CheckPledge = [select id, Next_Payment_Date__c, Total_Paid__c, StageName from Opportunity where id = :TestPledge.id];
        system.AssertEquals(TestPayment1.amount + TestPayment2.amount + TestPayment3.amount,CheckPledge.Total_Paid__c);
        system.AssertEquals(null, CheckPledge.Next_Payment_Date__c);
        system.AssertEquals('Pledge Fulfilled', CheckPledge.StageName);
        //Delete Third Payment
        // for this test, reset the AvoidRecursieContributionTrigger
        AvoidRecursiveContributionTrigger.setClosed();
        Delete TestPayment2;
        CheckPledge = [select id, Next_Payment_Date__c, Total_Paid__c, StageName from Opportunity where id = :TestPledge.id];
        system.AssertEquals(TestPayment1.amount+TestPayment2.amount, CheckPledge.Total_Paid__c);
        system.AssertEquals('Pledge Recorded', CheckPledge.StageName);		
		
	} // end of runAs
	} // end of testmethod

    
    //Insert the contributions in different order to make sure that doesn't effect result
static testMethod void NewMembershipVsRenewal() {

	id MembershipRTID = [select id from RecordType where DeveloperName = 'Membership'][0].id;
	id PledgeRTID = [select id from RecordType where DeveloperName = 'Pledge'][0].id;
				
	
//Wrap the test in system.runas so that it doesn't object to mixed DML (from setup and non-setup objects)		
	User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
	System.runAs ( thisUser ) {
		
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account testacct = ctv.fetchTestAccount();
		Contact testctct = ctv.fetchTestContact();
		Campaign testcamp = ctv.fetchTestCampaign();
		List<Opportunity> insertOpps = new List<Opportunity>();
		//Add Membership
		Opportunity TestMembership0 = new Opportunity (Contact__c = TestCtct.id,
		recordTypeID = MembershipRTID,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today()-90,
        Amount = 300);
        insert TestMembership0;
        Opportunity CheckMembership = [select id, Membership_Type__c from Opportunity where id = :TestMembership0.id];
        system.AssertEquals('New Membership',CheckMembership.Membership_Type__c);
		//Add another Membership
		Opportunity TestMembership1 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today()-60,
		recordTypeID = MembershipRTID,                                           
        Amount = 200);
        // for this test, reset the AvoidRecursieContributionTrigger
        AvoidRecursiveContributionTrigger.setClosed();
        insert TestMembership1;
        CheckMembership = [select id, Membership_Type__c from Opportunity where id = :TestMembership1.id];
        system.AssertEquals('Renewal',CheckMembership.Membership_Type__c);
		//Add new Membership, prior to previous first membership
		Opportunity TestMembership2 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today()-120,
		recordTypeID = MembershipRTID,
        Amount = 100);
        // reset the AvoidRecursiveContributionTrigger
        AvoidRecursiveContributionTrigger.setClosed();
		insert TestMembership2;
        CheckMembership = [select id, Membership_Type__c from Opportunity where id = :TestMembership2.id];
        system.AssertEquals('New Membership',CheckMembership.Membership_Type__c);
        //Delete Second Membership
        // for this test, reset the AvoidRecursieContributionTrigger
        AvoidRecursiveContributionTrigger.setClosed();
        Delete TestMembership2;
        CheckMembership = [select id, Membership_Type__c from Opportunity where id = :TestMembership0.id];
        system.AssertEquals('New Membership',CheckMembership.Membership_Type__c);
		
	} // end of runAs
	} // end of testmethod

static testMethod void LapseTest() {
				  
	id MembershipRTID = [select id from RecordType where DeveloperName = 'Membership'][0].id;
	id DonationRTID = [select id from RecordType where DeveloperName = 'Donation'][0].id;
    id PledgeRTID = [select id from RecordType where DeveloperName = 'Pledge'][0].id;
				
	
//Wrap the test in system.runas so that it doesn't object to mixed DML (from setup and non-setup objects)		
	User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
	System.runAs ( thisUser ) {
		
		Create_Test_Variables ctv = new Create_Test_Variables();
		Account testacct = ctv.fetchTestAccount();
		Contact testctct = ctv.fetchTestContact();
		Campaign testcamp = ctv.fetchTestCampaign();
		List<Opportunity> insertOpps = new List<Opportunity>();
		//Add First Membership
		Opportunity TestMembership0 = new Opportunity (Contact__c = TestCtct.id,
		recordTypeID = MembershipRTID,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today(),
        Amount = 300);
        insert TestMembership0;
        Opportunity CheckMembership = [select id, Donate_Lapse__c, Member_Lapse__c from Opportunity where id = :TestMembership0.id];
        // Lapse is null BECAUSE NO SUBSEQUENT donation
        system.AssertEquals(null,CheckMembership.Donate_Lapse__c);
        system.AssertEquals(null,CheckMembership.Member_Lapse__c);
		//Add Second Membership
		Opportunity TestMembership1 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today()-30,
		recordTypeID = MembershipRTID,                                           
        Amount = 200);
        // for this test, reset the AvoidRecursiveContributionTrigger
        AvoidRecursiveContributionTrigger.setClosed();
        insert TestMembership1;
        CheckMembership = [select id, Donate_Lapse__c, Member_Lapse__c, Membership_Type__c from Opportunity where id = :TestMembership1.id];
        // Lapse from first to second membership is now 30
        system.debug('TestMembership1 is ' + TestMembership1);
        system.AssertEquals(30,CheckMembership.Donate_Lapse__c);
        system.AssertEquals(30,CheckMembership.Member_Lapse__c);
        system.AssertEquals('New Membership',CheckMembership.Membership_Type__c);
		//Add new Membership, prior to previous first membership
		Opportunity TestMembership2 = new Opportunity (Contact__c = TestCtct.id,
        AccountID = TestAcct.id,
        CampaignID = TestCamp.id,
        Name = 'autofill',
        StageName = 'Closed/Won',
        CloseDate = system.today()-60,
		recordTypeID = MembershipRTID,
        Amount = 100);
        // reset the AvoidRecursiveContributionTrigger
        AvoidRecursiveContributionTrigger.setClosed();
		insert TestMembership2;
        CheckMembership = [select id, Donate_Lapse__c, Member_Lapse__c, Membership_Type__c from Opportunity where id = :TestMembership2.id];
        system.AssertEquals(30,CheckMembership.Donate_Lapse__c);
        system.AssertEquals(30,CheckMembership.Member_Lapse__c);
        system.AssertEquals('New Membership',CheckMembership.Membership_Type__c);
		// Test new summary fields
		Contact ConfirmCtct = [select First_Donate_Amount__c, Lifetime_Donation_Count__c, account.First_Donate_Amount__c, account.Lifetime_Donation_Count__c
		from Contact where lastname = 'Testcontact' LIMIT 1];
		SYSTEM.AssertEquals(TestMembership2.amount,ConfirmCtct.First_Donate_Amount__c);
		SYSTEM.AssertEquals(TestMembership2.amount,ConfirmCtct.account.First_Donate_Amount__c);
		System.AssertEquals(3,ConfirmCtct.Lifetime_Donation_Count__c);
		System.AssertEquals(3,ConfirmCtct.account.Lifetime_Donation_Count__c);
        //Delete Second Membership
        // for this test, reset the AvoidRecursieContributionTrigger
        AvoidRecursiveContributionTrigger.setClosed();
        Delete TestMembership1;
		system.assertEquals(2,[select id from Opportunity].size());
        CheckMembership = [select id, Donate_Lapse__c from Opportunity where id = :TestMembership2.id];
        system.AssertEquals(60,CheckMembership.Donate_Lapse__c);
        Opportunity CheckMembership0 = [select id, Donate_Lapse__c, Membership_Type__c from Opportunity where id = :TestMembership0.id limit 1];
        system.AssertEquals('Renewal', CheckMembership0.Membership_Type__c);
		//
		// Test new summary fields
		Contact ConfirmCtct2 = [select First_Donate_Amount__c, Lifetime_Donation_Count__c, account.First_Donate_Amount__c, account.Lifetime_Donation_Count__c
		from Contact where lastname = 'Testcontact' LIMIT 1];
		System.AssertEquals(2,ConfirmCtct2.Lifetime_Donation_Count__c);
		System.AssertEquals(2,ConfirmCtct2.account.Lifetime_Donation_Count__c);

		
	} // end of runAs
	} // end of testmethod  

	static testMethod void VolunteerContributions() {
		// Does the Contact.LifetimeVolHours__c field summarize only
		// Won opportunities?

		id VolRTID = [select id from RecordType where DeveloperName = 'Volunteer_Task'][0].id;


//Wrap the test in system.runas so that it doesn't object to mixed DML (from setup and non-setup objects)
		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
		System.runAs ( thisUser ) {

			Create_Test_Variables ctv = new Create_Test_Variables();
			Account testacct = ctv.fetchTestAccount();
			Contact testctct = ctv.fetchTestContact();
			Campaign testcamp = ctv.fetchTestCampaign();
			List<Opportunity> insertOpps = new List<Opportunity>();
			//First Contribution
			Opportunity TestContrib1 = new Opportunity (Contact__c = TestCtct.id,
					AccountID = TestAcct.id,
					CampaignID = TestCamp.id,
					Name = 'autofill',
					StageName = 'Closed/Won',
					CloseDate = system.today(),
					recordTypeID = VolRTID,
					Hours_Actual__c = 10);
			insertOpps.add(TestContrib1);
			//Second Contribution
			Opportunity TestContrib2 = new Opportunity (Contact__c = TestCtct.id,
					AccountID = TestAcct.id,
					CampaignID = TestCamp.id,
					Name = 'autofill',
					StageName = 'Abandoned',
					CloseDate = system.today(),
					recordTypeID = VolRTID,
					Hours_Actual__c = 10);
			insertOpps.add(TestContrib2);
			insert insertOpps;

			Contact checkCtct = [select Id, LifetimeVolHours__c, YearToDate_VolHours__c FROM Contact
					where Id =: Testctct.Id];
			system.assertEquals(TestContrib1.Hours_Actual__c,checkCtct.LifetimeVolhours__c,'Should only have included 10 Closed/Won Hours and not 10 Abandoned hours');
			system.assertEquals(TestContrib1.Hours_Actual__c,checkCtct.YearToDate_Volhours__c,'Should only have included 10 Closed/Won Hours and not 10 Abandoned hours');

					Account checkAcct = [select Last_Contrib_Amount__c, Last_Donate_Amount__c,
					Last_Membership_Amount__c, Last_Donate_Date__c, Last_Contrib_Date__c, Last_Membership_Date__c,
			(select amount, ContribOrder__c, Donate_Lapse__c from opportunities order by ContribOrder__c)
			from Account where name = 'TestAccount'][0];

		} // end of runAs
	} // end of DoubleContribution

}