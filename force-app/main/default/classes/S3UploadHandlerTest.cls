@isTest
public with sharing class S3UploadHandlerTest
{

    @TestSetup
    static void makeData()
    {
        ContentVersion cv = new ContentVersion(
        VersionData = Blob.valueOf('Test content'),
        Title = 'Test Title',
        PathOnClient = 'Test.png'
        );
        insert cv;
    }


    @isTest
    public static void testCallout()
    {
        List<ContentVersion> contentVersions = [SELECT Id, PathOnClient, ContentSize, FileType, VersionData FROM ContentVersion];

        List<Id> contentVersionIDs = new List<Id>();
        for(ContentVersion version : contentVersions)
        {
            contentVersionIDs.add(version.Id);
        }

        S3TestMock mock = new S3TestMock();
        test.setMock(HttpCalloutMock.class, mock);

        S3UploadHandler handler = new S3UploadHandler(contentVersionIDs);
        test.startTest();
        List<HttpResponse> responses = handler.performCallout(contentVersions);
        test.stopTest();

        for (HttpResponse res : responses)
        {
            System.assertEquals(200, res.getStatusCode());
        }
    }
}