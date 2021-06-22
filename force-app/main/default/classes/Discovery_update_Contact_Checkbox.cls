global class Discovery_update_Contact_Checkbox implements Database.Batchable<sObject>,Database.Stateful{
    // no related list

    // 
    global Database.QueryLocator start(Database.BatchableContext BC) {
       String query = 'SELECT Id,Dup_Record__c from Contact where Dup_Record__c  =  TRUE';
	   return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> contactListChunk) {
        for(Contact con:contactListChunk ){
            con.Dup_Record__c =  false;
            
        }
        update contactListChunk;
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    public class DataWrp{
        //public TEST_OBJ__c testObj;
        public boolean isListPresent;
    }
}