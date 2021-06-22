//ID jobID = System.enqueueJob(new DQ_Count_OF_Duplicate_US_HH());
global class DQ_Count_OF_Duplicate_US_HH implements Database.Batchable<sObject>,Database.Stateful{
    // no related list
    Global String ParentIdVal = '0PB2C000000KykEWAS';
    Global Integer recordCount = 0;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM DuplicateRecordSet where  RecordCount = 2 AND ParentId=:ParentIdVal';
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<DuplicateRecordSet> DuplicateRecordSetChunk) {
        try {
            List<DuplicateRecordSet> recordSetList = new List<DuplicateRecordSet>();
            recordSetList = [Select Id,(Select Id,RecordId from DuplicateRecordItems) from DuplicateRecordSet 
                             where ParentId=:ParentIdVal AND RecordCount = 2 AND Id IN :DuplicateRecordSetChunk];
            
            String accounthouseholdId_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='HH_Account'].Id;
            String US_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='US_Organization'].Id;
            
            Set<String> include_recordTypeIds =  new set<String>();
            include_recordTypeIds.add(accounthouseholdId_TypeId);
            include_recordTypeIds.add(US_TypeId);
            
            Set<String> contactIdSet =  new Set<String>();
            //Map<String,String>
            for(DuplicateRecordSet DP_Set : recordSetList){
                if(!DP_Set.DuplicateRecordItems.isEmpty()){
                    for(DuplicateRecordItem DP_SetItem : DP_Set.DuplicateRecordItems){
                        contactIdSet.add(DP_SetItem.recordId);
                    }
                }
            }
            if(!contactIdSet.isEmpty()){
                Map<Id,Contact> contactDataMap =  new Map<Id,Contact>([Select Id,Account.RecordTypeId from Contact where ID IN :contactIdSet AND AccountId!=null AND Account.RecordTypeId IN :include_recordTypeIds]);
                if(contactDataMap!=null && !contactDataMap.isEmpty()){
                    
                    for(DuplicateRecordSet DP_Set : recordSetList){
                        Boolean isHH = false , isUS=false;
                        if(!DP_Set.DuplicateRecordItems.isEmpty()){
                            for(DuplicateRecordItem DP_SetItem : DP_Set.DuplicateRecordItems){
                                if(contactDataMap.containsKey(DP_SetItem.RecordId)){
                                    if(contactDataMap.get(DP_SetItem.RecordId).Account.RecordTypeID == accounthouseholdId_TypeId){
                                        isHH = true;
                                    }
                                    else if(contactDataMap.get(DP_SetItem.RecordId).Account.RecordTypeID == US_TypeId){
                                        isUS = true;
                                    }
                                   
                                }
                            }
                        }
                        if(isHH && isUS){
                            recordCount = recordCount +1;
                            DP_Set.Qualified__c = true;
                        }
                    }
                    
                    if(recordSetList!=null && !recordSetList.isEmpty()){
                        update recordSetList;
                    }
                    
                }
            }
            
            
            
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber()+' error is=>'+e.getMessage());
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        DQ_Count__c dq = new DQ_Count__c();
        Integer size = [Select Id from DQ_Count__c].Size()+1;
        dq.Name = 'DQ1'+size;
        dq.accountRecords__c = recordCount;
        upsert dq;
    }
}