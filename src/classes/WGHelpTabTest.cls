/**
 * Created by Baird on 5/2/2019.
 */


@IsTest
private class WGHelpTabTest {
    @IsTest
    static void testBehavior() {
        PageReference pageRef = Page.WG_Help_Tab;
        Test.setCurrentPage(pageRef);

        WGHelpTab WGHT = new WGHelpTab();
        system.assertEquals(18,WGHT.OrgID18.length(),'WGHelpTab controller should have brought back and OrgId of length 18.');
        system.assertEquals('BaseURL',WGHT.BaseURL);
    }
}