@isTest 
private class LogErrorTest {
    
    static testmethod void InsertOppNoCampaign() {    
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestMemberCamp = ctv.fetchTestcampaign();
        TestMemberCamp.name = 'Test Membership Campaign';
        update testMemberCamp;
//    CreateCustomSettings.createCustomSettings();
        
        // ManageCnPData MCnPD = new ManageCnPData();
        // Create CnP Data List
        string XMLstring ='<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Tester</BillingFirstName><BillingMI></BillingMI>';
        XMLstring += '<BillingLastName>Tester</BillingLastName><BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
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
		List<string> DataXMLs = new List<string>();
        DataXMLs.add(XMLstring);
        DataXMLs.add(XMLstring+'2');
      
  // create new CnP_Data record        
        // CnP_PaaS_Bridge__CnPData__c TestData = new CnP_PaaS_Bridge__CnPData__c(
        // CnP_PaaS_Bridge__DataXML__c = XMLstring,
        // CnP_PaaS_Bridge__Order_Number__c = '1207181600564311111',
        // CnP_PaaS_Bridge__StatusID__c = 1);
        // MCnPD.NewData = new List<CnP_PaaS_Bridge__CnPData__c>();
        // MCnPD.newData.add(TestData);
        // MCnPD.DataXMLs.add(XMLstring);
        
        Opportunity Opp1 = new Opportunity(
            name = 'TestOpp',
            amount = 1.11,
            RecordTypeId = [select id from RecordType where name = 'Donation'][0].id,
            accountid = TestAcct.id,
            contact__c = TestCtct.id);
        Opportunity Opp2 = new Opportunity(
            name = 'TestOpp',
            amount = 2.22,
            RecordTypeId = [select id from RecordType where name = 'Donation'][0].id,
            accountid = TestAcct.id,
            contact__c = TestCtct.id);
        List<Opportunity> ListOpps = new List<Opportunity>();
        ListOpps.add(Opp1);
        ListOpps.add(Opp2);
        // MCnPD.newOpps.add(Opp);
        // Insert ListOpps, generate "no campaign" errors;
        List<Database.SaveResult> SRList = database.insert(ListOpps, false);
        // Insert errors in log
       LogError LE = new LogError();
       List<WG_Error_Log__c> results = LE.LogCnPOppInsertError(SRList, ListOpps, DataXMLs);
                
        List<WG_Error_Log__c> TestErrLog = [select id, Category__c, Description__c from WG_Error_Log__c];
        system.AssertEquals(2,TestErrLog.size());
        system.AssertEquals(XMLstring,TestErrLog[0].Description__c);
        
        
    }//end InsertOppNoCampaign    

/*        
    static testmethod void InsertBadXML() {    
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestMemberCamp = ctv.fetchTestcampaign();
        TestMemberCamp.name = 'Test Membership Campaign';
        update testMemberCamp;
        
        ManageCnPData MCnPD = new ManageCnPData();
        // Create CnP Data List
        string XMLstring ='<?xml version="1.0" encoding="UTF-8"?><CnPTransactionData><Version>40</Version><Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Tester</BillingFirstName><BillingMI></BillingMI>';
        XMLstring += '</OrderItemList></CnPTransactionData>';

      
  // create new CnP_Data record        
        CnP_PaaS_Bridge__CnPData__c TestData = new CnP_PaaS_Bridge__CnPData__c(
        CnP_PaaS_Bridge__DataXML__c = XMLstring,
        CnP_PaaS_Bridge__Order_Number__c = '1207181600564311111',
        CnP_PaaS_Bridge__StatusID__c = 1);
        insert TestData;
        
        List<WG_Error_Log__c> TestErrLog = [select id, Category__c, Description__c from WG_Error_Log__c];
        system.AssertEquals(2,TestErrLog.size());
        system.debug('First error is: ' + TestErrLog[0]);
        system.debug('Second error is: ' + TestErrLog[1]);
        

    }  */
}