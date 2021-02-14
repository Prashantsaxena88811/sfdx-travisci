public class LeadTriggerHandlerRoundRobin {
    
    public static Set<String> US_CANADA_cites = new Set<String>{'united states','canada','usa'};
        
        public static Set<String> LATAM_cites = new Set<String>{'argentina','bolivia','brazil','chile','colombia','ecuador','frenchguiana','guyana',
            'paraguay','peru','suriname','uruguay','venezuela','belize','costarica','elsalvador','guatemala','honduras','mexico','nicaragua','panama',
            'bahamas','barbados','caymanislands','cuba','dominicanrepublic','haiti','puertorico','portugal','spain','trinadadandtobago'}; 
                
      public static Set<String> AFRICA_cites = new Set<String>{'algeria','angola','benin','botswana','burundi','cabo verde','cameroon','congo',
'cote d\'ivoire','dr congo','chad','ethiopia','gabon','gambia','ghana','guinea','kenya','liberia','madagascar','malawi','mali','morocco',
'mozambique','namibia','niger','nigeria','rwanda','senegal','sierra leone','somalia','south africa','south sudan','sudan','tanzania','togo',
'tunisia','uganda','zambia','zimbabwe'};

    public static Set<String> EUROPE_cites = new Set<String>{'albania','andorra','austria','belgium','bosnia and herzegovina','bulgaria','croatia',
    'czech republic','denmark','estonia','finland','france','germany','greece','holy see','hungary','iceland','ireland','italy','latvia',
    'liechtenstien','lithuania','luxembourg','malta','moldova','monaco','montenegro','netherlands','north macedonia','norway','poland',
    'romania','russia','san marino','serbia','slovakia','slovenia','sweden','switzerland','ukraine','england','scotland','wales'};
    
    public static Set<String> ASIA_APAC_cites = new Set<String>{'afghanistan','armenia','azerbaijan','bangladesh','bhutan','brunei','combodia',
    'china','georgia','india','indonesia','kazakhstan','kyrgyzstan','laos','lebanon','malaysia','maldives','mongolia','myanmar','nepal',
    'north korea','pakistan','singapore','sri lanka','tajikistan','thailand','timor-leste','turkmenistan','uzbekistan','vietnam',
    'equatorial guinea'};
    
    public static Set<String> PACIFIC_APAC_cites = new Set<String>{'american samoa','micronesia','fiji','cook islands','french polynesia',
    'guam','kiribati','nauru','new caledonia','papua new guinea','samoa','solomon islands','tokelau islands','tonga','tuvalu','vanuatu',
    'wallis & futuna islands'};
    
    public static Set<String>  Middle_East_cites = new Set<String>{'cyprus','turkey','syria','lebanon','israel','jordan','iraq','iran',
    'saudi arabia','yemen','oman','united arab emirates','qatar','bahrain','kuwait','egypt','libya'};
    
    public static Set<String> PJKANZ_cites = new Set<String>{'philippines','japan','south korea','australia','new zealand'};   


    public  static Map<String,Integer> globalLeadCounterMap_Vals = new Map<String,Integer>();
    public  static Map<String,List<Global_Lead_Round_Robin__c>> geoToGlobalMap_Vals =  new Map<String,List<Global_Lead_Round_Robin__c>>();
    
    public  static Map<String , List<Lead_Owner_Round_Robin__c> > industryToListOfUsersMap_leadOwner_Vals = new Map<String , List<Lead_Owner_Round_Robin__c> >();
    public  static Map<String,Integer> CounterMap_IndustryleadOwner_Vals = new Map<String,Integer>();
    
    public  static List<EDU_Round_Robin__c> EDU_UsersList_Vals = new List<EDU_Round_Robin__c>();
    public  static Integer CountEDU = 0;
    
    public  static Map<String , List<Lead_Owner_Round_Robin__c> > SegmentGeoToListOfUsersMap_leadOwner_Vals = new Map<String , List<Lead_Owner_Round_Robin__c> >();
    public  static Map<String,Integer> CounterMap_leadOwner_Vals = new Map<String,Integer>();
    
    public  static Map<String , List<Lead_Owner_Round_Robin__c> > GeoToListOfUsersMap_leadOwner_Vals = new Map<String , List<Lead_Owner_Round_Robin__c> >();
    public  static Map<String,Integer> CounterMap_Geo_leadOwner_Vals = new Map<String,Integer>();
    
    
    
    public  static List<Lead_Owner_Round_Robin__c> catchAllUsersList_Vals = new List<Lead_Owner_Round_Robin__c>();
    public  static Integer CountCatchAll = 0;
    
    public  static Map<String,String> userNameToId_Vals = new Map<String,String>();
    
    public static Map<String,Sobject> customSettingRecordToBeUpdated = New Map<String,Sobject>();
    
    
    public Static void leadRoundRobin(List<Lead> newLeadList , Map<Id,Lead> oldLeadMap){
        try{
            System.debug('newLeadList-->'+newLeadList);
            /*Get global Account list Start*/
            //Set<String> globalCompanySet = new Set<String>();
            List<Global_List__c> globalList = new List<Global_List__c>(); 
            globalList = [Select Id , Company__c from Global_List__c where Company__c!=null];
            /*for(Global_List__c compObj : globalList ){
globalCompanySet.add(compObj.Company__c.toLowerCase()); 
}*/
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
            
            /*GLOBAL USERS SETUP START*/
            mapKey = '';
            Map<String,List<Global_Lead_Round_Robin__c>> geoToGlobalMap =  new Map<String,List<Global_Lead_Round_Robin__c>>();
            List<Global_Lead_Round_Robin__c> globalUserList = new List<Global_Lead_Round_Robin__c>();
            globalUserList = [Select Id,Geography__c,UserName__c  from Global_Lead_Round_Robin__c where Geography__c!=null and UserName__c!=null order by date__c asc];
            Map<String,Integer> globalLeadCounterMap = new Map<String,Integer>();
            for( Global_Lead_Round_Robin__c globalUserObj : globalUserList){
                mapKey = globalUserObj.Geography__c;
                if(!geoToGlobalMap.containsKey(mapKey.toLowerCase()) ){
                    geoToGlobalMap.put(mapKey.toLowerCase() , new List<Global_Lead_Round_Robin__c>());
                }
                if( !globalLeadCounterMap.containsKey(mapKey.toLowerCase() ) ){
                    globalLeadCounterMap.put( mapKey.toLowerCase() , 0 );
                }
                geoToGlobalMap.get( mapKey.toLowerCase() ).add(globalUserObj);
                usernames.add(globalUserObj.UserName__c.trim());
            }
            /*GLOBAL USERS SETUP END*/
            
            /*EDU USERS SETUP START*/
            List<EDU_Round_Robin__c> EDU_UsersList = new List<EDU_Round_Robin__c>();
            EDU_UsersList = [Select Id,User_Name__c,Date__c from EDU_Round_Robin__c where User_Name__c!=null order by date__c asc];
            //Integer CountEDU = 0;
            for( EDU_Round_Robin__c EDU_User : EDU_UsersList){
                usernames.add(EDU_User.User_Name__c.trim());
            }
            /*EDU USERS SETUP END*/
            
            /*Industry and (Segment,Geography) USERS SETUP START*/
            List<Lead_Owner_Round_Robin__c> lead_Owner_OwnerList = new List<Lead_Owner_Round_Robin__c>();
            lead_Owner_OwnerList = [Select Geography__c,UserName__c,Date__c,Segment__c,Industry__c from Lead_Owner_Round_Robin__c where 
                                    Catch_All__c =FALSE AND UserName__c!=null order by date__c asc];
            System.debug('lead_Owner_OwnerList-->'+lead_Owner_OwnerList);
            
            // create map of String[segment-Geography] , List<Sorted-Lead_AE_ROUND_ROBIN>
            Map<String , List<Lead_Owner_Round_Robin__c> > SegmentGeoToListOfUsersMap_leadOwner = new Map<String , List<Lead_Owner_Round_Robin__c> >();
            // create map for Counter [segment-Geography]
            Map<String,Integer> CounterMap_leadOwner = new Map<String,Integer>();
            // create map of String [Industry] List usersname
            Map<String , List<Lead_Owner_Round_Robin__c> > industryToListOfUsersMap_leadOwner = new Map<String , List<Lead_Owner_Round_Robin__c> >();
            // create map for Counter  [Industry] 
            Map<String,Integer> CounterMap_IndustryleadOwner = new Map<String,Integer>();
            
            Map<String , List<Lead_Owner_Round_Robin__c> > GeoToListOfUsersMap_leadOwner = new Map<String , List<Lead_Owner_Round_Robin__c> >();
            // create map for Counter  [Industry] 
            Map<String,Integer> CounterMap_Geo_leadOwner = new Map<String,Integer>();
            
            //if(checkGeography.Lead_Owner_Round_Robin_Geography__c || checkGeography.Lead_Owner_Round_Robin_Segment__c){
            for(Lead_Owner_Round_Robin__c AE_Obj : lead_Owner_OwnerList){
                usernames.add(AE_Obj.UserName__c.trim());
                mapKey = '';
                /*Industry map Start*/
                if(AE_Obj.Industry__c!=null && AE_Obj.Industry__c!=''){
                    mapKey = AE_Obj.Industry__c;
                }
                if(!industryToListOfUsersMap_leadOwner.containsKey(mapKey.toLowerCase()) && mapKey!=''){
                    industryToListOfUsersMap_leadOwner.put(mapKey.toLowerCase() , new List<Lead_Owner_Round_Robin__c>());
                    CounterMap_IndustryleadOwner.put( mapKey.toLowerCase() , 0 );
                }if(industryToListOfUsersMap_leadOwner.containsKey(mapKey.toLowerCase())){
                    industryToListOfUsersMap_leadOwner.get( mapKey.toLowerCase() ).add(AE_Obj); 
                }
                /*if( !CounterMap_IndustryleadOwner.containsKey(mapKey.toLowerCase() ) ){
                    CounterMap_IndustryleadOwner.put( mapKey.toLowerCase() , 0 );
                }*/
                /*Industry map End*/
                /*segemnt + geography [geography] Start*/
                mapKey = '';
                if(AE_Obj.Segment__c!=null && AE_Obj.Segment__c!=''){
                    mapKey = AE_Obj.Segment__c;
                }
                if(AE_Obj.Geography__c!=null && AE_Obj.Geography__c!='' ){
                    System.debug('*******11****');
                    mapKey = mapKey+AE_Obj.Geography__c;
                    if(!GeoToListOfUsersMap_leadOwner.containsKey(AE_Obj.Geography__c.toLowerCase())  ){
                        System.debug('*******22****');
                           if(AE_Obj.Segment__c==null || AE_Obj.Segment__c==''){
                               System.debug('*******33****');
                               if(AE_Obj.Industry__c==null || AE_Obj.Industry__c==''){
                                   System.debug('*******44****');
                                   GeoToListOfUsersMap_leadOwner.put(AE_Obj.Geography__c.toLowerCase() , new List<Lead_Owner_Round_Robin__c>());
                                   CounterMap_Geo_leadOwner.put( AE_Obj.Geography__c.toLowerCase() , 0 );
                               } 
                           }
                           
                       }
                    if(GeoToListOfUsersMap_leadOwner.containsKey(AE_Obj.Geography__c.toLowerCase())){
                        GeoToListOfUsersMap_leadOwner.get( AE_Obj.Geography__c.toLowerCase() ).add(AE_Obj);
                    }
                }
               
                //mapKey = AE_Obj.Segment__c+ AE_Obj.Geography__c+AE_Obj.Industry__c;
                //System.debug('**Lead_user_Obj.userRec==>'+AE_Obj.userRec);
                if(!SegmentGeoToListOfUsersMap_leadOwner.containsKey(mapKey.toLowerCase()) && mapKey!=''){
                    SegmentGeoToListOfUsersMap_leadOwner.put(mapKey.toLowerCase() , new List<Lead_Owner_Round_Robin__c>());
                     CounterMap_leadOwner.put( mapKey.toLowerCase() , 0 );
                }
                if(SegmentGeoToListOfUsersMap_leadOwner.containsKey(mapKey.toLowerCase())){
                    SegmentGeoToListOfUsersMap_leadOwner.get( mapKey.toLowerCase() ).add(AE_Obj); 
                }
                /*if( !CounterMap_leadOwner.containsKey(mapKey.toLowerCase() ) ){
                    CounterMap_leadOwner.put( mapKey.toLowerCase() , 0 );
                }*/
                /*segemnt + geography [geography] Start*/
            }  
            
            /*Industry and (Segment,Geography) USERS SETUP END*/
            /*Catch-ALL USERS SETUP START*/
            List<Lead_Owner_Round_Robin__c> catchAllUsersList = new List<Lead_Owner_Round_Robin__c>();
            catchAllUsersList = [Select UserName__c,Date__c from Lead_Owner_Round_Robin__c where Catch_All__c =TRUE AND UserName__c!=null order by date__c asc];
            //Integer CountCatchAll = 0;
            for( Lead_Owner_Round_Robin__c catchAll_User : catchAllUsersList){
                usernames.add(catchAll_User.UserName__c.trim());
            }
            /*Catch-ALL USERS SETUP END*/
            
            
            /*Lead Owner round robin end*/
            
            // Map GeoGraphy=>username for Lead Owner
            
            
            //get the users and create a Map
            List<User> userListAE = new List<User>();
            if(usernames != null && (!usernames.isEmpty()) ){
                userListAE = [Select Id , username from User where username IN :usernames];
            }
            
            /*add values to the class level Start*/
            System.debug('CounterMap_leadOwner-->'+CounterMap_leadOwner);
            System.debug('SegmentGeoToListOfUsersMap_leadOwner-->'+SegmentGeoToListOfUsersMap_leadOwner);
            globalLeadCounterMap_Vals = globalLeadCounterMap;
            geoToGlobalMap_Vals = geoToGlobalMap;
            EDU_UsersList_Vals = EDU_UsersList;
            SegmentGeoToListOfUsersMap_leadOwner_Vals = SegmentGeoToListOfUsersMap_leadOwner;
            CounterMap_leadOwner_Vals = CounterMap_leadOwner;
            catchAllUsersList_Vals = catchAllUsersList;
            industryToListOfUsersMap_leadOwner_Vals =industryToListOfUsersMap_leadOwner;
            CounterMap_IndustryleadOwner_Vals =CounterMap_IndustryleadOwner;
            GeoToListOfUsersMap_leadOwner_Vals = GeoToListOfUsersMap_leadOwner;
            CounterMap_Geo_leadOwner_Vals =CounterMap_Geo_leadOwner;
            System.debug('CounterMap_IndustryleadOwner_Vals-->'+CounterMap_IndustryleadOwner_Vals);
            System.debug('industryToListOfUsersMap_leadOwner_Vals-->'+industryToListOfUsersMap_leadOwner_Vals);
            System.debug('SegmentGeoToListOfUsersMap_leadOwner_Vals-->'+SegmentGeoToListOfUsersMap_leadOwner_Vals);
            System.debug('GeoToListOfUsersMap_leadOwner_Vals-->'+GeoToListOfUsersMap_leadOwner_Vals);
            System.debug('CounterMap_Geo_leadOwner_Vals-->'+CounterMap_Geo_leadOwner_Vals);
            /*add values to the class level END*/
            // create a map of username to user Id
            Map<String,String> userNameToId = new Map<String,String>();
            for( User userObj1 : userListAE){
                userNameToId.put(userObj1.username.toLowerCase() , userObj1.Id ); 
            }
            userNameToId_Vals = userNameToId;
            System.debug('userNameToId-->'+userNameToId);
            // sort the userIds based upon the date.
            //get the user name from custom label
            String username = Label.LeadRoundRobin; 
            if(Test.isRunningTest()){
                username = 'emmersiontestUser@sf.com';
            }
            User userObj = [Select Id from user where Username =:username];// store username in custom label
            
            Integer countAE = 0 ;  // for AE OWNER round robin
            
            
            //List<Lead> globalLeadList = new List<Lead>();
            // Iteration On leads
            Boolean isGlobalLead =  false;
            Boolean isOwnerAssigned =  false;
            String newLeadOwnerId ='';
            Set<String> eduLeads = new Set<String>{'school','university','college'};
            for(Lead leadObj : newLeadList){
                
                /*Assign Geohraphy START*/
                if( oldLeadMap== null || (oldLeadMap!=null && leadObj.Country != oldLeadMap.get(leadObj.Id).Country) ){
                    System.debug(oldLeadMap+'**SET the geography**'+leadObj.Country);
                    if( leadObj.Country =='' || leadObj.Country ==null ){
                        leadObj.Geography__c = 'Unknown'; 
                    }
                    else if(US_CANADA_cites.contains(leadObj.Country.toLowerCase())){
                        leadObj.Geography__c = 'US/Canada'; 
                    }
                    else if(LATAM_cites.contains(leadObj.Country.toLowerCase())){
                        System.debug('GEOGRAPHY changed to LATAM-->');
                        leadObj.Geography__c = 'LATAM'; 
                    }
                    else if(AFRICA_cites.contains(leadObj.Country.toLowerCase())){
                        leadObj.Geography__c = 'Africa'; 
                    }
                    else if(EUROPE_cites.contains(leadObj.Country.toLowerCase())){
                        leadObj.Geography__c = 'Europe'; 
                    }
                    else if(ASIA_APAC_cites.contains(leadObj.Country.toLowerCase())){
                        leadObj.Geography__c = 'APAC'; 
                    }
                    else if(PACIFIC_APAC_cites.contains(leadObj.Country.toLowerCase())){
                        leadObj.Geography__c = 'APAC'; 
                    }
                    else if(Middle_East_cites.contains(leadObj.Country.toLowerCase())){
                        leadObj.Geography__c = 'Middle East'; 
                    }
                    else if(PJKANZ_cites.contains(leadObj.Country.toLowerCase())){
                        leadObj.Geography__c = 'PJKANZ'; 
                    }
                    else{
                        leadObj.Geography__c = 'Unknown'; 
                    }
                    
                }
                System.debug('leadObj--info>+'+leadObj);
                /*Assign Geohraphy END*/
                isGlobalLead =  false;
                isOwnerAssigned =  false;
                newLeadOwnerId ='';
                System.debug(leadObj.ownerId+'--leadObj.ownerId-->'+userObj.Id);
                mapKey = '';
                /* Lead Owner Round Robin Starts */
                if(leadObj.Company!=null && leadObj.Company!=''){
                    // && globalCompanySet.contains(leadObj.Company.toLowerCase()
                    System.debug('---global--lead--obj--'+leadObj);
                    if( leadObj.Company.toLowerCase() == 'bp' || leadObj.Company.toLowerCase() == 'abb' ){
                        isGlobalLead =  true;
                    }
                    if(!isGlobalLead){
                        for(Global_List__c globalLead : globalList ){
                            if( !(globalLead.company__c.toLowerCase() == 'bp' || globalLead.company__c.toLowerCase() == 'abb') 
                               && leadObj.Company.containsIgnoreCase(globalLead.company__c) ){
                                   isGlobalLead =  true;
                                   if(isGlobalLead){
                                       break;
                                   }
                               }
                        }  
                    }
                    if(isGlobalLead){
                        leadObj.Global_List_Lead__c = true; 
                    }
                    
                }
                System.debug('leadObj-->'+leadObj);
                if( ( leadObj.ownerId == userObj.Id && oldLeadMap == null && leadObj.Status=='Round Robin')
                   || ( oldLeadMap != null && leadObj.Status=='Round Robin' && leadObj.ownerId == userObj.Id   && 
                       (  (leadObj.Status != oldLeadMap.get(leadObj.Id).Status  || leadObj.ownerId != oldLeadMap.get(leadObj.Id).ownerId) )  )  ){
                           System.debug('execute twice');
                           
                           // CHECK FOR GLOBAL TYPE LEAD
                           if(leadObj.Company!=null && leadObj.Company!='' && isGlobalLead){
                               System.debug('---global--lead--obj--'+leadObj);
                               if(leadObj.Geography__c != NULL){
                                   newLeadOwnerId = assignOwnerToGlobalLeads(leadObj.Geography__c.toLowerCase());
                                   system.debug(' new owner Id assignOwnerToGlobalLeads-->'+newLeadOwnerId);
                                   if(String.isNotBlank(newLeadOwnerId)){
                                       leadObj.OwnerId = newLeadOwnerId;
                                       isOwnerAssigned =  true;
                                   }
                               }
                           }
                           System.debug(leadObj+'------'+!isOwnerAssigned);
                           
                           // CHECK FOR EDU TYPE LEAD
                           if(!isOwnerAssigned &&
                              ( (leadObj.Email !=null && String.isNotBlank(leadObj.Email) && leadObj.Email.containsIgnoreCase('.edu')) || 
                               (leadObj.Company!=null && String.isNotBlank(leadObj.Company) && eduLeads.contains(leadObj.Company.toLowerCase())) ) )
                           {  
                               newLeadOwnerId = assignOwnerToEDULeads();
                               if(String.isNotBlank(newLeadOwnerId)){
                                   system.debug(' new owner Id assignOwnerToEDULeads-->'+newLeadOwnerId);
                                   leadObj.OwnerId = newLeadOwnerId;
                                   isOwnerAssigned =  true;
                               }
                           }
                            // CHECK FOR Industry TYPE LEAD
                           if( !isOwnerAssigned  && leadObj.Industry!=null && String.isNotBlank(leadObj.Industry) ){
                               newLeadOwnerId =  assignOwnerToIndustryLead(leadObj.Industry.toLowerCase());
                               if(String.isNotBlank(newLeadOwnerId)){
                                   system.debug(' new owner Id assignOwnerToIndustryLead-->'+newLeadOwnerId);
                                   leadObj.OwnerId = newLeadOwnerId;
                                   isOwnerAssigned =  true;
                               }
                               
                           }
                           // CHECK FOR Segment_GEO TYPE LEAD
                           if( !isOwnerAssigned  && /**leadObj.Industry!=null && String.isNotBlank(leadObj.Industry) && **/leadObj.Segment__c!=null && 
                               String.isNotBlank(leadObj.Segment__c) && leadObj.Geography__c!=NULL && String.isNotBlank(leadObj.Geography__c) ){
                                   newLeadOwnerId =  assignOwnerToSegment_geo_Lead((leadObj.Segment__c +leadObj.Geography__c).toLowerCase());
                                   System.debug('newLeadOwnerId-->'+newLeadOwnerId);
                                   if(String.isNotBlank(newLeadOwnerId)){
                                   system.debug(' new owner Id assignOwnerToSegment_GEOLead-->'+newLeadOwnerId);
                                   leadObj.OwnerId = newLeadOwnerId;
                                   isOwnerAssigned =  true;
                               }
                               
                           }
                           // CHECK FOR GEOGRAPHY TYPE
                           if( !isOwnerAssigned && leadObj.Geography__c!=null && leadObj.Geography__c!='' ){
                               System.debug('NO geo block-->'+leadObj.Geography__c);
                               newLeadOwnerId =  assignOwnerToGeographyLead(leadObj.Geography__c.toLowerCase());
                               if(String.isNotBlank(newLeadOwnerId)){
                                   system.debug(' new owner Id assignOwnerToISGLead-->'+newLeadOwnerId);
                                   leadObj.OwnerId = newLeadOwnerId;
                                   isOwnerAssigned =  true;
                               }
                           }
                           if(!isOwnerAssigned){
                               newLeadOwnerId = assignOwnerToNOGeographyLead();
                               if(String.isNotBlank(newLeadOwnerId)){
                                   system.debug(' new owner Id assignOwnerToISGLead-->'+newLeadOwnerId);
                                   leadObj.OwnerId = newLeadOwnerId;
                                   isOwnerAssigned =  true;
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
            
            if(customSettingRecordToBeUpdated != null && !customSettingRecordToBeUpdated.isEmpty()){
                System.debug('customSettingRecordToBeUpdated-->'+customSettingRecordToBeUpdated);
                update customSettingRecordToBeUpdated.values();
            }
            
           
            
            
        }catch(Exception e){
            System.debug('Exception on Line number-->'+e.getMessage()+'-error is line number-->'+e.getLineNumber());
        }
        
        
    }
    
    public static String assignOwnerToGlobalLeads(String mapKey){
        Integer count = 0;
        String ownerId ='';
        if( globalLeadCounterMap_Vals.containsKey(mapKey.toLowerCase()) ){
            mapKey.toLowerCase();
            System.debug('ROUNDROBIN RUN');
            count = globalLeadCounterMap_Vals.get(mapKey.toLowerCase() );
            ownerId = userNameToId_Vals.get( geoToGlobalMap_Vals.get(mapKey.toLowerCase())[count].UserName__c.toLowerCase() );
            
            system.debug('Id-->'+userNameToId_Vals.get( geoToGlobalMap_Vals.get(mapKey.toLowerCase())[count].UserName__c.toLowerCase() ));
            //update time on user records
            geoToGlobalMap_Vals.get(mapKey.toLowerCase())[count].Date__c = DateTime.now() ;
            //add user to the map to update the date time
            customSettingRecordToBeUpdated.put(geoToGlobalMap_Vals.get(mapKey.toLowerCase())[count].Id , geoToGlobalMap_Vals.get(mapKey.toLowerCase())[count]);
            count = count +1;
            if( count >= geoToGlobalMap_Vals.get(mapKey.toLowerCase()).size() ){
                System.debug('global round robin count---->'+count);
                count = 0;
                globalLeadCounterMap_Vals.put( mapKey.toLowerCase() , count );
            }
            globalLeadCounterMap_Vals.put( mapKey.toLowerCase() , count );
            //leadObj.Status = 'Assigned (SDR)';
        }
        return ownerId;
        
    }
    public static String assignOwnerToEDULeads(){
        String ownerId ='';
        System.debug('>>assignOwnerToEDULeads');
        if(EDU_UsersList_Vals!=null && !EDU_UsersList_Vals.isEmpty()){
            if( CountEDU >= EDU_UsersList_Vals.size() ){
                System.debug('global round robin count---->'+CountEDU);
                CountEDU = 0;
            } 
            ownerId = userNameToId_Vals.get( EDU_UsersList_Vals[CountEDU].User_Name__c.toLowerCase() );
            EDU_UsersList_Vals[CountEDU].Date__c = DateTime.now() ;
            //add user to the map to update the date time
            customSettingRecordToBeUpdated.put(EDU_UsersList_Vals[CountEDU].Id , EDU_UsersList_Vals[CountEDU]);
            CountEDU = CountEDU +1;
        }
        return ownerId;
    }
    
    public static String assignOwnerToSegment_geo_Lead(String mapKey){ // ISG = Industry/Segment/Geography
        String ownerId ='';
        System.debug('assignOwnerToSegment_geo_Lead-->'+mapKey);
        //String mapKey = '';
        //mapKey = leadObj.Segment__c +leadObj.Geography__c+leadObj.Industry;
        Integer count = 0 ;
        if( CounterMap_leadOwner_Vals.containsKey(mapKey.toLowerCase()) ){
            
            mapKey.toLowerCase();
            System.debug('assignOwnerToISGLead ROUNDROBIN RUN');
            count = CounterMap_leadOwner_Vals.get(mapKey.toLowerCase() );
            System.debug('username-->'+SegmentGeoToListOfUsersMap_leadOwner_Vals.get(mapKey.toLowerCase())[count].UserName__c.toLowerCase());
            OwnerId = userNameToId_Vals.get( SegmentGeoToListOfUsersMap_leadOwner_Vals.get(mapKey.toLowerCase())[count].UserName__c.toLowerCase() );
            System.debug('ownerId-->'+ownerId);
            //update time on user records
            SegmentGeoToListOfUsersMap_leadOwner_Vals.get(mapKey.toLowerCase())[count].Date__c = DateTime.now() ; 
            //add user to the map to update the date time
            customSettingRecordToBeUpdated.put(SegmentGeoToListOfUsersMap_leadOwner_Vals.get(mapKey.toLowerCase())[count].Id , SegmentGeoToListOfUsersMap_leadOwner_Vals.get(mapKey.toLowerCase())[count]);
            count = count +1;
            if( count >= SegmentGeoToListOfUsersMap_leadOwner_Vals.get(mapKey.toLowerCase()).size() ){
                System.debug('lead owner before Mid-Market reseeting the value---->'+count);
                count = 0;
                CounterMap_leadOwner_Vals.put( mapKey.toLowerCase() , count );
            } 
            CounterMap_leadOwner_Vals.put( mapKey.toLowerCase() , count );
            
        }
        return ownerId;
    }
    public static String assignOwnerToIndustryLead(String mapKey){
        String ownerId ='';
        Integer count = 0 ;
        if( CounterMap_IndustryleadOwner_Vals.containsKey(mapKey.toLowerCase()) ){
            
            mapKey.toLowerCase();
            System.debug('assignOwnerToIndustryLead ROUNDROBIN RUN');
            count = CounterMap_IndustryleadOwner_Vals.get(mapKey.toLowerCase() );
            OwnerId = userNameToId_Vals.get( industryToListOfUsersMap_leadOwner_Vals.get(mapKey.toLowerCase())[count].UserName__c.toLowerCase() );
            //update time on user records
            industryToListOfUsersMap_leadOwner_Vals.get(mapKey.toLowerCase())[count].Date__c = DateTime.now() ; 
            //add user to the map to update the date time
            customSettingRecordToBeUpdated.put(industryToListOfUsersMap_leadOwner_Vals.get(mapKey.toLowerCase())[count].Id , industryToListOfUsersMap_leadOwner_Vals.get(mapKey.toLowerCase())[count]);
            count = count +1;
            if( count >= industryToListOfUsersMap_leadOwner_Vals.get(mapKey.toLowerCase()).size() ){
                System.debug('industryToListOfUsersMap_leadOwner_Vals lead owner before Mid-Market reseeting the value---->'+count);
                count = 0;
                //CounterMap_IndustryleadOwner_Vals.put( mapKey.toLowerCase() , count );
            } 
            CounterMap_IndustryleadOwner_Vals.put( mapKey.toLowerCase() , count );
            
        }
        return ownerId;
    }
    public static String assignOwnerToGeographyLead(String mapKey){
        String ownerId ='';
        Integer count = 0 ;
        if( CounterMap_Geo_leadOwner_Vals.containsKey(mapKey.toLowerCase()) && GeoToListOfUsersMap_leadOwner_Vals.get(mapKey.toLowerCase())!=null 
           && !GeoToListOfUsersMap_leadOwner_Vals.get(mapKey.toLowerCase()).isEmpty()){
            
            mapKey.toLowerCase();
            System.debug('assignOwnerToIndustryLead ROUNDROBIN RUN');
            count = CounterMap_Geo_leadOwner_Vals.get(mapKey.toLowerCase() );
            OwnerId = userNameToId_Vals.get( GeoToListOfUsersMap_leadOwner_Vals.get(mapKey.toLowerCase())[count].UserName__c.toLowerCase() );
            //update time on user records
            GeoToListOfUsersMap_leadOwner_Vals.get(mapKey.toLowerCase())[count].Date__c = DateTime.now() ; 
            //add user to the map to update the date time
            customSettingRecordToBeUpdated.put(GeoToListOfUsersMap_leadOwner_Vals.get(mapKey.toLowerCase())[count].Id , GeoToListOfUsersMap_leadOwner_Vals.get(mapKey.toLowerCase())[count]);
            count = count +1;
            if( count >= GeoToListOfUsersMap_leadOwner_Vals.get(mapKey.toLowerCase()).size() ){
                System.debug('industryToListOfUsersMap_leadOwner_Vals lead owner before Mid-Market reseeting the value---->'+count);
                count = 0;
                //CounterMap_IndustryleadOwner_Vals.put( mapKey.toLowerCase() , count );
            } 
            CounterMap_Geo_leadOwner_Vals.put( mapKey.toLowerCase() , count );
            
        }
        return ownerId;
    }
    public static String assignOwnerToNOGeographyLead(){ // catch-all lead
        String ownerId ='';
        if(catchAllUsersList_Vals!=null && !catchAllUsersList_Vals.isEmpty()){
            if( CountCatchAll >= catchAllUsersList_Vals.size() ){
                System.debug('assignOwnerToNOGeographyLead---->'+CountCatchAll);
                CountCatchAll = 0;
            } 
            ownerId = userNameToId_Vals.get( catchAllUsersList_Vals[CountCatchAll].UserName__c.toLowerCase() );
            catchAllUsersList_Vals[CountCatchAll].Date__c = DateTime.now() ;
            //add user to the map to update the date time
            customSettingRecordToBeUpdated.put(catchAllUsersList_Vals[CountCatchAll].Id , catchAllUsersList_Vals[CountCatchAll]);
            CountCatchAll = CountCatchAll +1;
        }
        return ownerId;
    }
    
    
    
}