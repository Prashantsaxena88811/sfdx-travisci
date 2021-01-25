public class GlobalRoundRobinLogic {
    
    public static void globalRoundRobin(List<Lead> leadlist){
        System.debug('*****GlobalRoundRobinLogic***');
        System.debug('**GlobalRoundRobinLogic-leadlist-'+leadlist);
        try{ 
            /*Create Map geograpgy to user Map*/
            Map<String,List<Global_Lead_Round_Robin__c>> geoToGlobalMap =  new Map<String,List<Global_Lead_Round_Robin__c>>();
            List<Global_Lead_Round_Robin__c> globalUserList = new List<Global_Lead_Round_Robin__c>();
            globalUserList = [Select Id,Geography__c,UserName__c  from Global_Lead_Round_Robin__c where Geography__c!=null and UserName__c!=null];
            Map<String,Integer> CounterMap = new Map<String,Integer>();
            Set<String> usernames = New Set<String>();
            String mapKey;
            for( Global_Lead_Round_Robin__c globalUserObj : globalUserList){
                mapKey = globalUserObj.Geography__c;
                if(!geoToGlobalMap.containsKey(globalUserObj.Geography__c.toLowerCase()) ){
                    geoToGlobalMap.put(globalUserObj.Geography__c.toLowerCase() , new List<Global_Lead_Round_Robin__c>());
                }
                if( !CounterMap.containsKey(mapKey.toLowerCase() ) ){
                    CounterMap.put( globalUserObj.Geography__c.toLowerCase() , 0 );
                }
                geoToGlobalMap.get( globalUserObj.Geography__c.toLowerCase() ).add(globalUserObj);
                usernames.add(globalUserObj.UserName__c.trim());
            }
            System.debug('geoToGlobalMap-->'+geoToGlobalMap);
            List<User> userList = new List<User>();
            if(usernames != null && (!usernames.isEmpty()) ){
                userList = [Select Id , username from User where username IN :usernames];
            }
            
            
            // create a map of username to user Id
            Map<String,String> userNameToId = new Map<String,String>();
            for( User userObj1 : userList){
                userNameToId.put(userObj1.username.toLowerCase() , userObj1.Id ); 
            }
            System.debug('userNameToId-->'+userNameToId);
            mapKey ='';
            Integer count = 0; 
            for(Lead leadObj : leadList){
                System.debug('**GlobalRoundRobinLogic-leadObj-'+leadObj);
                mapKey = leadObj.Geography__c; 
                //leadObj.Company = leadObj.Company+'Changed';
                if( CounterMap.containsKey(mapKey.toLowerCase()) ){
                    
                    mapKey.toLowerCase();
                    System.debug('ROUNDROBIN RUN');
                    count = CounterMap.get(mapKey.toLowerCase() );
                    leadObj.OwnerId = userNameToId.get( geoToGlobalMap.get(mapKey.toLowerCase())[count].UserName__c.toLowerCase() );
                    system.debug('Id-->'+userNameToId.get( geoToGlobalMap.get(mapKey.toLowerCase())[count].UserName__c.toLowerCase() ));
                    //update time on user records
                    geoToGlobalMap.get(mapKey.toLowerCase())[count].Date__c = DateTime.now() ; 
                    count = count +1;
                    if( count == geoToGlobalMap.get(mapKey.toLowerCase()).size() ){
                        System.debug('global round robin count---->'+count);
                        count = 0;
                        CounterMap.put( mapKey.toLowerCase() , count );
                    } 
                    CounterMap.put( mapKey.toLowerCase() , count );
                    leadObj.Status = 'Assigned (SDR)';
                }
            }
            if(!globalUserList.isEmpty()){
                update globalUserList;
            }
        }catch(Exception e){
            System.debug('Exception on Line number-->'+e.getMessage()+'-error is line number-->'+e.getLineNumber());
        }
    }
    
}