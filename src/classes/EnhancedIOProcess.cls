/**
 * Created by PeterChurchill on 2/7/2018.
 */

public with sharing class EnhancedIOProcess {
        public ImportObject__c matchIO {get; set;}
        public sObject matchedsObject {get; set;}
        public List<enhancedIOResult> eioResults {get; set;}
        public String IOlastname;
        public String IOfirstname;
        public String IOfirstinitial;
        //If we match by Legacy Id, only match by Email if not the same
        public String IOlegacyEmail;
        public Boolean bCreate {get;set;}
        public integer iBestMatchScore {get;set;}
        public Boolean bIsDonation {get;set;}

        public EnhancedIOProcess(ImportObject__c IO){

            if (IO.Contribution_Amount__c != NULL || IO.Contribution_HoursActual__c != NULL) {
                bIsDonation = TRUE;
            }

            eioResults = new List<enhancedIOResult> ();
            matchIO = IO;
            IOlastname = IO.Person_LastName__c;
            if (String.IsBlank(IO.Person_FirstName__c) == FALSE) {
                IOfirstname = IO.Person_FirstName__c;
                IOfirstinitial = IO.Person_FirstName__c.left(1);
            }

        }

        public class enhancedIOResult {
            public sObject matchedsObject {get; set;}
            public String sType {get; set;}
            public string MatchReliability {get;set;}
            public Boolean bUseThisRecord {get;set;}
            public integer iMatchScore {get;set;}

            public enhancedIOResult() {
                iMatchScore = 10;
            }
        }
}