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
        /*for(){
            
        }*/
        
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
        for( Event eventObj : newEventList){
            SPIF__c spifObj = new SPIF__c();
            if(eventObj.Meeting_Source__c != '' && eventObj.Meeting_Source__c != null ){
                
                if( userRolelistSDR != NULL && (!userRolelistSDR.isEmpty()) && eventObj.OwnerId ==  userRolelistSDR[0].Id)
                {
                   // spifObj = returnSPIFRecord( String.valueOf(eventObj.OwnerId) , );
                }
                
                if( userRolelistAE != NULL && (!userRolelistAE.isEmpty()) && eventObj.OwnerId ==  userRolelistAE[0].Id )
                {
                    
                }
                
            }
        }
        
        
        
    }
    
    public SPIF__c returnSPIFRecord(String ownerId , Integer points , String recName , String Description , String eventLink ,
                                 DateTime dateOfActivity , Boolean Top25 ){
                                     return null;
        
    }
    
}