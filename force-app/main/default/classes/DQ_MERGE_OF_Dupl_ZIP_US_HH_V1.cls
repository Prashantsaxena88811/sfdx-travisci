global class DQ_MERGE_OF_Dupl_ZIP_US_HH_V1 implements Database.Batchable<sObject>,Database.Stateful{
    // no related list
    Global String ParentIdVal = '0PB2C000000KykJWAS';
    Global Integer recordCount = 0;
    Global String recordSetId = '';
    global DQ_MERGE_OF_Dupl_ZIP_US_HH_V1(String recordSetId ,string ParentIdVal){
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
            query = 'SELECT Id FROM DuplicateRecordSet where  RecordCount = 2 AND ParentId=:ParentIdVal';
        }
        
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<DuplicateRecordSet> DuplicateRecordSetChunk) {
        try {
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
                List<DuplicateRecordSet> update_duplicateRecordset = new List<DuplicateRecordSet>();
                Map<Id,Contact> contactDataMap =  new Map<Id,Contact>([Select MailingPostalCode,Id,Email,AccountId,Account.RecordTypeId,(Select Id from npe5__Affiliations__r where isAccountSame__c = true limit 1) from Contact where ID IN :contactIdSet AND AccountId!=null AND Account.RecordTypeId IN :include_recordTypeIds]);
                if(contactDataMap!=null && !contactDataMap.isEmpty()){
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
                                }
                                if(contactDataMap.get(conId_1).Account.recordTypeId == US_TypeId){
                                    isUS = true;
                                }
                                if(contactDataMap.get(conId_2).Account.recordTypeId == accounthouseholdId_TypeId){
                                    isHH = true;
                                }
                                if(contactDataMap.get(conId_2).Account.recordTypeId == US_TypeId){
                                    isUS = true;
                                }
                                if(String.isNotBlank(Email1)  && 
                                   String.isNotBlank(Email2)){
                                       System.debug('email not blank');
                                       if(Email1.toLowerCase() == Email2.toLowerCase()){
                                           DuplicateRecordSet dupObj = new DuplicateRecordSet();
                                           dupObj.Id = DP_Set.Id;
                                           dupObj.DUP_US_HH_with_ZIP__c =  true;
                                           //update_duplicateRecordset.add(dupObj);
                                       }
                                       
                                   }else{
                                       if(isUS && isHH){
                                           System.debug('adding valus in list');
                                           DuplicateRecordSet dupObj = new DuplicateRecordSet();
                                           dupObj.Id = DP_Set.Id;
                                           dupObj.DUP_US_HH_with_ZIP__c =  true;
                                           update_duplicateRecordset.add(dupObj);  
                                       }
                                       
                                   }
                            }
                            
                        }
                        
                    }
                    if(!update_duplicateRecordset.isEmpty()){
                        update update_duplicateRecordset;
                    }
                }
                
            }
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber()+' error is=>'+e.getMessage()+' trace->'+e.getStackTraceString());
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
}