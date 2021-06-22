global class DQ_Delete_Invocies implements Database.Batchable<sObject>,Database.Stateful{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date purgeBeforeDate = Date.newInstance(2020, 1, 1);
        String query = 'SELECT Id,State__c,createddate FROM Sales_Invoice__c where State__c = \'Closed\' AND createddate<:purgeBeforeDate ';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Sales_Invoice__c> salesInvoiceList) {
        System.debug('salesInvoiceList==>'+salesInvoiceList); 
        
        //if(false || Test.isRunningTest()){
        delete  salesInvoiceList;
        //}
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}