/**
 * Created by PeterChurchill on 2/6/2018.
 */

public with sharing class DataImportRecords {


    //public List<ImportObject__c> records { get; set; }
    //public List<ImportObject__c> selectedRecords { get; set; }
    //public map<Id,MatchOrCreatePerson.enhancedIO> LookupMatches {get;set;}
    public List<ImportWrapper> iowrappers { get; set; }
    public MatchOrCreatePerson matchprocess { get; set; }
    public Boolean bSelectALL { get; set; }
    //Set which active tab to display after match process
    public String sActiveTab { get; set; }

    public String StringA { get; set; }
    ConvertLeadToContactBulk convertinbulk;

    public DataImportRecords() {
        bSelectALL = FALSE;
        matchprocess = new matchOrCreatePerson();
        this.StringA = '1';
        //LookupMatches = new map<Id,MatchOrCreatePerson.enhancedIO>();
        iowrappers = new List<ImportWrapper>();
        setRecords();
    }

    public void setList() {
        this.setRecords();
    }



    public void submitListToDelete() {

        List <ImportObject__c> selectedRecords = new List<ImportObject__c>();

        for (ImportWrapper iotemp : iowrappers) {
            if (iotemp.bSelected == true) {
                selectedRecords.add(iotemp.io);
            }
        }

        database.delete (selectedRecords, false);
        //refresh data
        iowrappers = new List<ImportWrapper>();
        setRecords();
    }

    public void submitListToProcess() {
        system.debug('in test');

        List <EnhancedIOProcess> selectedRecords = new List<EnhancedIOProcess>();

        for (ImportWrapper iotemp : iowrappers) {
            if (iotemp.bSelected == true) {
                selectedRecords.add(iotemp.eio);
            }
        }

        matchprocess.matchRecordsToPeople(selectedRecords);
        sActiveTab = '1';
        //iterate through results to determine active tab
        if (matchprocess.EIMatches[5].IsEmpty() == FALSE) {
            sActiveTab = '1';
        } else {
            for (integer i = 0; i < 5; i++) {
                if (matchprocess.EIMatches[i].IsEmpty() == FALSE) {
                    sActiveTab = String.Valueof(i + 2);
                    break;
                }
            }
        }
    }

    private void setRecords() {
        String sStatus = 'To Process';
        String q = 'SELECT ';

        for (Schema.sObjectField f : ImportObject__c.sObjectType.getDescribe().fields.getMap().values()) {
            q += f + ', ';
        }
        q = q.removeEnd(', ');
        q += ' FROM ImportObject__c WHERE Status__c = :sStatus Order By CreatedDate DESC';


        for (ImportObject__c rtemp : Database.query(q)) {
            //LookupMatches.put(rtemp.Id, new MatchOrCreatePerson.enhancedIO());
            iowrappers.add(new ImportWrapper(rtemp));
        }
        //selectedRecords = new List<ImportObject__c>();
        //selectedRecords.add(records[0]);
        //process();
    }

    public void process() {

        //Campaign List
        List<ImportObject__c> campaignstoCreate = new List<ImportObject__c>();
        Map<String, Campaign> CampaignMap = new Map<String, Campaign>();

        //List of Leads to Convert since Contributions
        Map<Id, Lead> leadstoConvert = new Map<Id, Lead>();

        //public List< List< EnhancedIOProcess> > EIMatches {get;set;}
        for (EnhancedIOProcess processedNewListTemp : matchprocess.EIMatches[5]) {
            system.debug(processedNewListTemp.matchIO);
            for (EnhancedIOProcess.enhancedIOResult eiorTemp : processedNewListTemp.eioResults) {
                if (eiorTemp.bUseThisRecord == TRUE && eiorTemp.MatchReliability == 'Create New Record') {
                    matchprocess.newSoRecordsMap.put(processedNewListTemp.matchIO.Id, eiorTemp.matchedsObject);
                }
            }
        }

        //create new leads and contacts
        matchprocess.createNEWSORecords();

        Map<Id, ImportObject__c> finalStatusUpdates = new Map<Id, ImportObject__c>();

        for (Id moId : matchprocess.newSoRecordsMap.keyset()) {
            ImportObject__c ioTemp = new ImportObject__c(Id = moId, Processed_Date__c = system.today());
            if (matchprocess.newSoRecordsMap.get(moId).Id == NULL) {
                ioTemp.Match_Status__c = 'Error with New Record Creation';
            } else if (matchprocess.newSoRecordsMap.get(moId).getSObjectType().getDescribe().getName() == 'Contact') {
                ioTemp.Match_Status__c = 'New Contact Created';
            } else if (matchprocess.newSoRecordsMap.get(moId).getSObjectType().getDescribe().getName() == 'Lead') {
                ioTemp.Match_Status__c = 'New Lead Created';
            }
            finalStatusUpdates.put(ioTemp.Id, ioTemp);
        }



/*
        EIMatches.add(new List<EnhancedIOProcess>  ()); //Name Match 0
        EIMatches.add(new List<EnhancedIOProcess>  ()); //EmailOnlyMatch Match 1
        EIMatches.add(new List<EnhancedIOProcess>  ()); //Email LN Match Match 2
        EIMatches.add(new List<EnhancedIOProcess>  ()); //Email Full Name Match Match 3
        EIMatches.add(new List<EnhancedIOProcess>  ()); //WatergrassId Match Match 4
        EIMatches.add(new List<EnhancedIOProcess>  ()); //New Records 5
 */
        //Loop through processed lists and setup processing data
            Map<sObject, List<sObject>> matchedRecordsToUpdate = new Map<sObject, List<ImportObject__c>> ();

            for (List<EnhancedIOProcess> processedLists : matchprocess.EIMatches) {
                for (EnhancedIOProcess processedListTemp : processedLists) {
                    //Set Parent matched record
                    List<sObject> tempSOList;
                    for (EnhancedIOProcess.enhancedIOResult eiorTemp : processedListTemp.eioResults) {
                        //if (eiorTemp.bUseThisRecord == TRUE && eiorTemp.matchedsObject.Id != NULL) {
                        if (eiorTemp.bUseThisRecord == TRUE) {
                            processedListTemp.matchedsObject = eiorTemp.matchedsObject;

                            if (matchedRecordsToUpdate.containsKey(processedListTemp.matchedsObject)) {
                                tempSOList = matchedRecordsToUpdate.get(processedListTemp.matchedsObject);
                            } else {
                                tempSOList = new List<sObject>();
                            }
                            tempSOList.add(processedListTemp.matchIO);
                            matchedRecordsToUpdate.put(processedListTemp.matchedsObject, tempSOList);

                        }
                    }
                }
            }

                    //process matched records with data from import records
                    List<sObject> peopleRecordsToupdate =  updateTargetRecord(matchedRecordsToUpdate);

                    /*
                    Next - if there is a donation, or a second person on the record we need to convert a lead
                    so we can add contact to donation/add second contact to same account
                    */

                    for (List<EnhancedIOProcess> processedLists : matchprocess.EIMatches) {
                        for (EnhancedIOProcess processedListTemp : processedLists) {
                            //Set Parent matched record
                            for (EnhancedIOProcess.enhancedIOResult eiorTemp : processedListTemp.eioResults) {

                            if (eiorTemp.bUseThisRecord == TRUE &&
                                    (processedListTemp.bIsDonation == TRUE || String.IsBlank(processedListTemp.matchIO.Person2_LastName__c) == FALSE) &&
                                    processedListTemp.matchedsObject != NULL &&
                                    processedListTemp.matchedsObject.getSObjectType().getDescribe().getName() == 'Lead') {
                                        leadstoConvert.put(eiorTemp.matchedsObject.Id, (Lead) eiorTemp.matchedsObject);
                                    }
                                //Look for Campaigns
                                if (String.IsBlank(processedListTemp.matchIO.Campaign_Name__c) == FALSE) {
                                    campaignstoCreate.add(processedListTemp.matchIO);
                                }
                            }
                        }
                    }

                    convertinbulk = new ConvertLeadToContactBulk();
                    if (leadstoConvert.isEmpty() == FALSE) {
                        convertinbulk.ConvertLeadToContact(leadstoConvert.values());
                        //system.debug(convertinbulk.LeadtoContactMap);
                        //Add to AccountLookupMap
                        for (Id acctId: convertinbulk.AccountToLeadMap.keyset()) {
                            matchprocess.accountContactLookupMap.put(acctId, new Map<String, Contact>() );
                        }
                    }

                    //process matched records with data from import records
                    List<sObject> peopleRecordsToupdate2 = new List<sObject>();
                    for (sObject soTemp: peopleRecordsToupdate) {
                        if (convertinbulk.LeadtoContactMap.containskey(soTemp.Id) == false) {
                            peopleRecordsToupdate2.add(soTemp);
                        }
                    }

                    peopleRecordsToupdate2.sort();
                    database.update (peopleRecordsToupdate2, false);


        //Create Campaigns
        if (campaignstoCreate.IsEmpty() == FALSE) {
            CampaignMap = matchprocess.createCampaigns(campaignstoCreate);
        }

        //Create Second Contacts
        Map<Id, Contact> secondContacts = new Map<Id, Contact>();
        Map<Id, Contact> secondContactsMatched = new Map<Id, Contact>();
        List<Id> matchIds = new List<Id>();
        for (List<EnhancedIOProcess> processedLists : matchprocess.EIMatches) {
            for (EnhancedIOProcess processedListTemp : processedLists) {
                if (String.IsBlank(processedListTemp.matchIO.Person2_LastName__c) == FALSE) {
                    //Get Contact 1 along with Account Id
                    List<Id> ContactDetails = getContactDetails(processedListTemp);
                    Map<String, Contact> contact2Map = matchprocess.accountContactLookupMap.get(ContactDetails[1]);
                    system.debug('contact2Map' + contact2Map);

                            String sCon2Match = processedListTemp.matchIO.Person2_FirstName__c + ':' + processedListTemp.matchIO.Person2_LastName__c;
                    //if not contact with same First and Last Name at Account, create it new
                    Contact cTemp;
                    if (contact2Map.containsKey(sCon2Match) == FALSE ) {
                        cTemp = new Contact();
                        cTemp.FirstName = processedListTemp.matchIO.Person2_FirstName__c;
                        cTemp.lastName = processedListTemp.matchIO.Person2_LastName__c;
                        cTemp.MailingStreet = MatchOrCreatePerson.getStreetValue(processedListTemp.matchIO);
                        cTemp.MailingCity = processedListTemp.matchIO.Address_City__c;
                        cTemp.MailingState = processedListTemp.matchIO.Address_State__c;
                        cTemp.MailingPostalCode = processedListTemp.matchIO.Address_ZipCode__c;
                        cTemp.MailingCountry = processedListTemp.matchIO.Address_Country__c;
                        cTemp.AccountId = ContactDetails[1];
                        secondContacts.put(processedListTemp.matchIO.Id, cTemp);
                        String sCon2Key = cTemp.FirstName + ':' + cTemp.lastName;
                        contact2Map.put(sCon2Key, cTemp);
                        matchprocess.accountContactLookupMap.put(ContactDetails[1],contact2Map);
                        secondContactsMatched.put(processedListTemp.matchIO.Id, cTemp);
                    }
                    else {
                        //if (contact2Map.get(sCon2Match) != NULL) {
                            cTemp = contact2Map.get(sCon2Match);
                            secondContactsMatched.put(processedListTemp.matchIO.Id, cTemp);
                        //}

                    }
                    //secondContacts.put(processedListTemp.matchIO.Id, cTemp);
                    matchIds.add(processedListTemp.matchIO.Id);
                }
            }
        }
        List<WG_Error_Log__c> errors = new List<WG_Error_Log__c>();

        Database.SaveResult [] dsrContact = database.insert (secondContacts.values(), false);

        for (Integer i = 0; i < dsrContact.size(); i++) {
            if (dsrContact[i].isSuccess() == FALSE) {
                Database.SaveResult sr = dsrContact[i];
                // Use index to find unrelated id
                Id ImportId = matchIds[i];
                errors.add(MatchOrCreatePerson.importError (ImportId, sr.getErrors()));
            }
        }
        insert errors;

        //Now add matched to new list for later processing
        system.debug ('secondContactsMatched' + secondContactsMatched);
        secondContacts.putAll(secondContactsMatched);

        // Make sure Unknown Campaign exists just in case
        Campaign defaultCampaign = getDefaultCampaign();
        CampaignMap.put(defaultCampaign.Name, defaultCampaign);

        //Donation Processing
        Map<string, Schema.RecordTypeInfo> OppRTNameMap = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        Map<Id, Opportunity> newOptyMap = new Map<Id, Opportunity>();

        for (List<EnhancedIOProcess> processedLists : matchprocess.EIMatches) {
            for (EnhancedIOProcess processedListTemp : processedLists) {
                system.debug(processedListTemp);
                system.debug(processedListTemp.matchIO);

                if (processedListTemp.bIsDonation == TRUE) {//Donation
                    Id rtid;

                    if (String.isNotBlank(processedListTemp.matchIO.Contribution_RecordType__c) && OppRTNameMap.keyset().CONTAINS(processedListTemp.matchIO.Contribution_RecordType__c)) {
                        rtid = OppRTNameMap.get(processedListTemp.matchIO.Contribution_RecordType__c).getRecordTypeId();

                    } else {
                        // Look in Contribution_Type__c
                        if (String.isNotBlank(processedListTemp.matchIO.Contribution_Type__c)) {
                            for (string s : OppRTNameMap.keyset()) {
                                if (processedListTemp.matchIO.Contribution_Type__c.toLowerCase().CONTAINS(s.toLowerCase())) {
                                    rtid = OppRTNameMap.get(s).getRecordTypeId();
                                    continue;
                                }
                            }
                        } else {
                            // Look for RecordTypeName in Campaign Name
                            if (String.isNotBlank(processedListTemp.matchIO.Campaign_Name__c)) {
                                for (string s : OppRTNameMap.keyset()) {
                                    if (processedListTemp.matchIO.Campaign_Name__c.toLowerCase().CONTAINS(s.toLowerCase())) {
                                        rtid = OppRTNameMap.get(s).getRecordTypeId();
                                        continue;
                                    }
                                }
                            }
                        }
                    }
                    if (rtid == null && OppRTNameMap.keyset().CONTAINS('Donation')) rtid = OppRTNameMap.get('Donation').getRecordTypeId();


                    if (String.isBlank(processedListTemp.matchIO.Contribution_Stage__c)) {
                        if (processedListTemp.matchIO.Contribution_Amount__c != null && processedListTemp.matchIO.Contribution_Amount__c > 0)
                            processedListTemp.matchIO.Contribution_Stage__c = 'Donation Received'; else
                                processedListTemp.matchIO.Contribution_Stage__c = 'Completed';
                    }

                    if (processedListTemp.matchIO.Contribution_TransactionDate__c == null) processedListTemp.matchIO.Contribution_TransactionDate__c = Date.today();
                    system.debug(processedListTemp.matchedsObject);
                    Id ContactId;
                    Id AccountId;

                    if (processedListTemp.matchedsObject != NULL) {
                        List<Id> ContactDetails = getContactDetails(processedListTemp);
                        ContactId = ContactDetails[0];
                        AccountId = ContactDetails[1];

                        Opportunity o = new Opportunity();
                        o.ImportObjectSource__c = processedListTemp.matchIO.Id;
                        o.Name = 'autofill';
                        o.AccountId = AccountId;
                        o.Contact__c = ContactId;

                        if (CampaignMap.containsKey(processedListTemp.matchIO.Campaign_Name__c)) {
                            o.CampaignId = CampaignMap.get(processedListTemp.matchIO.Campaign_Name__c).Id;
                        } else if (CampaignMap.containsKey('Unknown Campaign')) {
                            o.CampaignId = CampaignMap.get('Unknown Campaign').Id;
                        }

                        o.RecordTypeId = rtId;
                        o.Amount = processedListTemp.matchIO.Contribution_Amount__c;
                        o.Hours_Actual__c = processedListTemp.matchIO.Contribution_HoursActual__c;
                        o.StageName = processedListTemp.matchIO.Contribution_Stage__c;
                        o.CloseDate = processedListTemp.matchIO.Contribution_TransactionDate__c;
                        o.Type = processedListTemp.matchIO.Contribution_Type__c;
                        o.Membership_Start_Date__c = processedListTemp.matchIO.Contribution_MmbrStartDate__c;
                        o.Membership_End_Date__c = processedListTemp.matchIO.Contribution_MmbrEndDate__c;
                        o.Description = processedListTemp.matchIO.Contribution_Description__c;
                        o.Anonymous__c = processedListTemp.matchIO.Contribution_Anonymous__c;

                        newOptyMap.put(processedListTemp.matchIO.Id, o);
                    }
                }
            }
        }
        database.insert (newOptyMap.values(), false);

        Map<Id, CampaignMember> cmemberMap = new Map<Id, CampaignMember>();
        Map<Id, CampaignMember> cmemberMap2 = new Map<Id, CampaignMember>();
        for (List<EnhancedIOProcess> processedLists : matchprocess.EIMatches) {
            for (EnhancedIOProcess processedListTemp : processedLists) {
                system.debug(processedListTemp.matchIO);

                for (EnhancedIOProcess.enhancedIOResult eiorTemp : processedListTemp.eioResults) {
                    if (
                            eiorTemp.bUseThisRecord == TRUE &&
                            eiorTemp.matchedsObject != NULL &&
                            String.IsBlank(processedListTemp.matchIO.Campaign_Name__c) == FALSE &&
                            CampaignMap.containskey(processedListTemp.matchIO.Campaign_Name__c)
                       )
                    {
                        CampaignMember cmTemp = new CampaignMember();
                        cmTemp.CampaignId = CampaignMap.get(processedListTemp.matchIO.Campaign_Name__c).Id;
                        if (eiorTemp.matchedsObject.getSObjectType().getDescribe().getName() == 'Lead') {
                            //Check it hasn't been converted due to a contribution
                            if (convertinbulk.LeadtoContactMap.containskey(eiorTemp.matchedsObject.Id)) {
                                cmTemp.ContactId = convertinbulk.LeadtoContactMap.get(eiorTemp.matchedsObject.Id);
                            } else {
                                cmTemp.LeadId = eiorTemp.matchedsObject.Id;
                            }
                        }
                        else if (eiorTemp.matchedsObject.getSObjectType().getDescribe().getName() == 'Contact') {
                            cmTemp.ContactId = eiorTemp.matchedsObject.Id;
                        }
                        cmemberMap.put(processedListTemp.matchIO.Id, cmTemp);

                        //Also convert any second contacts
                        if (secondContacts.containsKey(processedListTemp.matchIO.Id) && secondContacts.get(processedListTemp.matchIO.Id).Id != NULL) {
                            CampaignMember cmTemp2 = new CampaignMember();
                            cmTemp2.CampaignId = CampaignMap.get(processedListTemp.matchIO.Campaign_Name__c).Id;
                            cmTemp2.ContactId = secondContacts.get(processedListTemp.matchIO.Id).Id;
                            cmemberMap2.put(processedListTemp.matchIO.Id, cmTemp2);
                        }
                    }
                }
            }
        }
        database.insert (cmemberMap.values(), false);
        database.insert (cmemberMap2.values(), false);

      /*  List<sObject> peopleRecordsToupdate = new List<sObject>();
        for (List<EnhancedIOProcess> processedLists : matchprocess.EIMatches) {
            for (EnhancedIOProcess processedListTemp : processedLists) {
                if (convertinbulk.LeadtoContactMap.containskey(processedListTemp.matchedsObject.Id) == false) {
                    peopleRecordsToupdate.add(processedListTemp.matchedsObject);
                }
            }

        }
        peopleRecordsToupdate.sort();
        database.update (peopleRecordsToupdate, false);*/



        for (List<EnhancedIOProcess> processedLists : matchprocess.EIMatches) {
            for (EnhancedIOProcess processedListTemp : processedLists) {
                ImportObject__c ioTemp;
                if (finalStatusUpdates.containsKey(processedListTemp.matchIO.Id)) {
                    ioTemp = finalStatusUpdates.get(processedListTemp.matchIO.Id);
                } else {
                    ioTemp = new ImportObject__c(Id = processedListTemp.matchIO.Id, Processed_Date__c = system.today());
                }

                if (processedListTemp.matchedsObject == NULL || processedListTemp.matchedsObject.Id == NULL) {
                    ioTemp.Match_Status__c = 'Error with New Record Creation';
                    ioTemp.Status__c = 'Error with Processing';
                } else {
                    if (processedListTemp.matchedsObject.getSObjectType().getDescribe().getName() == 'Contact') {
                        ioTemp.Match_Status__c = 'Matched to Contact';
                        ioTemp.ContactCalculated__c = processedListTemp.matchedsObject.Id;
                    }
                    //But might be a converted Lead - so look up in Conversion Class
                    else if (processedListTemp.matchedsObject.getSObjectType().getDescribe().getName() == 'Lead') {
                        if (convertinbulk.LeadtoContactMap.containsKey(processedListTemp.matchedsObject.Id)) {
                            ioTemp.Match_Status__c = 'Matched to Converted Lead';
                            ioTemp.ContactCalculated__c = convertinbulk.LeadtoContactMap.get(processedListTemp.matchedsObject.Id);

                        } else {
                            ioTemp.Match_Status__c = 'Matched to Lead';
                            ioTemp.LeadCalculated__c = processedListTemp.matchedsObject.Id;
                        }
                    }
                }

                if (newOptyMap.containsKey(ioTemp.Id)) {
                    if (newOptyMap.get(ioTemp.Id).Id != NULL) {
                        ioTemp.Created_Contribution_Record__c = TRUE;
                    }
                }
                if (cmemberMap.containsKey(ioTemp.Id)) {
                    if (cmemberMap.get(ioTemp.Id).Id != NULL) {
                        ioTemp.Created_Campaign_Member_Record__c = TRUE;
                    }
                }

                if (secondContacts.containsKey(ioTemp.Id)) {
                    if (secondContacts.get(ioTemp.Id).Id != NULL) {
                        ioTemp.Created_Second_Contact__c = true;
                    }
                }


                if (String.IsBlank(ioTemp.Status__c)) ioTemp.Status__c = 'Processed';

                finalStatusUpdates.put(ioTemp.Id, ioTemp);
            }
        }
        update finalStatusUpdates.values();
    }

    public void selectALL() {
        for (ImportWrapper iotemp : iowrappers) {
            iotemp.bSelected = bSelectALL;
        }
    }

    public void cancel() {
    }

    public void save() {
    }

    private Campaign getDefaultCampaign() {
        // Make sure Unknown Campaign exists just in case
        Campaign defCampaign;
        List<Campaign> cas = [SELECT Id, Name FROM Campaign WHERE Name = 'Unknown Campaign'];

        if (cas.size() > 0) {
            defCampaign = cas[0];
        } else {
            Campaign campTemp = new Campaign(Name = 'Unknown Campaign');
            insert campTemp;
            defCampaign = campTemp;
        }
        return defCampaign;
    }

    private List<Id> getContactDetails(EnhancedIOProcess processedListTemp) {
        List<Id> idTemp = new List<Id>();
        system.debug(processedListTemp);
        if (processedListTemp.matchedsObject.getSObjectType().getDescribe().getName() == 'Contact') {
            Contact cDonor = (Contact) processedListTemp.matchedsObject;
            idTemp.add(cDonor.Id);
            idTemp.add(cDonor.AccountId);
        }
        //But might be a converted Lead - so look up in Conversion Class
        else if (processedListTemp.matchedsObject.getSObjectType().getDescribe().getName() == 'Lead') {
            idTemp.add(convertinbulk.LeadtoContactMap.get(processedListTemp.matchedsObject.Id));
            idTemp.add(convertinbulk.LeadtoAccountMap.get(processedListTemp.matchedsObject.Id));
        }

        return idTemp;
    }

    private List<sObject> updateTargetRecord (Map<sObject, List<ImportObject__c>> matchedRecordsToUpdate) {
    List<sObject> recordsToReturn = new List<sObject>();
    for (sObject so: matchedRecordsToUpdate.keyset() ) {

        for (ImportObject__c iotemp : matchedRecordsToUpdate.get(so)) {

            String sStreet = MatchOrCreatePerson.getStreetValue(iotemp);
            if (so.getSObjectType().getDescribe().name == 'Contact') {
                if (
                        String.IsBlank ((String) so.get('MailingStreet')) &&
                                String.IsBlank ((String) so.get('MailingCity')) &&
                                String.IsBlank ((String) so.get('MailingState')) &&
                                String.IsBlank ((String) so.get('MailingPostalCode'))
                        ) {

                    so.put('MailingStreet', sStreet);
                    so.put('MailingCity', iotemp.Address_City__c);
                    so.put('MailingState', iotemp.Address_State__c);
                    so.put('MailingPostalCode', iotemp.Address_ZipCode__c);
                    so.put('MailingCountry', iotemp.Address_Country__c);
                }
                if (String.IsBlank((String) so.get('HomePhone'))) {
                    so.put('HomePhone', iotemp.Person_PhoneHome__c);
                }
                if (String.IsBlank((String) so.get('OtherPhone'))) {
                    so.put('OtherPhone', iotemp.Person_PhoneOther__c);
                }

            } else {

                if (
                        String.IsBlank ((String) so.get('Street')) &&
                                String.IsBlank ((String) so.get('City')) &&
                                String.IsBlank ((String) so.get('State')) &&
                                String.IsBlank ((String) so.get('Country'))
                        ) {

                    so.put('Street', sStreet);
                    so.put('City', iotemp.Address_City__c);
                    so.put('State', iotemp.Address_State__c);
                    so.put('PostalCode', iotemp.Address_ZipCode__c);
                    so.put('Country', iotemp.Address_Country__c);
                }
                if (String.IsBlank ((String) so.get('Home_Phone__c'))) {
                    so.put('Home_Phone__c', iotemp.Person_PhoneHome__c);
                }
            }

            //These are compiund fields so won't work in custom meta data table so we'll hard code them for now
            if (String.IsBlank((String) so.get('FirstName'))) {
                so.put('FirstName', iotemp.Person_FirstName__c);
            }
            if (String.IsBlank((String) so.get('Salutation'))) {
                so.put('Salutation', iotemp.Person_Prefix__c);
            }

            Map<String, Data_Import_Mapping__mdt> dataImportFieldMap = MatchOrCreatePerson.getDataImportMap();

            for (String s : dataImportFieldMap.KeySet()) {
                String sNewValue = (String) iotemp.get (dataImportFieldMap.get(s).IO_FieldName__c);

                //Parse current values if present
                //If current is empty and new is not, just add to existing
                if (String.IsNotBlank(sNewValue)) {
                    if (dataImportFieldMap.get(s).AddToExistingValue__c == true) {
                        if (String.IsBlank((String) so.get(s))) {
                            so.put(s, (String) iotemp.get (dataImportFieldMap.get(s).IO_FieldName__c));
                        }

                        else {
                            String sCurrentValue = (String) so.get(s);
                            List<String> sListofValues = sCurrentValue.split (';');

                            for (String sTemp : sNewValue.split(';')) {
                                if (sListofValues.contains(sTemp) == FALSE) {
                                    sListofValues.add(sTemp);
                                }
                            }
                            system.debug('Values to add' + sListofValues);
                            so.put(s, String.join (sListofValues, ';'));
                        }
                    }

                    else {
                        if (String.IsBlank((String) so.get(s))) {
                            so.put(s, sNewValue);
                        }
                    }
                }
            }
        }
    recordsToReturn.add(so);
    }

return recordsToReturn;
    }

    public class ImportWrapper {
        public ImportObject__c io {
            get;
            set;
        }
        public Boolean bSelected {
            get;
            set;
        }
        public EnhancedIOProcess eio {
            get;
            set;
        }
        public ImportWrapper(ImportObject__c io) {
            this.io = io;
            bSelected = false;
            eio = new EnhancedIOProcess(io);
        }

    }

}