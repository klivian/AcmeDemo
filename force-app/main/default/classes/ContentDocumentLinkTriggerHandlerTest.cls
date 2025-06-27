/**
 * @description       : test class for ContentDocumentTriggerHandler
 * @author            : Rob Cowell
  * @last modified on  : 10/02/2021
 * @last modified by  : Rob Cowell
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   12-05-2020   Rob Cowell   Initial Version
**/
@isTest
public with sharing class ContentDocumentLinkTriggerHandlerTest
{
    @TestSetup
    static void makeData()
    {
        Account acct = new Account();
        acct.Name = 'Test Account';
        insert acct;

        WorkType wt = new WorkType();
        wt.Name = 'Test Work Type';
        wt.EstimatedDuration = 2.0;
        System.debug('ZXZX WORK TYPE ' + wt);
        insert wt;






        MaintenancePlan plan = new MaintenancePlan();
        plan.AccountId = acct.Id;
        plan.StartDate = Date.today();
        plan.NextSuggestedMaintenanceDate = date.today().addDays(30);
        plan.GenerationTimeframe = 10;
        insert plan;

        WorkOrder wo = new WorkOrder();
        WorkType wtype =[SELECT id,EstimatedDuration,MinimumCrewSize from WorkType limit 1];
        wo.WorkTypeId=wtype.id;
        wo.Description = 'Test Work Order';
        wo.MaintenancePlanId = plan.Id;
        wo.SuggestedMaintenanceDate = Date.today().addDays(30);
        System.debug('ZXZX WORK ORDER - ' + wo);
        insert wo;

        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrder = wo;
                woli.WorkType = wtype;






        ContentVersion cv = new ContentVersion(
        VersionData = Blob.valueOf('Test content'),
        Title = 'Test Title',
        PathOnClient = 'Test.png'
        );
        insert cv;
    }

    /**
    * @description Test Work order attachments
    * @author Rob Cowell | 12-05-2020
    **/
    @isTest
    private static void testWorkOrderAttachments()
    {
        ContentDocument doc = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];

        WorkOrder wo = [SELECT Id from WorkOrder LIMIT 1];

        ContentDocumentLink link = new ContentDocumentLink(
        LinkedEntityId = wo.Id,
        ContentDocumentId = doc.Id,
        ShareType='V',
        Visibility='InternalUsers'
        );

        List<Work_Order_Attached_Image__c> attachedimages = [SELECT Id, Work_Order__c, Image_RTF__c from Work_Order_Attached_Image__c];
        System.assertEquals(0, attachedimages.size());

        test.startTest();
        S3TestMock mock = new S3TestMock();
        test.setMock(HttpCalloutMock.class, mock);
        S3UploadHandler.makeCallout = false;
        insert link;
        test.stopTest();

        attachedimages = [SELECT Id, Work_Order__c, Image_RTF__c from Work_Order_Attached_Image__c];

        System.debug('Work order attached images - ' + attachedimages);
        Work_Order_Attached_Image__c woai = attachedimages[0];
        System.assertEquals(wo.Id, woai.Work_Order__c);
    }


}