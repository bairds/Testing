// identifyPerson takes contact 'signer'
// returns person[0] contact or lead id as string
// person[1] 'Contact' or 'Lead'
// person[2] 'match on email and name', 'match on email not name', 'match on name and zip',
// if not match found, return null
// August 2017 Jose modifies to add different matching conditions, Baird makes matching contact and lead available
// Sept 2 2017 Baird modifies to also pass Contact.AccountId to requesting method
public with sharing class identifyPerson {
	
public static List<String> person {get; set;}
public static Contact returnContact;
public static Lead returnLead;

//Identify Contact or Lead
public static String [] identifyPerson(Contact signer) { 
//declare a list to store results
person = new String[4];
   Contact[] pccheck;
    
    //Look for LegacyId and check if contact exists based on email or name
    if(String.isNotBlank(signer.Legacy_Contact_ID__c)) {
        pccheck = [ SELECT ID, AccountID, firstname, lastname, mailingstreet, mailingcity, mailingState, mailingPostalCode from Contact WHERE Legacy_Contact_ID__c =: signer.Legacy_Contact_ID__c AND 
                   		(email =: signer.email OR (firstname = :signer.firstname AND lastname = :signer.lastname)) LIMIT 1];
        
        if(pccheck.size() > 0) {
        	person[0] = pccheck[0].id;
            person[1] = 'Contact';
            person[2] = 'match on legacy id and email or name'; 
            person[3] = pccheck[0].AccountId;
            returnContact = pcCheck[0];
            
            return person;
    	}
    }
    
//If contact exists based on email and names
    pccheck = [Select ID, AccountID, firstname, lastname, mailingstreet, mailingcity, mailingState, mailingPostalCode from Contact where email = :signer.email and firstname = :signer.firstname
		and lastname = :signer.lastname];
    system.debug('signer is ' + signer);
    if (pccheck.size() > 0) {
    person[0] = pccheck[0].id;
    person[1] = 'Contact';
	person[2] = 'match on email and name'; 
    person[3] = pccheck[0].AccountId;
    returnContact = signer;
    system.debug('In IP, just found Contact based on email and name ' + pccheck[0].id + ' with AccountId ' + pccheck[0].AccountId);
      return person;
    }
	ELSE {
		//If contact matches email but not names
		pccheck = [Select ID, AccountID, firstname, lastname, mailingstreet, mailingcity, mailingState, mailingPostalCode from Contact where email = :signer.email];
		if (pccheck.size() > 0) {
		person[0] = pccheck[0].id;
    	person[1] = 'Contact';
		person[2] = 'match on email not name';
            person[3] = pccheck[0].AccountId;
            returnContact = pcCheck[0];
    	system.debug('In ICP, just found Contact based on email alone ' + pccheck[0].id);
    	return person;
		} //end 
	    ELSE {
	        //If lead exists based on email and names,   Make sure it's not one that's been converted.
	        Lead[] lcheck = [Select Id, firstname, lastname, street, city, state, PostalCode from Lead where email = :signer.email and status <> 'Closed - Converted'
				and firstname = :signer.firstname and lastname = :signer.lastname];
	        if (lcheck.size() > 0) {
	        person[0] = lcheck[0].Id;
	        person[1] = 'Lead';
			person[2] = 'match on email and name';
                returnLead = lcheck[0];
			system.debug('In ICP, just found Lead based on email and names ' + lcheck[0].id);
	        return person;
	        }
	        ELSE {
				//If lead matches email but not names
				lcheck = [Select ID, firstname, lastname, street, city, state, PostalCode from Lead where email = :signer.email];
				if (lcheck.size() > 0) {
				person[0] = lcheck[0].id;
    			person[1] = 'Lead';
				person[2] = 'match on email not name';
                returnLead = lcheck[0];
   			 	system.debug('In ICP, just found Lead based on email alone ' + lcheck[0].id);
  			  	return person;
				} // end if lcheck.size > 0
				ELSE {
					//does contact exist based on name and zip code?
		            system.debug('signer.firstname is ' + signer.firstname);
		            pccheck = [Select ID, AccountID,firstname, lastname, mailingstreet, mailingcity, mailingState, mailingPostalCode from Contact 
		                where (firstname = :signer.firstname AND lastname = :signer.lastname 
		                and MailingPostalCode = :signer.MailingPostalCode)];
		            if (pccheck.size() > 0) {
		            person[0] = pccheck[0].ID;
		            person[1] = 'Contact';
					person[2] = 'match on name and zip';
            person[3] = pccheck[0].AccountId;
                	returnContact = pccheck[0];
		                system.debug('In ICP, just found Contact based on first+last+zip ' + pccheck[0].id);
		            return person;
		            }
		            ELSE {
		                //does LEAD exist based on name and zip code?  Make sure it's not one that's been converted.
		                lcheck = [Select ID, firstname, lastname, street, city, state, PostalCode from Lead 
		                    where (firstname = :signer.firstname AND lastname = :signer.lastname
		                    AND PostalCode = :signer.MailingPostalCode) and status <> 'Closed - Converted'];
		                if (lcheck.size() > 0) {
		                person[0] = lcheck[0].Id;
		                person[1] = 'Lead';
						person[2] = 'match on name and zip';
                returnLead = lcheck[0];
		                system.debug('In ICP, just found Lead based on first+last+zip. ' + lcheck[0].id );
		                return person;
		                } //end does Lead exist based on name and zip code?
		                ELSE {
		                    //return null
		                    person = null;
		                    return person;
		                    } //end return null
	            } //end ELSE does lead exist?
	        } //end ELSE does contact exist?
			} // end ELSE does lead match email but not names?
	    } // end ELSE does lead exist based on email?
		} //end If contact matches email but not names
	} // end does contact exist based on email and last names?
}