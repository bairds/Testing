public class ContributionHistoryController {
    private final Contact c;
    private List<Opportunity> contribHistory;
    private Integer contribCount = 0;
    private Double totalContribAmount = 0;
    private Date lastContribDate = system.today() - 730;
    private Double maxAmount = 0;
    
    public ContributionHistoryController(ApexPages.StandardController stdController) {
        c = (Contact)stdController.getRecord();   
        initContributionHistory();
    }
    
    public void initContributionHistory() {
        // Build string of Record Types for retrieving record type ids
        List<String> sRecordTypes = new List<String>{'Challenge', 'Donation', 'Event', 'Grant','Major Donation','Membership', 'Pledge'};
        
        // Get record type ids for the strings listed above
        List<RecordType> lRecordTypes = [select id,name from RecordType where SobjectType='Opportunity' and Name in : sRecordTypes];
        
        contribHistory = [select o.Id, o.Amount, o.CloseDate, o.RecordTypeId from Opportunity o where o.Contact__c = :c.Id and o.CloseDate > :lastContribDate and o.RecordTypeId in :lRecordTypes];

        for (Integer x=0; x<contribHistory.size(); x++) {
            if(contribHistory[x].Amount > maxAmount) {
                maxAmount=contribHistory[x].Amount;
            }
            
            if(contribHistory[x].CloseDate > lastContribDate) {
                lastContribDate=contribHistory[x].CloseDate;
            }
            
            if(contribHistory[x].Amount>0) {
                totalContribAmount = totalContribAmount + contribHistory[x].Amount;
            }
            contribCount++;
        }
    }
   
    public Integer getContribCount () {
        return contribCount; 
    }
    
    public Double getTotalContribAmount () {
        return totalContribAmount;
    }
    
    public String getMaxAmount () {
        return maxAmount.format();
    }       
    
    public String getLastContribDate () {
        if(contribCount>0){
            return lastContribDate.format();    
        }
        
        else {
            return 'No Contributions';
        }
        
        //Could also be returned as a Date and formatted in the Visualforce page as follows:
        //{!DAY(lastContribDate)}/{!MONTH(lastContribDate))}/{!YEAR(lastContribDate)}
    }

}