// TEsting dummy change
// Sept 29 2016 Baird updates to set Lead.Addressee__c and Dear__c
// March 2018 Baird adds return of AccountId.  Now results LIst<string> is contactId or LeadId, "lead" or "contact", and accountId if a Contact
public without sharing class identifyOrCreatePerson {
    
public static List<String> results {get; set;}

//Identify Contact or Lead
public static String [] identifyorCreatePerson(Contact signer) { 
//declare a list to store results
results = new String[3];
//If contact exists
//If email exists
    // if (!signer.email.isEmpty()) {
    Contact[] pccheck = [Select ID, AccountID from Contact where email = :signer.email];
    system.debug('signer.email is ' + signer.email);
    system.debug('signer.lastname is ' + signer.lastname);
    system.debug('signer is ' + signer);
    //Make sure that there's a match, and that it's not a match on "null"
    if (pccheck.size() > 0 && signer.Email != null && signer.email != '') {
    // The Secure Guest User Settings prohibit the following code, March 2020
////    if (signer.phone <> null) pccheck[0].phone=signer.phone;
////    if (signer.MailingStreet<> null) pccheck[0].MailingStreet=signer.MailingStreet;
////    if (signer.MailingCity <> null) pccheck[0].MailingCity=signer.MailingCity;
////    if (signer.MailingState <> null) pccheck[0].MailingState=signer.MailingState;
////    if (signer.MailingPostalCode <> null) pccheck[0].MailingPostalCode=signer.MailingPostalCode;
////    update pccheck[0];
    results[0] = pccheck[0].id;
    results[1] = 'Contact';
    results[2] = pccheck[0].accountId;
    system.debug('In ICP, just found Contact based on email ' + pccheck[0].id);
    return results;
    }
    // } // end of if email exists
    ELSE {
        //If lead exists based on email,   Make sure it's not one that's been converted.  And not null.
        Lead[] lcheck = [Select Id, Dear__c, Addressee__c from Lead where email = :signer.email and status <> 'Closed - Converted'];
    //Make sure that there's a match, and that it's not a match on "null"
    // The Secure Guest User Settings prohibit the following code, March 2020
    // if (pccheck.size() > 0 && signer.Email != null && signer.email != '') {
////    if (signer.phone <> null) pccheck[0].phone=signer.phone;
////    if (signer.MailingStreet<> null) pccheck[0].MailingStreet=signer.MailingStreet;
////    if (signer.MailingCity <> null) pccheck[0].MailingCity=signer.MailingCity;
////    if (signer.MailingState <> null) pccheck[0].MailingState=signer.MailingState;
////    if (signer.MailingPostalCode <> null) pccheck[0].MailingPostalCode=signer.MailingPostalCode;
////    update pccheck[0];

        if (lcheck.size() > 0  && signer.Email != null) {

        // The Secure Guest User Settings prohibit the following code, March 2020
//            if (signer.phone <> null) lcheck[0].phone=signer.phone;
//            if (signer.MailingStreet<> null) lcheck[0].Street=signer.MailingStreet;
//            if (signer.MailingCity <> null) lcheck[0].City=signer.MailingCity;
//            if (signer.MailingState <> null) lcheck[0].State=signer.MailingState;
//            if (signer.MailingPostalCode <> null) lcheck[0].PostalCode=signer.MailingPostalCode;
//            // Update Lead.Dear__c and Addressee__c if blank.
//            if (lcheck[0].Dear__c == null) lcheck[0].Dear__c=signer.Firstname;
//            if (lcheck[0].Addressee__c == null) lcheck[0].Addressee__c=signer.firstname + ' ' +  signer.lastname;
            update lcheck[0];
        results[0] = lcheck[0].Id;
        results[1] = 'Lead';
                system.debug('In ICP, just found Lead based on email ' + lcheck[0].id);
        return results;
        }
        ELSE {
            //does contact exist based on name and zip code?
            system.debug('signer.firstname is ' + signer.firstname);
            pccheck = [Select ID, AccountID,firstname,lastname,MailingPostalCode from Contact 
                where (firstname = :signer.firstname AND lastname = :signer.lastname 
                and MailingPostalCode = :signer.MailingPostalCode)];
            if (pccheck.size() > 0) {
            // The Secure Guest User Settings prohibit the following code, March 2020
//            if (signer.phone <> null) pccheck[0].phone=signer.phone;
//            if (signer.MailingStreet<> null) pccheck[0].MailingStreet=signer.MailingStreet;
//            if (signer.MailingCity <> null) pccheck[0].MailingCity=signer.MailingCity;
//            if (signer.MailingState <> null) pccheck[0].MailingState=signer.MailingState;
//            if (signer.MailingPostalCode <> null) pccheck[0].MailingPostalCode=signer.MailingPostalCode;
//            update pccheck[0];
            results[0] = pccheck[0].ID;
            results[1] = 'Contact';
    		results[2] = pccheck[0].accountId;
                system.debug('In ICP, just found Contact based on first+last+zip ' + pccheck[0].id);
            return results;
            }
            ELSE {
                //does LEAD exist based on name and zip code?  Make sure it's not one that's been converted.
                lcheck = [Select ID, firstname, lastname, PostalCode, Dear__c, Addressee__c from Lead 
                    where (firstname = :signer.firstname AND lastname = :signer.lastname
                    AND PostalCode = :signer.MailingPostalCode) and status <> 'Closed - Converted'];
                if (lcheck.size() > 0) {
                    // The Secure Guest User Settings prohibit the following code, March 2020
//                    if (signer.phone <> null) lcheck[0].phone=signer.phone;
//                    if (signer.MailingStreet<> null) lcheck[0].Street=signer.MailingStreet;
//                    if (signer.MailingCity <> null) lcheck[0].City=signer.MailingCity;
//                    if (signer.MailingState <> null) lcheck[0].State=signer.MailingState;
//                    if (signer.MailingPostalCode <> null) lcheck[0].PostalCode=signer.MailingPostalCode;
//                    // Update Lead.Dear__c and Addressee__c if blank.
//                    if (lcheck[0].Dear__c == null) lcheck[0].Dear__c=signer.Firstname;
//                    if (lcheck[0].Addressee__c == null) lcheck[0].Addressee__c=signer.firstname + ' ' +  signer.lastname;
//                    update lcheck[0];
                results[0] = lcheck[0].Id;
                results[1] = 'Lead';
                system.debug('In ICP, just found Lead based on first+last+zip. ' + lcheck[0].id );
                return results;
                } //end does Lead exist based on name and zip code?
                ELSE {
                    //create new lead
                    system.debug('In ICP, didnt find Contact or Lead, just entered Create New Lead');
                    lead newlead = new Lead (lastname = signer.lastname, 
                    firstname=signer.firstname,
                    email=signer.email, 
                    dear__c=signer.firstname,
                    Addressee__c=signer.firstname + ' ' + signer.lastname,                         
                    postalcode=signer.MailingPostalCode,
                    company= signer.lastname + ', ' + signer.firstname + ' Household', 
                    RecordTypeID = [select ID from RecordType where name = 'Online Signup'].id);
                    if (signer.phone <> null) newlead.phone=signer.phone;
                    if (signer.MailingStreet<> null) newlead.Street=signer.MailingStreet;
                    if (signer.MailingCity <> null) newlead.City=signer.MailingCity;
                    if (signer.MailingState <> null) newlead.State=signer.MailingState;
                    if (signer.MailingPostalCode <> null) newlead.PostalCode=signer.MailingPostalCode;
                    system.debug('Just before insert, signer.lastname is ' + signer.lastname);
                    try {
                    insert newlead;
                    results[0] = newlead.id;
                    results[1] = 'Lead';
                    }
                    catch (exception x) {
                    results[0] = null;
                    results[1] = 'Error ' + x.getmessage();
                    }
                    return results;
                    } //end create new lead
            } //end ELSE does lead exist?
        } //end ELSE does contact exist?
    } // end ELSE does lead exist based on email?
} // end does contact exist based on email?
}