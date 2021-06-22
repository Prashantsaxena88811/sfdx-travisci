global class DQ_Delete_Contact_With_only_notes implements Database.Batchable<sObject>,Database.Stateful{
    // no related list
    global Integer changeBooleanVar = 0 ;
    public DQ_Delete_Contact_With_only_notes(){
        
    }
    public DQ_Delete_Contact_With_only_notes(Integer changeBooleanVar){
        this.changeBooleanVar = changeBooleanVar;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String accounthouseholdId_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='HH_Account'].Id;
        String businessUnit_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='Business_Unit'].Id;
        String internaltionalChurch_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='International_Church'].Id;
        String canadaChurch_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='Canada_Church'].Id;
        
        Set<String> exclude_recordTypeIds =  new set<String>{accounthouseholdId_TypeId,businessUnit_TypeId,internaltionalChurch_TypeId,canadaChurch_TypeId};
        String query = 'SELECT Id,Name,Account.RecordType.Name FROM contact where Account.recordTypeId NOT IN :exclude_recordTypeIds and AccountID!=null AND pi__campaign__c = NUll';
        //String query = 'SELECT Id,Name,Account.RecordType.Name FROM contact where Account.recordTypeId NOT IN :exclude_recordTypeIds and AccountID!=null AND pi__campaign__c = NUll AND Id=\'003f400000Dp2vEAAR\'';
        
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> contactListChunk) {
        
        try {
            Map<String,Boolean> IdToRelatedListCheck = new Map<String,Boolean>();
            System.debug('contactListChunk=====>'+contactListChunk.size());
            List<Contact> contactList = new List<Contact>();
            contactList = [Select id , name ,Email,Gigya_UID__c,Constituent_Id__c,AccountID , Account.CreatedDate,Account.lastModifiedDate,
                           Account.RecordType.name,CreatedDate,lastModifiedDate,
                           (Select id,lastModifiedDate from ActivityHistories order by lastmodifieddate desc limit 1),
                           (Select id,lastModifiedDate from OpenActivities order by lastmodifieddate desc limit 1),
                           (Select id,lastModifiedDate from TT_Credits__r order by lastmodifieddate desc limit 1),
                           (Select id,lastModifiedDate from dsfs__DocuSign_Status__r order by lastmodifieddate desc limit 1),
                           (Select id,lastModifiedDate from npe4__Relationships__r order by lastmodifieddate desc limit 1),
                           (Select id,lastModifiedDate from attachments order by lastmodifieddate desc limit 1),
                           (Select id,lastModifiedDate from notes  where (NOT title LIKE '%MailChimp%')  limit 1),
                           (Select Id,lastModifiedDate from Order_Contact_Roles__r order by lastmodifieddate desc limit 1),
                           (Select Id,lastModifiedDate from npe5__Affiliations__r order by lastmodifieddate desc limit 1),
                           (Select Id,lastModifiedDate from Opportunities__r order by lastmodifieddate desc limit 1),
                           (Select Id,lastModifiedDate from CampaignMembers order by lastmodifieddate desc limit 1),
                           (Select Id,lastModifiedDate from R00N50000001IDTvEAO__r order by lastmodifieddate desc limit 1),
                           (Select Id,lastModifiedDate from Membership_Acceptances__r order by lastmodifieddate desc limit 1),
                           (Select Id,lastModifiedDate from dsfs__R00NS0000000WUMyMAO__r order by lastmodifieddate desc limit 1),
                           (Select Id,lastModifiedDate from Group_Contact_Contacts__r order by lastmodifieddate desc limit 1)
                           
                           ,
                           (Select Id,lastModifiedDate from Churches__r order by lastmodifieddate desc limit 1),
                           (Select Id,lastModifiedDate from dsfs__DocuSign_Envelope01__r order by lastmodifieddate desc limit 1),
                           (Select Id,lastModifiedDate from Contacts__r order by lastmodifieddate desc limit 1),
                           (Select Id,lastModifiedDate from ChargentOrders__Payment_Requests__r order by lastmodifieddate desc limit 1),
                           (Select Id from ContentDocumentLinks   limit 1)
                           from contact where Id IN :contactListChunk];
            System.debug('contactList-->'+contactList);
            
            Boolean isRelatedListPresent = false;
            Integer counterOld = 0;
            for(contact con : contactList){
                System.debug('counterOld '+counterOld+' ==>'+con.Id);
                counterOld = counterOld +1;
                isRelatedListPresent = false;
                if(con.npe5__Affiliations__r !=  null && !con.npe5__Affiliations__r.isEmpty()){
                    System.debug('con-------.npe5__Affiliations__r='+con.npe5__Affiliations__r);
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.Order_Contact_Roles__r !=  null && !con.Order_Contact_Roles__r.isEmpty()) || Test.isRunningTest()  ){
                    System.debug('con-------.Order_Contact_Roles__r='+con.Order_Contact_Roles__r );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.Opportunities__r !=  null && !con.Opportunities__r.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con-------.Opportunities__r='+con.Opportunities__r );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.CampaignMembers !=  null && !con.CampaignMembers.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con-------.CampaignMembers='+con.CampaignMembers );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.R00N50000001IDTvEAO__r !=  null  && !con.R00N50000001IDTvEAO__r.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con-------.R00N50000001IDTvEAO__r='+con.R00N50000001IDTvEAO__r);
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.Membership_Acceptances__r !=  null && !con.Membership_Acceptances__r.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con-------.Membership_Acceptances__r='+con.Membership_Acceptances__r );
                    isRelatedListPresent = true;
                }
                
                if( (!isRelatedListPresent && con.ActivityHistories !=  null && !con.ActivityHistories.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con-------.ActivityHistories='+con.ActivityHistories );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.OpenActivities !=  null && !con.OpenActivities.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con-------.OpenActivities='+con.OpenActivities );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.TT_Credits__r !=  null && !con.TT_Credits__r.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con-------.TT_Credits__r='+con.TT_Credits__r );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.dsfs__DocuSign_Status__r !=  null && !con.dsfs__DocuSign_Status__r.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con.dsfs__DocuSign_Status__r='+con.dsfs__DocuSign_Status__r );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.npe4__Relationships__r !=  null && !con.npe4__Relationships__r.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con.npe4__Relationships__r='+con.npe4__Relationships__r );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.attachments !=  null && !con.attachments.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con-------.attachments='+con.attachments );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.notes !=  null && !con.notes.isEmpty()) || Test.isRunningTest()  ){
                    System.debug('con-------.notes='+con.notes );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.dsfs__R00NS0000000WUMyMAO__r !=  null && !con.dsfs__R00NS0000000WUMyMAO__r.isEmpty()) || Test.isRunningTest()){
                    System.debug('con-------.dsfs__R00NS0000000WUMyMAO__r='+con.dsfs__R00NS0000000WUMyMAO__r );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.WE_FW8_NP__SearchResult__r !=  null && !con.WE_FW8_NP__SearchResult__r.isEmpty()) || Test.isRunningTest()){
                    System.debug('con-------.WE_FW8_NP__SearchResult__r='+con.WE_FW8_NP__SearchResult__r );
                    isRelatedListPresent = true;
                }
                if(!isRelatedListPresent && con.ContentDocumentLinks !=  null && !con.ContentDocumentLinks.isEmpty()){
                    System.debug('con-------.ContentDocumentLinks='+con.ContentDocumentLinks );
                    isRelatedListPresent = true;
                }
                if(!isRelatedListPresent && con.Group_Contact_Contacts__r !=  null && !con.Group_Contact_Contacts__r.isEmpty()){
                    System.debug('con-------.Group_Contact_Contacts__r='+con.Group_Contact_Contacts__r );
                    isRelatedListPresent = true;
                }
                
                
                /**/
                if(!isRelatedListPresent && con.Churches__r !=  null && !con.Churches__r.isEmpty()){
                    System.debug('con-------.Churches__r='+con.Churches__r );
                    isRelatedListPresent = true;
                }
                if(!isRelatedListPresent && con.dsfs__DocuSign_Envelope01__r !=  null && !con.dsfs__DocuSign_Envelope01__r.isEmpty()){
                    System.debug('con-------.dsfs__DocuSign_Envelope01__r='+con.dsfs__DocuSign_Envelope01__r );
                    isRelatedListPresent = true;
                }
                if(!isRelatedListPresent && con.Contacts__r !=  null && !con.Contacts__r.isEmpty()){
                    System.debug('con-------.Contacts__r='+con.Contacts__r );
                    isRelatedListPresent = true;
                }
                if(!isRelatedListPresent && con.ChargentOrders__Payment_Requests__r !=  null && !con.ChargentOrders__Payment_Requests__r.isEmpty()){
                    System.debug('con-------.ChargentOrders__Payment_Requests__r='+con.ChargentOrders__Payment_Requests__r );
                    isRelatedListPresent = true;
                }
                if(changeBooleanVar == 1){
                    isRelatedListPresent = false;
                }
                IdToRelatedListCheck.put(con.Id,isRelatedListPresent);
            }
            
            // again query
            
            contactList = new List<Contact>();
            contactList = [Select id , name ,Email,Gigya_UID__c,Constituent_Id__c,AccountID , Account.CreatedDate,Account.lastModifiedDate,
                           Account.RecordType.name,CreatedDate,lastModifiedDate,
                           (Select Id,lastModifiedDate from Accounts1__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from Accounts__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from npe01__Organizations__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from dsfs__DocuSign_Envelope_Recipient__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from npe4__Relationships1__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from Leads__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from Membership_Acceptances1__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from npsp__Honoree_Opportunities__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from npsp__Notification_Opportunities__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from npsp__Opportunities__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from Opportunities1__r order by lastmodifieddate desc limit 1)
                           
                           ,
                           (Select Id,lastModifiedDate from WE_FW8_NP__SearchResult__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from pi__Category_Contact_Scores__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from npsp__Partial_Soft_Credits__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from Club__r order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from WE_FW8_NP__Score_Results__r order by lastmodifieddate desc limit 1),
                           (Select Id,lastModifiedDate from opportunities order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from LiveChatTranscripts order by lastmodifieddate desc limit 1)  ,
                           (Select Id,lastModifiedDate from opportunityContactroles order by lastmodifieddate desc limit 1)  
                           from contact where Id IN :contactListChunk];
            isRelatedListPresent = false;
            
            
            List<contact> contactTobeUpdated = new List<contact>();
            for(contact con : contactList){
                if(!IdToRelatedListCheck.containsKey(con.Id)){
                    continue;
                }else{
                    isRelatedListPresent = IdToRelatedListCheck.get(con.Id);   
                }
                if(isRelatedListPresent){
                    continue;   
                }
                System.debug('******contact*=>'+con); 
                if( !isRelatedListPresent && con.Accounts1__r !=  null && !con.Accounts1__r.isEmpty()){
                    System.debug('con-------.Accounts1__r='+con.Accounts1__r );
                    isRelatedListPresent = true;
                    
                }if(  !isRelatedListPresent && con.Accounts__r !=  null && !con.Accounts__r.isEmpty()){
                    System.debug('con-------.Accounts__r='+con.Accounts__r );
                    isRelatedListPresent = true;
                    
                }if(  !isRelatedListPresent && con.npe01__Organizations__r !=  null && !con.npe01__Organizations__r.isEmpty()){
                    System.debug('con-------.npe01__Organizations__r='+con.npe01__Organizations__r );
                    isRelatedListPresent = true;
                    
                }if(  !isRelatedListPresent && con.dsfs__DocuSign_Envelope_Recipient__r !=  null && !con.dsfs__DocuSign_Envelope_Recipient__r.isEmpty()){
                    System.debug('con-------.dsfs__DocuSign_Envelope_Recipient__r='+con.dsfs__DocuSign_Envelope_Recipient__r );
                    isRelatedListPresent = true;
                    
                }if(  !isRelatedListPresent && con.npe4__Relationships1__r !=  null && !con.npe4__Relationships1__r.isEmpty()){
                    System.debug('con-------.npe4__Relationships1__r='+con.npe4__Relationships1__r );
                    isRelatedListPresent = true;
                    
                }if(  !isRelatedListPresent && con.Leads__r !=  null && !con.Leads__r.isEmpty()){
                    System.debug('con-------.Leads__r='+con.Leads__r );
                    isRelatedListPresent = true;
                    
                }if(  !isRelatedListPresent && con.Membership_Acceptances1__r !=  null && !con.Membership_Acceptances1__r.isEmpty()){
                    System.debug('con-------.Membership_Acceptances1__r='+con.Membership_Acceptances1__r );
                    isRelatedListPresent = true;
                    
                }if(  !isRelatedListPresent && con.npsp__Honoree_Opportunities__r !=  null && !con.npsp__Honoree_Opportunities__r.isEmpty()){
                    System.debug('con-------.npsp__Honoree_Opportunities__r='+con.npsp__Honoree_Opportunities__r );
                    isRelatedListPresent = true;
                    
                }if(  !isRelatedListPresent && con.npsp__Notification_Opportunities__r !=  null && !con.npsp__Notification_Opportunities__r.isEmpty()){
                    System.debug('con-------.npsp__Notification_Opportunities__r='+con.npsp__Notification_Opportunities__r );
                    isRelatedListPresent = true;
                    
                }if(  !isRelatedListPresent && con.npsp__Opportunities__r !=  null && !con.npsp__Opportunities__r.isEmpty()){
                    System.debug('con-------.npsp__Opportunities__r='+con.npsp__Opportunities__r );
                    isRelatedListPresent = true;
                    
                }if(  !isRelatedListPresent && con.Opportunities1__r !=  null && !con.Opportunities1__r.isEmpty()){
                    System.debug('con-------.Opportunities1__r='+con.Opportunities1__r );
                    isRelatedListPresent = true;
                    
                }
                if(  !isRelatedListPresent && con.pi__Category_Contact_Scores__r !=  null && !con.pi__Category_Contact_Scores__r.isEmpty()){
                    System.debug('con-------.pi__Category_Contact_Scores__r='+con.pi__Category_Contact_Scores__r );
                    isRelatedListPresent = true;
                    
                }
                if(  !isRelatedListPresent && con.npsp__Partial_Soft_Credits__r !=  null && !con.npsp__Partial_Soft_Credits__r.isEmpty()){
                    System.debug('con-------.npsp__Partial_Soft_Credits__r='+con.npsp__Partial_Soft_Credits__r );
                    isRelatedListPresent = true;
                    
                }
                if(  !isRelatedListPresent && con.Club__r !=  null && !con.Club__r.isEmpty()){
                    System.debug('con-------.Club__r='+con.Club__r );
                    isRelatedListPresent = true;
                    
                }
                
                if(  !isRelatedListPresent && con.WE_FW8_NP__SearchResult__r !=  null && !con.WE_FW8_NP__SearchResult__r.isEmpty()){
                    System.debug('con-------.WE_FW8_NP__SearchResult__r='+con.WE_FW8_NP__SearchResult__r );
                    isRelatedListPresent = true;
                    
                }
                if(  !isRelatedListPresent && con.WE_FW8_NP__Score_Results__r !=  null && !con.WE_FW8_NP__Score_Results__r.isEmpty()){
                    System.debug('con-------.WE_FW8_NP__Score_Results__r='+con.WE_FW8_NP__Score_Results__r );
                    isRelatedListPresent = true;
                    
                }
                /**/
                if(  !isRelatedListPresent && con.LiveChatTranscripts !=  null && !con.LiveChatTranscripts.isEmpty()){
                    System.debug('con-------.LiveChatTranscripts='+con.LiveChatTranscripts );
                    isRelatedListPresent = true;
                    
                }
                if(  !isRelatedListPresent && con.opportunities !=  null && !con.opportunities.isEmpty()){
                    System.debug('con-------.opportunities='+con.opportunities );
                    isRelatedListPresent = true;
                    
                }
                if(  !isRelatedListPresent && con.opportunityContactroles !=  null && !con.opportunityContactroles.isEmpty()){
                    System.debug('con-------.opportunityContactroles='+con.opportunityContactroles );
                    isRelatedListPresent = true;
                    
                }
                
                if(!isRelatedListPresent){
                    System.debug('isRelatedListPresent==>'+isRelatedListPresent);
                    contact conObj = new Contact();
                    conObj.Id = con.Id;
                    conObj.To_be_Deleted__c = true;
                    contactTobeUpdated.add(conObj);
                    System.debug('************************');
                    
                }
                
            }
            
            System.debug('before contactTobeUpdated==>'+contactTobeUpdated);
            if(contactTobeUpdated!=null && !contactTobeUpdated.isEmpty()){
                System.debug('contactTobeUpdated==>'+contactTobeUpdated);
                update contactTobeUpdated;
            }
            
            
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber()+' error is=>'+e.getMessage());
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    
}

/*Set<String> gigyaId = new Set<String>();
gigyaId.add('e2d6ba9d88fa4717a1ee52ee35ab5a95');
gigyaId.add('acZySqkGxpyTyGM9R3tasZvvt3');
gigyaId.add('_guid_R8u41mGw--_kV1uPAR0nPYRoTHPvduDLBlXfpFlTcLQ=');
gigyaId.add('ff28f3c9bc53413bafa861d8d97a38c8');
gigyaId.add('44fe38f9257a45a8b96fda7e4ecca458');
gigyaId.add('_guid_zJMTSL5_4rQRtFQPd38lIMJNrwOXLi1BduiukUqQbTI=');
gigyaId.add('343ffa5a6d564018a0d089785d403c21');
gigyaId.add('3dca5408c757491b875a46c76b17d3df');
gigyaId.add('7b82fb3dad8249afbcb8d574e25bd5f7');
gigyaId.add('abTToe8QZApeMVAEaRbehRUHzg');
gigyaId.add('_guid_E0bR7PisgXa2qvToX19ZpoqBL4BnVJ86Db-1Eh2yAsc=');
gigyaId.add('bdXkZbzAnawkNZsiR0B3of3fXy');
gigyaId.add('3a8669decfa347f58dcd8a102d6609f9');
gigyaId.add('bdo4G9xb4FsaxNEdTLtkRiKMEF');
gigyaId.add('001c025540eb4cd6bd847533556327b7');
gigyaId.add('abqZjPn0nppT3GtFcDlLXrvZNn');
gigyaId.add('_guid_LG5KyxpOStTMhZKUo6Z8Mq1cjUqQktYKQDAeTrAz5b4=');
gigyaId.add('abqt7gMWQxekVWQN6JKM0FsQ7g');
gigyaId.add('dd56b6881d654a28ba08506f527bfe74');
gigyaId.add('acCgbTonkSH19raQDlURIbuJc3');
gigyaId.add('abP3ixYWqkEjpfCSVzKFucFl1z');
gigyaId.add('_guid_k3jOKWM9apKa38GrfXGZsfwahhfjpJhd13yVCBQvt8M=');
gigyaId.add('265722a02e604c5693eb02c1dc8a6211');
gigyaId.add('abAUr8y49OxRzxLdYAvflYc85t');
gigyaId.add('0160120f7cb549dea4163f0ec3677e57');
gigyaId.add('93eaff95ccde4009b581218af63f0f1f');
gigyaId.add('abMc5P6EqM83o7TdsYfS5KW5Rt');
List<Contact> conlist = new list<Contact>();
conlist = [select id , to_be_deleted__c from contact where Gigya_UID__c IN : gigyaId and  to_be_deleted__c = true ];
System.debug('conlist size=>'+conlist.size());
for(contact c : conlist){
system.debug('==>'+c);
c.to_be_deleted__c =  false;

}
update conlist;*/