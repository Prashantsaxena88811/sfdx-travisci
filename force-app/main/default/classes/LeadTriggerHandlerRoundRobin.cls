public class LeadTriggerHandlerRoundRobin {
    
    public Static void leadRoundRobin(List<Lead> newLeadList , Map<Id,Lead> oldLeadMap){
        try{
            
            /*Get global Account list Start*/
            Set<String> globalCompanySet = new Set<String>();
            List<Global_List__c> globalList = new List<Global_List__c>(); 
            globalList = [Select Id , Company__c from Global_List__c];
            for(Global_List__c compObj : globalList ){
                globalCompanySet.add(compObj.Company__c.toLowerCase()); 
            }
            /*Get global Account list End*/
            
            Lead_Round_Robin__c checkGeography = Lead_Round_Robin__c.getOrgDefaults();
            System.debug('checkGeography-'+checkGeography);
            
            /*AE round robin start*/
            List<Lead_AE_Owner_Round_Robin__c> lead_AE_OwnerList = new List<Lead_AE_Owner_Round_Robin__c>();
            lead_AE_OwnerList = [Select Geography__c,UserName__c,Lead_Assigned_DateTime__c,Segment__c from Lead_AE_Owner_Round_Robin__c order by Lead_Assigned_DateTime__c asc];
            System.debug('lead_AE_OwnerList-->'+lead_AE_OwnerList);
            
            //List<AE_OwnerCustomsorting>  AE_OwnerCustomsortingList = new List<AE_OwnerCustomsorting>();
            Set<String> usernames = New Set<String>();
            for( Lead_AE_Owner_Round_Robin__c userObj1 : lead_AE_OwnerList){
                //AE_OwnerCustomsortingList.add(new AE_OwnerCustomsorting( userObj1 ));
                usernames.add(userObj1.UserName__c.trim());
            }
            //System.debug('AE_OwnerCustomsortingList-->'+AE_OwnerCustomsortingList);
            // AE_OwnerCustomsortingList.sort();
            //System.debug('AFTER Sorting AE_OwnerCustomsortingList-->'+AE_OwnerCustomsortingList);
            
            // create map of String[segment-Geography] , List<Sorted-Lead_AE_ROUND_ROBIN>
            Map<String , List<Lead_AE_Owner_Round_Robin__c> > SegmentGeoToListOfUsersMapAE = new Map<String , List<Lead_AE_Owner_Round_Robin__c> >();
            // create map for Counter
            Map<String,Integer> CounterMap = new Map<String,Integer>();//for AE owner
            String mapKey;
            if( checkGeography.AE_Owner_Round_Robin_Segment__c  ||  checkGeography.AE_Owner_Round_Robin_Geography__c){
                for( Lead_AE_Owner_Round_Robin__c AE_Obj : lead_AE_OwnerList){
                    mapKey = '';
                    if(checkGeography.AE_Owner_Round_Robin_Segment__c){
                        if( AE_Obj.Segment__c != null && AE_Obj.Segment__c != '' ){
                            mapKey = AE_Obj.Segment__c;
                        } 
                    }
                    
                    if(checkGeography.AE_Owner_Round_Robin_Geography__c){
                        if( AE_Obj.Geography__c != null && AE_Obj.Geography__c != '' ){
                            mapKey = mapKey + AE_Obj.Geography__c;
                        }  
                    }
                    
                    mapKey.toLowerCase();
                    System.debug('**AE_Obj.userRec==>'+AE_Obj);
                    if(!SegmentGeoToListOfUsersMapAE.containsKey(mapKey.toLowerCase()) ){
                        SegmentGeoToListOfUsersMapAE.put(mapKey.toLowerCase() , new List<Lead_AE_Owner_Round_Robin__c>());
                    }
                    if( !CounterMap.containsKey( mapKey.toLowerCase() ) ){
                        CounterMap.put( mapKey.toLowerCase() , 0 );
                    }
                    SegmentGeoToListOfUsersMapAE.get( mapKey.toLowerCase() ).add(AE_Obj);
                    //usernames.add(AE_Obj.userRec.UserName__c.trim());
                } 
            }
            
            System.debug('CounterMap-->'+CounterMap);
            System.debug(oldLeadMap+'--SegmentGeoToListOfUsersMapAE-->'+SegmentGeoToListOfUsersMapAE);
            /*AE round robin end*/
            
            /*Lead Owner round robin start*/
            List<Lead_Owner_Round_Robin__c> lead_Owner_OwnerList = new List<Lead_Owner_Round_Robin__c>();
            lead_Owner_OwnerList = [Select Geography__c,UserName__c,Date__c,Segment__c from Lead_Owner_Round_Robin__c order by date__c asc];
            System.debug('lead_Owner_OwnerList-->'+lead_Owner_OwnerList);
            
            //List<Lead_OwnerCustomsorting>  lead_Owner_OwnerListSorted = new List<Lead_OwnerCustomsorting>();
            //Set<String> usernames = New Set<String>();
            for( Lead_Owner_Round_Robin__c userObj1 : lead_Owner_OwnerList){
                //lead_Owner_OwnerListSorted.add(new Lead_OwnerCustomsorting( userObj1 ));
                usernames.add(userObj1.UserName__c.trim());
            }
            //System.debug('lead_Owner_OwnerListSorted-->'+lead_Owner_OwnerListSorted);
            //lead_Owner_OwnerListSorted.sort();
            //System.debug('AFTER Sorting lead_Owner_OwnerListSorted-->'+lead_Owner_OwnerListSorted);
            
            // create map of String[segment-Geography] , List<Sorted-Lead_AE_ROUND_ROBIN>
            Map<String , List<Lead_Owner_Round_Robin__c> > SegmentGeoToListOfUsersMap_leadOwner = new Map<String , List<Lead_Owner_Round_Robin__c> >();
            // create map for Counter
            Map<String,Integer> CounterMap_leadOwner = new Map<String,Integer>();
            if(checkGeography.Lead_Owner_Round_Robin_Geography__c || checkGeography.Lead_Owner_Round_Robin_Segment__c){
                for(Lead_Owner_Round_Robin__c AE_Obj : lead_Owner_OwnerList){
                    mapKey = '';
                    if(checkGeography.Lead_Owner_Round_Robin_Segment__c){
                        if( AE_Obj.Segment__c != null && AE_Obj.Segment__c != '' ){
                            mapKey = AE_Obj.Segment__c;
                        }  
                    }
                    if(checkGeography.Lead_Owner_Round_Robin_Geography__c){
                        if( AE_Obj.Geography__c != null && AE_Obj.Geography__c != '' ){
                            mapKey = mapKey + AE_Obj.Geography__c;
                        }  
                    }
                    
                    mapKey.toLowerCase();
                    //System.debug('**Lead_user_Obj.userRec==>'+AE_Obj.userRec);
                    if(!SegmentGeoToListOfUsersMap_leadOwner.containsKey(mapKey.toLowerCase()) ){
                        SegmentGeoToListOfUsersMap_leadOwner.put(mapKey.toLowerCase() , new List<Lead_Owner_Round_Robin__c>());
                    }
                    if( !CounterMap_leadOwner.containsKey(mapKey.toLowerCase() ) ){
                        CounterMap_leadOwner.put( mapKey.toLowerCase() , 0 );
                    }
                    SegmentGeoToListOfUsersMap_leadOwner.get( mapKey.toLowerCase() ).add(AE_Obj);
                    //usernames.add(AE_Obj.userRec.UserName__c.trim());
                }  
            }
            
            
            /*Lead Owner round robin end*/
            
            // Map GeoGraphy=>username for Lead Owner
            
            
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
            if(Test.isRunningTest()){
                username = 'emmersiontestUser@sf.com';
            }
            User userObj = [Select Id from user where Username =:username];// store username in custom label
            Integer count = 0; // for leadOwner round robin
            Integer countAE = 0 ;  // for AE OWNER round robin
            
            //allow single time for udpate
            Integer isExecute = 0;
            if( newLeadList[0].Id == null && newLeadList[0].ownerId == userObj.Id){
                isExecute = isExecute + 1;
                LeadRobinRecursiveCheck.firstCall = isExecute;
                System.debug('---------------isExecute1-'+isExecute);
            }
            if(newLeadList[0].Id !=null ){
                LeadRobinRecursiveCheck.firstCall = LeadRobinRecursiveCheck.firstCall +1;
                isExecute = LeadRobinRecursiveCheck.firstCall;
                //LeadRobinRecursiveCheck.firstCall = true;
                System.debug('---------------isExecute2-'+isExecute);
            }
            System.debug('isExecute-->'+isExecute);
            List<Lead> globalLeadList = new List<Lead>();
            // Iteration On leads
            for(Lead leadObj : newLeadList){
                System.debug(leadObj.ownerId+'--leadObj.ownerId-->'+userObj.Id);
                mapKey = '';
                /* Lead Owner Round Robin Starts */
                if(leadObj.Company!=null && leadObj.Company!='' && globalCompanySet.contains(leadObj.Company.toLowerCase())){
                    System.debug('---global--lead--obj--'+leadObj);
                    leadObj.Global_List_Lead__c = true;
                }
                System.debug('leadObj-->'+leadObj);
                if( ( leadObj.ownerId == userObj.Id && oldLeadMap == null && leadObj.Status=='Round Robin')
                   || ( oldLeadMap != null && (isExecute == 2 || leadObj.Status=='Round Robin') && (isExecute == 2 || leadObj.ownerId == userObj.Id)   && 
                       (  isExecute == 2  || (leadObj.Status != oldLeadMap.get(leadObj.Id).Status  || leadObj.ownerId != oldLeadMap.get(leadObj.Id).ownerId) )  )  ){
                           System.debug('execute twice');
                           if(leadObj.Company!=null && leadObj.Company!='' && globalCompanySet.contains(leadObj.Company.toLowerCase())){
                               System.debug('---global--lead--obj--'+leadObj);
                               globalLeadList.add(leadObj);
                           }
                           else{  
                               System.debug('LEAD ROUND ROBIN');
                               if(checkGeography.Lead_Owner_Round_Robin_Geography__c || checkGeography.Lead_Owner_Round_Robin_Segment__c){
                                   mapKey = '';
                                   
                                   if(checkGeography.Lead_Owner_Round_Robin_Segment__c){
                                       if( leadObj.Segment__c != null && leadObj.Segment__c != '' ){
                                           mapKey = leadObj.Segment__c;
                                       }
                                   }
                                   
                                   if(checkGeography.Lead_Owner_Round_Robin_Geography__c){
                                       if( leadObj.Geography__c != null && leadObj.Geography__c != '' ){
                                           mapKey = mapKey + leadObj.Geography__c;
                                       }  
                                   }
                                   
                                   
                                   
                                   if( CounterMap_leadOwner.containsKey(mapKey.toLowerCase()) ){
                                       
                                       mapKey.toLowerCase();
                                       System.debug('ROUNDROBIN RUN');
                                       count = CounterMap_leadOwner.get(mapKey.toLowerCase() );
                                       leadObj.OwnerId = userNameToId.get( SegmentGeoToListOfUsersMap_leadOwner.get(mapKey.toLowerCase())[count].UserName__c.toLowerCase() );
                                       //update time on user records
                                       SegmentGeoToListOfUsersMap_leadOwner.get(mapKey.toLowerCase())[count].Date__c = DateTime.now() ; 
                                       count = count +1;
                                       if( count == SegmentGeoToListOfUsersMap_leadOwner.get(mapKey.toLowerCase()).size() ){
                                           System.debug('lead owner before Mid-Market reseeting the value---->'+count);
                                           count = 0;
                                           CounterMap_leadOwner.put( mapKey.toLowerCase() , count );
                                       } 
                                       CounterMap_leadOwner.put( mapKey.toLowerCase() , count );
                                       leadObj.Status = 'Assigned (SDR)';
                                   }
                                   
                               }
                               else{
                                   if(lead_Owner_OwnerList!=null && lead_Owner_OwnerList.size() > 0){
                                       System.debug('ROUNDROBIN RUN');
                                       System.debug('owner1-->'+lead_Owner_OwnerList[count].UserName__c.toLowerCase());
                                       System.debug('owner2-->'+userNameToId.get(lead_Owner_OwnerList[count].UserName__c.toLowerCase()));
                                       leadObj.ownerId = userNameToId.get(lead_Owner_OwnerList[count].UserName__c.toLowerCase());
                                       lead_Owner_OwnerList[count].date__c = Datetime.now();
                                       count =count +1;
                                       if( count == lead_Owner_OwnerList.size() ){
                                           System.debug('before reseeting the value---->'+count);
                                           count =0;
                                       }
                                       leadObj.Status = 'Assigned (SDR)';  
                                   }
                                   
                               }
                           } 
                       }
                
                
                
                /* Lead Owner Round Robin Ends */
                
                /* Lead AE Owner Round Robin Starts */
                
                if( leadObj.status!='Disqualified' && leadObj.User__c==null && ( leadObj.Segment__c != '' && leadObj.Segment__c!= null ) &&
                   ( oldLeadMap == null || ( oldLeadMap != null && (leadObj.User__c!=oldLeadMap.get(leadObj.Id).User__c || leadObj.Segment__c!=oldLeadMap.get(leadObj.Id).Segment__c) )  ) ){
                       mapKey = '';
                       
                       if(checkGeography.AE_Owner_Round_Robin_Geography__c || checkGeography.AE_Owner_Round_Robin_Segment__c){
                           if(checkGeography.AE_Owner_Round_Robin_Segment__c){
                               if( leadObj.Segment__c != null && leadObj.Segment__c != '' ){
                                   mapKey = leadObj.Segment__c;
                               }  
                           }
                           
                           if(checkGeography.AE_Owner_Round_Robin_Geography__c){
                               if( leadObj.Geography__c != null && leadObj.Geography__c != '' ){
                                   mapKey = mapKey + leadObj.Geography__c;
                               } 
                           }
                           
                           if( CounterMap.containsKey(mapKey.toLowerCase()) ){
                               mapKey.toLowerCase();
                               System.debug('-->'+mapKey.toLowerCase()+'-ROUNDROBIN RUN--countAE--'+countAE+' -->'+CounterMap.get(mapKey.toLowerCase()));
                               countAE = CounterMap.get(mapKey.toLowerCase() );
                               System.debug('ROUNDROBIN RUN--countAE-->>'+countAE);
                               System.debug('1-->>'+ SegmentGeoToListOfUsersMapAE.get(mapKey.toLowerCase())[countAE]);
                               leadObj.User__c = userNameToId.get( SegmentGeoToListOfUsersMapAE.get(mapKey.toLowerCase())[countAE].UserName__c.toLowerCase() );
                               //update time on user records
                               SegmentGeoToListOfUsersMapAE.get(mapKey.toLowerCase())[countAE].Lead_Assigned_DateTime__c = DateTime.now() ; 
                               countAE = countAE +1;
                               if( countAE == SegmentGeoToListOfUsersMapAE.get(mapKey.toLowerCase()).size() ){
                                   System.debug('lead owner before Mid-Market reseeting the value---->'+countAE);
                                   countAE = 0;
                                   //CounterMap.put( mapKey.toLowerCase() , countAE );
                               } 
                               CounterMap.put( mapKey.toLowerCase() , countAE );
                           }
                       }else{
                           if(lead_AE_OwnerList!=null && lead_AE_OwnerList.size() > 0){
                               leadObj.User__c = userNameToId.get(lead_AE_OwnerList[countAE].UserName__c.toLowerCase());
                               lead_AE_OwnerList[countAE].Lead_Assigned_DateTime__c = Datetime.now();
                               countAE =countAE +1;
                               if( countAE == lead_AE_OwnerList.size() ){
                                   System.debug('before reseeting the value---->'+countAE);
                                   countAE =0;
                               }  
                           }
                           
                           
                       }
                   }
                /* Lead AE Owner Round Robin Ends */
                
            }
            
            
            /*Send for global round robin*/
            System.debug('globalLeadList-->'+globalLeadList);
            if(globalLeadList!=null && !globalLeadList.isEmpty()){
                GlobalRoundRobinLogic.globalRoundRobin(globalLeadList);  
            }
            
            if(checkGeography.AE_Owner_Round_Robin_Geography__c  || checkGeography.AE_Owner_Round_Robin_Segment__c  ){
                List<Lead_AE_Owner_Round_Robin__c> lead_AE_OwnerListUpdate = new List<Lead_AE_Owner_Round_Robin__c>();
                for( String mapKeyVal : SegmentGeoToListOfUsersMapAE.keySet() ){
                    lead_AE_OwnerListUpdate.addAll( SegmentGeoToListOfUsersMapAE.get(mapKeyVal) );
                } 
                if(!lead_AE_OwnerListUpdate.isEmpty()){
                    update lead_AE_OwnerListUpdate;
                }  
            }else{
                if(!lead_AE_OwnerList.isEmpty()){
                    update lead_AE_OwnerList;
                }  
            }
            
            
            if(checkGeography.Lead_Owner_Round_Robin_Geography__c || checkGeography.Lead_Owner_Round_Robin_Segment__c){
                List<Lead_Owner_Round_Robin__c> lead_Owner_OwnerListUpdate = new List<Lead_Owner_Round_Robin__c>();
                for( String mapKeyVal : SegmentGeoToListOfUsersMap_leadOwner.keySet() ){
                    lead_Owner_OwnerListUpdate.addAll( SegmentGeoToListOfUsersMap_leadOwner.get(mapKeyVal) );
                } 
                if(!lead_Owner_OwnerListUpdate.isEmpty()){
                    update lead_Owner_OwnerListUpdate;
                }
            }else{
                if(!lead_Owner_OwnerList.isEmpty()){
                    update lead_Owner_OwnerList;
                }
            }
            
        }catch(Exception e){
            System.debug('Exception on Line number-->'+e.getMessage()+'-error is line number-->'+e.getLineNumber());
        }
        
        
    }
}