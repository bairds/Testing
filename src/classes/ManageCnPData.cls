// June 18 2015.  Accepts eChecks.  Inserts orderItem.CampaignName as campaign if it exists.  Avoids matching on email=null.  
//      Escapes all apostrophes which exist in the CnP DataXML object.
// 11 June 2015.  Added test for Virtual Terminal, when the email is blank.
// Oct 27, 2014.  Recognizes "Dinner Attendee" and other attendees as well as "Event Attendee"
// Dec 16, 2014.  Manages Installment payments 2 and above, and Installment Payments not linked to valid Pledge.
// Sept 29, 2015.  Remove beforeInsert() and rely on CnP routines to remove middle 8 characters from credit card #.
// Version of 20 Nov 2015.  Baird and Peter add .tolowercase() to avoid campaigns being missed because of capitalization errors in the Virtual Terminal.
// 15 DEC 2015.  SECTION ADDED TO test DataXML FROM THE CONNECT APPLICATION.
// 14 Aug 2016 ConvertLead() to handle conversion of leads while inserting Dear__c and Attendee__c
// 1 Sept 2016 Amended to accepted SKU's with the the RecordType anywhere in the SKU.
// 15 Nov 2016 For CnP Connect search for Salesforce CampaignId in the DataXML.  Also revise code to fit Gravity Forms.
// Still needs to handle campaigns and subcampaigns for Peer to Peer.
// 6 Dec 2016 Catch error caused by GravityForms recurring payments (DataXML doesn't include next payment date).  Line 316
// 7 Dec Refactor campaign search and insertion.  Remove all the .tolowercase() because it causes errors.
// 11 Apr 2017 Set opp.CloseDate = TransactionDate rather than system.today(), so that Carl can push old contributions through.
// 11 Apr 2017 Add final safety catch to make sure that opp has an existing campaign.  Retest with problematic DataXML from Diverse&Resilient, success.
// August 2017 Refactor; add programming for monthly memberships.  Deploy beginning Jan 2018.
// March 2018 Correct error caused by a new pledge with multiple order items, which used to create multiple pledges
// May 2019 Correct periodicity values for recurring memberships, add in 'Yearly' which is what CnP now uses
// June 2019 Allow either "Yearly" or "Annually" - because picklist is now exact, switch "Annually" to "Yearly" to avoid error on insert.
//  June 2019 Refactor to catch errors without preventing CnP from inserting record.  Errors end up in the WG_Error_Log

public with sharing class ManageCnPData {
    public list<Opportunity> newOpps;
    public List<CnP_PaaS_Bridge__CnPData__c> NewData;
    public List<string> DataXMLs = new list<string>();
    public ID WGCampaignId;
    public Boolean foundTransactionCamp = false;
    public String sCampaignName;
    public Id sOptyCampaignId;
    public string sOptyCampaignName;
    public Map<String, Id> CampaignMap;
    public map<string, Id> OppRTMap = new map<string, Id>();
    public map <string, string> parseResults;
    public date Transdate;
    public CnP_PaaS_Bridge__CnPData__c d;
    public Id sID;
    public contact scontact;
    public Opportunity newPledgeOrRecurring;
    public Opportunity OrphanagePledge;
    public static Boolean AlreadyRunning;

    public ManageCnPData() {
        newOpps = new List<Opportunity>();
    }


    // AfterInsert
    public void afterInsert(CnP_PaaS_Bridge__CnPData__c [] NewData, CnP_PaaS_Bridge__CnPData__c [] oldData) {
        AlreadyRunning = true;
        for (CnP_PaaS_Bridge__CnPData__c d : newData) {
            try {
                afterInsertMethod(d);
            } catch (Exception ex) {
                WG_Error_Log__c EL = new WG_Error_Log__c(
                        C_P_Data__c = d.id,
                        Description__c = 'Message is: ' + ex.getMessage() + '.  Exception of type ' + ex.getTypeName() + ' occurred at line ' + ex.getLineNumber() + ' because of ' + ex.getCause() + ' and stack trace is ' + ex.getStackTraceString(),
                        Category__c = 'Occurred in afterInsert');
                insert EL;
                system.debug('Error on saving newOpps ' + EL);
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new String[] { 'baird@watergrass.org', 'support@watergrass.org' };
                message.subject = 'ManageCnPData Error';
                Organization org = [select name, Id from Organization];
                string msg = org.Name + ' (' + org.Id + ') had a CnP error.';
                        msg += '  Message was ' + ex.getMessage();
                        msg += '  Type was ' + ex.getTypeName();
                        msg += ' Occurred at line ' + ex.getLineNumber();
                        msg += ' because of ' + ex.getCause();
                        message.plainTextBody = msg;
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                if (results[0].success) {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                }
            }
        }
        AlreadyRunning = false;
    }

    public void afterInsertMethod(CnP_PaaS_Bridge__CnPData__c d) {
        // IF TRANSACTION NOT AUTHORIZED END METHOD
        // map <string, string> parseResults;
        parseResults = parseCnPDataXML.parseXML(d.CnP_PaaS_Bridge__DataXML__c);
        // If not an authorized transaction or "credit" or customtransactiontype or a free transaction don't continue
        system.debug('parseResults.get(transactionresult) is ' + parseResults.get('transactionresult'));
        system.debug('parseResults.get(PaymentType) is ' + parseResults.get('PaymentType'));
        system.debug('parseResults.get(TotalCharge) is ' + parseResults.get('TotalCharge'));
        // + ' and parseResults.get(PaymentType) is ' + parseResults.get('PaymentType') + ' and parseResults.get(TotalCharge) is ' + decimal.valueOf(parseResults.get('TotalCharge')));
        if (parseResults.containsKey('transactionresult') && (parseResults.get('transactionresult') == 'Authorized' || parseResults.get('transactionresult') == 'Credit' || parseResults.get('paymenttype') == 'CustomPaymentType' || decimal.valueOf(parseResults.get('totalcharge')) == 0)) {
            list<account> acctsToDelete = new list<account>();
            datetime datenow = system.now();
            date todaydate = system.today();
            id insertCampaignID;
            string CampaignName;

            // create a map of opportunity record types and ids;
            Schema.DescribeSObjectResult R = Opportunity.SObjectType.getDescribe();
            List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
            system.debug('List of Schema.RecordTypeInfo is ' + RT);
            For (Schema.RecordTypeInfo rti : RT) {
                OppRTMap.put(rti.getName(), rti.getRecordTypeId());
            }

            // identify each contact or lead
            Contact pcontact = new Contact(
                    firstname = parseResults.get('firstname'),
                    lastname = parseResults.get('lastname'),
                    email = parseResults.get('email'),
                    MailingStreet = parseResults.get('street1') + (STRING.ISNOTEMPTY(parseResults.get('street2')) ? ' ' + parseResults.get('street2') : ''),
                    MailingCity = parseResults.get('city'),
                    MailingState = parseResults.get('state'),
                    MailingPostalCode = parseResults.get('zip'));

            system.debug('Does MTC insert lastname into pcontact?  Lastname is ' + pcontact.lastname);
            String[] sresults = identifyorcreatePerson.IdentifyOrCreatePerson(pcontact);
            sID = sresults[0];
            string stype = sresults[1];
            system.debug('After identifyOrCreatePerson, STYPE IS ' + stype);
            if (stype == 'Lead') {
                //Convert lead and adjust AccountName, Addressee, Dear
                lead checkLead = [select id, company, firstname, lastname from Lead where id = :sID];
                List<Id> Results = convertLeadtoContact.convertLeadToContact(checkLead.Id);
                sID = Results[0];
                stype = 'Contact';
            } // end conversion of lead
            //Update contact with all available info from data record;
            scontact = [
                    select id,mailingstreet,phone,mailingcity,mailingstate, mailingPostalCode,
                            firstname,lastname,email,accountid
                    from Contact
                    where id = :sid
            ];
            if (pcontact.MailingStreet != null) scontact.mailingstreet = pcontact.MailingStreet;
            if (parseResults.get('phone') != null) scontact.phone = parseResults.get('phone');
            if (parseResults.get('city') != null) scontact.mailingcity = parseResults.get('city');
            if (parseResults.get('state') != null) scontact.MailingState = parseResults.get('state');
            if (pcontact.MailingPostalCode != null) scontact.MailingPostalCode = pcontact.mailingPostalCode;
            system.debug('After establishing contact, leadsource is ' + parseresults.get('leadsource'));
            if (parseresults.get('leadsource') != null) scontact.LeadSource = parseresults.get('leadsource');
            update scontact;
            System.debug('scontact is now ' + scontact);

            // Create the map of all campaigns mentioned in the DataXML
            CampaignMap = CreateCampaignMap(parseResults);

            //Loop through OrderItems again to create Opportunities
            if (STRING.ISNOTEMPTY(parseResults.get('orderitems'))) for (Integer i = 0; i < Integer.valueOf(parseResults.get('orderitems')); i++) {
                system.debug('parseResults SKUi is ' + parseResults.get('sku' + i));
                // Assign correct campaign Name
                system.debug('Before calling AssignCampaignId(), campaignname+i is ' + parseResults.get('campaignname' + i) + ' and WGCampaignId is ' + parseResults.get('WGCampaignId') + ' and CampaignName is ' + parseResults.get('CampaignName') + ' and campaign is ' + parseResults.get('campaign'));
                SOptyCampaignId = AssignCampaignId(parseResults.get('campaignname' + i), parseResults.get('WGCampaignId'), parseResults.get('CampaignName'), parseResults.get('campaign'));

                //Calculate amount, apportioning the processing fee across different items
                Decimal Amt = (decimal.valueof(parseResults.get('unitpricedue' + i) != null ? parseResults.get('unitpricedue' + i) : '0')
                        - Decimal.valueOf(parseResults.get('taxamountdue' + i) != null ? parseResults.get('taxamountdue' + i) : '0') -
                        Decimal.valueOf(parseResults.get('discountdue' + i) != null ? parseResults.get('discountdue' + i) : '0'))
                        * Decimal.valueOf(parseResults.get('quantity' + i) != null ? parseResults.get('quantity' + i) : '1');
                // apportion processing fee across items, if it is not 0
                Decimal Proc_Fee = 0;
                if (decimal.valueOf(parseResults.get('totalcharge')) != 0)
                    Proc_Fee = Amt * Decimal.valueOf(parseResults.get('chargamount')) / decimal.valueOf(parseResults.get('totalcharge'));

                System.debug(' and amount is ' + Amt);
                // Does custom setting map contain the SKU?  Then retrieve string Recordtype.name = customsettingmap.get('SKU').recordTypeName;
                // Does OppRTMap.contain(Recordtype.name)?  If yes, RecordTypeID = OppRTMap(get ...
                // Otherwise use 'Donation'
                System.debug('XXX at this point parseResults.get(itemname) is ' + parseResults.get('itemname' + i));
                System.debug('SOpptyCampaignId is ' + sOptyCampaignId);
                string EventName = parseResults.get('itemname' + i) + ' for ' + sOptyCampaignName + ' paid on ' + String.valueOf(System.today());
                system.debug('sOptyCampaignId is ' + sOptyCampaignId + ' and EventName is ' + EventName);
                string target = '-';
                string replacement = ',';
                string TransDateString = parseResults.get('transactiondate').left(10).replaceAll(target, replacement);
                Transdate = date.newinstance(integer.valueOf((TransDateString).left(4)), integer.valueOf(TransDateString.substring(5, 7)), integer.valueOf(TransDateString.substring(8, 10)));
                system.debug('Transactiondate is ' + Transdate);
                system.debug('SKU+i is parsed as ' + parseResults.get('sku' + i));
                Opportunity Opp = new Opportunity(
                        Name = (parseResults.get('itemname' + i).contains('Attendee')) ? EventName : 'autofill',
                        Attendee__c = (parseResults.get('itemname' + i).contains('Attendee')) ? parseResults.get('itemname' + i).substring(15, parseResults.get('itemname' + i).length()) : null,
                        CloseDate = TransDate,
                        stageName = 'Payment Received',
                        CampaignID = SOptyCampaignId,
                        C_P_Data__c = d.id,
                        Accountid = [select id, accountid from contact where id = :sid][0].accountid,
                        Contact__c = sID,
                        RecordTypeID = parseResults.get('sku' + i) == null ? OppRTMap.get('Donation') : AssignOppRTId(parseResults.get('sku' + i)),
                        Payment_Type__c = parseResults.get('paymenttype') + ' through C&P',
                        Amount = Amt,
                        Processing_Fee__c = Proc_Fee.setScale(2),
                        CustomQuestion1__c = STRING.ISNOTBLANK(parseResults.get('customquestion1')) ? parseResults.get('customquestion1').left(255) : null,
                        CustomAnswer1__c = STRING.ISNOTBLANK(parseResults.get('customanswer1')) ? parseResults.get('customanswer1').left(255) : null,
                        CustomQuestion2__c = STRING.ISNOTBLANK(parseResults.get('customquestion2')) ? parseResults.get('customquestion2').left(255) : null,
                        CustomAnswer2__c = STRING.ISNOTBLANK(parseResults.get('customanswer2')) ? parseResults.get('customanswer2').left(255) : null,
                        CustomQuestion3__c = STRING.ISNOTBLANK(parseResults.get('customquestion3')) ? parseResults.get('customquestion3').left(255) : null,
                        CustomAnswer3__c = STRING.ISNOTBLANK(parseResults.get('customanswer3')) ? parseResults.get('customanswer3').left(255) : null,
                        CustomQuestion4__c = STRING.ISNOTBLANK(parseResults.get('customquestion4')) ? parseResults.get('customquestion4').left(255) : null,
                        CustomAnswer4__c = STRING.ISNOTBLANK(parseResults.get('customanswer4')) ? parseResults.get('customanswer4').left(255) : null,
                        CustomQuestion5__c = STRING.ISNOTBLANK(parseResults.get('customquestion5')) ? parseResults.get('customquestion5').left(255) : null,
                        CustomAnswer5__c = STRING.ISNOTBLANK(parseResults.get('customanswer5')) ? parseResults.get('customanswer5').left(255) : null,
                        CustomQuestion6__c = STRING.ISNOTBLANK(parseResults.get('customquestion6')) ? parseResults.get('customquestion6').left(255) : null,
                        CustomAnswer6__c = STRING.ISNOTBLANK(parseResults.get('customanswer6')) ? parseResults.get('customanswer6').left(255) : null,
                        C_P_Custom_Payment_Name__c = STRING.ISNOTBLANK(parseResults.get('custompaymentname')) ? parseResults.get('custompaymentname').left(100) : null
                );
                system.debug('C_P_Custom_Payment_Name is ' + Opp.C_P_Custom_Payment_Name__c);
                system.debug('Opp.name is ' + Opp.Name);

                //Check for recurring membership payment
                if (opp.RecordTypeId == OppRTMap.get('Membership')) {
                    if (parseResults.get('periodicity') != null) {
                        opp.Membership_Start_Date__c = TransDate;
                        if (parseResults.get('periodicity') == 'Weekly') opp.Membership_End_Date__c = TransDate.adddays(7);
                        if (parseResults.get('periodicity') == 'Every 2 Weeks') opp.Membership_End_Date__c = TransDate.adddays(14);
                        if (parseResults.get('periodicity') == 'Monthly') opp.Membership_End_Date__c = TransDate.addmonths(1);
                        if (parseResults.get('periodicity') == 'Every 2 Months') opp.Membership_End_Date__c = TransDate.addmonths(1);
                        if (parseResults.get('periodicity') == 'Quarterly') opp.Membership_End_Date__c = TransDate.addmonths(3);
                        if (parseResults.get('periodicity') == 'Every 6 Months') opp.Membership_End_Date__c = TransDate.addmonths(6);
                        if (parseResults.get('periodicity') == 'Annually' || parseResults.get('periodicity') == 'Yearly') opp.Membership_End_Date__c = TransDate.addmonths(12);
                    }
                }


                //Check for Pledge payment.  If this is a pledge payment, there may still be multiple order items.
                if (parseResults.get('recurringid') != null) {
                    // If this is the first orderitem
                    if (i == 0) {
                        // If this is the first payment, create the pledge record
                        if (parseResults.get('installmentnumber') == '1') {
                            Opportunity MasterPledgeOrRecurringOpp = createPledgeOrRecurring(parseResults, d.id);
                            opp.Matches_Which_Challenge_or_Pledge__c = MasterPledgeOrRecurringOpp.Id;
                        } else // If not the first payment, find the master pledge or recurring payment and link this
                        {
                            List<Opportunity> ListPledge = [select id, Total_Paid_CnP__c, Next_Installment_Date__c from Opportunity where CnPMasterTransactionNumber__c = :parseResults.get('mastertransactionnumber')];
                            if (ListPledge.size() == 0) {
                                opp.Matches_Which_Challenge_or_Pledge__c = assignToOrphanage();
                            } else {
                                opp.Matches_Which_Challenge_or_Pledge__c = ListPledge[0].id;
                            }
                        }
                        opp.Total_Paid_CnP__c = Decimal.valueOf(parseResults.get('totalmade'));
                        opp.Installment_Nr__c = Decimal.valueOf(parseResults.get('installmentnumber'));
                        // And update the Total_Paid_CnP field in the pledge
                        If (opp.Installment_Nr__c > 1) {
                            Opportunity Pledge = [select id, Total_Paid_CnP__c, Next_Installment_Date__c from Opportunity where id = :opp.Matches_Which_Challenge_or_Pledge__c];
                            Pledge.Total_Paid_CnP__c = Decimal.valueOf(parseResults.get('totalmade'));
                            if (STRING.ISNOTBLANK(parseResults.get('nextinstallmentdate'))) Pledge.Next_Installment_Date__c = Date.valueOf(parseResults.get('nextinstallmentdate'));
                            Update Pledge;
                        }
                    } // End check for orderitem[0]
                } // End Check for Pledge Payment

                DataXMLs.add(d.CnP_PaaS_Bridge__DataXML__c);
                // Ensure that campaign exists
                if (opp.campaignId == null) {
                    if (CampaignMap.get('Generic CnP Campaign') != null) {
                        opp.campaignId = CampaignMap.get('Generic CnP Campaign');
                    } else {
                        Campaign GenericCampaign = new Campaign(
                                name = 'Generic CnP Campaign',
                                recordTypeId = [select id from recordtype where name = 'Fundraising Activity'].id);
                        insert GenericCampaign;
                        opp.campaignId = GenericCampaign.Id;
                    }
                }
                newOpps.add(opp);
                system.debug('At bottom of loop, newOpps is ' + newOpps);
            } // end if orderItems is not empty
            // end of catch
        } // end of loop if TransactionResult is Authorized
        SaveOppList(newOpps, DataXMLs);
    } // end of method


    public void SaveOppList(List<Opportunity> newOpps, List<string> DataXMLs) {
        List<Database.SaveResult> SRList = database.insert(newOpps, false);
        /*        List<DateBase.SaveResult, List<Opportunity>, DataXMLs> errorlist = new List<DateBase.SaveResult, List<Opportunity>, DataXML>();
For (Database.SaveREsult DSR : SRList) {
if (DSR == false) errorlist.add(DSR,opportunity,DataXML);
}
if (ErrorList != null) {
LogError LE = new LogError();
LE.LogOppInsertError(errorList);
}*/
    }

    public Id assignToOrphanage() {
        Campaign OrphanCampaign;
        system.debug('Beginning assignToOrphanage');
        // If there's no matching Master Pledge
        //[select id from RecordType where name ='Family' limit 1].id);

        List<Opportunity> ListForOrphanage = [select id from Opportunity where name = 'Orphanage for Lost Payments'];
        if (ListForOrphanage.size() != 0) {
            return ListForOrphanage[0].Id;
        } else {
            Schema.DescribeSObjectResult d = Schema.SObjectType.Account;
            Map<String, Schema.RecordTypeInfo> rtAccountMapByName = d.getRecordTypeInfosByName();

            d = Schema.SObjectType.Opportunity;
            Map<String, Schema.RecordTypeInfo> rtOptyMapByName = d.getRecordTypeInfosByName();

            Account OrphanageAccount = new Account (name = 'OrphanageAccount', recordTypeID = rtAccountMapByName.get('Family').getRecordTypeId());
            insert OrphanageAccount;
            Contact Overseer = new Contact(lastname = 'OrphanOverseer', accountid = OrphanageAccount.id);
            insert Overseer;
            List<Campaign> OrphanageCampaigns = [select id from Campaign where name = 'Lost Payments'];
            if (OrphanageCampaigns.size() == 0) {
                OrphanCampaign = new Campaign(name = 'Lost Payments');
                insert OrphanCampaign;
            } else {
                OrphanCampaign = OrphanageCampaigns[0];
            }
            OrphanagePledge = new Opportunity(
                    Name = 'Orphanage for Lost Payments',
                    AccountId = OrphanageAccount.id,
                    Contact__c = Overseer.Id,
                    CampaignId = OrphanCampaign.Id,
                    closeDate = system.today(),
                    number_of_payments__c = 99,
                    //recordTypeId = [select Id from RecordType where Name = 'Pledge' limit 1].id,
                    recordTypeId = rtOptyMapByName.get('Pledge').getRecordTypeId(),
                    StageName = 'Closed Won');
            system.debug('About to insert OrphanagePledge ' + OrphanagePledge);
            Insert OrphanagePledge;
            return OrphanagePledge.Id;
        }
    } // End of AssignToOrphanage()

    //createCampaignMap
    // Jan 2016.  Campaign can now be in 3 places in the DataXML: campaignName the campaign list (new with Connect, which allows multiple campaigns, each of
    // which is a ndoe.); the campaign field, which is for the whole transaction (original CnP easy pages); the campaignName field, which is part of the
    // orderItem, and is used in virtual terminal and any other transaction for multiple items.
    // Thus we have to parse for each.  To the new opportunity we assign: 1) the campaignName from the OrderItem node, if it exists; otherwise 2) the
    // campaignName from the CampaignList node, if it exists; 3) the campaign from the transactiondetail node, if it exists; 4) "Generic CnP Campaign,"
    // which we create if it doesn't exist.
    // Nov 15 2016 And also in ExternalCampaignId, which can be for whole donation or individual orderitems.
    // Dec 7 2016 Refactor.  Search first for OrderItemCampaign, then for TransactionCampaign, then for Generic CnP Campaign.
    public Map<string, Id> createCampaignMap(Map<string, string> parseResults) {
        CampaignMap = new Map<string, id>();
        // Search OrderItems for Campaign
        if (STRING.ISNOTEMPTY(parseResults.get('orderitems')))
            for (Integer i = 0; i < Integer.valueOf(parseResults.get('orderitems')); i++) {
                system.debug('campaignname' + i + ' is ' + parseResults.get('campaignname' + i));
                system.debug('parseResults.containskey(campaignname + i) evaluated to ' + parseResults.containskey('campaignname' + i));
                system.debug('STRING.ISNOTEMPTY(parseResults.get(campaigname + i)) evaluated to ' + string.isnotempty(parseResults.get('campaigname' + i)));
                system.debug('(parseResults.containskey(campaignname + i) && parseResults.get(campaignname + i) != NULL) evaluates to ' + (parseResults.containskey('campaignname' + i) && parseResults.get('campaignname' + i) != null));

                if (parseResults.containskey('campaignname' + i) && parseResults.get('campaignname' + i) != null) {
                    sCampaignName = parseResults.get('campaignname' + i);
                    CampaignMap.put(sCampaignName, NULL);
                    system.debug('Order item campaign is ' + parseResults.get('campaignname' + i));
                }
                // Also add Generic CnP Campaign
                CampaignMap.put('Generic CnP Campaign', null);
            } //End of search of Order Items
        // Search Transaction for Campaign

        if (  parseResults.containsKey('CampaignName') && parseResults.get('CampaignName')!=null) {
            CampaignMap.put(parseResults.get('CampaignName'), null);
        } else {
            if (parseResults.containsKey('campaign') && parseResults.get('campaign') != null) {
                CampaignMap.put(parseResults.get('campaign'), null);
                system.debug('CampaignMap after campaign insert is ' + CampaignMap);
            }
        }
        // Insert CampaignIds in map
        // If multiple campaigns have the same name, this will choose the Id of the last of the campaigns.
        system.debug('campaignMap.keyset is ' + CampaignMap.Keyset());
        system.debug('in this test the campaigns available are ' + [select id, name from campaign LIMIT 10]);
        List<Campaign> cChecks = [select id, name from Campaign where name IN :CampaignMap.keyset()];
        for (Campaign cCheck : cChecks) {
            CampaignMap.put(cCheck.Name, cCheck.Id);
            system.debug('CampaignMap is ' + CampaignMap);
            // return CampaignMap;
        }

        system.debug('CampaignMap is ' + CampaignMap);
        // Make sure we at least have a TransactionCampaign or a Generic CnP Campaign
        // Only run the following code if CampaignName is blank and Campaign is blank
        if ((!parseResults.containsKey('CampaignName') || STRING.ISBLANK(parseResults.get('CampaignName')))
                && (!parseResults.containsKey('Campaign') || STRING.ISBLANK(parseResults.get('Campaign')))) {
            List<Campaign> GenericCnPCampaigns = [SELECT id, name from Campaign where name = 'Generic CnP Campaign'];
            if (GenericCnPCampaigns.size() > 0) {
                Campaign TempCamp = GenericCnPCampaigns[0];
                CampaignMap.put(TempCamp.name, TempCamp.Id);
            } else {
                // Create Generic CnP campaign and insert it into CampaignMap
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'No campaign in WaterGrass matches the campaign name set in Click and Pledge.  This donation will be attributed to the Generic CnP Campaigns campaign.');
                campaign GenericCnPCampaign = new campaign(
                        name = 'Generic CnP Campaign',
                        isActive = true,
                        // BAIRD REMOVE THIS QUERY REPLACE WITH MAPLOOKUP
                        recordType = [select id from recordtype where name = 'Fundraising Activity']);// OppRTMap.get('Fundraising Activity').getRecordTypeId()
                insert GenericCnPCampaign;
                CampaignMap.put('Generic CnP Campaign', GenericCnPCampaign.Id);
                system.debug('Created new campaign Generic CnP Campaign with Id ' + GenericCnPCampaign.Id);
            }
        } // end search for TransactionCampaign
        return CampaignMap;
    }

    public Id AssignCampaignId(String OrderCampaignName, String WGCampaignId, String CampaignName, String LegacyCampaignName) {
        //is there a campaign supplied in item list?
        if (STRING.ISNOTBLANK(OrderCampaignName)) {
            sOptyCampaignId = CampaignMap.get(OrderCampaignName);
            sOptyCampaignName = OrderCampaignName;
            system.debug('After checking for OrderCampaignId SOptyCampaignId is' + SOptyCampaignId + ' for CampaignId for new opportunity.');
        } else {
            system.debug('WGCampaignId is ' + WGCampaignId);
            if (string.ISNOTEMPTY(WGCampaignId)) {
                sOptyCampaignId = WGCampaignId;
                system.debug('After checking WGCampaignId SOptyCampaignId is' + SOptyCampaignId + ' for CampaignId for new opportunity.');
            } else {
                if (CampaignName != NULL) {
                    if (CampaignMap.containskey(CampaignName)) {
                        sOptyCampaignId = CampaignMap.get(CampaignName);
                        sOptyCampaignName = CampaignName;
                        system.debug('After checking CampaignName SOptyCampaignId is' + SOptyCampaignId + ' for CampaignId for new opportunity.');
                    }
                } else {
                    if (!STRING.ISBLANK(LegacyCampaignName)) {
                        if (CampaignMap.containskey(LegacyCampaignName)) {
                            SOptyCampaignId = CampaignMap.get(LegacyCampaignName);
                            SOptyCampaignName = LegacyCampaignName;
                            system.debug('After checking LegacyCampaign SOptyCampaignId is' + SOptyCampaignId + ' for CampaignId for new opportunity.');
                        }
                    } else {
                        SOptyCampaignId = CampaignMap.get('Generic CnP Campaign');
                        SOptyCampaignName = 'Generic CnP Campaign';
                        system.debug('After checking generic cnp campaign SOptyCampaignId is' + SOptyCampaignId + ' for CampaignId for new opportunity.');
                    }
                }
            }
        }
        system.debug('Chose ' + SOptyCampaignId + ' for CampaignId for new opportunity.');
        return SOptyCampaignId;
    }

    public Id AssignOppRTId(string SKUstring) {
        Id RTID = OppRTMap.get('Donation');
        if (SKUstring != null) {
            if (OppRTMap.containsKey(SKUstring)) {
                RTID = OppRTMap.get(SKUstring);
            } else {
                for (string RTName : OppRTMap.KeySet()) {
                    // 1 Sept 2016 created this line to search for RecordTypeNames in SKU if they were prepended with "RT_".  It does not work for PrairieRivesr so reverted to the following line, which is less foolproof.
                    // if (OppRTMap.containsKey(SKUstring.substringAfterLast('RT_'))) RTID = OppRTMap.get(SKUstring.substringAfterLast('RT_')).getRecordTypeId();
                    if (SKUString.TOUPPERCASE().CONTAINS(RTName.TOUPPERCASE())) RTID = OppRTMap.get(RTName);
                }
            }
            if (RTID == null) RTID = OppRTMap.get('Donation');
        }
        System.debug(' and RecordtypeID is ' + RTID);
        return RTID;
    }

    //Here we create the "Master" Pledge or Recurring Record against which all the payments roll up.  It has no amount in it.
    public Opportunity createPledgeOrRecurring(map<string, string> parseResults, string CnPDataXMLID) {
        system.debug('Before createPledgeOrRecurring sOptyCampaignId is ' + sOptyCampaignId);
        newPledgeOrRecurring = new Opportunity(
                Pledge_Amount__c = parseResults.get('installments') == '999' ? 0.00 : decimal.valueOf(parseResults.get('totalcommitted')),
                CnPMasterTransactionNumber__c = parseResults.get('mastertransactionnumber'),
                RecurringMethod__c = parseResults.get('recurringmethod'),
                Periodicity__c = parseResults.get('periodicity'),
                closedate = Transdate,
                name = parseResults.get('installments') == '999' ? 'Recurring Payment begun on ' + date.today().format() : 'autofill',
                stageName = 'Pledge Recorded',
                CampaignID = SOptyCampaignId,
                C_P_Data__c = CnPDataXMLID,
                Accountid = [select id, accountid from contact where id = :sid][0].accountid,
                Contact__c = sID,
                RecordTypeId = OppRTMap.get('Pledge'),
                Payment_Type__c = 'Click and Pledge',
                Installment_Amount__c = decimal.valueOf(parseResults.get('totalmade')),
                Next_Installment_Date__c = date.valueOf(parseResults.get('nextinstallmentdate')),
                Total_Paid_CnP__c = decimal.valueOf(parseResults.get('totalmade')),
                Total_Paid__c = decimal.valueOf(parseResults.get('installmentamount')),
                Number_of_Payments__c = Decimal.valueOf(parseResults.get('installments')));
        system.debug('Creating pledge ' + newPledgeOrRecurring);
        // Ensure that campaign exists
        if (newPledgeOrRecurring.campaignId == null) {
            if (CampaignMap.get('Generic CnP Campaign') != null) {
                newPledgeOrRecurring.campaignId = CampaignMap.get('Generic CnP Campaign');
            } else {
                Campaign GenericCampaign = new Campaign(
                        name = 'Generic CnP Campaign',
                        recordTypeId = [select id from recordtype where name = 'Fundraising Activity'].id);
                insert GenericCampaign;
                newPledgeOrRecurring.campaignId = GenericCampaign.Id;
            }
        }
        // Insert newPledgeOrRecurring now in order to use its ID in the pledge payment, which is inserted next;
        insert newPledgeOrRecurring;
        return newPledgeOrRecurring;
    }

} // End of File