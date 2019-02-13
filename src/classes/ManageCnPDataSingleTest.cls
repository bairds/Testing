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
@isTest
private class ManageCnPDataSingleTest {

// single transaction test with existing contact, campaign specified
    @isTest
    static void SingleContactTransactionCampaignInOrderItemTest() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Lead TestLead = ctv.fetchTestLead();
        system.assertEquals('TestLead', testLead.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        TestCamp.name = 'Reviving the Dream (2017)';
        update TestCamp;
		createCustomSettings CCS = new createCustomSettings();
            CCS.createCustomSettings();

        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c 
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);
        
string XMLstring = '<?xml version="1.0" encoding="UTF-8"?>';
XMLstring += '<CnPTransactionData><Version>40</Version>';
XMLstring += '<PostedDateTime>2017-03-28 12:47:32</PostedDateTime>';
XMLstring += '<Patron>';
XMLstring += '<BillingInformation><BillingFirstName>Test</BillingFirstName>';
XMLstring += '<BillingMI></BillingMI>';
XMLstring += '<BillingLastName>TestLead</BillingLastName>';
XMLstring += '<BillingEmail>testlead@dontbotherme.org</BillingEmail>';
XMLstring += '<BillingPhone>414-312-3507</BillingPhone>';
XMLstring += '</BillingInformation>';
XMLstring += '<BillingAddress><BillingAddress1>2972 S Wentworth Ave</BillingAddress1>';
XMLstring += '<BillingAddress2></BillingAddress2>';
XMLstring += '<BillingAddress3></BillingAddress3>';
XMLstring += '<BillingCity>Milwaukee</BillingCity>';
XMLstring += '<BillingStateProvince>Wisconsin</BillingStateProvince>';
XMLstring += '<BillingPostalCode>53207</BillingPostalCode>';
XMLstring += '<BillingCountryName>United States</BillingCountryName>';
XMLstring += '</BillingAddress>';
XMLstring += '';
XMLstring += '</Patron>';
XMLstring += '<TransactionDetail>';
XMLstring += '<OrderNumber>1703281247192266546</OrderNumber>';
XMLstring += '<ReceiptNumber></ReceiptNumber>';
XMLstring += '<TransactionID>6702087</TransactionID>';
XMLstring += '<OrderMode>Test</OrderMode>';
XMLstring += '<Tracker></Tracker>';
XMLstring += '<Campaign>Reviving the Dream (2017)</Campaign>';
XMLstring += '<ConnectCampaignAlias></ConnectCampaignAlias>';
XMLstring += '<TransactionType>Test</TransactionType>';
XMLstring += '<OrganizationID>29024</OrganizationID>';
XMLstring += '<OrganizationName>Diverse and Resilient</OrganizationName>';
XMLstring += '<CurrencyCode>840</CurrencyCode>';
XMLstring += '<AuthorizationCode>9f0630</AuthorizationCode>';
XMLstring += '<WindowName>Reviving the Dream 2017</WindowName>';
XMLstring += '<WindowId>126411</WindowId>';
XMLstring += '<GatewayTransactionNumber>24fb7302-8c6b-4030-94e0-ccd128a2b788</GatewayTransactionNumber>';
XMLstring += '<TotalCharge>100.00</TotalCharge>';
XMLstring += '<TotalDue>100.00</TotalDue>';
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
XMLstring += '<ChargAmount>3.10</ChargAmount>';
XMLstring += '<CouponCode></CouponCode>';
XMLstring += '<TransactionDate>2017-03-28 12:47:00</TransactionDate>';
XMLstring += '<TransactionTimeZone>2017-03-28 11:47:00</TransactionTimeZone>';
XMLstring += '<UrlReferrer>https://www.diverseandresilient.org/reviving/</UrlReferrer>';
XMLstring += '<VaultGUID></VaultGUID>';
XMLstring += '<TransactionResult>Authorized</TransactionResult>';
XMLstring += '<PaymentMethod>';
XMLstring += '<PaymentType>Credit Card</PaymentType>';
XMLstring += '<CreditCard>';
XMLstring += '<NameOnCard>MORGAN J TILLEMAN</NameOnCard>';
XMLstring += '<CardNumber>41476546</CardNumber>';
XMLstring += '<CardName>VISA</CardName>';
XMLstring += '<ExpirationDate>1908</ExpirationDate>';
XMLstring += '</CreditCard>';
XMLstring += '</PaymentMethod>';
XMLstring += '';
XMLstring += '</TransactionDetail>';
XMLstring += '<CustomFieldList>';
XMLstring += '<CustomField>';
XMLstring += '<FieldName>In honor of:</FieldName>';
XMLstring += '<FieldValue></FieldValue>';
XMLstring += '</CustomField>';
XMLstring += '<CustomField>';
XMLstring += '<FieldName>What is your meal preference?</FieldName>';
XMLstring += '<FieldValue>Chicken Entrée</FieldValue>';
XMLstring += '</CustomField>';
XMLstring += '<CustomField>';
XMLstring += '<FieldName>What is your guests name?</FieldName>';
XMLstring += '<FieldValue></FieldValue>';
XMLstring += '</CustomField>';
XMLstring += '<CustomField>';
XMLstring += '<FieldName>What is your guests name?</FieldName>';
XMLstring += '<FieldValue></FieldValue>';
XMLstring += '</CustomField>';
XMLstring += '<CustomField>';
XMLstring += '<FieldName>What is your guests name?</FieldName>';
XMLstring += '<FieldValue></FieldValue>';
XMLstring += '</CustomField>';
XMLstring += '<CustomField>';
XMLstring += '<FieldName>If this is your first donation or payment to our organization, please tell us how you first heard about us.</FieldName>';
XMLstring += '<FieldValue>Web</FieldValue>';
XMLstring += '</CustomField>';
XMLstring += '<CustomField>';
XMLstring += '<FieldName>What is your guests name?</FieldName>';
XMLstring += '<FieldValue></FieldValue>';
XMLstring += '</CustomField>';
XMLstring += '<CustomField>';
XMLstring += '<FieldName>What is your guests name?</FieldName>';
XMLstring += '<FieldValue></FieldValue>';
XMLstring += '</CustomField>';
XMLstring += '<CustomField>';
XMLstring += '<FieldName>What is your guests name?</FieldName>';
XMLstring += '<FieldValue></FieldValue>';
XMLstring += '</CustomField>';
XMLstring += '<CustomField>';
XMLstring += '<FieldName>What is your guests name?</FieldName>';
XMLstring += '<FieldValue></FieldValue>';
XMLstring += '</CustomField>';
XMLstring += '</CustomFieldList>';
XMLstring += '<OrderItemList>';
XMLstring += '<OrderItem>';
XMLstring += '<ItemID>0</ItemID>';
XMLstring += '<ItemName>Individual Ticket</ItemName>';
XMLstring += '<Quantity>1</Quantity>';
XMLstring += '<UnitPriceCharge>100</UnitPriceCharge>';
XMLstring += '<UnitPriceDue>100</UnitPriceDue>';
XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge>';
XMLstring += '<UnitDeductibleDue>0</UnitDeductibleDue>';
XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
XMLstring += '<DiscountCharge>0</DiscountCharge>';
XMLstring += '<DiscountDue>0</DiscountDue>';
XMLstring += '<SKU>Event</SKU>';
XMLstring += '</OrderItem>';
XMLstring += '</OrderItemList>';
XMLstring += '</CnPTransactionData>';

      
  // create new CnP_Data record
        CnP_PaaS_Bridge__CnPData__c TestData = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = XMLstring,
        CnP_PaaS_Bridge__Order_Number__c = '1207181600564311111',
        CnP_PaaS_Bridge__StatusID__c = 1);
        insert testdata;
        system.debug('Testdata record now contains: '+ testdata);   
        CnP_PaaS_Bridge__CnPData__c TestDataUpdated = [select id, CnP_PaaS_Bridge__DataXML__c from CnP_PaaS_Bridge__CnPData__c
            where id = :testdata.id];
        
        //Has TestData credit card # and expiration date been masked?
        Dom.Document docx = new Dom.Document();
        docx.load(TestDataUpdated.CnP_PaaS_Bridge__DataXML__c);
           
        dom.XmlNode xroot = docx.getrootelement() ;
        dom.XmlNode xr2 = xroot.getchildelement('TransactionDetail', null) ; //Level 2
        dom.XmlNode xr2paymentmethod = xr2.getchildelement('PaymentMethod', null) ; //
        dom.XmlNode xr2paymentmethodCC = xr2paymentmethod.getchildelement('CreditCard', null) ; //
        dom.XmlNode xr2paymentmethodCCName = xr2paymentmethodCC.getchildelement('CardName', null) ; //
        dom.XmlNode xr2paymentmethodCCNr = xr2paymentmethodCC.getchildelement('CardNumber', null) ; //
        dom.XmlNode xr2paymentmethodCCExp = xr2paymentmethodCC.getchildelement('ExpirationDate', null) ; //
            system.debug('xr2paymentmethodCCName.getText() is ' + xr2paymentmethodCCName.getText());
            system.debug('xr2paymentmethodCCExp.gettext() is ' + xr2paymentmethodCCExp.gettext());
        system.assertEquals(xr2paymentmethodCCNr.gettext(), '41476546');
        
        // Have one new donations been created?
        system.debug('TestAcct.id is ' + TestAcct.ID);
        Payments = [select id,Name,CampaignID,Campaign.Name,Amount,AccountID,Contact__c, Attendee__c 
            from Opportunity where campaignid = :TestCamp.id];
        system.debug(Payments);
        system.AssertEquals(1,Payments.size());
        system.AssertEquals(100,Payments[0].amount);
        //system.AssertEquals(TestAcct.ID, Payments[0].AccountId);
        system.AssertEquals(TestCamp.Name, Payments[0].Campaign.Name);
        system.AssertEquals(TestCamp.ID,Payments[0].CampaignId);
      //  system.AssertEquals('Event Attendee-Tester TestContact for Testcampaign paid on ' + String.valueOf(System.today()),Payments[0].Name);
      //  System.assertEquals('Tester TestContact',Payments[0].attendee__c);
        Contact checkContact = [select id, lastname, mailingStreet, mailingPostalCode, leadsource,
            account.billingCity, account.ShippingState, account.dear__c, account.addressee__c 
            from Contact where id = :Payments[0].contact__c];
        system.AssertEquals('TestLead',checkContact.lastname);
        system.AssertEquals('Web',checkContact.leadsource);
    }
   
}