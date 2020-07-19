/**
 * Created by Baird on 7/18/2020.
 */

@IsTest
private class ApproveMultipoleGUUEditsTEST {
    @TestSetup
    static void setupGUUs(){
        List<Contact> ListCtcts = new List<Contact>();
        For (integer i=0;i<9;i++) {
            Contact Ctct = new Contact(
                    FirstName = 'Test',
                    LastName = 'Tester' + i,
                    Email = 'test' + i + '@tester.com'
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
        List<GUUTask__c> ListGUUTs = new List<GUUTask__c>();
        For (integer i=0;i<9;i++){
            GUUTask__c newGUUT = new GUUTask__c(
                    GuestUserUpdate__c=ListGUUs[i].Id,
                    Description__c='Description of work',
                    Hours__c=2,
                    Processing_Status__c='Review'
            );
            ListGUUTs.add(newGUUT);
        }
        ListGUUTs[8].Processing_Status__c='Rejected';
        insert ListGUUTs;
    }
    @IsTest
    static void processAll() {
        PageReference pageRef = Page.ApproveMultipleGUUEdits;
        Test.setCurrentPage(pageRef);
        ApproveMultipleGUUEdits AMGE = new ApproveMultipleGUUEdits();
        system.assertEquals(8,AMGE.GUUs.size());
        // Change one more processing status
        // Only 7 should go into the processing
        AMGE.GUUs[1].Processing_Status__c = 'Rejected';
        AMGE.submitEdits();
        system.AssertEquals(1,[SELECT Id from Contact where email = 'ChangedTest8@tester.com'].size(),'Should have found one Contact with a changed email.');

    }
}