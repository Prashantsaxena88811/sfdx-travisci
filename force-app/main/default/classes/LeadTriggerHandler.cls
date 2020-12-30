public class LeadTriggerHandler {
    
    public Static void leadRoundRobin(List<Lead> newLeadList , Map<Id,Lead> oldLeadMap){
        try{
            
            List<Lead_AE_Owner_Round_Robin__c> lead_AE_OwnerList_Mid_Market = new List<Lead_AE_Owner_Round_Robin__c>();
            List<Lead_AE_Owner_Round_Robin__c> lead_AE_OwnerList_Enterprise = new List<Lead_AE_Owner_Round_Robin__c>();
            
            // get the users from custom setting.
            List<Lead_Round_Robin__c> userList = new List<Lead_Round_Robin__c>();
            userList = [SELECT Id,SetupOwnerId , date__c FROM Lead_Round_Robin__c order by date__c asc];
            System.debug('userList-->'+userList);
            // sort the userIds based upon the date.
            //get the user name from custom label
            String username = Label.LeadRoundRobin; 
            User userObj = [Select Id from user where Username =:username];// store username in custom label
            Integer count = 0;
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
                    userNameToId.put(userObj1.username , userObj1.Id ); 
                }
                
                Integer Count_MidMarket = 0;
                Integer Count_Enterprise = 0;
                if( leadObj.User__c==null && ( leadObj.Segment__c== 'Mid-Market' || leadObj.Segment__c== 'Enterprise' ) &&
                   ( oldLeadMap == null || ( oldLeadMap != null && (leadObj.User__c!=oldLeadMap.get(leadObj.Id).User__c || leadObj.Segment__c!=oldLeadMap.get(leadObj.Id).Segment__c) ) ) ){
                       
                       if( leadObj.Segment__c == 'Mid-Market' && (!lead_AE_OwnerList_Mid_Market.isEmpty()) ){
                           leadObj.User__c = userNameToId.get(lead_AE_OwnerList_Mid_Market[Count_MidMarket].UserName__c);
                           lead_AE_OwnerList_Mid_Market[Count_MidMarket].Lead_Assigned_DateTime__c = Datetime.now();
                           Count_MidMarket = Count_MidMarket +1;
                           if( Count_MidMarket == lead_AE_OwnerList_Mid_Market.size() ){
                               System.debug('before Mid-Market reseeting the value---->'+count);
                               Count_MidMarket = 0;
                           }
                       }
                       else if( leadObj.Segment__c == 'Enterprise' && (!lead_AE_OwnerList_Enterprise.isEmpty()) ){
                           leadObj.User__c = userNameToId.get(lead_AE_OwnerList_Enterprise[Count_Enterprise].UserName__c);
                           lead_AE_OwnerList_Enterprise[Count_Enterprise].Lead_Assigned_DateTime__c = Datetime.now();
                           Count_Enterprise = Count_Enterprise +1;
                           if( Count_Enterprise == lead_AE_OwnerList_Enterprise.size() ){
                               System.debug('before lead_AE_OwnerList_Enterprise reseeting the value---->'+count);
                               Count_Enterprise = 0;
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
            if(!lead_AE_OwnerList_Mid_Market.isEmpty()){
                update lead_AE_OwnerList_Mid_Market;
            }
            if(!lead_AE_OwnerList_Enterprise.isEmpty()){
                update lead_AE_OwnerList_Enterprise;
            }
        }catch(Exception e){
            System.debug('Exception on Line number-->'+e.getMessage()+'-error is line number-->'+e.getLineNumber());
        }
        
        
    }
    
}