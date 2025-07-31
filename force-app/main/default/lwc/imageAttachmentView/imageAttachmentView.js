import { LightningElement, wire, api, track } from 'lwc';
import getImages from '@salesforce/apex/ImageAttachmentController.getImages';

export default class ImageAttachmentView extends LightningElement
{
    @api listType;
    @api recordId;

    listlabel;

    @wire(getImages, {recordId : '$recordId', objectName : '$listType'})
    images;

    connectedCallback()
    {
        switch(this.listType)
        {
            case 'Work_Order_Attached_Image__c':
                this.listlabel = 'Work Order Images';
                break;
            case 'Asset_Reading_Attached_Image__c':
                this.listlabel = 'Asset Reading Images';
                break;
            case 'Case_Attached_Image__c':
                this.listlabel = 'Case Images';
                break;
            case 'Survey_Attached_Image__c':
                this.listlabel = 'Survey Images';
                break;
            case 'Asset_Attached_Image__c':
                this.listlabel = 'Asset Images';
                break;
            default:
                this.listlabel = 'Attached Images';
        }
    }
}