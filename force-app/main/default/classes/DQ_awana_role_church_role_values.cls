global class DQ_awana_role_church_role_values implements Database.Batchable<sObject>,Database.Stateful{
    // no related list
    Global String ParentIdVal = '0PB2C000000KykEWAS';
    Global Integer recordCount = 0;
    Global String recordSetId = '';
    global DQ_awana_role_church_role_values(String recordSetId ,string ParentIdVal){
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
                Map<Id,Contact> contactDataMap =  new Map<Id,Contact>([Select Id,AccountId,Account.RecordTypeId,(Select Id from npe5__Affiliations__r where isAccountSame__c = true limit 1) from Contact where ID IN :contactIdSet AND AccountId!=null AND Account.RecordTypeId IN :include_recordTypeIds]);
                if(contactDataMap!=null && !contactDataMap.isEmpty()){
                    List<Contact> conList = new List<Contact>();
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
                    if(conList!=null && !conList.isEmpty()){
                        update conList;
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