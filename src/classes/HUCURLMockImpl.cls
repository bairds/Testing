@isTest
global class HUCURLMockImpl implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('http://api.salesforce.com/foo/bar', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/plain');
        res.setBody('https://services.nationalmap.gov/arcgis/rest/services/nhd/MapServer/[1]/query?geometry=[2]%2C[3]&geometryType=esriGeometryPoint&outFields=HUC[4]%2C+NAME&returnGeometry=false&f=pjson&inSR=4326|6|7');
        res.setStatusCode(200);
        return res;
    }
}