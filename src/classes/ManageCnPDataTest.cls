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
private class ManageCnPDataTest {


/*    @testSetup static void SetupData(){
        createCustomSettings.createCustomSettings();
}*/

// single transaction test with existing contact, campaign specified
    @isTest
    static void SingleContactTransactionCampaignInOrderItemTest() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        system.assertEquals('Testcampaign', testCamp.name);

        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c 
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);
        
        string XMLstring ='<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Tester</BillingFirstName><BillingMI></BillingMI>';
        XMLstring += '<BillingLastName>TestContact</BillingLastName><BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
        XMLstring += '<BillingPhone>333</BillingPhone></BillingInformation><BillingAddress><BillingAddress1>Test Street</BillingAddress1>';
        XMLstring += '<BillingAddress2></BillingAddress2><BillingAddress3></BillingAddress3><BillingCity>Test City</BillingCity>';
        XMLstring += '<BillingStateProvince>Alabama</BillingStateProvince><BillingPostalCode>33333</BillingPostalCode>';
        XMLstring += '<BillingCountryName>United States of America</BillingCountryName></BillingAddress></Patron><TransactionDetail>';
        XMLstring += '<OrderNumber>1207131327206181111</OrderNumber><Tracker>TestTracker</Tracker><Campaign>Testcampaign</Campaign>';
        XMLstring += '<WindowName>Wild and Scenic Film Fest</WindowName><WindowId>55337</WindowId><TotalCharge>14.00</TotalCharge><ChargAmount>0.70</ChargAmount><TransactionDate>2012-07-13 13:27:00</TransactionDate><TransactionTimeZone>2012-07-13 13:27:00</TransactionTimeZone><TransactionResult>Authorized</TransactionResult><UrlReferrer>http://leadgreen.org/wordpress/</UrlReferrer><PaymentMethod><PaymentType>Credit Card</PaymentType><CreditCard>';
        XMlstring += '<NameOnCard>Test16 Tester</NameOnCard><CardNumber>41111111</CardNumber><CardName>VISA</CardName>';
        XMlstring += '<ExpirationDate>1208</ExpirationDate></CreditCard></PaymentMethod></TransactionDetail>';
        XMLstring += '<OrderItemList>';
        XMLstring += '<OrderItem>';
        XMLstring += '<ItemID>1</ItemID>';
        XMLstring += '<ItemName>Event Attendee-Tester TestContact</ItemName>';
        XMLstring += '<Quantity>1</Quantity>';
        XMLstring += '<UnitPriceCharge>14</UnitPriceCharge>';
        XMLstring += '<UnitPriceDue>14</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge>';
        XMLstring += '<UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
        XMLstring += '<DiscountCharge>0</DiscountCharge>';
        XMLstring += '<DiscountDue>0</DiscountDue>';
        XMLstring += '<SKU>Event</SKU>';
        XMLstring += '<CampaignName>Testcampaign</CampaignName>';
        XMLstring += '</OrderItem>';

        XMLstring += '</OrderItemList></CnPTransactionData>';

      
  // create new CnP_Data record
        CnP_PaaS_Bridge__CnPData__c TestData = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = XMLstring,
        CnP_PaaS_Bridge__Order_Number__c = '1207181600564311111',
        CnP_PaaS_Bridge__StatusID__c = 1);
        insert testdata;
        system.debug('Testdata record now contains: '+ testdata);
        // Capture errors
        List<WG_Error_Log__c> ErrorLogs = [SELECT Category__c, Description__c, Error_Level__c, Status_Code__c from WG_Error_Log__c];
        system.assertEquals(0,ErrorLogs.size(),'Error inserting CnP testdata which generated a WG_Error_Log ');
        if (ErrorLogs.size()>=0) system.debug('On line 71 inserted testdata, which generated an error: '+ErrorLogs);
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
        system.assertEquals(xr2paymentmethodCCNr.gettext(), '41111111');
        
        // Have one new donations been created?
        system.debug('TestAcct.id is ' + TestAcct.ID);
        Payments = [select id,Name,CampaignID,Campaign.Name,Amount,AccountID,Contact__c, Attendee__c
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);
        system.AssertEquals(1,Payments.size());
        system.AssertEquals(14,Payments[0].amount);
        system.AssertEquals(TestAcct.ID, Payments[0].AccountId);
        system.AssertEquals(TestCtct.ID, Payments[0].Contact__c);
        system.AssertEquals('Testcampaign', Payments[0].Campaign.Name);
        system.AssertEquals(TestCamp.ID,Payments[0].CampaignId);
        system.AssertEquals('Event Attendee-Tester TestContact for Testcampaign paid on ' + String.valueOf(System.today()),Payments[0].Name);
        System.assertEquals('Tester TestContact',Payments[0].attendee__c);
        Contact checkContact = [select id, lastname, mailingStreet, mailingPostalCode, 
            account.billingCity, account.ShippingState, account.dear__c, account.addressee__c 
            from Contact where id = :Payments[0].contact__c];
        system.AssertEquals('TestContact',checkContact.lastname);
        System.assertEquals('Test Street',checkContact.mailingStreet);
        System.assertEquals('33333', checkContact.mailingPostalCode);
        System.assertEquals('Test Street',[select id, MailingStreet from contact where id = :TestCtct.id].mailingStreet);
    }

// single transaction test with existing contact, campaign specified, 2 custom questions
    @isTest
    static void SingleContactTransactionsCustomQuestionsTest() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        system.assertEquals('Testcampaign', testCamp.name);

        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c 
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);

        
        string XMLstring ='<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Tester</BillingFirstName><BillingMI></BillingMI>';
        XMLstring += '<BillingLastName>TestContact</BillingLastName><BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
        XMLstring += '<BillingPhone>333</BillingPhone></BillingInformation><BillingAddress><BillingAddress1>Test Street</BillingAddress1>';
        XMLstring += '<BillingAddress2></BillingAddress2><BillingAddress3></BillingAddress3><BillingCity>Test City</BillingCity>';
        XMLstring += '<BillingStateProvince>Alabama</BillingStateProvince><BillingPostalCode>33333</BillingPostalCode>';
        XMLstring += '<BillingCountryName>United States of America</BillingCountryName></BillingAddress></Patron>'; 
            XMLstring +='<CustomFieldList>';
            XMLstring +='<CustomField>';
            XMLstring +='<FieldName>GiftMember</FieldName><FieldValue>Gift Membership Recipient</FieldValue>';
            XMLstring +='</CustomField>';
            XMLstring +='<CustomField>';
            XMLstring +='<FieldName>InHonorOf</FieldName><FieldValue>Person Memorialized</FieldValue>';
            XMLstring +='</CustomField>'; 
            XMLstring +='</CustomFieldList>'; 
            XMLstring +='<TransactionDetail>';  
        XMLstring += '<OrderNumber>1207131327206181111</OrderNumber><Tracker>TestTracker</Tracker><Campaign>Testcampaign</Campaign>';
        XMLstring += '<WindowName>Wild and Scenic Film Fest</WindowName><WindowId>55337</WindowId><TotalCharge>14.00</TotalCharge><ChargAmount>0.70</ChargAmount><TransactionDate>2012-07-13 13:27:00</TransactionDate><TransactionTimeZone>2012-07-13 13:27:00</TransactionTimeZone><TransactionResult>Authorized</TransactionResult><UrlReferrer>http://leadgreen.org/wordpress/</UrlReferrer><PaymentMethod><PaymentType>Credit Card</PaymentType><CreditCard>';
        XMlstring += '<NameOnCard>Test16 Tester</NameOnCard><CardNumber>41111111</CardNumber><CardName>VISA</CardName>';
        XMlstring += '<ExpirationDate>1208</ExpirationDate></CreditCard></PaymentMethod></TransactionDetail>';
        XMLstring += '<OrderItemList>';
        XMLstring += '<OrderItem>';
        XMLstring += '<ItemID>1</ItemID>';
        XMLstring += '<ItemName>Item Name</ItemName>';
        XMLstring += '<Quantity>1</Quantity>';
        XMLstring += '<UnitPriceCharge>14</UnitPriceCharge>';
        XMLstring += '<UnitPriceDue>14</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge>';
        XMLstring += '<UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
        XMLstring += '<DiscountCharge>0</DiscountCharge>';
        XMLstring += '<DiscountDue>0</DiscountDue>';
        XMLstring += '<SKU>Event</SKU>';
        XMLstring += '<CampaignName>Testcampaign</CampaignName>';
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
        system.assertEquals(xr2paymentmethodCCNr.gettext(), '41111111');
        
        // Have one new donations been created?
        system.debug('TestAcct.id is ' + TestAcct.ID);
        Payments = [select id,Name,CampaignID,Amount,AccountID,Contact__c,CustomQuestion1__c,CustomQuestion2__c,
            CustomQuestion3__c,CustomAnswer1__c,CustomAnswer2__c,CustomAnswer3__c
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);
        system.AssertEquals(1,Payments.size());
        //system.AssertEquals(14,Payments[0].amount);
        system.AssertEquals(TestAcct.ID, Payments[0].AccountId);
        system.AssertEquals(TestCtct.ID, Payments[0].Contact__c);
        system.AssertEquals(TestCamp.ID,Payments[0].CampaignId);
        System.assertEquals('GiftMember',Payments[0].CustomQuestion1__c);
        System.assertEquals('Gift Membership Recipient',Payments[0].CustomAnswer1__c);
        system.AssertEquals(Payments[0].Name.contains('Event Attendee'),false);
        System.assertEquals('InHonorOf',Payments[0].CustomQuestion2__c);
        System.assertEquals('Person Memorialized',Payments[0].CustomAnswer2__c);
        
        Contact checkContact = [select id, lastname, mailingStreet, mailingPostalCode, 
            account.billingCity, account.ShippingState, account.dear__c, account.addressee__c 
            from Contact where id = :Payments[0].contact__c];
        system.AssertEquals('TestContact',checkContact.lastname);
        System.assertEquals('Test Street',checkContact.mailingStreet);
        System.assertEquals('33333', checkContact.mailingPostalCode);
        System.assertEquals('Test Street',[select id, MailingStreet from contact where id = :TestCtct.id].mailingStreet);
    }
    
    
// single transaction test with existing contact, campaign specified
    @isTest
    static void SingleContactTransactionMembershipTest() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        system.assertEquals('Testcampaign', testCamp.name);

        
        string XMLstring ='<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Tester</BillingFirstName><BillingMI></BillingMI>';
        XMLstring += '<BillingLastName>TestContact</BillingLastName><BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
        XMLstring += '<BillingPhone>333</BillingPhone></BillingInformation><BillingAddress><BillingAddress1>lkj;</BillingAddress1>';
        XMLstring += '<BillingAddress2></BillingAddress2><BillingAddress3></BillingAddress3><BillingCity>;lkj</BillingCity>';
        XMLstring += '<BillingStateProvince>Alabama</BillingStateProvince><BillingPostalCode>33333</BillingPostalCode>';
        XMLstring += '<BillingCountryName>United States of America</BillingCountryName></BillingAddress></Patron><TransactionDetail>';
        XMLstring += '<OrderNumber>1207131327206181111</OrderNumber><Tracker>TestTracker</Tracker><Campaign>Testcampaign</Campaign>';
        XMLstring += '<WindowName>Wild and Scenic Film Fest</WindowName><WindowId>55337</WindowId><TotalCharge>14.00</TotalCharge><ChargAmount>0.70</ChargAmount><TransactionDate>2012-07-13 13:27:00</TransactionDate><TransactionTimeZone>2012-07-13 13:27:00</TransactionTimeZone><TransactionResult>Authorized</TransactionResult><UrlReferrer>http://leadgreen.org/wordpress/</UrlReferrer><PaymentMethod><PaymentType>Credit Card</PaymentType><CreditCard>';
        XMlstring += '<NameOnCard>Test16 Tester</NameOnCard><CardNumber>41111111</CardNumber><CardName>VISA</CardName>';
        XMlstring += '<ExpirationDate>1208</ExpirationDate></CreditCard></PaymentMethod></TransactionDetail>';
        XMLstring += '<OrderItemList>';
        XMLstring += '<OrderItem>';
        XMLstring += '<ItemID>1</ItemID>';
        XMLstring += '<ItemName>Dinner Attendee-Baird Straughan</ItemName>';
        XMLstring += '<Quantity>1</Quantity>';
        XMLstring += '<UnitPriceCharge>14</UnitPriceCharge>';
        XMLstring += '<UnitPriceDue>14</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge>';
        XMLstring += '<UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
        XMLstring += '<DiscountCharge>0</DiscountCharge>';
        XMLstring += '<DiscountDue>0</DiscountDue>';
        XMLstring += '<SKU>Event</SKU>';
        XMLstring += '<CampaignName>Testcampaign</CampaignName>';
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
        system.assertEquals(xr2paymentmethodCCNr.gettext(), '41111111');
        
        // Have one new donations been created?
        system.debug('TestAcct.id is ' + TestAcct.ID);
        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c,Name 
            from Opportunity where Accountid = :TestAcct.Id];
        system.AssertEquals(1,Payments.size());
        system.AssertEquals(14,Payments[0].amount);
        system.AssertEquals(TestAcct.ID, Payments[0].AccountId);
        system.AssertEquals(TestCtct.ID, Payments[0].Contact__c);
        system.AssertEquals(TestCamp.ID,Payments[0].CampaignId);
        system.AssertEquals('Dinner Attendee-Baird Straughan for Testcampaign paid on ' + String.valueOf(System.today()),Payments[0].Name);

    }

// single transaction test with existing contact, no campaign specified
    static testmethod void SingleTransactionNoCampaignTest() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        Contact TestCtct = ctv.fetchTestContact();
        Campaign TestCamp = ctv.fetchTestcampaign();
        
// create new CnP_Data record        
        string XMLstring ='<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Tester</BillingFirstName><BillingMI></BillingMI>';
        XMLstring += '<BillingLastName>TestContact</BillingLastName><BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
        XMLstring += '<BillingPhone>333</BillingPhone></BillingInformation><BillingAddress><BillingAddress1>lkj;</BillingAddress1>';
        XMLstring += '<BillingAddress2></BillingAddress2><BillingAddress3></BillingAddress3><BillingCity>;lkj</BillingCity>';
        XMLstring += '<BillingStateProvince>Alabama</BillingStateProvince><BillingPostalCode>33333</BillingPostalCode>';
        XMLstring += '<BillingCountryName>United States of America</BillingCountryName></BillingAddress></Patron><TransactionDetail>';
        XMLstring += '<OrderNumber>1207131327206181111</OrderNumber><Tracker>TestTracker</Tracker><Campaign></Campaign>';
        XMLstring += '<WindowName>Wild and Scenic Film Fest</WindowName><WindowId>55337</WindowId><TotalCharge>14.00</TotalCharge><ChargAmount>0.70</ChargAmount><TransactionDate>2012-07-13 13:27:00</TransactionDate><TransactionTimeZone>2012-07-13 13:27:00</TransactionTimeZone><TransactionResult>Authorized</TransactionResult><UrlReferrer>http://leadgreen.org/wordpress/</UrlReferrer><PaymentMethod><PaymentType>Credit Card</PaymentType><CreditCard>';
        XMlstring += '<NameOnCard>Test16 Tester</NameOnCard><CardNumber>41111111</CardNumber><CardName>VISA</CardName>';
        XMlstring += '<ExpirationDate>1208</ExpirationDate></CreditCard></PaymentMethod></TransactionDetail>';
        XMLstring += '<OrderItemList>';
        XMLstring += '<OrderItem>';
        XMLstring += '<ItemID>1</ItemID>';
        XMLstring += '<ItemName>Event Attendee-Baird straughan</ItemName>';
        XMLstring += '<Quantity>1</Quantity>';
        XMLstring += '<UnitPriceCharge>14</UnitPriceCharge>';
        XMLstring += '<UnitPriceDue>14</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge>';
        XMLstring += '<UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
        XMLstring += '<DiscountCharge>0</DiscountCharge>';
        XMLstring += '<DiscountDue>0</DiscountDue>';
        XMLstring += '<SKU>Event</SKU>';
        XMLstring += '<CampaignName></CampaignName>';
        XMLstring += '</OrderItem>';
        XMLstring += '</OrderItemList></CnPTransactionData>';

        CnP_PaaS_Bridge__CnPData__c TestData = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = XMLstring,
        CnP_PaaS_Bridge__Order_Number__c = '1207181600564311111',
        CnP_PaaS_Bridge__StatusID__c = 1);
        insert testdata;
        system.debug('Testdata record now contains: '+ testdata);         

        // Have one new donations been created?
        system.debug('TestAcct.id is ' + TestAcct.ID);
        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c 
            from Opportunity where Accountid = :TestAcct.Id];
        system.AssertEquals(1,Payments.size());
        system.AssertEquals(14,Payments[0].amount);
        system.AssertEquals(TestAcct.ID, Payments[0].AccountId);
        system.AssertEquals(TestCtct.ID, Payments[0].Contact__c);
        system.AssertEquals('Generic CnP Campaign',[select name from Campaign where id = :Payments[0].CampaignId].name);
    }

//Batch transaction test with existing contacts, campaign specified    
        @isTest
        static void BatchCnPDataTest() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        Contact TestCtct = ctv.fetchTestContact();
        Campaign TestCamp = ctv.fetchTestcampaign();
        
// create 5 new CnP_Data record        
        list<CnP_PaaS_Bridge__CnPData__c> TestDataList = new list<CnP_PaaS_Bridge__CnPData__c>();
        for (integer x = 0; x<5; x++) {
        string XMLstring ='<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><Patron><BillingInformation><BillingFirstName>Tester</BillingFirstName><BillingMI></BillingMI><BillingLastName>TestContact</BillingLastName><BillingEmail>testcontact@dontbotherme.org</BillingEmail><BillingPhone>333</BillingPhone></BillingInformation><BillingAddress><BillingAddress1>lkj;</BillingAddress1><BillingAddress2></BillingAddress2><BillingAddress3></BillingAddress3><BillingCity>;lkj</BillingCity><BillingStateProvince>Alabama</BillingStateProvince><BillingPostalCode>33333</BillingPostalCode><BillingCountryName>United States of America</BillingCountryName></BillingAddress></Patron><TransactionDetail><OrderNumber>1207131327206181111</OrderNumber><Tracker>TestTracker</Tracker><Campaign></Campaign><WindowName>Wild and Scenic Film Fest</WindowName><WindowId>55337</WindowId><TotalCharge>14.00</TotalCharge><ChargAmount>0.70</ChargAmount><TransactionDate>2012-07-13 13:27:00</TransactionDate><TransactionTimeZone>2012-07-13 13:27:00</TransactionTimeZone><TransactionResult>Authorized</TransactionResult><UrlReferrer>http://leadgreen.org/wordpress/</UrlReferrer><PaymentMethod><PaymentType>Credit Card</PaymentType><CreditCard>';
        XMlstring += '<NameOnCard>Test16 Tester</NameOnCard><CardNumber>41111111</CardNumber><CardName>VISA</CardName>';
        XMlstring += '<ExpirationDate>1208</ExpirationDate></CreditCard></PaymentMethod></TransactionDetail>';
        XMLstring += '<OrderItemList>';
        XMLstring += '<OrderItem>';
        XMLstring += '<ItemID>1</ItemID>';
        XMLstring += '<ItemName>Event Attendee-Baird straughan</ItemName>';
        XMLstring += '<Quantity>1</Quantity>';
        XMLstring += '<UnitPriceCharge>14</UnitPriceCharge>';
        XMLstring += '<UnitPriceDue>14</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge>';
        XMLstring += '<UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
        XMLstring += '<DiscountCharge>0</DiscountCharge>';
        XMLstring += '<DiscountDue>0</DiscountDue>';
        XMLstring += '<SKU>Event</SKU>';
        XMLstring += '<CampaignName>Testcampaign</CampaignName>';
        XMLstring += '</OrderItem>';
        XMLstring += '</OrderItemList></CnPTransactionData>';
        CnP_PaaS_Bridge__CnPData__c TestData = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = XMLstring, //'<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><Patron><BillingInformation><BillingFirstName>Tester</BillingFirstName><BillingMI></BillingMI><BillingLastName>TestContact</BillingLastName><BillingEmail>testcontact@dontbotherme.org</BillingEmail><BillingPhone>333</BillingPhone></BillingInformation><BillingAddress><BillingAddress1>lkj;</BillingAddress1><BillingAddress2></BillingAddress2><BillingAddress3></BillingAddress3><BillingCity>;lkj</BillingCity><BillingStateProvince>Alabama</BillingStateProvince><BillingPostalCode>33333</BillingPostalCode><BillingCountryName>United States of America</BillingCountryName></BillingAddress></Patron><TransactionDetail><OrderNumber>1207131327206181111</OrderNumber><Tracker>TestTracker</Tracker><Campaign></Campaign><WindowName>Wild and Scenic Film Fest</WindowName><WindowId>55337</WindowId><TotalCharge>14.00</TotalCharge><ChargAmount>0.70</ChargAmount><TransactionDate>2012-07-13 13:27:00</TransactionDate><TransactionTimeZone>2012-07-13 13:27:00</TransactionTimeZone><TransactionResult>Authorized</TransactionResult><UrlReferrer>http://leadgreen.org/wordpress/</UrlReferrer><PaymentMethod><PaymentType>Credit Card</PaymentType></PaymentMethod></TransactionDetail></CnPTransactionData>',
        CnP_PaaS_Bridge__Order_Number__c = '120718160056431111' + x,
        CnP_PaaS_Bridge__StatusID__c = 1);
            TestDataList.add (TestData);
        }//end loop for creatin Data record
        system.debug('TestDataList contains ' + TestDataList.size() + ' transactions.');
        system.debug('The OrderNumbers go from ' + TestDataList[0].CnP_PaaS_Bridge__Order_Number__c + ' to ' + TestDataList[4].CnP_PaaS_Bridge__Order_Number__c);

test.starttest();
        insert TestDataList;
test.stoptest();

        // Have ten new donations been created?
        System.debug('Just after inserting the 10 batch opps, Contact.id is ' + TestCtct.Id);
        List<Opportunity> ListOpsCreated = [select id,accountID,CampaignID,Contact__c, amount from Opportunity where contact__c = :TestCtct.ID];
        system.debug('List of ops created ' + ListOpsCreated);
        system.AssertEquals(5,ListOpsCreated.size());
        system.AssertEquals(14,ListOpsCreated[0].amount);
        system.AssertEquals(TestAcct.ID, ListOpsCreated[0].AccountId);
        system.AssertEquals(TestCtct.ID, ListOpsCreated[0].Contact__c);
        system.AssertEquals('Testcampaign',[select name from Campaign where id = :ListOpsCreated[0].CampaignId].name);
        }

//Single transaction test with existing lead, campaign specified
    @isTest
    static void SingleLeadTransactionsTest() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Lead TestLead = ctv.fetchTestLead();
        Campaign TestCamp = ctv.fetchTestcampaign();
          
// create new CnP_Data record        
        string XMLstring ='<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><Patron><BillingInformation><BillingFirstName>Test</BillingFirstName><BillingMI></BillingMI><BillingLastName>TestLead</BillingLastName><BillingEmail>testlead@dontbotherme.org</BillingEmail><BillingPhone>333</BillingPhone></BillingInformation><BillingAddress><BillingAddress1>Test Street</BillingAddress1><BillingAddress2></BillingAddress2><BillingAddress3></BillingAddress3><BillingCity>;lkj</BillingCity><BillingStateProvince>Alabama</BillingStateProvince><BillingPostalCode>33333</BillingPostalCode><BillingCountryName>United States of America</BillingCountryName></BillingAddress></Patron><TransactionDetail><OrderNumber>1207131327206181111</OrderNumber><Tracker>TestTracker</Tracker><Campaign>Testcampaign</Campaign><WindowName>Wild and Scenic Film Fest</WindowName><WindowId>55337</WindowId><TotalCharge>14.00</TotalCharge><ChargAmount>0.70</ChargAmount><TransactionDate>2012-07-13 13:27:00</TransactionDate><TransactionTimeZone>2012-07-13 13:27:00</TransactionTimeZone><TransactionResult>Authorized</TransactionResult><UrlReferrer>http://leadgreen.org/wordpress/</UrlReferrer><PaymentMethod><PaymentType>Credit Card</PaymentType>';
        XMlstring += '<CreditCard><NameOnCard>Test16 Tester</NameOnCard><CardNumber>41111111</CardNumber><CardName>VISA</CardName>';
        XMlstring += '<ExpirationDate>1208</ExpirationDate></CreditCard></PaymentMethod></TransactionDetail>';
        XMLstring += '<OrderItemList>';
        XMLstring += '<OrderItem>';
        XMLstring += '<ItemID>1</ItemID>';
        XMLstring += '<ItemName>Event Attendee-Baird straughan</ItemName>';
        XMLstring += '<Quantity>1</Quantity>';
        XMLstring += '<UnitPriceCharge>14</UnitPriceCharge>';
        XMLstring += '<UnitPriceDue>14</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge>';
        XMLstring += '<UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
        XMLstring += '<DiscountCharge>0</DiscountCharge>';
        XMLstring += '<DiscountDue>0</DiscountDue>';
        XMLstring += '<SKU>Event</SKU>';
        XMLstring += '<CampaignName></CampaignName>';
        XMLstring += '</OrderItem>';
        XMLstring += '</OrderItemList></CnPTransactionData>';
        CnP_PaaS_Bridge__CnPData__c TestData = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = XMLstring,
        CnP_PaaS_Bridge__Order_Number__c = '1207181600564311111',
        CnP_PaaS_Bridge__StatusID__c = 1);
        insert testdata;
        system.debug('Testdata record now contains: '+ testdata);         

        // Have one new donations been created?
        List<contact> checkContacts = [select id from Contact where lastname = 'TestLead'];
        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c 
            from Opportunity where Contact__c = :checkContacts[0].id];
        system.AssertEquals(1,Payments.size());
        system.AssertEquals(14,Payments[0].amount);
        system.AssertEquals(TestCamp.ID,Payments[0].CampaignId);
        contact checkContact = [select id, lastname, mailingStreet, leadsource from Contact where id = :Payments[0].contact__c];
        System.assertEquals('Test Street',checkContact.MailingStreet);
        system.AssertEquals('TestCompany',[select id, name from Account where id = :Payments[0].accountid].name);
        system.AssertEquals(14,Payments[0].amount);
    }

//Single transaction test with no contact or lead, campaign specified, type Donation
    @isTest
    static void UnknownPersonTransactionsTest() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        //Account TestAcct = ctv.fetchTestAccount();
        //Contact TestCtct = ctv.fetchTestContact();
        //Lead TestLead = ctv.fetchTestLead();
        Campaign TestCamp = ctv.fetchTestcampaign();
          
// create new CnP_Data record        
        string XMLstring ='<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><Patron><BillingInformation><BillingFirstName>New</BillingFirstName><BillingMI></BillingMI> ' +
        '<BillingLastName>Newtestlead</BillingLastName><BillingEmail>unknown@dontbotherme.org</BillingEmail><BillingPhone>333</BillingPhone></BillingInformation><BillingAddress><BillingAddress1>111 Test St.</BillingAddress1>' +
        '<BillingAddress2></BillingAddress2><BillingAddress3></BillingAddress3><BillingCity>Test City</BillingCity><BillingStateProvince>MI</BillingStateProvince><BillingPostalCode>33333</BillingPostalCode>' +
        '<BillingCountryName>United States of America</BillingCountryName></BillingAddress></Patron>'+
        '<TransactionDetail><OrderNumber>1207131327206181111</OrderNumber><Tracker>TestTracker</Tracker>' +
        '<Campaign>Testcampaign</Campaign><WindowName>Wild and Scenic Film Fest</WindowName><WindowId>55337</WindowId><TotalCharge>14.00</TotalCharge><ChargAmount>0.70</ChargAmount>' +
        '<TransactionDate>2012-07-13 13:27:00</TransactionDate><TransactionTimeZone>2012-07-13 13:27:00</TransactionTimeZone><TransactionResult>Authorized</TransactionResult>' +
        '<UrlReferrer>http://leadgreen.org/wordpress/</UrlReferrer><PaymentMethod><PaymentType>Credit Card</PaymentType><CreditCard>' +
        '<NameOnCard>Test16 Tester</NameOnCard><CardNumber>41111111</CardNumber><CardName>VISA</CardName>' +
        '<ExpirationDate>1208</ExpirationDate></CreditCard></PaymentMethod></TransactionDetail>' +
        '<OrderItemList>' +
        '<OrderItem>' +
        '<ItemID>1</ItemID>' +
        '<ItemName>Event Attendee-Baird straughan</ItemName>' +
        '<Quantity>1</Quantity>' +
        '<UnitPriceCharge>14</UnitPriceCharge>' +
        '<UnitPriceDue>14</UnitPriceDue>' +
        '<UnitDeductibleCharge>0</UnitDeductibleCharge>' +
        '<UnitDeductibleDue>0</UnitDeductibleDue>' +
        '<TaxAmountCharge>0</TaxAmountCharge>' +
        '<TaxAmountDue>0</TaxAmountDue>' +
        '<DiscountCharge>0</DiscountCharge>' +
        '<DiscountDue>0</DiscountDue>' +
        '<SKU>Donation</SKU>' +
        '<CampaignName></CampaignName>' +
        '</OrderItem>' +
        '</OrderItemList></CnPTransactionData>';
        CnP_PaaS_Bridge__CnPData__c TestData = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = XMLstring,
        CnP_PaaS_Bridge__Order_Number__c = '1207181600564311111',
        CnP_PaaS_Bridge__StatusID__c = 1);
        insert testdata;
        system.debug('Testdata record now contains: '+ testdata);         

        // Have one new donations been created?
        List<contact> checkContacts = [select id from Contact where firstname = 'New' and lastname = 'Newtestlead'];
        system.assertEquals(1,checkContacts.size(),'Should have found one contact with firstname New and lastname Newtestlead');
        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c,RecordType.Name 
            from Opportunity where Contact__c = :checkContacts[0].id];
        system.AssertEquals(1,Payments.size());
        system.AssertEquals(14,Payments[0].amount);
        system.AssertEquals(TestCamp.ID,Payments[0].CampaignId);
        Contact checkContact = [select id, lastname, mailingStreet, mailingPostalCode, 
            account.billingCity, account.BillingState, account.dear__c, account.addressee__c 
            from Contact where id = :Payments[0].contact__c];
        system.AssertEquals('Newtestlead',checkContact.lastname);
        System.assertEquals('111 Test St.',checkContact.mailingStreet);
        System.assertEquals('33333', checkContact.mailingPostalCode);
        System.assertEquals('Test City',checkContact.account.BillingCity);
        System.assertEquals('MI',checkContact.account.BillingState);
        System.assertEquals('New',checkContact.account.dear__c);
        System.assertEquals('New Newtestlead',checkContact.account.addressee__c);
        system.AssertEquals('Newtestlead, New Household',[select id, name from Account where id = :Payments[0].accountid].name);
        system.AssertEquals(14,Payments[0].amount);
        System.AssertEquals('Donation',Payments[0].RecordType.Name);
    }

//Try with AMEX card - Mask should have only 11 Xs (15 digit card)
        @isTest
        static void AMEXCnPDataTest() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        Contact TestCtct = ctv.fetchTestContact();
        Campaign TestCamp = ctv.fetchTestcampaign();

// create new CnP_Data record        
        string XMLstring ='<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Tester</BillingFirstName><BillingMI></BillingMI>';
        XMLstring += '<BillingLastName>TestContact</BillingLastName><BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
        XMLstring += '<BillingPhone>333</BillingPhone></BillingInformation><BillingAddress><BillingAddress1>lkj;</BillingAddress1>';
        XMLstring += '<BillingAddress2></BillingAddress2><BillingAddress3></BillingAddress3><BillingCity>;lkj</BillingCity>';
        XMLstring += '<BillingStateProvince>Alabama</BillingStateProvince><BillingPostalCode>33333</BillingPostalCode>';
        XMLstring += '<BillingCountryName>United States of America</BillingCountryName></BillingAddress></Patron><TransactionDetail>';
        XMLstring += '<OrderNumber>1207131327206181111</OrderNumber><Tracker>TestTracker</Tracker><Campaign></Campaign>';
        XMLstring += '<WindowName>Wild and Scenic Film Fest</WindowName><WindowId>55337</WindowId><TotalCharge>14.00</TotalCharge><ChargAmount>0.70</ChargAmount><TransactionDate>2012-07-13 13:27:00</TransactionDate><TransactionTimeZone>2012-07-13 13:27:00</TransactionTimeZone><TransactionResult>Authorized</TransactionResult><UrlReferrer>http://leadgreen.org/wordpress/</UrlReferrer><PaymentMethod><PaymentType>Credit Card</PaymentType><CreditCard>';
        XMlstring += '<NameOnCard>Test16 Tester</NameOnCard><CardNumber>411111111111111</CardNumber><CardName>AMEX</CardName>';
        XMlstring += '<ExpirationDate>1208</ExpirationDate></CreditCard></PaymentMethod></TransactionDetail>';
        XMLstring += '<OrderItemList>';
        XMLstring += '<OrderItem>';
        XMLstring += '<ItemID>1</ItemID>';
        XMLstring += '<ItemName>Event Attendee-Baird straughan</ItemName>';
        XMLstring += '<Quantity>1</Quantity>';
        XMLstring += '<UnitPriceCharge>14</UnitPriceCharge>';
        XMLstring += '<UnitPriceDue>14</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge>';
        XMLstring += '<UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
        XMLstring += '<DiscountCharge>0</DiscountCharge>';
        XMLstring += '<DiscountDue>0</DiscountDue>';
        XMLstring += '<SKU>Event</SKU>';
        XMLstring += '<CampaignName></CampaignName>';
        XMLstring += '</OrderItem>';
        XMLstring += '</OrderItemList></CnPTransactionData>';
        CnP_PaaS_Bridge__CnPData__c TestData = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = XMLstring,
        CnP_PaaS_Bridge__Order_Number__c = '1207181600564311111',
        CnP_PaaS_Bridge__StatusID__c = 1);
        insert testdata;
        system.debug('Testdata record now contains: '+ testdata);         
        CnP_PaaS_Bridge__CnPData__c TestDataUpdated = [select id, CnP_PaaS_Bridge__DataXML__c from CnP_PaaS_Bridge__CnPData__c
            where id = :testdata.id];

//Has TestData credit card # and expiration date been masked for 15 digit CC number?
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
 //       system.assertEquals('41111111', xr2paymentmethodCCNr.gettext());
        } // END AMEX TEST

        
// single transaction test with recurring, existing contact, campaign specified
    @isTest
    static void SingleRecurringTransactionMembershipTest() {
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
        XMlstring += '<RecurringMethod>Subscription</RecurringMethod><Periodicity>Monthly</Periodicity>';
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
        dom.XmlNode xrrecurring = xroot.getchildelement('Recurring', null) ; //
        
            system.debug('xr2paymentmethodCCName.getText() is ' + xr2paymentmethodCCName.getText());
            system.debug('xr2paymentmethodCCExp.gettext() is ' + xr2paymentmethodCCExp.gettext());
        system.assertEquals(xr2paymentmethodCCNr.gettext(), '41111111');
        
        // Has one donation and one pledge been created?
        system.debug('TestAcct.id is ' + TestAcct.ID);
        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c,CnPMasterPledgeID__c,pledge_amount__c,
            CnPMasterTransactionNumber__c,Matches_Which_Challenge_or_Pledge__c,name,RecordType.name,Installment_Nr__c,
            Number_of_Payments__c from Opportunity where Accountid = :TestAcct.Id order by Amount];
        // Two opps created - the pledge and the payment
        system.AssertEquals(2,Payments.size());
        // Is the pledge amount = null and pledge_amount__c = 3 and Number_Installments__c = 3
        system.AssertEquals(null,Payments[0].amount);
        system.AssertEquals(3,Payments[0].pledge_amount__c);
        System.assertEquals(3,Payments[0].number_of_payments__c);
        // Is the payment amount = 1 and the pledge_amount__c = null and recordType "Membership" and Intallment Number 1?
        system.AssertEquals(1,Payments[1].amount);
        system.AssertEquals(null,Payments[1].pledge_amount__c);
        System.assertEquals('Membership',Payments[1].recordtype.name);
        System.assertEquals(1.0,Payments[1].installment_nr__c);
        // Do the two IDs match for the pledge and payment?
        System.assertEquals(Payments[0].id,Payments[1].Matches_Which_Challenge_or_Pledge__c);
        system.AssertEquals(TestAcct.ID, Payments[0].AccountId);
        system.AssertEquals(TestCtct.ID, Payments[0].Contact__c);
        system.AssertEquals(TestMemberCamp.ID,Payments[0].CampaignId);

// Create a second pledge payment
// 
        XMLstring ='<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><Patron>';
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
        XMlstring += '<RecurringMethod>Subscription</RecurringMethod><Periodicity>Monthly</Periodicity>';
        XMlstring += '<InstallmentNumber>2</InstallmentNumber><NextInstallmentDate>2013-09-10 16:08:00</NextInstallmentDate>';
        XMlstring += '<InstallmentAmount>1.00</InstallmentAmount><TotalAmount>1.00</TotalAmount><TotalCommitted>3.00</TotalCommitted>';
        XMlstring += '<TotalMade>2.00</TotalMade><TotalDue>1.00</TotalDue></Recurring>';
        XMLstring += '<OrderItemList>';
        XMLstring += '<OrderItem>';
        XMLstring += '<ItemID>1</ItemID>';
        XMLstring += '<ItemName>Membership-Baird straughan</ItemName>';
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
        CnP_PaaS_Bridge__CnPData__c TestData2 = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = XMLstring,
        CnP_PaaS_Bridge__Order_Number__c = '1207181600564311112',
        CnP_PaaS_Bridge__StatusID__c = 1);
        insert testData2;
        system.debug('Testdata record now contains: '+ testdata);   
        CnP_PaaS_Bridge__CnPData__c TestDataUpdated2 = [select id, CnP_PaaS_Bridge__DataXML__c from CnP_PaaS_Bridge__CnPData__c
            where id = :testdata.id];
        
        // Are there now three contributions - one pledge, two payments?
        system.debug('TestAcct.id is ' + TestAcct.ID);
        Payments = [select id,CampaignID,Amount,AccountID,Contact__c,CnPMasterPledgeID__c,pledge_amount__c,
            CnPMasterTransactionNumber__c,Matches_Which_Challenge_or_Pledge__c,name,RecordType.name,Installment_Nr__c,
            Number_of_Payments__c, Total_Paid_CnP__c from Opportunity where Accountid = :TestAcct.Id order by Amount];
        // Two opps created - the pledge and the payment
        system.AssertEquals(3,Payments.size());
        // Is the pledge amount = null and pledge_amount__c = 3 and Number_Installments__c = 3
        system.AssertEquals(null,Payments[0].amount);
        system.AssertEquals(3,Payments[0].pledge_amount__c);
        System.assertEquals(2,Payments[0].Total_Paid_CnP__c);
        // Is the payment amount = 1.00 and the pledge_amount__c = null and recordType "Membership" and Intallment Number 2?
        system.AssertEquals(1.00,Payments[2].amount);
        system.AssertEquals(null,Payments[2].pledge_amount__c);
        System.assertEquals('Membership',Payments[2].recordtype.name);
        System.assertEquals(2.0,Payments[2].installment_nr__c);
        // Is the Total_Paid_CnP__c updated for the master?
        system.AssertEquals(Payments[0].Total_Paid_CnP__c,2.00);
        // System.assertEquals(Payments[0].id,Payments[2].Matches_Which_Challenge_or_Pledge__c);
    } // end single recurring test

//single payment against pledge, can't find pledge
    @isTest
    static void SingleRecurringPaymentNoPledgeTest() {
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
        XMlstring += '<MasterTransactionNumber>1311111111111111111</MasterTransactionNumber><Installments>3</Installments>';
        XMlstring += '<RecurringMethod>Subscription</RecurringMethod><Periodicity>Monthly</Periodicity>';
        XMlstring += '<InstallmentNumber>2</InstallmentNumber><NextInstallmentDate>2013-08-10 16:08:00</NextInstallmentDate>';
        XMlstring += '<InstallmentAmount>2.22</InstallmentAmount><TotalAmount>2.22</TotalAmount><TotalCommitted>3.00</TotalCommitted>';
        XMlstring += '<TotalMade>2.00</TotalMade><TotalDue>1.00</TotalDue></Recurring>';
        XMLstring += '<OrderItemList>';
        XMLstring += '<OrderItem>';
        XMLstring += '<ItemID>1</ItemID>';
        XMLstring += '<ItemName>Event Attendee-Baird straughan</ItemName>';
        XMLstring += '<Quantity>1</Quantity>';
        XMLstring += '<UnitPriceCharge>14</UnitPriceCharge>';
        XMLstring += '<UnitPriceDue>14</UnitPriceDue>';
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
        CnP_PaaS_Bridge__Order_Number__c = '1207181600564311112',
        CnP_PaaS_Bridge__StatusID__c = 1);
        insert testdata;
        system.debug('Testdata record now contains: '+ testdata);   
        CnP_PaaS_Bridge__CnPData__c TestDataUpdated = [select id, CnP_PaaS_Bridge__DataXML__c from CnP_PaaS_Bridge__CnPData__c
            where id = :testdata.id];
        
        // Has two donations been created - One Orphanage for Lost Payments" and one payment?
        system.debug('TestAcct.id is ' + TestAcct.ID);
        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c,CnPMasterPledgeID__c,pledge_amount__c,
            CnPMasterTransactionNumber__c,Matches_Which_Challenge_or_Pledge__c,name,RecordType.name,Installment_Nr__c,
            Number_of_Payments__c from Opportunity where Accountid = :TestAcct.Id or Account.Name = 'OrphanageAccount' order by Amount];
        // One Opp created
        system.AssertEquals(2,Payments.size());
        // Is this attributed to the "Orphanage" pledge?
        system.AssertEquals(null,Payments[0].amount);
        system.AssertEquals('Orphanage for Lost Payments',Payments[0].Name);
        System.assertEquals(99,Payments[0].number_of_payments__c);
        // Do the two IDs match for the pledge and payment?
        system.AssertEquals(Payments[0].CnPMasterTransactionNumber__c,Payments[1].CnPMasterPledgeID__c);
        System.assertEquals(Payments[0].id,Payments[1].Matches_Which_Challenge_or_Pledge__c);

        
    } // end single recurring test

       
// single transaction test with existing contact, campaign specified, transaction not authorized
    @isTest
    static void SingleContactTransactionsTestNotAuthorized() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        system.assertEquals('Testcampaign', testCamp.name);

        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c 
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);

        
        string XMLstring ='<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Tester</BillingFirstName><BillingMI></BillingMI>';
        XMLstring += '<BillingLastName>TestContact</BillingLastName><BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
        XMLstring += '<BillingPhone>333</BillingPhone></BillingInformation><BillingAddress><BillingAddress1>Test Street</BillingAddress1>';
        XMLstring += '<BillingAddress2></BillingAddress2><BillingAddress3></BillingAddress3><BillingCity>Test City</BillingCity>';
        XMLstring += '<BillingStateProvince>Alabama</BillingStateProvince><BillingPostalCode>33333</BillingPostalCode>';
        XMLstring += '<BillingCountryName>United States of America</BillingCountryName></BillingAddress></Patron><TransactionDetail>';
        XMLstring += '<OrderNumber>1207131327206181111</OrderNumber><Tracker>TestTracker</Tracker><Campaign>Testcampaign</Campaign>';
        XMLstring += '<WindowName>Wild and Scenic Film Fest</WindowName><WindowId>55337</WindowId><TotalCharge>14.00</TotalCharge><ChargAmount>0.70</ChargAmount><TransactionDate>2012-07-13 13:27:00</TransactionDate><TransactionTimeZone>2012-07-13 13:27:00</TransactionTimeZone><TransactionResult>Declined</TransactionResult><UrlReferrer>http://leadgreen.org/wordpress/</UrlReferrer><PaymentMethod><PaymentType>Credit Card</PaymentType><CreditCard>';
        XMlstring += '<NameOnCard>Test16 Tester</NameOnCard><CardNumber>41111111</CardNumber><CardName>VISA</CardName>';
        XMlstring += '<ExpirationDate>1208</ExpirationDate></CreditCard></PaymentMethod></TransactionDetail></CnPTransactionData>';

      
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
        system.assertEquals(xr2paymentmethodCCNr.gettext(), '41111111');
        
        // No new donations been created because transaction was declined.
        Payments = [select id,CampaignID,Amount,AccountID,Contact__c 
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.AssertEquals(0,Payments.size());
    }

// single transaction test with existing contact, campaign specified, multiple order items
    @isTest
    static  void SingleContactTransactionMultipleOrderItems() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        system.assertEquals('Testcampaign', testCamp.name);

        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c 
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);
   
        string XMLstring ='<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Tester</BillingFirstName><BillingMI></BillingMI>';
        XMLstring += '<BillingLastName>TestContact</BillingLastName><BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
        XMLstring += '<BillingPhone>333</BillingPhone></BillingInformation><BillingAddress><BillingAddress1>Test Street</BillingAddress1>';
        XMLstring += '<BillingAddress2></BillingAddress2><BillingAddress3></BillingAddress3><BillingCity>Test City</BillingCity>';
        XMLstring += '<BillingStateProvince>Alabama</BillingStateProvince><BillingPostalCode>33333</BillingPostalCode>';
        XMLstring += '<BillingCountryName>United States of America</BillingCountryName></BillingAddress></Patron><TransactionDetail>';
        XMLstring += '<OrderNumber>1207131327206181111</OrderNumber><Tracker>TestTracker</Tracker><Campaign>Testcampaign</Campaign>';
        XMLstring += '<WindowName>Wild and Scenic Film Fest</WindowName><WindowId>55337</WindowId><TotalCharge>400.00</TotalCharge><ChargAmount>1.00</ChargAmount><TransactionDate>2012-07-13 13:27:00</TransactionDate><TransactionTimeZone>2012-07-13 13:27:00</TransactionTimeZone><TransactionResult>Authorized</TransactionResult><UrlReferrer>http://leadgreen.org/wordpress/</UrlReferrer><PaymentMethod><PaymentType>Credit Card</PaymentType><CreditCard>';
        XMlstring += '<NameOnCard>Test16 Tester</NameOnCard><CardNumber>41111111</CardNumber><CardName>VISA</CardName>';
        XMlstring += '<ExpirationDate>1208</ExpirationDate></CreditCard></PaymentMethod></TransactionDetail>';
        XMLstring += '<OrderItemList><OrderItem><ItemID>100</ItemID><ItemName>Dinner Attendee-Brian Nudelman</ItemName>';
        XMLstring += '<Quantity>6</Quantity><UnitPriceCharge>50</UnitPriceCharge><UnitPriceDue>50</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge><UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge><TaxAmountDue>0</TaxAmountDue><DiscountCharge>0</DiscountCharge>';
        XMLstring += '<DiscountDue>0</DiscountDue><SKU>Event</SKU><CampaignName>Dinner 2013 Tickets Event</CampaignName></OrderItem>';
        XMLstring += '<OrderItem><ItemID>101</ItemID><ItemName>Please make a donation to Prairie Rivers Network</ItemName>';
        XMLstring += '<Quantity>1</Quantity><UnitPriceCharge>100</UnitPriceCharge><UnitPriceDue>100</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>100</UnitDeductibleCharge><UnitDeductibleDue>100</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge><TaxAmountDue>0</TaxAmountDue><DiscountCharge>0</DiscountCharge>';
        XMLstring += '<DiscountDue>0</DiscountDue><SKU>Donation</SKU></OrderItem>';
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
        
        // One new donation and one new events payment been created, both linked to the same CnP payment but possibly different campaigns
        system.debug('How many payments were made? Payments are '+[select name,AccountId,campaignId,opportunity.campaign.Name from Opportunity]);
        Payments = [select id,RecordType.Name,Amount,AccountID,Contact__c,C_P_Data__c,Processing_Fee__c 
            from Opportunity where Accountid = :TestAcct.Id order by amount DESC];
        system.AssertEquals(2,Payments.size());
        System.assertEquals(300,Payments[0].amount);
        System.assertEquals('Event',Payments[0].RecordType.Name);
        System.assertEquals(100,Payments[1].amount);
        System.assertEquals('Donation',Payments[1].RecordType.Name);
        System.assertEquals(Payments[0].C_P_Data__c,TestData.Id);
        System.assertEquals(Payments[1].C_P_Data__c,TestData.Id);
        System.assertEquals(Payments[0].AccountID,TestAcct.Id);
        System.assertEquals(Payments[1].AccountID,TestAcct.Id);
        System.assertEquals(Payments[0].Contact__c,TestCtct.Id);
        System.assertEquals(Payments[1].Contact__c,TestCtct.Id);
        System.assertEquals(Payments[0].Processing_Fee__c,.75);
        System.assertEquals(Payments[1].Processing_Fee__c,.25);
        // add test for discount, for charge amount here
    }

// single transaction test with existing contact, campaign specified, multiple order items, WITH DISCOUNTS
    @isTest
    static  void SingleContactTransactionMultipleOrderDiscountItems() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        system.assertEquals('Testcampaign', testCamp.name);

        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c 
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);
   
        string XMLstring ='<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Tester</BillingFirstName><BillingMI></BillingMI>';
        XMLstring += '<BillingLastName>TestContact</BillingLastName><BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
        XMLstring += '<BillingPhone>333</BillingPhone></BillingInformation><BillingAddress><BillingAddress1>Test Street</BillingAddress1>';
        XMLstring += '<BillingAddress2></BillingAddress2><BillingAddress3></BillingAddress3><BillingCity>Test City</BillingCity>';
        XMLstring += '<BillingStateProvince>Alabama</BillingStateProvince><BillingPostalCode>33333</BillingPostalCode>';
        XMLstring += '<BillingCountryName>United States of America</BillingCountryName></BillingAddress></Patron><TransactionDetail>';
        XMLstring += '<OrderNumber>1207131327206181111</OrderNumber><Tracker>TestTracker</Tracker><Campaign>Testcampaign</Campaign>';
        XMLstring += '<WindowName>Wild and Scenic Film Fest</WindowName><WindowId>55337</WindowId><TotalCharge>299.98</TotalCharge><ChargAmount>1.00</ChargAmount><TransactionDate>2012-07-13 13:27:00</TransactionDate><TransactionTimeZone>2012-07-13 13:27:00</TransactionTimeZone><TransactionResult>Authorized</TransactionResult><UrlReferrer>http://leadgreen.org/wordpress/</UrlReferrer><PaymentMethod><PaymentType>Credit Card</PaymentType><CreditCard>';
        XMlstring += '<NameOnCard>Test16 Tester</NameOnCard><CardNumber>41111111</CardNumber><CardName>VISA</CardName>';
        XMlstring += '<ExpirationDate>1208</ExpirationDate></CreditCard></PaymentMethod></TransactionDetail>';
        XMLstring += '<OrderItemList><OrderItem><ItemID>100</ItemID><ItemName>Dinner Attendee-Brian Nudelman</ItemName>';
        XMLstring += '<Quantity>6</Quantity><UnitPriceCharge>50</UnitPriceCharge><UnitPriceDue>50</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge><UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge><TaxAmountDue>0</TaxAmountDue><DiscountCharge>16.67</DiscountCharge>';
        XMLstring += '<DiscountDue>16.67</DiscountDue><SKU>Event</SKU><CampaignName>Dinner 2013 Tickets Event</CampaignName></OrderItem>';
        XMLstring += '<OrderItem><ItemID>101</ItemID><ItemName>Please make a donation to Prairie Rivers Network</ItemName>';
        XMLstring += '<Quantity>1</Quantity><UnitPriceCharge>100</UnitPriceCharge><UnitPriceDue>100</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>100</UnitDeductibleCharge><UnitDeductibleDue>100</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge><TaxAmountDue>0</TaxAmountDue><DiscountCharge>0</DiscountCharge>';
        XMLstring += '<DiscountDue>0</DiscountDue><SKU>Donation</SKU></OrderItem>';
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
        
        // One new donation and one new events payment been created, both linked to the same CnP payment
        Payments = [select id,RecordType.Name,Amount,AccountID,Contact__c,C_P_Data__c,Processing_Fee__c 
            from Opportunity where Accountid = :TestAcct.Id order by amount DESC];
        system.AssertEquals(2,Payments.size());
        System.assertEquals(199.98,Payments[0].amount);
        System.assertEquals('Event',Payments[0].RecordType.Name);
        System.assertEquals(100,Payments[1].amount);
        System.assertEquals('Donation',Payments[1].RecordType.Name);
        System.assertEquals(Payments[0].C_P_Data__c,TestData.Id);
        System.assertEquals(Payments[1].C_P_Data__c,TestData.Id);
        System.assertEquals(Payments[0].AccountID,TestAcct.Id);
        System.assertEquals(Payments[1].AccountID,TestAcct.Id);
        System.assertEquals(Payments[0].Contact__c,TestCtct.Id);
        System.assertEquals(Payments[1].Contact__c,TestCtct.Id);
        System.assertEquals(Payments[0].Processing_Fee__c,.67);
        System.assertEquals(Payments[1].Processing_Fee__c,.33);
        // add test for discount, for charge amount here
    }

// single transaction test with existing contact, campaign specified, multiple order items
// using the "RT_Membership" notation in the SKU to delineate recordType
    @isTest
    static  void SingleContactTransactionMultipleOrderItemsNewSKU() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        system.assertEquals('Testcampaign', testCamp.name);

        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c 
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);
   
        string XMLstring ='<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Tester</BillingFirstName><BillingMI></BillingMI>';
        XMLstring += '<BillingLastName>TestContact</BillingLastName><BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
        XMLstring += '<BillingPhone>333</BillingPhone></BillingInformation><BillingAddress><BillingAddress1>Test Street</BillingAddress1>';
        XMLstring += '<BillingAddress2></BillingAddress2><BillingAddress3></BillingAddress3><BillingCity>Test City</BillingCity>';
        XMLstring += '<BillingStateProvince>Alabama</BillingStateProvince><BillingPostalCode>33333</BillingPostalCode>';
        XMLstring += '<BillingCountryName>United States of America</BillingCountryName></BillingAddress></Patron><TransactionDetail>';
        XMLstring += '<OrderNumber>1207131327206181111</OrderNumber><Tracker>TestTracker</Tracker><Campaign>Testcampaign</Campaign>';
        XMLstring += '<WindowName>Wild and Scenic Film Fest</WindowName><WindowId>55337</WindowId><TotalCharge>400.00</TotalCharge><ChargAmount>1.00</ChargAmount><TransactionDate>2012-07-13 13:27:00</TransactionDate><TransactionTimeZone>2012-07-13 13:27:00</TransactionTimeZone><TransactionResult>Authorized</TransactionResult><UrlReferrer>http://leadgreen.org/wordpress/</UrlReferrer><PaymentMethod><PaymentType>Credit Card</PaymentType><CreditCard>';
        XMlstring += '<NameOnCard>Test16 Tester</NameOnCard><CardNumber>41111111</CardNumber><CardName>VISA</CardName>';
        XMlstring += '<ExpirationDate>1208</ExpirationDate></CreditCard></PaymentMethod></TransactionDetail>';
        XMLstring += '<OrderItemList><OrderItem><ItemID>100</ItemID><ItemName>Dinner Attendee-Brian Nudelman</ItemName>';
        XMLstring += '<Quantity>6</Quantity><UnitPriceCharge>50</UnitPriceCharge><UnitPriceDue>50</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge><UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge><TaxAmountDue>0</TaxAmountDue><DiscountCharge>0</DiscountCharge>';
        XMLstring += '<DiscountDue>0</DiscountDue><SKU>2016 Gala Dinner RT_Event</SKU><CampaignName>Dinner 2013 Tickets Event</CampaignName></OrderItem>';
        XMLstring += '<OrderItem><ItemID>101</ItemID><ItemName>Please make a donation to Prairie Rivers Network</ItemName>';
        XMLstring += '<Quantity>1</Quantity><UnitPriceCharge>100</UnitPriceCharge><UnitPriceDue>100</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>100</UnitDeductibleCharge><UnitDeductibleDue>100</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge><TaxAmountDue>0</TaxAmountDue><DiscountCharge>0</DiscountCharge>';
        XMLstring += '<DiscountDue>0</DiscountDue><SKU>Gala Dinner Donation RT_Donation</SKU></OrderItem>';
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
        
        // One new donation and one new events payment been created, both linked to the same CnP payment
        Payments = [select id,RecordType.Name,Amount,AccountID,Contact__c,C_P_Data__c,Processing_Fee__c 
            from Opportunity where Accountid = :TestAcct.Id order by amount DESC];
        system.AssertEquals(2,Payments.size());
        System.assertEquals(300,Payments[0].amount);
        System.assertEquals('Event',Payments[0].RecordType.Name);
        System.assertEquals(100,Payments[1].amount);
        System.assertEquals('Donation',Payments[1].RecordType.Name);
        System.assertEquals(Payments[0].C_P_Data__c,TestData.Id);
        System.assertEquals(Payments[1].C_P_Data__c,TestData.Id);
        System.assertEquals(Payments[0].AccountID,TestAcct.Id);
        System.assertEquals(Payments[1].AccountID,TestAcct.Id);
        System.assertEquals(Payments[0].Contact__c,TestCtct.Id);
        System.assertEquals(Payments[1].Contact__c,TestCtct.Id);
        System.assertEquals(Payments[0].Processing_Fee__c,.75);
        System.assertEquals(Payments[1].Processing_Fee__c,.25);
        // add test for discount, for charge amount here
    }    
    
// single transaction test with existing contact, campaign specified, free event
    @isTest
    static void SingleContactTransactionFreeEvent() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        system.assertEquals('Testcampaign', testCamp.name);

        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c 
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);
        
        //insert XML from free event
        string XMLstring = '<?xml version="1.0" encoding="UTF-8"?>';
        XMLstring += '<CnPTransactionData><Version>40</Version>';
        XMLstring += '<Application><ID>Salesforce:CnP_PaaS_Evt</ID>';
        XMLstring += '<Name>Salesforce:CnP_PaaS_Evt</Name>';
        XMLstring += '<Version>1.2014</Version>';
        XMLstring += '</Application>';
        XMLstring += '<Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Tester</BillingFirstName>';
        XMLstring += '<BillingMI></BillingMI>';
        XMLstring += '<BillingLastName>testcontact</BillingLastName>';
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
        XMLstring += '<Campaign>Testcampaign</Campaign>';
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
        XMLstring += '<CampaignName>Testcampaign</CampaignName>';
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
        
        // One new donation and one new events payment been created, both linked to the same CnP payment
        Payments = [select id,RecordType.Name,Amount,AccountID,Contact__c,C_P_Data__c,Processing_Fee__c, Attendee__c 
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id order by amount DESC];
        system.AssertEquals(1,Payments.size());
        System.assertEquals(0,Payments[0].amount);
        System.assertEquals('Event',Payments[0].RecordType.Name);
        //System.assertEquals(100,Payments[1].amount);
        //System.assertEquals('Donation',Payments[1].RecordType.Name);
        System.assertEquals(Payments[0].C_P_Data__c,TestData.Id);
        //System.assertEquals(Payments[1].C_P_Data__c,TestData.Id);
        System.assertEquals(Payments[0].AccountID,TestAcct.Id);
        //System.assertEquals(Payments[1].AccountID,TestAcct.Id);
        System.assertEquals(Payments[0].Contact__c,TestCtct.Id);
        //System.assertEquals(Payments[1].Contact__c,TestCtct.Id);
        System.assertEquals(Payments[0].Processing_Fee__c,.00);
        //System.assertEquals(Payments[1].Processing_Fee__c,.33);
        // add test for discount, for charge amount here
    }
    
    // single transaction test for Swiper1 transaction with only first + last + zip
    @isTest
    static void Swiper1TransactionNoEmail() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Account TestAcct2 = ctv.fetchTestAccount();
        TestAcct2.BillingPostalCode = '55555';
        update TestAcct2;
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        testCtct.email = null;
        testCtct.firstname = 'Test';
        update TestCtct;
        Contact TestCtct2 = ctv.fetchTestContact();
        TestCtct2.email = null;
        TestCtct2.MailingPostalCode = '55555';
        TestCtct2.Firstname = 'Test';
        update TestCtct2;
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        system.assertEquals('Testcampaign', testCamp.name);

        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c 
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);
        
        //insert XML from Swiper1
        String XMLString = '<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version>';
        XMLstring += '<Application><ID>Android</ID>';
        XMLstring += '<Name>Swiper1</Name>';
        XMLstring += '<Version>5.000.001.000</Version>';
        XMLstring += '</Application>';
        XMLstring += '<Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Test</BillingFirstName>';
        XMLstring += '<BillingMI />';
        XMLstring += '<BillingLastName>TestContact</BillingLastName>';
        XMLstring += '<BillingEmail />';
        XMLstring += '<BillingPhone />';
        XMLstring += '</BillingInformation>';
        XMLstring += '<BillingAddress><BillingAddress1 />';
        XMLstring += '<BillingAddress2 />';
        XMLstring += '<BillingAddress3 />';
        XMLstring += '<BillingCity />';
        XMLstring += '<BillingStateProvince />';
        XMLstring += '<BillingPostalCode>55555</BillingPostalCode>';
        XMLstring += '<BillingCountryName />';
        XMLstring += '</BillingAddress>';
        
        XMLstring += '</Patron>';
        XMLstring += '<TransactionDetail>';
        XMLstring += '<OrderNumber>1502201905271655143</OrderNumber>';
        XMLstring += '<TransactionID>3379419</TransactionID>';
        XMLstring += '<OrderMode>Live</OrderMode>';
        XMLstring += '<Tracker />';
        XMLstring += '<Campaign />';
        XMLstring += '<TransactionType>Live</TransactionType>';
        XMLstring += '<OrganizationID>28716</OrganizationID>';
        XMLstring += '<OrganizationName>Cannon River Watershed Partnership, Inc.</OrganizationName>';
        XMLstring += '<CurrencyCode>840</CurrencyCode>';
        XMLstring += '<AuthorizationCode>080524</AuthorizationCode>';
        XMLstring += '<WindowName />';
        XMLstring += '<WindowId>-1</WindowId>';
        XMLstring += '<GatewayTransactionNumber>679044535</GatewayTransactionNumber>';
        XMLstring += '<TotalCharge>60.00</TotalCharge>';
        XMLstring += '<TotalDue>60.00</TotalDue>';
        XMLstring += '<DeductibleCharge>0.00</DeductibleCharge>';
        XMLstring += '<DeductibleDue>0.00</DeductibleDue>';
        XMLstring += '<DiscountDue>0.00</DiscountDue>';
        XMLstring += '<DiscountCharge>0.00</DiscountCharge>';
        XMLstring += '<TaxAmountDue>0.00</TaxAmountDue>';
        XMLstring += '<TaxAmountCharge>0.00</TaxAmountCharge>';
        XMLstring += '<SurCharge>0.00</SurCharge>';
        XMLstring += '<ChargAmount>1.80</ChargAmount>';
        XMLstring += '<CouponCode />';
        XMLstring += '<TransactionDiscountDue>0.00</TransactionDiscountDue>';
        XMLstring += '<TransactionDiscountCharge>0.00</TransactionDiscountCharge>';
        XMLstring += '<TransactionTaxDue>0.00</TransactionTaxDue>';
        XMLstring += '<TransactionTaxCharge>0.00</TransactionTaxCharge>';
        XMLstring += '<TransactionDate>2015-02-20 19:05:27</TransactionDate>';
        XMLstring += '<TransactionTimeZone>2015-02-20 18:05:27</TransactionTimeZone>';
        XMLstring += '<UrlReferrer>Swiper1-Android 4.4.2-5.000.001.000-10:30:47:EF:BD:2D-beth@crwp.net-</UrlReferrer>';
        XMLstring += '<VaultGUID>5d008348-e89d-451f-9ee8-b80bab510252</VaultGUID>';
        XMLstring += '<TransactionResult>Authorized</TransactionResult>';
        XMLstring += '<PaymentMethod>';
        XMLstring += '<PaymentType>Credit Card</PaymentType>';
        XMLstring += '<CreditCard>';
        XMLstring += '<NameOnCard>Test Testcontact</NameOnCard>';
        
        XMLstring += '<CardName>VISA</CardName>';
        
        XMLstring += '<ExpirationDate>XXXX</ExpirationDate><CardNumber>41111111</CardNumber></CreditCard>';
        XMLstring += '</PaymentMethod>';
        
        XMLstring += '</TransactionDetail>';
        // ADD IN THE SLEW OF CUSTOM QUESTIONS ANN CREATED
        XMLstring += '<CustomFieldList>';
            XMLstring += '<CustomField>';
            XMLstring += '<FieldName>NAME OF RIDER(S) BEING REGISTERED</FieldName>';
            XMLstring += '<FieldValue>Baird Straughan</FieldValue>';
            XMLstring += '</CustomField>';
            XMLstring += '<CustomField>';
            XMLstring += '<FieldName>How did you hear about Tour de Talbot?: previous Tour de Talbot rider</FieldName>';
            XMLstring += '<FieldValue>Not Checked</FieldValue>';
            XMLstring += '</CustomField>';
            XMLstring += '<CustomField>';
            XMLstring += '<FieldName>How did you hear about Tour de Talbot?: previous Tour de Talbot supporter (non-rider)</FieldName>';
            XMLstring += '<FieldValue>Not Checked</FieldValue>';
            XMLstring += '</CustomField>';
            XMLstring += '<CustomField>';
            XMLstring += '<FieldName>How did you hear about Tour de Talbot?: MRC member</FieldName>';
            XMLstring += '<FieldValue>Not Checked</FieldValue>';
            XMLstring += '</CustomField>';
            XMLstring += '<CustomField>';
            XMLstring += '<FieldName>How did you hear about Tour de Talbot?: MRC newsletter</FieldName>';
            XMLstring += '<FieldValue>Not Checked</FieldValue>';
            XMLstring += '</CustomField>';
            XMLstring += '<CustomField>';
            XMLstring += '<FieldName>How did you hear about Tour de Talbot?: MRC e-news</FieldName>';
            XMLstring += '<FieldValue>Not Checked</FieldValue>';
            XMLstring += '</CustomField>';
            XMLstring += '<CustomField>';
            XMLstring += '<FieldName>How did you hear about Tour de Talbot?: CBF member</FieldName>';
            XMLstring += '<FieldValue>Not Checked</FieldValue>';
            XMLstring += '</CustomField>';
            XMLstring += '<CustomField>';
            XMLstring += '<FieldName>How did you hear about Tour de Talbot?: CBF e-news</FieldName>';
            XMLstring += '<FieldValue>Not Checked</FieldValue>';
            XMLstring += '</CustomField>';
            XMLstring += '<CustomField>';
            XMLstring += '<FieldName>How did you hear about Tour de Talbot?: street banner</FieldName>';
            XMLstring += '<FieldValue>Not Checked</FieldValue>';
            XMLstring += '</CustomField>';
            XMLstring += '<CustomField>';
            XMLstring += '<FieldName>How did you hear about Tour de Talbot?: Bicycling magazine</FieldName>';
            XMLstring += '<FieldValue>Not Checked</FieldValue>';
            XMLstring += '</CustomField>';
            XMLstring += '<CustomField>';
            XMLstring += '<FieldName>How did you hear about Tour de Talbot?: word of mouth</FieldName>';
            XMLstring += '<FieldValue>Not Checked</FieldValue>';
            XMLstring += '</CustomField>';
            XMLstring += '<CustomField>';
            XMLstring += '<FieldName>How did you hear about Tour de Talbot?: other</FieldName>';
            XMLstring += '<FieldValue>Not Checked</FieldValue>';
            XMLstring += '</CustomField>';
            XMLstring += '<CustomField>';
            XMLstring += '<FieldName>If Other, please explain below</FieldName>';
            XMLstring += '<FieldValue></FieldValue>';
            XMLstring += '</CustomField>';
            XMLstring += '<CustomField>';
            XMLstring += '<FieldName>Help us make it happen!: Check here if you are interested in learning about volunteer opportunities at MRC.</FieldName>';
            XMLstring += '<FieldValue>Not Checked</FieldValue>';
            XMLstring += '</CustomField>';
            XMLstring += '</CustomFieldList>';
            XMLstring += '<CustomField>';
            XMLstring += '<FieldName>If this is your first donation or payment to our organization, please tell us how you first heard about us.</FieldName>';
            XMLstring += '<FieldValue>Web</FieldValue>';
            XMLstring += '</CustomField>';

        XMLstring += '<OrderItemList>';
        XMLstring += '<OrderItem>';
        XMLstring += '<ItemID>1</ItemID>';
        XMLstring += '<ItemName>two tickets</ItemName>';
        XMLstring += '<Quantity>1</Quantity>';
        XMLstring += '<UnitPriceCharge>60</UnitPriceCharge>';
        XMLstring += '<UnitPriceDue>60</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge>';
        XMLstring += '<UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
        XMLstring += '<DiscountCharge>0</DiscountCharge>';
        XMLstring += '<DiscountDue>0</DiscountDue>';
        XMLstring += '<SKU />';
        XMLstring += '<CampaignName>Testcampaign</CampaignName>';
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
        
        // One new payment has been created, linked to TestContact2
        Payments = [select id,RecordType.Name,Amount,AccountID,Contact__c,C_P_Data__c,Processing_Fee__c, Attendee__c, CampaignID 
            from Opportunity where Accountid = :TestAcct.Id];
        system.AssertEquals(1,Payments.size());
        System.assertEquals(TestCtct2.id,Payments[0].Contact__c);
        // No SKU so payment defaults to "Donation" record type
        System.assertEquals('Donation',Payments[0].RecordType.Name);
    }

    // single transaction test with existing contact, null email, campaign specified on Order Item
// Note this test actually depends on the identifyOrCreatePerson, and perhaps shouldn't be included here.
// But the problem of incorrect matches on email==null bedeviled us for a long time and it's important
// to make sure it doesn't recur.
    @isTest
    static void NoContactAvoidMatchOnNullEmail() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
            TestCtct.MailingPostalCode = '33332';
            TestCtct.Firstname = 'Test';
            TestCtct.Lastname = 'Tester';
            TestCtct.Email = null;
            TestCtct.Accountid = Testacct.id;
            update TestCtct;
        //system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        system.assertEquals('Testcampaign', testCamp.name);


        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c 
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);
        
        String XMLString = '<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version>';
        XMLstring += '<Application><ID>Salesforce:CnP_PaaS</ID>';
        XMLstring += '<Name>Salesforce:CnP_PaaS</Name>';
        XMLstring += '<Version>8.9004</Version>';
        XMLstring += '</Application>';
        XMLstring += '<Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Test</BillingFirstName>';
        XMLstring += '<BillingMI />';
        XMLstring += '<BillingLastName>Tester</BillingLastName>';
        XMLstring += '<BillingEmail />';
        XMLstring += '<BillingPhone>201-797-6891</BillingPhone>';
        XMLstring += '</BillingInformation>';
        XMLstring += '<BillingAddress><BillingAddress1>67 Bell Avenue</BillingAddress1>';
        XMLstring += '<BillingAddress2 />';
        XMLstring += '<BillingAddress3 />';
        XMLstring += '<BillingCity>Saddle Brook</BillingCity>';
        XMLstring += '<BillingStateProvince>NJ</BillingStateProvince>';
        XMLstring += '<BillingPostalCode>07663</BillingPostalCode>';
        XMLstring += '<BillingCountryName>United States</BillingCountryName>';
        XMLstring += '</BillingAddress>';
        XMLstring += '<ShippingInformation><ShippingContactInformation><ShippingFirstName>Test</ShippingFirstName>';
        XMLstring += '<ShippingMI />';
        XMLstring += '<ShippingLastName>Tester</ShippingLastName>';
        XMLstring += '<ShippingEmail />';
        XMLstring += '<ShippingPhone>201-797-6891</ShippingPhone>';
        XMLstring += '</ShippingContactInformation>';
        XMLstring += '<ShippingAddress><ShippingAddress1>67 Bell Avenue</ShippingAddress1>';
        XMLstring += '<ShippingAddress2 />';
        XMLstring += '<ShippingAddress3 />';
        XMLstring += '<ShippingCity>Saddle Brook</ShippingCity>';
        XMLstring += '<ShippingStateProvince>NJ</ShippingStateProvince>';
        XMLstring += '<ShippingPostalCode>07663</ShippingPostalCode>';
        XMLstring += '<ShippingCountryName>United States</ShippingCountryName>';
        XMLstring += '</ShippingAddress>';
        XMLstring += '</ShippingInformation>';
        XMLstring += '<CustomParameters><Parameter>';
        XMLstring += '<Field>SalesforceContactID</Field>';
        XMLstring += '<Value>003U0000007HFQpIAO</Value>';
        XMLstring += '</Parameter>';
        XMLstring += '</CustomParameters>';
        XMLstring += '</Patron>';
        XMLstring += '<TransactionDetail>';
        XMLstring += '<OrderNumber>1506011028293797797</OrderNumber>';
        XMLstring += '<TransactionID>3904357</TransactionID>';
        XMLstring += '<OrderMode>Live</OrderMode>';
        XMLstring += '<Tracker />';
        XMLstring += '<Campaign />';
        XMLstring += '<TransactionType>Live</TransactionType>';
        XMLstring += '<OrganizationID>21907</OrganizationID>';
        XMLstring += '<OrganizationName>Hackensack Riverkeeper, Inc.</OrganizationName>';
        XMLstring += '<CurrencyCode>840</CurrencyCode>';
        XMLstring += '<AuthorizationCode>04900C</AuthorizationCode>';
        XMLstring += '<WindowName />';
        XMLstring += '<WindowId>-1</WindowId>';
        XMLstring += '<GatewayTransactionNumber>722112640</GatewayTransactionNumber>';
        XMLstring += '<TotalCharge>100.00</TotalCharge>';
        XMLstring += '<TotalDue>100.00</TotalDue>';
        XMLstring += '<DeductibleCharge>0.00</DeductibleCharge>';
        XMLstring += '<DeductibleDue>0.00</DeductibleDue>';
        XMLstring += '<DiscountDue>0.00</DiscountDue>';
        XMLstring += '<DiscountCharge>0.00</DiscountCharge>';
        XMLstring += '<TaxAmountDue>0.00</TaxAmountDue>';
        XMLstring += '<TaxAmountCharge>0.00</TaxAmountCharge>';
        XMLstring += '<SurCharge>0.00</SurCharge>';
        XMLstring += '<ChargAmount>4.00</ChargAmount>';
        XMLstring += '<CouponCode />';
        XMLstring += '<TransactionDiscountDue>0.00</TransactionDiscountDue>';
        XMLstring += '<TransactionDiscountCharge>0.00</TransactionDiscountCharge>';
        XMLstring += '<TransactionTaxDue>0.00</TransactionTaxDue>';
        XMLstring += '<TransactionTaxCharge>0.00</TransactionTaxCharge>';
        XMLstring += '<TransactionDate>2015-06-01 10:28:29</TransactionDate>';
        XMLstring += '<TransactionTimeZone>2015-06-01 10:28:29</TransactionTimeZone>';
        XMLstring += '<UrlReferrer />';
        XMLstring += '<VaultGUID>2b2557c6-25f4-484d-93d5-f1ed13a57d7e</VaultGUID>';
        XMLstring += '<TransactionResult>Authorized</TransactionResult>';
        XMLstring += '<PaymentMethod>';
        XMLstring += '<PaymentType>Credit Card</PaymentType>';
        XMLstring += '<CreditCard>';
        XMLstring += '<NameOnCard>Lorraine Matys</NameOnCard>';
        XMLstring += '<CardName>VISA</CardName>';
        XMLstring += '<ExpirationDate>XXXX</ExpirationDate><CardNumber>XXXXXXXXXXXX7797</CardNumber></CreditCard>';
        XMLstring += '</PaymentMethod>';
        XMLstring += '</TransactionDetail>';
        XMLstring += '<CustomFieldList>';
        XMLstring += '<CustomField>';
        XMLstring += '<FieldName>Additional Information</FieldName>';
        XMLstring += '<FieldValue>4 Meadowlands trips: 7/16, 8/1, 8/16 and 8/29</FieldValue>';
        XMLstring += '</CustomField>';
        XMLstring += '</CustomFieldList>';
        XMLstring += '<OrderItemList>';
        XMLstring += '<OrderItem>';
            XMLstring += '<ItemID>1000</ItemID>';
            XMLstring += '<ItemName>Eco-Cruise: Meadowlands Discovery</ItemName>';
            XMLstring += '<Quantity>4</Quantity>';
            XMLstring += '<UnitPriceCharge>25</UnitPriceCharge>';
            XMLstring += '<UnitPriceDue>25</UnitPriceDue>';
            XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge>';
            XMLstring += '<UnitDeductibleDue>0</UnitDeductibleDue>';
            XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
            XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
            XMLstring += '<DiscountCharge>0</DiscountCharge>';
            XMLstring += '<DiscountDue>0</DiscountDue>';
            XMLstring += '<SKU>Eco-Cruise M</SKU>';
            XMLstring += '<CampaignName>Testcampaign</CampaignName>';
        XMLstring += '</OrderItem>';
        XMLstring += '</OrderItemList>';
        XMLstring += '<Shipping>';
        XMLstring += '<ShippingMethod>Shipping</ShippingMethod>';
        XMLstring += '<ShippingValueCharge>0</ShippingValueCharge>';
        XMLstring += '<ShippingValueDue>0</ShippingValueDue>';
        XMLstring += '<ShippingTaxCharge>0</ShippingTaxCharge>';
        XMLstring += '<ShippingTaxDue>0</ShippingTaxDue>';
        XMLstring += '</Shipping>';
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
        
        // One new donation and one new events payment been created, both linked to the same CnP payment
        Payments = [select id,RecordType.Name,Amount,AccountID,Contact__c,C_P_Data__c,Processing_Fee__c, Attendee__c 
            from Opportunity where Accountid != :TestAcct.Id and campaignid = :TestCamp.id order by amount DESC];
        system.AssertEquals(1,Payments.size(),'If Payments.size is 0 then the identifyOrCreatePerson controller failed to distinguish between two different contacts which both have an email==null.');
        System.assertEquals(100,Payments[0].amount);
        System.assertEquals('Donation',Payments[0].RecordType.Name);
        System.assertEquals(Payments[0].C_P_Data__c,TestData.Id);
        System.assertNotEquals(Payments[0].AccountID,TestAcct.Id);
        System.assertNOtEquals(Payments[0].Contact__c,TestCtct.Id);
        System.assertEquals(Payments[0].Processing_Fee__c,4.00);
    }    
   
// Virtual Terminal Test with CampaignName on Item
    @isTest
    static void VirtualTerminalWithCampaigName() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
            TestCtct.MailingPostalCode = '33332';
            TestCtct.Firstname = 'Test';
            TestCtct.Lastname = 'Tester';
            TestCtct.Email = null;
            TestCtct.Accountid = Testacct.id;
            update TestCtct;
        //system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        system.assertEquals('Testcampaign', testCamp.name);


        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c 
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);
        
        string XMLstring='<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version>';
        XMLstring +='<Application><ID>Salesforce:CnP_PaaS</ID>';
        XMLstring +='<Name>Salesforce:CnP_PaaS</Name>';
        XMLstring +='<Version>8.9004</Version>';
        XMLstring +='</Application>';
        XMLstring +='<Patron>';
        XMLstring +='<BillingInformation><BillingFirstName>Test</BillingFirstName>';
        XMLstring +='<BillingMI />';
        XMLstring +='<BillingLastName>Tester</BillingLastName>';
        XMLstring +='<BillingEmail />';
        XMLstring +='<BillingPhone>201-797-6891</BillingPhone>';
        XMLstring +='</BillingInformation>';
        XMLstring +='<BillingAddress><BillingAddress1>67 Bell Avenue</BillingAddress1>';
        XMLstring +='<BillingAddress2 />';
        XMLstring +='<BillingAddress3 />';
        XMLstring +='<BillingCity>Saddle Brook</BillingCity>';
        XMLstring +='<BillingStateProvince>NJ</BillingStateProvince>';
        XMLstring +='<BillingPostalCode>33332</BillingPostalCode>';
        XMLstring +='<BillingCountryName>United States</BillingCountryName>';
        XMLstring +='</BillingAddress>';
        XMLstring +='<ShippingInformation><ShippingContactInformation><ShippingFirstName>Lorraine</ShippingFirstName>';
        XMLstring +='<ShippingMI />';
        XMLstring +='<ShippingLastName>Matys</ShippingLastName>';
        XMLstring +='<ShippingEmail />';
        XMLstring +='<ShippingPhone>201-797-6891</ShippingPhone>';
        XMLstring +='</ShippingContactInformation>';
        XMLstring +='<ShippingAddress><ShippingAddress1>67 Bell Avenue</ShippingAddress1>';
        XMLstring +='<ShippingAddress2 />';
        XMLstring +='<ShippingAddress3 />';
        XMLstring +='<ShippingCity>Saddle Brook</ShippingCity>';
        XMLstring +='<ShippingStateProvince>NJ</ShippingStateProvince>';
        XMLstring +='<ShippingPostalCode>07663</ShippingPostalCode>';
        XMLstring +='<ShippingCountryName>United States</ShippingCountryName>';
        XMLstring +='</ShippingAddress>';
        XMLstring +='</ShippingInformation>';
        XMLstring +='<CustomParameters><Parameter>';
        XMLstring +='<Field>SalesforceContactID</Field>';
        XMLstring +='<Value>003U0000007HFQpIAO</Value>';
        XMLstring +='</Parameter>';
        XMLstring +='</CustomParameters>';
        XMLstring +='</Patron>';
        XMLstring +='<TransactionDetail>';
        XMLstring +='<OrderNumber>1506011028293797797</OrderNumber>';
        XMLstring +='<TransactionID>3904357</TransactionID>';
        XMLstring +='<OrderMode>Live</OrderMode>';
        XMLstring +='<Tracker />';
        XMLstring +='<Campaign />';
        XMLstring +='<TransactionType>Live</TransactionType>';
        XMLstring +='<OrganizationID>21907</OrganizationID>';
        XMLstring +='<OrganizationName>Hackensack Riverkeeper, Inc.</OrganizationName>';
        XMLstring +='<CurrencyCode>840</CurrencyCode>';
        XMLstring +='<AuthorizationCode>04900C</AuthorizationCode>';
        XMLstring +='<WindowName />';
        XMLstring +='<WindowId>-1</WindowId>';
        XMLstring +='<GatewayTransactionNumber>722112640</GatewayTransactionNumber>';
        XMLstring +='<TotalCharge>100.00</TotalCharge>';
        XMLstring +='<TotalDue>100.00</TotalDue>';
        XMLstring +='<DeductibleCharge>0.00</DeductibleCharge>';
        XMLstring +='<DeductibleDue>0.00</DeductibleDue>';
        XMLstring +='<DiscountDue>0.00</DiscountDue>';
        XMLstring +='<DiscountCharge>0.00</DiscountCharge>';
        XMLstring +='<TaxAmountDue>0.00</TaxAmountDue>';
        XMLstring +='<TaxAmountCharge>0.00</TaxAmountCharge>';
        XMLstring +='<SurCharge>0.00</SurCharge>';
        XMLstring +='<ChargAmount>4.00</ChargAmount>';
        XMLstring +='<CouponCode />';
        XMLstring +='<TransactionDiscountDue>0.00</TransactionDiscountDue>';
        XMLstring +='<TransactionDiscountCharge>0.00</TransactionDiscountCharge>';
        XMLstring +='<TransactionTaxDue>0.00</TransactionTaxDue>';
        XMLstring +='<TransactionTaxCharge>0.00</TransactionTaxCharge>';
        XMLstring +='<TransactionDate>2015-06-01 10:28:29</TransactionDate>';
        XMLstring +='<TransactionTimeZone>2015-06-01 10:28:29</TransactionTimeZone>';
        XMLstring +='<UrlReferrer />';
        XMLstring +='<VaultGUID>2b2557c6-25f4-484d-93d5-f1ed13a57d7e</VaultGUID>';
        XMLstring +='<TransactionResult>Authorized</TransactionResult>';
        XMLstring +='<PaymentMethod>';
        XMLstring +='<PaymentType>Credit Card</PaymentType>';
        XMLstring +='<CreditCard>';
        XMLstring +='<NameOnCard>Lorraine Matys</NameOnCard>';
        XMLstring +='<CardName>VISA</CardName>';
        XMLstring +='<ExpirationDate>XXXX</ExpirationDate><CardNumber>XXXXXXXXXXXX7797</CardNumber></CreditCard>';
        XMLstring +='</PaymentMethod>';
        XMLstring +='</TransactionDetail>';
        XMLstring +='<CustomFieldList>';
        XMLstring +='<CustomField>';
        XMLstring +='<FieldName>Additional Information</FieldName>';
        XMLstring +='<FieldValue>4 Meadowlands trips: 7/16, 8/1, 8/16 and 8/29</FieldValue>';
        XMLstring +='</CustomField>';
        XMLstring +='</CustomFieldList>';
        XMLstring +='<OrderItemList>';
            XMLstring +='<OrderItem>';
                XMLstring +='<ItemID>1000</ItemID>';
                XMLstring +='<ItemName>Eco-Cruise: Meadowlands Discovery</ItemName>';
                XMLstring +='<Quantity>4</Quantity>';
                XMLstring +='<UnitPriceCharge>25</UnitPriceCharge>';
                XMLstring +='<UnitPriceDue>25</UnitPriceDue>';
                XMLstring +='<UnitDeductibleCharge>0</UnitDeductibleCharge>';
                XMLstring +='<UnitDeductibleDue>0</UnitDeductibleDue>';
                XMLstring +='<TaxAmountCharge>0</TaxAmountCharge>';
                XMLstring +='<TaxAmountDue>0</TaxAmountDue>';
                XMLstring +='<DiscountCharge>0</DiscountCharge>';
                XMLstring +='<DiscountDue>0</DiscountDue>';
                XMLstring +='<SKU>Eco-Cruise M</SKU>';
                XMLstring +='<CampaignName>Testcampaign</CampaignName>';
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
        
        // One new donation and one new events payment been created, both linked to the same CnP payment
        Payments = [select id,RecordType.Name,Amount,Campaign.Name, AccountID,Contact__c,C_P_Data__c,Processing_Fee__c, Attendee__c 
            from Opportunity where accountId = :TestAcct.Id];
        system.AssertEquals('Testcampaign',Payments[0].campaign.name);
        system.AssertEquals(1,Payments.size());
        System.assertEquals(100,Payments[0].amount);
    }    

    //eCheck Test
    static void eCheckTest() {
    // Create test string, this time with recurring information
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        system.assertEquals('Testcampaign', testCamp.name);

        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c 
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);

            string XMLstring = '<?xml version="1.0" encoding="UTF-8"?>';
            XMLstring+='<CnPTransactionData><Version>40</Version>';
            XMLstring+='<Patron>';
            XMLstring+='<BillingInformation><BillingFirstName>Test</BillingFirstName>';
            XMLstring+='<BillingMI></BillingMI>';
            XMLstring+='<BillingLastName>TestContact</BillingLastName>';
            XMLstring+='<BillingEmail>test@dontbotherme.org</BillingEmail>';
            XMLstring+='<BillingPhone>651-388-2892</BillingPhone>';
            XMLstring+='</BillingInformation>';
            XMLstring+='<BillingAddress><BillingAddress1>4058 Luverne Dr.</BillingAddress1>';
            XMLstring+='<BillingAddress2></BillingAddress2>';
            XMLstring+='<BillingAddress3></BillingAddress3>';
            XMLstring+='<BillingCity>Red Wing</BillingCity>';
            XMLstring+='<BillingStateProvince>Minnesota</BillingStateProvince>';
            XMLstring+='<BillingPostalCode>55066</BillingPostalCode>';
            XMLstring+='<BillingCountryName>United States</BillingCountryName>';
            XMLstring+='</BillingAddress>';
            XMLstring+='</Patron>';
            XMLstring+='<TransactionDetail>';
            XMLstring+='<OrderNumber>1541011111769659527669</OrderNumber>';
            XMLstring+='<TransactionID>3609932</TransactionID>';
            XMLstring+='<OrderMode>Live</OrderMode>';
            XMLstring+='<Tracker></Tracker>';
            XMLstring+='<Campaign>TestCampaign</Campaign>';
            XMLstring+='<TransactionType>Live</TransactionType>';
            XMLstring+='<OrganizationID>28716</OrganizationID>';
            XMLstring+='<OrganizationName>Cannon River Watershed Partnership, Inc.</OrganizationName>';
            XMLstring+='<CurrencyCode>840</CurrencyCode>';
            XMLstring+='<AuthorizationCode>CHECK IS NOT VERIFIED</AuthorizationCode>';
            XMLstring+='<WindowName>Support CRWP\'s Work for Clean Water</WindowName>';
            XMLstring+='<WindowId>89900</WindowId>';
            XMLstring+='<GatewayTransactionNumber>60859677</GatewayTransactionNumber>';
            XMLstring+='<TotalCharge>10.00</TotalCharge>';
            XMLstring+='<TotalDue>10.00</TotalDue>';
            XMLstring+='<DeductibleCharge>0.00</DeductibleCharge>';
            XMLstring+='<DeductibleDue>0.00</DeductibleDue>';
            XMLstring+='<DiscountDue>0.00</DiscountDue>';
            XMLstring+='<DiscountCharge>0.00</DiscountCharge>';
            XMLstring+='<TaxAmountDue>0.00</TaxAmountDue>';
            XMLstring+='<TaxAmountCharge>0.00</TaxAmountCharge>';
            XMLstring+='<SurCharge>0.00</SurCharge>';
            XMLstring+='<ChargAmount>0.44</ChargAmount>';
            XMLstring+='<CouponCode></CouponCode>';
            XMLstring+='<TransactionDiscountDue>0.00</TransactionDiscountDue>';
            XMLstring+='<TransactionDiscountCharge>0.00</TransactionDiscountCharge>';
            XMLstring+='<TransactionTaxDue>0.00</TransactionTaxDue>';
            XMLstring+='<TransactionTaxCharge>0.00</TransactionTaxCharge>';
            XMLstring+='<TransactionDate>2015-04-10 11:11:00</TransactionDate>';
            XMLstring+='<TransactionTimeZone>2015-04-10 10:11:00</TransactionTimeZone>';
            XMLstring+='<UrlReferrer>http://crwp.net/onething/</UrlReferrer>';
            XMLstring+='<VaultGUID>b5fe90ae-da06-4179-b482-6675a769bf31</VaultGUID>';
            XMLstring+='<TransactionResult>Authorized</TransactionResult>';
            XMLstring+='<PaymentMethod>';
            XMLstring+='<PaymentType>eCheck</PaymentType>';
            XMLstring+='<eCheck>';
            XMLstring+='<CheckNumber>6595</CheckNumber>';
            XMLstring+='<NameOnAccount></NameOnAccount>';
            XMLstring+='</eCheck>';
            XMLstring+='</PaymentMethod>';
            XMLstring+='</TransactionDetail>';
            XMLstring+='<Recurring>';
            XMLstring+='<TransactionResult>Authorized</TransactionResult>';
            XMLstring+='<RecurringID>104251</RecurringID>';
            XMLstring+='<RecurringIDUpdate></RecurringIDUpdate>';
            XMLstring+='<MasterTransactionNumber>1412101842051181895</MasterTransactionNumber>';
            XMLstring+='<Installments>12</Installments>';
            XMLstring+='<RecurringMethod>Subscription</RecurringMethod>';
            XMLstring+='<Periodicity>2 Months</Periodicity>';
            XMLstring+='<InstallmentNumber>3</InstallmentNumber>';
            XMLstring+='<NextInstallmentDate>2015-06-10 00:00:00</NextInstallmentDate>';
            XMLstring+='<InstallmentAmount>10.00</InstallmentAmount>';
            XMLstring+='<TotalAmount>10.00</TotalAmount>';
            XMLstring+='<TotalCommitted>120.00</TotalCommitted>';
            XMLstring+='<TotalMade>30.00</TotalMade>';
            XMLstring+='<TotalDue>90.00</TotalDue>';
            XMLstring+='</Recurring>';
            XMLstring+='<OrderItemList>';
            XMLstring+='<OrderItem>';
            XMLstring+='<ItemID>1616613</ItemID>';
            XMLstring+='<ItemName>Become a Member</ItemName>';
            XMLstring+='<Quantity>1</Quantity>';
            XMLstring+='<UnitPriceCharge>10</UnitPriceCharge>';
            XMLstring+='<UnitPriceDue>10</UnitPriceDue>';
            XMLstring+='<UnitDeductibleCharge>0</UnitDeductibleCharge>';
            XMLstring+='<UnitDeductibleDue>0</UnitDeductibleDue>';
            XMLstring+='<TaxAmountCharge>0</TaxAmountCharge>';
            XMLstring+='<TaxAmountDue>0</TaxAmountDue>';
            XMLstring+='<DiscountCharge>0</DiscountCharge>';
            XMLstring+='<DiscountDue>0</DiscountDue>';
            XMLstring+='<SKU>Membership</SKU>';
            XMLstring+='</OrderItem>';
            XMLstring+='</OrderItemList>';
            XMLstring+='</CnPTransactionData>';
  // create new CnP_Data record
        CnP_PaaS_Bridge__CnPData__c TestData = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = XMLstring,
        CnP_PaaS_Bridge__Order_Number__c = '1207181600564311111',
        CnP_PaaS_Bridge__StatusID__c = 1);
        insert testdata;
        system.debug('Testdata record now contains: '+ testdata);   
        CnP_PaaS_Bridge__CnPData__c TestDataUpdated = [select id, CnP_PaaS_Bridge__DataXML__c from CnP_PaaS_Bridge__CnPData__c
            where id = :testdata.id];
        
        // Have one new donations been created?
        system.debug('TestAcct.id is ' + TestAcct.ID);
        Payments = [select id,Name,CampaignID,Amount,AccountID,Contact__c, Attendee__c
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);
        system.AssertEquals(1,Payments.size());
        system.AssertEquals(10,Payments[0].amount);
        system.AssertEquals(TestAcct.ID, Payments[0].AccountId);
        system.AssertEquals(TestCtct.ID, Payments[0].Contact__c);
        system.AssertEquals(TestCamp.ID,Payments[0].CampaignId);
        System.assertEquals('Test Street',[select id, MailingStreet from contact where id = :TestCtct.id].mailingStreet);
    }

        static testMethod void ConnectDonationWithLeadsource() {           
        // Create test string, this time with campaign in campaign node format as per Connect Donation
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        system.assertEquals('Testcampaign', TestCamp.name);


            Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c 
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);

            string XMLstring = '<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version>';
            XMLstring +='<Application><ID>Salesforce:CnP_PaaS</ID>';
            XMLstring +='<Name>Connect</Name>';
            XMLstring +='<Version>8.9004</Version>';
            XMLstring +='</Application>';
            XMLstring +='<Patron>';
            XMLstring +='<BillingInformation><BillingFirstName>Tester</BillingFirstName>';
            XMLstring +='<BillingMI />';
            XMLstring +='<BillingLastName>TestContact</BillingLastName>';
            XMLstring +='<BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
            XMLstring +='<BillingPhone>(301) 775-5944</BillingPhone>';
            XMLstring +='</BillingInformation>';
            XMLstring +='<BillingAddress><BillingAddress1>675 Mariners Circle</BillingAddress1>';
            XMLstring +='<BillingAddress2 />';
            XMLstring +='<BillingAddress3 />';
            XMLstring +='<BillingCity>Annapolis</BillingCity>';
            XMLstring +='<BillingStateProvince>MD</BillingStateProvince>';
            XMLstring +='<BillingPostalCode>33333</BillingPostalCode>';
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
            XMLstring +='<CustomField>';
            XMLstring +='<FieldName>Would you also like to volunteer?</FieldName>';
            XMLstring +='<FieldValue>Maybe</FieldValue>';
            XMLstring +='</CustomField>';
            XMLstring +='<CustomField>';
            XMLstring +='<FieldName>When are you available to volunteer?</FieldName>';
            XMLstring +='<FieldValue>Weekdays</FieldValue>';
            XMLstring +='</CustomField>';
            XMLstring += '<CustomField>';
            XMLstring += '<FieldName>If this is your first donation or payment to our organization, please tell us how you first heard about us.</FieldName>';
            XMLstring += '<FieldValue>Web</FieldValue>';
            XMLstring += '</CustomField>';
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

        // Map<String, String> parseResults = parseCnPDataXML.parseXML(XMLstring);
        
        
        CnP_PaaS_Bridge__CnPData__c TestData2 = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = XMLstring, 
        CnP_PaaS_Bridge__Order_Number__c = '1207131327206181111');
        insert testdata2;
        
        Payments = [select id,Name,CampaignID,Amount,AccountID,Contact__c, Attendee__c
            from Opportunity ];
        system.debug(Payments);
        system.AssertEquals(1,Payments.size());
        system.AssertEquals(1.00,Payments[0].amount);
        system.AssertEquals(TestAcct.ID, Payments[0].AccountId); 
        system.AssertEquals(TestCtct.ID, Payments[0].Contact__c); 
        system.AssertEquals(TestCamp.ID,Payments[0].CampaignId);
        system.Assert(Payments[0].name.contains('Testcampaign'));
            
        Contact resultContact = [select leadsource from Contact where id =: Payments[0].Contact__c];
         system.assertEquals('Web',resultContact.leadsource);
    } // end test  
    
        static testMethod void ConnectDonationWithOverallExternalCampaignId() {           
        // Create test string, this time with campaign in campaign node format as per Connect Donation
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        system.assertEquals('Testcampaign', testCamp.name);
        string TestCampId = string.valueOf(TestCamp.Id);


            Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c 
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);

            string XMLstring = '<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version>';
            XMLstring +='<Application><ID>Salesforce:CnP_PaaS</ID>';
            XMLstring +='<Name>Connect</Name>';
            XMLstring +='<Version>8.9004</Version>';
            XMLstring +='</Application>';
            XMLstring +='<Patron>';
            XMLstring +='<BillingInformation><BillingFirstName>Tester</BillingFirstName>';
            XMLstring +='<BillingMI />';
            XMLstring +='<BillingLastName>TestContact</BillingLastName>';
            XMLstring +='<BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
            XMLstring +='<BillingPhone>(301) 775-5944</BillingPhone>';
            XMLstring +='</BillingInformation>';
            XMLstring +='<BillingAddress><BillingAddress1>675 Mariners Circle</BillingAddress1>';
            XMLstring +='<BillingAddress2 />';
            XMLstring +='<BillingAddress3 />';
            XMLstring +='<BillingCity>Annapolis</BillingCity>';
            XMLstring +='<BillingStateProvince>MD</BillingStateProvince>';
            XMLstring +='<BillingPostalCode>33333</BillingPostalCode>';
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
            XMLstring +='<CampaignExternalID>'+TestCampId+'</CampaignExternalID>';
            XMLstring +='<CampaignScope>Transaction</CampaignScope>';
            XMLstring +='</CampaignNode>';
            XMLstring +='</CampaignList>';
            XMLstring +='</TransactionDetail>';
            XMLstring +='<CustomFieldList>';
            XMLstring +='<CustomField>';
            XMLstring +='<FieldName>Additional Information</FieldName>';
            XMLstring +='<FieldValue />';
            XMLstring +='</CustomField>';
            XMLstring +='<CustomField>';
            XMLstring +='<FieldName>Would you also like to volunteer?</FieldName>';
            XMLstring +='<FieldValue>Maybe</FieldValue>';
            XMLstring +='</CustomField>';
            XMLstring +='<CustomField>';
            XMLstring +='<FieldName>When are you available to volunteer?</FieldName>';
            XMLstring +='<FieldValue>Weekdays</FieldValue>';
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

        // Map<String, String> parseResults = parseCnPDataXML.parseXML(XMLstring);
        
        
        CnP_PaaS_Bridge__CnPData__c TestData2 = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = XMLstring, 
        CnP_PaaS_Bridge__Order_Number__c = '1207131327206181111');
        insert testdata2;
        
        Payments = [select id,Name,CampaignID,Amount,AccountID,Contact__c, Attendee__c
            from Opportunity ];
        system.debug(Payments);
        system.AssertEquals(1,Payments.size()); 
        system.AssertEquals(TestCamp.ID,Payments[0].CampaignId);
        system.Assert(Payments[0].name.contains('Testcampaign'));
    } // end test      

    // single transaction test with recurring, existing contact, campaign specified, installments=999
    @isTest
    static void SingleRecurringDonationTest() {
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
        XMlstring += '<MasterTransactionNumber>1307101607584781111</MasterTransactionNumber><Installments>999</Installments>';
        XMlstring += '<RecurringMethod>Subscription</RecurringMethod><Periodicity>Monthly</Periodicity>';
        XMlstring += '<InstallmentNumber>1</InstallmentNumber><NextInstallmentDate>2013-08-10 16:08:00</NextInstallmentDate>';
        XMlstring += '<InstallmentAmount>1.00</InstallmentAmount><TotalAmount>1.00</TotalAmount><TotalCommitted>3.00</TotalCommitted>';
        XMlstring += '<TotalMade>1.00</TotalMade><TotalDue>2.00</TotalDue></Recurring>';
        XMLstring += '<OrderItemList>';
        XMLstring += '<OrderItem>';
        XMLstring += '<ItemID>1</ItemID>';
        XMLstring += '<ItemName>Recurring Donation</ItemName>';
        XMLstring += '<Quantity>1</Quantity>';
        XMLstring += '<UnitPriceCharge>1</UnitPriceCharge>';
        XMLstring += '<UnitPriceDue>1</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge>';
        XMLstring += '<UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
        XMLstring += '<DiscountCharge>0</DiscountCharge>';
        XMLstring += '<DiscountDue>0</DiscountDue>';
        XMLstring += '<SKU>Donation</SKU>';
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
        
        //Has TestData credit card # and expiration date been masked?
        Dom.Document docx = new Dom.Document();
        docx.load(TestDataUpdated.CnP_PaaS_Bridge__DataXML__c);
        
        // Has one donation and one pledge been created?
        system.debug('TestAcct.id is ' + TestAcct.ID);
        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c,CnPMasterPledgeID__c,pledge_amount__c,
            CnPMasterTransactionNumber__c,Matches_Which_Challenge_or_Pledge__c,name,RecordType.name,Installment_Nr__c,
            Number_of_Payments__c from Opportunity where Accountid = :TestAcct.Id order by Amount];
                // Two opps created - the pledge and the payment
        system.AssertEquals(2,Payments.size());
        // Is the pledge amount = null and pledge_amount__c = 3 and Number_Installments__c = 3
        system.AssertEquals(null,Payments[0].amount);
        system.Assert(Payments[0].name.CONTAINS('Recurring Payment begun on'),'Installments is 999 so this should be a recurring payment not a pledge.');
        System.assertEquals(0,Payments[0].Pledge_Amount__c,'Installments is 999 so this should be a recurring payment without a pledge amount.');
        // Is the payment amount = 1 and the pledge_amount__c = null and recordType "Donation" and Intallment Number 1?
        system.AssertEquals(1,Payments[1].amount);
        system.AssertEquals(null,Payments[1].pledge_amount__c);
        System.assertEquals('Donation',Payments[1].recordtype.name);
        System.assertEquals(1.0,Payments[1].installment_nr__c);
        // Do the two IDs match for the pledge and payment?
        System.assertEquals(Payments[0].id,Payments[1].Matches_Which_Challenge_or_Pledge__c);
        system.AssertEquals(TestAcct.ID, Payments[0].AccountId);
        system.AssertEquals(TestCtct.ID, Payments[0].Contact__c);
        system.AssertEquals(TestMemberCamp.ID,Payments[0].CampaignId);
    }
 
// recurring transaction test with existing contact, campaign specified, through Gravity Forms
    @isTest
    static void SingleContactTransactionGravityFormsTest() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        system.assertEquals('Testcampaign', testCamp.name);


        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c 
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);
        
        string XMLstring ='<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><PostedDateTime>2016-11-15 08:55:24</PostedDateTime>';
        XMLstring += '<Application><ID>CnP_PaaS_FM_GravityForm</ID><Name>CnP_PaaS_FM_GravityForm</Name><Version>3.400.000/WP:v4.6.1/GF:v2.1.1</Version>';
        XMLstring += '</Application>';
        XMLstring += '<Patron><BillingInformation><BillingFirstName>Tester</BillingFirstName><BillingMI></BillingMI><BillingLastName>TestContact</BillingLastName>';
        XMLstring += '<BillingEmail>testcontact@dontbotherme.org</BillingEmail><BillingPhone>(217) 344-2371</BillingPhone></BillingInformation><BillingAddress><BillingAddress1>1902 Fox Drive</BillingAddress1>';
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


      
  // create new CnP_Data record
        CnP_PaaS_Bridge__CnPData__c TestData = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = XMLstring,
        CnP_PaaS_Bridge__Order_Number__c = '1207181600564311111',
        CnP_PaaS_Bridge__StatusID__c = 1);
        insert testdata;
        system.debug('Testdata record now contains: '+ testdata);   
        CnP_PaaS_Bridge__CnPData__c TestDataUpdated = [select id, CnP_PaaS_Bridge__DataXML__c from CnP_PaaS_Bridge__CnPData__c
            where id = :testdata.id];
        
        // Have one new donations been created?
        system.debug('TestAcct.id is ' + TestAcct.ID);
        Payments = [select id,Name,CampaignID,Campaign.Name,Amount,AccountID,Contact__c, Attendee__c
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);
        system.AssertEquals(2,Payments.size());
        system.AssertEquals(null,Payments[0].amount);
        system.AssertEquals(5,Payments[1].amount);
        //system.AssertEquals(TestAcct.ID, Payments[0].AccountId);
        //system.AssertEquals(TestCtct.ID, Payments[0].Contact__c);
        system.AssertEquals('Testcampaign', Payments[0].Campaign.Name);
        system.AssertEquals(TestCamp.ID,Payments[0].CampaignId);
        system.AssertEquals('Recurring Payment begun on ' + System.today().format(),Payments[0].Name);
    }    
 
    static testmethod void GiftMembershipWithTransactionCampaign() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        system.assertEquals(testAcct.Id, testCtct.AccountId);
        Campaign TestMemberCamp = ctv.fetchTestcampaign();
        TestMemberCamp.name = 'Testcampaign';
        update testMemberCamp;

        
        string XMLstring ='<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Tester</BillingFirstName><BillingMI></BillingMI>';
        XMLstring += '<BillingLastName>TestContact</BillingLastName><BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
        XMLstring += '<BillingPhone>333</BillingPhone></BillingInformation><BillingAddress><BillingAddress1>Test Street</BillingAddress1>';
        XMLstring += '<BillingAddress2></BillingAddress2><BillingAddress3></BillingAddress3><BillingCity>Test City</BillingCity>';
        XMLstring += '<BillingStateProvince>Alabama</BillingStateProvince><BillingPostalCode>33333</BillingPostalCode>';
        XMLstring += '<BillingCountryName>United States of America</BillingCountryName></BillingAddress></Patron>'; 
XMLstring += '<TransactionDetail>';
XMLstring += '<OrderNumber>1612021526446747266</OrderNumber>';
XMLstring += '<ReceiptNumber></ReceiptNumber>';
XMLstring += '<TransactionID>6144849</TransactionID>';
XMLstring += '<OrderMode>Live</OrderMode>';
XMLstring += '<Tracker></Tracker>';
XMLstring += '<Campaign>Testcampaign</Campaign>';
XMLstring += '<TransactionType>Live</TransactionType>';
XMLstring += '<OrganizationID>25820</OrganizationID>';
XMLstring += '<OrganizationName>Prairie Rivers Network</OrganizationName>';
XMLstring += '<CurrencyCode>840</CurrencyCode>';
XMLstring += '<AuthorizationCode>217183</AuthorizationCode>';
XMLstring += '<WindowName></WindowName>';
XMLstring += '<WindowId>-1</WindowId>';
XMLstring += '<GatewayTransactionNumber>987423287</GatewayTransactionNumber>';
XMLstring += '<TotalCharge>2.05</TotalCharge>';
XMLstring += '<TotalDue>2.05</TotalDue>';
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
XMLstring += '<ChargAmount>0.06</ChargAmount>';
XMLstring += '<CouponCode></CouponCode>';
XMLstring += '<TransactionDate>2016-12-02 15:26:44</TransactionDate>';
XMLstring += '<TransactionTimeZone>2016-12-02 08:26:44</TransactionTimeZone>';
XMLstring += '<UrlReferrer>https://prairierivers.org/gift/</UrlReferrer>';
XMLstring += '<VaultGUID>9ddb27c0-8ab0-4d8b-957f-8ba5c3fd4ff0</VaultGUID>';
XMLstring += '<TransactionResult>Authorized</TransactionResult>';
XMLstring += '<PaymentMethod>';
XMLstring += '<PaymentType>Credit Card</PaymentType>';
XMLstring += '<CreditCard>';
XMLstring += '<NameOnCard>Vickie Nudelman</NameOnCard>';
XMLstring += '<CardNumber>44187266</CardNumber>';
XMLstring += '<CardName>VISA</CardName>';
XMLstring += '<ExpirationDate>1801</ExpirationDate>';
XMLstring += '</CreditCard>';
XMLstring += '</PaymentMethod>';
XMLstring += '</TransactionDetail>';
XMLstring += '<CustomFieldList>';
XMLstring += '<CustomField>';
XMLstring += '<FieldName>Gift Membership Recipient:</FieldName>';
XMLstring += '<FieldValue>Final test of gift membership page.</FieldValue>';
XMLstring += '</CustomField>';
XMLstring += '<CustomField>';
XMLstring += '<FieldName>Payment type</FieldName>';
XMLstring += '<FieldValue>Credit Card</FieldValue>';
XMLstring += '</CustomField>';
XMLstring += '</CustomFieldList>';
XMLstring += '<OrderItemList>';
XMLstring += '<OrderItem>';
XMLstring += '<ItemID>101101</ItemID>';
XMLstring += '<ItemName>Other Amount</ItemName>';
XMLstring += '<Quantity>1</Quantity>';
XMLstring += '<UnitPriceCharge>2.05</UnitPriceCharge>';
XMLstring += '<UnitPriceDue>2.05</UnitPriceDue>';
XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge>';
XMLstring += '<UnitDeductibleDue>0</UnitDeductibleDue>';
XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
XMLstring += '<DiscountCharge>0</DiscountCharge>';
XMLstring += '<DiscountDue>0</DiscountDue>';
XMLstring += '<SKU>Membership</SKU>';
XMLstring += '</OrderItem>';
XMLstring += '</OrderItemList>';
XMLstring += '</CnPTransactionData>';

      
  // create new CnP_Data record        
        CnP_PaaS_Bridge__CnPData__c TestData = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = XMLstring,
        CnP_PaaS_Bridge__Order_Number__c = '1611301022402635092',
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
        dom.XmlNode xrrecurring = xroot.getchildelement('Recurring', null) ; //
        
            system.debug('xr2paymentmethodCCName.getText() is ' + xr2paymentmethodCCName.getText());
            system.debug('xr2paymentmethodCCExp.gettext() is ' + xr2paymentmethodCCExp.gettext());
        system.assertEquals(xr2paymentmethodCCNr.gettext(), '44187266');
        
        // Has one donation been created?
        system.debug('TestAcct.id is ' + TestAcct.ID);
        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c,CnPMasterPledgeID__c,pledge_amount__c,
            CnPMasterTransactionNumber__c,Matches_Which_Challenge_or_Pledge__c,name,RecordType.name,Installment_Nr__c,
            Number_of_Payments__c from Opportunity where Accountid = :TestAcct.Id order by Amount];
        
        system.AssertEquals(1,Payments.size());
        system.AssertEquals(2.05,Payments[0].amount);

    } // end MembershipTestWithTransactionCampaign

        static testMethod void ConnectWhyGenericCampaign() {           
        // Teststring from MRK, why isn't the campaign found?
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        system.assertEquals('Testcampaign', TestCamp.name);

            Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c 
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);

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
        
        Payments = [select id,Name,CampaignID,Amount,AccountID,Contact__c, Attendee__c
            from Opportunity ];
        system.debug(Payments);
        system.AssertEquals(1,Payments.size());
        system.AssertEquals(1.00,Payments[0].amount);
        system.AssertEquals(TestCamp.ID,Payments[0].CampaignId);
        system.Assert(Payments[0].name.contains('Testcampaign'));
    } // end test  

// single transaction test with existing contact, campaign specified in orderItem
    static testmethod void SingleContactTransactionCampaignCnPConnectTest() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        system.assertEquals('Testcampaign', testCamp.name);


        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c 
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);
string XMLstring = '<?xml version="1.0" encoding="UTF-8"?>';        
XMLstring+='<CnPTransactionData><Version>40</Version>';
XMLstring+='<PostedDateTime>2017-12-27 13:23:23</PostedDateTime>';
XMLstring+='<Application><Name>Connect.Forms</Name>';
XMLstring+='<Version>1.5</Version>';
XMLstring+='</Application>';
XMLstring+='<Patron>';
XMLstring+='<BillingInformation><BillingFirstName>Paul</BillingFirstName>';
XMLstring+='<BillingMI>E</BillingMI>';
XMLstring+='<BillingLastName>TestContact</BillingLastName>';
XMLstring+='<BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
XMLstring+='<BillingPhone>16109458795</BillingPhone>';
XMLstring+='</BillingInformation>';
XMLstring+='<BillingAddress><BillingAddress1>Test Street</BillingAddress1>';
XMLstring+='<BillingAddress2></BillingAddress2>';
XMLstring+='<BillingAddress3></BillingAddress3>';
XMLstring+='<BillingCity>Media</BillingCity>';
XMLstring+='<BillingStateProvince>Pennsylvania</BillingStateProvince>';
XMLstring+='<BillingPostalCode>33333</BillingPostalCode>';
XMLstring+='<BillingCountryName>United States</BillingCountryName>';
XMLstring+='</BillingAddress>';
XMLstring+='<CustomParameters><Parameter>';
XMLstring+='<Field>SocialComment</Field>';
XMLstring+='<Value></Value>';
XMLstring+='</Parameter>';
XMLstring+='<Parameter>';
XMLstring+='<Field>SocialCommentStatus</Field>';
XMLstring+='<Value>0</Value>';
XMLstring+='</Parameter>';
XMLstring+='</CustomParameters>';
XMLstring+='</Patron>';
XMLstring+='<TransactionDetail>';
XMLstring+='<OrderNumber>28702-1712271323147429925</OrderNumber>';
XMLstring+='<ReceiptNumber></ReceiptNumber>';
XMLstring+='<TransactionID>8063294</TransactionID>';
XMLstring+='<OrderMode>Live</OrderMode>';
XMLstring+='<Tracker></Tracker>';
XMLstring+='<Campaign></Campaign>';
XMLstring+='<ConnectCampaignAlias>MembershipsOnline</ConnectCampaignAlias>';
XMLstring+='<TransactionType>Live</TransactionType>';
XMLstring+='<OrganizationID>28702</OrganizationID>';
XMLstring+='<OrganizationName>ShoreRivers, Inc.</OrganizationName>';
XMLstring+='<CurrencyCode>840</CurrencyCode>';
XMLstring+='<AuthorizationCode>07086D</AuthorizationCode>';
XMLstring+='<WindowName>Membership</WindowName>';
XMLstring+='<WindowId>4a10a15c-d022-4621-8bdd-e1523ec866d0</WindowId>';
XMLstring+='<GatewayTransactionNumber>1204763005</GatewayTransactionNumber>';
XMLstring+='<TotalCharge>500.00</TotalCharge>';
XMLstring+='<TotalDue>500.00</TotalDue>';
XMLstring+='<DeductibleCharge>0.00</DeductibleCharge>';
XMLstring+='<DeductibleDue>0.00</DeductibleDue>';
XMLstring+='<DiscountCharge>0.00</DiscountCharge>';
XMLstring+='<DiscountDue>0.00</DiscountDue>';
XMLstring+='<TaxAmountCharge>0.00</TaxAmountCharge>';
XMLstring+='<TaxAmountDue>0.00</TaxAmountDue>';
XMLstring+='<TransactionDiscountCharge>0.00</TransactionDiscountCharge>';
XMLstring+='<TransactionDiscountDue>0.00</TransactionDiscountDue>';
XMLstring+='<TransactionTaxCharge>0.00</TransactionTaxCharge>';
XMLstring+='<TransactionTaxDue>0.00</TransactionTaxDue>';
XMLstring+='<SurCharge>0.00</SurCharge>';
XMLstring+='<ChargAmount>13.90</ChargAmount>';
XMLstring+='<CouponCode></CouponCode>';
XMLstring+='<TransactionDate>2017-12-27 13:23:14</TransactionDate>';
XMLstring+='<TransactionTimeZone>2017-12-27 13:23:14</TransactionTimeZone>';
XMLstring+='<UrlReferrer></UrlReferrer>';
XMLstring+='<VaultGUID>b609e06c-89b0-4af0-bef6-98ad9de0b7bf</VaultGUID>';
XMLstring+='<TransactionResult>Authorized</TransactionResult>';
XMLstring+='<PaymentMethod>';
XMLstring+='<PaymentType>Credit Card</PaymentType>';
XMLstring+='<CreditCard>';
XMLstring+='<NameOnCard>Paul Edward Schlenker</NameOnCard>';
XMLstring+='<CardNumber>42649925</CardNumber>';
XMLstring+='<CardName>VISA</CardName>';
XMLstring+='<ExpirationDate>2011</ExpirationDate>';
XMLstring+='</CreditCard>';
XMLstring+='</PaymentMethod>';
XMLstring+='<CampaignList><CampaignNode>';
XMLstring+='<CampaignName>Testcampaign</CampaignName>';
XMLstring+='<CampaignID>50244</CampaignID>';
XMLstring+='<AccountID>28702</AccountID>';
XMLstring+='<CampaignExternalID>'+TestCamp.Id+'</CampaignExternalID>';
XMLstring+='<CampaignScope>Transaction</CampaignScope>';
XMLstring+='</CampaignNode>';
XMLstring+='</CampaignList>';
XMLstring+='<CustomParameters><Parameter>';
XMLstring+='<Field>GiveBigCampaignId</Field>';
XMLstring+='<Value>50240</Value>';
XMLstring+='</Parameter>';
XMLstring+='<Parameter>';
XMLstring+='<Field>PostItID</Field>';
XMLstring+='<Value>0</Value>';
XMLstring+='</Parameter>';
XMLstring+='<Parameter>';
XMLstring+='<Field>PostItAlias</Field>';
XMLstring+='<Value></Value>';
XMLstring+='</Parameter>';
XMLstring+='<Parameter>';
XMLstring+='<Field>PaymentWidgetID</Field>';
XMLstring+='<Value>9752</Value>';
XMLstring+='</Parameter>';
XMLstring+='<Parameter>';
XMLstring+='<Field>Pay-04</Field>';
XMLstring+='<Value>Site.20171219.002.018.004</Value>';
XMLstring+='</Parameter>';
XMLstring+='</CustomParameters>';
XMLstring+='</TransactionDetail>';
XMLstring+='<CustomFieldList>';
XMLstring+='<CustomField>';
XMLstring+='<FieldName>Which watershed are you most interested in?</FieldName>';
XMLstring+='<FieldValue>Sassafras River</FieldValue>';
XMLstring+='</CustomField>';
XMLstring+='<CustomField>';
XMLstring+='<FieldName>Would you like your donation to go toward a specific program, project or river? If so, please indicate below.</FieldName>';
XMLstring+='<FieldValue>Sassafras River</FieldValue>';
XMLstring+='</CustomField>';
XMLstring+='<CustomField>';
XMLstring+='<FieldName>Would you like to volunteer with us? Select a volunteer opportunity below.</FieldName>';
XMLstring+='<FieldValue>Select</FieldValue>';
XMLstring+='</CustomField>';
XMLstring+='<CustomField>';
XMLstring+='<FieldName>COMMENTS</FieldName>';
XMLstring+='<FieldValue></FieldValue>';
XMLstring+='</CustomField>';
XMLstring+='</CustomFieldList>';
XMLstring+='<OrderItemList>';
XMLstring+='<OrderItem>';
XMLstring+='<ItemID>0</ItemID>';
XMLstring+='<ItemName>Sustaining Member - 500</ItemName>';
XMLstring+='<Quantity>1</Quantity>';
XMLstring+='<UnitPriceCharge>500</UnitPriceCharge>';
XMLstring+='<UnitPriceDue>500</UnitPriceDue>';
XMLstring+='<UnitDeductibleCharge>0</UnitDeductibleCharge>';
XMLstring+='<UnitDeductibleDue>0</UnitDeductibleDue>';
XMLstring+='<TaxAmountCharge>0</TaxAmountCharge>';
XMLstring+='<TaxAmountDue>0</TaxAmountDue>';
XMLstring+='<DiscountCharge>0</DiscountCharge>';
XMLstring+='<DiscountDue>0</DiscountDue>';
XMLstring+='<SKU>MembershipMembershipMemberships Online</SKU>';
XMLstring+='</OrderItem>';
XMLstring+='</OrderItemList>';
XMLstring+='</CnPTransactionData>';
        
        Map<String, String> parseResults = parseCnPDataXML.parseXML(XMLstring);
		CnP_PaaS_Bridge__CnPData__c TestData2 = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = XMLstring, 
        CnP_PaaS_Bridge__Order_Number__c = '1207131327206181111');
        List<CnP_PaaS_Bridge__CnPData__c> ListTestData = new List<CnP_PaaS_Bridge__CnPData__c>();
            ListTestData.add(TestData2);
        ManageCnPData MCPDB = new ManageCnPData();
        MCPDB.afterInsert(ListTestData,null); 
        system.AssertEquals(TestCamp.Id,MCPDB.WGCampaignId,'Did not identify correct campaign');
        //system.AssertEquals(TestCamp.name,MCPDB.sOptyCampaignName,'Did not identify correct campaign');
        system.debug('NewOpps is ' + MCPDB.NewOpps);
        Opportunity opp = MCPDB.NewOpps[0];
        system.AssertEquals(opp.Amount,500);
        system.AssertEquals('Credit Card through C&P', opp.Payment_Type__c);
        
        system.AssertEquals(TestCamp.Id,opp.campaignID);
        system.AssertEquals(TestCtct.Id,opp.contact__c);
        system.AssertEquals(TestAcct.Id,opp.accountID);


        system.AssertEquals('TestContact',MCPDB.scontact.lastname);
		// BAIRD: RESTORE THE NEXT LINE WHEN WE FIGURE OUT WHAT THE PROBLEM IS.
        String teststring = 'Test Street';
        System.assertEquals(teststring,MCPDB.sContact.mailingStreet.left(11),'Address should have been updated from null to Test Street');        
        System.assertEquals(true,MCPDB.sContact.mailingStreet.contains(teststring),'Address should have been updated from null to Test Street');
        System.assertEquals('33333', MCPDB.sContact.mailingPostalCode,'PostalCode should have been updated from null to 33333');
    }    
    
// single transaction test with existing contact, campaign specified in orderItem
// created Mar 16 2018 to handle errors identified by Jaron at SHTA
    static testmethod void RecurringPaymentWithAdditionalCharge() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        system.assertEquals('Testcampaign', testCamp.name);
        // populate WG_Settings
//        populateWGCustomSettings.populateWGSettings();

        Opportunity [] Payments = [select id,CampaignID,Amount,AccountID,Contact__c 
            from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
        system.debug(Payments);
        
string XMLstring ='<?xml version="1.0" encoding="UTF-8"?>';
XMLstring+='<CnPTransactionData><Version>40</Version>';
XMLstring+='<PostedDateTime>2018-02-13 10:47:19</PostedDateTime>';
XMLstring+='<Application><Name>Connect.Forms</Name>';
XMLstring+='<Version>1.5</Version>';
XMLstring+='</Application>';
XMLstring+='<Patron>';
XMLstring+='<BillingInformation><BillingFirstName>Test</BillingFirstName>';
XMLstring+='<BillingMI></BillingMI>';
XMLstring+='<BillingLastName>Testcontact</BillingLastName>';
XMLstring+='<BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
XMLstring+='<BillingPhone>218-390-4915</BillingPhone>';
XMLstring+='</BillingInformation>';
XMLstring+='<BillingAddress><BillingAddress1>Test Street</BillingAddress1>';
XMLstring+='<BillingAddress2></BillingAddress2>';
XMLstring+='<BillingAddress3></BillingAddress3>';
XMLstring+='<BillingCity>Duluth</BillingCity>';
XMLstring+='<BillingStateProvince>Minnesota</BillingStateProvince>';
XMLstring+='<BillingPostalCode>33333</BillingPostalCode>';
XMLstring+='<BillingCountryName>United States</BillingCountryName>';
XMLstring+='</BillingAddress>';
XMLstring+='<CustomParameters><Parameter>';
XMLstring+='<Field>SocialComment</Field>';
XMLstring+='<Value></Value>';
XMLstring+='</Parameter>';
XMLstring+='<Parameter>';
XMLstring+='<Field>SocialCommentStatus</Field>';
XMLstring+='<Value>0</Value>';
XMLstring+='</Parameter>';
XMLstring+='</CustomParameters>';
XMLstring+='';
XMLstring+='</Patron>';
XMLstring+='<TransactionDetail>';
XMLstring+='<OrderNumber>39196-1802131047104886145</OrderNumber>';
XMLstring+='<ReceiptNumber></ReceiptNumber>';
XMLstring+='<TransactionID>8303416</TransactionID>';
XMLstring+='<OrderMode>Live</OrderMode>';
XMLstring+='<Tracker></Tracker>';
XMLstring+='<Campaign></Campaign>';
XMLstring+='<ConnectCampaignAlias>2018websitegifts</ConnectCampaignAlias>';
XMLstring+='<TransactionType>Live</TransactionType>';
XMLstring+='<OrganizationID>39196</OrganizationID>';
XMLstring+='<OrganizationName>Superior Hiking Trail Association</OrganizationName>';
XMLstring+='<CurrencyCode>840</CurrencyCode>';
XMLstring+='<AuthorizationCode>225562</AuthorizationCode>';
XMLstring+='<WindowName>2018 Website Gifts 8</WindowName>';
XMLstring+='<WindowId>9d7fca76-5b49-4606-a7d3-9df8972a8cc1</WindowId>';
XMLstring+='<GatewayTransactionNumber>1233803501</GatewayTransactionNumber>';
XMLstring+='<TotalCharge>5.54</TotalCharge>';
XMLstring+='<TotalDue>5.54</TotalDue>';
XMLstring+='<DeductibleCharge>0.00</DeductibleCharge>';
XMLstring+='<DeductibleDue>0.00</DeductibleDue>';
XMLstring+='<DiscountCharge>0.00</DiscountCharge>';
XMLstring+='<DiscountDue>0.00</DiscountDue>';
XMLstring+='<TaxAmountCharge>0.00</TaxAmountCharge>';
XMLstring+='<TaxAmountDue>0.00</TaxAmountDue>';
XMLstring+='<TransactionDiscountCharge>0.00</TransactionDiscountCharge>';
XMLstring+='<TransactionDiscountDue>0.00</TransactionDiscountDue>';
XMLstring+='<TransactionTaxCharge>0.00</TransactionTaxCharge>';
XMLstring+='<TransactionTaxDue>0.00</TransactionTaxDue>';
XMLstring+='<SurCharge>0.00</SurCharge>';
XMLstring+='<ChargAmount>0.56</ChargAmount>';
XMLstring+='<CouponCode></CouponCode>';
XMLstring+='<TransactionDate>2018-02-13 10:47:10</TransactionDate>';
XMLstring+='<TransactionTimeZone>2018-02-13 09:47:10</TransactionTimeZone>';
XMLstring+='<UrlReferrer>https://shta.org/donate/</UrlReferrer>';
XMLstring+='<VaultGUID>8584a5b8-479a-43f8-9a81-54eba21dd051</VaultGUID>';
XMLstring+='<TransactionResult>Authorized</TransactionResult>';
XMLstring+='<PaymentMethod>';
XMLstring+='<PaymentType>Credit Card</PaymentType>';
XMLstring+='<CreditCard>';
XMLstring+='<NameOnCard>Marie T Isley</NameOnCard>';
XMLstring+='<CardNumber>46116145</CardNumber>';
XMLstring+='<CardName>VISA</CardName>';
XMLstring+='<ExpirationDate>1803</ExpirationDate>';
XMLstring+='</CreditCard>';
XMLstring+='</PaymentMethod>';
XMLstring+='';
XMLstring+='<CampaignList><CampaignNode>';
XMLstring+='<CampaignName>'+TestCamp.Name+'</CampaignName>';
XMLstring+='<CampaignExternalID>'+TestCamp.Id+'</CampaignExternalID>';
XMLstring+='<CampaignScope>Transaction</CampaignScope>';
XMLstring+='</CampaignNode>';
XMLstring+='</CampaignList>';
XMLstring+='<CustomParameters>';
XMLstring+='<Parameter>';
XMLstring+='<Field>GiveBigCampaignId</Field>';
XMLstring+='<Value>49012</Value>';
XMLstring+='</Parameter>';
XMLstring+='<Parameter>';
XMLstring+='<Field>PostItID</Field>';
XMLstring+='<Value>0</Value>';
XMLstring+='</Parameter>';
XMLstring+='<Parameter>';
XMLstring+='<Field>PostItAlias</Field>';
XMLstring+='<Value></Value>';
XMLstring+='</Parameter>';
XMLstring+='<Parameter>';
XMLstring+='<Field>PaymentWidgetID</Field>';
XMLstring+='<Value>10935</Value>';
XMLstring+='</Parameter>';
XMLstring+='<Parameter>';
XMLstring+='<Field>Pay-02</Field>';
XMLstring+='<Value>Site.20180207.002.018.010</Value>';
XMLstring+='</Parameter>';
XMLstring+='</CustomParameters></TransactionDetail>';
XMLstring+='<Recurring>';
XMLstring+='<TransactionResult>Authorized</TransactionResult>';
XMLstring+='<RecurringStatus>Active</RecurringStatus>';
XMLstring+='<RecurringID>319266</RecurringID>';
XMLstring+='<RecurringIDUpdate></RecurringIDUpdate>';
XMLstring+='<MasterTransactionNumber>39196-1802131047104886145</MasterTransactionNumber>';
XMLstring+='<MasterTransactionDate>2018-02-13 09:47:10</MasterTransactionDate>';
XMLstring+='<Installments>999</Installments>';
XMLstring+='<ToDateRemainingInstallments>998</ToDateRemainingInstallments>';
XMLstring+='<RecurringMethod>Subscription</RecurringMethod>';
XMLstring+='<Periodicity>Monthly</Periodicity>';
XMLstring+='<InstallmentNumber>1</InstallmentNumber>';
XMLstring+='<NextInstallmentDate>2018-03-13 09:47:00</NextInstallmentDate>';
XMLstring+='<InstallmentAmount>5.54</InstallmentAmount>';
XMLstring+='<TotalAmount>5.54</TotalAmount>';
XMLstring+='<TotalCommitted>5534.46</TotalCommitted>';
XMLstring+='<TotalMade>5.54</TotalMade>';
XMLstring+='<TotalDue>5528.92</TotalDue>';
XMLstring+='';
XMLstring+='</Recurring>';
XMLstring+='<CustomFieldList>';
XMLstring+='<CustomField>';
XMLstring+='<FieldName>Please provide the name and address of the recipient.</FieldName>';
XMLstring+='<FieldValue></FieldValue>';
XMLstring+='</CustomField>';
XMLstring+='';
XMLstring+='</CustomFieldList>';
XMLstring+='<OrderItemList>';
XMLstring+='<OrderItem>';
XMLstring+='<ItemID>0</ItemID>';
XMLstring+='<ItemName>Generic Donation</ItemName>';
XMLstring+='<Quantity>1</Quantity>';
XMLstring+='<UnitPriceCharge>5</UnitPriceCharge>';
XMLstring+='<UnitPriceDue>5</UnitPriceDue>';
XMLstring+='<UnitDeductibleCharge>0</UnitDeductibleCharge>';
XMLstring+='<UnitDeductibleDue>0</UnitDeductibleDue>';
XMLstring+='<TaxAmountCharge>0</TaxAmountCharge>';
XMLstring+='<TaxAmountDue>0</TaxAmountDue>';
XMLstring+='<DiscountCharge>0</DiscountCharge>';
XMLstring+='<DiscountDue>0</DiscountDue>';
XMLstring+='<SKU>Donation</SKU>';
XMLstring+='<CampaignList><CampaignNode>';
XMLstring+='<CampaignName>2018 Website Gifts</CampaignName>';
XMLstring+='<CampaignExternalID>7011I0000001Hla</CampaignExternalID>';
XMLstring+='<CampaignScope>Transaction</CampaignScope>';
XMLstring+='</CampaignNode>';
XMLstring+='</CampaignList>';
XMLstring+='</OrderItem>';
XMLstring+='<OrderItem>';
XMLstring+='<ItemID>0</ItemID>';
XMLstring+='<ItemName>Additional Fee</ItemName>';
XMLstring+='<Quantity>1</Quantity>';
XMLstring+='<UnitPriceCharge>0.54</UnitPriceCharge>';
XMLstring+='<UnitPriceDue>0.54</UnitPriceDue>';
XMLstring+='<UnitDeductibleCharge>0</UnitDeductibleCharge>';
XMLstring+='<UnitDeductibleDue>0</UnitDeductibleDue>';
XMLstring+='<TaxAmountCharge>0</TaxAmountCharge>';
XMLstring+='<TaxAmountDue>0</TaxAmountDue>';
XMLstring+='<DiscountCharge>0</DiscountCharge>';
XMLstring+='<DiscountDue>0</DiscountDue>';
XMLstring+='<SKU></SKU>';
XMLstring+='<CampaignList><CampaignNode>';
XMLstring+='<CampaignName>2018 Website Gifts</CampaignName>';
XMLstring+='<CampaignExternalID>7011I0000001Hla</CampaignExternalID>';
XMLstring+='<CampaignScope>Transaction</CampaignScope>';
XMLstring+='</CampaignNode>';
XMLstring+='</CampaignList>';
XMLstring+='</OrderItem>';
XMLstring+='';
XMLstring+='</OrderItemList>';
XMLstring+='</CnPTransactionData>';
        
        Map<String, String> parseResults = parseCnPDataXML.parseXML(XMLstring);
		CnP_PaaS_Bridge__CnPData__c TestData2 = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = XMLstring, 
        CnP_PaaS_Bridge__Order_Number__c = '1207131327206181111');
        List<CnP_PaaS_Bridge__CnPData__c> ListTestData = new List<CnP_PaaS_Bridge__CnPData__c>();
            ListTestData.add(TestData2);
        ManageCnPData MCPDB = new ManageCnPData();
        MCPDB.afterInsert(ListTestData,null);  
        system.AssertEquals(TestCamp.Id,MCPDB.WGCampaignId,'Did not identify correct campaign');
        //system.AssertEquals(TestCamp.name,MCPDB.sOptyCampaignName,'Did not identify correct campaign');
        system.debug('NewOpps is ' + MCPDB.NewOpps);
        Opportunity opp = MCPDB.NewOpps[0];
        system.AssertEquals(5,opp.Amount);
        system.AssertEquals('Credit Card through C&P', opp.Payment_Type__c);
        
        system.AssertEquals(TestCamp.Id,opp.campaignID);
        system.AssertEquals(TestCtct.Id,opp.contact__c);
        system.AssertEquals(TestAcct.Id,opp.accountID);

        system.AssertEquals('TestContact',MCPDB.scontact.lastname);
		// BAIRD: RESTORE THE NEXT LINE WHEN WE FIGURE OUT WHAT THE PROBLEM IS.
        String teststring = 'Test Street';
        System.assertEquals(teststring,MCPDB.sContact.mailingStreet.left(11),'Address should have been updated from null to Test Street');        
        System.assertEquals(true,MCPDB.sContact.mailingStreet.contains(teststring),'Address should have been updated from null to Test Street');
        System.assertEquals('33333', MCPDB.sContact.mailingPostalCode,'PostalCode should have been updated from null to 33333');
        // TEST THAT ADDITIONAL FEE DOESN'T RESULT IN DUPLICATE DONATION
        System.assertEquals(2,MCPDB.newOpps.size(),'Should have been two order items');
        System.assertEquals(5.54,MCPDB.NewOpps[0].amount + MCPDB.NewOpps[1].amount,'Two item amounts should equal total paid amount');
        
        // Has only one pledge been created?
        List<Opportunity> TestPledges = [select id, Installment_Amount__c from Opportunity where recordType.Name = 'Pledge'];
        system.assertEquals(1,TestPledges.size(),'The DATAXML had two orderitems but should only have created one pledge.');
        system.assertEquals(5.54,TestPledges[0].Installment_Amount__c,'Pledge.Installment_Amount__c should come from parseresults.installmentamount.');        
    } 
    
    @isTest
    static void SingleLeadWithLeadSource() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Lead TestLead = ctv.fetchTestLead();
        system.assertEquals('TestLead', testLead.lastname);
        Campaign TestCamp = ctv.fetchTestcampaign();
        TestCamp.name = 'Reviving the Dream (2017)';
        update TestCamp;


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