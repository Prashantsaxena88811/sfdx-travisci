global  class DQ_GetContactInfo_Dup_Email_Batch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id,Email,DUP_EMAIL__C FROM Contact where Email!=null AND DUP_EMAIL__C=false ';
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext bc, List<Contact> contactChunk){
        Set<String> emailSet = new Set<String>();
        for(Contact con :contactChunk){
             emailSet.add(con.Email);
        }
        AggregateResult[] countByEmailList = [select count(id),email from contact where EMAIL IN :emailSet AND DUP_EMAIL__C=false group by email  having count(id)>1 ]; 
        emailSet = new Set<String>();
        for(AggregateResult ag:countByEmailList){
            emailSet.add(String.valueOf(ag.get('Email')));
        }
        if(!emailSet.isEmpty()){
            //System.debug('=total Count==>'+[Select count(Id) from Contact where Email IN :emailSet]);
            
            List<Contact> contactList = new List<Contact>();
            contactList = [Select Id,DUP_EMAIL__C from Contact where EMAIL IN :emailSet];   
            
            for(Contact con :contactList ){
                con.DUP_EMAIL__C = true;
            }
            if(contactList!=null && !contactList.isEmpty()){
                update contactList;
            }
            
            
        }
        
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}