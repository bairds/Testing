// Older version from 2017 which still works
public class ContactCustom {
    public String id { get; set; }
    public String name { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String company { get; set; }
    public String email { get; set; }
    public String phone { get; set; }
    public String zip { get; set; }
    public String street { get; set; }
    public String city { get; set; }
    public String state { get; set; }
    public Boolean over18 { get; set; }
    public Boolean newsletter { get; set; }
    public AccountContactRole acr { get; set; }
    public Boolean flag { get; set; }

    public String[] volunteerInterests { get; set; }
    public List<SelectOption> volunteerInterestsList { get; set; }
    public String howHeard { get; set; }
    public String[] mailingLists { get; set; }

    public List<Contact> cs;
    private Contact c;
    private Lead l;
    public List<Task> ts;

    public ContactCustom() {
        this.newsletter = true;
    }

    public ContactCustom(List<Contact> cs) {
        this.cs = cs;
    }

    public void setVolunteerInterests() {
        this.volunteerInterests = new String[]{
        };
        this.volunteerInterestsList = new List<SelectOption>();

        for (Schema.PicklistEntry ll : Contact.Volunteer_Interests__c.getDescribe().getPicklistValues())
            this.volunteerInterestsList.add(new SelectOption(ll.getValue(), ll.getLabel()));
    }
}