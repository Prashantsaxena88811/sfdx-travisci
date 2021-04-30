public class OpportunityTriggerHelper {
        //List to store trigger new list
    public static List<Opportunity> opportunityNewList = new List<Opportunity>();
    
    // List to store trigger old list
    public static List<Opportunity> opportunityOldList = new List<Opportunity>();
    
    // Map to store new Trigger Map
    public static Map<Id, Opportunity> opportunityNewMap = new Map<Id, Opportunity>();

    // Map to store Old Trigger Map
    public static Map<Id, Opportunity> opportunityOldMap = new Map<Id, Opportunity>();
    
    
    Public static List<String> recordTypeNameList = new List<String>{'Accounting','Client Success','Deal Desk','Opportunity Follow-up','Existing Business CS Case'};
    Public static List<String> recordTypeToCreateWhenCaseIsCLosed = new List<String>{'Client Success'};
        //Public static List<String> recordTypeToCreateWhenCaseIsCLosedCompleted = new List<String>{'Accounting'};
        Public static Map<String,String> RecordTypeToStatusMap = new Map<String,String>{
                                                            'Accounting' => 'Open',
                                                            'Client Success' => 'Open',
                                                            'Deal Desk' => 'Save to Drive',
                                                            'Existing Business CS Case' => 'Save to Drive',
                                                            'Opportunity Follow-up' => 'Send CSM Introduction'
                                                                };
        
        public static void createFollowUpcases(){
            List<Case_Owner_Assignment__c> caseOwnerAssignmentList = new List<Case_Owner_Assignment__c>();
            caseOwnerAssignmentList = [Select Catch_All__c,Geography__c,Opportunity_Owner_Role__c,Segment__c,UserName__c FROM Case_Owner_Assignment__c where
                                      UserName__c != NULL AND Opportunity_Owner_Role__c!=NULL];
            Map<String,String> keyToUsersMap = new  Map<String,String>();
            Set<String> userNames = new Set<String>();
            String mapKey;
            for(Case_Owner_Assignment__c caseOwner :caseOwnerAssignmentList ){
                userNames.add(caseOwner.UserName__c);
                if(caseOwner.Catch_All__c){
                    keyToUsersMap.put(caseOwner.Opportunity_Owner_Role__c ,caseOwner.UserName__c );
                }else{
                    if(caseOwner.Segment__c != '' && caseOwner.Segment__c!=null &&
                       caseOwner.Geography__c != '' && caseOwner.Geography__c!=null ){
                           mapKey = (caseOwner.Opportunity_Owner_Role__c+caseOwner.Segment__c+caseOwner.Geography__c).toLowerCase();
                           keyToUsersMap.put(mapKey ,caseOwner.UserName__c );
                       }
                }
            }
            Map<String,String> userNameToIdMap =  new Map<String,String>();
            if(userNames!=null && !userNames.isEmpty()){
                for(User userObj : [Select Id,username from user where username IN : userNames]){
                    userNameToIdMap.put( userObj.username ,  userObj.Id );
                }
            }
                
                
            List<RecordType> recordTypeList = [Select Id,Name from RecordType where Name IN : recordTypeNameList];
            Map<String,String> NameToRecordIdMap = new Map<String,String>();
            for(RecordType recorTypeRec  : recordTypeList){
                NameToRecordIdMap.put(recorTypeRec.Name, recorTypeRec.Id);
            }
            
            List<group> queueRecList = [Select id,Name,Type from group where type = 'Queue' AND Name  IN  ('Accounting','Deal Desk')];
            Map<String,String> queueNameToIdMap = new Map<String,String>();
            for(group groupRec : queueRecList){
                queueNameToIdMap.put(groupRec.Name,groupRec.Id);
            }
            
            List<user> userRecList = [Select Id from user where name =: Label.Client_Success ];
            String recordName;
            String ownerId ;
            List<Case> caseRecToInsert = new List<Case>();
            for(Opportunity oppRec : opportunityNewList){
                if((oppRec.StageName == 'Closed Won' &&  opportunityOldMap == null)||
                   (oppRec.StageName == 'Closed Won' && oppRec.StageName !=  opportunityOldMap.get(oppRec.id).StageName)){
                       if(oppRec.Type =='' || oppRec.Type ==null ){
                           return;
                       }
                     //for(String recordName  : recordTypeToCreateWhenCaseIsCLosed){
                        //ownerId = OppRec.OwnerId;
                        /*if(recordName == 'Accounting' && queueNameToIdMap.get(recordName) != null){
                            ownerId = queueNameToIdMap.get(recordName);
                        } else */
                        /*if(recordName == 'Client Success' && userRecList.size() > 0){
                            ownerId = userRecList[0].Id;
                        }*/
                       /*if(!userRecList.isEmpty()){
                           ownerId = userRecList[0].Id; 
                       }*/
                       if(true){
                           
                       }
                       if(oppRec.Type == 'New Logo'){
                           /*if(!userRecList.isEmpty()){
                               ownerId = userRecList[0].Id; 
                           }*/
                           recordName = 'Client Success';
                       }else if(oppRec.Type == 'Opp within 12 months' || oppRec.Type == 'Opp after 12 months'){
                           recordName = 'Existing Business CS Case';
                       }
                        caseRecToInsert.add(createCaseRecord(NameToRecordIdMap.get(recordName),OppRec.Name + ' - '+ recordName, RecordTypeToStatusMap.get(recordName),ownerId, oppRec.Id,oppRec.accountId ));
                    //}
                } /*else if((oppRec.StageName == 'Closed Complete' &&  opportunityOldMap == null)||
                   (oppRec.StageName == 'Closed Complete' && oppRec.StageName !=  opportunityOldMap.get(oppRec.id).StageName)){
                    for(String recordName  : recordTypeToCreateWhenCaseIsCLosedCompleted){
                        String ownerId = OppRec.OwnerId;
                        if(recordName == 'Accounting' && queueNameToIdMap.get(recordName) != null){
                            ownerId = queueNameToIdMap.get(recordName);
                        } 
                        caseRecToInsert.add(createCaseRecord(NameToRecordIdMap.get(recordName),recordName, RecordTypeToStatusMap.get(recordName),ownerId, oppRec.Id ));
                    }
                }*/
            }
            
            if(caseRecToInsert.size() > 0){
                insert caseRecToInsert;
            }
        }
        
        
        private static case createCaseRecord(String recordTypeId, String subject, String status, String ownerId, String oppId,String accountId){
            case caseRec  = new case();
            caseRec.RecordTypeId = recordTypeId;
            caseRec.Subject =  subject;
            caseRec.OwnerId = ownerId;
            caseRec.Status =  status;
            caseRec.Opportunity__c = oppId;
            caseRec.AccountId = accountId;
            return caseRec;
        }
        
    public static void validateOpportunityUpdation(){
        Set<Id> accountIdSet = new Set<Id>();
        Id newLogoRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Logo').getRecordTypeId();
        for(opportunity oppRec : opportunityNewList){
            if(oppRec.StageName == 'Closed Won' && oppRec.AccountId != null && oppRec.RecordTypeId == newLogoRecordTypeId) {
                if(Trigger.isInsert){
                    accountIdSet.add(oppRec.AccountId);
                } else if(Trigger.isUpdate && oppRec.StageName != opportunityOldMap.get(oppRec.Id).StageName){
                    accountIdSet.add(oppRec.AccountId);
                }
            }
        }
        List<Account> accountRecList = [Select id,(Select Id, StageName from Opportunities where recordTypeId =:newLogoRecordTypeId AND StageName = 'Closed Won' ) 
                                        from Account where Id IN : accountIdSet];
        //Map<String,Integer> AccountIdToOpportunityCount = new Map<String,Integer>();
        Set<String> accHavingOpp = new Set<String>();
        for(Account accRec : accountRecList){
            if(accRec.Opportunities.size() > 0){
                accHavingOpp.add(accRec.Id);
            }
        }
        for(opportunity oppRec : opportunityNewList){
            if(oppRec.AccountId != null && oppRec.RecordTypeId == newLogoRecordTypeId 
                && accHavingOpp.contains(oppRec.AccountId) && oppRec.StageName == 'Closed Won'
                && (Trigger.isInsert || (Trigger.isUpdate && oppRec.StageName != opportunityOldMap.get(oppRec.Id).StageName))
            ){
                oppRec.addError(Label.Opportunity_Record_Type_Error);
            }
        }
        
    }
    
    
    /*public static void populateSDRFromAccount(){
        Set<Id> accountIds = new Set<Id>();
		for(opportunity oppRec : opportunityNewList){
            if(oppRec.AccountId != null){
                accountIds.add(oppRec.AccountId);
            }
        }
        Map<Id, Account> accountById = new Map<Id, Account>([SELECT Id, SDR__c, First_Contract_Date__c FROM Account
                                                             WHERE Id IN :accountIds]);
        
        for(opportunity oppRec : opportunityNewList){
            if(oppRec.AccountId != null && accountById.containsKey(oppRec.AccountId)){
                Account acc = accountById.get(oppRec.AccountId);
                if(acc.First_Contract_Date__c != null){
                    Date x12monthlaterDate = acc.First_Contract_Date__c.addMonths(12);
                    Date todayDate = Date.today();
                    if(x12monthlaterDate > todayDate){
                        oppRec.SDR__c = acc.SDR__c;
                    }
                }
            }
        }
    }*/
    
    
}