public with sharing class Thanks_List_Controller{
        
public final Opportunity op;            
public string TemplateName {get; set;}
public list<apexPage> Thanks_Templates {get; set;}


public Thanks_List_Controller(ApexPages.StandardController controller) {
                Thanks_Templates = [select id, name, description from apexPage where name like 'Thanks%' ORDER BY name];
                this.op=(Opportunity)Controller.getRecord();
        }
        
   public PageReference saveattach() {  
               PageReference pr = new PageReference('/apex/'+TemplateName+'?id='+op.id);
                // pr.getParameters().put('id',objId);
                //get the content as a PDF
                Blob b;
	   				if(!Test.isRunningTest()) {
						b = pr.getContentAsPDF();
					} else {
						b = Blob.valueOf('TestBlob because cannot use getContentAsPDF so just inserted this text');
					}
                Attachment att = new Attachment();
                att.Body = b;

                //set which record to save the pdf against.
                att.ParentId = op.Id;


                att.Name = 'Thank You Letter for '+ Op.Name + ' ' + '.pdf';
                att.ContentType = 'application/pdf';
                insert att;
        system.debug('About to set Op.DateAcknowledged and StageName');
        Op.Date_Acknowledged__c = system.today();
        Op.StageName = 'Thank You Mailed';
        update Op;
        system.debug('Op is now ' + Op);
                
                pr.setRedirect(true);
                return pr;
   }    

}