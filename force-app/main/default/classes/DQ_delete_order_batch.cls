global class DQ_delete_order_batch  implements Database.Batchable<sObject>,Database.Stateful {
    
    // if false then order will be marked will to_be_deleted field true/false , 
    // if true record is eligible for deletion    
    global Boolean isUpdateRecordOnly = true;
    global DQ_delete_order_batch(Boolean isUpdateRecordOnly){
        this.isUpdateRecordOnly = isUpdateRecordOnly;
        
    }
    global DQ_delete_order_batch(){
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date purgeBeforeDate = Date.newInstance(2016, 6, 1);
        String query='';
        query='Select Id,Chargent_Order__c from order Where Order_Created_Date__c<:purgeBeforeDate';
        if(isUpdateRecordOnly){
            //query='Select Id,Chargent_Order__c from order Where createddate<:purgeBeforeDate AND To_be_deleted__c =false  AND Id=\'8011V000000PL91\'';
            //query='Select Id,Chargent_Order__c from order where  To_be_deleted__c =false  ';
        }else{
            //query='Select Id,Chargent_Order__c from order Where To_be_deleted__c =true ';
        }
        
        
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<order> OrderChunk) {
        try {
            if(isUpdateRecordOnly){
                System.debug('update only');
                List<Order> orderList = new List<Order>();
                orderList = [Select Id,(Select Id from Digital_Curriculum_Expirations__r limit 1) from Order where Id IN :OrderChunk];
                
                for(Order orderObj:orderList){
                    if(orderObj.Digital_Curriculum_Expirations__r.isEmpty()){
                        orderObj.To_be_deleted__c = true;
                    }
                    
                }
                if(orderList!=Null && !orderList.isEmpty()){
                    update orderList;
                }
                
            }
            else{
                List<ChargentOrders__ChargentOrder__c> chargentOrderList = new List<ChargentOrders__ChargentOrder__c>();
                System.debug('delete only');
                for(Order orderObj:OrderChunk){
                    if(orderObj.Chargent_Order__c!=null){
                        ChargentOrders__ChargentOrder__c chargentOrderObj = new ChargentOrders__ChargentOrder__c();
                        chargentOrderObj.Id = orderObj.Chargent_Order__c;
                        chargentOrderList.add(chargentOrderObj);
                    }
                    
                }
                delete OrderChunk;
                if(chargentOrderList!=null && !chargentOrderList.isEmpty()){
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