public class EventTriggerHandler {
    
    public static void createSPIFRecord(List<Event> newEventList){
        List<UserRole> userRolelistSDR = new List<UserRole>();
        List<UserRole> userRolelistAE = new List<UserRole>();
        
        // get the role Id of SDR
        userRolelistSDR = [Select Id,Name from UserRole where DeveloperName=:'SDR' limit 1];
        // get the role Id of AE (Account_Executive)
        userRolelistAE = [Select Id,Name from UserRole where DeveloperName=:'Account_Executive' limit 1];
        
        //create role Id to role Name Map
        Map<String,UserRole> roleIDtoNameMap = New Map<String,UserRole>();
        roleIDtoNameMap.put(userRolelistSDR[0].Id , userRolelistSDR[0] );
        roleIDtoNameMap.put(userRolelistAE[0].Id , userRolelistAE[0] );
        
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
        // Create Map to Map Id to user 
        Map<Id,User> idToUserMap = new Map<Id,User>();
        for(User userObj : userList ){
            if( (userObj.UserRoleId != null || userObj.UserRoleId != '') &&
               (userObj.UserRoleId == userRolelistSDR[0].Id || userObj.UserRoleId != userRolelistAE[0].Id) ){
                   idToUserMap.put(userObj.Id , userObj); 
               }
            
        }
        
        
        List<SPIF__c> spifList =  new List<SPIF__c>();
        String description = '';
        Integer points = 0;
        
        EventTriggerHandler eventTriggerHandlerObj = new EventTriggerHandler();
        for( Event eventObj : newEventList){
            SPIF__c spifObj = new SPIF__c();
            if(eventObj.Meeting_Source__c != '' && eventObj.Meeting_Source__c != null ){
                description = eventObj.description == null ? '' : eventObj.description ;
                
                
                if( userRolelistSDR != NULL && (!userRolelistSDR.isEmpty()) && idToUserMap.containsKey(eventObj.OwnerId))
                {
                    if( roleToPointsMap!=null && roleToPointsMap.containsKey('SDR')){
                        points = roleToPointsMap.get('SDR').Points__c==null ? 0 :Integer.valueOf(roleToPointsMap.get('SDR').Points__c);
                        spifObj = eventTriggerHandlerObj.returnSPIFRecord( String.valueOf(eventObj.OwnerId) ,points ,
                                                                          eventObj.Subject +' | '+idToUserMap.get(eventObj.OwnerId).Name,
                                                                          description ,URL.getSalesforceBaseUrl().toExternalForm() +'/' + eventObj.Id ,
                                                                          eventObj.StartDateTime , true ,'' ,true );
                        
                        
                    }
                    
                }
                
                if( userRolelistAE != NULL && (!userRolelistAE.isEmpty()) && eventObj.OwnerId ==  userRolelistAE[0].Id )
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
            
            spifObj.Points__c = points;
            spifObj.Top_25__c = Top25;
            return spifObj;   
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber() +' error is-->'+e.getMessage());
            return null;
        } 
        
        
    }
    
}