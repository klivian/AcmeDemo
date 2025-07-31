/**
 * @description       : 
 * @author            : Rob Cowell
 * @group             : 
 * @last modified on  : 14/01/2021
 * @last modified by  : Rob Cowell
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   14/01/2021   Rob Cowell   Initial Version
**/
public with sharing class ImageAttachmentController
{
    @AuraEnabled(cacheable=true)
    @SuppressWarnings('PMD.ApexSOQLInjection')
    public static List<SObject> getImages(Id recordId, String objectName)
    {
            List<SObject> images = new List<SObject>();
            if(recordId != null && objectName != null)
            {
                String query = 'SELECT Image_RTF__c FROM ' + objectName + ' WHERE Work_Order__c = \'' + recordId + '\'';
                images = Database.query(query);
            }
            return images;
    }
}