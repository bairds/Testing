/**
 * Created by Baird on 11/22/2020.
 */

@IsTest
private class CopyACRolesTEST {
    @TestSetup
    static void SetUpTest(){
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        Account OtherAccount = New Account(Name = 'Other Account');
        Insert OtherAccount;
        List<Contact> ListCtcts = new List<Contact>();
        Contact TestCtct = ctv.fetchTestContact();
        Contact TestCtct2 = new Contact(
                AccountId = TestAcct.Id,
                FirstName = 'Test',
                LastName = 'Contact2'
        );
                ListCtcts.add(TestCtct2);
        Contact TestCtct3 = new Contact(
                AccountId = TestAcct.Id,
                FirstName = 'Test',
                LastName = 'Contact3'
        );
        ListCtcts.add(TestCtct3);
        Contact OtherCtct = new Contact(
                LastName = 'Contact',
                FirstName = 'Other',
                AccountId = OtherAccount.Id
        );
        ListCtcts.add(OtherCtct);
        insert ListCtcts;
        List<AccountContactRole> ListACRos = new List<AccountContactRole>();
        AccountContactRole ACR2 = New AccountContactRole(
                AccountId = TestAcct.Id,
                ContactId = TestCtct2.Id,
                Role = 'Influencer'
        );
        ListACRos.add(ACR2);
        AccountContactRole ACR3 = New AccountContactRole(
                AccountId = TestAcct.Id,
                ContactId = TestCtct3.Id,
                Role = 'Helper'
        );
        ListACRos.add(ACR3);
        AccountContactRole ACR4 = New AccountContactRole(
                AccountId = TestAcct.Id,
                ContactId = OtherCtct.Id,
                Role = 'Influencer'
        );

    }

    @IsTest
    static void TestCopyRolestoRelations() {
        Account TestAcct = [SELECT Id from Account WHERE
        Name = 'TestAccount' limit 1];
        List<Id> AcctIds = new List<Id>();
        AcctIds.add(TestAcct.Id);
        CopyACRolesToACRelationships CAC = new CopyACRolesToACRelationships();
        CAC.SimpleCopyRolesToRelations(AcctIds);

        List<AccountContactRelation> Results = [SELECT Id, AccountId, Account.Name, ContactId,Contact.FirstName,IsDirect,
        IsPrimary__c,Roles,Contact.LastName FROM AccountContactRelation];
        System.assertEquals(4,Results.size());
        For (AccountContactRelation ACR : Results){
            if (ACR.Contact.LastName == 'TestContact')
                system.assertEquals(true,ACR.IsPrimary__c,'This is the first contact, the ACRole should have isPrimary, so the ACRelation should have isPrimary__c');
            if (ACR.Contact.LastName == 'Contact' && ACR.Contact.FirstName == 'Other' && ACR.Account.Name == 'TestAccount') {
                system.Debug('ACR is ' + ACR + ' and Account Name is ' + ACR.Account.Name);
                system.assertEquals('Influencer', ACR.Roles, 'Should have inserted Influencer in the ACRelation');
                system.assertEquals(false, ACR.IsDirect, 'This ACRelation is to a contact in another account.');
            }
        }
    }
}