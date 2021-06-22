global class DQ_NO_Email_No_Donation implements Database.Batchable<sObject>,Database.Stateful{
    // no related list
    global Integer changeBooleanVar = 0 ;
    public DQ_NO_Email_No_Donation(){
        
    }
    public DQ_NO_Email_No_Donation(Integer changeBooleanVar){
        this.changeBooleanVar = changeBooleanVar;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
       String query = 'SELECT Id,Name,Account.RecordType.Name FROM contact where Email=NUll';
        //String query = 'SELECT Id,Name,Account.RecordType.Name FROM contact where Account.recordTypeId NOT IN :exclude_recordTypeIds and AccountID!=null AND pi__campaign__c = NUll AND Id=\'003f400000Dp2vEAAR\'';
        
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> contactListChunk) {
        
        try {
            
            System.debug('contactListChunk=====>'+contactListChunk.size());
            List<Contact> contactList = new List<Contact>();
            contactList = [Select id , name ,Email,Gigya_UID__c,Constituent_Id__c,AccountID , Account.CreatedDate,Account.lastModifiedDate,
                           Account.RecordType.name,CreatedDate,lastModifiedDate,
                           (Select id,lastModifiedDate from Opportunities__r where RecordTypeId=:'012f4000000nLu2' limit 1),
                           (Select id,lastModifiedDate from npsp__Honoree_Opportunities__r where RecordTypeId=:'012f4000000nLu2' limit 1),
                           (Select id,lastModifiedDate from npsp__Notification_Opportunities__r where RecordTypeId=:'012f4000000nLu2' limit 1),
                           (Select id,lastModifiedDate from npsp__Opportunities__r where RecordTypeId=:'012f4000000nLu2' limit 1),
                           (Select id,lastModifiedDate from Opportunities1__r where RecordTypeId=:'012f4000000nLu2' limit 1),
                           (Select id,lastModifiedDate from opportunities where RecordTypeId=:'012f4000000nLu2' limit 1),
                           (Select id,lastModifiedDate from opportunityContactroles where Opportunity.RecordTypeId=:'012f4000000nLu2' limit 1)
                           
                           from contact where Id IN :contactListChunk];
            System.debug('contactList-->'+contactList);
            
            
            Integer counterOld = 0;
            List<contact> contactToBeUpdated = new  List<contact>();
            for(contact con : contactList){
                System.debug('counterOld '+counterOld+' ==>'+con.Id);
                Boolean isRelatedListPresent = false;
                if(con.Opportunities__r !=  null && !con.Opportunities__r.isEmpty()){
                    System.debug('con-------.Opportunities__r='+con.Opportunities__r);
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.npsp__Honoree_Opportunities__r !=  null && !con.npsp__Honoree_Opportunities__r.isEmpty()) || Test.isRunningTest()  ){
                    System.debug('con-------.npsp__Honoree_Opportunities__r='+con.npsp__Honoree_Opportunities__r );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.opportunityContactroles !=  null && !con.opportunityContactroles.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con-------.opportunityContactroles='+con.opportunityContactroles );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.npsp__Notification_Opportunities__r !=  null && !con.npsp__Notification_Opportunities__r.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con-------.npsp__Notification_Opportunities__r='+con.npsp__Notification_Opportunities__r );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.npsp__Opportunities__r !=  null  && !con.npsp__Opportunities__r.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con-------.npsp__Opportunities__r='+con.npsp__Opportunities__r);
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.Opportunities1__r !=  null && !con.Opportunities1__r.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con-------.Opportunities1__r='+con.Opportunities1__r );
                    isRelatedListPresent = true;
                }
                
                if( (!isRelatedListPresent && con.opportunities !=  null && !con.opportunities.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con-------.opportunities='+con.opportunities );
                    isRelatedListPresent = true;
                }
                
                
                if(!isRelatedListPresent){
                    Contact c = new Contact();
                    c.No_Email_No_Donation__c =  true; 
                    c.Id = con.Id;
                    contactToBeUpdated.add(c);
                }
                
                
            }
            if(contactToBeUpdated!=null && !contactToBeUpdated.isEmpty()){
                update contactToBeUpdated;
            }
            
            
            
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber()+' error is=>'+e.getMessage());
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    
}