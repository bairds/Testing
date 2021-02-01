/**
 * Created by Baird on 6/5/2020.
 * Prepare all emails to use the new 3 email system.  See
 * document at https://docs.google.com/document/d/1AYvzWeRQn4lVzV-UkUoR_kpjrFisIXX7e7mwgZGEnjU/edit
 * Before deploying this, must manually change Lead. and Contact.Other_emails__c to Legacy_Emails__c
 * Before deploying, must change Preferred_Email__c value from "Alternate" to "Other"
 * 6/6/200 Reprogram so that bumped Email goes into Other, Other goes into Legacy.
 */

public with sharing class morph1EmailTo3 {

    public morph1Emailto3() {
    }

    public void arrangeEmails(List<Id> CLIds) {
        List<SOEx> LSOEs = new List<SOEx>();
        List<SObject> LSOs = new List<SObject>();
        List<Contact> LCs = [
                SELECT Firstname, Lastname, Email,Other_Email__c,Personal_Email__c,Last_Email_Overwrite__c,
                        Work_Email__c,Preferred_Email__c,Legacy_Emails__c,Account.RecordType.DeveloperName
                FROM Contact
                WHERE Id in:CLIds AND (Other_Email__c <> null OR Personal_Email__c <> NULL OR Work_Email__c <> null OR Email <> null)
        ];
        For (Contact c : LCs) {
            if (c.Account.RecordType.DeveloperName == 'Family') {
                SOEx SOE = new SOEx(c, 'Personal');
                LSOEs.add(SOE);
            } else {
                SOEx SOE = new SOEx(c, 'Work');
                LSOEs.add(SOE);
            }
        }
        system.debug('LSOEs is ' + LSOEs);
        List<Lead> LLs = [
                SELECT Email,Other_Email__c,Personal_Email__c,Last_Email_Overwrite__c,
                        Work_Email__c,Preferred_Email__c,Legacy_Emails__c
                from Lead
                WHERE Id in:CLIds AND (Other_Email__c <> null OR Personal_Email__c <> NULL OR Work_Email__c <> NULL OR Email <> null)
        ];
        // SAME THING FOR LEAD
        For (Lead L : LLs) {
            SOEx SOE = new SOEx(L, 'Personal');
            LSOEs.add(SOE);
            system.debug('After entering leads LSOEs is ' + LSOEs);
        }

        For (SOEX s : LSOES) {
            String ChosenEmail = '';
            String SFEmail = (String) s.SO.get('Email');
            //STORE EMAIL IN Legacy_emails__c
            If (SFEmail <> null) {
                String oes = (String) s.SO.get('Legacy_Emails__c');
                OES = OES == null ? SFEMail + ',' : SFEMail + ',' + OES;
                s.SO.put('Legacy_Emails__c', OES);
                system.debug('Just set Legacy_Email__c to ' + OES);
                system.debug('s is now ' + s.SO);
            }
            // If Preferred_Email__c is set, use it
            String PreferredEmail = (String) s.SO.get('Preferred_Email__c');
            If (PreferredEmail <> null) {
                switch on PreferredEmail {
                    when 'Personal' {
                        if ((String) s.SO.get('Personal_Email__c') != null) {
                            ChosenEmail = (String) s.SO.get('Personal_Email__c');
                        } else {
                            if (SFEmail <> null) {
                                ChosenEmail = SFEmail;
                                s.SO.put('Personal_Email__c', SFEmail);
                            }
                        }
                    }
                    when 'Work' {
                        if ((String) s.SO.get('Work_Email__c') != null) {
                            ChosenEmail = (String) s.SO.get('Work_Email__c');
                        } else {
                            if (SFEmail <> null) {
                                ChosenEmail = SFEmail;
                                s.SO.put('Work_Email__c', SFEmail);
                            }
                        }
                    }
                    when 'Other' {
                        if ((String) s.SO.get('Other_Email__c') != null) {
                            ChosenEmail = (String) s.SO.get('Other_Email__c');
                        } else {
                            if (SFEmail <> null) {
                                ChosenEmail = SFEmail;
                                s.SO.put('Other_Email__c', SFEmail);
                            }
                        }
                    }
                }
            }
            // If Preferred_Email__c is null
            else {
                String PersonalEmail = (String) s.SO.get('Personal_Email__c');
                String WorkEmail = (String) s.SO.get('Work_Email__c');
                String OtherEmail = (String) s.SO.get('Other_Email__c');
                If (SFEMail != null) {
                    // PreferredEmail is not set.  Assume SFEmail is the preferred email.
                    // Is it one of the WGEmails?  If so, set that one to preferred.
                    If (SFEmail == PersonalEmail) {
                        s.SO.put('Preferred_Email__c', 'Personal');
                        ChosenEmail = SFEmail;
                    } else {
                        If (SFEmail == WorkEmail) {
                            s.SO.put('Preferred_Email__c', 'Work');
                            ChosenEmail = SFEmail;
                        } else {
                            If (SFEmail == OtherEmail) {
                                s.SO.put('Preferred_Email__c', 'Other');
                                ChosenEmail = SFEmail;
                            } else {
                                // Insert into Personal, Work, Other
                                If (s.PorW == 'Personal') {
                                    // If this is a lead or contact from a family account
                                    // Order by Personal, Work, Other
                                    If (PersonalEmail == null) {
                                        s.SO.put('Personal_Email__c', SFEmail);
                                        s.SO.put('Preferred_Email__c', 'Personal');
                                        ChosenEmail = SFEmail;
                                    } else {
                                        If (WorkEmail == null) {
                                            s.SO.put('Work_Email__c', SFEmail);
                                            s.SO.put('Preferred_Email__c', 'Work');
                                            ChosenEmail = SFEmail;
                                        } else {
                                            if (OtherEmail == null) {
                                                s.SO.put('Other_Email__c', SFEmail);
                                                s.SO.put('Preferred_Email__c', 'Other');
                                                ChosenEmail = SFEmail;
                                            } else {
                                                // All WGEmails are filled, leave SFEmail alone.
                                                // Do not set preferred.  Refer to user for resolution.
                                                ChosenEmail = SFEmail;
                                            }
                                        }
                                    }
                                } else {
                                    // This is a contact from a non-family account
                                    // Order by Work, Personal, Other
                                    If (WorkEmail == null) {
                                        s.SO.put('Work_Email__c', SFEmail);
                                        s.SO.put('Preferred_Email__c', 'Work');
                                        ChosenEmail = SFEmail;
                                    } else {
                                        If (PersonalEmail == null) {
                                            s.SO.put('Personal_Email__c', SFEmail);
                                            s.SO.put('Preferred_Email__c', 'Personal');
                                            ChosenEmail = SFEmail;
                                        } else {
                                            if (OtherEmail == null) {
                                                s.SO.put('Other_Email__c', SFEmail);
                                                s.SO.put('Preferred_Email__c', 'Other');
                                                ChosenEmail = SFEmail;
                                            } else {
                                                ChosenEmail = SFEmail;
                                            }
                                    }
                                    }
                                }

                            }
                        }
                    }
                } else {
                    // SFEmail == null && PreferredEmail == null
                    If (s.PorW == 'Personal') {
                        // If this is a lead or contact from a family account
                        // Order by Personal, Work, Other
                        If (PersonalEmail <> null) {
                            ChosenEmail = PersonalEmail;
                            s.SO.put('Preferred_Email__c', 'Personal');
                        } else {
                            If (WorkEmail <> null) {
                                ChosenEmail = WorkEmail;
                                s.SO.put('Preferred_Email__c', 'Work');
                            } else {
                                If (OtherEmail <> null) {
                                    ChosenEmail = OtherEmail;
                                    s.SO.put('Preferred_Email__c', 'Other');
                                }
                            }
                        }
                    } else {
                        // This is a contact from a non-family account
                        If (WorkEmail <> null) {
                            ChosenEmail = WorkEmail;
                            s.SO.put('Preferred_Email__c', 'Work');
                        } else {
                            If (PersonalEmail <> null) {
                                ChosenEmail = PersonalEmail;
                                s.SO.put('Preferred_Email__c', 'Personal');
                            } else {
                                If (OtherEmail <> null) {
                                    ChosenEmail = OtherEmail;
                                    s.SO.put('Preferred_Email__c', 'Other');
                                }
                            }
                        }
                    }
                }
            }
            if (ChosenEmail!=SFEmail) s.SO.put('Last_Email_Overwrite__c',system.now());
                s.SO.put('Email', ChosenEmail);
                system.debug('After arrangeEmails() s is ' + s.SO);
                LSOs.add(s.SO);
            }
            database.update(LSOs,false);
        }

        public class SOEx {
        public string PorW;
        SObject SO;
        public SOEx(SObject OrigSO, string OrigPorW) {
        SO = OrigSO;
        PorW = OrigPorW;
    }
}
}