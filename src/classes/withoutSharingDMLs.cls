/**
 * Created by Baird on 7/15/2020.
 */

public without sharing class withoutSharingDMLs {

    public static void SaveGUU(GuestUserUpdate__c guu) {
        upsert guu;
    }

    public static void SaveOpportunity(Opportunity o) {
        upsert o;
    }

    public static void SaveContact(Contact c) {
        upsert c;
    }

    public Static void SaveAccountContactRoles(List<AccountContactRole> ListACRs){
        upsert ListACRs;
    }

    public static List<Opportunity> getListSubmittedTasks(Id ContactId){
        return [
                SELECT Id, Date_and_Time_Start__c, Date_and_Time_End__c, Description, Campaign_Guess__c,
                        Contact__r.FirstName, Contact__r.LastName,Hours_Actual__c,Contact__c
                from Opportunity
                WHERE (Contact__c = :ContactId AND StageName = 'Task Submitted')];
    }

    public static List<Opportunity> UpdateOppsWoutSharing(List<Opportunity> Opps){
        database.update(Opps,false);
        // add error catching here.
        return Opps;
    }

    public static List<Account> UpdateAcctsWoutSharing(List<Account> Accts){
        database.update(Accts,false);
        // add error catching here.
        return Accts;
    }

    public static List<Contact> UpdateCtctsWoutSharing(List<Contact> Ctcts){
        database.update(Ctcts,false);
        // add error catching here.
        return Ctcts;
    }
}