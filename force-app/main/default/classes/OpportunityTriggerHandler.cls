public class OpportunityTriggerHandler {
    public static void populateSDRFromCloseWonOpp(List<Opportunity> opportunityNewList){
        Set<Id> accountIds = new Set<Id>();
        for(opportunity oppRec : opportunityNewList){
            if(oppRec.AccountId != null){
                accountIds.add(oppRec.AccountId);
            }
        }
        Map<Id, Account> accountById = new Map<Id, Account>([Select id,(Select SDR__c,CloseDate from Opportunities  where Recordtype.DeveloperName = 'New_Logo' and SDR__c!=null order by CloseDate asc Limit 1) from Account where Id IN :accountIds]);
        for(opportunity oppRec : opportunityNewList){
            if(oppRec.AccountId != null && accountById.containsKey(oppRec.AccountId) 
               && accountById.get(oppRec.AccountId).Opportunities !=null ){
                   if(!accountById.get(oppRec.AccountId).Opportunities.isEmpty()){
                       if(accountById.get(oppRec.AccountId).Opportunities[0].CloseDate.addMonths(12) >  oppRec.CloseDate )
                           oppRec.SDR__c = accountById.get(oppRec.AccountId).Opportunities[0].SDR__c; 
                   }
                   
               }
        }
    }
    
    public static void createDualOpportunities(List<Opportunity> opportunityNewList){
        RecordType recordType = new RecordType();
        recordType = [select id from recordtype where DeveloperName = 'Existing_Business' and SobjectType = 'Opportunity'];
        List<opportunity> cloneOpportunityList =  new List<opportunity>();
        List<Integer> indexList = new List<Integer>();
        Integer count = 0;
        String deserialzeSerialze;
        Set<Id> oppIds = new Set<Id>();
        String query  = OpportunityTriggerHandler.getCreatableFieldsSOQL('Opportunity');
        System.debug('query------->'+query);
        query = query +' where Id IN:opportunityNewList';
        List<Opportunity> opList = Database.query(query);
        for(opportunity oppRec : opList){
            if(oppRec.Future_Opp__c){
                Opportunity opp = new Opportunity();
                deserialzeSerialze =  (JSON.serializePretty(oppRec));
                opp = (Opportunity)JSON.deserialize(deserialzeSerialze, Opportunity.Class);
                opp.Name = oppRec.Name+' Future Opp';
                opp.Id =  null;
                opp.RecordTypeId = recordType.Id;
                opp.Future_Opp__c = false;
                opp.Type = 'Opp within 12 months';
                opp.Stated_Annual_Need__c = oppRec.Future_Stated_Annual_Need__c;
                opp.Future_Stated_Annual_Need__c = '';
                cloneOpportunityList.add(opp);  
                indexList.add(count);
                System.debug('oppRec------>'+oppRec);
                oppIds.add(oppRec.Id);
            }
            count = count +1;
            
        }
        if(!cloneOpportunityList.isEmpty()){
            
            insert cloneOpportunityList;
            system.debug('------cloneOpportunityList->'+cloneOpportunityList);
            System.debug('oppIds----->'+oppIds);
            count =0;
            for(opportunity oppRec : opList){
                if(oppRec.Future_Opp__c){
                    System.debug('add future Opportunity');
                  oppRec.Future_Opportunity__c = cloneOpportunityList[count].Id;
                  count = count + 1;
                }
                
            }
            update opList;
        }
    }
    
    public static string getCreatableFieldsSOQL(String objectName){
        String selects = '';
         
       // if (whereClause == null || whereClause == ''){ return null; }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
         
        return 'SELECT ' + selects + ' FROM ' + objectName ;
       // return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
         
    }
}