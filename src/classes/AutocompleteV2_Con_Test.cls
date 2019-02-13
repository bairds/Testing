/*
Copyright (c) 2013 avidev9@gmail.com
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of the author may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
@isTest
private class AutocompleteV2_Con_Test{
    static testMethod void test_AutocompleteV2_Con(){
        //create some test account
        List<Account> accountList = new List<Account>();
        for(Integer i =0 ; i < 200 ; i++){
            accountList.add(new Account(Name='Test'+i));
        }
        //insert test records
        insert accountList;
        Test.startTest();
        /*  CHANGED THE FOLLOWING CODE BECAUSE OF INCORRECT SIGNATURE FOR METHOD
            System.assertEquals(accountList.size(),AutoCompleteV2_Con.getData('Account','Name','Id','T','').size());
            System.assertEquals(1, AutoCompleteV2_Con.getData('Account','Name','Id','Test111','').size());
            System.assertEquals(0, AutoCompleteV2_Con.getData('Account','Name','Id','xxxxxxx','').size()); */
        System.assertEquals(accountList.size(),AutoCompleteV2_Con.getData('Account','Name','Id','T','').size());
        System.assertEquals(1, AutoCompleteV2_Con.getData('Account','Name','Id','Test111','').size());
        System.assertEquals(0, AutoCompleteV2_Con.getData('Account','Name','Id','xxxxxxx','').size());
        AutoCompleteV2_Con controller = new AutoCompleteV2_Con ();
        controller.setTargetFieldVar(accountList[0].Id);
        System.assertEquals(accountList[0].Id,controller.getTargetFieldVar());
        controller.setCacheField(null);
        Test.stopTest();

    }
    static testMethod void test_LeadsAndConvertedLeads(){
        // If a lead is converted it should not appear in the returned list
        //create some test Lead
        List<Lead> LeadList = new List<Lead>();
        for(Integer i =0 ; i < 200 ; i++){
            LeadList.add(new Lead(Firstname='Test',LastName='Tester'+i,Company='Company'+i));
        }
        //insert test records
        insert LeadList;
        Test.startTest();
        /*  CHANGED THE FOLLOWING CODE BECAUSE OF INCORRECT SIGNATURE FOR METHOD */
        System.assertEquals(LeadList.size(),AutoCompleteV2_Con.getData('Lead','Name','Id','Te','').size());
        System.assertEquals(1, AutoCompleteV2_Con.getData('Lead','Name','Id','Tester111','').size());
        System.assertEquals(1, AutoCompleteV2_Con.getData('Lead','Name','Id','Tester111','').size());
        System.assertEquals(0, AutoCompleteV2_Con.getData('Lead','Name','Id','xxxxxxx','').size());
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(LeadList[0].id);
        lc.setDoNotCreateOpportunity(true);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE
        IsConverted=true and MasterLabel <> 'Qualified' LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        // Make sure conversion was successful
        System.assert(lcr.isSuccess());
        // Should be one fewer lead found
        System.assertEquals(LeadList.size()-1,AutoCompleteV2_Con.getData('Lead','Name','Id','Te','').size());


        AutoCompleteV2_Con controller = new AutoCompleteV2_Con ();
        controller.setTargetFieldVar(LeadList[0].Id);
        System.assertEquals(LeadList[0].Id,controller.getTargetFieldVar());
        controller.setCacheField(null);
        Test.stopTest();

    }
    static testMethod void test_LeadsContactsAndConvertedLeads(){
        // If a lead is converted it should not appear in the returned list
        //create some test Lead
        List<Lead> LeadList = new List<Lead>();
        for(Integer i =0 ; i < 200 ; i++){
            LeadList.add(new Lead(Firstname='Test',LastName='Tester'+i,Company='Company'+i));
        }
        //insert test records
        Account Acct = new Account(Name='TestAccount');
        insert Acct;

        insert LeadList;
        List<Contact> ContactList = new List<Contact>();
        for(Integer i =0 ; i < 200 ; i++){
            ContactList.add(new Contact(Firstname='Test',LastName='Tester'+i,AccountId=Acct.Id));
        }
        //insert test records
        insert ContactList;
        Test.startTest();
        /*  CHANGED THE FOLLOWING CODE BECAUSE OF INCORRECT SIGNATURE FOR METHOD */
        System.assertEquals(LeadList.size()+ContactList.Size(),AutoCompleteV2_Con.getData('Contact;Lead','Name','Id','Te','').size());
        System.assertEquals(2, AutoCompleteV2_Con.getData('Lead;Contact','Name','Id','Tester111','').size());
        System.assertEquals(0, AutoCompleteV2_Con.getData('Lead;Contact','Name','Id','xxxxxxx','').size());
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(LeadList[0].id);
        lc.setDoNotCreateOpportunity(true);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE
        IsConverted=true and MasterLabel <> 'Qualified' LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        // Make sure conversion was successful
        System.assert(lcr.isSuccess());
        // Should be one fewer lead found
        System.assertEquals(LeadList.size()-1,AutoCompleteV2_Con.getData('Lead','Name','Id','Te','').size());
        // But one more contact
        System.assertEquals(ContactList.size()+1,AutoCompleteV2_Con.getData('Contact','Name','Id','Te','').size());


        AutoCompleteV2_Con controller = new AutoCompleteV2_Con ();
        controller.setTargetFieldVar(LeadList[0].Id);
        System.assertEquals(LeadList[0].Id,controller.getTargetFieldVar());
        controller.setCacheField(null);
        Test.stopTest();

    }
}