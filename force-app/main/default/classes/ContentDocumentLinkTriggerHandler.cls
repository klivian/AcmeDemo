public with sharing class ContentDocumentLinkTriggerHandler
{
    public void afterInsert(Map<Id, ContentDocumentLink> newItems)
    {
        updateAttachmentRTF(newItems);
    }

    public void updateAttachmentRTF(Map<Id, ContentDocumentLink> links)
    {
        Map<Id, List<ContentDocumentLink>> entityLinkMap = new Map<Id, List<ContentDocumentLink>>();

        //Store the list of entity IDs
        Set<Id> workOrderSet = new Set<Id>();

        for (ContentDocumentLink link : links.values())
        {
            if(!entityLinkMap.containsKey(link.LinkedEntityId))
            {
                entityLinkMap.put(link.LinkedEntityId, new List<ContentDocumentLink>());
            }
            entityLinkMap.get(link.LinkedEntityId).add(link);

            //get linked entity object type
            String objectAPIName = link.LinkedEntityId.getSObjectType().getDescribe().getName();

            switch on objectAPIName
            {
                when 'WorkOrder'
                {
                    workOrderSet.add(link.LinkedEntityId);
                }
            }
        }

        if(workOrderSet.size() > 0)
        {
            updateWorkOrderAttachments(workOrderSet, entityLinkMap);
        }
    }

    public void updateWorkOrderAttachments(Set<Id> workOrderSet, Map<Id, List<ContentDocumentLink>> entityLinkMap)
    {
        List<WorkOrder> workOrders = [SELECT Id, Subject FROM WorkOrder WHERE Id IN :workOrderSet];

            Map<Id, List<Id>> docToEntityMap = new Map<Id, List<Id>>();
            Set<Id> docIDSet = new Set<Id>();

            for(List<ContentDocumentLink> cdlList : entityLinkMap.values())
            {
                for(ContentDocumentLink cdl : cdlList)
                {
                    if(!docToEntityMap.keySet().contains(cdl.LinkedEntityId))
                    {
                        docToEntityMap.put(cdl.LinkedEntityId, new List<Id>());
                    }
                    docToEntityMap.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);
                    docIDSet.add(cdl.ContentDocumentId);
                }
            }

            WorkOrderAttachmentBatch batch = new WorkOrderAttachmentBatch(new List<Id>(docIDSet), workOrders, docToEntityMap);
            Database.executeBatch(batch);
    }
}