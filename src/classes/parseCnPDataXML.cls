// 15 DEC 2015.  SECTION ADDED TO PARSE THE CAMPAIGN NODE STRUCTURE FROM THE CONNECT APPLICATION.
// Added Exception Handling, send errors to WG_Error_Log;
// 7 Dec removed search for application by name, search for WGCampaignId now works.
// 11 Mar 2018 Parses for leadsource
public class parseCnPDataXML{
        public WGSettings__mdt Setting;
    
    public parseCnPDataXML(){
    }
    
    public static Map<String,String> parseXML(string XMLstring) {
        //public static List<String> parseCnPDataXML(string XML) {
        //system.debug('parseCn
        // PDataXML is looking for Data record where OrderNumber is ' + OrderNumber);
        //string toparse = [select id, CnP_PaaS__DataXML__c from
        //CnP_PaaS__CnPData__c where CnP_PaaS__OrderNumber__c = :OrderNumber][0].CnP_PaaS__DataXML__c;
        WGSettings__mdt Setting = WGHelpers.getWGSettings();
        Integer i = 0;
        Map<string, string> result = new Map<string, string>{
            'firstname' => null,
                'lastname' => null,
                'phone' => null,
                'street1' => null,
                'street2' => null,
                'city' => null,
                'state' => null,
                'zip' => null,
                'email' => null,
                'tracker' => null,
                'campaign' => null,
                'CampaignName' => null,
                'WGCampaignId' => null,
                'windowname' => null,
                'windowid' => null,
                'totalcharge' => null,
                'chargamount' => null,
                'transactionresult' => null,
                'urlreferrer' => null,
                'paymentType' => null,
                'CustomPaymentName' => null,
                'CustomPaymentNumber' => null,
                'nameoncard' => null,
                'cardnumber' => null,
                'expirationdate' => null,
                'transactiontesult' => null,
                'recurringid' => null,
                'mastertransactionnr' => null,
                'installments' => null,
                'recurringmethod' => null,
                'installmentnr' => null,
                'nextinstallmentdate' => null,
                'installmentamount' => null,
                'totalamount' => null,
                'Totalcommitted' => null,
                'totalmade' => null,
                'application' => null,
                'applicationId' => null,
                'totaldue' => null,
                'leadsource' => null
                };
                    
                    Dom.Document docx = new Dom.Document();
        try{
        docx.load(XMLstring);
        
        dom.XmlNode xroot = docx.getrootelement() ;
        if (xroot.getchildelement('Application', null) != null) {
            dom.XmlNode xrapplication = xroot.getchildelement('Application', null) ; //Leve
            list<dom.XMLNode> children = xrapplication.getchildelements();    
            for (Dom.XMLNode child : children) {
                if (child.getname() == 'Name') result.put('Application', child.getText());
                if (child.getname() == 'ID') result.put('ApplicationId', child.getText());
            }
        } //
        dom.XmlNode xr = xroot.getchildelement('Patron', null) ; //Level 2
        dom.XmlNode xrbilling = xr.getchildelement('BillingInformation', null) ; //
        dom.XmlNode xrbillingaddress = xr.getchildelement('BillingAddress', null) ; //
        dom.XmlNode xrcustomfieldlist = xroot.getchildelement('CustomFieldList', null) ; //
        dom.XmlNode xr2 = xroot.getchildelement('TransactionDetail', null) ; //Level 2
        dom.XmlNode xrcampaignlist = xr2.getchildelement('CampaignList', null) ;
        dom.XmlNode xr2paymentmethod = xr2.getchildelement('PaymentMethod', null) ; //
        dom.XmlNode xr3custompayment = xr2paymentmethod.getchildelement('CustomPaymentType', null) ; //
        dom.XmlNode xrrecurring = xroot.getchildelement('Recurring', null) ; //
        dom.XmlNode xr3 = xroot.getchildelement('OrderItemList', null) ; //Level 2
        
        list<dom.XmlNode> xbillingrec;
        
        xbillingrec = xrbilling.getchildelements() ; //Get all Record Elements
        
        for(Dom.XMLNode child : xbillingrec) //Loop Through Records
        {
            //system.debug('Field' + child.getname() + ': value :' + child.getText());
            if (child.getname() == 'BillingFirstName') result.put('firstname', child.getText());
            if (child.getname() == 'BillingLastName') result.put('lastname', string.escapesinglequotes(child.getText()));
            if (child.getname() == 'BillingEmail') result.put('email', child.getText());
            if (child.getname() == 'BillingPhone') result.put('phone', child.getText());
        }
        
        xbillingrec = xrbillingaddress.getchildelements() ; //Get all Record Elements
        
        for(Dom.XMLNode child : xbillingrec) //Loop Through Records
        {
            //system.debug('Field' + child.getname() + ': value :' + child.getText());
            if (child.getname() == 'BillingAddress1') result.put('street1', child.getText());
            if (child.getname() == 'BillingAddress2') result.put('street2', child.getText());
            if (child.getname() == 'BillingCity') result.put('city', child.getText());
            if (child.getname() == 'BillingStateProvince') result.put('state', child.getText());
            if (child.getname() == 'BillingPostalCode') result.put('zip', child.getText());
        }
        
        if (xrcustomfieldlist != null) {	
            xbillingrec = xrcustomfieldlist.getchildelements() ; //Get all Record Elements
            
            integer j = 1;
            for(Dom.XMLNode customfield : xbillingrec) //Loop Through Records
            {
                String fn;
                String fv;
                fn = customfield.GetChildElement('FieldName',null).gettext();
                fv = customfield.GetChildElement('FieldValue',null).gettext();
                // Check whether the LeadSource_QuestionCnP has been set in the WG_Settings__c and whether it is the questions text
                system.debug('ParseCnPDataXML line 18 Leadsource is ' + Setting.LeadSource_QuestionCnP__c);
                if (Setting.LeadSource_QuestionCnP__c != null && fn == Setting.LeadSource_QuestionCnP__c) {
                    result.put('leadsource',fv);
                    continue;
                }
                result.put('customquestion'+j,fn);
                result.put('customanswer'+j,fv);
                j = j+1;	
            }
        } // end if (xrcustomfieldlist != null)
        
        
        xbillingrec = xr2.getchildelements() ; // get all record elements for this level 2 node
        
        for (Dom.XMLNode child : xbillingrec) { // loop through records

            if (child.getname() != NULL) result.put(child.getname().tolowercase(), string.escapesinglequotes(child.getText()));
        }
            
        xbillingrec = xr2paymentMethod.getchildelements() ; // get all record elements for this level 2 node
        
        for (Dom.XMLNode child : xbillingrec) { // loop through records
            /*
if (child.getname() == 'paymentType') result.put('paymentType', child.getText());
if (child.getname() == 'nameOnCard') result.put('nameOnCard', child.getText());
if (child.getname() == 'CardNumber') result.put('CardNumber', child.getText());
if (child.getname() == 'ExpirationDate') result.put('ExpirationDate', child.getText());
*/
            if (child.getname() != NULL) result.put(child.getname().tolowercase(), string.escapesinglequotes(child.getText()));
        } 
            
//CustomPaymentMethod
            if(xr3custompayment != null) {
                xbillingrec = xr3custompayment.getchildelements();
                for (Dom.XMLNode child : xbillingrec) {
                    if (child.getname() != NULL) result.put(child.getname().tolowercase(), string.escapesinglequotes(child.getText()));
                }
            }
        
        System.debug('Xrrecurring is now ' + xrrecurring);
        if (xrrecurring != null) {
            xbillingrec = xrrecurring.getchildelements() ; // get all records for this level 2 node
            
            for (Dom.XMLNode child : xbillingrec) {
                /*
if (child.getname() == 'TransactionResult') result.put('TransactionResult', child.getText());
if (child.getname() == 'RecurringID') result.put('RecurringID', child.getText());
if (child.getname() == 'MasterTransactionNumber') result.put('MasterTransactionNumber', child.getText());
if (child.getname() == 'Installments') result.put('Installments', child.getText());
if (child.getname() == 'RecurringMethod') result.put('RecurringMethod', child.getText());
if (child.getname() == 'InstallmentNumber') result.put('InstallmentNumber', child.getText());
if (child.getname() == 'NextInstallmentDate') result.put('NextInstallmentDate', child.getText());
if (child.getname() == 'InstallmentAmount') result.put('InstallmentAmount', child.getText());
if (child.getname() == 'TotalAmount') result.put('TotalAmount', child.getText());
if (child.getname() == 'TotalCommitted') result.put('TotalCommitted', child.getText());
if (child.getname() == 'TotalMade') result.put('TotalMade', child.getText());
if (child.getname() == 'TotalDue') result.put('TotalDue', child.getText());
*/
                if (child.getname() != NULL) result.put(child.getname().tolowercase(), child.getText());
            }
        } // end if (xrrecurring != null)
        
        if (xr3 != null) {	
            list<dom.XmlNode> xrorderItems = xr3.getchildelements() ; 
            System.debug('parseCnPDataXML has found ' + String.valueOf(xrorderItems.size()) + 'order items.');
            result.put('orderitems',string.valueOf(xrorderItems.size()));
            for (Dom.XMLNode child : xrorderitems) {
                List<dom.XmlNode> grandchildren = child.getchildelements();
                for (Dom.XmlNode grandchild : grandchildren) {
                    
                    if (grandchild.getname() != NULL) result.put(grandchild.getname().tolowercase() + i, grandchild.getText());
                    system.debug(grandchild.getname().tolowercase() + i + ':' + grandchild.getText());
                    /*
if (grandchild.getname() == 'ItemID') result.put('ItemID' + i, grandchild.getText());
System.debug('In xrOrderItems, just Set ItemID' + i + ' to ' + grandchild.getText());
if (grandchild.getname() == 'ItemID') result.put('ItemID' + i, grandchild.getText());
if (grandchild.getname() == 'ItemName') result.put('ItemName' + i, grandchild.getText());
if (grandchild.getname() == 'Quantity') result.put('Quantity' + i, grandchild.getText());
if (grandchild.getname() == 'UnitPriceCharge') result.put('UnitPriceCharge' + i, grandchild.getText());
if (grandchild.getname() == 'UnitPriceDue') result.put('UnitPriceDue' + i, grandchild.getText());
if (grandchild.getname() == 'TaxAmountCharge') result.put('TaxAmountCharge' + i, grandchild.getText());
if (grandchild.getname() == 'TaxAmountDue') result.put('TaxAmountDue' + i, grandchild.getText());
if (grandchild.getname() == 'DiscountCharge') result.put('DiscountCharge' + i, grandchild.getText());
if (grandchild.getname() == 'DiscountDue') result.put('DiscountDue' + i, grandchild.getText());
if (grandchild.getname() == 'SKU') result.put('SKU' + i, grandchild.getText());
*/
                    
                } //end grandchild loop
                i = i + 1;
            } // end child loop
        } // END IF xr3 != null
            
        system.debug('After looking at transactiondetail result is ' + result);
        
        
        // WE TAKE ONLY THE FIRST CAMPAIGN NAME, SET IT EQUAL TO CampaignName.
            system.debug('XRCampaignList is ' + xrcampaignlist);
            if (xrcampaignlist != null) {
                // the following code never runs
                system.debug('XRCampaignList is ' + xrcampaignlist);
                list<dom.XmlNode> xrcampaignNodes = xrcampaignlist.getchildelements() ; 
                if (xrcampaignnodes != null) {
                    // ONLY USE THE FIRST CAMPAIGN NAME IN THE NODE STRUCTURE.    
                    Dom.XMLNode child = xrcampaignnodes[0];
                    system.debug('XXX ' + child.getChildElement('CampaignName',null));
                    if (child.getChildElement('CampaignName',null)!=null) result.put('CampaignName', child.getChildElement('CampaignName',null).getText());
					// Connect uses SF Campaign Ids, so pull that.
                    if (child.getChildElement('CampaignExternalID',null)!=null) result.put('WGCampaignId', child.getChildElement('CampaignExternalID',null).getText());                                       
                }
            }
        system.debug(result);
            // If periodicity = Yearly, change it to Annually to avoid error on insert.
            if (result.get('periodicity')=='Yearly') result.put('periodicity','Annually');
        return result;
        } catch (exception ex) {
                WG_Error_Log__c EL = new WG_Error_Log__c(
                Description__c = 'Message is: ' + ex.getMessage() + '.  Exception of type ' + ex.getTypeName() + ' occurred at line ' + ex.getLineNumber() + ' because of ' + ex.getCause() + ' and stack trace is ' + ex.getStackTraceString(),
                Category__c = 'Occurred in parseCnPDataXML');
                LogError LE = new LogError();
                LE.LogDataXMLProcessingError(EL);
            return null;
        }
    }
    
}