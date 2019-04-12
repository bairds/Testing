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

    @istest
    static void ConnectDonation() {
    // Create test string, this time with campaign in campaign node format as per Connect Donation
    Create_Test_Variables ctv = new Create_Test_Variables();
    Account TestAcct = ctv.fetchTestAccount();
    system.assertEquals('TestAccount', testAcct.name);
    Contact TestCtct = ctv.fetchTestContact();
    system.assertEquals('TestContact', testCtct.lastname);
    Campaign TestCamp = ctv.fetchTestcampaign();
    TestCamp.name = 'Membership Renewal';
    update TestCamp;
    system.assertEquals('Membership Renewal', TestCamp.name);
    // createCustomSettings CCS = new createCustomSettings();
    CreateCustomSettings.createCustomSettings();
Opportunity [] PaymentsBefore = [select id,CampaignID,Amount,AccountID,Contact__c
from Opportunity where Accountid = :TestAcct.Id and campaignid = :TestCamp.id];
system.debug('Have inserted these payments:' + PaymentsBefore);
        PaymentsBefore = [select id,Name,CampaignID,Amount,AccountID,Contact__c, Account.Name, Attendee__c
        from Opportunity ];
        system.debug('Before inserting DataXML we have ' + PaymentsBefore.size() + ' payments.');

string XMLstring = '<?xml version="1.0" encoding="UTF-8"?>';
XMLstring += '<CnPTransactionData><Version>40</Version>';
XMLstring += '<PostedDateTime>2019-04-07 12:53:44</PostedDateTime>';
XMLstring += '<Application><Name>AM</Name>';
XMLstring += '<Version>1.0</Version>';
XMLstring += '</Application>';
XMLstring += '<Patron>';
XMLstring += '<BillingInformation><BillingFirstName>Test</BillingFirstName>';
XMLstring += '<BillingMI></BillingMI>';
XMLstring += '<BillingLastName>TestContact</BillingLastName>';
XMLstring += '<BillingEmail>testcontact@dontbotherme.org</BillingEmail>';
XMLstring += '<BillingPhone>2698613001</BillingPhone>';
XMLstring += '</BillingInformation>';
XMLstring += '<BillingAddress><BillingAddress1>1618 Pear St</BillingAddress1>';
XMLstring += '<BillingAddress2></BillingAddress2>';
XMLstring += '<BillingAddress3></BillingAddress3>';
XMLstring += '<BillingCity>Ann Arbor</BillingCity>';
XMLstring += '<BillingStateProvince>Michigan</BillingStateProvince>';
XMLstring += '<BillingPostalCode>48105</BillingPostalCode>';
XMLstring += '<BillingCountryName>United States</BillingCountryName>';
XMLstring += '</BillingAddress>';
XMLstring += '';
XMLstring += '</Patron>';
XMLstring += '<TransactionDetail>';
XMLstring += '<OrderNumber>29011-190407125336798</OrderNumber>';
XMLstring += '<ReceiptNumber></ReceiptNumber>';
XMLstring += '<TransactionID>11104408</TransactionID>';
XMLstring += '<OrderMode>Live</OrderMode>';
XMLstring += '<Tracker></Tracker>';
XMLstring += '<Campaign>New Membership</Campaign>';
XMLstring += '<ConnectCampaignAlias>membership-renewal</ConnectCampaignAlias>';
XMLstring += '<TransactionType>Live</TransactionType>';
XMLstring += '<OrganizationID>29011</OrganizationID>';
XMLstring += '<OrganizationName>Huron River Watershed Council</OrganizationName>';
XMLstring += '<CurrencyCode>840</CurrencyCode>';
XMLstring += '<AuthorizationCode>148571</AuthorizationCode>';
XMLstring += '<WindowName>New Membership</WindowName>';
XMLstring += '<WindowId>90740</WindowId>';
XMLstring += '<GatewayTransactionNumber>1490786489</GatewayTransactionNumber>';
XMLstring += '<TotalCharge>10.00</TotalCharge>';
XMLstring += '<TotalDue>10.00</TotalDue>';
XMLstring += '<DeductibleCharge>10.00</DeductibleCharge>';
XMLstring += '<DeductibleDue>10.00</DeductibleDue>';
XMLstring += '<DiscountCharge>0.00</DiscountCharge>';
XMLstring += '<DiscountDue>0.00</DiscountDue>';
XMLstring += '<TaxAmountCharge>0.00</TaxAmountCharge>';
XMLstring += '<TaxAmountDue>0.00</TaxAmountDue>';
XMLstring += '<TransactionDiscountCharge>0.00</TransactionDiscountCharge>';
XMLstring += '<TransactionDiscountDue>0.00</TransactionDiscountDue>';
XMLstring += '<TransactionTaxCharge>0.00</TransactionTaxCharge>';
XMLstring += '<TransactionTaxDue>0.00</TransactionTaxDue>';
XMLstring += '<SurCharge>0.00</SurCharge>';
XMLstring += '<ChargAmount>0.04</ChargAmount>';
XMLstring += '<CouponCode></CouponCode>';
XMLstring += '<TransactionDate>2019-04-07 12:53:36</TransactionDate>';
XMLstring += '<TransactionTimeZone>2019-04-07 12:53:36</TransactionTimeZone>';
XMLstring += '<UrlReferrer>http://www.hrwc.org/donate/membership.html</UrlReferrer>';
XMLstring += '<VaultGUID>77212401-2a7e-472c-b962-7ef6be66c7e2</VaultGUID>';
XMLstring += '<TransactionResult>Authorized</TransactionResult>';
XMLstring += '<PaymentMethod>';
XMLstring += '<PaymentType>Credit Card</PaymentType>';
XMLstring += '<CreditCard>';
XMLstring += '<NameOnCard>Test TestContact</NameOnCard>';
XMLstring += '<CardNumber>37953111</CardNumber>';
XMLstring += '<CardName>American Express</CardName>';
XMLstring += '<ExpirationDate>2107</ExpirationDate>';
XMLstring += '</CreditCard>';
XMLstring += '</PaymentMethod>';
XMLstring += '';
XMLstring += '<CampaignList><CampaignNode>';
XMLstring += '<CampaignName>Membership</CampaignName>';
XMLstring += '<CampaignID>43728</CampaignID>';
XMLstring += '<AccountID>29011</AccountID>';
XMLstring += '<CampaignExternalID>'+TestCamp.Id+'</CampaignExternalID>';
XMLstring += '<CampaignScope>Transaction</CampaignScope>';
XMLstring += '</CampaignNode>';
XMLstring += '</CampaignList>';
XMLstring += '</TransactionDetail>';
XMLstring += '<Recurring>';
XMLstring += '<TransactionResult>Authorized</TransactionResult>';
XMLstring += '<RecurringStatus>Active</RecurringStatus>';
XMLstring += '<RecurringID>213534</RecurringID>';
XMLstring += '<RecurringIDUpdate></RecurringIDUpdate>';
XMLstring += '<MasterTransactionNumber>1609071021080923000</MasterTransactionNumber>';
XMLstring += '<MasterTransactionDate>2016-09-07 10:21:00</MasterTransactionDate>';
XMLstring += '<Installments>999</Installments>';
XMLstring += '<ToDateRemainingInstallments>967</ToDateRemainingInstallments>';
XMLstring += '<RecurringMethod>Subscription</RecurringMethod>';
XMLstring += '<Periodicity>Monthly</Periodicity>';
XMLstring += '<InstallmentNumber>32</InstallmentNumber>';
XMLstring += '<NextInstallmentDate>2019-05-07 00:00:00</NextInstallmentDate>';
XMLstring += '<InstallmentAmount>10.00</InstallmentAmount>';
XMLstring += '<TotalAmount>10.00</TotalAmount>';
XMLstring += '<TotalCommitted>9990.00</TotalCommitted>';
XMLstring += '<TotalMade>320.00</TotalMade>';
XMLstring += '<TotalDue>9670.00</TotalDue>';
XMLstring += '';
XMLstring += '</Recurring>';
XMLstring += '<CustomFieldList>';
XMLstring += '<CustomField>';
XMLstring += '<FieldName>How did you hear about HRWC?</FieldName>';
XMLstring += '<FieldValue>Web</FieldValue>';
XMLstring += '</CustomField>';
XMLstring += '<CustomField>';
XMLstring += '<FieldName>Online newsletter only?</FieldName>';
XMLstring += '<FieldValue>Yes</FieldValue>';
XMLstring += '</CustomField>';
XMLstring += '';
XMLstring += '</CustomFieldList>';
XMLstring += '<OrderItemList>';
XMLstring += '<OrderItem>';
XMLstring += '<ItemID>2507190</ItemID>';
XMLstring += '<ItemName>Additional Donation or Other Amount</ItemName>';
XMLstring += '<Quantity>1</Quantity>';
XMLstring += '<UnitPriceCharge>10</UnitPriceCharge>';
XMLstring += '<UnitPriceDue>10</UnitPriceDue>';
XMLstring += '<UnitDeductibleCharge>10</UnitDeductibleCharge>';
XMLstring += '<UnitDeductibleDue>10</UnitDeductibleDue>';
XMLstring += '<TaxAmountCharge>0</TaxAmountCharge>';
XMLstring += '<TaxAmountDue>0</TaxAmountDue>';
XMLstring += '<DiscountCharge>0</DiscountCharge>';
XMLstring += '<DiscountDue>0</DiscountDue>';
XMLstring += '<SKU>Donation</SKU>';
XMLstring += '</OrderItem>';
XMLstring += '';
XMLstring += '</OrderItemList>';
XMLstring += '</CnPTransactionData>';

CnP_PaaS_Bridge__CnPData__c TestData2 = new CnP_PaaS_Bridge__CnPData__c(
CnP_PaaS_Bridge__DataXML__c = XMLstring,
CnP_PaaS_Bridge__Order_Number__c = '1207131327206181111');
insert testdata2;

List<Opportunity> PaymentsAfter = [select id,Name,CampaignID,Amount,AccountID,Contact__c, Account.Name, Attendee__c
from Opportunity ];
system.debug(PaymentsAfter);
system.AssertEquals(PaymentsBefore+1,PaymentsAfter.size());
system.AssertEquals(10.00,PaymentsAfter[1].amount);
system.AssertEquals(TestAcct.ID, PaymentsAfter[1].AccountId);
system.AssertEquals(TestCtct.ID, PaymentsAfter[1].Contact__c);
system.AssertEquals(TestCamp.ID,PaymentsAfter[1].CampaignId);
system.Assert(PaymentsAfter[1].name.contains('Membership Renewal'),'Payment name is ' + PaymentsAfter[1].name);
} // end test

} // end class