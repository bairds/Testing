public without sharing class ManageContacts {

    public List<Contact> cs;
    public static List<Id> AccountIds;
    private Contact c;
    private Lead l;
    public List<string> VolunteerInterests { get; set; }
    public List<SelectOption> volunteerInterestsList { get; set; }
    // public List<Task> tasks;


    // Originally written by Peter Churchill
    // With reference to Steve Andersen's post:
    // http://gokubi.com/archives/two-interesting-ways-to-architect-apex-triggers
    // PNC 4/12/2010
    // Revised Baird 3 July 2018 to catch direct injections of contacts without accounts from other applications like EventBrite.

    // This method arranges emails into the 3 email system
    public static List<Contact> beforeInsert(Contact [] ctcts) {
        system.debug('Triggernew contacts is ' + ctcts);
        Map<Id, Id> CtctRTypeMap = new Map<Id, Id>();
        List<Contact> CtctsWEmails = new List<Contact>();

        // Check for emails
        For (Contact ctct : ctcts) {
            if (ctct.Email != null || ctct.Personal_Email__c != null || ctct.Work_Email__c != null
                    || ctct.Other_Email__c != null) {
                CtctsWEmails.add(ctct);
            }
        }

        List<Id> AccountIds = new List<Id>();
        For (Contact c : CtctsWEmails) {
            if (c.AccountId != null) AccountIds.add(c.AccountId);
        }
        Map<Id, Id> RecordTypeMap = new Map<id, Id>();
        List<Account> Accounts = [SELECT Id, Name, RecordTypeId from Account where Id IN:AccountIds];
        For (Account acct : Accounts) {
            RecordTypeMap.put(acct.Id, acct.RecordTypeId);
        }
        For (Contact c : CtctsWEmails) {
            CtctRTypeMap.put(c.Id, RecordTypeMap.get(c.AccountId));
        }
        arrangeEmails(CtctsWEmails, CtctRTypeMap);


        // This method catches direction injection of contacts without accounts.
        List<Task> Tasks = new List<Task>();
        // First, check to see whether there are any such contacts.
        List<Contact> CtctsWoutAcct = new List<Contact>();
        for (Contact ctct : ctcts) {
            If (ctct.AccountId == null) {
                CtctsWoutAcct.add(ctct);
                system.debug('In beforeInsert method added to CtctsWoutAcct contact: ' + ctct);
            }
        }
        // If there are any contacts without accounts
        if (CtctsWoutAcct != null) {
            List<Contact> CtctsQueuedForNewAcct = new List<Contact>();
            List<Contact> CtctsToLinkToAccts = new List<Contact>();
            List<Account> AcctsToCreate = new List<Account>();
            Map<string, Contact> CtctsWAccts;
            Map<string, Contact> ContactEmailMap = new Map<string, Contact>();
            Boolean LeadNotBeingConverted;
            List<Task> ts = new List<Task>();
            Id FamilyRTID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Family').getRecordTypeId();
            //These injected contacts may have emails
            For (Contact c : CtctsWoutAcct) {
                If (c.email != null) {
                    ContactEmailMap.put(c.email, c);
                } else {
                    CtctsQueuedForNewAcct.add(c);
                }
            }
            if (ContactEmailMap.size() > 0) {
                CtctsWAccts = new Map<string, Contact>();
                List<Contact> ContactEmailMatches = [SELECT id, firstname, lastname, email, accountId from Contact WHERE Email IN :ContactEmailMap.keyset()];
                system.debug('Does c have id? ' + ContactEmailMatches);
                for (Contact c : ContactEmailMatches) CtctsWAccts.put(c.email, c);

                For (Contact c : ctcts) {
                    if (CtctsWAccts.keyset().Contains(c.email)) {
                        c.AccountId = CtctsWAccts.get(c.email).AccountId;
                        // CtctsToLinkToAccts.add(c);
                    } else {
                        CtctsQueuedForNewAcct.add(c);
                    }
                }
            }
            //Update contacts which match contacts with existing accounts
            // update CtctsToLinkToAccts;
            //Create Accounts for the rest
            If (CtctsQueuedForNewAcct.size() > 0) {
                for (Contact c : CtctsQueuedForNewAcct) {
                    Account a = new Account(
                            RecordTypeId = FamilyRTId,
                            Name = c.LastName + ', ' + c.FirstName + ' Household',
                            Is_Dummy__c = true,
                            Dear__c = c.FirstName,
                            Addressee__c = c.FirstName + ' ' + c.LastName,
                            Phone = c.MobilePhone,
                            BillingStreet = c.MailingStreet,
                            BillingCity = c.MailingCity,
                            BillingState = c.MailingState,
                            BillingPostalCode = c.MailingPostalCode,
                            BillingCountry = c.MailingCountry,
                            Active__c = 'Active',
                            Description = 'Created when contact without account was injected directly into database without searching for match & creating account.');
                    AcctsToCreate.add(a);
                    tasks.add(setTask(c, 'Review New Account/Contact'));
                }
                List<Database.saveResult> SRList = database.insert(AcctsToCreate, false);
                for (integer i = 0; i < CtctsQueuedForNewAcct.size(); i++) {
                    if (SRList[i].isSuccess()) {
                        CtctsQueuedForNewAcct[i].AccountId = AcctsToCreate[i].Id;
                        system.debug('Success: CtctsQueuedForNewAcct[i] is ' + CtctsQueuedForNewAcct[i]);
                    } else {
                        for (Database.Error err : SRList[i].getErrors()) {
                            System.debug('Attempted to create new account for contact wout account.  The following error has occurred.');
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
        }
        if (tasks.size() > 0) {
            insert tasks;
            sendEmail(tasks);
        }
        return ctcts;
    }

    public static List<Contact> beforeUpdate(List<Contact> NewContacts, List<Contact> OldContacts) {
        // Principles:
        // Allow users to make changes and not be overwritten.
        // Force users to make changes by using Personal, Work, Other and Preferred.
        // Manage automated processes (SDI, etc.) to keep ctct.Email and Preferred synchronized.

        // Pseudocode:
        // Is ctct.Email changed?  If so, this is an automated process.
        // Does new ctct.email match any of the other WGemails?
        // If so, set Preferred to the Matching Email.
        // If not,
        // If Other_Email is populated, move it to Legacy_Emails__c.
        // Insert old ctct.email in Other_Email.
        // Set Preferred to Other_Email.
        // Would any of the automated processes also change the Personal, Work or Other?
        // For now, assume the answer is no.  (SDI is the possible exception.)
        // Are there changes beside ctct.Email?  If so, this is a user.
        // Does the Ctct.Email agree with both the Preferred field and the email to which Preferred Points?
        // If so, do nothing.
        // If not,
        // Are both the Preferred field and the email to which it points populated?
        // If not, send error message to UI.
        // If so,
        // If Other_Email is populated, move it to Legacy_Emails__c.
        // Insert old ctct.email in Other_Email.
        // Set Preferred to Other_Email.

        for (integer i = 0; i < NewContacts.size(); i++) {
            // An internal process or external program has changed the Email field.
            system.debug('NewContacts[i].Email is ' + NewContacts[i].Email + ' and OldContacts[i].Email is ' + OldContacts[i].Email);
            // PREVENT SYS ADMINS, EXTERNAL USERS FROM JUST ERASING THE EMAIL FIELD
            /* if(NewContacts[i].Email == null) {
                 NewContacts[i].Email = OldContacts[i].Email;
                 newContacts[0].addError('Please adjust email using the Preferred field and the Personal, Work, and Other_Email.  Do not change the Email field.');
             }*/
            if (NewContacts[i].Email != OldContacts[i].Email) {
                // if Preferred & Emails align
                if (NewContacts[i].Email == OldContacts[i].Personal_Email__c) {
                    NewContacts[i].Preferred_Email__c = 'Personal';
                } else {
                    if (NewContacts[i].Email == OldContacts[i].Work_Email__c) {
                        NewContacts[i].Preferred_Email__c = 'Work';
                    } else {
                        if (NewContacts[i].Preferred_Email__c == null && OldContacts[i].Preferred_Email__c != null) {
                            NewContacts[i].Email = null;
                            system.debug('Erased email because Preferred set to None.');
                        } else {
                            // Unless there is a match, Other Email has to be moved to Legacy Email
                            NewContacts[i].Preferred_Email__c = 'Other';
                            if (OldContacts[i].Other_Email__c != null) {
                                if (NewContacts[i].Email != OldContacts[i].Other_Email__c)
                                    NewContacts[i].Legacy_Emails__c = OldContacts[i].Legacy_Emails__c == null ? OldContacts[i].Other_Email__c : OldContacts[i].Other_Email__c + ', ' + OldContacts[i].Legacy_Emails__c;
                            }
                            if (NewContacts[i].Email != null) {
                                NewContacts[i].Other_Email__c = NewContacts[i].Email;
                                system.debug('Should have just set NewContacts[i].Other_Email__c to ' + NewContacts[i].Email + ' and it is now ' + NewContacts[i].Other_Email__c);
                                NewContacts[i].Last_Email_Overwrite__c = DateTime.now();
                            }
                            System.debug('NewContacts[i].Last_Email_Overwrite__c is ' + NewContacts[i].Last_Email_Overwrite__c);
                            // Avoid the storeOldEmail routine below, which is incorrect for this case
                            continue;
                        }
                    }
                }
            } else {
                // Contact.Email was not changed, so the change was to one of the other fields or made through the UI
                // Do Contact.Email, Preferred and the email field it points to agree?  If yes, do nothing.
                // If not, insert the Preferred Email into Email.
                // store old email
                If (NewContacts[i].Preferred_Email__c == 'Personal' && NewContacts[i].Personal_Email__c != null) {
                    if (NewContacts[i].Personal_Email__c != NewContacts[i].Email) {
                        newContacts[i].Email = NewContacts[i].Personal_Email__c;
                        if (newContacts[i].Personal_Email__c != OldContacts[i].Personal_Email__c) NewContacts[i].Legacy_Emails__c = OldContacts[i].Legacy_Emails__c == null ? OldContacts[i].Personal_Email__c : OldContacts[i].Personal_Email__c + ', ' + OldContacts[i].Legacy_Emails__c;
                    } else continue;

                } else {
                    if (NewContacts[i].Preferred_Email__c == 'Work' && NewContacts[i].Work_Email__c != null) {
                        if (NewContacts[i].Work_Email__c != NewContacts[i].Email) {
                            newContacts[i].Email = NewContacts[i].Work_Email__c;
                            if (newContacts[i].Work_Email__c != OldContacts[i].Work_Email__c) NewContacts[i].Legacy_Emails__c = OldContacts[i].Legacy_Emails__c == null ? OldContacts[i].Work_Email__c : OldContacts[i].Work_Email__c + ', ' + OldContacts[i].Legacy_Emails__c;
                        } else continue;
                    } else {
                        if (NewContacts[i].Preferred_Email__c == 'Other' && NewContacts[i].Other_Email__c != null) {
                            if (NewContacts[i].Other_Email__c != NewContacts[i].Email) {
                                newContacts[i].Email = NewContacts[i].Other_Email__c;
                                if (newContacts[i].Other_Email__c != OldContacts[i].Other_Email__c && OldContacts[i].Other_Email__c != null) NewContacts[i].Legacy_Emails__c = OldContacts[i].Legacy_Emails__c == null ? OldContacts[i].Other_Email__c : OldContacts[i].Other_Email__c + ', ' + OldContacts[i].Legacy_Emails__c;
                            } else continue;
                        } else {
                            if (NewContacts[i].Preferred_Email__c == null && OldContacts[i].Preferred_Email__c != null) {
                                NewContacts[i].Email = null;
                                system.debug('Erased email because Preferred set to None.');
                            }
                            // Preferred does not point to populated email
                            // if Email populated, Preferred points to blank field
                            if (NewContacts[i].Preferred_Email__c == 'Personal' && NewContacts[i].Personal_Email__c == null)
                                NewContacts[i].Personal_Email__c = NewContacts[i].Email;
                            if (NewContacts[i].Preferred_Email__c == 'Work' && NewContacts[i].Work_Email__c == null)
                                NewContacts[i].Work_Email__c = NewContacts[i].Email;
                            if (NewContacts[i].Preferred_Email__c == 'Other' && NewContacts[i].Other_Email__c == null)
                                NewContacts[i].Other_Email__c = NewContacts[i].Email;
                        }
                    }
                }
                //store old Email
                if (OldContacts[i].Email != null && OldContacts[i].Email != NewContacts[i].Personal_Email__c &&
                        OldContacts[i].Email != NewContacts[i].Work_Email__c &&
                        OldContacts[i].Email != NewContacts[i].Other_Email__c) {
                    List<string> Emails = new List<String>{
                            OldContacts[i].Email, OldContacts[i].Other_Email__c, OldContacts[i].Legacy_Emails__c
                    };
                    Emails = StoreEmailInLegacy(Emails);
                    if (NewContacts[i].Other_Email__c != NewContacts[i].Email) {
                        NewContacts[i].Other_Email__c = Emails[1];
                        NewContacts[i].Legacy_Emails__c = Emails[2];
                    }
                    NewContacts[i].Last_Email_Overwrite__c = DateTime.now();
                }
            }
            }
        return NewContacts;
    }


    public static void afterInsert(Contact [] contacts, Contact [] OldContacts) {
        //If the instance is set to use only AccountContactRelationships
        Boolean ACRelations = [SELECT Use_AcctCtctRelations__c from WGSettings__mdt
                WHERE DeveloperName = 'WGDefault' LIMIT 1].Use_AcctCtctRelations__c;
        If (ACRelations){

        } else {

            //Now make sure that a new primary ACR is created if the Account doesn't already have one
            Set<Id> AllAccounts = new Set<Id> ();
            Set<Id> WithPrimaryAccounts = new Set<Id> ();
            List<AccountContactRole> NewAccountRoleContacts = new List<AccountContactRole>();

            for (Contact c : contacts) {
                AllAccounts.add(c.AccountId);
            }
            List<Account> UpdateAccts = CountCtctsInAcct(new List<Id>(AllAccounts));
            //Count up the contacts
            /*List<Account> Accts = [select id, (select id from Contacts where Deceased__c<>true AND (Active__c = 'Active' OR Active__c = 'Yes' OR Active__c = null)) FROM Account WHERE Id in :AllAccounts];
        for (Account a : Accts) {
            a.Nr_Contacts_In_Acct__c = a.Contacts.size();
        }*/
            update UpdateAccts;

            for (AccountContactRole acr : [Select AccountId from AccountContactRole where AccountId in :AllAccounts AND IsPrimary = TRUE]) {
                WithPrimaryAccounts.add(acr.AccountId);
            }

            for (Contact c : contacts) {
                if (WithPrimaryAccounts.contains(c.AccountId)) {
                    //do nothing
                } else {
                    NewAccountRoleContacts.add(new AccountContactRole (
                            AccountId = c.AccountId,
                            ContactId = c.Id,
                            IsPrimary = TRUE,
                            Role = 'Decision Maker'));
                    //and now we've added it, we don't want to add another, so update the list
                    WithPrimaryAccounts.add(c.AccountId);
                }
            }

            if (NewAccountRoleContacts.size() > 0) {
                insert NewAccountRoleContacts;
            }
        }
        //end method
    }

    public static void beforeDelete(Contact [] contacts, Contact [] oldcontacts) {
        AccountIds = new List<Id>();
        Set<Id> PrimaryOnAccount = new Set<Id> ();

        for (AccountContactRole acr : [Select ContactId from AccountContactRole where IsPrimary = TRUE AND ContactId in :oldcontacts]) {
            PrimaryOnAccount.add(acr.ContactId);
        }

        for (Contact c : oldcontacts) {
            if (PrimaryOnAccount.contains(c.Id)) {
                c.AccountId.adderror('Contact is the Primary Contact Role on an Account!  Please make another Contact Primary before deleting this one.');
            } else {
                AccountIds.add(c.AccountId);
            }
        }

    }

    public static void afterDelete(Contact[] ctcts) {
        // Count the contacts in the accounts
        List<Account> UpdateAccounts = CountCtctsInAcct(AccountIds);
        update UpdateAccounts;
    }

    public static List<Account> CountCtctsInAcct(list<Id> AccountIds) {
        List<Account> Accts = [select id, (select id from Contacts where Deceased__c <> true AND (Active__c = 'Active' OR Active__c = 'Yes' OR Active__c = null)) FROM Account WHERE Id in :AccountIds];
        for (Account a : Accts) {
            a.Nr_Contacts_In_Acct__c = a.Contacts.size();
        }
        return Accts;
    }

    public static Task setTask(Contact c, String s) {
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.WhatId = c.AccountId;
        t.Subject = s;
        return t;
    }

    private static void sendEmail(List<Task> tasks) {
        String body = '<h1> Summary of Processed Duplicate/New Contacts/Accounts </h1>';
        Integer count = 1;

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setBccSender(false);
        mail.setUseSignature(false);

        mail.setSenderDisplayName(System.UserInfo.getOrganizationName());
        mail.setReplyTo(System.UserInfo.getUserEmail());
        mail.setSubject('Duplicate contacts / leads');
        mail.setTargetObjectId(System.UserInfo.getUserId());
        //mail.setTreatTargetObjectAsRecipient(true);
        mail.saveAsActivity = false;

        for (Task t : tasks) {
            body += '<table>';
            body += '<tr> <td> # </td> <td> ' + count + '</td> </tr>';
            body += '<tr> <td> task </td> <td> <a href="' + System.URL.getSalesforceBaseURL().toExternalForm() + '/' + t.id + '">' + t.Subject + '</a> </td> </tr>';
            body += '</table>';

            count++;
        }
    }

    public void setVolunteerInterests() {
        volunteerInterests = new String[]{
        };
        volunteerInterestsList = new List<SelectOption>();

        for (Schema.PicklistEntry ll : Contact.Volunteer_Interests__c.getDescribe().getPicklistValues())
            volunteerInterestsList.add(new SelectOption(ll.getValue(), ll.getLabel()));
    }

    // In the case of an update, we also need to have the newly injected emails.
    // That's the triggernew.email.
    public static List<Contact> arrangeEmails(List<Contact> Ctcts, Map<Id, Id> RTIdMap) {
        For (Contact c : Ctcts) {
            If (c.Preferred_Email__c <> null) {
                switch on c.Preferred_Email__c {
                    when 'Personal' {
                        if (c.Personal_Email__c != null) {
                            storeEmailInLegacy(c);
                            c.Email = c.Personal_Email__c;
                        } else {
                            if (c.Email != null) c.Personal_Email__c = c.Email;
                        }
                    }
                    when 'Work' {
                        if (c.Work_Email__c != null) {
                            storeEmailInLegacy(c);
                            c.Email = c.Work_Email__c;
                        } else {
                            if (c.Email != null) c.Work_Email__c = c.Email;
                        }
                    }
                    when 'Other' {
                        if (c.Other_Email__c != null) {
                            storeEmailInLegacy(c);
                            c.Email = c.Other_Email__c;
                        } else {
                            if (c.Email != null) c.Other_Email__c = c.Email;
                        }
                    }
                }
            }
            // If Preferred_Email__c is null
            else {
                String FamilyRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Family').getRecordTypeId();
                String PersonalEmail = c.Personal_Email__c;
                String WorkEmail = c.Work_Email__c;
                String OtherEmail = c.Other_Email__c;
                If (c.Email != null) {
                    // c.Preferred_Email__c is not set.  Assume c.Email is the preferred email.
                    // Is it one of the WGEmails?  If so, set that one to preferred.
                    If (c.Email == PersonalEmail) {
                        c.Preferred_Email__c = 'Personal';
                    } else {
                        If (c.Email == WorkEmail) {
                            c.Preferred_Email__c = 'Work';
                        } else {
                            If (c.Email == OtherEmail) {
                                c.Preferred_Email__c = 'Other';
                            } else {
                                // Insert into Personal, Work, Other
                                // Is this a Family account?
                                system.debug('CtctRTIdMap.get(c.Id) is ' + RTIdMap.get(c.Id));
                                If (RTIdMap.get(c.Id) == FamilyRTId) {
                                    // If this is a lead or contact from a family account
                                    // Order by Personal, Work, Other
                                    If (PersonalEmail == null) {
                                        c.Preferred_Email__c = 'Personal';
                                        c.Personal_Email__c = c.Email;
                                    } else {
                                        If (WorkEmail == null) {
                                            c.Preferred_Email__c = 'Work';
                                            c.Work_Email__c = c.Email;
                                        } else {
                                            if (OtherEmail == null) {
                                                c.Preferred_Email__c = 'Other';
                                                c.Other_Email__c = c.Email;
                                            } else {
                                                // All WGEmails are filled, bump Other into Legacy_Emails.
                                                if (c.Legacy_Emails__c == null) {
                                                    c.Legacy_Emails__c = c.Other_Email__c;
                                                } else {
                                                    c.Legacy_Emails__c += ', ' + c.Other_Email__c;
                                                    // this is just for the case of an update.
                                                    c.Other_Email__c = c.Email;
                                                    // c.Email = NEWEMAIL;
                                                }
                                            }

                                        }
                                    }
                                } else {
                                    // This is a contact from a non-family account
                                    // Order by Work, Personal, Other
                                    If (WorkEmail == null) {
                                        c.Preferred_Email__c = 'Work';
                                        c.Work_Email__c = c.Email;
                                    } else {
                                        If (PersonalEmail == null) {
                                            c.Preferred_Email__c = 'Personal';
                                            c.Personal_Email__c = c.Email;
                                        } else {
                                            if (OtherEmail == null) {
                                                c.Preferred_Email__c = 'Other';
                                                c.Other_Email__c = c.Email;
                                            }
                                        }
                                    }
                                }

                            }
                        }
                    }
                } else {
                    // c.Email == null && c.Preferred_Email__c == null
                    If (RTIdMap.get(c.Id) == FamilyRTId) {
                        // If this is a lead or contact from a family account
                        // Order by Personal, Work, Other
                        If (c.Personal_Email__c <> null) {
                            c.Email = c.Personal_Email__c;
                            c.Preferred_Email__c = 'Personal';
                        } else {
                            If (WorkEmail <> null) {
                                c.Email = c.Work_Email__c;
                                c.Preferred_Email__c = 'Work';
                            } else {
                                If (OtherEmail <> null) {
                                    c.Email = c.Other_Email__c;
                                    c.Preferred_Email__c = 'Other';
                                }
                            }
                        }
                    } else {
                        // This is a contact from a non-family account
                        If (WorkEmail <> null) {
                            c.Email = c.Work_Email__c;
                            c.Preferred_Email__c = 'Work';
                        } else {
                            If (c.Personal_Email__c <> null) {
                                c.Email = c.Personal_Email__c;
                                c.Preferred_Email__c = 'Personal';
                            } else {
                                If (OtherEmail <> null) {
                                    c.Email = c.Other_Email__c;
                                    c.Preferred_Email__c = 'Other';
                                }
                            }
                        }
                    }
                }
            }
        }
        return Ctcts;
    }


    public static List<String> StoreEmailInLegacy(List<String> Emails) {
        system.debug('At beginning of storeEmailInLegacy is ' + Emails);
        string Email1 = Emails[0];
        string EmailOther = Emails[1];
        string EmailsLegacy = Emails[2];
        If (EmailOther == null) {
            Emails[1] = Email1;
        } else {
            if (EmailsLegacy == null) {
                Emails[2] = EmailOther;
            } else {
                Emails[2] += ', ' + EmailOther;
            }
            Emails[1] = Email1;
        }
        return Emails;
    }

    public static void StoreEmailInLegacy(contact c) {
        If (c.Other_Email__c == null) {
            c.Other_Email__c = c.Email;
        } else {
            if (c.Legacy_Emails__c == null) {
                c.Legacy_Emails__c = c.Other_Email__c;
            } else {
                c.Legacy_Emails__c += ', ' + c.Other_Email__c;
            }
            c.Other_Email__c = c.Email;
            Datetime now = Datetime.now();
            Integer offset = UserInfo.getTimezone().getOffset(now);
            Datetime local = now.addSeconds(offset / 1000);
            c.Last_Email_Overwrite__c = local;
        }
    }

    public static PageReference EmailErrorOnContactInsert() {
        // PageReference PR = page.EmailErrorOnContactInsert;
        // PR.setredirect(false);
        return null;
    }

}