global  class DQ_Count_contacts_On_HouseHold implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String accounthouseholdId_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='HH_Account'].Id;
        Set<String> includeRecordTypesId =  new set<String>{accounthouseholdId_TypeId};
            String query = 'SELECT Id,Name,RecordType.Name FROM Account where  Account.recordTypeId IN :includeRecordTypesId';
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext bc, List<Account> accountChunk){
        List<AggregateResult> aggregateList = [SELECT AccountId, COUNT(Id) FROM Contact where AccountId IN :accountChunk GROUP BY AccountId ];
        System.debug('aggregateList=>'+aggregateList);
        System.debug('*******************************');
        
        List<Account> accountListTo_beUpdated = new List<Account>();
        for(AggregateResult ar:aggregateList){
            Integer contactCount ;
            System.debug(ar.get('AccountId')+' ------- '+ar.get('expr0'));
            if(ar.get('AccountId') !=null){
                Account accObj = new Account();
                accObj.Id = String.valueOf(ar.get('AccountId'));
                if( ar.get('expr0') == null ){
                    System.debug('***********111111111************');
                    accObj.Total_Contact_Count__c = 0;
                }else{
                    System.debug('***********22222222222222************');
                    contactCount = Integer.valueOf(ar.get('expr0'));
                    accObj.Total_Contact_Count__c = contactCount;
                }
               accountListTo_beUpdated.add(accObj); 
            }
        }
        
        if(accountListTo_beUpdated!=null && !accountListTo_beUpdated.isEmpty()){
            System.debug('******update account******');
           update accountListTo_beUpdated;
        }
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}