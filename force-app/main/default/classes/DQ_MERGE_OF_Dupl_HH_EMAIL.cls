global class DQ_MERGE_OF_Dupl_HH_EMAIL implements Database.Batchable<sObject>,Database.Stateful{
   // no related list//0GK2C000000ADO2
    //database.executeBatch(new DQ_MERGE_OF_Dupl_HH_EMAIL('0GK2C000000ADO2','',false),2000);
    
    Global String ParentIdVal = '0PB2C000000KykEWAS';
    Global Integer recordCount = 0;
    Global String recordSetId = '';//0GK2C000000ADO2
    Global Boolean isMergeRecord = false;
    Global String errorList='' ;
    global DQ_MERGE_OF_Dupl_HH_EMAIL(String recordSetId ,string ParentIdVal,boolean isMergeRecord){
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
            //query = 'SELECT Id FROM DuplicateRecordSet where  RecordCount = 2 AND ParentId=:ParentIdVal ';
            //NOTE check DQ_MERGE_OF_Dupl_ZIP_US_HH_V5 to add qualified check.
            if(String.isNotBlank(recordSetId)){
                query = query +  ' AND ID=:recordSetId ';
            }
        }
        
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<DuplicateRecordSet> DuplicateRecordSetChunk) {
        Savepoint sp = Database.setSavepoint();
        try {
            // Church Value Mapping
            /*Map<String,String> churchValueMapping = new Map<String,String>();
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
            churchValueMapping.put('Youth pastor'.toLowerCase(),'Youth Pastor / Director');*/
            
            
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
            //String US_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='US_Organization'].Id;
            
            Set<String> include_recordTypeIds =  new set<String>();
            include_recordTypeIds.add(accounthouseholdId_TypeId);
            //include_recordTypeIds.add(US_TypeId);
            
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
                String accountField='',contactFields='';
                contactFields = 'Select Id,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry ';
                accountField = 'Select Id,BillingCity,BillingCountry,BillingGeocodeAccuracy,BillingLatitude,BillingLongitude,BillingPostalCode,BillingState,BillingStreet,IntacctID__c';
                List<Contact_Merge__mdt> contactMergeFieldInfoList = new List<Contact_Merge__mdt>();
                List<Contact_Merge__mdt> AccountMergeFieldInfoList = new List<Contact_Merge__mdt>();
                contactMergeFieldInfoList = [Select Id,Entity_Type__c,Label,Rule_Type__c,Field_API_Name__c from Contact_Merge__mdt where Rule_Type__c!=null AND  Entity_Type__c='Contact'];
                AccountMergeFieldInfoList = [Select Id,Entity_Type__c,Label,Rule_Type__c,Field_API_Name__c from Contact_Merge__mdt where Rule_Type__c!=null AND  Entity_Type__c='Account'];
                
                //Map<String,String> field_ruleTypeMap_Contact = new Map<String,String>();
                //Map<String,String> field_ruleTypeMap_Account = new Map<String,String>();
                for(Contact_Merge__mdt conMerge : contactMergeFieldInfoList){
                    if(conMerge.Entity_Type__c == 'Contact'){
                        //field_ruleTypeMap_Contact.put(conMerge.Field_API_Name__c.toLowerCase(),conMerge.Rule_Type__c);
                        contactFields= contactFields+','+conMerge.Field_API_Name__c;
                    }
                    
                }
                for(Contact_Merge__mdt conMerge : AccountMergeFieldInfoList){
                     if(conMerge.Entity_Type__c == 'Account'){
                        //field_ruleTypeMap_Account.put(conMerge.Field_API_Name__c.toLowerCase(),conMerge.Rule_Type__c);
                        accountField= accountField+','+conMerge.Field_API_Name__c;
                    }
                    
                }
                System.debug('fields to be queried contactFields =1=>'+contactFields);
                contactFields = contactFields+' from contact where ID IN :contactIdSet AND AccountId!=null AND Account.RecordTypeId IN :include_recordTypeIds';
                System.debug('Final Query contactFields=>'+contactFields);
                
                List<DuplicateRecordSet> update_duplicateRecordset = new List<DuplicateRecordSet>();
                Map<Id,Contact> contactDataMap =  new Map<Id,Contact>([Select Gigya_UID__c,Id,AccountId,Account.RecordTypeId,(Select Id from npe5__Affiliations__r where isAccountSame__c = true limit 1) from Contact where ID IN :contactIdSet AND AccountId!=null AND Account.RecordTypeId IN :include_recordTypeIds]);
                Map<Id,Contact> contact_MAP_WIthALLField =  new Map<Id,Contact>();
                List<Contact> contactList = new List<Contact>();
                contactList = Database.query(contactFields);
                System.debug('contactList==>'+contactList);
                for(contact conObj:contactList){
                    contact_MAP_WIthALLField.put(conObj.Id,conObj);
                }
                if(contactDataMap!=null && !contactDataMap.isEmpty()){
                    List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
                    List<Contact> contactToBeMarked = new List<Contact>();
                    List<Account> accountToBeMarked = new List<Account>();
                    Set<String> HH_ContactIds = new Set<String>();
                    //Set<Id> relatedAccountIds = new Set<Id>();
                    // Map duplicaterecordId to Account Set
                    Map<String,List<String>> duplicateRecordSet_TO_AccountIDs = new Map<String,List<String>>();
                    
                    //contact to AccountId MAP
                    Map<String,String> AccountIdTocontactMap = new  Map<String,String>();
                    
                    Set<String> relatedAccountIds_Set = new Set<String>();
                    // Iteration On Duplicate Set to Find Qualified Contacts Ids START here
                    for(DuplicateRecordSet DP_Set : recordSetList){
                        Integer count_of_HH=0;
                        if(!DP_Set.DuplicateRecordItems.isEmpty()){
                            Set<String> HH_ContactIds_Local = new Set<String>();
                            Set<String> relatedAccountIds_Set_Local = new Set<String>();
                            
                            for(DuplicateRecordItem DP_SetItem : DP_Set.DuplicateRecordItems){
                                if(contactDataMap.containsKey(DP_SetItem.RecordId)){
                                    if(contactDataMap.get(DP_SetItem.RecordId).Account.RecordTypeID == accounthouseholdId_TypeId){
                                        count_of_HH = count_of_HH +1;
                                        HH_ContactIds_Local.add(DP_SetItem.RecordId);
                                        relatedAccountIds_Set_Local.add(contactDataMap.get(DP_SetItem.RecordId).AccountId);
                                        //relatedAccountIds.add(contactDataMap.get(DP_SetItem.RecordId).AccountId);
                                        //AccountIdTocontactMap.put(contactDataMap.get(DP_SetItem.RecordId).AccountId,DP_SetItem.RecordId);
                                    }
                                }
                            }
                            if(count_of_HH == 2){
                                System.debug('**count_of_HH**');
                                // make set of contacts , if both are related to Household Account
                                HH_ContactIds.addALL(HH_ContactIds_Local);
                                // change this one to only add accountId set , if size = 2
                                // if(relatedAccountIds_Set_Local.size() == 2){
                                //duplicateRecordSet_TO_AccountIDs.put(DP_Set.Id,new Set<String>(relatedAccountIds_Set_Local));
                                duplicateRecordSet_TO_AccountIDs.put(DP_Set.Id,new List<String>(relatedAccountIds_Set_Local));
                                relatedAccountIds_Set.addAll(relatedAccountIds_Set_Local);
                                List<String> HH_ContactIds_Local_List = new List<String>(HH_ContactIds_Local);
                                AccountIdTocontactMap.put(contactDataMap.get(HH_ContactIds_Local_List[0]).AccountId,HH_ContactIds_Local_List[0]);
                                AccountIdTocontactMap.put(contactDataMap.get(HH_ContactIds_Local_List[1]).AccountId,HH_ContactIds_Local_List[1]);
                                //  }
                                
                                //accounToContact Map
                                
                            }
                        }
                        if(!update_duplicateRecordset.isEmpty()){
                            //update update_duplicateRecordset;
                        }
                    }
                    // Iteration On Duplicate Set to Find Qualified Contacts Ids and AccountId END here
                    
                    
                    // query for account fields START
                    System.debug('fields to be queried AccountFields =1=>'+accountField);
                    accountField = accountField+' from Account where ID IN :relatedAccountIds_Set';
                    System.debug('Final Query accountField=>'+accountField);
                    
                    Map<Id,Account> accountMap_withALL_field =  new Map<Id,Account>();
                    List<Account> accountList = new List<Account>();
                    accountList = Database.query(accountField);
                    System.debug('accountList==>'+accountList);
                    for(Account accObj:accountList){
                        accountMap_withALL_field.put(accObj.Id,accObj);
                    }
                    // QUER  for Contact field END
                    System.debug('accountMap_withALL_field=>'+accountMap_withALL_field);
                    
                    System.debug('relatedAccountIds_Set=>'+relatedAccountIds_Set);
                    // do Processing on the duplicateRecordSet_TO_AccountIDs MAP
                    if(!HH_ContactIds.isEmpty() && !duplicateRecordSet_TO_AccountIDs.isEmpty()){
                        Map<Id,Account> accountMap_withRelatedList = new Map<Id,Account>([Select Id,(Select Id,createddate from Orders order by createddate desc Limit 1),
                                                                                          (Select Id,createddate from Opportunities order by createddate desc Limit 1) from Account Where Id IN : relatedAccountIds_Set]);
                        
                        System.debug('accountMap_withRelatedList=>'+accountMap_withRelatedList);
                        // start mergin the Account and contact  records.
                        //for(String dupRecordSetId : duplicateRecordSet_TO_AccountIDs.keySet()){
                        
                        for(DuplicateRecordSet DP_Set : recordSetList){
                            if(!DP_Set.DuplicateRecordItems.isEmpty() && DP_Set.DuplicateRecordItems.size() == 2){
                                String dupRecordSetId = DP_Set.Id;
                                String masterAccountId , mergerAccountId;
                                Integer countOfAccId_with_DupSet = 0;
                                if(duplicateRecordSet_TO_AccountIDs.containsKey(dupRecordSetId) ){
                                    
                                    // both contact belongs to different Account
                                    if( duplicateRecordSet_TO_AccountIDs.get(dupRecordSetId).size() == 2){
                                        countOfAccId_with_DupSet = 2;
                                        
                                        String AccountId1 = duplicateRecordSet_TO_AccountIDs.get(dupRecordSetId)[0];
                                        String AccountId2 = duplicateRecordSet_TO_AccountIDs.get(dupRecordSetId)[1];
                                        
                                        // check in orders First
                                        if(!accountMap_withRelatedList.get(AccountId1).Orders.isEmpty() && !accountMap_withRelatedList.get(AccountId2).Orders.isEmpty()){
                                            System.debug('*********check in orders*********');
                                            if(accountMap_withRelatedList.get(AccountId1).Orders[0].createdDate > accountMap_withRelatedList.get(AccountId2).Orders[0].createdDate){
                                                masterAccountId = AccountId1;
                                                mergerAccountId = AccountId2;
                                            }else{
                                                masterAccountId = AccountId2;
                                                mergerAccountId = AccountId1;
                                            }
                                        }else if(!accountMap_withRelatedList.get(AccountId1).Orders.isEmpty()){
                                            System.debug('*********check in orders1*********');
                                            masterAccountId = AccountId1;
                                            mergerAccountId = AccountId2;
                                            
                                        }else if(!accountMap_withRelatedList.get(AccountId2).Orders.isEmpty()){
                                            System.debug('*********check in orders2*********');
                                            masterAccountId = AccountId2;
                                            mergerAccountId = AccountId1;
                                        }
                                        // check for doantions , if any
                                        if(String.isBlank(masterAccountId)){
                                            System.debug('*********check in donation*********');
                                            if(!accountMap_withRelatedList.get(AccountId1).Opportunities.isEmpty() && !accountMap_withRelatedList.get(AccountId2).Opportunities.isEmpty()){
                                                if(accountMap_withRelatedList.get(AccountId1).Opportunities[0].createdDate > accountMap_withRelatedList.get(AccountId2).Opportunities[0].createdDate){
                                                    masterAccountId = AccountId1;
                                                    mergerAccountId = AccountId2;
                                                }else{
                                                    masterAccountId = AccountId2;
                                                    mergerAccountId = AccountId1;
                                                }
                                            }else if(!accountMap_withRelatedList.get(AccountId1).Opportunities.isEmpty()){
                                                masterAccountId = AccountId1;
                                                mergerAccountId = AccountId2;
                                                
                                            }else if(!accountMap_withRelatedList.get(AccountId2).Opportunities.isEmpty()){
                                                masterAccountId = AccountId2;
                                                mergerAccountId = AccountId1;
                                            }
                                        }
                                        // check for gigyaId , if any
                                        if(String.isBlank(masterAccountId)){
                                            System.debug('*********check in gigyaId*********');
                                            if(AccountIdTocontactMap.containsKey(AccountId1)){
                                                if(contactDataMap.containsKey(AccountIdTocontactMap.get(AccountId1))){
                                                    System.debug('*********check in gigyaId 1 A*********'+contactDataMap.get(AccountIdTocontactMap.get(AccountId1)));
                                                    if(contactDataMap.get(AccountIdTocontactMap.get(AccountId1)).Gigya_UID__c!=null){
                                                        System.debug('*********check in gigyaId 1 B*********');
                                                        masterAccountId = AccountId1;
                                                        mergerAccountId = AccountId2; 
                                                    }
                                                    
                                                }
                                            } if(String.isBlank(masterAccountId) && AccountIdTocontactMap.containsKey(AccountId2)){
                                                if(contactDataMap.containsKey(AccountIdTocontactMap.get(AccountId2)) ){
                                                    System.debug('*********check in gigyaId 2 A*********');
                                                    if(contactDataMap.get(AccountIdTocontactMap.get(AccountId2)).Gigya_UID__c!=null){
                                                        System.debug('*********check in gigyaId 2 B*********');
                                                        masterAccountId = AccountId2;
                                                        mergerAccountId = AccountId1;
                                                    }
                                                    
                                                }
                                                
                                            }
                                        }
                                        if(String.isBlank(masterAccountId)){
                                            System.debug('***NO ASSIGNMENT**');
                                            masterAccountId = AccountId1;
                                            mergerAccountId = AccountId2;
                                        }
                                        System.debug('masterAccountId==>'+masterAccountId+'--mergerAccountId--'+mergerAccountId);
                                        //populate field in account
                                        //merege account start populate the fields START
                                        //
                                        //populate intact Id of merger Account record to Master Account Record
                                        if(accountMap_withALL_field.get(masterAccountId).get('IntacctID__c')!=''){
                                            if( accountMap_withALL_field.get(masterAccountId).get('Comments__c')!=null ){
                                               accountMap_withALL_field.get(masterAccountId).put('Comments__c',String.valueOf(accountMap_withALL_field.get(masterAccountId).get('Comments__c')) + '  \n '+' Old Reserved Intacct Id= '+String.valueOf(accountMap_withALL_field.get(masterAccountId).get('IntacctID__c'))); 
                                            }else{
                                               accountMap_withALL_field.get(masterAccountId).put('Comments__c','Old Reserved Intacct Id= '+String.valueOf(accountMap_withALL_field.get(masterAccountId).get('IntacctID__c'))+' \n ');
                                            }
                                            
                                        }
                                        System.debug('intactIdAdd '+accountMap_withALL_field.get(masterAccountId).get('Comments__c'));
                                        if(accountMap_withALL_field.get(masterAccountId).get('BillingCity') == null && accountMap_withALL_field.get(masterAccountId).get('BillingCountry') == null &&
                                           accountMap_withALL_field.get(masterAccountId).get('BillingGeocodeAccuracy') == null && accountMap_withALL_field.get(masterAccountId).get('BillingLatitude') == null &&
                                           accountMap_withALL_field.get(masterAccountId).get('BillingLongitude') == null && accountMap_withALL_field.get(masterAccountId).get('BillingPostalCode') == null &&
                                           accountMap_withALL_field.get(masterAccountId).get('BillingState') == null  && accountMap_withALL_field.get(masterAccountId).get('BillingStreet') == null){
                                               
                                               if(accountMap_withALL_field.get(mergerAccountId).get('BillingCity')!=null){
                                                   accountMap_withALL_field.get(masterAccountId).put('BillingCity',accountMap_withALL_field.get(mergerAccountId).get('BillingCity'));
                                               }
                                               if(accountMap_withALL_field.get(mergerAccountId).get('BillingCountry')!=null){
                                                   accountMap_withALL_field.get(masterAccountId).put('BillingCountry',accountMap_withALL_field.get(mergerAccountId).get('BillingCountry'));
                                               }
                                               if(accountMap_withALL_field.get(mergerAccountId).get('BillingGeocodeAccuracy')!=null){
                                                   accountMap_withALL_field.get(masterAccountId).put('BillingGeocodeAccuracy',accountMap_withALL_field.get(mergerAccountId).get('BillingGeocodeAccuracy'));
                                               }
                                               if(accountMap_withALL_field.get(mergerAccountId).get('BillingLatitude')!=null){
                                                   accountMap_withALL_field.get(masterAccountId).put('BillingLatitude',accountMap_withALL_field.get(mergerAccountId).get('BillingLatitude'));
                                               }
                                               if(accountMap_withALL_field.get(mergerAccountId).get('BillingLongitude')!=null){
                                                   accountMap_withALL_field.get(masterAccountId).put('BillingLongitude',accountMap_withALL_field.get(mergerAccountId).get('BillingLongitude'));
                                               }
                                               
                                               if(accountMap_withALL_field.get(mergerAccountId).get('BillingPostalCode')!=null){
                                                   accountMap_withALL_field.get(masterAccountId).put('BillingPostalCode',accountMap_withALL_field.get(mergerAccountId).get('BillingPostalCode'));
                                               }
                                               if(accountMap_withALL_field.get(mergerAccountId).get('BillingState')!=null){
                                                   accountMap_withALL_field.get(masterAccountId).put('BillingState',accountMap_withALL_field.get(mergerAccountId).get('BillingState'));
                                               }
                                               if(accountMap_withALL_field.get(mergerAccountId).get('BillingStreet')!=null){
                                                   accountMap_withALL_field.get(masterAccountId).put('BillingStreet',accountMap_withALL_field.get(mergerAccountId).get('BillingStreet'));
                                               }
                                               
                                           }
                                        
                                        for(Contact_Merge__mdt conMerge : AccountMergeFieldInfoList){
                                            System.debug('**merege Account fields'+conMerge);
                                            if(conMerge.Rule_Type__c.toLowerCase() == 'Default Behaviour' ){
                                                if(accountMap_withALL_field.get(masterAccountId).get(conMerge.Field_API_Name__c)==null){
                                                    if( accountMap_withALL_field.get(mergerAccountId).get(conMerge.Field_API_Name__c)!=null){
                                                        accountMap_withALL_field.get(masterAccountId).put(conMerge.Field_API_Name__c,accountMap_withALL_field.get(mergerAccountId).get(conMerge.Field_API_Name__c));
                                                    }  
                                                }
                                            }else if(conMerge.Rule_Type__c.toLowerCase() == 'Keep True'){
                                                if(accountMap_withALL_field.get(masterAccountId).get(conMerge.Field_API_Name__c) == False){
                                                    if(accountMap_withALL_field.get(mergerAccountId).get(conMerge.Field_API_Name__c) == True){
                                                        accountMap_withALL_field.get(masterAccountId).put(conMerge.Field_API_Name__c,accountMap_withALL_field.get(mergerAccountId).get(conMerge.Field_API_Name__c));
                                                    }
                                                }
                                            }else if(conMerge.Rule_Type__c.toLowerCase() == 'concatenation'){
                                                System.debug(' concate field');
                                                Schema.SObjectType objectType = Schema.getGlobalDescribe().get('Account');
                                                Schema.DescribeFieldResult dfr = objectType.getDescribe().fields.getMap().get(conMerge.Field_API_Name__c).getDescribe();
                                                if(dfr.getType() == Schema.DisplayType.TEXTAREA || dfr.getType() == Schema.DisplayType.STRING ){
                                                    System.debug('confirm field type'+dfr.getType());
                                                    Integer HH_field_length = 0;
                                                    Integer total_field_length = dfr.getLength();
                                                    if(accountMap_withALL_field.get(masterAccountId).get(conMerge.Field_API_Name__c)!=null && 
                                                       accountMap_withALL_field.get(masterAccountId).get(conMerge.Field_API_Name__c)!=''){
                                                           //String fieldValue = contactDataMap1.get(HH_contactID).get(conMerge.Field_API_Name__c);
                                                           HH_field_length = String.valueOf(accountMap_withALL_field.get(masterAccountId).get(conMerge.Field_API_Name__c)).length();
                                                       }
                                                    
                                                    //get value from US contact
                                                    if(total_field_length - HH_field_length != 0){
                                                        if(accountMap_withALL_field.get(mergerAccountId).get(conMerge.Field_API_Name__c) !=null){
                                                            if(HH_field_length !=0){
                                                                accountMap_withALL_field.get(masterAccountId).put(conMerge.Field_API_Name__c,String.valueOf(accountMap_withALL_field.get(masterAccountId).get(conMerge.Field_API_Name__c))+' '+String.valueOf(accountMap_withALL_field.get(mergerAccountId).get(conMerge.Field_API_Name__c)).mid(0,total_field_length - (HH_field_length+1)));
                                                            }else{
                                                                System.debug('***null***************'+conMerge.Field_API_Name__c);
                                                                accountMap_withALL_field.get(masterAccountId).put(conMerge.Field_API_Name__c,String.valueOf(accountMap_withALL_field.get(mergerAccountId).get(conMerge.Field_API_Name__c)));
                                                                
                                                            }
                                                        }
                                                        
                                                        System.debug(conMerge.Field_API_Name__c+' conMerge.Field_API_Name__c  ==>'+accountMap_withALL_field.get(masterAccountId).get(conMerge.Field_API_Name__c));
                                                    }
                                                }
                                            }
                                            
                                            
                                        }
                                        
                                        System.debug('accountMap_withALL_field.get(masterAccountId)=>'+accountMap_withALL_field.get(masterAccountId));
                                        for(Contact_Merge__mdt fieldVal : AccountMergeFieldInfoList){
                                            System.debug('fieldVal='+fieldVal.Field_API_Name__c+' ==> '+accountMap_withALL_field.get(masterAccountId).get(fieldVal.Field_API_Name__c));  
                                        }
                                        System.debug('fieldVal= BillingCity ==> '+accountMap_withALL_field.get(masterAccountId).get('BillingCity')); 
                                        System.debug('fieldVal= BillingCountry ==> '+accountMap_withALL_field.get(masterAccountId).get('BillingCountry')); 
                                        System.debug('fieldVal= BillingGeocodeAccuracy ==> '+accountMap_withALL_field.get(masterAccountId).get('BillingGeocodeAccuracy')); 
                                        System.debug('fieldVal= BillingLatitude ==> '+accountMap_withALL_field.get(masterAccountId).get('BillingLatitude')); 
                                        System.debug('fieldVal= BillingLongitude ==> '+accountMap_withALL_field.get(masterAccountId).get('BillingLongitude')); 
                                        System.debug('fieldVal= BillingPostalCode ==> '+accountMap_withALL_field.get(masterAccountId).get('BillingPostalCode')); 
                                        System.debug('fieldVal= BillingState ==> '+accountMap_withALL_field.get(masterAccountId).get('BillingState')); 
                                        System.debug('fieldVal= BillingStreet ==> '+accountMap_withALL_field.get(masterAccountId).get('BillingStreet')); 
                                       
                                        
                                        //merege account start populate the fields END
                                        if(isMergeRecord){
                                            System.debug('**do not merge Account Records');
                                            Merge accountMap_withALL_field.get(masterAccountId)  mergerAccountId;  
                                        }else{
                                            System.debug('**do not merge Account Records');
                                            Account ac1 = new Account();
                                            ac1.Id = masterAccountId;
                                            ac1.Record_Value__c = 'Master';
                                            
                                            Account ac2 = new Account();
                                            ac2.Id = mergerAccountId;
                                            ac2.Record_Value__c = 'Merger';
                                            
                                            accountToBeMarked.add(ac1);
                                            accountToBeMarked.add(ac2);
                                        }
                                        
                                        
                                    }
                                    else{ //  both Contact belongs to Same Account
                                        
                                    }
                                    String masterContactId,mergerContactId;
                                    for(DuplicateRecordItem DP_SetItem : DP_Set.DuplicateRecordItems){
                                        
                                        if(countOfAccId_with_DupSet == 2){// both contact having different Account
                                            //decide master contact based upon the Master Account
                                            if(contactDataMap.containsKey(DP_SetItem.recordId) && contactDataMap.get(DP_SetItem.recordId).AccountId == masterAccountId){
                                                masterContactId = DP_SetItem.recordId;
                                            }else if(contactDataMap.containsKey(DP_SetItem.recordId) && contactDataMap.get(DP_SetItem.recordId).AccountId == mergerAccountId){
                                                mergerContactId = DP_SetItem.recordId;
                                            }
                                        }
                                    }
                                    if(countOfAccId_with_DupSet !=2){// both contact having Same Account
                                        //decide master contact based upon the Master Account
                                        masterContactId = DP_Set.DuplicateRecordItems[0].recordId;
                                        mergerContactId = DP_Set.DuplicateRecordItems[1].recordId;
                                        
                                    }
                                    if(String.isNotBlank(masterContactId) && String.isNotBlank(mergerContactId)){
                                        if(isMergeRecord){
                                            System.debug('******Mereging records***********');
                                            if(contact_MAP_WIthALLField.containsKey(masterContactId) && contact_MAP_WIthALLField.containsKey(mergerContactId)){
                                                // get Other Addrss for US contact if HH contact having no mailing Address
                                                if(contact_MAP_WIthALLField.get(masterContactId).get('MailingStreet') == null && contact_MAP_WIthALLField.get(masterContactId).get('MailingCity') == null &&
                                                   contact_MAP_WIthALLField.get(masterContactId).get('MailingState') == null && contact_MAP_WIthALLField.get(masterContactId).get('MailingPostalCode') == null &&
                                                   contact_MAP_WIthALLField.get(masterContactId).get('MailingCountry') == null ){
                                                       
                                                       if(contact_MAP_WIthALLField.get(mergerContactId).get('OtherStreet')!=null){
                                                           contact_MAP_WIthALLField.get(masterContactId).put('MailingStreet',contact_MAP_WIthALLField.get(mergerContactId).get('OtherStreet'));
                                                       }
                                                       if(contact_MAP_WIthALLField.get(mergerContactId).get('OtherCity')!=null){
                                                           contact_MAP_WIthALLField.get(masterContactId).put('MailingCity',contact_MAP_WIthALLField.get(mergerContactId).get('OtherCity'));
                                                       }
                                                       if(contact_MAP_WIthALLField.get(mergerContactId).get('OtherState')!=null){
                                                           contact_MAP_WIthALLField.get(masterContactId).put('MailingState',contact_MAP_WIthALLField.get(mergerContactId).get('OtherState'));
                                                       }
                                                       if(contact_MAP_WIthALLField.get(mergerContactId).get('OtherPostalCode')!=null){
                                                           contact_MAP_WIthALLField.get(masterContactId).put('MailingPostalCode',contact_MAP_WIthALLField.get(mergerContactId).get('OtherPostalCode'));
                                                       }
                                                       if(contact_MAP_WIthALLField.get(mergerContactId).get('OtherCountry')!=null){
                                                           contact_MAP_WIthALLField.get(masterContactId).put('MailingCountry',contact_MAP_WIthALLField.get(mergerContactId).get('OtherCountry'));
                                                       }
                                                       
                                                   }
                                                // iterate over fields added in metadata
                                                for(Contact_Merge__mdt conMerge : contactMergeFieldInfoList){
                                                    
                                                   // if(field_ruleTypeMap.containsKey(conMerge.Field_API_Name__c.toLowerCase())){
                                                        if(conMerge.Rule_Type__c.toLowerCase() == 'Default Behaviour' ){
                                                            if(contact_MAP_WIthALLField.get(masterContactId).get(conMerge.Field_API_Name__c)==null){
                                                                if( contact_MAP_WIthALLField.get(mergerContactId).get(conMerge.Field_API_Name__c)!=null){
                                                                    contact_MAP_WIthALLField.get(masterContactId).put(conMerge.Field_API_Name__c,contact_MAP_WIthALLField.get(mergerContactId).get(conMerge.Field_API_Name__c));
                                                                }  
                                                            }
                                                        }else if(conMerge.Rule_Type__c.toLowerCase() == 'Keep True'){
                                                            if(contact_MAP_WIthALLField.get(masterContactId).get(conMerge.Field_API_Name__c) == False){
                                                                if(contact_MAP_WIthALLField.get(mergerContactId).get(conMerge.Field_API_Name__c) == True){
                                                                    contact_MAP_WIthALLField.get(masterContactId).put(conMerge.Field_API_Name__c,contact_MAP_WIthALLField.get(mergerContactId).get(conMerge.Field_API_Name__c));
                                                                }
                                                            }
                                                        }else if(conMerge.Rule_Type__c.toLowerCase() == 'concatenation'){
                                                            Schema.SObjectType objectType = Schema.getGlobalDescribe().get('Contact');
                                                            Schema.DescribeFieldResult dfr = objectType.getDescribe().fields.getMap().get(conMerge.Field_API_Name__c).getDescribe();
                                                            if(dfr.getType() == Schema.DisplayType.TEXTAREA || dfr.getType() == Schema.DisplayType.STRING ){
                                                                Integer HH_field_length = 0;
                                                                Integer total_field_length = dfr.getLength();
                                                                if(contact_MAP_WIthALLField.get(masterContactId).get(conMerge.Field_API_Name__c)!=null && 
                                                                   contact_MAP_WIthALLField.get(masterContactId).get(conMerge.Field_API_Name__c)!=''){
                                                                       //String fieldValue = contactDataMap1.get(HH_contactID).get(conMerge.Field_API_Name__c);
                                                                       HH_field_length = String.valueOf(contact_MAP_WIthALLField.get(masterContactId).get(conMerge.Field_API_Name__c)).length();
                                                                   }
                                                                
                                                                //get value from US contact
                                                                if(total_field_length - HH_field_length != 0){
                                                                    if(contact_MAP_WIthALLField.get(mergerContactId).get(conMerge.Field_API_Name__c)!=null){
                                                                        if(HH_field_length !=0){
                                                                            contact_MAP_WIthALLField.get(masterContactId).put(conMerge.Field_API_Name__c,String.valueOf(contact_MAP_WIthALLField.get(masterContactId).get(conMerge.Field_API_Name__c))+' '+String.valueOf(contact_MAP_WIthALLField.get(mergerContactId).get(conMerge.Field_API_Name__c)).mid(0,total_field_length - (HH_field_length+1)));
                                                                        }else{
                                                                            System.debug('***null***************'+conMerge.Field_API_Name__c);
                                                                            contact_MAP_WIthALLField.get(masterContactId).put(conMerge.Field_API_Name__c,String.valueOf(contact_MAP_WIthALLField.get(mergerContactId).get(conMerge.Field_API_Name__c)));
                                                                            
                                                                        }
                                                                    }
                                                                    System.debug(conMerge.Field_API_Name__c+' conMerge.Field_API_Name__c  ==>'+contact_MAP_WIthALLField.get(masterContactId).get(conMerge.Field_API_Name__c));
                                                                }
                                                            }
                                                        }
                                                  //  }
                                                    
                                                }
                                                
                                                System.debug('HH_AWANA_ROLE==>'+ String.valueOf(contact_MAP_WIthALLField.get(masterContactId).get('Awana_Role__c')));
                                                //add awana to role new Affliation.
                                                //create the affliation records on household  Start
                                               /* if(contact_MAP_WIthALLField.containsKey(mergerContactId) && contact_MAP_WIthALLField.containsKey(masterContactId) 
                                                   && (contact_MAP_WIthALLField.get(mergerContactId).npe5__Affiliations__r ==null || 
                                                   contact_MAP_WIthALLField.get(mergerContactId).npe5__Affiliations__r.isEmpty())){
                                                       System.debug('*******creating affliation***');
                                                       npe5__Affiliation__c affiliationObj = new npe5__Affiliation__c();
                                                       affiliationObj.npe5__Organization__c = contactDataMap.get(mergerContactId).AccountId;
                                                       affiliationObj.npe5__Contact__c = masterContactId;
                                                       System.debug('Awana_Role__c value on US==>'+contact_MAP_WIthALLField.get(mergerContactId).get('Awana_Role__c'));
                                                       if(contact_MAP_WIthALLField.get(masterContactId).get('Awana_Role__c') != null &&
                                                          contact_MAP_WIthALLField.get(masterContactId).get('Awana_Role__c') !=''){
                                                              List<String> awanaRolesONUS_Contact = new List<String>();
                                                              awanaRolesONUS_Contact = String.valueOf(contact_MAP_WIthALLField.get(masterContactId).get('Awana_Role__c')).split(';');
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
                                                              if(contact_MAP_WIthALLField.get(masterContactId).get('Church_Role__c') != null &&
                                                                 contact_MAP_WIthALLField.get(masterContactId).get('Church_Role__c') !=''){
                                                                     String churchRole_HH = String.valueOf(contact_MAP_WIthALLField.get(masterContactId).get('Church_Role__c')).split(';')[0];
                                                                     if(String.isNotBlank( churchRole_HH)){
                                                                         
                                                                         if(churchValueMapping.containsKey(churchRole_HH.toLowerCase())){
                                                                             affiliationObj.Church_Role__c = churchValueMapping.get(churchRole_HH.toLowerCase());
                                                                         }
                                                                         
                                                                     }
                                                                 }
                                                              // add church role END
                                                          }
                                                       System.debug('affiliationObj=>'+affiliationObj);
                                                       affiliationList.add(affiliationObj);
                                                       
                                                   }*/
                                                
                                                
                                                
                                                //create the affliation records on household  END
                                                
                                            }
                                            	
                                            System.debug('masterContactId=>'+masterContactId+'	mergerContactId=>'+mergerContactId);
                                            System.debug('contact before merging=>'+contact_MAP_WIthALLField.get(masterContactId));
                                            // Merge Contact here
                                            Merge contact_MAP_WIthALLField.get(masterContactId)  mergerContactId; 
                                        }
                                        else{
                                            System.debug('Do not merge Contact records');
                                               contact conObj = new Contact();
                                               conObj.Id = masterContactId;
                                               conObj.Record_Value__c = 'Master';
                                               
                                               contact conObj1 = new Contact();
                                               conObj1.Id = mergerContactId;
                                               conObj1.Record_Value__c = 'Merger';
                                               
                                               contactToBeMarked.add(conObj);
                                               contactToBeMarked.add(conObj1);
                                        }
                                        
                                       
                                    }
                                    
                                    
                                }
                                
                                
                                
                            }
                            
                            
                        }
                        
                        // insert affliaiton list
                        // update contact list
                        
                        
                    }
                    if(affiliationList!=null && !affiliationList.isEmpty()){
                        System.debug('affiliationList==>'+affiliationList);
                        if(isMergeRecord){
                            System.debug('***affiliationList****');
                           // insert affiliationList; 
                        }
                        
                    }
                    if(ContactToBeMarked!=null && !ContactToBeMarked.isEmpty()){
                        System.debug('ContactToBeMarked==>'+ContactToBeMarked);
                        if(!isMergeRecord){
                            System.debug('***contactToBeMarked****');
                            update contactToBeMarked; 
                        }
                        
                    }
                    if(accountToBeMarked!=null && !accountToBeMarked.isEmpty()){
                        System.debug('accountToBeMarked==>'+accountToBeMarked);
                        if(!isMergeRecord){
                            System.debug('***accountToBeMarked****');
                            update accountToBeMarked; 
                        }
                        
                    }
                   
                }
            }
        }catch(Exception e){
            Database.rollback(sp);
            errorList = errorList + ' get exception on line number-->'+e.getLineNumber()+' error is=>'+e.getMessage()+' chunkId=>'+DuplicateRecordSetChunk[0]+' <br>';
            System.debug('get exception on line number-->'+e.getLineNumber()+' error is=>'+e.getMessage()+' trace->'+e.getStackTraceString());
        }
    }  
    
    
    global void finish(Database.BatchableContext BC) {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'Prashant@infoglen.com'};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Match Merge Batch ');
        
        mail.setHtmlBody(errorList);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    
}