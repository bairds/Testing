/**
 * Created by PeterChurchill on 4/9/2018.
 */

public with sharing class ConvertLeadToContactBulk {

    public Map<Id, Id> LeadtoAccountMap;
    public Map<Id, Id> AccountToLeadMap;
    public Map<Id, Id> LeadtoContactMap;

    public ConvertLeadToContactBulk() {
        LeadtoContactMap = new Map<Id, Id> ();
        LeadtoAccountMap = new Map<Id, Id> ();
        AccountToLeadMap = new Map<Id, Id> ();

    }

    public void ConvertLeadToContact(List<Lead> leadsToProcess) {

        Map<Id, Lead> checkLeads = new Map<Id, Lead> ([select id, company, firstname, lastname from Lead where Id IN :leadsToProcess]);

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true and MasterLabel <> 'Qualified' LIMIT 1];

        List<Database.LeadConvert> lconverts = new List<Database.LeadConvert>();
        for (Lead lTemp: leadsToProcess) {
            Database.Leadconvert lc = new Database.Leadconvert();
            lc.setLeadId(lTemp.Id);
            lc.setDoNotCreateOpportunity(true);

            lc.setConvertedStatus(convertStatus.MasterLabel);
            lconverts.add(lc);
        }
        system.debug('Leads to be converted are ' + lconverts);
        
        avoidRecursiveContactTrigger.setworking();
        List<Database.LeadConvertResult> leadcresults = Database.convertLead(lconverts);
        For (Database.LeadConvertResult lcr : leadcresults) system.debug('Converted lead to contact ' + lcr.ContactId);
        avoidRecursiveContactTrigger.setclosed();


        for (Database.LeadConvertResult lcsresult: leadcresults) {
        // if conversion was successful, add to Lead to Conatct Map
        if (lcsresult.isSuccess() ) {
            LeadtoContactMap.put(lcsresult.leadId, lcsresult.contactId);
            LeadtoAccountMap.put(lcsresult.leadId, lcsresult.accountId);
            AccountToLeadMap.put(lcsresult.accountId, lcsresult.leadId);
        }
        else {
            for(Database.Error err : lcsresult.getErrors()) {
                System.debug('The following error has occurred.');
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('Account fields that affected this error: ' + err.getFields());
            }

        }
        }
        //Update account information
        List<Account> accountsFromLeads = [select id, name, Addressee__c, Dear__c,
        (Select firstname, lastname, MailingStreet, MailingCity, MailingState, MailingPostalCode from Contacts)
        from Account where id = :AccountToLeadMap.keyset()];

        for (Account aTemp: accountsFromLeads) {

            if (aTemp.name == 'none' || aTemp.name == 'not provided' || string.isblank(aTemp.name)) {
                if (AccountToLeadMap.containsKey(aTemp.Id)
                        && checkLeads.containsKey(AccountToLeadMap.get(aTemp.Id))
                        && aTemp.contacts.size() > 0) {

                    Lead checkLead = checkLeads.get(AccountToLeadMap.get(aTemp.Id));

                    if (checkLead.company == 'none' || checkLead.company == 'not provided' || string.isblank(checklead.company)) {
                        aTemp.name = aTemp.contacts[0].lastname + ', ' + aTemp.contacts[0].firstname + ' Household';
                    } else {
                        aTemp.name = checkLead.company;
                    }
                }
            }
                    aTemp.Dear__c = aTemp.contacts[0].firstname;
                    aTemp.Addressee__c = aTemp.contacts[0].firstname + ' ' + aTemp.contacts[0].lastname;
                    aTemp.BillingStreet = aTemp.contacts[0].MailingStreet;
                    aTemp.BillingCity = aTemp.contacts[0].MailingCity;
                    aTemp.BillingState = aTemp.contacts[0].MailingState;
                    aTemp.BillingPostalCode = aTemp.contacts[0].MailingPostalCode;
        }
        // Set the ARCT so that the update to the account doesn't trigger anything else;
                    avoidRecursiveContributionTrigger.setworking();
                    AvoidRecursiveContactTrigger.setworking();
                    update accountsFromLeads;
                    avoidRecursiveContributionTrigger.setclosed();
                    AvoidRecursiveContactTrigger.setclosed();

                    ConvertLeadToContact.leadBeingConverted = false;

    }  // end ConvertLeadToContact() method;

}