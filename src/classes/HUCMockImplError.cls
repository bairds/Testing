@isTest
global class HUCMockImplError implements HttpCalloutMock{
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('http://api.salesforce.com/foo/bar', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('<html lang="en">    <head>        <title>Error: Output format not supported.</title>        <link href="/arcgis/rest/static/main.css" rel="stylesheet" type="text/css"/>    </head>    <body>        <table width="100%" class="userTable">            <tr>                <td class="titlecell">ArcGIS REST Framework</td>            </tr>        </table>        <table width="100%" class="navTable">            <tr valign="top">                <td class="breadcrumbs">                    <a href="/arcgis/rest/services">Home</a>                </td>            </tr>        </table>        <div class="cbody">            <br/>            <br/>            <b>Error: </b>Output format not supported.            <br/>            <b>Code: </b>400            <br/>            <br/>            <div style="color:#ff6666"> </div>        </div></body></html>');
        res.setStatusCode(200);
        return res;
    }
}