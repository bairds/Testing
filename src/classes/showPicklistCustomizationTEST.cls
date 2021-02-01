/**
 * Created by Baird on 4/8/2019.
 */

@IsTest
private class showPicklistCustomizationTEST {
    @IsTest
    static void testBehavior() {
        PageReference pageRef = Page.showPicklistCustomizationPage;
        Test.setCurrentPage(pageRef);

        showPicklistCustomization SPC = new showPicklistCustomization();
        system.debug('Within the test, OuterResultsMap is ' + SPC.OuterResultsMap);
        system.assertEquals(7,SPC.OuterResultsMap.size());
    }
}