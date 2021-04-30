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
                roleToPointsMap.put(activityObj.Rep_Role__c.toLowerCase(),activityObj);
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
            
            Map<Id, Account> accountMap = new Map<Id, Account>([Select id,Top_25_Account__c,Name,Is_SPIF_for_Opp_Created__c from Account where Id IN : accountIds 
                                                                AND Top_25_Account__c !=null AND Is_SPIF_for_Opp_Created__c = false]);
            // Map<Id, User> userMap = new Map<Id, User>([Select id ,Name, UserRoleId from  User where Id IN : userIds AND  UserRoleId IN :userRoleMap.keySet() ]);
            System.debug('accountMap-->'+accountMap);
            userIds  = new Set<Id>();
            Set<String> companyNameSet =  new Set<String>();
            for(Id accIdObj : accountMap.keySet()){
                userIds.add(accountMap.get(accIdObj).Top_25_Account__c);
                companyNameSet.add(accountMap.get(accIdObj).Name.toLowerCase());
            }
            //System.debug('UserRoleId-->'+userRoleMap.keySet());
             System.debug('UserRoleId-val->'+userRoleMap);
            System.debug('userIds-->'+userIds);
            Map<Id, User> userMap = new Map<Id, User>([Select id ,Name,UserName,UserRoleId from  User where Id IN : userIds AND  UserRoleId IN :userRoleMap.keySet() ]);
            System.debug('userMap-->'+userMap);
            Set<String> usernameSet =  new Set<String>();
            for(Id userIdObj : userMap.keySet()){
                usernameSet.add(userMap.get(userIdObj).username.toLowerCase());
            }
            
            EventTriggerHandler eventTriggerHandlerObj = new EventTriggerHandler();
            
            // SPIF record will only be created if the active for spif for spif is marked as true for that user.
            List<Top_25_Accounts__c> top25AccountList = new List<Top_25_Accounts__c>();
            top25AccountList = [Select Id ,Active_for_SPIF__c,Username__c,company__c from  Top_25_Accounts__c where company__c!=null AND Active_for_SPIF__c=true AND Username__c!=null AND Username__c IN :usernameSet AND Company__c IN : companyNameSet ];
            Map<String,String> username_TO_ID_MAP =  new Map<String,String>();
            for(user userObj : [Select Id , username from user where username IN :usernameSet]){
                username_TO_ID_MAP.put(userObj.username.toLowerCase() , String.valueOf(userObj.Id));
            }
            Set<String> usernameSet_Top =  new Set<String>();
            for(Top_25_Accounts__c topAcc : top25AccountList){
                if(username_TO_ID_MAP.containsKey(topAcc.Username__c.toLowerCase()) && username_TO_ID_MAP.get(topAcc.Username__c.toLowerCase())!=null){
                  usernameSet_Top.add(topAcc.company__c.toLowerCase()+username_TO_ID_MAP.get(topAcc.Username__c.toLowerCase()));  
                }
            }
            System.debug('usernameSet_Top=>'+usernameSet_Top);
            //Map<Id,User> active_SPFI_userMap = new Map<Id,User>([Select Id from user where username IN : usernameSet]);
            
            // end
            
            List<SPIF__c> spifList =  new List<SPIF__c>();
            String description = '';
            Integer points = 0;
            String roleName ='';
            String roleId = '';
            accountIds = new Set<Id>();
            Date recordDate = Date.newInstance(2021, 1, 1);
            for(Opportunity oppObj : opportunitynewList ){
                System.debug('obj**-->'+oppObj);
                System.debug('newkey==>'+accountMap.get(oppObj.AccountId).Name.toLowerCase()+accountMap.get(oppObj.AccountId).Top_25_Account__c);
                if(oppObj.createdDate >recordDate && oppObj.AccountId!=null && !accountIds.contains(oppObj.AccountId) && userMap!=null && accountMap.containsKey(oppObj.AccountId) &&  
                   accountMap.get(oppObj.AccountId).Top_25_Account__c!=null && 
                   usernameSet_Top.contains(accountMap.get(oppObj.AccountId).Name.toLowerCase()+accountMap.get(oppObj.AccountId).Top_25_Account__c) &&
                   userMap.containsKey(accountMap.get(oppObj.AccountId).Top_25_Account__c) &&
                   userMap.get( accountMap.get(oppObj.AccountId).Top_25_Account__c).UserRoleId!=null
                   &&  userRoleMap.containsKey( userMap.get( accountMap.get(oppObj.AccountId).Top_25_Account__c).UserRoleId ) ){
                       System.debug('*******1*****');
                       SPIF__c spifObj = new SPIF__c();
                       //roleName = userRoleMap.get(userMap.get(oppObj.CreatedById).UserRoleId).Name;
                       roleName = userRoleMap.get( userMap.get(accountMap.get(oppObj.AccountId).Top_25_Account__c).UserRoleId ).Name;
                       description = oppObj.description == null ? '' : oppObj.description ;
                       
                       if(  roleToPointsMap!=null && roleToPointsMap.containsKey(roleName.toLowerCase()) ){
                           System.debug('oppObj.AccountId-->'+oppObj.AccountId);
                           System.debug('accountMap.get(oppObj.AccountId)-->'+accountMap.get(oppObj.AccountId));
                           System.debug('>>>>>>>>>->'+userMap.get(accountMap.get(oppObj.AccountId).Top_25_Account__c));
                           
                           points = roleToPointsMap.get(roleName.toLowerCase()).Points__c==null ? 0 :Integer.valueOf(roleToPointsMap.get(roleName.toLowerCase()).Points__c);
                           System.debug('-1-> '+String.valueOf(accountMap.get(oppObj.AccountId).Top_25_Account__c));
                           System.debug('-2-> '+oppObj.Id);
                          
                          spifObj = eventTriggerHandlerObj.returnSPIFRecord( accountMap.get(oppObj.AccountId).Top_25_Account__c ,points ,
                                                                             oppObj.Name +' | '+userMap.get(accountMap.get(oppObj.AccountId).Top_25_Account__c).Name,
                                                                             description ,'' ,
                                                                             oppObj.CreatedDate , true ,String.valueOf(oppObj.Id ),false , 'New Opportunity','','');
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
                           accountIds.add(oppObj.AccountId);
                           spifList.add(spifObj);   
                       }
                       
                        
                   } 
                
                
                
            }
            
            
            if( spifList!=null && !spifList.isEmpty() ){
                System.debug('before insert spifList-->'+spifList);
                insert spifList;
                System.debug('spifList-->'+spifList);
            }
            if( accountIds!=null && !accountIds.isEmpty() ){
                System.debug('Account Ids to be updated'+accountIds);
                List<Account> accList = new List<Account>();
                accList = [Select Id,Is_SPIF_for_Opp_Created__c from Account where Id IN :accountIds];
                for(Account accountObj : accList){
                    accountObj.Is_SPIF_for_Opp_Created__c = true;
                }
                if(accList!=null && !accList.isEmpty()){
                    update accList;
                }
            }
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber() +' error is-->'+e.getMessage());
            
        } 
    }
}