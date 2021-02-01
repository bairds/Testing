/**
 * Created by Baird on 1/27/2021.
 */

@IsTest
private class ManageACRelationsTEST {

    @IsTest
    static void InsertFirstContactOnAccount() {
        // Turn on trigger for test
        WGHelpers.BManageACRelations = true;
        WGhelpers.BManageContacts = true;
        Account TestAcct = new Account(
                Name = 'TestAcct'
        );
        insert TestAcct;
        Contact TestCtct = new Contact(
                LastName = 'TestContact',
                AccountId = TestAcct.Id
        );
        insert TestCtct;
        // Because this is a direct relation, the ACRelation is created.

        // Check that there's an ACRelation created with IsPrimary == true
        List<AccountContactRelation> results = [
                SELECT Id, AccountId, ContactId, IsPrimary__c
                from AccountContactRelation
                WHERE AccountId = :TestAcct.Id AND ContactId = :TestCtct.Id
        ];
        system.assertEquals(true, results[0].IsPrimary__c, 'The default ACRelation has been created, and IsPrimary should be true.');
    }

    @IsTest
    static void InsertSecondContactOnAccount() {
        WGHelpers.BManageACRelations = true;
        WGhelpers.BManageContacts = true;
        Account TestAcct = new Account(
                Name = 'TestAcct'
        );
        insert TestAcct;
        Contact TestCtct = new Contact(
                LastName = 'TestContact',
                AccountId = TestAcct.Id
        );
        insert TestCtct;
        // Because this is a direct relation, the ACRelation is created.

        // Check that there's an ACRelation created with IsPrimary == true
        List<AccountContactRelation> results = [
                SELECT Id, AccountId, ContactId, IsPrimary__c
                from AccountContactRelation
                WHERE AccountId = :TestAcct.Id AND ContactId = :TestCtct.Id
        ];
        system.assertEquals(true, results[0].IsPrimary__c, 'The default ACRelation has been created, and IsPrimary should be true.');

        // Insert a second contact
        Contact TestCtct2 = new Contact(
                LastName = 'TestContact2',
                AccountId = TestAcct.Id
        );
        insert TestCtct2;
        // Because this is a direct relation, the ACRelation is created.

        results = [
                SELECT Id, AccountId, ContactId, Contact.LastName, IsPrimary__c
                from AccountContactRelation
                WHERE AccountId = :TestAcct.Id
        ];
        system.assertEquals(2, results.size(), 'Should have found two ACRelations.');
        system.debug('The two ACRelations created are ' + results);
        for (AccountContactRelation acr : results) {
            if (acr.ContactId == TestCtct.Id) {
                system.assertEquals(true, acr.IsPrimary__c, 'For the first ACRelation IsPrimary should be true.');
            } else {
                if (acr.ContactId == TestCtct2.Id) {
                    system.assertEquals(false, acr.IsPrimary__c, 'For the second ACRelation IsPrimary should be false.');
                }
            }
        }
    }

    @IsTest
    static void updateSecondACRToPrimary() {// Turn off trigger so I can test just the code
        WGHelpers.BManageACRelations = true;
        WGhelpers.BManageContacts = true;
        Account TestAcct = new Account(
                Name = 'TestAcct'
        );
        insert TestAcct;
        Contact TestCtct = new Contact(
                LastName = 'TestContact',
                AccountId = TestAcct.Id
        );
        insert TestCtct;
        // Because this is a direct relation, the ACRelation is created.

        // Insert a second contact
        Contact TestCtct2 = new Contact(
                LastName = 'TestContact2',
                AccountId = TestAcct.Id
        );
        insert TestCtct2;
        // Because this is a direct relation, the ACRelation is created.

        List<AccountContactRelation> results = [
                SELECT Id, AccountId, ContactId, Contact.LastName, IsPrimary__c
                from AccountContactRelation
                WHERE AccountId = :TestAcct.Id
        ];
        system.assertEquals(2, results.size(), 'Should have found two ACRelations.');
        system.debug('The two ACRelations created are ' + results);
        for (AccountContactRelation acr : results) {
            if (acr.ContactId == TestCtct.Id) {
                system.assertEquals(true, acr.IsPrimary__c, 'For the first ACRelation IsPrimary should be true.');
            } else {
                if (acr.ContactId == TestCtct2.Id) {
                    system.assertEquals(false, acr.IsPrimary__c, 'For the second ACRelation IsPrimary should be false.');
                }
            }
        }
        AccountContactRelation acrel2 = [
                SELECT Id,IsPrimary__c
                from AccountContactRelation
                WHERE AccountId = :TestAcct.Id AND ContactId = :TestCtct2.Id
        ];
        acrel2.IsPrimary__c = true;
        update acrel2;
        // IsPrimary should have switched between the accounts.
        results = [
                SELECT Id, AccountId, ContactId, Contact.LastName, IsPrimary__c
                from AccountContactRelation
                WHERE AccountId = :TestAcct.Id
        ];
        system.assertEquals(2, results.size(), 'Should have found two ACRelations.');
        system.debug('The two ACRelations created are ' + results);
        for (AccountContactRelation acr : results) {
            if (acr.ContactId == TestCtct.Id) {
                system.assertEquals(false, acr.IsPrimary__c, 'After switching, the first ACRelation IsPrimary should be false.');
            } else {
                if (acr.ContactId == TestCtct2.Id) {
                    system.assertEquals(true, acr.IsPrimary__c, 'After switching, the second ACRelation IsPrimary should be true.');
                }
            }
        }
    }

    @IsTest
    static void insertBulkIndirectACRelations() {
        WGHelpers.BManageACRelations = true;
        WGhelpers.BManageContacts = true;
        Account TestAcct = new Account(
                Name = 'TestAcct'
        );
        insert TestAcct;
        Account TestAcct2 = new Account(
                Name = 'TestAcct2'
        );
        insert TestAcct2;
        // Create 2 Contacts in the second Account.
        List<Contact> NewContacts = new List<Contact>();
        for (Integer i = 0; i < 100; i++) {
            Contact NewContact = new Contact(
                    LastName = 'TestContact' + i,
                    AccountId = TestAcct2.Id
            );
            NewContacts.add(NewContact);
        }
        Insert NewContacts;
        List<AccountContactRelation> results = [
                SELECT Id, AccountId, ContactId, Contact.LastName, IsPrimary__c
                from AccountContactRelation
                WHERE AccountId = :TestAcct2.Id
        ];
        system.assertEquals(100, results.size(), 'Should have created 100 ACRelations for 100 Contacts.');
        // Only the first contact should have IsPrimary==true.
        // For (AccountContactRelation acr : results) {
        For (Integer i = 0; i < 100; i++) {
            if (i == 0) {
                system.assertEquals(true, results[i].IsPrimary__c, 'First of the new direct ACRelations should have IsPrimary==true but for ' + results[0].Contact.Lastname + ' it is ' + results[0].IsPrimary__c);
            } else {
                system.assertEquals(false, results[i].IsPrimary__c, 'Other direct ACRelations should have IsPrimary==false but for ' + results[i].Contact.Lastname + ' it is ' + results[i].IsPrimary__c);
            }

            // }

            // Create 2 new indirect AccountContactRelations in the first account.
            // Set them all to IsPrimary, which should move all the old ACRelations to IsPrimary==false.
            List<AccountContactRelation> NewACRelations = new List<AccountContactRelation>();
            for (i = 0; i < 100; i++) {
                AccountContactRelation NewACRelation = new AccountContactRelation(
                        ContactId = NewContacts[i].Id,
                        // in the first account
                        AccountId = TestAcct.Id,
                        Roles = 'Influencer',
                        IsPrimary__c = true
                );
                NewACRelations.add(NewACRelation);
            }
            insert NewACRelations;

            // test result
            results = [
                    SELECT Id, AccountId, Account.Name, ContactId, Contact.LastName, IsPrimary__c, IsDirect
                    from AccountContactRelation
            ];
            system.debug('results is ' + results);
            system.assertEquals(200, results.size(), 'Should have created another 100 ACRelations for 200 total Contacts.');
            For (AccountContactRelation acr : results) {
                if (acr.AccountId == TestAcct2.Id) {
                    For (i = 0; i < 100; i++) {
                        if (i == 0) {
                            system.assertEquals(true, results[i].IsPrimary__c, 'First of the new direct ACRelations should have IsPrimary==true but for ' + results[0].Contact.Lastname + ' it is ' + results[0].IsPrimary__c);
                        } else {
                            system.assertEquals(false, results[i].IsPrimary__c, 'Other direct ACRelations should have IsPrimary==false but for ' + results[i].Contact.Lastname + ' it is ' + results[i].IsPrimary__c);
                        }
                    }
                } else {
                    // these are the indirect contacts, one should be true
                    system.debug('Indirect ACRelation is ' + acr);
                    if (acr.ContactId==NewContacts[0].Id) {
                        system.assertEquals(true, acr.IsPrimary__c, 'The first of the new indirect ACRelations should have IsPrimary==true.');
                    } else {
                        system.assertEquals(false, acr.IsPrimary__c, 'The other new indirect ACRelations should have IsPrimary==false.');
                    }
                }
            }

        }
    }
}
