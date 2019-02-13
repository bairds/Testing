// Clases:
// - HUCCustom
// - AccountCustom
// - AccountBatch
// - AccountSchedule
// - HUCTests
// - HUCURLMockImpl
// - HUCMockImpl

public class HUCCustom
{
    private HUCCustom parent;
    
    public HUC__c huc;

    private Decimal latitude;
    private Decimal longitude;
     
    private NationalMap nm;     
    
    public HUCURL__c hu;
      
    public HUCCustom()
    {        
    }
    
    public HUCCustom(HUCCustom parent)
    {        
        this.parent = parent;
    }
    
    public void setURL()
    {       
        this.hu = [SELECT Id, URL__c, HUC10__c, HUC12__c FROM HUCURL__c LIMIT 1];
        
        if(!Test.isRunningTest())
			this.getURL();            
    }
    
    public void getURL()
    {
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setTimeout(20000);
        req.setEndpoint('http://watergrass.force.com/settings?id=a0QA000000Fhi3kMAB&sn&sn2');
        
        Http http = new Http();
        
        try {            
            HttpResponse resp = http.send(req);
            
            if(resp.getStatusCode() == 200) {
                String url = resp.getBody();
                
                if(String.isNotBlank(url)) {
                    String[] urlParts = url.split('\\|', 6);
                    
                    this.hu.URL__c = urlParts[0];
                    this.hu.HUC10__c = urlParts[1];
                    this.hu.HUC12__c = urlParts[2];       
                }                    
            }
        } 
        catch (CalloutException e) {
            
        }
    }
    
    public HUCCustom getHUC(Decimal lat, Decimal lon)
    {
		HUCCustom h = new HUCCustom(this);
        
        if(lat != null && lon != null) {
            h.latitude = lat;
            h.longitude = lon;
            
            h.request('12');
            
            if(h.nm != null) {
                if(String.isNotEmpty(h.nm.huc12)) {            
                    h.setHUC(h.nm.huc12, 'Current', null);
                    
                    if(String.isNotEmpty(h.nm.Name)) {
                        h.huc.Subwatershed__c = h.nm.Name;
                        h.huc.Name += ' (' + h.huc.Subwatershed__c + ')';
                        
                        h.request('10');
                        
                        if(h.nm != null && String.isNotEmpty(h.nm.Name)) 
                            h.huc.Watershed__c = h.nm.Name;
                    }
                }
                else
                	h.setHUC(null, 'USGS HUC doesn\'t exist', null);
            }
        }
        else
            h.setHUC(null, 'No geocode for address', null);
        
        return h;
    }
    
    private void setHUC(String code, String status, String errors)
    {          
        this.huc = new HUC__c();
        this.huc.Code__c = code;
        this.huc.Name = code;
        
        if(String.isNotEmpty(status)) {
            this.huc.Status__c = status;
            
            if(String.isEmpty(this.huc.Name))
                this.huc.Name = status;
            
            if(String.isNotEmpty(errors)) {
                if(errors.length() > 255)
                    errors = errors.abbreviate(255);
                
            	this.huc.Errors__c = errors;
            }
        }   
    }
    
    private void request(String level) 
    {                   
        String bracket = this.parent.hu.HUC12__c;
        
        if(level == '10')
            bracket = this.parent.hu.HUC10__c;
            
		String url = this.parent.hu.URL__c.replace('[1]', bracket).replace('[2]', String.valueOf(this.longitude)).replace('[3]', String.valueOf(this.latitude)).replace('[4]', level);

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setTimeout(20000);
        req.setEndpoint(url);
        
        this.nm = null;
        
        Http http = new Http();
        
        try {            
        	HttpResponse resp = http.send(req);
            
            if(resp.getStatusCode() == 200) {
                String JSONContent = resp.getBody();
                
                JSONParser parser = JSON.createParser(JSONContent);    
                parser.nextToken();
                
                try {
                    NationalMap nm = (NationalMap) parser.readValueAs(NationalMap.class);
                    
                    if(nm.features.size() > 0)
                        this.nm = nm.features[0].attributes;
                    else
                        this.setHUC(null, 'USGS HUC doesn\'t exist', null);
            	}
                catch(NullPointerException e) {
                    this.setHUC(null, 'Call to USGS errors', e.getMessage());
                }
            }
            else
                this.setHUC(null, 'Call to USGS errors', 'HTTP Status Code: ' + resp.getStatusCode());
        } 
        catch(CalloutException e) {
            this.setHUC(null, 'Call to USGS errors', e.getMessage());
        }
    }
    
    public Id getHUCId()
    {      
        String q = 'SELECT Id FROM HUC__c WHERE ';
        
        if(String.isNotEmpty(this.huc.Code__c))
            q += 'Code__c = \'' + this.huc.Code__c + '\'';
        else
            q += 'Status__c = \'' + String.escapeSingleQuotes(this.huc.Status__c) + '\'';
        
        if(String.isNotEmpty(this.huc.Errors__c))
            q += ' AND Errors__c = \'' + this.huc.Errors__c + '\'';
        
        List<HUC__c> hucs = Database.query(q);
        
        if(hucs.size() > 0)
            this.huc = hucs[0];
        
        if(String.isEmpty(this.huc.Id)) {
         	if(this.huc.Name.length() > 80)
                this.huc.Name = this.huc.Name.abbreviate(80);
            
            insert this.huc;        
        }
        
        return this.huc.Id;
    }
    
    public static Id getHUCId(String status)
    {
        HUCCustom h = new HUCCustom();
        h.setHUC(null, status, null);
        
        return h.getHUCId();
    }
        
    public class NationalMap
    {   
        public List<NationalMap> features;
        
        public NationalMap attributes;
        
        public String huc10;
        public String huc12;        
   		public String name;
    	public String subWatershed;
    	public String watershed;
        public String url;
    }
}