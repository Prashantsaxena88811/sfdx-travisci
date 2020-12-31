public class LeadTriggerHandler {
    
    public Static void leadRoundRobin(List<Lead> newLeadList , Map<Id,Lead> oldLeadMap){
        try{
            
            //List<Lead_AE_Owner_Round_Robin__c> lead_AE_OwnerList_Mid_Market = new List<Lead_AE_Owner_Round_Robin__c>();
            //List<Lead_AE_Owner_Round_Robin__c> lead_AE_OwnerList_Enterprise = new List<Lead_AE_Owner_Round_Robin__c>();
            
            /*AE round robin start*/
            List<Lead_AE_Owner_Round_Robin__c> lead_AE_OwnerList = new List<Lead_AE_Owner_Round_Robin__c>();
            lead_AE_OwnerList = [Select UserName__c,Lead_Assigned_DateTime__c,Segment__c from Lead_AE_Owner_Round_Robin__c];
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
            
            List<User> userListAE = new List<User>();
            userListAE = [Select Id , username from User where username IN :usernames];
            
            // create a map of username to user Id
            Map<String,String> userNameToId = new Map<String,String>();
            for( User userObj1 : userListAE){
                userNameToId.put(userObj1.username.toLowerCase() , userObj1.Id ); 
            }
            /*AE round robin end*/
            
            // get the users from custom setting.
            List<Lead_Round_Robin__c> userList = new List<Lead_Round_Robin__c>();
            userList = [SELECT Id,SetupOwnerId , date__c FROM Lead_Round_Robin__c order by date__c asc];
            System.debug('userList-->'+userList);
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
                           
                           System.debug('ROUNDROBIN RUN');
                           leadObj.ownerId = userList[count].SetupOwnerId;
                           userList[count].date__c = Datetime.now();
                           count =count +1;
                           if( count == userList.size() ){
                               System.debug('before reseeting the value---->'+count);
                               count =0;
                           }
                           
                       }
                /* Lead Owner Round Robin Ends */
                
                /* Lead AE Owner Round Robin Starts */
                Boolean b = false;
                if(b){// checkfor GeoGraphy
                    System.debug('Round Robin Based on Geography');
                }
                else {
                    System.debug('divide leads between users');
                    if( leadObj.User__c==null && ( leadObj.Segment__c != '' && leadObj.Segment__c!= null ) &&
                       ( oldLeadMap == null || ( oldLeadMap != null && (leadObj.User__c!=oldLeadMap.get(leadObj.Id).User__c || leadObj.Segment__c!=oldLeadMap.get(leadObj.Id).Segment__c) )  ) ){
                           
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
                
                /*
lead_AE_OwnerList_Mid_Market = [Select UserName__c,Lead_Assigned_DateTime__c,Segment__c from Lead_AE_Owner_Round_Robin__c where Segment__c = 'Mid-Market' order by Lead_Assigned_DateTime__c asc];
lead_AE_OwnerList_Enterprise = [Select UserName__c,Lead_Assigned_DateTime__c,Segment__c from Lead_AE_Owner_Round_Robin__c where Segment__c = 'Enterprise' order by Lead_Assigned_DateTime__c asc];

// create a set of username
Set<String> usernames = New Set<String>();
for( Lead_AE_Owner_Round_Robin__c lead_AE_Owner : lead_AE_OwnerList_Mid_Market){
usernames.add(lead_AE_Owner.UserName__c);
}
for( Lead_AE_Owner_Round_Robin__c lead_AE_Owner : lead_AE_OwnerList_Enterprise){
usernames.add(lead_AE_Owner.UserName__c);
}

List<User> userListAE = new List<User>();
userListAE = [Select Id , username from User where username IN :usernames];

// create a map of username to user Id
Map<String,String> userNameToId = new Map<String,String>();
for( User userObj1 : userListAE){
userNameToId.put(userObj1.username.toLowerCase() , userObj1.Id ); 
}

Integer Count_MidMarket = 0;
Integer Count_Enterprise = 0;
if( leadObj.User__c==null && ( leadObj.Segment__c== 'Mid-Market' || leadObj.Segment__c== 'Enterprise' ) &&
( oldLeadMap == null || ( oldLeadMap != null && (leadObj.User__c!=oldLeadMap.get(leadObj.Id).User__c || leadObj.Segment__c!=oldLeadMap.get(leadObj.Id).Segment__c) ) ) ){

if( leadObj.Segment__c == 'Mid-Market' && (!lead_AE_OwnerList_Mid_Market.isEmpty()) ){
leadObj.User__c = userNameToId.get(lead_AE_OwnerList_Mid_Market[Count_MidMarket].UserName__c.toLowerCase());
lead_AE_OwnerList_Mid_Market[Count_MidMarket].Lead_Assigned_DateTime__c = Datetime.now();
Count_MidMarket = Count_MidMarket +1;
if( Count_MidMarket == lead_AE_OwnerList_Mid_Market.size() ){
System.debug('before Mid-Market reseeting the value---->'+count);
Count_MidMarket = 0;
}
}
else if( leadObj.Segment__c == 'Enterprise' && (!lead_AE_OwnerList_Enterprise.isEmpty()) ){
leadObj.User__c = userNameToId.get(lead_AE_OwnerList_Enterprise[Count_Enterprise].UserName__c.toLowerCase());
lead_AE_OwnerList_Enterprise[Count_Enterprise].Lead_Assigned_DateTime__c = Datetime.now();
Count_Enterprise = Count_Enterprise +1;
if( Count_Enterprise == lead_AE_OwnerList_Enterprise.size() ){
System.debug('before lead_AE_OwnerList_Enterprise reseeting the value---->'+count);
Count_Enterprise = 0;
}
}

}*/
                
                /* Lead AE Owner Round Robin Ends */
                
            }
            // Lead Round Robin User List
            if(!userList.isEmpty()){
                update userList;
            }
            // AE Owner
            List<Lead_AE_Owner_Round_Robin__c> userListAE1 = new List<Lead_AE_Owner_Round_Robin__c>();
            for( String mapKey : SegmentToListOfUsersMap.keySet() ){
                userListAE1.addAll( SegmentToListOfUsersMap.get(mapKey) );
            }
            if(!userListAE1.isEmpty()){
                update userListAE1;
            }
        }catch(Exception e){
            System.debug('Exception on Line number-->'+e.getMessage()+'-error is line number-->'+e.getLineNumber());
        }
        
        
    }
    
}