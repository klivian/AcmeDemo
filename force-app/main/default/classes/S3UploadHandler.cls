public with sharing class S3UploadHandler implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    @TestVisible static Boolean makeCallout = true;

    private final string endpointURL;
    private final string bucketName;
    private final string maxHeight;

    private List<Id> versionIds;

    public S3UploadHandler(List<Id> contentVersionIDs)
    {
        this.versionIds = contentVersionIDs;
        this.endpointURL = ([Select Value__c from AWS_Setting__mdt where Developername = 'Image_Handler_Endpoint']).Value__c;
        this.bucketName = ([Select Value__c from AWS_Setting__mdt where Developername = 'S3_Bucket_Name']).Value__c;
    }

    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator('SELECT Id, ContentDocumentID FROM ContentVersion WHERE Id IN :versionIds');
    }

    public void execute(Database.BatchableContext context, List<SObject> versions)
    {
        if(makeCallout)
        {
            List<HttpResponse> responses = performCallout(versions);
        }
    }

    public void finish(Database.BatchableContext bc)
    {
       
    }

    public List<HTTPResponse> performCallout(List<SObject> versionList)
    {
        List<ContentVersion> versions = new List<ContentVersion>();
        
        if(versionList.size() > 0 )
        {
            String versionId = versionList[0].Id;
            versions = [SELECT PathOnClient, ContentSize, fileType, VersionData, ContentDocumentId
                                             FROM ContentVersion
                                             WHERE Id = :versionId ];
        }
        List<HttpResponse> responses = new List<HttpResponse>();
     
        try
        {    
            if(versions != null && versions.size() > 0)
            {
                for(Integer j=0; j < versions.size(); j++)
                {
                    ContentVersion image = versions[j];
                    HttpRequest req = new HttpRequest();
                    req.setMethod('PUT');
                    req.setEndpoint('callout:S3Callout' + '/' + image.Id +  '_' + image.PathOnClient.replaceAll('\\s+','').toLowerCase());   //strip spaces from filenames
                    req.setHeader('Host', bucketname + '.' + endpointURL);
                    req.setHeader('Content-Length', String.valueOf(image.ContentSize));
                    req.setHeader('Content-Encoding', 'UTF-8');
                    req.setHeader('Content-type', image.fileType);
                    req.setHeader('Connection', 'keep-alive');
                    req.setHeader('Date', Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z'));
                    req.setHeader('ACL', 'public-read-write');
                    req.setBodyAsBlob(image.VersionData);
                    System.debug('ZXZX request - ' + req);

                    Http http = new Http();
                    HTTPResponse res = http.send(req);
                    
                    System.debug('>>>> The response');
                    System.debug(res);
                    System.debug('>>>> The body');
                    System.debug(res.getBody());
                    System.debug('>>>> Status code');
                    System.debug(res.getStatusCode());

                    responses.add(res);
                }
            }
        }
        catch (Exception ex)
        {
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
        }
        return responses;
    }
}