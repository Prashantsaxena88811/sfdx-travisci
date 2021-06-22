global  class DQ_Check_All_Contact_purged_houseHold implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String accounthouseholdId_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='HH_Account'].Id;
        //String usOrganization_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='US_Organization'].Id;
        Date purgeBeforeDate = Date.newInstance(2020, 10, 1);
        Set<String> exclude_recordTypeIds =  new set<String>{accounthouseholdId_TypeId};
            String query = 'SELECT Id,Name,AccountId,Account.RecordType.Name FROM contact where  createddate<:purgeBeforeDate AND Account.recordTypeId IN :exclude_recordTypeIds and AccountID!=null AND pi__campaign__c = NUll AND To_be_deleted__c = true';
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext bc, List<Contact> contactChunk){
        Set<Id> accountIds =  new Set<Id>();
        for(contact conObj : contactChunk){
            accountIds.add(conObj.AccountId);
        }
        List<Account> accountList = new List<Account>();
        accountList = [Select Id,All_Contact_to_be_Deleted__c,(Select Id,To_be_deleted__c from contacts where To_be_deleted__c = false limit 1) 
                       from Account where ID IN :accountIds];
        
        for(Account accountObj : accountList){
            if(accountObj.contacts.isEmpty()){
                accountObj.All_Contact_to_be_Deleted__c =  true;
            }
        }
        
        if(!accountList.isEmpty()){
         update accountList;
        }
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}