/**
 * @description       : Mock handler for S3 callouts
 * @author            : Rob Cowell
 * @group             :
 * @last modified on  : 07/12/2020
 * @last modified by  : Rob Cowell
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   07/12/2020   Rob Cowell   Initial Version
**/
@isTest
public with sharing class S3TestMock implements HttpCalloutMock
{
    public HttpResponse respond(HttpRequest req)
    {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('x-amz-id-2', 'Yd6PSJxJFQeTYJ/3dDO7miqJfVMXXW0S2Hijo3WFs4bz6oe2QCVXasxXLZdMfASd');
        res.setHeader('x-amz-request-id', '80DF413BB3D28A25');
        res.setHeader('Date', 'Fri, 6 Oct 2020 05:54:59 GMT');
        res.setHeader('ETag', 'dd038b344cf9553547f8b395a814b274');
        res.setHeader('Content-Length', '0');
        res.setHeader('Server', 'Amazons3');
        return res;
    }
}