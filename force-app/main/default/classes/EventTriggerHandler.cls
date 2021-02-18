public class EventTriggerHandler {
    
    public static void createSPIFRecord(List<Event> newEventList , Map<Id,Event> oldEventMap){
        try{
            System.debug('*************EventTriggerHandler*************1');
           /* List<UserRole> userRolelistSDR = new List<UserRole>();
            List<UserRole> userRolelistAE = new List<UserRole>();
            
            // get the role Id of SDR
            userRolelistSDR = [Select Id,Name from UserRole where DeveloperName=:'SDR' limit 1];
            // get the role Id of AE (Account_Executive)
            userRolelistAE = [Select Id,Name from UserRole where DeveloperName=:'Account_Executive' limit 1];
            System.debug(userRolelistSDR[0]+'----'+userRolelistAE[0]);*/
            
            //create role Id to role Name Map
            //Map<String,UserRole> roleIDtoNameMap = New Map<String,UserRole>();
            //roleIDtoNameMap.put(userRolelistSDR[0].Id , userRolelistSDR[0] );
            //roleIDtoNameMap.put(userRolelistAE[0].Id , userRolelistAE[0] );
            
            // query the points records from custom setting
            List<SPIF_Activity_Records__c> spifActivityRecords = new List<SPIF_Activity_Records__c>();
            spifActivityRecords = [Select Id,Points__c,Activity_Name__c,Rep_Role__c  from SPIF_Activity_Records__c where Activity_Name__c = 'Set a Meeting' and Points__c!=null];
            // Create rolename to points Map
            Map<String,SPIF_Activity_Records__c> roleToPointsMap = New Map<String,SPIF_Activity_Records__c>();
            for( SPIF_Activity_Records__c activityObj : spifActivityRecords){
                roleToPointsMap.put(activityObj.Rep_Role__c,activityObj);
            }
            System.debug('roleToPointsMap==>'+roleToPointsMap);
            
            //fetch all the roles which are present in SPIF_Activity_Records__c custom Settings and Create a Map
            Map<Id,UserRole> userRoleMap =  new Map<Id,UserRole>([Select Id,Name from UserRole where Name IN : roleToPointsMap.keySet()]);
            System.debug('userRoleMap-->'+userRoleMap);
            
            // Add all the user Ids
            Set<Id> userIds = new Set<Id>();
            List<Event> filteredEventList = new List<Event>();
            Set<Id> leadIds = new set<Id>();
            Set<Id> contactIds = new set<Id>();
            Date recordDate = Date.newInstance(2021, 1, 1);
            for( Event eventObj : newEventList){
                if( eventObj.Is_SPIF_Created__c==false && eventObj.CreatedDate > recordDate){
                    if(eventObj.whoId !=null && eventObj.Meeting_Source__c != '' && eventObj.Meeting_Source__c != null && eventObj.Event_Type__c !=null &&  eventObj.Event_Type__c !=''
                       && eventObj.Subject !=null && eventObj.Subject !=''){
                           
                           if(eventObj.whoId.getsobjecttype() == Lead.sObjectType){
                               userIds.add(eventObj.OwnerId);
                               leadIds.add(eventObj.whoId);
                               filteredEventList.add(eventObj);
                           }
                       }
                }
                
            }
            System.debug('filteredEventList-========>'+filteredEventList);
            System.debug('contactIds-->'+contactIds);
            System.debug('leadIds-->'+leadIds);
            //List<User> userList = new List<User>();
            //userList = [Select Id,Name,UserRoleId from User where Id IN : userIds];
            //System.debug('userList-->'+userList);
            // Create Map to Map Id to user 
            Map<Id,User> idToUserMap = new Map<Id,User>([Select Id,Name,UserRoleId from User where  ID IN :userIds AND UserRoleId IN :userRoleMap.keySet()]);
           
            System.debug('idToUserMap-->'+idToUserMap);
            
            //System.debug('eventoIdToLeadId-->'+eventoIdToLeadId);
            //List<Lead> leadList = new List<Lead>();
            Map<Id , Lead > leadIdToTop25Map = new Map<Id , Lead >();
            if(!leadIds.isEmpty()){
                leadIdToTop25Map = new Map<Id , Lead >([Select Id,Top_25_Account__c,Title from lead where isConverted = false and  Id IN:leadIds and Top_25_Account__c!=null and  Top_25_Account__c IN :idToUserMap.keySet()]);
                system.debug('leadIdToTop25Map-->'+leadIdToTop25Map);
                
            }
            //Map<Id , Contact > contactIdToTop25Map = new Map<Id , Contact >();
            Map<String , String> contactIdToTop25InfoMap = new Map<String , String>();
            if(!contactIds.isEmpty()){
               // contactIdToTop25Map = new Map<Id , Contact >([Select Id,Top_25_Account__c from Contact where Id IN:contactIds and Top_25_Account__c!=null and Top_25_Account__c IN :idToUserMap.keySet()]);
                //system.debug('contactIdToTop25Map-->'+contactIdToTop25Map);
                List<Contact> contactList = new List<Contact>();
                contactList =[Select id,AccountId,Account.Top_25_Account__c from Contact Where Id IN :contactIds and Account.Top_25_Account__c !=null and Account.Top_25_Account__c IN : idToUserMap.keySet()];
                for(Contact conObj :contactList){
                    contactIdToTop25InfoMap.put(conObj.Id ,conObj.Account.Top_25_Account__c);
                }
                
            }
            
            
            List<SPIF__c> spifList =  new List<SPIF__c>();
            String description = '';
            Integer points = 0;
            
            EventTriggerHandler eventTriggerHandlerObj = new EventTriggerHandler();
            System.debug('filteredEventList----<>'+filteredEventList);
            Set<Id> eventIdsTobeUpdated = new Set<Id>();
            if( (contactIdToTop25InfoMap != null && !contactIdToTop25InfoMap.isEmpty()) || (leadIdToTop25Map != null && !leadIdToTop25Map.isEmpty()) ){
                String roleName = '';
                String leadTitle = '';
                for( Event eventObj : filteredEventList){
                    system.debug('eventObj-->'+eventObj);
                    SPIF__c spifObj = new SPIF__c();
                    if( eventObj.whoId !=null && idToUserMap !=null && idToUserMap.containsKey(eventObj.OwnerId) 
                       && (( leadIdToTop25Map.containsKey(eventObj.whoId) 
                            && eventObj.OwnerId == leadIdToTop25Map.get(eventObj.whoId).Top_25_Account__c) || 
                           ( contactIdToTop25InfoMap.containsKey(eventObj.whoId) 
                            && eventObj.OwnerId == contactIdToTop25InfoMap.get(eventObj.whoId)) ) ){
                                eventIdsTobeUpdated.add(eventObj.Id);
                                description = eventObj.description == null ? '' : eventObj.description ;
                                leadTitle = leadIdToTop25Map.get(eventObj.whoId).Title == null ? '' : leadIdToTop25Map.get(eventObj.whoId).Title ;
                                if( roleToPointsMap!=null && !roleToPointsMap.isEmpty() && 
                                   roleToPointsMap.containsKey( userRoleMap.get(idToUserMap.get(eventObj.OwnerId).UserRoleId).Name )){
                                       roleName = userRoleMap.get(idToUserMap.get(eventObj.OwnerId).UserRoleId).Name;
                                    points = roleToPointsMap.get(roleName ).Points__c==null ? 0 :Integer.valueOf(roleToPointsMap.get(roleName ).Points__c);
                                    spifObj = eventTriggerHandlerObj.returnSPIFRecord( eventObj.OwnerId ,points ,
                                                                                      eventObj.Subject +' | '+idToUserMap.get(eventObj.OwnerId).Name,
                                                                                      description ,URL.getSalesforceBaseUrl().toExternalForm() +'/' + eventObj.Id ,
                                                                                      eventObj.StartDateTime , true ,'' ,true , 'Set a Meeting',String.valueOf(eventObj.whoId),leadTitle);
                                    
                                }
                                if( spifObj !=new SPIF__c() && spifObj !=null){
                                    spifList.add(spifObj);   
                                }
                                
                            }
                }
                
                if( spifList!=null && !spifList.isEmpty() ){
                    insert spifList;
                    System.debug('spifList-->'+spifList);
                } 
                if( eventIdsTobeUpdated!=null && !eventIdsTobeUpdated.isEmpty() ){
                    List<Event> eventListTobeUpdated = new List<Event>();
                    eventListTobeUpdated = [Select Id,Is_SPIF_Created__c from Event where Id IN :eventIdsTobeUpdated];
                    for(Event eventVar : eventListTobeUpdated){
                        eventVar.Is_SPIF_Created__c = true;
                    }
                    if(eventListTobeUpdated!=null && !eventListTobeUpdated.isEmpty()){
                        update eventListTobeUpdated;
                    }
                }
            }
            
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber() +' error is-->'+e.getMessage());
            
        } 
        
        
        
    }
    
    public   SPIF__c returnSPIFRecord(Id ownerId , Integer points , String recName , String description , String eventLink , DateTime dateOfActivity , Boolean Top25 ,String OppId , Boolean isEvent , String SpifType,String leadId,String leadTitle )
    {
        try{
            
            System.debug('****returnSPIFRecord1***********');
            SPIF__c spifObj = new SPIF__c();
            spifObj.Date_of_activity__c = dateOfActivity;
            spifObj.Description__c = description;
            if(isEvent){
                spifObj.Event__c = eventLink;  
                System.debug('leadId-->'+leadId);
                spifObj.Lead__c = Id.valueOf(leadId);
                spifObj.Title__c = leadTitle;
            }else{
                spifObj.Opportunity__c = Id.valueOf(OppId); 
            }
            spifObj.Name = recName;
            spifObj.Points__c = points;
            spifObj.Top_25__c = Top25;
            spifObj.OwnerId = ownerId;
            spifObj.SPIF_Type__c = SpifType;
            return spifObj;   
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber() +' error is-->'+e.getMessage());
            return null;
        } 
        
        
    }
    
}