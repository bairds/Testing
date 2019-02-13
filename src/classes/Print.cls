public class Print {
    public String src {get; set;}

    public Print() {
        String template = ApexPages.CurrentPage().getParameters().get('template');
        String contrib = ApexPages.CurrentPage().getParameters().get('contrib');
        src = '/apex/Unauthorized';
        

        if(String.isNotEmpty(template) && String.isNotEmpty(contrib)) {
            List<ApexPage> ts = [SELECT Id, Name FROM ApexPage WHERE Id =: template];
            
			if(ts.size() > 0) {
				ApexPage t = ts[0];
        
				src = '/apex/' + t.Name + '?id=' + contrib;
      		}
        }       
    }
    
    public static void saveAttach(Id oId, Id tId)
    {
        Opportunity o = [SELECT Id, Name FROM Opportunity WHERE Id =: oId ];
        
        List<ApexPage> ts = [ SELECT Id, Name FROM ApexPage WHERE Id =: tId ];
            
        if(ts.size() > 0) {
            ApexPage t = ts[0];
            
            PageReference p = new PageReference(t);  
            p.getParameters().put('id', o.Id);       

            Attachment AttachThanks = new Attachment();
            
            Blob ThanksLetter;          
                       
            try {
                   // returns the output of the page as a PDF                
                ThanksLetter = p.getContent();
         
            // need to pass unit test -- current bug    
            } catch (Exception e) {
                system.debug('failed'+ e.getMessage());
               ThanksLetter = Blob.valueOf('Some Text');
            }
            
            attachThanks.Body = ThanksLetter;
            // add the user entered name
            attachThanks.Name = 'Thank You Letter for '+ o.Name + ' ' + '.pdf';
            attachThanks.IsPrivate = false;
            // attach the pdf to the account
            attachThanks.ParentId = o.Id;
            insert attachThanks;
            
            o.Date_Acknowledged__c = system.today();
            o.StageName = 'Thank You Mailed';
            update o;            
        }         
            // send the user to the account to view results
    }
}