public class camp_members_list {

id thiscampid;
string campaignName;
integer numberMembers;
public List<campaignmember> list_contacts;

    public camp_members_list(ApexPages.StandardController controller) {
    thiscampid = System.currentPageReference().getParameters().get('id');
    }
    
public string getCampaignName() {
    if (campaignName == null) {
    campaignName = [select id, name from campaign where id = :thiscampid limit 1].name;
    }
    return campaignName;
}
    
public integer getNumberMembers() {
    return numberMembers;
    }    

public List<campaignmember> getList_contacts() {
        list_contacts = [select id, contactid, to_delete__c, contact.email, 
        contact.firstname, contact.lastname, contact.phone, contact.mailingPostalCode, 
        contact.account.name, leadid, lead.firstname, lead.lastname,
        lead.email, lead.phone, lead.PostalCode, lead.Company from campaignMember 
        where campaignid = :thiscampid
        order by lead.lastname, contact.lastname];
        numberMembers = list_contacts.size();
        return list_contacts;
        }

public pageReference deleteRefresh(){
    system.debug(list_contacts);
    	try {
    	update list_contacts;  
    	}
     	catch( System.Exception e) 
      	{
         	System.debug('ERROR: '+ e);
      	}      
    list<campaignmember> deleteList = [select id from campaignmember where To_delete__c
    = true and campaignid=:thiscampid];	
    try {
    	delete deleteList;
    	}
     	catch( System.Exception e) 
      	{
         	System.debug('ERROR: '+ e);
      	}     
    pageReference return_to_list = page.camp_member_list_page;
    return return_to_list;
    
    }
    
    }