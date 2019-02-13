@isTest
global class HUCMockImplBadServerURL implements HttpCalloutMock{
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('http://api.salesforce.com/foo/bar', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ "error": {  "code": 500,  "message": "Service wb/MapServer not found ",  "details": [] }}');
        res.setStatusCode(500);
        return res;
    }
}