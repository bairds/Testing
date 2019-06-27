// 18 June 2015. Accepts eChecks.  Inserts orderItem.CampaignName as campaign if it exists.  Avoids matching on email=null.  
//      Escapes all apostrophes which exist in the CnP DataXML object.
// 11 June 2015.  Added test for Virtual Terminal, when the email is blank.
// Version of 27 Oct 2014, Baird.  Added test for "Dinner Attendee" as well as "Event Attendee"
// Version of 29 Sept 2015, Baird.  Changed test for stripping data to check for the CnP data stripping rather than
// the WAterGrass version.  Removed the WaterGrass beforeInsert() trigger.  CnP now strips the middle 8 digits of a credit card number.
// Version of 20 Nov 2015.  Baird and Peter add .tolowercase() to avoid campaigns being missed because of capitalization errors in the Virtual Terminal.
// // 15 DEC 2015.  SECTION ADDED TO test DataXML FROM THE CONNECT APPLICATION.
// 14 Aug 2016 ConvertLead() to handle conversion of leads while inserting Dear__c and Attendee__c
// 1 Sept 2016 Amended to accepted SKU's with the the RecordType anywhere in the SKU.
// 15 Nov added code to catch Connect CampaignIds, to identify recurring donations, added GravityForms code
// 26 June 2019 Added secure catch
@isTest
private class ManageCnPDataSingleTest {

    @isTest
    static void SingleRecurringBadPeriodicityError() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestMemberCamp = ctv.fetchTestcampaign();
        TestMemberCamp.name = 'Test Membership Campaign';
        update testMemberCamp;

        string XMLstring ='<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Tester</BillingFirstName><BillingMI></BillingMI>';
        XMLstring += '<BillingLastName>TestContact</BillingLastName><BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
        XMLstring += '<BillingPhone>333</BillingPhone></BillingInformation><BillingAddress><BillingAddress1>lkj;</BillingAddress1>';
        XMLstring += '<BillingAddress2></BillingAddress2><BillingAddress3></BillingAddress3><BillingCity>;lkj</BillingCity>';
        XMLstring += '<BillingStateProvince>Alabama</BillingStateProvince><BillingPostalCode>33333</BillingPostalCode>';
        XMLstring += '<BillingCountryName>United States of America</BillingCountryName></BillingAddress></Patron><TransactionDetail>';
        XMLstring += '<OrderNumber>1207131327206181111</OrderNumber><Tracker>TestTracker</Tracker><Campaign>Test Membership Campaign</Campaign>';
        XMLstring += '<WindowName>Wild and Scenic Film Fest</WindowName><WindowId>55337</WindowId><TotalCharge>1.00</TotalCharge><ChargAmount>0.70</ChargAmount><TransactionDate>2012-07-13 13:27:00</TransactionDate><TransactionTimeZone>2012-07-13 13:27:00</TransactionTimeZone><TransactionResult>Authorized</TransactionResult><UrlReferrer>http://leadgreen.org/wordpress/</UrlReferrer><PaymentMethod><PaymentType>Credit Card</PaymentType><CreditCard>';
        XMlstring += '<NameOnCard>Test16 Tester</NameOnCard><CardNumber>41111111</CardNumber><CardName>VISA</CardName>';
        XMlstring += '<ExpirationDate>1208</ExpirationDate></CreditCard></PaymentMethod></TransactionDetail>';
        XMlstring += '<Recurring><TransactionResult>Authorized</TransactionResult><RecurringID>47212</RecurringID>';
        XMlstring += '<MasterTransactionNumber>1307101607584781111</MasterTransactionNumber><Installments>3</Installments>';
        XMlstring += '<RecurringMethod>Subscription</RecurringMethod><Periodicity>Daily</Periodicity>';
        XMlstring += '<InstallmentNumber>1</InstallmentNumber><NextInstallmentDate>2013-08-10 16:08:00</NextInstallmentDate>';
        XMlstring += '<InstallmentAmount>1.00</InstallmentAmount><TotalAmount>1.00</TotalAmount><TotalCommitted>3.00</TotalCommitted>';
        XMlstring += '<TotalMade>1.00</TotalMade><TotalDue>2.00</TotalDue></Recurring>';
        XMLstring += '<OrderItemList>';
        XMLstring += '<OrderItem>';
        XMLstring += '<ItemID>1</ItemID>';
        XMLstring += '<ItemName>Event Attendee-Baird straughan</ItemName>';
        XMLstring += '<Quantity>1</Quantity>';
        XMLstring += '<UnitPriceCharge>1</UnitPriceCharge>';
        XMLstring += '<UnitPriceDue>1</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge>';
        XMLstring += '<UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
        XMLstring += '<DiscountCharge>0</DiscountCharge>';
        XMLstring += '<DiscountDue>0</DiscountDue>';
        XMLstring += '<SKU>Membership</SKU>';
        XMLstring += '<CampaignName></CampaignName>';
        XMLstring += '</OrderItem>';
        XMLstring += '</OrderItemList></CnPTransactionData>';


        // create new CnP_Data record
        CnP_PaaS_Bridge__CnPData__c TestData = new CnP_PaaS_Bridge__CnPData__c(
                CnP_PaaS_Bridge__DataXML__c = XMLstring,
                CnP_PaaS_Bridge__Order_Number__c = '1207181600564311111',
                CnP_PaaS_Bridge__StatusID__c = 1);
        insert testdata;
        system.debug('Testdata record now contains: '+ testdata);
        CnP_PaaS_Bridge__CnPData__c TestDataUpdated = [select id, CnP_PaaS_Bridge__DataXML__c from CnP_PaaS_Bridge__CnPData__c
        where id = :testdata.id];
            List<WG_Error_Log__c> ErrorList = [SELECT id, Description__c, Category__c from WG_Error_Log__c];
            system.assertEquals(1,ErrorList.size());
            system.debug('ErrorList[0].Description__c is ' + ErrorList[0].Description__c);
            system.debug('ErrorList[0].Category__c is ' + ErrorList[0].Category__c);

            List<CnP_PaaS_Bridge__CnPData__c> CnPData = [SELECT id, CnP_PaaS_Bridge__Order_Number__c FROM CnP_PaaS_Bridge__CnPData__c];
            system.assertEquals(1,CnPData.size(),'If try/catch worked, the CnPData should have been saved.');

            // No Opportunity saved
            List<Opportunity> Payments = [select id,Name,CampaignID,Amount,AccountID,Contact__c, campaign.Name, Account.Name, Attendee__c from Opportunity ];
        system.assertEquals(0,Payments.size(),'Should have created a payment linked to the orphanage');
        // system.assertEquals('Lost Payments',Payments[0].campaign.name,'Should have created a payment linked to Lost Payments');
} // end test
} // end class