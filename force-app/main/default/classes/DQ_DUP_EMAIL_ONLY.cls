global class DQ_DUP_EMAIL_ONLY implements Database.Batchable<sObject>,Database.Stateful{
    //duplicate email only
    Global String ParentIdVal = '0PB2C000000KykOWAS';
    Global Integer recordCount = 0;
    Global String recordSetId = '';
    Global Boolean isMergeRecord = false;
    global DQ_DUP_EMAIL_ONLY(String recordSetId ,string ParentIdVal,boolean isMergeRecord){
        this.recordSetId = recordSetId;
        this.isMergeRecord = isMergeRecord;
        if(ParentIdVal !='' && ParentIdVal!=null){
            this.ParentIdVal = ParentIdVal;
        }
    }
    global DQ_DUP_EMAIL_ONLY(){}
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //String recordSetId = '0GK2C000000AEka';
        String query='';
        System.debug('ParentIdVal>>>>>>>>'+ParentIdVal);
        System.debug('recordSetId>>>>>>>>'+recordSetId);
        if(Test.isRunningTest()){
            query = 'SELECT Id FROM DuplicateRecordSet where  RecordCount = 2  AND ID=:recordSetId';
            
        }else{
            query = 'SELECT Id FROM DuplicateRecordSet where  ParentId=:ParentIdVal ';
        }
        
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<DuplicateRecordSet> DuplicateRecordSetChunk) {
        try {
            List<DuplicateRecordSet> recordSetList = new List<DuplicateRecordSet>();
            
            recordSetList = [Select Id,(Select Id,RecordId from DuplicateRecordItems) from DuplicateRecordSet 
                             where ParentId=:ParentIdVal AND Id IN :DuplicateRecordSetChunk];
            System.debug('recordSetList==>'+recordSetList);
            Set<String> conIds = new Set<String>();
            for(DuplicateRecordSet dupRec : recordSetList){
                System.debug('dupRec.DuplicateRecordItems=>'+dupRec.DuplicateRecordItems);
                for(DuplicateRecordItem dupRecItems : dupRec.DuplicateRecordItems){
                    conIds.add(dupRecItems.RecordId);
                }
                
            }     
            System.debug('conIds==>'+conIds);
            List<Contact> conList = new List<Contact>();
            conList = [Select Id ,DUP_EMAIL_ONLY__c from Contact where Id IN :conIds];
            System.debug('conList==>'+conList);
            for(Contact cc:conList){
                cc.DUP_EMAIL_ONLY__c = true;
            }
            update conList;
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber()+' error is=>'+e.getMessage()+' trace->'+e.getStackTraceString());
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
}