/**
 * Created by Baird on 2/7/2020.
 */

public without sharing class accessData {

    public static string insertACR(list<AccountContactRole> LACR){
        try {
            insert LACR;
            return 'success';
        } catch (DmlException exc){
            return exc.getMessage();
        }
    }

    public static string insertCM(list<CampaignMember> LCM){
        try {
            insert LCM;
            system.debug('In accessData just tried inserting list of campaign members ' + LCM);
            return 'success';
        } catch (DmlException exc){
            return exc.getMessage();
        }
    }

    public static list<Messaging.SendEmailResult> sendEmail(list<Messaging.SingleEmailMessage> emailList, Boolean allOrNothing) {
        return Messaging.sendEmail(emailList, allOrNothing);
    }

}