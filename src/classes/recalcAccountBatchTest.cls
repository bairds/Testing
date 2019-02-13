// Updated to test for last_donate_date__c on 1 May 2015

@isTest
private class recalcAccountBatchTest {

    static testMethod void recalcAccountBatchTest() {

//INSERT Donations for TestContact
        Opportunity[] CYOps;
        Opportunity[] LYOps;
        Opportunity[] YBLOps;
        Opportunity[] AncientOps;
        Opportunity[] VolTasks;
        Opportunity Grant;
        Opportunity AncientOp;
        Opportunity AncientOp2;
        Campaign Testcampaign = new Campaign();
        Testcampaign.Name = 'Testcampaign';
        //Testcampaign.RecordtypeID = [select id from recordtype where name = 'Fundraising Activity'].id;
        insert Testcampaign;
        Account Testaccount = new Account (Name = 'TestAccount');
        insert Testaccount;
        Contact TestContact = new Contact (FirstName = 'Test', LastName = 'TestContact', Email = 'testcontact@dontbotherme.org', AccountId = Testaccount.Id);
        insert TestContact;
        Id membershipRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership').getRecordTypeId();

        List<Opportunity> InsertOpps = new List<Opportunity>();
//insert current year donations
        CYOps = new Opportunity[3];
        //CYOCRs = new OpportunityContactRole[3];
        for (Integer I = 0; I < 3; I++) {
            CYOps[I] = new Opportunity(Name = 'Test ' + String.valueOf(I),
                    Amount = 100,
                    CampaignId = Testcampaign.Id,
                    AccountId = Testaccount.Id,
                    Contact__c = TestContact.Id,
                    RecordTypeId = [select Id from RecordType where Name = 'Donation'].Id,
                    StageName = 'Closed Won',
                    CloseDate = System.today());
            InsertOpps.add(CYOps[I]);
        }

// Insert grant, which should not appear in totals
            Grant = new Opportunity(
                    Name = 'TestGrant',
                    Amount = 100000,
                    CampaignId = Testcampaign.Id,
                    AccountId = Testaccount.Id,
                    Contact__c = TestContact.Id,
                    RecordTypeId = [select Id from RecordType where Name = 'Grant'].Id,
                    StageName = 'Closed Won',
                    CloseDate = System.today());
            InsertOpps.add(Grant);

//insert last year donations
            LYOps = new Opportunity[2];
            for (integer I = 0; I < 2; I++) {
                LYOps[I] = new Opportunity(Name = 'Test ' + String.valueOf(I),
                        Amount = 101,
                        CampaignId = Testcampaign.Id,
                        AccountId = Testaccount.Id,
                        Contact__c = TestContact.Id,
                        RecordTypeId = membershipRTID,
                        StageName = 'Closed Won',
                        CloseDate = System.today().addYears(-I-1));
                InsertOpps.add(LYOps[I]);
            }

//insert year before last donations
            YBLOps = new Opportunity[2];
            for (integer I = 0; I < 2; I++) {
                YBLOps[I] = new Opportunity(Name = 'Test ' + String.valueOf(I),
                        Amount = 100,
                        CampaignId = Testcampaign.Id,
                        AccountId = Testaccount.Id,
                        Contact__c = TestContact.Id,
                        RecordTypeId = [select Id from RecordType where Name = 'Donation'].Id,
                        StageName = 'Closed Won',
                        CloseDate = System.today() - 730);
                InsertOpps.add(YBLOps[I]);
            }

//insert ancient donations
        AncientOps = new Opportunity[2];
        for (integer I = 0; I < 2; I++) {
            AncientOps[I] = new Opportunity(Name = 'Test Ancient ' + String.valueOf(I),
                    Amount = 500,
                    CampaignId = Testcampaign.Id,
                    AccountId = Testaccount.Id,
                    Contact__c = TestContact.Id,
                    RecordTypeId = [select Id from RecordType where Name = 'Major Donation'].Id,
                    StageName = 'Closed Won',
                    CloseDate = System.today() - 1200);
            InsertOpps.add(AncientOps[I]);
        }

//insert ancient donations
        VolTasks = new Opportunity[2];
        for (integer I = 0; I < 2; I++) {
            VolTasks[I] = new Opportunity(Name = 'Test VolTask ' + String.valueOf(I),
                    Hours_Actual__c = 500,
                    CampaignId = Testcampaign.Id,
                    AccountId = Testaccount.Id,
                    Contact__c = TestContact.Id,
                    RecordTypeId = [select Id from RecordType where Name = 'Volunteer Task'].Id,
                    StageName = 'Completed',
                    CloseDate = System.today() - 1200 - I);
            InsertOpps.add(VolTasks[I]);
        }

//insert custom settings
           //  createCustomSettings.createCustomSettings();
            insert InsertOpps;

            recalcAccountInvokeBatch rAIB = new recalcAccountInvokeBatch();
            Test.startTest();
            rAIB.invokeBatch();
            Test.stopTest();


//test to see whether account giving fields are updated

            Account a = [
                    select Id, Last_Donate_Amount__c, Last_Contrib_Source__c, Account_Membership_Expires__c,
                            Last_Membership_Amount__c, Last_Membership_Date__c, First_Contrib_Source__c, First_Contrib_Cat__c
                    from Account
                    where Id = :Testaccount.Id
            ];

            System.assertEquals(100.00, a.Last_Donate_Amount__c);
            System.assertEquals('Testcampaign', a.Last_Contrib_Source__c);
            System.assertEquals(101, a.Last_Membership_Amount__c);
            System.assertEquals(system.now().date().addyears(-1), a.Last_Membership_Date__c);
            //System.assertEquals(System.Today(),a.account_membership_expires__c);
            System.assertEquals('Testcampaign', a.First_Contrib_Source__c);
            System.assertEquals('Volunteer Task', a.First_Contrib_Cat__c);

        Contact c = [select id, last_donate_amt__c, last_contrib_Amt__c, first_contrib_source__c, first_contrib_cat__c, LifetimeVolhours__c
        from Contact where id = :TestContact.id];

        system.assertEquals(100.00,c.last_donate_amt__c);
        system.assertEquals(100000.00,c.Last_Contrib_Amt__c);
        system.assertEquals('Testcampaign',c.first_contrib_source__c);
        system.assertEquals('Volunteer Task',c.first_contrib_cat__c);
        system.assertEquals(1000,c.LifetimeVolhours__c);
    }
}