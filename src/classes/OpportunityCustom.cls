public class OpportunityCustom 
{
    public RecordType recordType { get; set; }
    public List<SelectOption> recordTypes { get; set; } 
    
    public String thankYouLetter { get; set; }
    public List<SelectOption> thankYouLetters { get; set; }
    public String[] thankYouLetterFormats { get; set; }
    public List<SelectOption> thankYouLetterFormatsList { get; set; }
    
    public OpportunityCustom()
    {
    }
    
    public void setRecordTypes()
    {
        this.recordTypes = new List<SelectOption>();

        for(Schema.RecordTypeInfo rt : Opportunity.SObjectType.getDescribe().getRecordTypeInfos()) {
         	if(rt.getName() != 'Master')
            	this.recordTypes.add(new SelectOption(rt.getRecordTypeId(), rt.getName()));
        }
    }
    
    public void setThankYouLetters()
    {
        this.thankYouLetters = new List<SelectOption>();
        this.thankYouLetters.add(new SelectOption('', '-- None --'));
        
    	List<ApexPage> tyls = [SELECT Id, Name FROM apexPage WHERE Name LIKE '%thanks%'];
    
    	for(ApexPage tyl : tyls)
    		this.thankYouLetters.add(new SelectOption(String.valueOf(tyl.Id), tyl.Name));
    }
    
    public void setThankYouLetterFormats(Contact co)
    {
        this.thankYouLetterFormats = new String[]{'Print'};
            
        this.thankYouLetterFormatsList = new List<SelectOption>();
        this.thankYouLetterFormatsList.add(new SelectOption('Print', 'Print'));
        
        if(co != null && String.isNotBlank(co.Email))
        	this.thankYouLetterFormatsList.add(new SelectOption('Email', 'Email'));
        else
            this.thankYouLetterFormatsList.add(new SelectOption('Email', 'No email address', true));
    }
}