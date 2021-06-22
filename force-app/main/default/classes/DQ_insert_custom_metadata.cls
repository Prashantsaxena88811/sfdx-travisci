/**
*@Desc: A class that can be used to insert and update multiple custom metadata records in a single transaction. 
**/
public class DQ_insert_custom_metadata {    
    /**
*@desc: A method to insert multiple records for custom metadata object in a single go. 
**/
    public void insertbulkMetadata(){
        try{
            List<Test_obj__c> customMetaDataRecordsTobe_inserted = new List<Test_obj__c>();
            customMetaDataRecordsTobe_inserted = [Select Custom_Field_Name__c,Custom_Metadata_Label__c,include_in_logic__c,Data_Type__c from Test_obj__c where 
                                                  Custom_Metadata_Label__c!=null  order by Name];
            System.debug('customMetaDataRecordsTobe_inserted==>'+customMetaDataRecordsTobe_inserted);
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            Integer count = 1;
            for(Test_obj__c rec:customMetaDataRecordsTobe_inserted){
                String nameSpacePrefix =''; // if the metadata belongs to any package than include the namespace.                
                //First Record 
                Metadata.CustomMetadata firstMetadataRec =  new Metadata.CustomMetadata();
                //firstMetadataRec.fullName = nameSpacePrefix + 'Contact_Merge__mdt.'+rec.Custom_Metadata_Label__c.replace('__c', '').mid(0, 40);
                firstMetadataRec.fullName = 'Contact_Merge__mdt.'+rec.Custom_Metadata_Label__c;
                count = count +1;
                firstMetadataRec.label = rec.Custom_Metadata_Label__c;
                //firstMetadataRec.Field_API_Name__c = rec.Custom_Metadata_Label__c;
                //adding values to fields
                Metadata.CustomMetadataValue customField1 = new Metadata.CustomMetadataValue();
                customField1.field = 'Rule_Type__c';
                String behavioutType ='';
                if(rec.include_in_logic__c == 'n'){
                    behavioutType = 'Default Behaviour';
                }else if(rec.include_in_logic__c == 'y'){
                    if(rec.Data_Type__c == 'Checkbox'){
                        behavioutType = 'Keep True';  
                    }else {
                        behavioutType = 'concatenation';  
                    }
                    
                }
                customField1.value = behavioutType;
                
                Metadata.CustomMetadataValue customField2 = new Metadata.CustomMetadataValue();
                customField2.field = 'Field_API_Name__c';
                customField2.value = rec.Custom_Field_Name__c;
                System.debug('rec.Custom_Field_Name__c=>'+rec.Custom_Field_Name__c);
                
                firstMetadataRec.values.add(customField1); 
                firstMetadataRec.values.add(customField2); 
                mdContainer.addMetadata(firstMetadataRec);  //adding record container that will be used to deploy the records in custom metadata.                        
            }
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);
            
            system.debug('jobId***'+jobId);
        }
        catch(Exception ex){             
            //System.assert(false,ex.getMessage()); 
            system.debug('Error while creating modifying custom metadata.');
        }
    }
    
}