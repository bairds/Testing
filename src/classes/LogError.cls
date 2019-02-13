// This is an instance method because it could be called multiple times from the same execution of the ManageCnPData controller.  
// For example, there could be various types of errors in the same execution, which would submit separately to this method, and this
// method would correctly process each individually.

public class LogError{
    
    public LogError(){}

    public List<WG_Error_Log__c> LogOppInsertError(List<Database.SaveResult> srs, List<Opportunity> Opps, List<String> DataXMLs) {
        List<WG_Error_Log__c> EL = new List<WG_Error_Log__c>();
        for(integer i=0; i<srs.size(); i++) {
            for (Database.Error err : srs[i].getErrors()) {
                WG_Error_Log__c E = new WG_Error_Log__c(
                        Category__c = 'Database',
                        Error_Level__c = string.ValueOf(err.getStatusCode()),
                        Description__c = DataXMLs[i]);
                EL.add(E);
            } // end loop through list of errors in SaveResult
        } // end loop through list of SaveResult
        Database.insert(EL);
        Return EL;
    } // end LogError method

    public List<WG_Error_Log__c> LogCnPOppInsertError(List<Database.SaveResult> srs, List<Opportunity> Opps, List<String> DataXMLs) {
        List<WG_Error_Log__c> EL = new List<WG_Error_Log__c>();
        for(integer i=0; i<srs.size(); i++) {
                for (Database.Error err : srs[i].getErrors()) {
					System.debug('The following error has occurred.');                   
		            System.debug(err.getStatusCode() + ': ' + err.getMessage());
		            System.debug('Contribution fields that affected this error: ' + err.getFields());
                    WG_Error_Log__c E = new WG_Error_Log__c(
                          Category__c = 'Database',
                          Error_Level__c = string.ValueOf(err.getStatusCode()),
                          C_P_Data__c = Opps[i].C_P_Data__c,
                          Description__c = DataXMLs[i]);                    	
                    EL.add(E);
                    } // end loop through list of errors in SaveResult
        } // end loop through list of SaveResult
        Database.insert(EL);
        Return EL;
    } // end LogError method
    
    public WG_Error_Log__c LogDataXMLProcessingError(WG_Error_Log__c error) {
        insert error;
        return error;
    }    
    
    public WG_Error_Log__c LogHUCError(String Code, String Message, String Details) {
        WG_Error_Log__c E = new WG_Error_Log__c(
                          Category__c = 'HUC WebService',
                          Description__c = 'Message: ' + Message + ' Details: ' + Details,
        				Status_Code__c = Code); 
        insert E;
        return E;
    }
    
//Process multiple HUC Errors        
    public void LogHUCErrors(List<ErrorHolder> LEH) {
        List<WG_Error_Log__c> LWEL = new List<WG_Error_Log__c>();
        For (ErrorHolder EH : LEH) {
        WG_Error_Log__c E = new WG_Error_Log__c(
                          Category__c = 'HUC WebService',
                          Description__c = 'Message: ' + EH.Message + ' Details: ' + EH.Details,
        				Status_Code__c = EH.Code); 
            LWEL.add(E);
        }
        
        Database.insert(LWEL);
    }
}