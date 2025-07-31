/**
 * @description       : 
 * @author            : Rob Cowell
 * @group             : 
 * @last modified on  : 14/01/2021
 * @last modified by  : Rob Cowell
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   21/12/2020   Rob Cowell   Initial Version
**/
@SuppressWarnings('PMD.AvoidGlobalModifier, PMD.ClassNamingConventions')
global class imageViewerDesignController extends VisualEditor.DynamicPickList
{
    global override VisualEditor.DataRow getDefaultValue()
    {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('Work Order', 'Work_Order_Attached_Image__c');
        return defaultValue;
    }

    global override VisualEditor.DynamicPickListRows getValues()
    {
        VisualEditor.DataRow workOrderValue = new VisualEditor.DataRow('Work Order', 'Work_Order_Attached_Image__c');
        VisualEditor.DataRow assetReadingValue = new VisualEditor.DataRow('Asset Reading', 'Asset_Reading_Attached_Image__c');
        VisualEditor.DataRow caseValue = new VisualEditor.DataRow('Case', 'Case_Attached_Image__c');
        VisualEditor.DataRow surveyValue = new VisualEditor.DataRow('Survey', 'Survey_Attached_Image__c');
        VisualEditor.DataRow assetValue = new VisualEditor.DataRow('Asset', 'Asset_Attached_Image__c');

        VisualEditor.DynamicPickListRows  picklistValues = new VisualEditor.DynamicPickListRows();
        picklistValues.addRow(workOrderValue);
        picklistValues.addRow(assetReadingValue);
        picklistValues.addRow(caseValue);
        picklistValues.addRow(surveyValue);
        picklistValues.addRow(assetValue);
        return picklistValues;
    }
}