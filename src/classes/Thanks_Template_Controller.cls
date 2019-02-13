public with sharing class Thanks_Template_Controller {

//public Opportunity Op {get; set;}
    public String renderAs { get; set; }

    
    public Thanks_Template_Controller(ApexPages.StandardController controller) 
    {
        PageReference pr = ApexPages.CurrentPage();
        
        if(pr != null)
        	this.renderAs = pr.getParameters().get('ra');
        
        if(String.isBlank(this.renderAs))
            this.renderAs = 'pdf';
    }
}