@isTest
global class HUCMock500Error implements HttpCalloutMock{
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"error": {"code": 500,"message": "Service wb/MapServer not found ","details": []}}');
        res.setStatusCode(200);
        return res;
    }
}