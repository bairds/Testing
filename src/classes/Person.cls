public class Person {
    public String Id {
        get; set;
    }
    
    public String Name {
        get; set;
    }
    
    public String Type {
        get; set;
    }
    
    public sObject Details {
        get; set;
    }
        
    public Person (String id, String name)
    {
        this.Id = id;
        this.Name = name;
        
    	if(id.substring(0, 3) == '003') //Contact
           this.Type = 'Contact';
        else // Lead
           this.Type = 'Lead';  
        
		this.Details = Database.query('SELECT Name FROM ' + this.Type +  ' WHERE Id = \'' + this.Id + '\'');

        //this.Details = [SELECT Name FROM this.Type WHERE Id = :this.Id];
    }
    
    //public Person (Contact contact)
    //{
      //  this.Id = contact.Id;
        //this.Name = contact.Name;
    //}
    
    //public Person (Lead lead)
    //{
      //  this.Id = lead.Id;
        //this.Name = lead.Name;
    //}
}