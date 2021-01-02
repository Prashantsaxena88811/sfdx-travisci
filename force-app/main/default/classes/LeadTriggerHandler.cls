public class LeadTriggerHandler {
    
    public Static void leadRoundRobin(List<Lead> newLeadList , Map<Id,Lead> oldLeadMap){
        try{
            
            Lead_Round_Robin__c checkGeography = Lead_Round_Robin__c.getOrgDefaults();
            System.debug('checkGeography-'+checkGeography);
            
            /*AE round robin start*/
            List<Lead_AE_Owner_Round_Robin__c> lead_AE_OwnerList = new List<Lead_AE_Owner_Round_Robin__c>();
            lead_AE_OwnerList = [Select Geography__c,UserName__c,Lead_Assigned_DateTime__c,Segment__c from Lead_AE_Owner_Round_Robin__c];
            System.debug('lead_AE_OwnerList-->'+lead_AE_OwnerList);
            
            List<AE_OwnerCustomsorting>  AE_OwnerCustomsortingList = new List<AE_OwnerCustomsorting>();
            for( Lead_AE_Owner_Round_Robin__c userObj1 : lead_AE_OwnerList){
                AE_OwnerCustomsortingList.add(new AE_OwnerCustomsorting( userObj1 ));
            }
            System.debug('AE_OwnerCustomsortingList-->'+AE_OwnerCustomsortingList);
            AE_OwnerCustomsortingList.sort();
            System.debug('AFTER Sorting AE_OwnerCustomsortingList-->'+AE_OwnerCustomsortingList);
            
            // create map of String[segment] , List<Sorted-Lead_AE_ROUND_ROBIN>
            Map<String , List<Lead_AE_Owner_Round_Robin__c> > SegmentToListOfUsersMap = new Map<String , List<Lead_AE_Owner_Round_Robin__c> >();
            // create map for Counter
            Map<String,Integer> CounterMap = new Map<String,Integer>();
            Set<String> usernames = New Set<String>();
            
            
            // Map GeoGraphy=>username for AE Owner
            Map<String,String> GeographyToUserNames = new Map<String,String>();
            
            if(!checkGeography.AE_Owner_Round_Robin_Geography__c){
                for(AE_OwnerCustomsorting AE_Obj : AE_OwnerCustomsortingList){
                    System.debug('**AE_Obj.userRec==>'+AE_Obj.userRec);
                    if(!SegmentToListOfUsersMap.containsKey(AE_Obj.userRec.Segment__c.toLowerCase()) ){
                        SegmentToListOfUsersMap.put(AE_Obj.userRec.Segment__c.toLowerCase() , new List<Lead_AE_Owner_Round_Robin__c>());
                    }
                    if( !CounterMap.containsKey( AE_Obj.userRec.Segment__c.toLowerCase() ) ){
                        CounterMap.put( AE_Obj.userRec.Segment__c.toLowerCase() , 0 );
                    }
                    SegmentToListOfUsersMap.get( AE_Obj.userRec.Segment__c.toLowerCase() ).add(AE_Obj.userRec);
                    usernames.add(AE_Obj.userRec.UserName__c.trim());
                }
                System.debug('SegmentToListOfUsersMap=>'+SegmentToListOfUsersMap);
                System.debug('CounterMap==>'+CounterMap); 
            }else{
                for(Lead_AE_Owner_Round_Robin__c userObj1 : lead_AE_OwnerList){
                    if( userObj1.Geography__c != null && userObj1.Geography__c != ''){
                        GeographyToUserNames.put( userObj1.Geography__c.toLowerCase(), userObj1.UserName__c );
                        usernames.add(userObj1.UserName__c.trim());
                    }
                }
            }
            
            
           
            /*AE round robin end*/
            
            // get the users from custom setting.
            List<Lead_Owner_Round_Robin__c> userList = new List<Lead_Owner_Round_Robin__c>();
            userList = [SELECT Id,UserName__c , date__c,Geography__c FROM Lead_Owner_Round_Robin__c order by date__c asc];
            System.debug('userList-->'+userList);
            // Map GeoGraphy=>username for Lead Owner
            Map<String,String> GeographyToUserNamesLeadOwner = new Map<String,String>();
            //if(cs.Lead_Owner_Round_Robin_Geography__c){
                for(Lead_Owner_Round_Robin__c userObj1 : userList){
                    if( userObj1.Geography__c != null && userObj1.Geography__c != ''){
                        GeographyToUserNamesLeadOwner.put( userObj1.Geography__c.toLowerCase(), userObj1.UserName__c );
                        usernames.add(userObj1.UserName__c.trim());
                    }
                } 
            
            
            //get the users and create a Map
            List<User> userListAE = new List<User>();
            if(usernames != null && (!usernames.isEmpty()) ){
                userListAE = [Select Id , username from User where username IN :usernames];
            }
            
            
            // create a map of username to user Id
            Map<String,String> userNameToId = new Map<String,String>();
            for( User userObj1 : userListAE){
                userNameToId.put(userObj1.username.toLowerCase() , userObj1.Id ); 
            }
            
            System.debug('userNameToId-->'+userNameToId);
            // sort the userIds based upon the date.
            //get the user name from custom label
            String username = Label.LeadRoundRobin; 
            User userObj = [Select Id from user where Username =:username];// store username in custom label
            Integer count = 0; // for leadOwner round robin
            Integer countAE = 0 ;  // for AE OWNER round robin
            // Iteration On leads
            for(Lead leadObj : newLeadList){
                System.debug(leadObj.ownerId+'--leadObj.ownerId-->'+userObj.Id);
                
                /* Lead Owner Round Robin Starts */
                if( ( leadObj.ownerId == userObj.Id && oldLeadMap == null && leadObj.Status=='Round Robin')
                   || ( oldLeadMap != null && leadObj.Status=='Round Robin' && leadObj.ownerId == userObj.Id   && 
                       (leadObj.Status != oldLeadMap.get(leadObj.Id).Status  || leadObj.ownerId != oldLeadMap.get(leadObj.Id).ownerId )  )  ){
                           
                           if(checkGeography.Lead_Owner_Round_Robin_Geography__c){
                               if(leadObj.Geography__c !=null && GeographyToUserNamesLeadOwner.containsKey(leadObj.Geography__c.toLowerCase()) ){
                                   leadObj.ownerId = userNameToId.get( GeographyToUserNamesLeadOwner.get(leadObj.Geography__c.toLowerCase()).toLowerCase() );
                               }
                           }
                           else{
                               System.debug('ROUNDROBIN RUN');
                               System.debug('owner1-->'+userList[count].UserName__c.toLowerCase());
                               System.debug('owner2-->'+userNameToId.get(userList[count].UserName__c.toLowerCase()));
                               leadObj.ownerId = userNameToId.get(userList[count].UserName__c.toLowerCase());
                               userList[count].date__c = Datetime.now();
                               count =count +1;
                               if( count == userList.size() ){
                                   System.debug('before reseeting the value---->'+count);
                                   count =0;
                               }
                               /*leadObj.ownerId = userList[count].SetupOwnerId;
userList[count].date__c = Datetime.now();
count =count +1;
if( count == userList.size() ){
System.debug('before reseeting the value---->'+count);
count =0;
} */
                           }
                       }
                /* Lead Owner Round Robin Ends */
                
                /* Lead AE Owner Round Robin Starts */
                
                if( leadObj.User__c==null && ( leadObj.Segment__c != '' && leadObj.Segment__c!= null ) &&
                   ( oldLeadMap == null || ( oldLeadMap != null && (leadObj.User__c!=oldLeadMap.get(leadObj.Id).User__c || leadObj.Segment__c!=oldLeadMap.get(leadObj.Id).Segment__c) )  ) ){
                       
                       if(checkGeography.AE_Owner_Round_Robin_Geography__c){// checkfor GeoGraphy
                           System.debug('Round Robin Based on Geography'); //GeographyToUserNames
                           if( leadObj.Geography__c !=null && GeographyToUserNames.containsKey(leadObj.Geography__c.toLowerCase()) ){
                               leadObj.User__c = userNameToId.get( GeographyToUserNames.get(leadObj.Geography__c.toLowerCase()).toLowerCase() );
                           }
                       }
                       else {
                           System.debug('divide leads between users');
                           
                           if(  SegmentToListOfUsersMap.containsKey(leadObj.Segment__c.toLowerCase()) ){
                               countAE = CounterMap.get( leadObj.Segment__c.toLowerCase() );
                               leadObj.User__c = userNameToId.get( SegmentToListOfUsersMap.get(leadObj.Segment__c.toLowerCase())[countAE].UserName__c.toLowerCase() );
                               //update time on user records
                               SegmentToListOfUsersMap.get(leadObj.Segment__c.toLowerCase())[countAE].Lead_Assigned_DateTime__c = DateTime.now() ; 
                               countAE = countAE +1;
                               if( countAE == SegmentToListOfUsersMap.get(leadObj.Segment__c.toLowerCase()).size() ){
                                   System.debug('before Mid-Market reseeting the value---->'+count);
                                   countAE = 0;
                                   CounterMap.put( leadObj.Segment__c.toLowerCase() , countAE );
                               }
                           }
                           
                       }
                       
                   }
                
                
                
                /* Lead AE Owner Round Robin Ends */
                
            }
            // Lead Round Robin User List
            if(!userList.isEmpty()){
                update userList;
            }
            // AE Owner
            List<Lead_AE_Owner_Round_Robin__c> userListAE1 = new List<Lead_AE_Owner_Round_Robin__c>();
            if( SegmentToListOfUsersMap!=null && (!SegmentToListOfUsersMap.isEmpty()) ){
                for( String mapKey : SegmentToListOfUsersMap.keySet() ){
                    userListAE1.addAll( SegmentToListOfUsersMap.get(mapKey) );
                } 
            }
           
            if(!userListAE1.isEmpty()){
                update userListAE1;
            }
        }catch(Exception e){
            System.debug('Exception on Line number-->'+e.getMessage()+'-error is line number-->'+e.getLineNumber());
        }
        
        
    }
    
}