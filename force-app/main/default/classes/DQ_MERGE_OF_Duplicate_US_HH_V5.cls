//ID jobID = System.enqueueJob(new DQ_Count_OF_Duplicate_US_HH());
global class DQ_MERGE_OF_Duplicate_US_HH_V5 implements Database.Batchable<sObject>,Database.Stateful{
    // no related list
    Global String ParentIdVal = '0PB2C000000KykEWAS';
    Global Integer recordCount = 0;
    Global String recordSetId = '';
    global DQ_MERGE_OF_Duplicate_US_HH_V5(String recordSetId ,string ParentIdVal){
        this.recordSetId = recordSetId;
        if(ParentIdVal !='' && ParentIdVal!=null){
            this.ParentIdVal = ParentIdVal;
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //String recordSetId = '0GK2C000000ADO1';
        String query='';
        System.debug('ParentIdVal>>>>>>>>'+ParentIdVal);
        System.debug('recordSetId>>>>>>>>'+recordSetId);
        if(Test.isRunningTest()){
            query = 'SELECT Id FROM DuplicateRecordSet where  RecordCount = 2  AND ID=:recordSetId';
            
        }else{
            query = 'SELECT Id FROM DuplicateRecordSet where  RecordCount = 2 AND ParentId=:ParentIdVal AND ID=:recordSetId';
        }
        
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<DuplicateRecordSet> DuplicateRecordSetChunk) {
        try {
            Set<String> affiliationsAwanaRoles = new Set<String>();
            Schema.DescribeFieldResult fieldDescription = npe5__Affiliation__c.Awana_Role__c.getDescribe();
            List<Schema.PicklistEntry> entries = fieldDescription.getPicklistValues();
            for( Schema.PicklistEntry pickVal : entries){
                if(pickVal.isActive()){
                    affiliationsAwanaRoles.add(pickVal.getValue().toLowerCase());
                }
            }
            System.debug('affiliationsAwanaRoles->'+affiliationsAwanaRoles);

            System.debug('DuplicateRecordSetChunk==>'+DuplicateRecordSetChunk);
            List<DuplicateRecordSet> recordSetList = new List<DuplicateRecordSet>();
            if(Test.isRunningTest()){
                recordSetList = [Select Id,(Select Id,RecordId from DuplicateRecordItems) from DuplicateRecordSet 
                                 where RecordCount = 2 AND Id IN :DuplicateRecordSetChunk];
            }else{
                recordSetList = [Select Id,(Select Id,RecordId from DuplicateRecordItems) from DuplicateRecordSet 
                                 where ParentId=:ParentIdVal AND RecordCount = 2 AND Id IN :DuplicateRecordSetChunk];
            }
            String accounthouseholdId_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='HH_Account'].Id;
            String US_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='US_Organization'].Id;
            
            Set<String> include_recordTypeIds =  new set<String>();
            include_recordTypeIds.add(accounthouseholdId_TypeId);
            include_recordTypeIds.add(US_TypeId);
            
            Set<String> contactIdSet =  new Set<String>();
            
            System.debug('recordSetList==>'+recordSetList);
            //Map<String,String>
            for(DuplicateRecordSet DP_Set : recordSetList){
                if(!DP_Set.DuplicateRecordItems.isEmpty()){
                    for(DuplicateRecordItem DP_SetItem : DP_Set.DuplicateRecordItems){
                        contactIdSet.add(DP_SetItem.recordId);
                    }
                }
            }
            if(!contactIdSet.isEmpty()){
                Map<Id,Contact> contactDataMap =  new Map<Id,Contact>([Select Id,AccountId,Account.RecordTypeId,(Select Id from npe5__Affiliations__r where isAccountSame__c = true limit 1) from Contact where ID IN :contactIdSet AND AccountId!=null AND Account.RecordTypeId IN :include_recordTypeIds]);
                //Map<Id,Contact> contactDataMap1 =  new Map<Id,Contact>([Select Id from Contact where ID IN :contactIdSet AND AccountId!=null AND Account.RecordTypeId IN :include_recordTypeIds]);
                Map<Id,Contact> contactDataMap1 = new Map<Id,Contact>();
                List<Contact_Merge__mdt> contactMergeFieldInfoList = new List<Contact_Merge__mdt>();
                contactMergeFieldInfoList = [Select Id,Label,Rule_Type__c,Field_API_Name__c from Contact_Merge__mdt where Rule_Type__c!=null];
                Map<String,String> field_ruleTypeMap = new Map<String,String>();
                
                String query = 'Select Church_Role__c,Awana_Role__c,Id,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry ';
                for(Contact_Merge__mdt conMerge : contactMergeFieldInfoList){
                    field_ruleTypeMap.put(conMerge.Field_API_Name__c.toLowerCase(),conMerge.Rule_Type__c);
                    query= query+','+conMerge.Field_API_Name__c;
                }
                System.debug('fields to be queried=1=>'+query);
                query = query+' from contact where ID IN :contactIdSet AND AccountId!=null AND Account.RecordTypeId IN :include_recordTypeIds';
                System.debug('Final Query=>'+query);
                
                List<Contact> contactList = new List<Contact>();
                contactList = Database.query(query);
                System.debug('contactList==>'+contactList);
                for(contact conObj:contactList){
                    contactDataMap1.put(conObj.Id,conObj);
                }
                if(contactDataMap!=null && !contactDataMap.isEmpty()){
                    List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
                    for(DuplicateRecordSet DP_Set : recordSetList){
                        Boolean isHH = false , isUS=false ,isAffliationPresent = false;
                        String HH_contactID = '';String US_contactID = '';
                        if(!DP_Set.DuplicateRecordItems.isEmpty()){
                            for(DuplicateRecordItem DP_SetItem : DP_Set.DuplicateRecordItems){
                                if(contactDataMap.containsKey(DP_SetItem.RecordId)){
                                    if(contactDataMap.get(DP_SetItem.RecordId).Account.RecordTypeID == accounthouseholdId_TypeId){
                                        isHH = true;
                                        HH_contactID = DP_SetItem.RecordId;
                                    }
                                    else if(contactDataMap.get(DP_SetItem.RecordId).Account.RecordTypeID == US_TypeId){
                                        isUS = true;
                                        US_contactID = DP_SetItem.RecordId;
                                        
                                    }
                                    
                                }
                            }
                        }
                        if(isHH && isUS){
                            recordCount = recordCount +1;
                            //create the affliation records on household  Start
                            if(contactDataMap.get(US_contactID).npe5__Affiliations__r ==null || 
                               contactDataMap.get(US_contactID).npe5__Affiliations__r.isEmpty()){
                                   System.debug('*******creating affliation***');
                                   npe5__Affiliation__c affiliationObj = new npe5__Affiliation__c();
                                   affiliationObj.npe5__Organization__c = contactDataMap.get(US_contactID).AccountId;
                                   affiliationObj.npe5__Contact__c = HH_contactID;
                                   System.debug('Awana_Role__c value on US==>'+contactDataMap1.get(US_contactID).get('Awana_Role__c'));
                                   if(contactDataMap1.get(US_contactID).get('Awana_Role__c') != null &&
                                      contactDataMap1.get(US_contactID).get('Awana_Role__c') !=''){
                                          List<String> awanaRolesONUS_Contact = new List<String>();
                                          awanaRolesONUS_Contact = String.valueOf(contactDataMap1.get(US_contactID).get('Awana_Role__c')).split(';');
                                          Boolean isAllValExist = true;
                                          System.debug('awanaRolesONUS_Contact==>'+awanaRolesONUS_Contact);
                                          for(String awanaRoleContact : awanaRolesONUS_Contact){
                                              if(!affiliationsAwanaRoles.contains(awanaRoleContact.toLowerCase())){
                                                  System.debug('****************false');
                                                  isAllValExist = false;
                                                  break;
                                              }
                                          }
                                          if(isAllValExist){
                                              affiliationObj.Awana_Role__c = String.valueOf(contactDataMap1.get(US_contactID).get('Awana_Role__c'));
                                          }
                                      }
                                   affiliationList.add(affiliationObj);
                                   
                               }
                            
                            //create the affliation records on household  END
                            
                            //Merge the Church_Role__c field values Start
                            if(contactDataMap1.get(US_contactID).get('Church_Role__c') != null && contactDataMap1.get(HH_contactID).get('Church_Role__c') != null){
                                List<String> churchRoleOn_US_Contact_List = String.valueOf(contactDataMap1.get(US_contactID).get('Church_Role__c')).split(';');
                                
                                String churchRoleOn_HH_Contact = String.valueOf(contactDataMap1.get(HH_contactID).get('Church_Role__c'));
                                Set<String> churchRoleOn_HH_Contact_set = new Set<String>(churchRoleOn_HH_Contact.split(';'));
                                for(String role_ON_US :churchRoleOn_US_Contact_List){
                                    if(!churchRoleOn_HH_Contact_set.contains(role_ON_US)){
                                        churchRoleOn_HH_Contact = churchRoleOn_HH_Contact + ';'+role_ON_US;
                                    }
                                }
                                contactDataMap1.get(HH_contactID).put('Church_Role__c',churchRoleOn_HH_Contact); 
                                
                            }
                            //Merge the Church_Role__c field values END
                            
                            // add the values in field of HH contact from US contact
                            if(contactDataMap1.containsKey(US_contactID) && contactDataMap1.containsKey(HH_contactID)){
                                // get Other Addrss for US contact if HH contact having no mailing Address
                                if(contactDataMap1.get(HH_contactID).get('MailingStreet') == null && contactDataMap1.get(HH_contactID).get('MailingCity') == null &&
                                   contactDataMap1.get(HH_contactID).get('MailingState') == null && contactDataMap1.get(HH_contactID).get('MailingPostalCode') == null &&
                                   contactDataMap1.get(HH_contactID).get('MailingCountry') == null ){
                                       
                                       if(contactDataMap1.get(US_contactID).get('OtherStreet')!=null){
                                           contactDataMap1.get(HH_contactID).put('MailingStreet',contactDataMap1.get(US_contactID).get('OtherStreet'));
                                       }
                                       if(contactDataMap1.get(US_contactID).get('OtherCity')!=null){
                                           contactDataMap1.get(HH_contactID).put('MailingCity',contactDataMap1.get(US_contactID).get('OtherCity'));
                                       }
                                       if(contactDataMap1.get(US_contactID).get('OtherState')!=null){
                                           contactDataMap1.get(HH_contactID).put('MailingState',contactDataMap1.get(US_contactID).get('OtherState'));
                                       }
                                       if(contactDataMap1.get(US_contactID).get('OtherPostalCode')!=null){
                                           contactDataMap1.get(HH_contactID).put('MailingPostalCode',contactDataMap1.get(US_contactID).get('OtherPostalCode'));
                                       }
                                       if(contactDataMap1.get(US_contactID).get('OtherCountry')!=null){
                                           contactDataMap1.get(HH_contactID).put('MailingCountry',contactDataMap1.get(US_contactID).get('OtherCountry'));
                                       }
                                       
                                   }
                                // iterate over fields added in metadata
                                for(Contact_Merge__mdt conMerge : contactMergeFieldInfoList){
                                    
                                    if(field_ruleTypeMap.containsKey(conMerge.Field_API_Name__c.toLowerCase())){
                                        if(field_ruleTypeMap.get(conMerge.Field_API_Name__c.toLowerCase()) == 'Default Behaviour' ){
                                            if(contactDataMap1.get(HH_contactID).get(conMerge.Field_API_Name__c)==null){
                                                if( contactDataMap1.get(US_contactID).get(conMerge.Field_API_Name__c)!=null){
                                                    contactDataMap1.get(HH_contactID).put(conMerge.Field_API_Name__c,contactDataMap1.get(US_contactID).get(conMerge.Field_API_Name__c));
                                                }  
                                            }
                                        }else if(field_ruleTypeMap.get(conMerge.Field_API_Name__c.toLowerCase()) == 'Keep True'){
                                            if(contactDataMap1.get(HH_contactID).get(conMerge.Field_API_Name__c) == False){
                                                if(contactDataMap1.get(US_contactID).get(conMerge.Field_API_Name__c) == True){
                                                    contactDataMap1.get(HH_contactID).put(conMerge.Field_API_Name__c,contactDataMap1.get(US_contactID).get(conMerge.Field_API_Name__c));
                                                }
                                            }
                                        }else if(field_ruleTypeMap.get(conMerge.Field_API_Name__c.toLowerCase()) == 'concatenation'){
                                            Schema.SObjectType objectType = Schema.getGlobalDescribe().get('Contact');
                                            Schema.DescribeFieldResult dfr = objectType.getDescribe().fields.getMap().get(conMerge.Field_API_Name__c).getDescribe();
                                            if(dfr.getType() == Schema.DisplayType.TEXTAREA || dfr.getType() == Schema.DisplayType.STRING ){
                                                Integer HH_field_length = 0;
                                                Integer total_field_length = dfr.getLength();
                                                if(contactDataMap1.get(HH_contactID).get(conMerge.Field_API_Name__c)!=null && 
                                                   contactDataMap1.get(HH_contactID).get(conMerge.Field_API_Name__c)!=''){
                                                       //String fieldValue = contactDataMap1.get(HH_contactID).get(conMerge.Field_API_Name__c);
                                                       HH_field_length = String.valueOf(contactDataMap1.get(HH_contactID).get(conMerge.Field_API_Name__c)).length();
                                                   }
                                                
                                                //get value from US contact
                                                if(total_field_length - HH_field_length != 0){
                                                    if(HH_field_length !=0){
                                                        contactDataMap1.get(HH_contactID).put(conMerge.Field_API_Name__c,String.valueOf(contactDataMap1.get(HH_contactID).get(conMerge.Field_API_Name__c))+' '+String.valueOf(contactDataMap1.get(US_contactID).get(conMerge.Field_API_Name__c)).mid(0,total_field_length - (HH_field_length+1)));
                                                    }else{
                                                        System.debug('***null***************'+conMerge.Field_API_Name__c);
                                                        contactDataMap1.get(HH_contactID).put(conMerge.Field_API_Name__c,String.valueOf(contactDataMap1.get(US_contactID).get(conMerge.Field_API_Name__c)));
                                                        
                                                    }
                                                    System.debug(conMerge.Field_API_Name__c+' conMerge.Field_API_Name__c  ==>'+contactDataMap1.get(HH_contactID).get(conMerge.Field_API_Name__c));
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                                // add
                            }
                            
                            
                            Merge contactDataMap1.get(HH_contactID)  US_contactID;
                            
                        }
                    }
                    System.debug('affiliationList==>'+affiliationList);
                    if(affiliationList!=null && !affiliationList.isEmpty()){
                       insert affiliationList;
                    }
                }
            }
            
            
            
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber()+' error is=>'+e.getMessage()+' trace->'+e.getStackTraceString());
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        /*DQ_Count__c dq = new DQ_Count__c();
        Integer size = [Select Id from DQ_Count__c].Size()+1;
        dq.Name = 'DQ1'+size;
        dq.accountRecords__c = recordCount;
        upsert dq;*/
    }
}
/*Schema.SObjectType objectType = Schema.getGlobalDescribe().get('Account');
Schema.DescribeFieldResult dfr = objectType.getDescribe().fields.getMap().get('Description').getDescribe();
integer fieldLength = dfr.getLength();	
System.debug('fieldLength->'+fieldLength);

*/