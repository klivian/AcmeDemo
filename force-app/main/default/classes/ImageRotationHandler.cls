public with sharing class ImageRotationHandler 
{
    // Construct the URL for the call to the image handler endpoint
     public static string getRotatedURL(String imageFilename)
    {
        String endpointURL = ([Select Value__c from AWS_Setting__mdt where Developername = 'Image_Handler_Endpoint']).Value__c;
        String bucketName = ([Select Value__c from AWS_Setting__mdt where Developername = 'S3_Bucket_Name']).Value__c;
        String maxHeight = ([Select Value__c from AWS_Setting__mdt where Developername = 'Max_image_height']).Value__c;

        Map<String, Object> obj = new Map<String, Object>();
        Map<String, Object> edits = new Map<String, Object>();
        Map<String, Object> resizeParams = new Map<String, Object>();

        resizeParams.put('height', Integer.valueOf(maxHeight));
        edits.put('rotate', null);  //passing null tells the handler to use the orientation of the image metadata, where available (portrait/landscape)
        edits.put('resize', resizeParams);
        obj.put('bucket', bucketname);
        obj.put('key', imageFilename);
        obj.put('edits', edits);

        String serialized = JSON.serialize(obj);

        String jsonString = EncodingUtil.base64Encode(Blob.valueOf(serialized));
        return endpointURL + jsonString;
    }
}