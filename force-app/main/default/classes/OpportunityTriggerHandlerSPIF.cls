public class OpportunityTriggerHandlerSPIF {
    
    public static void creatSPIFRecord(List<Opportunity> opportunitynewList){
        
        List<UserRole> userRolelistSDR = new List<UserRole>();
        List<UserRole> userRolelistAE = new List<UserRole>();
        
        // get the role Id of SDR
        userRolelistSDR = [Select Id,Name from UserRole where Name=:'SDR' limit 1];
        // get the role Id of AE (Account_Executive)
        userRolelistAE = [Select Id,Name from UserRole where  Name=:'Account Executive' limit 1];
        System.debug(userRolelistSDR[0]+'----'+userRolelistAE[0]);
        
        // query the points records from custom setting
        List<SPIF_Activity_Records__c> spifActivityRecords = new List<SPIF_Activity_Records__c>();
        spifActivityRecords = [Select Id,Points__c,Activity_Name__c,Rep_Role__c  from SPIF_Activity_Records__c where Activity_Name__c = 'Set a Meeting'];
        // Create rolename to points Map
        Map<String,SPIF_Activity_Records__c> roleToPointsMap = New Map<String,SPIF_Activity_Records__c>();
        for( SPIF_Activity_Records__c activityObj : spifActivityRecords){
            roleToPointsMap.put(activityObj.Rep_Role__c,activityObj);
        }
        
        
        
        Set<Id> accountIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        for(Opportunity oppObj : opportunitynewList){
            accountIds.add(oppObj.AccountId);
            userIds.add(oppObj.CreatedById);
        }
        
        Map<Id, Account> accountMap = new Map<Id, Account>([Select id from Account where Id IN : accountIds]);
        Map<Id, User> userMap = new Map<Id, User>([Select id , UserRoleId from  User where Id IN : userIds]);
        // = [Select id , Top_25_Account__c from Account where Id IN : accountIds ];
        
        EventTriggerHandler eventTriggerHandlerObj = new EventTriggerHandler();
        for(Opportunity oppObj : opportunitynewList ){
            
            if( oppObj.AccountId!=null && userRolelistSDR != NULL && (!userRolelistSDR.isEmpty()) ){
                
            }
            
        }
    }
    
}