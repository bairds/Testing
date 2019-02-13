@istest
private class SignInTest 
{
	static testMethod void test()
    {
        Create_Test_Variables ctv = new Create_Test_Variables();
        
        SignIn s = new SignIn();
        s.setSignIn();
        
        s.a = '2';        
        s.setSignIn();
        s.cc.Name = 'Test';
        s.submitCampaign();
        
        System.currentPageReference().getParameters().put('cid', s.c.Id);
        s.a = '3';
        s.setSignIn();
        
        s.a = '1';
        s.s = '2';
        s.setSignIn();
        s.review();
        s.back();
        s.review();
        s.co.LastName = 'Te';
        s.co.Email = 'dd@dd.com';
        s.signIn();
             
        System.currentPageReference().getParameters().put('co', ctv.TestContact.Id);
        
        s.setSignIn();
        s.review();                
        s.signIn();      
       
	}
}