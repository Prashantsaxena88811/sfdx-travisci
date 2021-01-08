public class EventTriggerHandler {
    
    public static void createSPIFRecord(List<Event> newEventList){
        try{
            System.debug('*************EventTriggerHandler*************1');
            List<UserRole> userRolelistSDR = new List<UserRole>();
            List<UserRole> userRolelistAE = new List<UserRole>();
            
            // get the role Id of SDR
            userRolelistSDR = [Select Id,Name from UserRole where DeveloperName=:'SDR' limit 1];
            // get the role Id of AE (Account_Executive)
            userRolelistAE = [Select Id,Name from UserRole where DeveloperName=:'Account_Executive' limit 1];
            System.debug(userRolelistSDR[0]+'----'+userRolelistAE[0]);
            
            //create role Id to role Name Map
            //Map<String,UserRole> roleIDtoNameMap = New Map<String,UserRole>();
            //roleIDtoNameMap.put(userRolelistSDR[0].Id , userRolelistSDR[0] );
            //roleIDtoNameMap.put(userRolelistAE[0].Id , userRolelistAE[0] );
            
            // query the points records from custom setting
            List<SPIF_Activity_Records__c> spifActivityRecords = new List<SPIF_Activity_Records__c>();
            spifActivityRecords = [Select Id,Points__c,Activity_Name__c,Rep_Role__c  from SPIF_Activity_Records__c where Activity_Name__c = 'Set a Meeting'];
            // Create rolename to points Map
            Map<String,SPIF_Activity_Records__c> roleToPointsMap = New Map<String,SPIF_Activity_Records__c>();
            for( SPIF_Activity_Records__c activityObj : spifActivityRecords){
                roleToPointsMap.put(activityObj.Rep_Role__c,activityObj);
            }
            
            // Add all the user Ids
            Set<Id> userIds = new Set<Id>();
            for( Event eventObj : newEventList){
                if(eventObj.Meeting_Source__c != '' && eventObj.Meeting_Source__c != null ){
                    userIds.add(eventObj.OwnerId);
                }
            }
            
            List<User> userList = new List<User>();
            userList = [Select Id,Name,UserRoleId from User where Id IN : userIds];
            System.debug('userList-->'+userList);
            // Create Map to Map Id to user 
            Map<Id,User> idToUserMap = new Map<Id,User>();
            for(User userObj : userList ){
                if( (userObj.UserRoleId != null || userObj.UserRoleId != '') &&
                   (userObj.UserRoleId == userRolelistSDR[0].Id || userObj.UserRoleId == userRolelistAE[0].Id) ){
                       idToUserMap.put(userObj.Id , userObj); 
                   }
                
            }
            System.debug('idToUserMap-->'+idToUserMap);
            // check for same user in lead and event
            Set<Id> leadIds = new set<Id>();
            List<Event> filteredEventList = new List<Event>();
            
            //Map<String , Map<String , String>> eventIdToeventownerToLeadId = new Map<String , Map<String , String>>();//eventId => eventAssignedToLeadTop25
            Map<String , String> eventoIdToLeadId = new Map<String , String>();
            for( Event eventObj : newEventList){
                if( idToUserMap.containsKey(eventObj.OwnerId)  && eventObj.whoId!=null && eventObj.whoId.getsobjecttype() == Lead.sObjectType){
                    leadIds.add(eventObj.whoId);
                    filteredEventList.add(eventObj);
                    eventoIdToLeadId.put(eventObj.Id , eventObj.whoId);
                    // eventIdToeventownerToLeadId.put(eventObj.Id ,eventownerToLeadId );
                    //eventownerToLeadId =  new Map<String , String>();
                }
                
            }
            System.debug('eventoIdToLeadId-->'+eventoIdToLeadId);
            List<Lead> leadList = new List<Lead>();
            Map<String , String > leadIdToTop25Map = new Map<String , String >();
            if(!leadIds.isEmpty()){
                leadList = [Select Id,Top_25_Account__c from lead where Id IN:leadIds and Top_25_Account__c!=null];
                system.debug('leadList-->'+leadList);
                
            }
            if(!leadList.isEmpty()){
                for(Lead leadObj : leadList){
                    leadIdToTop25Map.put(leadObj.Id , leadObj.Top_25_Account__c);   
                }
                
            }
            
            List<SPIF__c> spifList =  new List<SPIF__c>();
            String description = '';
            Integer points = 0;
            
            EventTriggerHandler eventTriggerHandlerObj = new EventTriggerHandler();
            if(!leadList.isEmpty()){
                for( Event eventObj : filteredEventList){
                    SPIF__c spifObj = new SPIF__c();
                    if(eventObj.Meeting_Source__c != '' && eventObj.Meeting_Source__c != null && (eventObj.OwnerId == leadIdToTop25Map.get(eventObj.whoId) ) ){
                        description = eventObj.description == null ? '' : eventObj.description ;
                        
                        
                        if( userRolelistSDR != NULL && (!userRolelistSDR.isEmpty()) && idToUserMap.containsKey(eventObj.OwnerId) && 
                           idToUserMap.get(eventObj.OwnerId).UserRoleId == userRolelistSDR[0].Id)
                        {
                            if( roleToPointsMap!=null && roleToPointsMap.containsKey('SDR')){
                                points = roleToPointsMap.get('SDR').Points__c==null ? 0 :Integer.valueOf(roleToPointsMap.get('SDR').Points__c);
                                spifObj = eventTriggerHandlerObj.returnSPIFRecord( String.valueOf(eventObj.OwnerId) ,points ,
                                                                                  eventObj.Subject +' | '+idToUserMap.get(eventObj.OwnerId).Name,
                                                                                  description ,URL.getSalesforceBaseUrl().toExternalForm() +'/' + eventObj.Id ,
                                                                                  eventObj.StartDateTime , true ,'' ,true );
                                
                                
                            }
                            
                        }
                        
                       else if( userRolelistAE != NULL && (!userRolelistAE.isEmpty()) && idToUserMap.containsKey(eventObj.OwnerId)  &&
                              idToUserMap.get(eventObj.OwnerId).UserRoleId == userRolelistAE[0].Id)
                        {
                            if( roleToPointsMap!=null && roleToPointsMap.containsKey('Account Executive')){
                                points = roleToPointsMap.get('Account Executive').Points__c==null ? 0 :Integer.valueOf(roleToPointsMap.get('Account Executive').Points__c);
                                spifObj = eventTriggerHandlerObj.returnSPIFRecord( String.valueOf(eventObj.OwnerId) ,points ,
                                                                                  eventObj.Subject +' | '+idToUserMap.get(eventObj.OwnerId).Name,
                                                                                  description ,URL.getSalesforceBaseUrl().toExternalForm() +'/' + eventObj.Id ,
                                                                                  eventObj.StartDateTime , true ,'', true );
                            }
                        }
                        if( spifObj !=new SPIF__c() && spifObj !=null){
                            spifList.add(spifObj);   
                        }
                        
                    }
                }
                
                if( !spifList.isEmpty() ){
                    insert spifList;
                    System.debug('spifList-->'+spifList);
                }  
            }
            
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber() +' error is-->'+e.getMessage());
            
        } 
        
        
        
    }
    
    public  SPIF__c returnSPIFRecord(String ownerId , Integer points , String recName , String description , String eventLink , DateTime dateOfActivity , Boolean Top25 ,String OppId , Boolean isEvent )
    {
        try{
            SPIF__c spifObj = new SPIF__c();
            spifObj.Date_of_activity__c = dateOfActivity;
            spifObj.Description__c = description;
            if(isEvent){
                spifObj.Event__c = eventLink;  
            }else{
                spifObj.Opportunity__c = OppId; 
            }
            spifObj.Name = recName;
            spifObj.Points__c = points;
            spifObj.Top_25__c = Top25;
            spifObj.OwnerId = ownerId;
            return spifObj;   
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber() +' error is-->'+e.getMessage());
            return null;
        } 
        
        
    }
    
}