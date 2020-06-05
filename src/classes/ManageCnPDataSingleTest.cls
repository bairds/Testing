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
    static void RenewalEmailError() {
        Create_Test_Variables ctv = new Create_Test_Variables();
        Account TestAcct = ctv.fetchTestAccount();
        system.assertEquals('TestAccount', testAcct.name);
        Contact TestCtct = ctv.fetchTestContact();
        // TestCtct.firstname = 'Tester';
        // update TestCtct;
        system.assertEquals('TestContact', testCtct.lastname);
        Campaign TestMemberCamp = ctv.fetchTestcampaign();
        TestMemberCamp.name = 'Test Membership Campaign';
        update testMemberCamp;

        string XMLstring = '<?xml version="1.0" encoding="UTF-8"?>';
        XMLstring += '<CnPTransactionData><Version>40</Version>';
        XMLstring += '<PostedDateTime>2020-01-09 23:04:42</PostedDateTime>';
        XMLstring += '<Application><Name>Connect.Forms</Name>';
        XMLstring += '<Version>1.5</Version>';
        XMLstring += '</Application>';
        XMLstring += '<Patron>';
        XMLstring += '<BillingInformation><BillingFirstName>Bill</BillingFirstName>';
        XMLstring += '<BillingMI></BillingMI>';
        XMLstring += '<BillingLastName>Test</BillingLastName>';
        XMLstring += '<BillingEmail>bdstraughan@gmail.com</BillingEmail>';
        XMLstring += '<BillingPhone>3333333333333</BillingPhone>';
        XMLstring += '</BillingInformation>';
        XMLstring += '<BillingAddress><BillingAddress1>7110 Sleaford Pl</BillingAddress1>';
        XMLstring += '<BillingAddress2></BillingAddress2>';
        XMLstring += '<BillingAddress3></BillingAddress3>';
        XMLstring += '<BillingCity>Bethesda</BillingCity>';
        XMLstring += '<BillingStateProvince>Maryland</BillingStateProvince>';
        XMLstring += '<BillingPostalCode>20814</BillingPostalCode>';
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
        XMLstring += '';
        XMLstring += '</Patron>';
        XMLstring += '<TransactionDetail>';
        XMLstring += '<OrderNumber>18801-2001092304336451111</OrderNumber>';
        XMLstring += '<ReceiptNumber></ReceiptNumber>';
        XMLstring += '<TransactionID>13503312</TransactionID>';
        XMLstring += '<OrderMode>Live</OrderMode>';
        XMLstring += '<Tracker>0060W000010mzEf</Tracker>';
        XMLstring += '<ConnectCampaignAlias>RenewalsOnline</ConnectCampaignAlias>';
        XMLstring += '<TransactionType>Live</TransactionType>';
        XMLstring += '<OrganizationID>18801</OrganizationID>';
        XMLstring += '<OrganizationName>LeadGreen.org</OrganizationName>';
        XMLstring += '<CurrencyCode>840</CurrencyCode>';
        XMLstring += '<AuthorizationCode>374870</AuthorizationCode>';
        XMLstring += '<WindowName>Online Renewals for WRA</WindowName>';
        XMLstring += '<WindowId>4938b482-5b02-40f7-8d05-cc333a234751</WindowId>';
        XMLstring += '<GatewayTransactionNumber>5e17274e-fd3b-3000-0087-0003ba9896f7</GatewayTransactionNumber>';
        XMLstring += '<TotalCharge>1.11</TotalCharge>';
        XMLstring += '<TotalDue>1.11</TotalDue>';
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
        XMLstring += '<ChargeAmount>0.00</ChargeAmount>';
        XMLstring += '<CouponCode></CouponCode>';
        XMLstring += '<TransactionDate>2020-01-09 23:04:33</TransactionDate>';
        XMLstring += '<TransactionTimeZone>2020-01-09 23:04:33</TransactionTimeZone>';
        XMLstring += '<UrlReferrer>https://watergrass-demo-dev-ed--c.documentforce.com/</UrlReferrer>';
        XMLstring += '<VaultGUID>2200edda-0e81-4db3-af9b-3aedc533a14e</VaultGUID>';
        XMLstring += '<TransactionResult>Authorized</TransactionResult>';
        XMLstring += '<PaymentMethod>';
        XMLstring += '<PaymentType>Credit Card</PaymentType>';
        XMLstring += '<CreditCard>';
        XMLstring += '<NameOnCard>Bill Test</NameOnCard>';
        XMLstring += '<CardNumber>41111111</CardNumber>';
        XMLstring += '<CardName>VISA</CardName>';
        XMLstring += '<ExpirationDate>2112</ExpirationDate>';
        XMLstring += '</CreditCard>';
        XMLstring += '</PaymentMethod>';
        XMLstring += '';
        XMLstring += '<CampaignList><CampaignNode>';
        XMLstring += '<CampaignName>Renewals Online</CampaignName>';
        XMLstring += '<CampaignID>69466</CampaignID>';
        XMLstring += '<AccountID>18801</AccountID>';
        XMLstring += '<CampaignExternalID>'+TestMemberCamp.Id+'</CampaignExternalID>';
        XMLstring += '<CampaignScope>Transaction</CampaignScope>';
        XMLstring += '</CampaignNode>';
        XMLstring += '</CampaignList>';
        XMLstring += '<CustomParameters>';
        XMLstring += '<Parameter>';
        XMLstring += '<Field>GiveBigCampaignId</Field>';
        XMLstring += '<Value>49491</Value>';
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
        XMLstring += '<Value>9389</Value>';
        XMLstring += '</Parameter>';
        XMLstring += '<Parameter>';
        XMLstring += '<Field>Pay-01</Field>';
        XMLstring += '<Value>Site.20191204.002.030.017</Value>';
        XMLstring += '</Parameter>';
        XMLstring += '<Parameter>';
        XMLstring += '<Field>ConnectCampaignId</Field>';
        XMLstring += '<Value>49491</Value>';
        XMLstring += '</Parameter>';
        XMLstring += '</CustomParameters></TransactionDetail>';
        XMLstring += '<CustomFieldList>';
        XMLstring += '<CustomField>';
        XMLstring += '<FieldName>Please tell us about the issues or activities that you would like to be involved with.</FieldName>';
        XMLstring += '<FieldValue></FieldValue>';
        XMLstring += '</CustomField>';
        XMLstring += '';
        XMLstring += '</CustomFieldList>';
        XMLstring += '<OrderItemList>';
        XMLstring += '<OrderItem>';
        XMLstring += '<ItemID>1400</ItemID>';
        XMLstring += '<ItemName>20 Membership Online</ItemName>';
        XMLstring += '<Quantity>1</Quantity>';
        XMLstring += '<UnitPriceCharge>1.11</UnitPriceCharge>';
        XMLstring += '<UnitPriceDue>1.11</UnitPriceDue>';
        XMLstring += '<UnitDeductibleCharge>0</UnitDeductibleCharge>';
        XMLstring += '<UnitDeductibleDue>0</UnitDeductibleDue>';
        XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
        XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
        XMLstring += '<DiscountCharge>0</DiscountCharge>';
        XMLstring += '<DiscountDue>0</DiscountDue>';
        XMLstring += '<SKU>Membership</SKU>';
        XMLstring += '</OrderItem>';
        XMLstring += '';
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
            List<Opportunity> Payments = [select id,Name, CampaignID,Amount,AccountID,Contact__c, Campaign.Id, campaign.Name, Account.Name, Attendee__c from Opportunity ];
        system.debug('Payments is ' + Payments);
        system.assertEquals(1.11,Payments[0].Amount);
        system.assertEquals('Test, Bill Household',Payments[0].account.name,'Should have created a payment for Tester, Test Household');
        // system.assertEquals('Test Membership Campaign', Payments[0].campaign.name,'Should have pulled name from OrderItem.CampaignExternalId');
        // system.assertEquals(TestMemberCamp.Id, Payments[0].campaign.Id,'Should have pulled Id from OrderItem.CampaignExternalId');
 } // end test

} // end class