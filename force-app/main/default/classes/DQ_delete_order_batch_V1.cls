global class DQ_delete_order_batch_V1  implements Database.Batchable<sObject>,Database.Stateful {
    
    // if false then order will be marked will to_be_deleted field true/false , 
    // if true record is eligible for deletion    
    global Boolean isdeleteRecord = false;
    global DQ_delete_order_batch_V1(Boolean isdeleteRecord){
        this.isdeleteRecord = isdeleteRecord;
        
    }
    global DQ_delete_order_batch_V1(){
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date purgeBeforeDate = Date.newInstance(2016, 7, 1);
        String query='';
        //query='Select Id,Chargent_Order__c from order Where createddate<:purgeBeforeDate AND To_be_deleted__c =false  AND Id=\'8011V000000PL91\'';
        query='Select Id,Chargent_Order__c from order Where Order_Created_Date__c<:purgeBeforeDate ';
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<order> OrderChunk) {
        try {
            List<ChargentOrders__ChargentOrder__c> chargentOrderList = new List<ChargentOrders__ChargentOrder__c>();
            System.debug('delete only');
            for(Order orderObj:OrderChunk){
                if(orderObj.Chargent_Order__c!=null){
                    ChargentOrders__ChargentOrder__c chargentOrderObj = new ChargentOrders__ChargentOrder__c();
                    chargentOrderObj.Id = orderObj.Chargent_Order__c;
                    chargentOrderList.add(chargentOrderObj);
                }
                
            }
            System.debug('OrderChunk=>'+OrderChunk);
            if(isdeleteRecord && OrderChunk!=null && !OrderChunk.isEmpty()){
                delete OrderChunk;  
            }
            
            if(chargentOrderList!=null && !chargentOrderList.isEmpty()){
                System.debug('chargentOrderList=>'+chargentOrderList);
                if(isdeleteRecord){
                    delete chargentOrderList;
                }
                
            }
            
            
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber()+' error is=>'+e.getMessage()+' trace->'+e.getStackTraceString());
        }
    }  
    
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}