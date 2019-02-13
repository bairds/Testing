public class CampaignCustom 
{
    public String id { get; set; }
    public String name { get; set; }
    public String type { get; set; }    
    public String signUpScopeType { get; set; }
    public String customQuestion { get; set; }
    public String customQuestion2 { get; set; }    
    public String masterCampaign { get; set; }
        
    public String eventDescription { get; set; }
    public String eventFeedback { get; set; }
    public String followUp { get; set; }
    public String waiver { get; set; }
    public String waiverBody { get; set; }
    public integer Nr_in_Group { get; set; }
    
    public List<SelectOption> signUpScopeTypes { get; set; }
    public List<SelectOption> howHeardAboutEvent { get; set; }
    public List<SelectOption> types { get; set; }
    public List<SelectOption> shirtSizes { get; set; }
    
    public String topText { get; set; }
    
    public CampaignCustom()
    {
        
    }
    
    public void setTypes()
    {
        this.types = new List<SelectOption>();

        for(Schema.PicklistEntry ll : Campaign.Type.getDescribe().getPicklistValues())
            this.types.add(new SelectOption(ll.getValue(), ll.getLabel()));
    }    
    
    public void setSignUpScopeTypes()
    {
        this.signUpScopeTypes = new List<SelectOption>();

        for(Schema.PicklistEntry ll : Campaign.Signup_for_group__c.getDescribe().getPicklistValues())
            this.signUpScopeTypes.add(new SelectOption(ll.getValue(), ll.getLabel()));
    }
    
    public void sethowHeardAboutEvent()
    {
        this.howHeardAboutEvent = new List<SelectOption>();
        
        for(Schema.PicklistEntry ll : CampaignMember.How_heard_about_event__c.getDescribe().getPicklistValues())
            this.howHeardAboutEvent.add(new SelectOption(ll.getValue(), ll.getLabel()));
    }
    
    public void setShirtSizes()
    {
        this.shirtSizes = new List<SelectOption>();
        
        for(Schema.PicklistEntry ll : CampaignMember.Shirt_Size__c.getDescribe().getPicklistValues())
            this.shirtSizes.add(new SelectOption(ll.getValue(), ll.getLabel()));
    }
}