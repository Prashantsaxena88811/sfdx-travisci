global  class DQ_Brit_Check_ON_US_Contact implements Database.Batchable<sObject>{
    //DQ_Delete_Contact_V4
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String usOrganization_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='US_Organization'].Id;
        Date purgeBeforeDate = Date.newInstance(2020, 10, 1);
        Set<String> exclude_recordTypeIds =  new set<String>{usOrganization_TypeId};
            String query = 'SELECT Id,Name,AccountId,To_be_Deleted1__c,isBrit_Present__c FROM contact where  createddate<:purgeBeforeDate AND To_be_Deleted1__c = true  AND Account.recordTypeId IN :exclude_recordTypeIds and AccountID!=null AND pi__campaign__c = NUll AND Account.Registration_Level__c!=\'R1\'';
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext bc, List<Contact> contactChunk){
        Set<Id> accountIds =  new Set<Id>();
        for(contact conObj : contactChunk){
            accountIds.add(conObj.AccountId);
        }
        Map<Id, Account> accountMap = new Map<Id,Account>([Select Id,(Select Id,name  from Digital_Curriculum_Expirations__r  limit 1) 
                                                   from Account where Id IN : accountIds]);
        
        for(Contact conObj : contactChunk){
            if(accountMap.containsKey(conObj.AccountId)){
                if(accountMap.get(conObj.AccountId).Digital_Curriculum_Expirations__r!=null &&
                  !accountMap.get(conObj.AccountId).Digital_Curriculum_Expirations__r.isEmpty()){
                      conObj.isBrit_Present__c =  true;
                    
                }
                
            }
        }
        update contactChunk;
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}