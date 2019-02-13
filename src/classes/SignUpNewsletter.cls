public with sharing class SignUpNewsletter{


//Identify Contact or Lead
public static String SignUpNewsletter(List<String> results) {
	WGSettings__mdt Settings = WGHelpers.getWGSettings();
	String mailing_list = Settings.online_signup_newsletter__c;

        if (results[1] == 'Contact')
        	{
	        contact tempContact = [select id, mailing_lists__c from Contact where id = :results[0]];
	        system.debug('Found that tempContact.mailing_lists__c is' + tempContact.Mailing_Lists__c);
	        if (tempContact.Mailing_Lists__c == null) {
	                tempContact.Mailing_Lists__c = mailing_list;
	                system.debug('Passed ïf mailing_lists__c == null, set it to single value');
					update tempContact;
					return tempContact.Mailing_Lists__c;
	                }
		        else { // mailing_lists__c not null
					if (tempContact.Mailing_Lists__c.contains(mailing_list)) {return mailing_list;}
						else {
							tempContact.Mailing_Lists__c = tempContact.Mailing_Lists__c+ ';' + mailing_list;
				                system.debug('Just added mailing_list to Mailing_lists__c');                  
				                }
		            update tempContact;
					return tempContact.mailing_lists__c; 
		        	} // end if not null
				} // end if Contact
    	else {
    
	    if (results[1] == 'Lead' ) {
        Lead tempLead = [select id, mailing_lists__c from Lead where id = :results[0]];
	    system.debug('Found that tempLead.mailing_lists__c is' + tempLead.Mailing_Lists__c);
	        if (tempLead.Mailing_Lists__c == null) {
	                tempLead.Mailing_Lists__c = mailing_list;
	                system.debug('Passed ïf mailing_lists__c == null, set it to single value');
	                }
		        else { // mailing_lists__c not null
					if (tempLead.Mailing_Lists__c.contains(mailing_list)) {return mailing_list;}
						else {
							tempLead.Mailing_Lists__c = tempLead.Mailing_Lists__c+ ';' + mailing_list;
				                system.debug('Just added mailing_list to Mailing_lists__c'); 
								}
		        	} // end if not null
					update tempLead;
					return tempLead.Mailing_Lists__c;
				} // end if Lead
	            else {
	                system.debug('In SignupNewsletter, was not passed either contact or lead value');
					ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'In SignupNewsletter, was not passed either contact or lead value');
					ApexPages.addmessage(myMsg);
					return null;
	            } 
	} // end Else check if results[1] is Lead 
} // END SignUpNewsletter


}