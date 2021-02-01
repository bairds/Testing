// ConvertLeadToContact
// takes id 'sid' of Lead
// returns id of Contact
// if Lead.company = 'none' then creates Account Family 'Lastname, Firstname Household'
// if Lead.compoany = 'anythingelse' then creates Account type Business 'anythingelse'
// Tests included within this controller
public without sharing class ConvertLeadToContact{
    public static Boolean leadBeingConverted = false;
    
    public ConvertLeadToContact() {}
    
    public static List<id> ConvertLeadToContact(id sid) {
        List<id> returnIds = new List<Id>();
        ConvertLeadToContact.leadBeingConverted = true;
                    lead checkLead = [select id, company, firstname, lastname from Lead where
                        id = :sID];
                        if (checkLead.company == 'none' || checkLead.company == 'not provided') {
                        checkLead.company = checkLead.lastname + ', ' + checkLead.firstname + ' Household';
                        update checkLead;
                        }
                        else {}
                    Database.LeadConvert lc = new database.LeadConvert();
                    lc.setLeadId(sID);
                    lc.setDoNotCreateOpportunity(true);
                    LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE 
                        IsConverted=true and MasterLabel <> 'Qualified' LIMIT 1];
                    lc.setConvertedStatus(convertStatus.MasterLabel);
                    Database.LeadConvertResult lcr = Database.convertLead(lc);
                    // Make sure conversion was successful
                    System.assert(lcr.isSuccess());
        			//Update account information
        			Account a = [select id, name, Addressee__c, Dear__c, (select
                                 firstname, lastname, MailingStreet, MailingCity, MailingState, MailingPostalCode from Contacts where id = :LCR.getContactId() limit 1)
                                 from Account where id = :lcr.getAccountId()];
        if (a.name == 'none' || checkLead.company == 'not provided' || string.isblank(a.name)) {
            if (checkLead.company=='none' || checkLead.company == 'not provided' || string.isblank(checklead.company)) {
                 a.name = a.contacts[0].lastname + ', ' + a.contacts[0].firstname + ' Household'; 
            } else {
                a.name = checkLead.company;
            }
             
        }
        			a.Dear__c = a.contacts[0].firstname;
        			a.Addressee__c = a.contacts[0].firstname + ' ' + a.contacts[0].lastname;
        			A.BillingStreet = a.contacts[0].MailingStreet;
        			A.BillingCity = a.contacts[0].MailingCity;
        			A.BillingState = a.contacts[0].MailingState;
        			A.BillingPostalCode = a.contacts[0].MailingPostalCode;
                    sID = a.contacts[0].id;
        			// Set the ARCT so that the update to the account doesn't trigger anything else;
        			avoidRecursiveContributionTrigger.setworking();
        			update a;
        			avoidRecursiveContributionTrigger.setclosed();
                           
        ConvertLeadToContact.leadBeingConverted = false;
        
        // return sid;
        ReturnIds.add(sid);
        ReturnIds.add(a.id);
        return ReturnIds;
                    
    }  // end ConvertLeadToContact() method;
    

    
} // end classS