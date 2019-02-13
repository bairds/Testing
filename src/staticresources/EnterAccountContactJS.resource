var recordType;
var contactsInAccount;

function setRequiredFields(select)
{
    var option = select[select.selectedIndex];
    var an = document.getElementById('account_name');
    var cia = document.getElementById('contacts_in_account');
    
    recordType = option.innerHTML;
    
    if(recordType != 'Family') {
    	an.firstElementChild.style.display = 'block';
        an.lastElementChild.required = true;
        cia.firstElementChild.style.display = 'none';
        cia.lastElementChild.required = false;
    }
    else {
        an.firstElementChild.style.display = 'none';
        an.lastElementChild.required = false;
        cia.firstElementChild.style.display = 'block';
        cia.lastElementChild.required = true;
        
        if(contactsInAccount.value == '') {
        	contactsInAccount.lastIndex = contactsInAccount.selectedIndex = 1;
            
            showLoading(1);
       		setContacts(contactsInAccount.value);
        }
	}
}

function validateContacts()
{  
    if(contactsInAccount.value == '0') {
        if(recordType == 'Family')  
       		contactsInAccount.selectedIndex = contactsInAccount.lastIndex;
        else 
        {
           var text = '<p> You\'re about to save an account without a contact, which makes it ' +
           				'hard for WaterGrass to include the account in reports and mailing lists. <br /><br />  ' +
               			'Please select one of the following options: </p>';
                    
            var dialog = $(text).dialog({
                modal: true,
                buttons: {
                    'Save Account Without Contact(s)': function() { 
                        showLoading(1);
                        dialog.dialog('close');                     	
        				setContacts(contactsInAccount.value);
                    },
                  	'Create Dummy Contact For Me Automatically': function() {
                        showLoading(1);
                        dialog.dialog('close');
                        contactsInAccount.lastIndex = contactsInAccount.selectedIndex = 1;                       
        				setContacts(contactsInAccount.value, true);                        
                    },
                    'Add Contact(s) To Account Manually': function() {
                        dialog.dialog('close');                  
                    }
                },
                
                close: function( event, ui ) { 
                	if(!loading)
               			contactsInAccount.selectedIndex = contactsInAccount.lastIndex;      
                },
                
                width: '26%'
            });
        }
    }
    else {
        showLoading(1);
        setContacts(contactsInAccount.value);
            
        contactsInAccount.lastIndex = contactsInAccount.selectedIndex;
    }      
}