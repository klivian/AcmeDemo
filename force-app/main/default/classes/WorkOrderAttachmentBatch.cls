public with sharing class WorkOrderAttachmentBatch implements Database.Batchable<SObject>, Database.Stateful
{
    private List<Id> contentVersionIds;
    private List<Id> docIDs;
    private string query;
    private List<WorkOrder> workOrders;
    private Map<Id, List<Id>> docToEntityMap;
    private String baseURL;

    public WorkOrderAttachmentBatch(List<Id> contentDocIds, List<WorkOrder> workOrders, Map<Id, List<Id>> docToEntityMap)
    {
        this.docIDs = contentDocIds;
        contentVersionIds = new List<Id>();
        this.workOrders = workOrders;
        this.docToEntityMap = docToEntityMap;
        baseURL = ([Select Value__c from AWS_Setting__mdt where Developername = 'S3_Bucket_Name']).Value__c + '.s3.amazonaws.com';
    }

    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator([SELECT Id, LatestPublishedVersionId, Title, FileExtension
                                         FROM ContentDocument
                                         WHERE FileType IN ('PNG','JPG')
                                         AND Id IN :DocIDs]);
    }

    public void execute(Database.BatchableContext bc, List<ContentDocument> documents)
    {
        Map<Id, ContentDocument> docVersionsByContentDocID = new Map<Id, ContentDocument>();
        for(SObject contentDoc : documents)
        {
            docVersionsByContentDocID.put(contentDoc.Id, (ContentDocument)contentDoc);
        }

            List<Work_Order_Attached_Image__c> attachedImages = new List<Work_Order_Attached_Image__c>();
            List<String> workOrderIDsToDelete = new List<String>();
            List<Work_Order_Attached_Image__c> attachmentsToDelete = new List<Work_Order_Attached_Image__c>();
            for(WorkOrder wko : workOrders)
            {
                List<Id> docsForThisWorkOrder = docToEntityMap.get(wko.Id);
                for(Id docId : docsForThisWorkOrder)
                {
                    String versionID = docVersionsByContentDocID.get(docId)?.LatestPublishedVersionId;
                    if(versionID != null)
                    {
                        workOrderIDsToDelete.add(wko.Id);
                        Work_Order_Attached_Image__c img = new Work_Order_Attached_Image__c();

                        //Populate properties
                        img.Work_Order__c = wko.Id;

                        //Prefix filename with the ID of the ContentVersion - this ensures unique filesnames across all attachments
                        String filename = docVersionsByContentDocID.get(docId)?.LatestPublishedVersionId + '_' + (docVersionsByContentDocID.get(docId)?.Title).toLowerCase();
                        if(filename.right(3).toUpperCase() != 'JPG' && filename.right(3).toUpperCase() != 'PNG')
                        {
                            filename += '.' + docVersionsByContentDocID.get(docId)?.FileExtension;
                        }
                        img.Description__c = filename.replaceAll('\\s+', '');   //strip spaces, S3 doesn't like them
                        img.Original_image_URL__c = baseURL + '/' + img.Description__c;
                        img.Resized_Image_URL__c = ImageRotationHandler.getRotatedURL(img.Description__c);
                        img.ContentVersionId__c = docVersionsByContentDocID.get(docId)?.LatestPublishedVersionId;
                        img.Image_RTF__c = '<a href="https://' + baseURL + '/' + img.Description__c + '" target="_blank"><img src=' + img.Resized_Image_URL__c + '></img></a>';
                        attachedImages.add(img);
                    }
                }
            }

            Database.SaveResult[] results = Database.insert(attachedImages, false);
            for (Database.SaveResult sr : results)
            {
                if(!sr.isSuccess())
                {
                    for(Database.Error err : sr.getErrors())
                    {
                        System.debug('Error updating Work Order RTF on Id ' + sr.getId() + ' - ' + err.getMessage());
                    }
                }
            }

             //Original image
             for(Work_Order_Attached_Image__c img : attachedImages)
             {
                 contentVersionIds.add(img.ContentVersionId__c);
             }
    }

    public void finish(Database.BatchableContext bc)
    {
        S3UploadHandler handler = new S3UploadHandler(contentVersionIds);
        Database.executeBatch(handler);
    }
}