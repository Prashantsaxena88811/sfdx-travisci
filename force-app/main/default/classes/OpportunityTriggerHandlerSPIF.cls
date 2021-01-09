public class OpportunityTriggerHandlerSPIF {
    
    public static void creatSPIFRecord(List<Opportunity> opportunitynewList){
        try{  
            List<UserRole> userRolelistSDR = new List<UserRole>();
            List<UserRole> userRolelistAE = new List<UserRole>();
            
            // get the role Id of SDR
            userRolelistSDR = [Select Id,Name from UserRole where Name=:'SDR' limit 1];
            // get the role Id of AE (Account_Executive)
            userRolelistAE = [Select Id,Name from UserRole where  Name=:'Account Executive' limit 1];
            System.debug(userRolelistSDR[0]+'----'+userRolelistAE[0]);
            
            // query the points records from custom setting
            List<SPIF_Activity_Records__c> spifActivityRecords = new List<SPIF_Activity_Records__c>();
            spifActivityRecords = [Select Id,Points__c,Activity_Name__c,Rep_Role__c  from SPIF_Activity_Records__c where Activity_Name__c = 'New Opportunity'];
            // Create rolename to points Map
            Map<String,SPIF_Activity_Records__c> roleToPointsMap = New Map<String,SPIF_Activity_Records__c>();
            for( SPIF_Activity_Records__c activityObj : spifActivityRecords){
                roleToPointsMap.put(activityObj.Rep_Role__c,activityObj);
            }
            
            
            
            Set<Id> accountIds = new Set<Id>();
            Set<Id> userIds = new Set<Id>();
            for(Opportunity oppObj : opportunitynewList){
                if(oppObj.AccountId != null){
                    accountIds.add(oppObj.AccountId); 
                }            
                userIds.add(oppObj.CreatedById);
            }
            
            Map<Id, Account> accountMap = new Map<Id, Account>([Select id,Top_25_Account__c from Account where Id IN : accountIds and Top_25_Account__c !=null]);
            Map<Id, User> userMap = new Map<Id, User>([Select id ,Name, UserRoleId from  User where Id IN : userIds and (UserRoleId IN :userRolelistSDR OR UserRoleId IN : userRolelistAE)]);
            // = [Select id , Top_25_Account__c from Account where Id IN : accountIds ];
            
            EventTriggerHandler eventTriggerHandlerObj = new EventTriggerHandler();
            
            
            List<SPIF__c> spifList =  new List<SPIF__c>();
            String description = '';
            Integer points = 0;
            for(Opportunity oppObj : opportunitynewList ){
                if(oppObj.AccountId!=null && accountMap.containsKey(oppObj.AccountId) &&  
                   accountMap.get(oppObj.AccountId).Top_25_Account__c!=null && userMap.containsKey(oppObj.CreatedById)){
                       SPIF__c spifObj = new SPIF__c();
                       description = oppObj.description == null ? '' : oppObj.description ;
                       
                       if(  userRolelistSDR != NULL && (!userRolelistSDR.isEmpty()) && userMap.get(oppObj.CreatedById).UserRoleId == userRolelistSDR[0].Id ){
                           points = roleToPointsMap.get('SDR').Points__c==null ? 0 :Integer.valueOf(roleToPointsMap.get('SDR').Points__c);
                           spifObj = eventTriggerHandlerObj.returnSPIFRecord( String.valueOf(accountMap.get(oppObj.AccountId).Top_25_Account__c) ,points ,
                                                                             oppObj.Name +' | '+userMap.get(oppObj.CreatedById).Name,
                                                                             description ,'' ,
                                                                             oppObj.CreatedDate , true ,oppObj.Id ,false );
                       } 
                       else if( userRolelistAE != NULL && (!userRolelistAE.isEmpty()) && userMap.get(oppObj.CreatedById).UserRoleId == userRolelistAE[0].Id ){
                           points = roleToPointsMap.get('Account Executive').Points__c==null ? 0 :Integer.valueOf(roleToPointsMap.get('Account Executive').Points__c);
                           spifObj = eventTriggerHandlerObj.returnSPIFRecord( String.valueOf(accountMap.get(oppObj.AccountId).Top_25_Account__c) ,points ,
                                                                             oppObj.Name +' | '+userMap.get(oppObj.CreatedById).Name,
                                                                             description ,'' ,
                                                                             oppObj.CreatedDate , true ,oppObj.Id ,false ); 
                       }
                       
                       if( spifObj !=new SPIF__c() && spifObj !=null){
                           if( accountMap.get(oppObj.AccountId).Top_25_Account__c != oppObj.CreatedById){
                               spifObj.Top_25__c = false;
                           }
                           spifList.add(spifObj);   
                       }
                       
                       
                   } 
                
                
                
            }
            
            
            if( !spifList.isEmpty() ){
                System.debug('before insert spifList-->'+spifList);
                insert spifList;
                System.debug('spifList-->'+spifList);
            }
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber() +' error is-->'+e.getMessage());
            
        } 
    }
    
}