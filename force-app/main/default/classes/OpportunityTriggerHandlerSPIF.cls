public class OpportunityTriggerHandlerSPIF {
    
    public static void creatSPIFRecord(List<Opportunity> opportunitynewList){
        try{  
            /*List<UserRole> userRolelistSDR = new List<UserRole>();
            List<UserRole> userRolelistAE = new List<UserRole>();
            
            // get the role Id of SDR
            userRolelistSDR = [Select Id,Name from UserRole where Name=:'SDR' limit 1];
            // get the role Id of AE (Account_Executive)
            userRolelistAE = [Select Id,Name from UserRole where  Name=:'Account Executive' limit 1];
            System.debug(userRolelistSDR[0]+'----'+userRolelistAE[0]);*/
            
            // query the points records from custom setting
            List<SPIF_Activity_Records__c> spifActivityRecords = new List<SPIF_Activity_Records__c>();
            spifActivityRecords = [Select Id,Points__c,Activity_Name__c,Rep_Role__c  from SPIF_Activity_Records__c where Activity_Name__c = 'New Opportunity'];
            // Create rolename to points Map
            Map<String,SPIF_Activity_Records__c> roleToPointsMap = New Map<String,SPIF_Activity_Records__c>();
            for( SPIF_Activity_Records__c activityObj : spifActivityRecords){
                roleToPointsMap.put(activityObj.Rep_Role__c,activityObj);
            }
            
            Map<Id,UserRole> userRoleMap =  new Map<Id,UserRole>([Select Id,Name from UserRole where Name IN : roleToPointsMap.keySet()]);
            System.debug('userRoleMap-->'+userRoleMap);
            
            
            Set<Id> accountIds = new Set<Id>();
            Set<Id> userIds = new Set<Id>();
            for(Opportunity oppObj : opportunitynewList){
                if(oppObj.AccountId != null){
                    accountIds.add(oppObj.AccountId); 
                   // userIds.add(oppObj.CreatedById);
                }            
                
            }
            
            Map<Id, Account> accountMap = new Map<Id, Account>([Select id,Top_25_Account__c from Account where Id IN : accountIds and Top_25_Account__c !=null]);
            // Map<Id, User> userMap = new Map<Id, User>([Select id ,Name, UserRoleId from  User where Id IN : userIds AND  UserRoleId IN :userRoleMap.keySet() ]);
            System.debug('accountMap-->'+accountMap);
            userIds  = new Set<Id>();
            for(Id accIdObj : accountMap.keySet()){
                userIds.add(accountMap.get(accIdObj).Top_25_Account__c);
            }
            //System.debug('UserRoleId-->'+userRoleMap.keySet());
             System.debug('UserRoleId-val->'+userRoleMap);
            System.debug('userIds-->'+userIds);
            Map<Id, User> userMap = new Map<Id, User>([Select id ,Name, UserRoleId from  User where Id IN : userIds AND  UserRoleId IN :userRoleMap.keySet() ]);
            System.debug('userMap-->'+userMap);
            
            EventTriggerHandler eventTriggerHandlerObj = new EventTriggerHandler();
            
            
            List<SPIF__c> spifList =  new List<SPIF__c>();
            String description = '';
            Integer points = 0;
            String roleName ='';
            String roleId = '';
            for(Opportunity oppObj : opportunitynewList ){
                System.debug('obj**-->'+oppObj);
                if(oppObj.AccountId!=null && userMap!=null && accountMap.containsKey(oppObj.AccountId) &&  
                   accountMap.get(oppObj.AccountId).Top_25_Account__c!=null && userMap.containsKey(accountMap.get(oppObj.AccountId).Top_25_Account__c) &&
                   userMap.get( accountMap.get(oppObj.AccountId).Top_25_Account__c).UserRoleId!=null
                   &&  userRoleMap.containsKey( userMap.get( accountMap.get(oppObj.AccountId).Top_25_Account__c).UserRoleId ) ){
                       SPIF__c spifObj = new SPIF__c();
                       //roleName = userRoleMap.get(userMap.get(oppObj.CreatedById).UserRoleId).Name;
                       roleName = userRoleMap.get( userMap.get(accountMap.get(oppObj.AccountId).Top_25_Account__c).UserRoleId ).Name;
                       description = oppObj.description == null ? '' : oppObj.description ;
                       
                       if(  roleToPointsMap!=null && roleToPointsMap.containsKey(roleName) ){
                           System.debug('oppObj.AccountId-->'+oppObj.AccountId);
                           System.debug('accountMap.get(oppObj.AccountId)-->'+accountMap.get(oppObj.AccountId));
                           System.debug('>>>>>>>>>->'+userMap.get(accountMap.get(oppObj.AccountId).Top_25_Account__c));
                           
                           points = roleToPointsMap.get(roleName).Points__c==null ? 0 :Integer.valueOf(roleToPointsMap.get(roleName).Points__c);
                           spifObj = eventTriggerHandlerObj.returnSPIFRecord( String.valueOf(accountMap.get(oppObj.AccountId).Top_25_Account__c) ,points ,
                                                                             oppObj.Name +' | '+userMap.get(accountMap.get(oppObj.AccountId).Top_25_Account__c).Name,
                                                                             description ,'' ,
                                                                             oppObj.CreatedDate , true ,oppObj.Id ,false );
                       } 
                      /* else if( userRolelistAE != NULL && (!userRolelistAE.isEmpty()) && userMap.get(oppObj.CreatedById).UserRoleId == userRolelistAE[0].Id ){
                           points = roleToPointsMap.get('Account Executive').Points__c==null ? 0 :Integer.valueOf(roleToPointsMap.get('Account Executive').Points__c);
                           spifObj = eventTriggerHandlerObj.returnSPIFRecord( String.valueOf(accountMap.get(oppObj.AccountId).Top_25_Account__c) ,points ,
                                                                             oppObj.Name +' | '+userMap.get(oppObj.CreatedById).Name,
                                                                             description ,'' ,
                                                                             oppObj.CreatedDate , true ,oppObj.Id ,false ); 
                       }*/
                       
                       if( spifObj !=new SPIF__c() && spifObj !=null){
                           if( accountMap.get(oppObj.AccountId).Top_25_Account__c != oppObj.CreatedById){
                               //spifObj.Top_25__c = false;
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