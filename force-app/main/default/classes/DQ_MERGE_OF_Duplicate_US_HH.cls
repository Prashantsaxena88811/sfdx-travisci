//ID jobID = System.enqueueJob(new DQ_Count_OF_Duplicate_US_HH());
global class DQ_MERGE_OF_Duplicate_US_HH implements Database.Batchable<sObject>,Database.Stateful{
    // no related list
    Global String ParentIdVal = '0PB2C000000KykEWAS';
    Global Integer recordCount = 0;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String recordSetId = '0GK2C000000ADNy';
        String query = 'SELECT Id FROM DuplicateRecordSet where  RecordCount = 2 AND ParentId=:ParentIdVal AND ID=:recordSetId';
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
                Map<Id,Contact> contactDataMap =  new Map<Id,Contact>([Select Id,AccountId,Account.RecordTypeId,(Select Id from npe5__Affiliations__r where isAccountSame__c = true limit 1) from Contact where ID IN :contactIdSet AND AccountId!=null AND Account.RecordTypeId IN :include_recordTypeIds]);
                //Map<Id,Contact> contactDataMap1 =  new Map<Id,Contact>([Select Id from Contact where ID IN :contactIdSet AND AccountId!=null AND Account.RecordTypeId IN :include_recordTypeIds]);
                Map<Id,Contact> contactDataMap1 = new Map<Id,Contact>();
                List<Contact_Merge__mdt> contactMergeFieldInfoList = new List<Contact_Merge__mdt>();
                contactMergeFieldInfoList = [Select Id,Label from Contact_Merge__mdt];
                String query = 'Select Id ';
                for(Contact_Merge__mdt conMerge : contactMergeFieldInfoList){
                    query= query+','+conMerge.Label;
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
                            
                            if(contactDataMap.get(US_contactID).npe5__Affiliations__r ==null || 
                               contactDataMap.get(US_contactID).npe5__Affiliations__r.isEmpty()){
                                   npe5__Affiliation__c affiliationObj = new npe5__Affiliation__c();
                                   affiliationObj.npe5__Organization__c = contactDataMap.get(US_contactID).AccountId;
                                   affiliationObj.npe5__Contact__c = HH_contactID;
                                   affiliationList.add(affiliationObj);
                               }
                            if(contactDataMap1.containsKey(US_contactID) && contactDataMap1.containsKey(HH_contactID)){
                                for(Contact_Merge__mdt conMerge : contactMergeFieldInfoList){
                                    if(contactDataMap1.get(HH_contactID).get(conMerge.Label)==null){
                                        if( contactDataMap1.get(US_contactID).get(conMerge.Label)!=null){
                                            contactDataMap1.get(HH_contactID).put(conMerge.Label,contactDataMap1.get(US_contactID).get(conMerge.Label));
                                        }  
                                    }
                                    
                                }  
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