public class FieldSetCustom 
{
    public String Label { get; set; }
    public String Name { get; set; }
    public String Type { get; set; }
    public Value Value { get; set; }
    public List<SelectOption> Picklist { get; set; }
    
    public FieldSetCustom(DescribeSObjectResult o, String label, String name, DisplayType type)
    {
        this.Label = label;
        this.Name = name;
        this.Type = String.valueOf(type);
        
        if(this.Type == 'PICKLIST' || this.Type == 'MULTIPICKLIST' || this.Type == 'PHONE') { 
            this.Value = new Value();
            
            if(this.Type == 'PICKLIST' || this.Type == 'MULTIPICKLIST') {
                if(this.Type == 'MULTIPICKLIST')
               		this.Value.StrL = new String[]{};
                
                this.Picklist = new List<SelectOption>();         
                
                DescribeFieldResult dfr = o.fields.getMap().get(this.Name).getDescribe();
                
                for(PicklistEntry ple : dfr.getPicklistValues())
                    this.Picklist.add(new SelectOption(ple.getValue(), ple.getLabel()));
            }
        }
        else
            this.Type = 'field';
    }
    
    public static List<FieldSetCustom> getList(DescribeSObjectResult o, String fsn)
    {                
        List<FieldSetCustom> l = new List<FieldSetCustom>();
        
        Schema.FieldSet fs = o.fieldSets.getMap().get(fsn);
        
        if(fs != null) {
            for(FieldSetMember f : fs.getFields())			           
                l.add(new FieldSetCustom(o, f.getLabel(), f.getFieldPath(), f.getType()));
        }
        
        return l;
    }
    
    public class Value
    {
        public String Str { get; set; }
        public String[] StrL { get; set; }
        
        public Value()
        {
            
        }        
    }
}