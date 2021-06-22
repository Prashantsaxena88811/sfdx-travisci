global class DQ_delete_Contact_batch implements Database.Batchable<sObject>,Database.Stateful{
    // no related list
    global Database.QueryLocator start(Database.BatchableContext BC) {
       String query = 'SELECT Id,Name,To_be_deleted__c from contact where To_be_deleted__c =  true';
	   return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> contactListChunk) {
        
        delete contactListChunk;
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    public class DataWrp{
        //public TEST_OBJ__c testObj;
        public boolean isListPresent;
    }
}