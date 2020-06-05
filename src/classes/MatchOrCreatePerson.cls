/**
 * Created by PeterChurchill on 2/6/2018.
 */

public with sharing class MatchOrCreatePerson {

    public Map<String, ImportObject__c> recordstoMatchMap;
    private set<string> MatchingEmails;
    private set<string> MatchingNames;
    private  set<string> LegacyIds;
    public List<EnhancedIOProcess> NewEnhancedIOs;
    public Map<Id, sObject> newSoRecordsMap {get;set;}
    private map<string,List<sObject> > lookupMap;
    List<EnhancedIOProcess> records;
    // Helper class to create map of all contacts, make sure they aren't duplicates
    public List< List< EnhancedIOProcess> > EIMatches {get;set;}
    private static Map<String, Data_Import_Mapping__mdt> DataImportFieldMap;
    //Create Map to hold Contacts at any Account that we us ein Match to look for Contact 2 by Name only
    public Map<Id, Map<String, Contact>> accountContactLookupMap;

    public MatchOrCreatePerson() {

    }

    Public void matchRecordsToPeople(List<EnhancedIOProcess> recordsToProcess) {


        setupLists();
        records = recordsToProcess;
        newSoRecordsMap = new Map<Id, sObject> ();
        // Turn off autorecalculation of account totals
        AvoidRecursiveContributionTrigger.setWorking();
        setupMatchingLists();
        setupLookupMap();

        // Loop through new EnhancedIOs
        for (EnhancedIOProcess eio : records) {
            //Integer for List this EI Record should be added to at end
            Integer iList;
            List<sObject> tempPersons;
            EnhancedIOProcess.enhancedIOResult iotemp;

            eio.eioResults.clear();
            //Check Legacy Id First
            if (String.IsBlank(eio.matchIO.Person_LegacyID__c) == FALSE && lookupMap.containskey(eio.matchIO.Person_LegacyID__c)) {
                for (sObject sotemp: lookupMap.get(eio.matchIO.Person_LegacyID__c) ) {
                    iotemp = new EnhancedIOProcess.enhancedIOResult();
                    iList = 4; //Watergrass List
                    iotemp.matchedsObject = sotemp;
                    iotemp.MatchReliability = 'Match on Legacy Id';
                    iotemp.iMatchScore = 4;
                    //Add Email to avoid dup matches by email
                    if (sotemp.get('Email') != NULL) {
                        eio.IOlegacyEmail = (String)sotemp.get('Email');
                    }
                    iotemp.sType = sotemp.getSObjectType().getDescribe().getName();
                    iotemp.bUseThisRecord = TRUE;
                    eio.iBestMatchScore =  iotemp.iMatchScore;
                    eio.eioResults.add(iotemp);
            }

            }

            //Check work email
            if (String.IsBlank(eio.matchIO.Person_EmailWork__c) == FALSE && lookupMap.containskey(eio.matchIO.Person_EmailWork__c)) {
                Integer tempiList;
                for (sObject sotemp: lookupMap.get(eio.matchIO.Person_EmailWork__c) ) {
                    //Don't add if legacy id match used same email
                    if (eio.IOlegacyEmail == NULL || eio.IOlegacyEmail != eio.matchIO.Person_EmailWork__c) {

                        iotemp = new EnhancedIOProcess.enhancedIOResult();
                        iotemp.matchedsObject = sotemp;
                        tempiList = 1;
                        iotemp.MatchReliability = 'Match on Email only';
                        iotemp.iMatchScore = 1;

                        String sLastName = (String) sotemp.get('lastname');
                        String sFirstName = (String) sotemp.get('firstname');

                        if (eio.IOlastname.tolowercase() == sLastName.tolowercase()) {
                            tempiList = 2;
                            iotemp.iMatchScore = 2;
                            iotemp.MatchReliability = 'Match on Email LN';
                            if (sFirstName != NULL) {
                                if (eio.IOfirstinitial == sFirstName.left(1)) {
                                    tempiList = 3;
                                    iotemp.iMatchScore = 3;
                                    iotemp.MatchReliability = 'Match on Email LN FN';
                                }
                            }
                        }
                        //If iList not set by WaterGrass Id check then set to highest email match
                        if (iList == NULL) iList = tempiList;
                        iotemp.sType = sotemp.getSObjectType().getDescribe().getName();
                        //If this is first match, use this record as primary match
                        if (eio.eioResults.IsEmpty() == TRUE) {
                            iotemp.bUseThisRecord = TRUE;
                            eio.iBestMatchScore =  iotemp.iMatchScore;
                        }
                        //but for subsequent matches, replace if this is a higher match
                        else {
                            if (iotemp.iMatchScore > eio.iBestMatchScore) {
                                eio.iBestMatchScore = iotemp.iMatchScore;
                                iotemp.bUseThisRecord = TRUE;
                                //Uncheck any others
                                for (EnhancedIOProcess.enhancedIOResult eiortemp: eio.eioResults) {
                                    eiortemp.bUseThisRecord = FALSE;
                                }
                            }
                        }

                        eio.eioResults.add(iotemp);
                    }
                }
            }
            //personal email
            if (String.IsBlank(eio.matchIO.Person_EmailPersonal__c) == FALSE && lookupMap.containskey(eio.matchIO.Person_EmailPersonal__c)) {
                Integer tempiList;
                for (sObject sotemp: lookupMap.get(eio.matchIO.Person_EmailPersonal__c) ) {
                    if (eio.IOlegacyEmail == NULL || eio.IOlegacyEmail != eio.matchIO.Person_EmailPersonal__c) {
                        iotemp = new EnhancedIOProcess.enhancedIOResult();
                        iotemp.matchedsObject = sotemp;
                        iotemp.MatchReliability = 'Match on Email only';
                        tempiList = 1;
                        iotemp.iMatchScore = 1;

                        String sLastName = (String) sotemp.get('lastname');
                        String sFirstName = (String) sotemp.get('firstname');

                        if (eio.IOlastname.tolowercase() == sLastName.tolowercase()) {
                            iotemp.MatchReliability = 'Match on Email LN';
                            tempiList = 2;
                            iotemp.iMatchScore = 2;
                            if (sFirstName != NULL) {
                                if (eio.IOfirstinitial == sFirstName.left(1)) {
                                    iotemp.MatchReliability = 'Match on Email LN FN';
                                    tempiList = 3;
                                    iotemp.iMatchScore = 3;
                                }
                            }
                        }
                        if (iList == NULL) {
                            iList = tempiList;
                        }
                        //This email match may be higher than last match though so higher wins
                        else if (iList < tempiList ) {
                            iList = tempiList;
                        }
                        iotemp.sType = sotemp.getSObjectType().getDescribe().getName();

                        if (eio.eioResults.IsEmpty() == TRUE) {
                            iotemp.bUseThisRecord = TRUE;
                            eio.iBestMatchScore =  iotemp.iMatchScore;
                        }
                        //but for subsequent matches, replace if this is a higher match
                        else {
                            if (iotemp.iMatchScore > eio.iBestMatchScore) {
                                eio.iBestMatchScore = iotemp.iMatchScore;
                                iotemp.bUseThisRecord = TRUE;
                                //Uncheck any others
                                for (EnhancedIOProcess.enhancedIOResult eiortemp: eio.eioResults) {
                                    eiortemp.bUseThisRecord = FALSE;
                                }
                            }
                        }
                        eio.eioResults.add(iotemp);
                    }
                }
            }

           //Key Name Match if no earlier matches
            //if (eio.eioResults.IsEmpty() == TRUE) {
                String sKey;
                if (String.IsBlank(eio.matchIO.Person_FirstName__c) == FALSE &&
                        String.IsBlank(eio.matchIO.Person_LastName__c) == FALSE &&
                        String.IsBlank(eio.matchIO.Address_ZipCode__c) == FALSE
                    )
                {
                    sKey = (String) eio.matchIO.Person_FirstName__c.tolowercase() + (String) eio.matchIO.Person_LastName__c.tolowercase() + (String) eio.matchIO.Address_ZipCode__c.tolowercase();
                }
                if (sKey != NULL) {
                    if (lookupMap.containskey(sKey)) {

                        for (sObject sotemp : lookupMap.get(sKey)) {

                            //First check if we already matched on some other better key
                            Boolean bAddRecord = TRUE;
                            for (EnhancedIOProcess.enhancedIOResult eiortemp : eio.eioResults) {
                                if (soTemp.Id == eiortemp.matchedsObject.Id) {
                                    bAddRecord = FALSE;
                                }
                            }

                            if (bAddRecord) {
                                iotemp = new EnhancedIOProcess.enhancedIOResult();
                                iotemp.matchedsObject = sotemp;
                                iotemp.MatchReliability = 'Match on LN FN ZIP';
                                if (iList == NULL) iList = 0;
                                iotemp.sType = sotemp.getSObjectType().getDescribe().getName();
                                if (eio.eioResults.IsEmpty() == TRUE) iotemp.bUseThisRecord = TRUE;
                                eio.eioResults.add(iotemp);
                            }
                        }
                    }
                }
            //}
            //Check if any records matched - if not create
            if (eio.eioResults.IsEmpty() == TRUE) {
            //Create new
                sObject newSO = createnewrecord(eio.matchIO, eio.bIsDonation);
                //newSoRecords.add(newSO);
                //newSoRecordsMap.put(eio.matchIO.Id, newSO);
                iotemp = new EnhancedIOProcess.enhancedIOResult();
                iotemp.matchedsObject = newSO;
                eio.matchedsObject = newSO;
                iotemp.MatchReliability = 'Create New Record';
                if (iList == NULL) iList = 5;
                iotemp.iMatchScore = 1;
                iotemp.sType = 'New ' + newSO.getSObjectType().getDescribe().getName();
                if (eio.eioResults.IsEmpty() == TRUE)  iotemp.bUseThisRecord = TRUE;
                eio.eioResults.add(iotemp);
            }

            system.debug(iList + ':' + eio);
            EIMatches[iList].add(eio);
        }

        // For all those without probable matches, we create new leads or contacts
        // We add the new leads or contacts to the DIO.Id,Person.Id map
        // For each DIO we choose the highest probability match
        // We remove all the matched records from the list of records
        // We create a set by email, create the new leads and contacts, return a list of the new
        // 	In each DIO record insert LeadId or ContactId;
        //update records;
        //return records;
        AvoidRecursiveContributionTrigger.setClosed();
        // Refresh account totals;
        //return null;
    }

    public void createNEWSORecords() {
        Map<Id, Account> newAccountsforContacts = new Map<Id, Account>();
        if (newSoRecordsMap.IsEmpty() == FALSE) {

            Schema.DescribeSObjectResult R = Account.SObjectType.getDescribe();
            Map<String, Schema.RecordTypeInfo> RTBN = R.getRecordTypeInfosByName();
            Id FamilyRTId = RTBN.get('Family').getRecordTypeId();


            for (String sTemp : newSoRecordsMap.keyset()) {
                sObject soTemp = newSoRecordsMap.get(sTemp);
                if (soTemp.getSObjectType().getDescribe().getName() == 'Contact') {//Create an Account
                    Contact c = (Contact) soTemp;
                    Account aTemp = new Account(
                            RecordTypeId = FamilyRTId,
                            Name = c.LastName + ', ' + c.FirstName + ' Household',
                            Is_Dummy__c = true,
                            Dear__c = c.Dear__c,
                            Addressee__c = c.FirstName + ' ' + c.LastName,
                            Phone = c.MobilePhone,
                            BillingStreet = c.MailingStreet,
                            BillingCity = c.MailingCity,
                            BillingState = c.MailingState,
                            BillingPostalCode = c.MailingPostalCode,
                            BillingCountry = c.MailingCountry);
                    newAccountsforContacts.put(sTemp, aTemp);
                }
            }
            //For new Contacts, we need to create Accounts First
            insert newAccountsforContacts.values();

            //Now loop back and update Contact with Acccount Id
            for (String sTemp : newSoRecordsMap.keyset()) {
                sObject soTemp = newSoRecordsMap.get(sTemp);
                if (soTemp.getSObjectType().getDescribe().getName() == 'Contact') {//Create an Account
                    if (newAccountsforContacts.containskey(sTemp) && newAccountsforContacts.get(sTemp).Id != NULL) { //Confirm Account created
                        soTemp.put('AccountId', newAccountsforContacts.get(sTemp).Id);
                        //Add to account lookup map for later use
                        accountContactLookupMap.put(newAccountsforContacts.get(sTemp).Id,new Map<String, Contact>());
                    }
                }
            }

            //Build ordered Map for Error handling
            List<Id> importLeadids = new List<Id>();
            List<Id> importContactids = new List<Id>();

            Map<Id, sObject> importMapLead = new Map<Id, sObject>();
            Map<Id, sObject> importMapContact = new Map<Id, sObject>();


            for (Id idTemp : newSoRecordsMap.keyset()) {
                sObject soTemp = newSoRecordsMap.get(idTemp);
                if (soTemp.getSObjectType().getDescribe().getName() == 'Contact') {
                    importMapContact.put(idTemp, newSoRecordsMap.get(idTemp));
                    importContactids.add(idTemp);
                }
                else if (soTemp.getSObjectType().getDescribe().getName() == 'Lead') {
                    importMapLead.put(idTemp, newSoRecordsMap.get(idTemp));
                    importLeadids.add(idTemp);
                }
            }

            List<WG_Error_Log__c> errors = new List<WG_Error_Log__c>();

            Database.SaveResult [] dsrLead = database.insert (importMapLead.values(), false);
            Database.SaveResult [] dsrContact = database.insert (importMapContact.values(), false);

            for (Integer i = 0; i < dsrLead.size(); i++) {
                if (dsrLead[i].isSuccess() == FALSE) {
                    Database.SaveResult sr = dsrLead[i];
                    // Use index to find unrelated id
                    Id ImportId = importLeadids[i];
                    errors.add(importError (ImportId, sr.getErrors()));
                }
            }
            for (Integer i = 0; i < dsrContact.size(); i++) {
                if (dsrContact[i].isSuccess() == FALSE) {
                    Database.SaveResult sr = dsrContact[i];
                    // Use index to find unrelated id
                    Id ImportId = importContactids[i];
                    errors.add(importError (ImportId, sr.getErrors()));
                }

            }
        insert errors;
        }
    }

    public Map<String, Campaign> createCampaigns(List<ImportObject__c> importRecords) {
        Map<String, Campaign> sCampaignMap = new Map<String, Campaign>();
        Map<String, Campaign> sNewCampaignMap = new Map<String, Campaign>();

        Set<String> sCampaigns = new Set<String>();
//Campaign_IsActive__c	Campaign_Name__c	Campaign_Type__c	Campaign_TypeText__c

        Schema.DescribeSObjectResult R = Campaign.SObjectType.getDescribe();
        Map<String, Schema.RecordTypeInfo> RTBN = R.getRecordTypeInfosByName();


        for (ImportObject__c iotemp: importRecords) {
            sCampaigns.add(iotemp.Campaign_Name__c);
        }

        for (Campaign camp: [Select Id, Name from Campaign WHERE Name IN :sCampaigns]) {
            sCampaignMap.put(camp.name, camp);
        }

        for (ImportObject__c iotemp: importRecords) {

            if (sNewCampaignMap.containskey(iotemp.Campaign_Name__c) == FALSE && sCampaignMap.get(iotemp.Campaign_Name__c) ==  NULL) {//No match, and not in list to create
                Campaign ctemp = new Campaign();
                ctemp.IsActive = iotemp.Campaign_IsActive__c;
                ctemp.Name = iotemp.Campaign_Name__c;

                if (RTBN.containsKey(iotemp.Campaign_Record_Type__c)) {
                    ctemp.RecordTypeId =  RTBN.get(iotemp.Campaign_Record_Type__c).getRecordTypeId();
                }

                ctemp.Type = iotemp.Campaign_TypeText__c;

                sNewCampaignMap.put(iotemp.Campaign_Name__c, ctemp);
            }
        }
        insert sNewCampaignMap.values();
        sCampaignMap.putall(sNewCampaignMap);

        return sCampaignMap;
    }

private sObject createnewrecord(ImportObject__c iotemp, Boolean bIsDonation) {
Sobject so;

    String sStreet = getStreetValue(iotemp);

    //If there is a donation OR there is a second person, create a Contact
    if (bIsDonation == TRUE || String.IsBlank(iotemp.Person2_LastName__c) == FALSE ) {
            //Contribution, so create Contact
        so = new Contact();
        so.put('MailingStreet', sStreet);
        so.put('MailingCity', iotemp.Address_City__c);
        so.put('MailingState', iotemp.Address_State__c);
        so.put('MailingPostalCode', iotemp.Address_ZipCode__c);
        so.put('MailingCountry', iotemp.Address_Country__c);
        so.put('HomePhone', iotemp.Person_PhoneHome__c);
        so.put('OtherPhone', iotemp.Person_PhoneOther__c);
    }
    else {
        so = new Lead();
        so.put('Company', 'Family');

        so.put('Street', sStreet);
        so.put('City', iotemp.Address_City__c);
        so.put('State', iotemp.Address_State__c);
        so.put('PostalCode', iotemp.Address_ZipCode__c);
        so.put('Country', iotemp.Address_Country__c);
        so.put('Home_Phone__c', iotemp.Person_PhoneHome__c);

    }
    //Handle shared fieldname first
    Map<String, Data_Import_Mapping__mdt> dataImportFieldMap = getDataImportMap();


    so.put('FirstName', iotemp.Person_FirstName__c);
    so.put('LastName', iotemp.Person_LastName__c);
    so.put('Salutation', iotemp.Person_Prefix__c);

    for (Data_Import_Mapping__mdt dtemp:  dataImportFieldMap.values()) {
        so.put(dtemp.Target_Field__r.QualifiedAPIName, (String) iotemp.get ( dtemp.IO_FieldName__c) );
    }

    //so.put('Personal_Email__c', iotemp.Person_EmailPersonal__c);
    //so.put('Work_Email__c', iotemp.Person_EmailWork__c);

    //so.put('Legacy_Contact_ID__c', iotemp.Person_LegacyID__c);
    //so.put('Phone', iotemp.Person_PhoneWork__c);
    //so.put('MobilePhone', iotemp.Person_PhoneMobile__c);
    //so.put('Title', iotemp.Person_Title__c);
    //so.put('Volunteer_Interests__c', iotemp.Person_VolunteerInterestsText__c);
    //so.put('Mailing_Lists__c', iotemp.Person_MailingListsText__c);
    //so.put('Do_Not__c', iotemp.Person_DoNot__c);

    if (String.IsBlank(iotemp.Person_LegacyID__c) == FALSE) {
        lookupMap.put(iotemp.Person_LegacyID__c, new List<sObject> {so});
    }
    if (String.IsBlank(iotemp.Person_EmailPersonal__c) == FALSE) {
        lookupMap.put(iotemp.Person_EmailPersonal__c, new List<sObject> {so});
    }
    if (String.IsBlank(iotemp.Person_EmailWork__c) == FALSE) {
        lookupMap.put(iotemp.Person_EmailWork__c, new List<sObject> {so});
    }

    if (    String.IsBlank(iotemp.Person_FirstName__c) == FALSE &&
            String.IsBlank(iotemp.Person_LastName__c) == FALSE &&
            String.IsBlank(iotemp.Address_ZipCode__c) == FALSE
            )
    {
        String sKey = (String)iotemp.Person_FirstName__c.tolowercase() + (String)iotemp.Person_LastName__c.tolowercase() + (String)iotemp.Address_ZipCode__c.tolowercase();
        lookupMap.put(sKey, new List<sObject> {so});
    }

    return so;
}

private void setupMatchingLists() {
NewEnhancedIOs = new List<EnhancedIOProcess>();

MatchingEmails = new set<string>();
MatchingNames = new set<string>();
LegacyIds = new set<string>();

for (EnhancedIOProcess EIO : records) {
    ImportObject__c io = EIO.matchIO;
    //NewEnhancedIOs.add(new enhancedIO(IO));
    system.debug(io);
    if (String.IsBlank(IO.Person_LegacyID__c) == FALSE) LegacyIds.add(IO.Person_LegacyID__c);

    if (String.IsBlank(IO.Person_EmailPersonal__c) == FALSE) MatchingEmails.add(IO.Person_EmailPersonal__c);
    if (String.IsBlank(IO.Person_EmailWork__c) == FALSE) MatchingEmails.add(IO.Person_EmailWork__c);

    if (
            String.IsBlank(IO.Person_FirstName__c) == FALSE &&
            String.IsBlank(IO.Person_LastName__c)  == FALSE &&
            String.IsBlank(IO.Address_ZipCode__c)  == FALSE
    )
        MatchingNames.add(IO.Person_FirstName__c.tolowercase() + IO.Person_LastName__c.tolowercase()+ IO.Address_ZipCode__c.tolowercase());
    }
}

private void setupLookupMap() {
// Create map of Lead and Contact who match list of newRecords
lookupMap = new map<string,List<sObject> >();
accountContactLookupMap = new Map<Id, Map<String, Contact>>();

String sLeadQuery = 'SELECT id, Name, Legacy_Contact_ID__c, email, firstname, lastname, phone, mobilephone,Home_Phone__c,' +
        ' Company,Street, City, State,PostalCode, Country,Salutation, Personal_Email__c,Other_Email__c, Lookup_Key__c, ' +
        ' Work_Email__c, Title, Volunteer_Interests__c, Mailing_Lists__c, Do_Not__c FROM Lead WHERE isConverted = FALSE ';
String sLeadLegacyQuery = sLeadQuery +  ' AND Legacy_Contact_ID__c in :LegacyIds';
String sLeadEmailQuery = sLeadQuery +  ' AND ( ' +
        ' email IN :MatchingEmails OR Personal_Email__c IN :MatchingEmails ' +
        ' OR Other_Email__c IN :MatchingEmails OR Work_Email__c IN :MatchingEmails ) ';
String sLeadNameQuery = sLeadQuery +  ' AND Lookup_Key__c in :MatchingNames ';

//Leads first so that matched Contacts will overwrite

        for (Lead MatchingLeads : database.query(sLeadLegacyQuery)) {
            addtoSOList(MatchingLeads.Legacy_Contact_ID__c, MatchingLeads);
        }


for (Lead MatchingLeads : database.query(sLeadEmailQuery) ) {
    if (String.isNotBlank(MatchingLeads.email)) addtoSOList(MatchingLeads.email, MatchingLeads);

    if (String.isNotBlank(MatchingLeads.Personal_Email__c)) addtoSOList(MatchingLeads.Personal_Email__c, MatchingLeads);

    if (String.isNotBlank(MatchingLeads.Other_Email__c)) addtoSOList(MatchingLeads.Other_Email__c, MatchingLeads);

    if (String.isNotBlank(MatchingLeads.Work_Email__c)) addtoSOList(MatchingLeads.Work_Email__c, MatchingLeads);
}

for (Lead MatchingLeads : database.query(sLeadNameQuery)) {
    addtoSOList(MatchingLeads.Lookup_Key__c, MatchingLeads);
}

    String sContactQuery = 'SELECT Id, Legacy_Contact_ID__c, Name, accountid, email, firstname, lastname, homephone, mobilephone, ' +
            ' MailingStreet, MailingCity, MailingState,MailingPostalCode, MailingCountry,OtherPhone, Salutation, Lookup_Key__c, ' +
            ' Personal_Email__c,Other_Email__c, Work_Email__c, Title, Volunteer_Interests__c, Mailing_Lists__c, Do_Not__c FROM Contact ';
    String sContactLegacyQuery = sContactQuery +  ' WHERE Legacy_Contact_ID__c in :LegacyIds';
    String sContactEmailQuery = sContactQuery +  ' WHERE ( ' +
            ' email IN :MatchingEmails OR Personal_Email__c IN :MatchingEmails ' +
            ' OR Other_Email__c IN :MatchingEmails OR Work_Email__c IN :MatchingEmails ) ';
    String sContactNameQuery = sContactQuery +  ' WHERE Lookup_Key__c in :MatchingNames ';

for (Contact MatchingContacts : database.query(sContactLegacyQuery) ) {
    //Add to Account Lookup Map to check for Contact 2
    accountContactLookupMap.put(MatchingContacts.AccountId, null );
    addtoSOList(MatchingContacts.Legacy_Contact_ID__c, MatchingContacts);
}

for (Contact MatchingContacts : database.query(sContactEmailQuery) ) {
    accountContactLookupMap.put(MatchingContacts.AccountId, null);
    if (String.isNotBlank(MatchingContacts.email)) addtoSOList(MatchingContacts.email, MatchingContacts);
    if (String.isNotBlank(MatchingContacts.Personal_Email__c)) addtoSOList(MatchingContacts.Personal_Email__c, MatchingContacts);
    if (String.isNotBlank(MatchingContacts.Other_Email__c)) addtoSOList(MatchingContacts.Other_Email__c, MatchingContacts);
    if (String.isNotBlank(MatchingContacts.Work_Email__c)) addtoSOList(MatchingContacts.Work_Email__c, MatchingContacts);
}

for (Contact MatchingContacts : database.query(sContactNameQuery)) {
    accountContactLookupMap.put(MatchingContacts.AccountId, null);
    addtoSOList(MatchingContacts.Lookup_Key__c, MatchingContacts);
}

    //Now populate Acount Lookup Map
    For (Account atemp: [Select Id, (Select Id, FirstName, LastName from Contacts) FROM Account WHERE ID in :accountContactLookupMap.keyset()]) {
                Map<String, Contact> ctempmap = new Map<String, Contact>();
                    for (Contact c: atemp.Contacts) {
                        ctempmap.put(c.FirstName+':'+c.LastName, c);
                    }
        accountContactLookupMap.put(atemp.Id,ctempmap);
    }
}

    public void setupLists() {
        EIMatches = new List< List<EnhancedIOProcess > > ();
        EIMatches.add(new List<EnhancedIOProcess>  ()); //Name Match 0
        EIMatches.add(new List<EnhancedIOProcess>  ()); //EmailOnlyMatch Match 1
        EIMatches.add(new List<EnhancedIOProcess>  ()); //Email LN Match Match 2
        EIMatches.add(new List<EnhancedIOProcess>  ()); //Email Full Name Match Match 3
        EIMatches.add(new List<EnhancedIOProcess>  ()); //WatergrassId Match Match 4
        EIMatches.add(new List<EnhancedIOProcess>  ()); //New Records 5
    }

    private void addtoSOList (String sKey, sObject soTemp) {
        List<sObject> soTempList = new List<sObject>();
        if (lookupMap.containskey(sKey) ) {
            soTempList = lookupMap.get(sKey);
        }
        soTempList.add(soTemp);
        lookupMap.put(sKey,soTempList);
    }

    public static string getStreetValue(ImportObject__c iotemp ) {
        String sStreet = iotemp.Address_StreetLine1__c;
        if (String.IsBlank(iotemp.Address_StreetLine2__c) == FALSE) {
            sStreet += iotemp.Address_StreetLine2__c;
        }
        if (String.IsBlank(iotemp.Address_StreetLine3__c) == FALSE) {
            sStreet += iotemp.Address_StreetLine3__c;
        }
        return sStreet;
    }

    public static WG_Error_Log__c importError (Id ImportId, Database.Error [] errors) {
        String sError = '';
        for (Database.Error err : errors) {
            sError += err.getStatusCode() + ': ' + err.getMessage() + '\n';
            sError += 'Fields that affected this error: ' + err.getFields();
        }
        WG_Error_Log__c werror = new WG_Error_Log__c();
        werror.Import_Object__c = ImportId;
        werror.Description__c = sError;
        werror.Category__c = 'Database';
        return werror;
    }

    public static Map<String, Data_Import_Mapping__mdt> getDataImportMap() {
    if (DataImportFieldMap != NULL) return DataImportFieldMap;
        DataImportFieldMap = new Map<String, Data_Import_Mapping__mdt>();
                for (Data_Import_Mapping__mdt datatemp : [
                SELECT
                        Label,
                        DeveloperName,
                        AddToExistingValue__c,
                        IO_FieldName__c,
                        Target_Field__r.QualifiedAPIName
                FROM Data_Import_Mapping__mdt
        ])
                {
                    DataImportFieldMap.put(datatemp.Target_Field__r.QualifiedAPIName, datatemp);
                }
    return DataImportFieldMap;
    }
}