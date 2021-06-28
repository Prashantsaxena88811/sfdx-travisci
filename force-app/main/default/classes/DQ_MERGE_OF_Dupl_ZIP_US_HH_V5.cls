global class DQ_MERGE_OF_Dupl_ZIP_US_HH_V5 implements Database.Batchable<sObject>,Database.Stateful{
    // DUPlicate US_HH based upon the zip code and consider only those where on one or on both the email is BLANK
    // no related list
    Global String ParentIdVal = '';
    Global Integer recordCount = 0;
    Global String recordSetId = '';
    Global Boolean isMergeRecord = false;
    Global String errorList='' ;
    global DQ_MERGE_OF_Dupl_ZIP_US_HH_V5(String recordSetId ,string ParentIdVal,boolean isMergeRecord){
        this.recordSetId = recordSetId;
        this.isMergeRecord = isMergeRecord;
        if(ParentIdVal !='' && ParentIdVal!=null){
            this.ParentIdVal = ParentIdVal;
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //String recordSetId = '0GK2C000000AEka';
        String query='';
        System.debug('ParentIdVal>>>>>>>>'+ParentIdVal);
        System.debug('recordSetId>>>>>>>>'+recordSetId);
        if(Test.isRunningTest()){
            query = 'SELECT Id FROM DuplicateRecordSet where  RecordCount = 2  AND ID=:recordSetId';
            
        }else{
            //query = 'SELECT Id FROM DuplicateRecordSet where  RecordCount = 2 AND ParentId=:ParentIdVal AND ID=:recordSetId ';
            if(isMergeRecord){
                query = 'SELECT Id FROM DuplicateRecordSet where  RecordCount = 2 AND ParentId=:ParentIdVal AND qualified__c=True ';
            }else{
                query = 'SELECT Id FROM DuplicateRecordSet where  RecordCount = 2 AND ParentId=:ParentIdVal  ';
            }
        }
        
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<DuplicateRecordSet> DuplicateRecordSetChunk) {
        Savepoint sp = Database.setSavepoint();
        try {
            Map<String,String> churchValueMapping = new Map<String,String>();
            churchValueMapping.put('Associate Pastor'.toLowerCase(),'Pastor / Associate Pastor');
            churchValueMapping.put('Business Manager'.toLowerCase(),'Church Staff Member');
            churchValueMapping.put('Children\'s Ministry Director'.toLowerCase(),'Children\'s Pastor / Director');
            churchValueMapping.put('Children\'s Pastor'.toLowerCase(),'Children\'s Pastor / Director');
            churchValueMapping.put('Christian Education Director'.toLowerCase(),'Children\'s Pastor / Director');
            churchValueMapping.put('Church Secretary'.toLowerCase(),'Church Staff Member');
            churchValueMapping.put('Elder'.toLowerCase(),'Church Volunteer');
            churchValueMapping.put('Missions Committee Chairperson'.toLowerCase(),'Church Volunteer');
            churchValueMapping.put('Missions Committee Member'.toLowerCase(),'Church Volunteer');
            churchValueMapping.put('Pastor'.toLowerCase(),'Pastor / Associate Pastor');
            
            churchValueMapping.put('Rorheim Ambassador'.toLowerCase(),'');
            churchValueMapping.put('Worship Director'.toLowerCase(),'Church Staff Member');
            churchValueMapping.put('Youth pastor'.toLowerCase(),'Youth Pastor / Director');
            
            
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
                
                //List<DuplicateRecordSet> update_duplicateRecordset = new List<DuplicateRecordSet>();
                Map<Id,Contact> contactDataMap =  new Map<Id,Contact>([Select MailingPostalCode,Id,Email,AccountId,Account.RecordTypeId,(Select Id from npe5__Affiliations__r where isAccountSame__c = true limit 1) from Contact where ID IN :contactIdSet AND AccountId!=null AND Account.RecordTypeId IN :include_recordTypeIds]);
                Map<Id,Contact> contactDataMap1 = new Map<Id,Contact>();
                List<Contact_Merge__mdt> contactMergeFieldInfoList = new List<Contact_Merge__mdt>();
                contactMergeFieldInfoList = [Select Id,Label,Rule_Type__c,Field_API_Name__c from Contact_Merge__mdt where Rule_Type__c!=null];
                Map<String,String> field_ruleTypeMap = new Map<String,String>();
                
                String query = 'Select Id,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry ';
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
                    List<Contact> conList = new List<Contact>();// to be updated
                    for(DuplicateRecordSet DP_Set : recordSetList){
                        Boolean isHH = false , isUS = false , qualified=false;
                        Integer count_of_HH=0;
                        String HH_contactID = '';String US_contactID = '';
                        if(!DP_Set.DuplicateRecordItems.isEmpty()){
                            
                            String conId_1 = DP_Set.DuplicateRecordItems[0].RecordId;
                            String Email1;
                            if(contactDataMap.containsKey(conId_1) && contactDataMap.get(conId_1).get('Email')!=null){
                                Email1 = String.valueOf(contactDataMap.get(conId_1).get('Email'));
                            }
                            
                            String conId_2 = DP_Set.DuplicateRecordItems[1].RecordId;
                            String Email2;
                            System.debug('conId_2==>'+conId_2);
                            System.debug('contactDataMap.get(conId_2)'+contactDataMap.get(conId_2));
                            if(contactDataMap.containsKey(conId_2) && contactDataMap.get(conId_2).get('Email')!=null){
                                Email2 = String.valueOf(contactDataMap.get(conId_2).get('Email'));
                            }
                            
                            
                            
                            if(contactDataMap.containsKey(conId_1)  && contactDataMap.containsKey(conId_2)){
                                System.debug('contactDataMap.get(conId_1).Account=>'+contactDataMap.get(conId_1).MailingPostalCode);
                                System.debug('contactDataMap.get(conId_2).Account=>'+contactDataMap.get(conId_2).MailingPostalCode);
                                if(contactDataMap.get(conId_1).Account.recordTypeId == accounthouseholdId_TypeId){
                                    isHH = true;
                                    HH_contactID = conId_1;
                                }
                                else if(contactDataMap.get(conId_1).Account.recordTypeId == US_TypeId){
                                    isUS = true;
                                    US_contactID = conId_1;
                                }
                                if(contactDataMap.get(conId_2).Account.recordTypeId == accounthouseholdId_TypeId){
                                    isHH = true;
                                    HH_contactID = conId_2;
                                }
                                else if(contactDataMap.get(conId_2).Account.recordTypeId == US_TypeId){
                                    isUS = true;
                                    US_contactID = conId_2;
                                    
                                }
                                if(String.isNotBlank(Email1)  && 
                                   String.isNotBlank(Email2)){
                                       System.debug('email not blank');
                                      /* if(Email1.toLowerCase() == Email2.toLowerCase()){
                                           DuplicateRecordSet dupObj = new DuplicateRecordSet();
                                           dupObj.Id = DP_Set.Id;
                                           dupObj.DUP_US_HH_with_ZIP__c =  true;
                                           //update_duplicateRecordset.add(dupObj);
                                       }*/
                                       
                                   }else{
                                       if(isUS && isHH){
                                           if(isMergeRecord){
                                               System.debug('******Mereging records***********');
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
                                                                       if(contactDataMap1.get(US_contactID).get(conMerge.Field_API_Name__c)!=null){
                                                                           if(HH_field_length !=0){
                                                                               contactDataMap1.get(HH_contactID).put(conMerge.Field_API_Name__c,String.valueOf(contactDataMap1.get(HH_contactID).get(conMerge.Field_API_Name__c))+' '+String.valueOf(contactDataMap1.get(US_contactID).get(conMerge.Field_API_Name__c)).mid(0,total_field_length - (HH_field_length+1)));
                                                                           }else{
                                                                               System.debug('***null***************'+conMerge.Field_API_Name__c);
                                                                               contactDataMap1.get(HH_contactID).put(conMerge.Field_API_Name__c,String.valueOf(contactDataMap1.get(US_contactID).get(conMerge.Field_API_Name__c)));
                                                                               
                                                                           }
                                                                       }
                                                                       System.debug(conMerge.Field_API_Name__c+' conMerge.Field_API_Name__c  ==>'+contactDataMap1.get(HH_contactID).get(conMerge.Field_API_Name__c));
                                                                   }
                                                               }
                                                           }
                                                       }
                                                       
                                                   }
                                                   
                                                   System.debug('HH_AWANA_ROLE==>'+ String.valueOf(contactDataMap1.get(HH_contactID).get('Awana_Role__c')));
                                                   //add awana to role new Affliation.
                                                   //create the affliation records on household  Start
                                                   if(contactDataMap1.containsKey(US_contactID) && contactDataMap1.containsKey(HH_contactID) 
                                                      && contactDataMap.get(US_contactID).npe5__Affiliations__r ==null || 
                                                      contactDataMap.get(US_contactID).npe5__Affiliations__r.isEmpty()){
                                                          System.debug('*******creating affliation***');
                                                          npe5__Affiliation__c affiliationObj = new npe5__Affiliation__c();
                                                          affiliationObj.npe5__Organization__c = contactDataMap.get(US_contactID).AccountId;
                                                          affiliationObj.npe5__Contact__c = HH_contactID;
                                                          System.debug('Awana_Role__c value on US==>'+contactDataMap1.get(US_contactID).get('Awana_Role__c'));
                                                          if(contactDataMap1.get(HH_contactID).get('Awana_Role__c') != null &&
                                                             contactDataMap1.get(HH_contactID).get('Awana_Role__c') !=''){
                                                                 List<String> awanaRolesONUS_Contact = new List<String>();
                                                                 awanaRolesONUS_Contact = String.valueOf(contactDataMap1.get(HH_contactID).get('Awana_Role__c')).split(';');
                                                                 System.debug('awanaRolesONUS_Contact==>'+awanaRolesONUS_Contact);
                                                                 String awan_roles_for_affilaition='';
                                                                 for(String awanaRoleContact : awanaRolesONUS_Contact){
                                                                     if(affiliationsAwanaRoles.contains(awanaRoleContact.toLowerCase())){
                                                                         System.debug('****************false');
                                                                         awan_roles_for_affilaition = awan_roles_for_affilaition+';'+awanaRoleContact;
                                                                         //isAllValExist = false;
                                                                         //break;
                                                                     }
                                                                 }
                                                                 if(String.isNotBlank( awan_roles_for_affilaition)){
                                                                     affiliationObj.Awana_Role__c = awan_roles_for_affilaition;
                                                                 }
                                                                 
                                                                 // add awana role end
                                                                 // add church role start
                                                                 if(contactDataMap1.get(HH_contactID).get('Church_Role__c') != null &&
                                                                    contactDataMap1.get(HH_contactID).get('Church_Role__c') !=''){
                                                                        String churchRole_HH = String.valueOf(contactDataMap1.get(HH_contactID).get('Church_Role__c')).split(';')[0];
                                                                        if(String.isNotBlank( churchRole_HH)){
                                                                            
                                                                            if(churchValueMapping.containsKey(churchRole_HH.toLowerCase())){
                                                                                affiliationObj.Church_Role__c = churchValueMapping.get(churchRole_HH.toLowerCase());
                                                                            }
                                                                            
                                                                        }
                                                                    }
                                                                 // add church role END
                                                             }
                                                          affiliationList.add(affiliationObj);
                                                          
                                                      }
                                                   
                                                   
                                                   
                                                   //create the affliation records on household  END
                                                   
                                               }
                                               
                                               
                                               Merge contactDataMap1.get(HH_contactID)  US_contactID;
                                           }else{
                                               DP_Set.qualified__c = true;
                                               System.debug('Do not merge Contact records');
                                               contact conObj = new Contact();
                                               conObj.Id = HH_contactID;
                                               conObj.Dup_Record__c = true;
                                               
                                               contact conObj1 = new Contact();
                                               conObj1.Id = US_contactID;
                                               conObj1.Dup_Record__c = true;
                                               
                                               conList.add(conObj);
                                               conList.add(conObj1);
                                           }
                                           
                                       }
                                       
                                   }
                            }
                            
                        }
                        
                    }
                    System.debug('affiliationList==>'+affiliationList);
                    if(isMergeRecord && affiliationList!=null && !affiliationList.isEmpty()  ){
                         insert affiliationList;
                    }
                    if(!isMergeRecord){
                        update recordSetList;
                        if(conList!=null && !conList.isEmpty()){
                            System.debug('conList==>'+conList); 
                            update conList;
                        } 
                    }
                }
                
            }
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber()+' error is=>'+e.getMessage()+' trace->'+e.getStackTraceString());
            Database.rollback(sp);
            errorList = errorList + ' get exception on line number-->'+e.getLineNumber()+' error is=>'+e.getMessage()+' chunkId=>'+DuplicateRecordSetChunk[0]+' <br>';
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'Prashant@infoglen.com'};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Match Merge Batch DQ_MERGE_OF_Dupl_ZIP_US_HH_V5 '+ParentIdVal);
        
        mail.setHtmlBody(errorList);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
}