/**
 * Created by Baird on 7/18/2020.
 */

@IsTest
private class approveGuestUserEditsTEST {
    @TestSetup
    static void setupGUUs(){
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAccount = ctv.fetchTestAccount();
        Id UnknownCampId = WGHelpers.getUnknownCampaignId();
        List<Contact> ListCtcts = new List<Contact>();
        For (integer i=0;i<9;i++) {
            Contact Ctct = new Contact(
                    FirstName = 'Test',
                    LastName = 'Tester' + i,
                    Email = 'test' + i + '@tester.com',
                    AccountId = TestAccount.Id
            );
            ListCtcts.add(Ctct);
        }
        Insert ListCtcts;
        List<GuestUserUpdate__c> ListGUUs = new List<GuestUserUpdate__c>();
        For (integer i=0;i<9;i++){
            GuestUserUpdate__c newGUU = new GuestUserUpdate__c(
              FirstName__c='Test',
                    LastName__c='Tester'+i,
                    Email__c='test'+i+'@tester.com',
                    Processing_Status__c='Review',
                    RelatedContact__c=ListCtcts[i].Id
            );
            ListGUUs.add(newGUU);
        }
        // One of the nine should not appear in the list
        // because it is set to rejected
        ListGUUs[8].Processing_Status__c='Rejected';
        ListGUUs[0].Email__c='ChangedTest8@tester.com';
        insert ListGUUs;
        List<Opportunity> ListOpps = new List<Opportunity>();
        For (integer i=0;i<9;i++){
            Opportunity newOpp = new Opportunity(
                    Contact__c=ListCtcts[i].Id,
                    Description='Description of work',
                    Hours_Actual__c=2,
                    StageName='Task Submitted',
                    CloseDate=system.today(),
                    AccountId = TestAccount.Id,
                    CampaignId = UnknownCampId,
                    Name = 'VolTask'+i
            );
            ListOpps.add(newOpp);
        }
        ListOpps[8].StageName='Task Rejected';
        insert ListOpps;
    }
    @IsTest
    static void processAll() {
        PageReference pageRef = Page.ApproveGuestUserEdits;
        Test.setCurrentPage(pageRef);
        approveGuestUserEdits AMGE = new approveGuestUserEdits();
        system.assertEquals(8,AMGE.GUUs.size());
        // Change one more processing status
        // Only 7 should go into the processing
        AMGE.GUUs[1].Processing_Status__c = 'Rejected';
        AMGE.GUUs[2].MailingStreet__c = 'New Mailing Street #111';
        AMGE.submitEdits();
        List<Contact> Results = [SELECT AccountId from Contact where email = 'ChangedTest8@tester.com'];
        system.AssertEquals(1,results.size(),'Should have found one Contact with a changed email.');
        Results = [SELECT AccountId, Account.BillingStreet, Contact.MailingStreet from Contact where email = 'test2@tester.com'];
        system.AssertEquals('New Mailing Street #111',Results[0].Account.BillingStreet,'Should have changed Account Address.');
    }

    @IsTest
    static void protectedAccountAddress() {
        PageReference pageRef = Page.ApproveGuestUserEdits;
        Test.setCurrentPage(pageRef);
        approveGuestUserEdits AMGE = new approveGuestUserEdits();
        system.assertEquals(8,AMGE.GUUs.size());
        // Change one more processing status
        // Only 7 should go into the processing
        AMGE.GUUs[1].Processing_Status__c = 'Rejected';
        AMGE.GUUs[2].MailingStreet__c = 'New Mailing Street #111';
        // Protect the contact from account address changes, and vice versa
        AMGE.CtctMap.get(AMGE.GUUs[2].RelatedContact__c).Protected__c = true;
        AMGE.submitEdits();
        List<Contact> Results = [SELECT AccountId from Contact where email = 'ChangedTest8@tester.com'];
        system.AssertEquals(1,results.size(),'Should have found one Contact with a changed email.');
        Results = [SELECT MailingStreet from Contact where id =: AMGE.GUUs[2].RelatedContact__c];
        system.AssertEquals('New Mailing Street #111',results[0].MailingStreet,'Should have found one Contact with a changed email.');
        Results = [SELECT AccountId, Account.BillingStreet, Contact.MailingStreet from Contact where email = 'test2@tester.com'];
        system.AssertNotEquals('New Mailing Street #111',Results[0].Account.BillingStreet,'Should have changed Account Address.');
    }
}