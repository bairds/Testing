/**
 * Created by Baird on 1/22/2021.
 */

@IsTest
private class ManageOppContactRsTEST {
    @IsTest
    static void insertOppWoutPrimaryContributor() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Contact TestContact = ctv.fetchTestContact();
        Opportunity TestOpp = ctv.fetchTestOpportunity();
        system.assertEquals(TestOpp.Contact__c, TestContact.Id, 'After creating the first opportunity, the Primary Contributor should be populated.');
        // Delete Contact__c;
        TestOpp.Contact__c = null;
        // Delete the OpportunityContactRole
        OpportunityContactRole ocr = [SELECT Id from OpportunityContactRole
        WHERE ContactId =: TestContact.Id AND OpportunityId =: TestOpp.Id];
        DELETE ocr;
        system.assertEquals(TestOpp.Contact__c, null, 'After deleting TestOpp.Contact__c, it should be null.');
        // Now does creating a new contact role also trigger the OCRTrigger to
        // populate the Opp.Contact__c field?
        OpportunityContactRole ocr2 = new OpportunityContactRole(
                Role = 'Primary',
                IsPrimary = true,
                ContactId = TestContact.Id,
                OpportunityId = TestOpp.Id
        );
        List<OpportunityContactRole> updateOCRs = new List<OpportunityContactRole>();
        updateOCRS.add(ocr2);
        ManageOppContactRs.afterInsert(UpdateOCRs);
        Opportunity ResultOpp = [SELECT Id, Contact__c from Opportunity];
        system.assertEquals(ResultOpp.Contact__c,TestContact.Id,'After inserting Primary OCR, Contact__c should have been restored to TestContact.Id');
    }
}