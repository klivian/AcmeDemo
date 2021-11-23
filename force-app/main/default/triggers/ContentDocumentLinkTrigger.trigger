trigger ContentDocumentLinkTrigger on ContentDocumentLink (
    before insert, before update, before delete,
    after insert, after update, after delete, after undelete)
{
    ContentDocumentLinkTriggerHandler handler = new ContentDocumentLinkTriggerHandler();

    if(trigger.isBefore)
    {
        if(trigger.isInsert)
        {
            
        }
        if(trigger.isUpdate)
        {

        }
    }
    else if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            handler.afterInsert(trigger.newMap);
        }
        if(trigger.isUpdate)
        {

        }
    }
}