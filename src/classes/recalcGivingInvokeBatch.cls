public with sharing class recalcGivingInvokeBatch {
        
        public pageReference InvokeBatch() {
                recalcGivingBatch RGB = new recalcGivingBatch();
                RGB.query = 'Select Id, LastName, (select OpportunityID, Opportunity.CloseDate, Opportunity.Amount from OpportunityContactRoles where Opportunity.IsWon = true Order by Opportunity.CloseDate DESC) from contact ORDER BY LastName';
                // Invoke the batch job. 
    
        ID batchprocessid = Database.executeBatch(RGB);
        System.debug('Returned batch process ID: ' + batchProcessId);
        return null;}

}