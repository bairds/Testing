// 15 DEC 2015.  SECTION ADDED TO PARSE THE CAMPAIGN NODE STRUCTURE FROM THE CONNECT APPLICATION.
// Added Exception Handling, send errors to WG_Error_Log;
// 7 Dec removed search for application by name, search for WGCampaignId now works.

@isTest 
private class parseCnPDataXMLTest {
    
/*    @testsetup static void SetupVariables(){
    populateWGCustomSettings.populateWGSettings();
    }*/
  
static testMethod void standardDonation() {
    String testxml = '<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><Patron>';
		testxml += '<BillingInformation><BillingFirstName>Tester</BillingFirstName><BillingMI></BillingMI>';
		testxml += '<BillingLastName>TestContact</BillingLastName><BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
		testxml += '<BillingPhone>333</BillingPhone></BillingInformation><BillingAddress>';
		testxml += '<BillingAddress1>lkj;</BillingAddress1><BillingAddress2></BillingAddress2><BillingAddress3>';
		testxml += '</BillingAddress3><BillingCity>;lkj</BillingCity><BillingStateProvince>Alabama</BillingStateProvince>';
		testxml += '<BillingPostalCode>33333</BillingPostalCode><BillingCountryName>United States of America</BillingCountryName>';
		testxml += '</BillingAddress></Patron>';
			testxml +='<CustomFieldList>';
			testxml +='<CustomField>';
			testxml +='<FieldName>GiftMember</FieldName><FieldValue>Gift Membership Recipient</FieldValue>';
			testxml +='</CustomField>';
			testxml +='<CustomField>';
			testxml +='<FieldName>InHonorOf</FieldName><FieldValue>Person Memorialized</FieldValue>';
			testxml +='</CustomField>';
			testxml +='<CustomField><FieldName>Place of Employment</FieldName><FieldValue>Blacksburg, Virginia</FieldValue>';
			testxml +='</CustomField>';
			testxml +='<CustomField><FieldName>If this is your first donation or payment to our organization, please tell us how you first heard about us.</FieldName><FieldValue>Web</FieldValue>';
			testxml +='</CustomField>';
			testxml +='</CustomFieldList>';
			testxml +='<TransactionDetail><OrderNumber>1207131327206181111</OrderNumber>';
		testxml += '<Tracker>TestTracker</Tracker><Campaign>TestCampaign</Campaign><WindowName>Wild and Scenic Film Fest</WindowName>';
		testxml += '<WindowId>55337</WindowId><TotalCharge>14.00</TotalCharge><ChargAmount>0.70</ChargAmount>';
		testxml += '<TransactionDate>2012-07-13 13:27:00</TransactionDate><TransactionTimeZone>2012-07-13 13:27:00</TransactionTimeZone>';
		testxml += '<TransactionResult>Authorized</TransactionResult><UrlReferrer>http://leadgreen.org/wordpress/</UrlReferrer>';
		testxml += '<PaymentMethod><PaymentType>Credit Card</PaymentType><CreditCard>';
		testxml += '<NameOnCard>Test16 Tester</NameOnCard><CardNumber>41111111</CardNumber><CardName>VISA</CardName>';
		testxml += '<ExpirationDate>1208</ExpirationDate></CreditCard></PaymentMethod></TransactionDetail>';
		testxml += '<OrderItemList>';
		testxml += '<OrderItem>';
		testxml += '<ItemID>1</ItemID>';
		testxml += '<ItemName>Event Attendee-Baird straughan</ItemName>';
		testxml += '<Quantity>1</Quantity>';
		testxml += '<UnitPriceCharge>14</UnitPriceCharge>';
		testxml += '<UnitPriceDue>14</UnitPriceDue>';
		testxml += '<UnitDeductibleCharge>0</UnitDeductibleCharge>';
		testxml += '<UnitDeductibleDue>0</UnitDeductibleDue>';
		testxml += '<TaxAmountCharge>0</TaxAmountCharge>';
		testxml += '<TaxAmountDue>0</TaxAmountDue>';
		testxml += '<DiscountCharge>0</DiscountCharge>';
		testxml += '<DiscountDue>0</DiscountDue>';
		testxml += '<SKU>Membership</SKU>';
		testxml += '<CampaignName></CampaignName>';
		testxml += '</OrderItem>';
		testxml += '</OrderItemList></CnPTransactionData>';

        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        Contact TestCtct = ctv.fetchTestContact();
        Campaign TestCamp = ctv.fetchTestCampaign();
    		
        // Create a CnP Data record;
        CnP_PaaS_Bridge__CnPData__c TestData = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = testxml, 
        CnP_PaaS_Bridge__Order_Number__c = '1207131327206181111');
        insert testdata;

        system.debug('Testdata record now contains: '+ testdata);
        system.debug('testdata.CnP_PaaS__OrderNumber__c is' + testdata.CnP_PaaS_Bridge__Order_Number__c);
        map<string, string> results = parseCNPDataXML.parseXML(testdata.CnP_PaaS_Bridge__DataXML__c);
        system.assertEquals('TestContact', results.get('lastname'));
		system.assertEquals('14.00',results.get('totalcharge'));
		system.assertEquals('14',results.get('unitpricecharge0'));
        system.assertEquals('0.70', results.get('chargamount'));
		System.assertEquals('GiftMember', results.get('customquestion1'));
		System.assertEquals('Gift Membership Recipient', results.get('customanswer1'));
		System.assertEquals('InHonorOf', results.get('customquestion2'));
		System.assertEquals('Person Memorialized', results.get('customanswer2'));
		System.assertEquals('Place of Employment', results.get('customquestion3'));
		System.assertEquals('Blacksburg, Virginia', results.get('customanswer3'));
		System.assertEquals('Web', results.get('leadsource'));
			
    // Is firstname "test" when I parse it? 
    
    //list<string> results = parseCnPDataXML.parseCnPDataXML(testdata.CnP_PaaS__OrderNumber__c);
    //system.assertEquals('Test',results[0]);        
    }
	

//Test for recurring donation		
	static testMethod void RecurringDonation() {

        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        Contact TestCtct = ctv.fetchTestContact();
        Campaign TestCamp = ctv.fetchTestCampaign();
    		        
		// Create test string, this time with recurring information
		String testxml = '<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><Patron><BillingInformation><BillingFirstName>Tester</BillingFirstName><BillingMI></BillingMI><BillingLastName>TestContact</BillingLastName><BillingEmail>testcontact@dontbotherme.org</BillingEmail><BillingPhone>333</BillingPhone></BillingInformation><BillingAddress><BillingAddress1>lkj;</BillingAddress1><BillingAddress2></BillingAddress2><BillingAddress3></BillingAddress3><BillingCity>;lkj</BillingCity><BillingStateProvince>Alabama</BillingStateProvince><BillingPostalCode>33333</BillingPostalCode><BillingCountryName>United States of America</BillingCountryName></BillingAddress></Patron><TransactionDetail><OrderNumber>1207131327206181111</OrderNumber><Tracker>TestTracker</Tracker>';
        testxml += '<Campaign>TestCampaign</Campaign><WindowName>Wild and Scenic Film Fest</WindowName><WindowId>55337</WindowId><TotalCharge>14.00</TotalCharge><ChargAmount>0.70</ChargAmount><TransactionDate>2012-07-13 13:27:00</TransactionDate><TransactionTimeZone>2012-07-13 13:27:00</TransactionTimeZone><TransactionResult>Authorized</TransactionResult><UrlReferrer>http://leadgreen.org/wordpress/</UrlReferrer><PaymentMethod><PaymentType>Credit Card</PaymentType><CreditCard>';
		testxml += '<NameOnCard>Test16 Tester</NameOnCard><CardNumber>41111111</CardNumber><CardName>VISA</CardName>';
		testxml += '<ExpirationDate>1208</ExpirationDate></CreditCard></PaymentMethod></TransactionDetail>';
		testxml += '<Recurring><TransactionResult>Authorized</TransactionResult><RecurringID>47212</RecurringID>';
		testxml += '<MasterTransactionNumber>1307101607584781111</MasterTransactionNumber><Installments>2</Installments>';
		testxml += '<RecurringMethod>Subscription</RecurringMethod><Periodicity>Monthly</Periodicity>';
		testxml += '<InstallmentNumber>1</InstallmentNumber><NextInstallmentDate>2013-08-10 16:08:00</NextInstallmentDate>';
		testxml += '<InstallmentAmount>14.00</InstallmentAmount><TotalAmount>14.00</TotalAmount><TotalCommitted>28.00</TotalCommitted>';
		testxml += '<TotalMade>14.00</TotalMade><TotalDue>14.00</TotalDue></Recurring>';
		testxml += '<OrderItemList>';
		testxml += '<OrderItem>';
		testxml += '<ItemID>1</ItemID>';
		testxml += '<ItemName>Event Attendee-Baird straughan</ItemName>';
		testxml += '<Quantity>1</Quantity>';
		testxml += '<UnitPriceCharge>14</UnitPriceCharge>';
		testxml += '<UnitPriceDue>14</UnitPriceDue>';
		testxml += '<UnitDeductibleCharge>0</UnitDeductibleCharge>';
		testxml += '<UnitDeductibleDue>0</UnitDeductibleDue>';
		testxml += '<TaxAmountCharge>0</TaxAmountCharge>';
		testxml += '<TaxAmountDue>0</TaxAmountDue>';
		testxml += '<DiscountCharge>0</DiscountCharge>';
		testxml += '<DiscountDue>0</DiscountDue>';
		testxml += '<SKU>Membership</SKU>';
		testxml += '<CampaignName></CampaignName>';
		testxml += '</OrderItem>';
		testxml += '</OrderItemList></CnPTransactionData>';

        Map<String, String> parseResults = parseCnPDataXML.parseXML(testxml);
		System.assertEquals('2013-08-10 16:08:00',parseresults.get('nextinstallmentdate'));
		
		
        CnP_PaaS_Bridge__CnPData__c TestData2 = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = testxml, 
        CnP_PaaS_Bridge__Order_Number__c = '1207131327206181111');
        insert testdata2;
		
		
        system.debug('Testdata record now contains: '+ testdata2);
        system.debug('testdata.CnP_PaaS__OrderNumber__c is' + testdata2.CnP_PaaS_Bridge__Order_Number__c);
        map<string, string> results = parseCNPDataXML.parseXML(testdata2.CnP_PaaS_Bridge__DataXML__c);
        system.assertEquals('TestContact', results.get('lastname'));
		system.assertEquals('14.00',results.get('totalcharge'));
        system.assertEquals('0.70', results.get('chargamount'));
		System.assertEquals('Subscription', results.get('recurringmethod'));
		System.assertEquals('1', results.get('installmentnumber'));
		System.assertEquals('2013-08-10 16:08:00', results.get('nextinstallmentdate'));
	}
	
//Test for multi-item donation		
	static testMethod void EventandDonation() {
		// Create test string, this time with recurring information
    String testxml = '<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><Patron>';
		testxml += '<BillingInformation><BillingFirstName>Tester</BillingFirstName><BillingMI></BillingMI>';
		testxml += '<BillingLastName>TestContact</BillingLastName><BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
		testxml += '<BillingPhone>333</BillingPhone></BillingInformation><BillingAddress>';
		testxml += '<BillingAddress1>lkj;</BillingAddress1><BillingAddress2></BillingAddress2><BillingAddress3>';
		testxml += '</BillingAddress3><BillingCity>;lkj</BillingCity><BillingStateProvince>Alabama</BillingStateProvince>';
		testxml += '<BillingPostalCode>33333</BillingPostalCode><BillingCountryName>United States of America</BillingCountryName>';
		testxml += '</BillingAddress></Patron><TransactionDetail><OrderNumber>1207131327206181111</OrderNumber>';
		testxml += '<Tracker>TestTracker</Tracker><Campaign>TestCampaign</Campaign><WindowName>Wild and Scenic Film Fest</WindowName>';
		testxml += '<WindowId>55337</WindowId><TotalCharge>14.00</TotalCharge><ChargAmount>0.70</ChargAmount>';
		testxml += '<TransactionDate>2012-07-13 13:27:00</TransactionDate><TransactionTimeZone>2012-07-13 13:27:00</TransactionTimeZone>';
		testxml += '<TransactionResult>Authorized</TransactionResult><UrlReferrer>http://leadgreen.org/wordpress/</UrlReferrer>';
		testxml += '<PaymentMethod><PaymentType>Credit Card</PaymentType><CreditCard>';
		testxml += '<NameOnCard>Test16 Tester</NameOnCard><CardNumber>41111111</CardNumber><CardName>VISA</CardName>';
		testxml += '<ExpirationDate>1208</ExpirationDate></CreditCard></PaymentMethod></TransactionDetail>';
		testxml += '<OrderItemList><OrderItem><ItemID>100</ItemID><ItemName>Dinner Attendee-Brian Nudelman</ItemName>';
		testxml += '<Quantity>1</Quantity><UnitPriceCharge>50</UnitPriceCharge><UnitPriceDue>50</UnitPriceDue>';
		testxml += '<UnitDeductibleCharge>0</UnitDeductibleCharge><UnitDeductibleDue>0</UnitDeductibleDue>';
		testxml += '<TaxAmountCharge>0</TaxAmountCharge><TaxAmountDue>0</TaxAmountDue><DiscountCharge>0</DiscountCharge>';
		testxml += '<DiscountDue>0</DiscountDue><SKU>AnnualDinnerFee</SKU><CampaignName>Dinner 2013 Tickets</CampaignName></OrderItem>';
		testxml += '<OrderItem><ItemID>101</ItemID><ItemName>Please make a donation to Prairie Rivers Network</ItemName>';
		testxml += '<Quantity>1</Quantity><UnitPriceCharge>33</UnitPriceCharge><UnitPriceDue>33</UnitPriceDue>';
		testxml += '<UnitDeductibleCharge>33</UnitDeductibleCharge><UnitDeductibleDue>33</UnitDeductibleDue>';
		testxml += '<TaxAmountCharge>0</TaxAmountCharge><TaxAmountDue>0</TaxAmountDue><DiscountCharge>0</DiscountCharge>';
		testxml += '<DiscountDue>0</DiscountDue><SKU>AnnualDinner2013Donation</SKU></OrderItem>';
		testxml += '</OrderItemList>';
		testxml += '</CnPTransactionData>';
		
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        Contact TestCtct = ctv.fetchTestContact();
        Campaign TestCamp = ctv.fetchTestCampaign();
    		
        Map<String, String> parseResults = parseCnPDataXML.parseXML(testxml);
		
		
        CnP_PaaS_Bridge__CnPData__c TestData2 = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = testxml, 
        CnP_PaaS_Bridge__Order_Number__c = '1207131327206181111');
        insert testdata2;
		
		
        system.debug('Testdata record now contains: '+ testdata2);
        system.debug('testdata.CnP_PaaS__OrderNumber__c is' + testdata2.CnP_PaaS_Bridge__Order_Number__c);
        map<string, string> results = parseCNPDataXML.parseXML(testdata2.CnP_PaaS_Bridge__DataXML__c);
        system.assertEquals('TestContact', results.get('lastname'));
        system.assertEquals('0.70', results.get('chargamount'));
		System.assertEquals('2',results.get('orderitems'));
		System.assertEquals('100',results.get('itemid0'));
		System.assertEquals('101',results.get('itemid1'));
		System.assertEquals('AnnualDinnerFee',results.get('sku0'));
		System.assertEquals('AnnualDinner2013Donation',results.get('sku1'));
		System.assertEquals('50',results.get('unitpricedue0'));
		System.assertEquals('33',results.get('unitpricedue1'));
		System.assertEquals('Dinner Attendee-Brian Nudelman',results.get('itemname0'));
		System.assertEquals('Please make a donation to Prairie Rivers Network',results.get('itemname1'));
	} // end multi-donation test

// free signup	
	static testMethod void FreeEvent() {
	// Create test string, this time with recurring information

		string XMLstring = '<?xml version="1.0" encoding="UTF-8"?>';
		XMLstring += '<CnPTransactionData><Version>40</Version>';
		XMLstring += '<Application><ID>Salesforce:CnP_PaaS_Evt</ID>';
		XMLstring += '<Name>Salesforce:CnP_PaaS_Evt</Name>';
		XMLstring += '<Version>1.2014</Version>';
		XMLstring += '</Application>';
		XMLstring += '<Patron>';
		XMLstring += '<BillingInformation><BillingFirstName>Tester</BillingFirstName>';
		XMLstring += '<BillingMI></BillingMI>';
		XMLstring += '<BillingLastName>TestContact</BillingLastName>';
		XMLstring += '<BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
		XMLstring += '<BillingPhone></BillingPhone>';
		XMLstring += '</BillingInformation>';
		XMLstring += '<BillingAddress><BillingAddress1>Test Street</BillingAddress1>';
		XMLstring += '<BillingAddress2></BillingAddress2>';
		XMLstring += '<BillingAddress3></BillingAddress3>';
		XMLstring += '<BillingCity>Test City</BillingCity>';
		XMLstring += '<BillingStateProvince>AL</BillingStateProvince>';
		XMLstring += '<BillingPostalCode>33333</BillingPostalCode>';
		XMLstring += '<BillingCountryName></BillingCountryName>';
		XMLstring += '</BillingAddress>';
		XMLstring += '</Patron>';
		XMLstring += '<TransactionDetail>';
		XMLstring += '<OrderNumber>130823105233452</OrderNumber>';
		XMLstring += '<TransactionID>1811524</TransactionID>';
		XMLstring += '<OrderMode>Live</OrderMode>';
		XMLstring += '<Tracker>TestTracker</Tracker>';
		XMLstring += '<Campaign>TestCampaign</Campaign>';
		XMLstring += '<TransactionType>Live</TransactionType>';
		XMLstring += '<OrganizationID>25820</OrganizationID>';
		XMLstring += '<OrganizationName>Prairie Rivers Network</OrganizationName>';
		XMLstring += '<CurrencyCode>840</CurrencyCode>';
		XMLstring += '<AuthorizationCode></AuthorizationCode>';
		XMLstring += '<WindowName></WindowName>';
		XMLstring += '<WindowId>-1</WindowId>';
		XMLstring += '<GatewayTransactionNumber></GatewayTransactionNumber>';
		XMLstring += '<TotalCharge>0.00</TotalCharge>';
		XMLstring += '<TotalDue>0.00</TotalDue>';
		XMLstring += '<DeductibleCharge>0.00</DeductibleCharge>';
		XMLstring += '<DeductibleDue>0.00</DeductibleDue>';
		XMLstring += '<DiscountDue>0.00</DiscountDue>';
		XMLstring += '<DiscountCharge>0.00</DiscountCharge>';
		XMLstring += '<TaxAmountDue>0.00</TaxAmountDue>';
		XMLstring += '<TaxAmountCharge>0.00</TaxAmountCharge>';
		XMLstring += '<SurCharge>0.00</SurCharge>';
		XMLstring += '<ChargAmount>0.00</ChargAmount>';
		XMLstring += '<CouponCode></CouponCode>';
		XMLstring += '<TransactionDiscountDue>0.00</TransactionDiscountDue>';
		XMLstring += '<TransactionDiscountCharge>0.00</TransactionDiscountCharge>';
		XMLstring += '<TransactionTaxDue>0.00</TransactionTaxDue>';
		XMLstring += '<TransactionTaxCharge>0.00</TransactionTaxCharge>';
		XMLstring += '<TransactionDate>2013-08-23 10:53:00</TransactionDate>';
		XMLstring += '<TransactionTimeZone>2013-08-23 02:53:00</TransactionTimeZone>';
		XMLstring += '<UrlReferrer></UrlReferrer>';
		XMLstring += '<VaultGUID></VaultGUID>';
		XMLstring += '<PaymentMethod>';
		XMLstring += '<PaymentType>CustomPaymentType</PaymentType>';
		XMLstring += '<CustomPaymentType>';
		XMLstring += '<CustomPaymentName>Free</CustomPaymentName>';
		XMLstring += '<CustomPaymentNumber></CustomPaymentNumber>';
		XMLstring += '</CustomPaymentType>';
		XMLstring += '</PaymentMethod>';

		XMLstring += '<CustomParameters><Parameter>';
		XMLstring += '<Field>sfeventid</Field>';
		XMLstring += '<Value>a0ri0000000OqzYAAS</Value>';
		XMLstring += '</Parameter>';
		XMLstring += '<Parameter>';
		XMLstring += '<Field>registrantid</Field>';
		XMLstring += '<Value>a0vi0000000lenoAAA</Value>';
		XMLstring += '</Parameter>';
		XMLstring += '</CustomParameters>';
		XMLstring += '</TransactionDetail>';
		XMLstring += '<OrderItemList>';
		XMLstring += '<OrderItem>';
		XMLstring += '<ItemID>1</ItemID>';
		XMLstring += '<ItemName>Event Attendee-Baird straughan</ItemName>';
		XMLstring += '<Quantity>1</Quantity>';
		XMLstring += '<UnitPriceCharge>0</UnitPriceCharge>';
		XMLstring += '<UnitPriceDue>0</UnitPriceDue>';
		XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge>';
		XMLstring += '<UnitDeductibleDue>0</UnitDeductibleDue>';
		XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
		XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
		XMLstring += '<DiscountCharge>0</DiscountCharge>';
		XMLstring += '<DiscountDue>0</DiscountDue>';
		XMLstring += '<SKU>Event</SKU>';
		XMLstring += '<CampaignName>TestCampaign</CampaignName>';
		XMLstring += '</OrderItem>';

		XMLstring += '</OrderItemList>';
		XMLstring += '<PassThroughList><PassThrough>';
		XMLstring += '<Name>CnP.SF.eVT.Setting</Name>';
		XMLstring += '<Parameter>';
		XMLstring += '<Field>sfeventid</Field>';
		XMLstring += '<Value>a0ri0000000OqzYAAS</Value>';
		XMLstring += '</Parameter>';
		XMLstring += '<Parameter>';
		XMLstring += '<Field>registrantid</Field>';
		XMLstring += '<Value>a0vi0000000lenoAAA</Value>';
		XMLstring += '</Parameter>';
		XMLstring += '</PassThrough>';
		XMLstring += '</PassThroughList>';
		XMLstring += '</CnPTransactionData>';
		
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        Contact TestCtct = ctv.fetchTestContact();
        Campaign TestCamp = ctv.fetchTestCampaign();
    		
        Map<String, String> parseResults = parseCnPDataXML.parseXML(XMLstring);
		
		
        CnP_PaaS_Bridge__CnPData__c TestData2 = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = XMLstring, 
        CnP_PaaS_Bridge__Order_Number__c = '1207131327206181111');
        insert testdata2;
		
		
        system.debug('Testdata record now contains: '+ testdata2);
        system.debug('testdata.CnP_PaaS__OrderNumber__c is' + testdata2.CnP_PaaS_Bridge__Order_Number__c);
        map<string, string> results = parseCNPDataXML.parseXML(testdata2.CnP_PaaS_Bridge__DataXML__c);
        system.assertEquals('TestContact', results.get('lastname'));
		system.assertEquals('TestCampaign', results.get('campaign'));
        system.assertEquals('0.00', results.get('chargamount'));
		System.assertEquals('1',results.get('orderitems'));
		System.assertEquals('1',results.get('itemid0'));
		System.assertEquals('Event',results.get('sku0'));
		System.assertEquals('0',results.get('unitpricedue0'));
		System.assertEquals('Event Attendee-Baird straughan',results.get('itemname0'));
	} // end free event test


// Virtual Terminal input test.  Virtal Terminal input puts the campaign into the "CampaignName" field on the item
// instead of the "Campaign" field on the event.
// In this case, also use the ItemName field for the ContributionRecordType.
	static testMethod void VirtualTerminalInput() {
	// Create test string, this time with recurring information

            string XMLstring = '<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version>';
            XMLstring +='<Application><ID>Salesforce:CnP_PaaS</ID>';
            XMLstring +='<Name>Salesforce:CnP_PaaS</Name>';
            XMLstring +='<Version>8.9004</Version>';
            XMLstring +='</Application>';
            XMLstring +='<Patron>';
            XMLstring +='<BillingInformation><BillingFirstName>Baird</BillingFirstName>';
            XMLstring +='<BillingMI />';
            XMLstring +='<BillingLastName>Straughan</BillingLastName>';
            XMLstring +='<BillingEmail>baird@leadgreen.org</BillingEmail>';
            XMLstring +='<BillingPhone>(301) 775-5944</BillingPhone>';
            XMLstring +='</BillingInformation>';
            XMLstring +='<BillingAddress><BillingAddress1>675 Mariners Circle</BillingAddress1>';
            XMLstring +='<BillingAddress2 />';
            XMLstring +='<BillingAddress3 />';
            XMLstring +='<BillingCity>Annapolis</BillingCity>';
            XMLstring +='<BillingStateProvince>MD</BillingStateProvince>';
            XMLstring +='<BillingPostalCode>21409</BillingPostalCode>';
            XMLstring +='<BillingCountryName>United States</BillingCountryName>';
            XMLstring +='</BillingAddress>';
            XMLstring +='<ShippingInformation><ShippingContactInformation><ShippingFirstName>Baird</ShippingFirstName>';
            XMLstring +='<ShippingMI />';
            XMLstring +='<ShippingLastName>Straughan</ShippingLastName>';
            XMLstring +='<ShippingEmail />';
            XMLstring +='<ShippingPhone>(301) 775-5944</ShippingPhone>';
            XMLstring +='</ShippingContactInformation>';
            XMLstring +='<ShippingAddress><ShippingAddress1>675 Mariners Circle</ShippingAddress1>';
            XMLstring +='<ShippingAddress2 />';
            XMLstring +='<ShippingAddress3 />';
            XMLstring +='<ShippingCity>Annapolis</ShippingCity>';
            XMLstring +='<ShippingStateProvince>MD</ShippingStateProvince>';
            XMLstring +='<ShippingPostalCode>21409</ShippingPostalCode>';
            XMLstring +='<ShippingCountryName>United States</ShippingCountryName>';
            XMLstring +='</ShippingAddress>';
            XMLstring +='</ShippingInformation>';
            XMLstring +='<CustomParameters><Parameter>';
            XMLstring +='<Field>SalesforceContactID</Field>';
            XMLstring +='<Value>003U000001D9IheIAF</Value>';
            XMLstring +='</Parameter>';
            XMLstring +='</CustomParameters>';
            XMLstring +='</Patron>';
            XMLstring +='<TransactionDetail>';
            XMLstring +='<OrderNumber>1505291752263478003</OrderNumber>';
            XMLstring +='<TransactionID>3899074</TransactionID>';
            XMLstring +='<OrderMode>Live</OrderMode>';
            XMLstring +='<Tracker>This the tracker.</Tracker>';
            XMLstring +='<Campaign>This is transaction campaign.</Campaign>';
            XMLstring +='<TransactionType>Live</TransactionType>';
            XMLstring +='<OrganizationID>21907</OrganizationID>';
            XMLstring +='<OrganizationName>Hackensack Riverkeeper, Inc.</OrganizationName>';
            XMLstring +='<CurrencyCode>840</CurrencyCode>';
            XMLstring +='<AuthorizationCode>065232</AuthorizationCode>';
            XMLstring +='<WindowName />';
            XMLstring +='<WindowId>-1</WindowId>';
            XMLstring +='<GatewayTransactionNumber>720938054</GatewayTransactionNumber>';
            XMLstring +='<TotalCharge>1.00</TotalCharge>';
            XMLstring +='<TotalDue>1.00</TotalDue>';
            XMLstring +='<DeductibleCharge>1.00</DeductibleCharge>';
            XMLstring +='<DeductibleDue>1.00</DeductibleDue>';
            XMLstring +='<DiscountDue>0.00</DiscountDue>';
            XMLstring +='<DiscountCharge>0.00</DiscountCharge>';
            XMLstring +='<TaxAmountDue>0.00</TaxAmountDue>';
            XMLstring +='<TaxAmountCharge>0.00</TaxAmountCharge>';
            XMLstring +='<SurCharge>0.00</SurCharge>';
            XMLstring +='<ChargAmount>0.78</ChargAmount>';
            XMLstring +='<CouponCode />';
            XMLstring +='<TransactionDiscountDue>0.00</TransactionDiscountDue>';
            XMLstring +='<TransactionDiscountCharge>0.00</TransactionDiscountCharge>';
            XMLstring +='<TransactionTaxDue>0.00</TransactionTaxDue>';
            XMLstring +='<TransactionTaxCharge>0.00</TransactionTaxCharge>';
            XMLstring +='<TransactionDate>2015-05-29 17:52:31</TransactionDate>';
            XMLstring +='<TransactionTimeZone>2015-05-29 17:52:31</TransactionTimeZone>';
            XMLstring +='<UrlReferrer />';
            XMLstring +='<VaultGUID>86c6212b-2eca-40a7-bbfe-5a6ddf500f0c</VaultGUID>';
            XMLstring +='<TransactionResult>Authorized</TransactionResult>';
            XMLstring +='<PaymentMethod>';
            XMLstring +='<PaymentType>Credit Card</PaymentType>';
            XMLstring +='<CreditCard>';
            XMLstring +='<NameOnCard>Baird Straughan</NameOnCard>';
            XMLstring +='<CardName>MasterCard</CardName>';
            XMLstring +='<ExpirationDate>XXXX</ExpirationDate><CardNumber>XXXXXXXXXXXX8003</CardNumber></CreditCard>';
            XMLstring +='</PaymentMethod>';
            XMLstring +='</TransactionDetail>';
            XMLstring +='<CustomFieldList>';
            XMLstring +='<CustomField>';
            XMLstring +='<FieldName>Additional Information</FieldName>';
            XMLstring +='<FieldValue />';
            XMLstring +='</CustomField>';
            XMLstring +='</CustomFieldList>';
            XMLstring +='<OrderItemList>';
            XMLstring +='<OrderItem>';
            XMLstring +='<ItemID>1000</ItemID>';
            XMLstring +='<ItemName>Other</ItemName>';
            XMLstring +='<Quantity>1</Quantity>';
            XMLstring +='<UnitPriceCharge>1</UnitPriceCharge>';
            XMLstring +='<UnitPriceDue>1</UnitPriceDue>';
            XMLstring +='<UnitDeductibleCharge>1</UnitDeductibleCharge>';
            XMLstring +='<UnitDeductibleDue>1</UnitDeductibleDue>';
            XMLstring +='<TaxAmountCharge>0</TaxAmountCharge>';
            XMLstring +='<TaxAmountDue>0</TaxAmountDue>';
            XMLstring +='<DiscountCharge>0</DiscountCharge>';
            XMLstring +='<DiscountDue>0</DiscountDue>';
            XMLstring +='<SKU>Donation</SKU>';
            XMLstring +='<CampaignName>YE14</CampaignName>';
            XMLstring +='</OrderItem>';
            XMLstring +='</OrderItemList>';
            XMLstring +='<Shipping>';
            XMLstring +='<ShippingMethod>Shipping</ShippingMethod>';
            XMLstring +='<ShippingValueCharge>0</ShippingValueCharge>';
            XMLstring +='<ShippingValueDue>0</ShippingValueDue>';
            XMLstring +='<ShippingTaxCharge>0</ShippingTaxCharge>';
            XMLstring +='<ShippingTaxDue>0</ShippingTaxDue>';
            XMLstring +='</Shipping>';
            XMLstring +='</CnPTransactionData>';

		
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        Contact TestCtct = ctv.fetchTestContact();
        Campaign TestCamp = ctv.fetchTestCampaign();
    		
        Map<String, String> parseResults = parseCnPDataXML.parseXML(XMLstring);
		
		
        CnP_PaaS_Bridge__CnPData__c TestData2 = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = XMLstring, 
        CnP_PaaS_Bridge__Order_Number__c = '1207131327206181111');
        insert testdata2;
		
		
        system.debug('Testdata record now contains: '+ testdata2);
        system.debug('testdata.CnP_PaaS__OrderNumber__c is' + testdata2.CnP_PaaS_Bridge__Order_Number__c);
        map<string, string> results = parseCNPDataXML.parseXML(testdata2.CnP_PaaS_Bridge__DataXML__c);
        system.assertEquals('Straughan', results.get('lastname'));
		system.assertEquals('This is transaction campaign.', results.get('campaign'));
		system.assertEquals('YE14', results.get('campaignname0'));
        system.assertEquals('0.78', results.get('chargamount'));
		System.assertEquals('1',results.get('orderitems'));
		System.assertEquals('1000',results.get('itemid0'));
		System.assertEquals('Donation',results.get('sku0'));
		System.assertEquals('1',results.get('unitpricedue0'));
		System.assertEquals('Other',results.get('itemname0'));
	} // end free event test

	static testMethod void ConnectDonation() {
	
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        Contact TestCtct = ctv.fetchTestContact();
        Campaign TestCamp = ctv.fetchTestCampaign();

        
        // Create test string, this time with recurring information

            string XMLstring = '<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version>';
            XMLstring +='<Application><ID>Salesforce:CnP_PaaS</ID>';
            XMLstring +='<Name>Connect</Name>';
            XMLstring +='<Version>8.9004</Version>';
            XMLstring +='</Application>';
            XMLstring +='<Patron>';
            XMLstring +='<BillingInformation><BillingFirstName>Baird</BillingFirstName>';
            XMLstring +='<BillingMI />';
            XMLstring +='<BillingLastName>Straughan</BillingLastName>';
            XMLstring +='<BillingEmail>baird@leadgreen.org</BillingEmail>';
            XMLstring +='<BillingPhone>(301) 775-5944</BillingPhone>';
            XMLstring +='</BillingInformation>';
            XMLstring +='<BillingAddress><BillingAddress1>675 Mariners Circle</BillingAddress1>';
            XMLstring +='<BillingAddress2 />';
            XMLstring +='<BillingAddress3 />';
            XMLstring +='<BillingCity>Annapolis</BillingCity>';
            XMLstring +='<BillingStateProvince>MD</BillingStateProvince>';
            XMLstring +='<BillingPostalCode>21409</BillingPostalCode>';
            XMLstring +='<BillingCountryName>United States</BillingCountryName>';
            XMLstring +='</BillingAddress>';
            XMLstring +='<ShippingInformation><ShippingContactInformation><ShippingFirstName>Baird</ShippingFirstName>';
            XMLstring +='<ShippingMI />';
            XMLstring +='<ShippingLastName>Straughan</ShippingLastName>';
            XMLstring +='<ShippingEmail />';
            XMLstring +='<ShippingPhone>(301) 775-5944</ShippingPhone>';
            XMLstring +='</ShippingContactInformation>';
            XMLstring +='<ShippingAddress><ShippingAddress1>675 Mariners Circle</ShippingAddress1>';
            XMLstring +='<ShippingAddress2 />';
            XMLstring +='<ShippingAddress3 />';
            XMLstring +='<ShippingCity>Annapolis</ShippingCity>';
            XMLstring +='<ShippingStateProvince>MD</ShippingStateProvince>';
            XMLstring +='<ShippingPostalCode>21409</ShippingPostalCode>';
            XMLstring +='<ShippingCountryName>United States</ShippingCountryName>';
            XMLstring +='</ShippingAddress>';
            XMLstring +='</ShippingInformation>';
            XMLstring +='<CustomParameters><Parameter>';
            XMLstring +='<Field>SalesforceContactID</Field>';
            XMLstring +='<Value>003U000001D9IheIAF</Value>';
            XMLstring +='</Parameter>';
            XMLstring +='</CustomParameters>';
            XMLstring +='</Patron>';
            XMLstring +='<TransactionDetail>';
            XMLstring +='<OrderNumber>1505291752263478003</OrderNumber>';
            XMLstring +='<TransactionID>3899074</TransactionID>';
            XMLstring +='<OrderMode>Live</OrderMode>';
            XMLstring +='<Tracker>This the tracker.</Tracker>';
            XMLstring +='<Campaign></Campaign>';
            XMLstring +='<TransactionType>Live</TransactionType>';
            XMLstring +='<OrganizationID>21907</OrganizationID>';
            XMLstring +='<OrganizationName>Hackensack Riverkeeper, Inc.</OrganizationName>';
            XMLstring +='<CurrencyCode>840</CurrencyCode>';
            XMLstring +='<AuthorizationCode>065232</AuthorizationCode>';
            XMLstring +='<WindowName />';
            XMLstring +='<WindowId>-1</WindowId>';
            XMLstring +='<GatewayTransactionNumber>720938054</GatewayTransactionNumber>';
            XMLstring +='<TotalCharge>1.00</TotalCharge>';
            XMLstring +='<TotalDue>1.00</TotalDue>';
            XMLstring +='<DeductibleCharge>1.00</DeductibleCharge>';
            XMLstring +='<DeductibleDue>1.00</DeductibleDue>';
            XMLstring +='<DiscountDue>0.00</DiscountDue>';
            XMLstring +='<DiscountCharge>0.00</DiscountCharge>';
            XMLstring +='<TaxAmountDue>0.00</TaxAmountDue>';
            XMLstring +='<TaxAmountCharge>0.00</TaxAmountCharge>';
            XMLstring +='<SurCharge>0.00</SurCharge>';
            XMLstring +='<ChargAmount>0.78</ChargAmount>';
            XMLstring +='<CouponCode />';
            XMLstring +='<TransactionDiscountDue>0.00</TransactionDiscountDue>';
            XMLstring +='<TransactionDiscountCharge>0.00</TransactionDiscountCharge>';
            XMLstring +='<TransactionTaxDue>0.00</TransactionTaxDue>';
            XMLstring +='<TransactionTaxCharge>0.00</TransactionTaxCharge>';
            XMLstring +='<TransactionDate>2015-05-29 17:52:31</TransactionDate>';
            XMLstring +='<TransactionTimeZone>2015-05-29 17:52:31</TransactionTimeZone>';
            XMLstring +='<UrlReferrer />';
            XMLstring +='<VaultGUID>86c6212b-2eca-40a7-bbfe-5a6ddf500f0c</VaultGUID>';
            XMLstring +='<TransactionResult>Authorized</TransactionResult>';
            XMLstring +='<PaymentMethod>';
            XMLstring +='<PaymentType>Credit Card</PaymentType>';
            XMLstring +='<CreditCard>';
            XMLstring +='<NameOnCard>Baird Straughan</NameOnCard>';
            XMLstring +='<CardName>MasterCard</CardName>';
            XMLstring +='<ExpirationDate>XXXX</ExpirationDate><CardNumber>XXXXXXXXXXXX8003</CardNumber></CreditCard>';
            XMLstring +='</PaymentMethod>';
            XMLstring +='<CampaignList><CampaignNode>';
            XMLstring +='<CampaignName>Testcampaign</CampaignName>';
            XMLstring +='<CampaignID>16908</CampaignID>';
            XMLstring +='<AccountID>18801</AccountID>';
            XMLstring +='<CampaignExternalID>'+TestCamp.Id+'</CampaignExternalID>';
            XMLstring +='<CampaignScope>Transaction</CampaignScope>';
            XMLstring +='</CampaignNode>';
            XMLstring +='</CampaignList>';
            XMLstring +='</TransactionDetail>';
            XMLstring +='<CustomFieldList>';
            XMLstring +='<CustomField>';
            XMLstring +='<FieldName>Additional Information</FieldName>';
            XMLstring +='<FieldValue />';
            XMLstring +='</CustomField>';
            XMLstring +='</CustomFieldList>';
            XMLstring +='<OrderItemList>';
            XMLstring +='<OrderItem>';
            XMLstring +='<ItemID>1000</ItemID>';
            XMLstring +='<ItemName>Other</ItemName>';
            XMLstring +='<Quantity>1</Quantity>';
            XMLstring +='<UnitPriceCharge>1</UnitPriceCharge>';
            XMLstring +='<UnitPriceDue>1</UnitPriceDue>';
            XMLstring +='<UnitDeductibleCharge>1</UnitDeductibleCharge>';
            XMLstring +='<UnitDeductibleDue>1</UnitDeductibleDue>';
            XMLstring +='<TaxAmountCharge>0</TaxAmountCharge>';
            XMLstring +='<TaxAmountDue>0</TaxAmountDue>';
            XMLstring +='<DiscountCharge>0</DiscountCharge>';
            XMLstring +='<DiscountDue>0</DiscountDue>';
            XMLstring +='<SKU>Donation</SKU>';
            XMLstring +='</OrderItem>';
            XMLstring +='</OrderItemList>';
            XMLstring +='<Shipping>';
            XMLstring +='<ShippingMethod>Shipping</ShippingMethod>';
            XMLstring +='<ShippingValueCharge>0</ShippingValueCharge>';
            XMLstring +='<ShippingValueDue>0</ShippingValueDue>';
            XMLstring +='<ShippingTaxCharge>0</ShippingTaxCharge>';
            XMLstring +='<ShippingTaxDue>0</ShippingTaxDue>';
            XMLstring +='</Shipping>';
            XMLstring +='</CnPTransactionData>';
    		
        Map<String, String> parseResults = parseCnPDataXML.parseXML(XMLstring);
		
		
        CnP_PaaS_Bridge__CnPData__c TestData2 = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = XMLstring, 
        CnP_PaaS_Bridge__Order_Number__c = '1207131327206181111');
        insert testdata2;
		
		
        system.debug('Testdata record now contains: '+ testdata2);
        system.debug('testdata.CnP_PaaS__OrderNumber__c is' + testdata2.CnP_PaaS_Bridge__Order_Number__c);
        map<string, string> results = parseCNPDataXML.parseXML(testdata2.CnP_PaaS_Bridge__DataXML__c);
        system.assertEquals('Straughan', results.get('lastname'));
        system.assertEquals('Connect', results.get('Application'));
		system.assertEquals('Testcampaign', results.get('CampaignName'));
        system.assertEquals('0.78', results.get('chargamount'));
		System.assertEquals('1',results.get('orderitems'));
		System.assertEquals('1000',results.get('itemid0'));
		System.assertEquals('Donation',results.get('sku0'));
		System.assertEquals('1',results.get('unitpricedue0'));
		System.assertEquals('Other',results.get('itemname0'));   
	} // end ConnectDonation test   

	static testMethod void GravityFormsDonation() {
	// Create test string, this time with recurring information

       string XMLstring ='<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><PostedDateTime>2016-11-15 08:55:24</PostedDateTime>';
        XMLstring += '<Application><ID>CnP_PaaS_FM_GravityForm</ID><Name>CnP_PaaS_FM_GravityForm</Name><Version>3.400.000/WP:v4.6.1/GF:v2.1.1</Version>';
        XMLstring += '</Application>';
        XMLstring += '<Patron><BillingInformation><BillingFirstName>Vickie</BillingFirstName><BillingMI></BillingMI><BillingLastName>Nudelman</BillingLastName>';
        XMLstring += '<BillingEmail>vnudelman@prairierivers.org</BillingEmail><BillingPhone>(217) 344-2371</BillingPhone></BillingInformation><BillingAddress><BillingAddress1>1902 Fox Drive</BillingAddress1>';
        XMLstring += '<BillingCity>Champaign</BillingCity><BillingStateProvince>IL</BillingStateProvince><BillingPostalCode>61820</BillingPostalCode><BillingCountryName></BillingCountryName></BillingAddress></Patron>';
        XMLstring += '<TransactionDetail><OrderNumber>1611150855085977266</OrderNumber><ReceiptNumber></ReceiptNumber><TransactionID>6018541</TransactionID>';
        XMLstring += '<OrderMode>Live</OrderMode><Campaign>Testcampaign</Campaign><TransactionType>Live</TransactionType>';
        XMLstring += '<OrganizationName>Prairie Rivers Network</OrganizationName><CurrencyCode>840</CurrencyCode><AuthorizationCode>834326</AuthorizationCode>';
        XMLstring += '<WindowId>-1</WindowId><GatewayTransactionNumber>978313298</GatewayTransactionNumber><TotalCharge>5.00</TotalCharge><TotalDue>5.00</TotalDue>';
        XMLstring += '<DeductibleCharge>0.00</DeductibleCharge><DeductibleDue>0.00</DeductibleDue><DiscountCharge>0.00</DiscountCharge><DiscountDue>0.00</DiscountDue>';
        XMLstring += '<TaxAmountCharge>0.00</TaxAmountCharge><TaxAmountDue>0.00</TaxAmountDue><TransactionDiscountCharge>0.00</TransactionDiscountCharge>';
        XMLstring += '<TransactionDiscountDue>0.00</TransactionDiscountDue><TransactionTaxCharge>0.00</TransactionTaxCharge><TransactionTaxDue>0.00</TransactionTaxDue>';
        XMLstring += '<SurCharge>0.00</SurCharge><ChargAmount>0.15</ChargAmount><CouponCode></CouponCode><TransactionDate>2016-11-15 08:55:08</TransactionDate>';
        XMLstring += '<TransactionTimeZone>2016-11-15 01:55:08</TransactionTimeZone><UrlReferrer>https://prairierivers.org/monarch/</UrlReferrer><VaultGUID>a1321af3-a758-4dc2-970b-96fb2256489f</VaultGUID>';
        XMLstring += '<TransactionResult>Authorized</TransactionResult>';
        XMLstring += '<PaymentMethod><PaymentType>Credit Card</PaymentType><CreditCard><NameOnCard>Vickie Nudelman</NameOnCard><CardNumber>XXXXXXX</CardNumber>';
        XMLstring += '<CardName>VISA</CardName><ExpirationDate>1801</ExpirationDate></CreditCard></PaymentMethod>';
        XMLstring += '</TransactionDetail>';
        XMLstring += '<Recurring><TransactionResult>Authorized</TransactionResult><RecurringStatus>Active</RecurringStatus><RecurringID>224657</RecurringID>';
        XMLstring += '<RecurringIDUpdate></RecurringIDUpdate><MasterTransactionNumber>1611150855085977266</MasterTransactionNumber><MasterTransactionDate>2016-11-15 01:55:08</MasterTransactionDate>';
        XMLstring += '<Installments>999</Installments><ToDateRemainingInstallments>998</ToDateRemainingInstallments><RecurringMethod>Subscription</RecurringMethod>';
        XMLstring += '<Periodicity>Monthly</Periodicity><InstallmentNumber>1</InstallmentNumber><NextInstallmentDate>2016-12-15 08:55:00</NextInstallmentDate>';
        XMLstring += '<InstallmentAmount>5.00</InstallmentAmount><TotalAmount>5.00</TotalAmount><TotalCommitted>4995.00</TotalCommitted><TotalMade>5.00</TotalMade>';
        XMLstring += '<TotalDue>4990.00</TotalDue></Recurring>';
        XMLstring += '<CustomFieldList><CustomField><FieldName>Memorial gift or other special instructions?</FieldName>';
        XMLstring += '<FieldValue>$5 monthly test donation</FieldValue></CustomField><CustomField><FieldName>Would you like a set of 12 notecards featuring 6 landscapes from around Illinois?</FieldName>';
        XMLstring += '<FieldValue>Yes.</FieldValue></CustomField><CustomField><FieldName>Payment type</FieldName><FieldValue>Credit Card</FieldValue>';
        XMLstring += '</CustomField></CustomFieldList>';
        XMLstring += '<OrderItemList><OrderItem><ItemID>101101</ItemID><ItemName>Select Your Monthly Donation Amount ($5)</ItemName><Quantity>1</Quantity>';
        XMLstring += '<UnitPriceCharge>5</UnitPriceCharge><UnitPriceDue>5</UnitPriceDue><UnitDeductibleCharge>0</UnitDeductibleCharge><UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge><TaxAmountDue>0</TaxAmountDue><DiscountCharge>0</DiscountCharge><DiscountDue>0</DiscountDue>';
        XMLstring += '<SKU>RT_Membership-$5</SKU></OrderItem></OrderItemList>';
        XMLstring += '</CnPTransactionData>';
	
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        Contact TestCtct = ctv.fetchTestContact();
        Campaign TestCamp = ctv.fetchTestCampaign();
    		
        Map<String, String> parseResults = parseCnPDataXML.parseXML(XMLstring);
        system.assertEquals(null,parseResults.get('campaignName'));
		system.assertEquals('Testcampaign', parseResults.get('campaign'));
		
		
        CnP_PaaS_Bridge__CnPData__c TestData2 = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = XMLstring, 
        CnP_PaaS_Bridge__Order_Number__c = '1207131327206181111');
        insert testdata2;
		
		
        system.debug('Testdata record now contains: '+ testdata2);
        system.debug('testdata.CnP_PaaS__OrderNumber__c is' + testdata2.CnP_PaaS_Bridge__Order_Number__c);
        map<string, string> results = parseCNPDataXML.parseXML(testdata2.CnP_PaaS_Bridge__DataXML__c);
        system.assertEquals('Nudelman', results.get('lastname'));
        system.assertEquals('CnP_PaaS_FM_GravityForm', results.get('Application'));
        system.assertEquals(null,results.get('campaignName'));
		system.assertEquals('Testcampaign', results.get('campaign'));
        system.assertEquals('0.15', results.get('chargamount'));
		System.assertEquals('1',results.get('orderitems'));
		System.assertEquals('101101',results.get('itemid0'));
		System.assertEquals('RT_Membership-$5',results.get('sku0'));
		System.assertEquals('5',results.get('unitpricedue0'));
		System.assertEquals('Select Your Monthly Donation Amount ($5)',results.get('itemname0'));   
	} // end ConnectDonation test   

	static testMethod void DonationWithExternalCampaignId() {
        
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        Contact TestCtct = ctv.fetchTestContact();
        Campaign TestCamp = ctv.fetchTestCampaign();
    		
	// Create test string, this time with recurring information

string XMLstring = '<?xml version="1.0" encoding="UTF-8"?>';
XMLstring += '<CnPTransactionData><Version>40</Version>';
XMLstring += '<PostedDateTime>2016-12-07 13:40:52</PostedDateTime>';
XMLstring += '<Application><Name>Connect.Forms</Name>';
XMLstring += '<Version>1.5</Version>';
XMLstring += '</Application>';
XMLstring += '<Patron>';
XMLstring += '<BillingInformation><BillingFirstName>Abby</BillingFirstName>';
XMLstring += '<BillingMI></BillingMI>';
XMLstring += '<BillingLastName>Kuranz</BillingLastName>';
XMLstring += '<BillingEmail>akuranz@gmail.com</BillingEmail>';
XMLstring += '<BillingPhone>2626728857</BillingPhone>';
XMLstring += '</BillingInformation>';
XMLstring += '<BillingAddress><BillingAddress1>1487 N Farwell Ave, Apt M</BillingAddress1>';
XMLstring += '<BillingAddress2></BillingAddress2>';
XMLstring += '<BillingAddress3></BillingAddress3>';
XMLstring += '<BillingCity>Milwaukee</BillingCity>';
XMLstring += '<BillingStateProvince>Wisconsin</BillingStateProvince>';
XMLstring += '<BillingPostalCode>53202</BillingPostalCode>';
XMLstring += '<BillingCountryName>United States</BillingCountryName>';
XMLstring += '</BillingAddress>';
XMLstring += '<CustomParameters><Parameter>';
XMLstring += '<Field>SocialComment</Field>';
XMLstring += '<Value></Value>';
XMLstring += '</Parameter>';
XMLstring += '<Parameter>';
XMLstring += '<Field>SocialCommentStatus</Field>';
XMLstring += '<Value>1</Value>';
XMLstring += '</Parameter>';
XMLstring += '</CustomParameters>';
XMLstring += '</Patron>';
XMLstring += '<TransactionDetail>';
XMLstring += '<OrderNumber>1612071340381417740</OrderNumber>';
XMLstring += '<ReceiptNumber></ReceiptNumber>';
XMLstring += '<TransactionID>6164766</TransactionID>';
XMLstring += '<OrderMode>Live</OrderMode>';
XMLstring += '<Tracker></Tracker>';
XMLstring += '<Campaign></Campaign>';
XMLstring += '<TransactionType>Live</TransactionType>';
XMLstring += '<OrganizationID>26913</OrganizationID>';
XMLstring += '<OrganizationName>Milwaukee Riverkeeper</OrganizationName>';
XMLstring += '<CurrencyCode>840</CurrencyCode>';
XMLstring += '<AuthorizationCode>733214</AuthorizationCode>';
XMLstring += '<WindowName>2016 Year End Appeal CnP</WindowName>';
XMLstring += '<WindowId>cd13251e-cd09-4695-9bf8-e659cea16cd7</WindowId>';
XMLstring += '<GatewayTransactionNumber>989733214</GatewayTransactionNumber>';
XMLstring += '<TotalCharge>1.00</TotalCharge>';
XMLstring += '<TotalDue>1.00</TotalDue>';
XMLstring += '<DeductibleCharge>1.00</DeductibleCharge>';
XMLstring += '<DeductibleDue>1.00</DeductibleDue>';
XMLstring += '<DiscountCharge>0.00</DiscountCharge>';
XMLstring += '<DiscountDue>0.00</DiscountDue>';
XMLstring += '<TaxAmountCharge>0.00</TaxAmountCharge>';
XMLstring += '<TaxAmountDue>0.00</TaxAmountDue>';
XMLstring += '<TransactionDiscountCharge>0.00</TransactionDiscountCharge>';
XMLstring += '<TransactionDiscountDue>0.00</TransactionDiscountDue>';
XMLstring += '<TransactionTaxCharge>0.00</TransactionTaxCharge>';
XMLstring += '<TransactionTaxDue>0.00</TransactionTaxDue>';
XMLstring += '<SurCharge>0.00</SurCharge>';
XMLstring += '<ChargAmount>0.18</ChargAmount>';
XMLstring += '<CouponCode></CouponCode>';
XMLstring += '<TransactionDate>2016-12-07 13:40:38</TransactionDate>';
XMLstring += '<TransactionTimeZone>2016-12-07 12:40:38</TransactionTimeZone>';
XMLstring += '<UrlReferrer></UrlReferrer>';
XMLstring += '<VaultGUID>f83bf4e9-3a1d-4172-afc9-89b8398c7543</VaultGUID>';
XMLstring += '<TransactionResult>Authorized</TransactionResult>';
XMLstring += '<PaymentMethod>';
XMLstring += '<PaymentType>Credit Card</PaymentType>';
XMLstring += '<CreditCard>';
XMLstring += '<NameOnCard>Abby Kuranz</NameOnCard>';
XMLstring += '<CardNumber>45357740</CardNumber>';
XMLstring += '<CardName>VISA</CardName>';
XMLstring += '<ExpirationDate>1805</ExpirationDate>';
XMLstring += '</CreditCard>';
XMLstring += '</PaymentMethod>';
XMLstring += '<CampaignList><CampaignNode>';
XMLstring += '<CampaignName>Testcampaign</CampaignName>';
XMLstring += '<CampaignID>36332</CampaignID>';
XMLstring += '<AccountID>26913</AccountID>';
XMLstring += '<CampaignExternalID>'+TestCamp.Id+'</CampaignExternalID>';
XMLstring += '<CampaignScope>Transaction</CampaignScope>';
XMLstring += '</CampaignNode>';
XMLstring += '</CampaignList>';
XMLstring += '<CustomParameters><Parameter>';
XMLstring += '<Field>GiveBigCampaignId</Field>';
XMLstring += '<Value>36327</Value>';
XMLstring += '</Parameter>';
XMLstring += '<Parameter>';
XMLstring += '<Field>PostItID</Field>';
XMLstring += '<Value>0</Value>';
XMLstring += '</Parameter>';
XMLstring += '<Parameter>';
XMLstring += '<Field>PostItAlias</Field>';
XMLstring += '<Value></Value>';
XMLstring += '</Parameter>';
XMLstring += '<Parameter>';
XMLstring += '<Field>PaymentWidgetID</Field>';
XMLstring += '<Value>2783</Value>';
XMLstring += '</Parameter>';
XMLstring += '<Parameter>';
XMLstring += '<Field>Pay09</Field>';
XMLstring += '<Value>Site.20161207.002.004.010</Value>';
XMLstring += '</Parameter>';
XMLstring += '</CustomParameters>';
XMLstring += '</TransactionDetail>';
XMLstring += '<OrderItemList>';
XMLstring += '<OrderItem>';
XMLstring += '<ItemID>0</ItemID>';
XMLstring += '<ItemName>Other</ItemName>';
XMLstring += '<Quantity>1</Quantity>';
XMLstring += '<UnitPriceCharge>1</UnitPriceCharge>';
XMLstring += '<UnitPriceDue>1</UnitPriceDue>';
XMLstring += '<UnitDeductibleCharge>1</UnitDeductibleCharge>';
XMLstring += '<UnitDeductibleDue>1</UnitDeductibleDue>';
XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
XMLstring += '<DiscountCharge>0</DiscountCharge>';
XMLstring += '<DiscountDue>0</DiscountDue>';
XMLstring += '<SKU></SKU>';
XMLstring += '</OrderItem>';
XMLstring += '</OrderItemList>';
XMLstring += '</CnPTransactionData>';
    		
        Map<String, String> parseResults = parseCnPDataXML.parseXML(XMLstring);
		
		
        CnP_PaaS_Bridge__CnPData__c TestData2 = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = XMLstring, 
        CnP_PaaS_Bridge__Order_Number__c = '1207131327206181111');
        insert testdata2;
		
		
        system.debug('Testdata record now contains: '+ testdata2);
        system.debug('testdata.CnP_PaaS__OrderNumber__c is' + testdata2.CnP_PaaS_Bridge__Order_Number__c);
        map<string, string> results = parseCNPDataXML.parseXML(testdata2.CnP_PaaS_Bridge__DataXML__c);
        system.assertEquals('Kuranz', results.get('lastname'));
        system.assertEquals('Connect.Forms', results.get('Application'));
		system.assertEquals(TestCamp.Id, results.get('WGCampaignId')); 
	} // end test
    
	static testMethod void ConnectWithExternalCampaignId() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        Contact TestCtct = ctv.fetchTestContact();
        Campaign TestCamp = ctv.fetchTestCampaign();
    		
	// Create test string, this time with recurring information

string XMLstring = '<?xml version="1.0" encoding="UTF-8"?>';
XMLstring += '<CnPTransactionData><Version>40</Version>';
XMLstring += '<PostedDateTime>2016-12-07 13:40:52</PostedDateTime>';
XMLstring += '<Application><Name>Connect.Forms</Name>';
XMLstring += '<Version>1.5</Version>';
XMLstring += '</Application>';
XMLstring += '<Patron>';
XMLstring += '<BillingInformation><BillingFirstName>Abby</BillingFirstName>';
XMLstring += '<BillingMI></BillingMI>';
XMLstring += '<BillingLastName>Kuranz</BillingLastName>';
XMLstring += '<BillingEmail>akuranz@gmail.com</BillingEmail>';
XMLstring += '<BillingPhone>2626728857</BillingPhone>';
XMLstring += '</BillingInformation>';
XMLstring += '<BillingAddress><BillingAddress1>1487 N Farwell Ave, Apt M</BillingAddress1>';
XMLstring += '<BillingAddress2></BillingAddress2>';
XMLstring += '<BillingAddress3></BillingAddress3>';
XMLstring += '<BillingCity>Milwaukee</BillingCity>';
XMLstring += '<BillingStateProvince>Wisconsin</BillingStateProvince>';
XMLstring += '<BillingPostalCode>53202</BillingPostalCode>';
XMLstring += '<BillingCountryName>United States</BillingCountryName>';
XMLstring += '</BillingAddress>';
XMLstring += '<CustomParameters><Parameter>';
XMLstring += '<Field>SocialComment</Field>';
XMLstring += '<Value></Value>';
XMLstring += '</Parameter>';
XMLstring += '<Parameter>';
XMLstring += '<Field>SocialCommentStatus</Field>';
XMLstring += '<Value>1</Value>';
XMLstring += '</Parameter>';
XMLstring += '</CustomParameters>';
XMLstring += '</Patron>';
XMLstring += '<TransactionDetail>';
XMLstring += '<OrderNumber>1612071340381417740</OrderNumber>';
XMLstring += '<ReceiptNumber></ReceiptNumber>';
XMLstring += '<TransactionID>6164766</TransactionID>';
XMLstring += '<OrderMode>Live</OrderMode>';
XMLstring += '<Tracker></Tracker>';
XMLstring += '<Campaign></Campaign>';
XMLstring += '<TransactionType>Live</TransactionType>';
XMLstring += '<OrganizationID>26913</OrganizationID>';
XMLstring += '<OrganizationName>Milwaukee Riverkeeper</OrganizationName>';
XMLstring += '<CurrencyCode>840</CurrencyCode>';
XMLstring += '<AuthorizationCode>733214</AuthorizationCode>';
XMLstring += '<WindowName>2016 Year End Appeal CnP</WindowName>';
XMLstring += '<WindowId>cd13251e-cd09-4695-9bf8-e659cea16cd7</WindowId>';
XMLstring += '<GatewayTransactionNumber>989733214</GatewayTransactionNumber>';
XMLstring += '<TotalCharge>1.00</TotalCharge>';
XMLstring += '<TotalDue>1.00</TotalDue>';
XMLstring += '<DeductibleCharge>1.00</DeductibleCharge>';
XMLstring += '<DeductibleDue>1.00</DeductibleDue>';
XMLstring += '<DiscountCharge>0.00</DiscountCharge>';
XMLstring += '<DiscountDue>0.00</DiscountDue>';
XMLstring += '<TaxAmountCharge>0.00</TaxAmountCharge>';
XMLstring += '<TaxAmountDue>0.00</TaxAmountDue>';
XMLstring += '<TransactionDiscountCharge>0.00</TransactionDiscountCharge>';
XMLstring += '<TransactionDiscountDue>0.00</TransactionDiscountDue>';
XMLstring += '<TransactionTaxCharge>0.00</TransactionTaxCharge>';
XMLstring += '<TransactionTaxDue>0.00</TransactionTaxDue>';
XMLstring += '<SurCharge>0.00</SurCharge>';
XMLstring += '<ChargAmount>0.18</ChargAmount>';
XMLstring += '<CouponCode></CouponCode>';
XMLstring += '<TransactionDate>2016-12-07 13:40:38</TransactionDate>';
XMLstring += '<TransactionTimeZone>2016-12-07 12:40:38</TransactionTimeZone>';
XMLstring += '<UrlReferrer></UrlReferrer>';
XMLstring += '<VaultGUID>f83bf4e9-3a1d-4172-afc9-89b8398c7543</VaultGUID>';
XMLstring += '<TransactionResult>Authorized</TransactionResult>';
XMLstring += '<PaymentMethod>';
XMLstring += '<PaymentType>Credit Card</PaymentType>';
XMLstring += '<CreditCard>';
XMLstring += '<NameOnCard>Abby Kuranz</NameOnCard>';
XMLstring += '<CardNumber>45357740</CardNumber>';
XMLstring += '<CardName>VISA</CardName>';
XMLstring += '<ExpirationDate>1805</ExpirationDate>';
XMLstring += '</CreditCard>';
XMLstring += '</PaymentMethod>';
XMLstring += '<CampaignList><CampaignNode>';
XMLstring += '<CampaignName>2016 Year End Appeal CnP</CampaignName>';
XMLstring += '<CampaignID>36332</CampaignID>';
XMLstring += '<AccountID>26913</AccountID>';
XMLstring += '<CampaignExternalID>'+TestCamp.Id+'</CampaignExternalID>';
XMLstring += '<CampaignScope>Transaction</CampaignScope>';
XMLstring += '</CampaignNode>';
XMLstring += '</CampaignList>';
XMLstring += '<CustomParameters><Parameter>';
XMLstring += '<Field>GiveBigCampaignId</Field>';
XMLstring += '<Value>36327</Value>';
XMLstring += '</Parameter>';
XMLstring += '<Parameter>';
XMLstring += '<Field>PostItID</Field>';
XMLstring += '<Value>0</Value>';
XMLstring += '</Parameter>';
XMLstring += '<Parameter>';
XMLstring += '<Field>PostItAlias</Field>';
XMLstring += '<Value></Value>';
XMLstring += '</Parameter>';
XMLstring += '<Parameter>';
XMLstring += '<Field>PaymentWidgetID</Field>';
XMLstring += '<Value>2783</Value>';
XMLstring += '</Parameter>';
XMLstring += '<Parameter>';
XMLstring += '<Field>Pay09</Field>';
XMLstring += '<Value>Site.20161207.002.004.010</Value>';
XMLstring += '</Parameter>';
XMLstring += '</CustomParameters>';
XMLstring += '</TransactionDetail>';
XMLstring += '<OrderItemList>';
XMLstring += '<OrderItem>';
XMLstring += '<ItemID>0</ItemID>';
XMLstring += '<ItemName>Other</ItemName>';
XMLstring += '<Quantity>1</Quantity>';
XMLstring += '<UnitPriceCharge>1</UnitPriceCharge>';
XMLstring += '<UnitPriceDue>1</UnitPriceDue>';
XMLstring += '<UnitDeductibleCharge>1</UnitDeductibleCharge>';
XMLstring += '<UnitDeductibleDue>1</UnitDeductibleDue>';
XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
XMLstring += '<DiscountCharge>0</DiscountCharge>';
XMLstring += '<DiscountDue>0</DiscountDue>';
XMLstring += '<SKU></SKU>';
XMLstring += '</OrderItem>';
XMLstring += '</OrderItemList>';
XMLstring += '</CnPTransactionData>';

        Map<String, String> parseResults = parseCnPDataXML.parseXML(XMLstring);
		
		
        CnP_PaaS_Bridge__CnPData__c TestData2 = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = XMLstring, 
        CnP_PaaS_Bridge__Order_Number__c = '1207131327206181111');
        insert testdata2;
		
		
        system.debug('Testdata record now contains: '+ testdata2);
        system.debug('testdata.CnP_PaaS__OrderNumber__c is' + testdata2.CnP_PaaS_Bridge__Order_Number__c);
        map<string, string> results = parseCNPDataXML.parseXML(testdata2.CnP_PaaS_Bridge__DataXML__c);
        system.assertEquals('Kuranz', results.get('lastname'));
        system.assertEquals('Connect.Forms', results.get('Application'));
		system.assertEquals(TestCamp.Id, results.get('WGCampaignId')); 
	} // end test

    	static testMethod void CustomPaymentCashTest() {
            
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        Contact TestCtct = ctv.fetchTestContact();
        Campaign TestCamp = ctv.fetchTestCampaign();
    		
	// Create test string, this time with recurring information

string XMLstring = '<?xml version="1.0" encoding="UTF-8"?>';
XMLstring += '<CnPTransactionData><Version>40</Version>';
XMLstring += '<PostedDateTime>2017-06-11 12:15:37</PostedDateTime>';
XMLstring += '<Application><ID>Android</ID>';
XMLstring += '<Name>Swiper1</Name>';
XMLstring += '<Version>7.001.022</Version>';
XMLstring += '</Application>';
XMLstring += '<Patron>';
XMLstring += '<BillingInformation><BillingFirstName>Oona</BillingFirstName>';
XMLstring += '<BillingMI></BillingMI>';
XMLstring += '<BillingLastName>Belich</BillingLastName>';
XMLstring += '<BillingEmail>obleich@ramapo.edu</BillingEmail>';
XMLstring += '<BillingPhone></BillingPhone>';
XMLstring += '</BillingInformation>';
XMLstring += '<BillingAddress><BillingAddress1></BillingAddress1>';
XMLstring += '<BillingAddress2></BillingAddress2>';
XMLstring += '<BillingAddress3></BillingAddress3>';
XMLstring += '<BillingCity></BillingCity>';
XMLstring += '<BillingStateProvince></BillingStateProvince>';
XMLstring += '<BillingPostalCode>07410</BillingPostalCode>';
XMLstring += '<BillingCountryName></BillingCountryName>';
XMLstring += '</BillingAddress>';
XMLstring += '</Patron>';
XMLstring += '<TransactionDetail>';
XMLstring += '<OrderNumber>21907-170611121529700</OrderNumber>';
XMLstring += '<ReceiptNumber></ReceiptNumber>';
XMLstring += '<TransactionID>7069326</TransactionID>';
XMLstring += '<OrderMode>Live</OrderMode>';
XMLstring += '<Tracker></Tracker>';
XMLstring += '<Campaign></Campaign>';
XMLstring += '<ConnectCampaignAlias>OverpeckPaddleCenter</ConnectCampaignAlias>';
XMLstring += '<TransactionType>Live</TransactionType>';
XMLstring += '<OrganizationID>21907</OrganizationID>';
XMLstring += '<OrganizationName>Hackensack Riverkeeper, Inc.</OrganizationName>';
XMLstring += '<CurrencyCode>840</CurrencyCode>';
XMLstring += '<AuthorizationCode></AuthorizationCode>';
XMLstring += '<WindowName></WindowName>';
XMLstring += '<WindowId></WindowId>';
XMLstring += '<GatewayTransactionNumber></GatewayTransactionNumber>';
XMLstring += '<TotalCharge>30.00</TotalCharge>';
XMLstring += '<TotalDue>30.00</TotalDue>';
XMLstring += '<DeductibleCharge>0.00</DeductibleCharge>';
XMLstring += '<DeductibleDue>0.00</DeductibleDue>';
XMLstring += '<DiscountCharge>0.00</DiscountCharge>';
XMLstring += '<DiscountDue>0.00</DiscountDue>';
XMLstring += '<TaxAmountCharge>0.00</TaxAmountCharge>';
XMLstring += '<TaxAmountDue>0.00</TaxAmountDue>';
XMLstring += '<TransactionDiscountCharge>0.00</TransactionDiscountCharge>';
XMLstring += '<TransactionDiscountDue>0.00</TransactionDiscountDue>';
XMLstring += '<TransactionTaxCharge>0.00</TransactionTaxCharge>';
XMLstring += '<TransactionTaxDue>0.00</TransactionTaxDue>';
XMLstring += '<SurCharge>0.00</SurCharge>';
XMLstring += '<ChargAmount>0.00</ChargAmount>';
XMLstring += '<CouponCode></CouponCode>';
XMLstring += '<TransactionDate>2017-06-11 12:15:29</TransactionDate>';
XMLstring += '<TransactionTimeZone>2017-06-11 12:15:29</TransactionTimeZone>';
XMLstring += '<UrlReferrer>Swiper1-Android 4.4.2-7.001.022-c4:54:44:af:45:e8-paddleoverpeck@gmail.com</UrlReferrer>';
XMLstring += '<VaultGUID>a394b07a-4e08-4128-8503-559df3537bfc</VaultGUID>';
XMLstring += '<PaymentMethod>';
XMLstring += '<PaymentType>CustomPaymentType</PaymentType>';
XMLstring += '<CustomPaymentType>';
XMLstring += '<CustomPaymentName>Cash</CustomPaymentName>';
XMLstring += '<CustomPaymentNumber></CustomPaymentNumber>';
XMLstring += '</CustomPaymentType>';
XMLstring += '</PaymentMethod>';
XMLstring += '<CampaignList><CampaignNode>';
XMLstring += '<CampaignName>Testcampaign</CampaignName>';
XMLstring += '<CampaignID>42040</CampaignID>';
XMLstring += '<AccountID>21907</AccountID>';
XMLstring += '<CampaignExternalID>'+TestCamp.Id+'</CampaignExternalID>';
XMLstring += '<CampaignScope>Transaction</CampaignScope>';
XMLstring += '</CampaignNode>';
XMLstring += '</CampaignList>';
XMLstring += '</TransactionDetail>';
XMLstring += '<OrderItemList>';
XMLstring += '<OrderItem>';
XMLstring += '<ItemID>1</ItemID>';
XMLstring += '<ItemName>Overpeck Kayak Center Paddler</ItemName>';
XMLstring += '<Quantity>2</Quantity>';
XMLstring += '<UnitPriceCharge>15</UnitPriceCharge>';
XMLstring += '<UnitPriceDue>15</UnitPriceDue>';
XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge>';
XMLstring += '<UnitDeductibleDue>0</UnitDeductibleDue>';
XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
XMLstring += '<DiscountCharge>0</DiscountCharge>';
XMLstring += '<DiscountDue>0</DiscountDue>';
XMLstring += '<SKU></SKU>';
XMLstring += '</OrderItem>';
XMLstring += '</OrderItemList>';
XMLstring += '</CnPTransactionData>';
    		
        Map<String, String> parseResults = parseCnPDataXML.parseXML(XMLstring);		
        CnP_PaaS_Bridge__CnPData__c TestData2 = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = XMLstring, 
        CnP_PaaS_Bridge__Order_Number__c = '1207131327206181111');
        insert testdata2;
				
        system.debug('Testdata record now contains: '+ testdata2);
        system.debug('testdata.CnP_PaaS__OrderNumber__c is' + testdata2.CnP_PaaS_Bridge__Order_Number__c);
        map<string, string> results = parseCNPDataXML.parseXML(testdata2.CnP_PaaS_Bridge__DataXML__c);
        system.assertEquals('Belich', results.get('lastname'));
        system.assertEquals('Swiper1', results.get('Application'));
        system.assertEquals('Android', results.get('ApplicationId'));
		system.assertEquals(TestCamp.Id, results.get('WGCampaignId')); 
	} // end test

}