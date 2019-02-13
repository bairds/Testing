@isTest
global class HUCMockImpl implements HttpCalloutMock{
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('http://api.salesforce.com/foo/bar', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ "displayFieldName": "NAME", "fieldAliases": {  "HUC12": "HUC12",  "NAME": "Name" }, "fields": [  {   "name": "HUC12",   "type": "esriFieldTypeString",   "alias": "HUC12",   "length": 12  },  {   "name": "NAME",   "type": "esriFieldTypeString",   "alias": "Name",   "length": 120  } ], "features": [  {   "attributes": {    "HUC12": "020700100102",    "NAME": "Lower Rock Creek"   }  } ]}');
        res.setStatusCode(200);
        return res;
    }
}