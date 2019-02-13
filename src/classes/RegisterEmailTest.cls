@istest
private class RegisterEmailTest 
{
	static testMethod void test()
    {
        Create_Test_Variables ctv = new Create_Test_Variables();
        
        Campaign c = new Campaign(Name='Shale Gas issues');
        
        insert c;
        
        RegisterEmail re = new RegisterEmail();
        
        // Lead
        
        re.setRegisterEmail();
        
        re.review();
        re.back();
        re.co.LastName = 'Te';
        re.co.Email = 'dd@dd.com';
        re.registerEmail();
               
        // Contact
                
        System.currentPageReference().getParameters().put('co', ctv.TestContact.Id);
        
        re.setRegisterEmail();
        re.co.Mailing_Lists__c = 'Deep Mine updates; Allegheny Energy Center updates';
        
        update re.co;
        
        re.coc.MailingLists = new String[]{'Youghiogheny River issues', 'Shale Gas issues'};
        re.review();
        
        re.registerEmail();
	}
    
    
    /*
    static testMethod void EmailCampaignPage(){
        Campaign c = new Campaign(Name='Youghiogheny River issues');
        
        insert c;
        
        Create_Test_Variables ctv = new Create_Test_Variables();
          
        registerEmail s = new registerEmail();
        s.setregisterEmail();
        
        s.a = '2';        
        s.setregisterEmail();
        s.cc.Name = 'Test';
        s.submitCampaign();
        
        System.currentPageReference().getParameters().put('cid', s.c.Id);
        s.a = '3';
        s.setregisterEmail();
        
        s.a = '1';
        s.s = '2';
        s.setregisterEmail();
        
                     
        s.co = ctv.fetchTestContact();
        s.co.Email = 'test@test.com';
        s.co.LastName = 'Mendi';
        s.co.Mailing_Lists__c = '(Trail news,Youghiogheny River issues)';
        
        update s.co;
        
        s.setEmailCampaign();
        s.co.Email = 'test@test.com';
        s.co.LastName = 'Mendi';
        s.coc.MailingLists = new String[]{'Youghiogheny River issues'};
        
        s.saveSignee();  
        
        
        s.setEmailCampaign();
        
        s.co.Email = 'test@test332.com';
        s.co.LastName = 'Mendi3';
        
        s.saveSignee();  
        
		//Was the contact saved as a campaignMember on the campaign?
		List<campaignMember> CMs = [SELECT ContactId, Id from CampaignMember where CampaignId = :s.c.Id];
        //System.AssertEquals(1,CMs.size(),'Expected only one CampaignMember');
        System.AssertEquals(CMs[0].contactId,ctv.TestContact.Id);
		
    }   */
}