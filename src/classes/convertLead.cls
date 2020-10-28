public without sharing class convertLead {
    public static Database.LeadConvertResult convertLead(Lead l) {
        Account acct;
        Contact ctct;
        ConvertLeadToContact.leadBeingConverted = true;
                    Database.LeadConvert lc = new database.LeadConvert();
                    lc.setLeadId(l.id);
                    lc.setDoNotCreateOpportunity(true);
        			LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE MasterLabel='Closed - Converted' LIMIT 1];
                    lc.setConvertedStatus(convertStatus.MasterLabel);
                    lc.setOverwriteLeadSource(true);
                    Database.LeadConvertResult lcr = Database.convertLead(lc);
                	//Feb 3 - Baird: These values need to get assigned after the lead conversion in order for them to be properly inserted in the opportuniy
	// Insert values for Dear__c, Addressee__c in Account without setting off triggers.
					acct = [select id, name, Addressee__c, Dear__c, (select
                                 firstname, lastname, MailingStreet, MailingCity, MailingState, MailingPostalCode from Contacts where id = :LCR.getContactId() limit 1)
                                 from Account where id = :lcr.getAccountId()];
        system.debug('Account and contact is now ' + acct + ' and Contacts.size() is ' + acct.contacts.size());
        if (acct.Contacts.size() > 0) {
        			if (acct.name == 'none') acct.name = acct.contacts[0].lastname + ', ' + acct.contacts[0].firstname + ' Household'; 
        } else {
            acct.name = acct.name == null ? 'Found no name for this account' : acct.name;
        }
        			acct.Dear__c = acct.contacts[0].firstname;
        			acct.Addressee__c = acct.contacts[0].firstname + ' ' + acct.contacts[0].lastname;
        			acct.BillingStreet = acct.contacts[0].MailingStreet;
        			acct.BillingCity = acct.contacts[0].MailingCity;
        			acct.BillingState = acct.contacts[0].MailingState;
        			acct.BillingPostalCode = acct.contacts[0].MailingPostalCode;
        			// Set the ARCT so that the update to the account doesn't trigger anything else;
        			avoidRecursiveContributionTrigger.setworking();
        			update acct;
        			avoidRecursiveContributionTrigger.setclosed();
        ConvertLeadToContact.leadBeingConverted = false;
          			return lcr;
    }

}