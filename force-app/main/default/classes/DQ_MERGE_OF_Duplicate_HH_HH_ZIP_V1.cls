global class DQ_MERGE_OF_Duplicate_HH_HH_ZIP_V1 implements Database.Batchable<sObject>,Database.Stateful{
    // no related list
    Global String ParentIdVal = '0PB2C000000KykJWAS';
    Global Integer recordCount = 0;
    Global String recordSetId = '';
    global DQ_MERGE_OF_Duplicate_HH_HH_ZIP_V1(String recordSetId ,string ParentIdVal){
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
                List<DuplicateRecordSet> update_duplicateRecordset = new List<DuplicateRecordSet>();
                Map<Id,Contact> contactDataMap =  new Map<Id,Contact>([Select Id,AccountId,Account.RecordTypeId,(Select Id from npe5__Affiliations__r where isAccountSame__c = true limit 1) from Contact where ID IN :contactIdSet AND AccountId!=null AND Account.RecordTypeId IN :include_recordTypeIds]);
                if(contactDataMap!=null && !contactDataMap.isEmpty()){
                    for(DuplicateRecordSet DP_Set : recordSetList){
                        //Boolean isHH = false;
                        Integer count_of_HH=0;
                        String HH_contactID = '';String US_contactID = '';
                        if(!DP_Set.DuplicateRecordItems.isEmpty()){
                            for(DuplicateRecordItem DP_SetItem : DP_Set.DuplicateRecordItems){
                                if(contactDataMap.containsKey(DP_SetItem.RecordId)){
                                    if(contactDataMap.get(DP_SetItem.RecordId).Account.RecordTypeID == accounthouseholdId_TypeId){
                                        count_of_HH = count_of_HH +1;
                                        //isHH = true;
                                        //HH_contactID = DP_SetItem.RecordId;
                                    }
                                    /*else if(contactDataMap.get(DP_SetItem.RecordId).Account.RecordTypeID == US_TypeId){
                                       // isUS = true;
                                       // US_contactID = DP_SetItem.RecordId;
                                        
                                    }*/
                                    
                                }
                            }
                        }
                        if(count_of_HH == 2){
                            DuplicateRecordSet dupObj = new DuplicateRecordSet();
                            dupObj.Id = DP_Set.Id;
                            dupObj.DUP_HH_with_ZIP__c =  true;
                            update_duplicateRecordset.add(dupObj);
                            
                            
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