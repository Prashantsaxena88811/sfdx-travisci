public with sharing class CustomLookupController {
    
    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, List<String> filterFieldList, String searchString, String value) {
        try {
            System.debug('filterFieldList=>'+filterFieldList);
            List<RecordsData> recordsDataList = new List<RecordsData>();
            String filterField  = String.join( filterFieldList, ', ' ); 
            
            String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
            if(String.isNotBlank(value)) {
                query += ' WHERE Id = \''+ value + '\' LIMIT 49999';
            } else {
                filterField = '';
                for(Integer count = 0 ; count <filterFieldList.size(); count++){
                    if(count < filterFieldList.size()-1){
                        filterField = filterField+' '+filterFieldList[count]+' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' OR ';
                        
                    }else{
                        filterField = filterField+' '+filterFieldList[count]+' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' ';
                        
                    }
                }
                /* query += ' WHERE '+filterField+
' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' LIMIT 49999';*/
                query += ' WHERE '+filterField+' LIMIT 49999';
                System.debug('Final Query==>'+query);
            }
            for(SObject s : Database.query(query)) {
                recordsDataList.add( new RecordsData((String)s.get('Name'), (String)s.get('id')) );
            }
            return recordsDataList;
        } catch (Exception err) {
            if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
        }
    }
    
    @AuraEnabled 
    public static dataWrp getTypeFieldValue(String OpportunityId){
        System.debug('getTypeFieldValue==>'+OpportunityId);
        List<Opportunity> opp =  new List<Opportunity>();
        opp = [Select Id ,type,CurrencyIsoCode from Opportunity where Id=:OpportunityId];
        if(opp.isEmpty()){
            return null;
        }
        dataWrp dataWrpObj = new dataWrp();
        List<pickListDataWrp> pickListDataType = new List<pickListDataWrp>();
        List<pickListDataWrp> pickListDatacurrency = new List<pickListDataWrp>();
        Schema.DescribeFieldResult fieldResult = Opportunity.Type.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            if(opp[0].Type == p.getValue()){
                pickListDataType.add( new pickListDataWrp(p.getLabel(), p.getValue() ,  true) );
            }else{
                pickListDataType.add( new pickListDataWrp(p.getLabel(), p.getValue(),false) );
            }
            
        }
        
        fieldResult = Opportunity.CurrencyIsoCode.getDescribe();
        pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            if(opp[0].CurrencyIsoCode == p.getValue()){
                pickListDatacurrency.add( new pickListDataWrp(p.getLabel(), p.getValue(),true) );
                
            }else{
              pickListDatacurrency.add( new pickListDataWrp(p.getLabel(), p.getValue(),false) );  
            }
        }
        dataWrpObj.pickListDatacurrency = pickListDatacurrency;
        dataWrpObj.pickListDataType = pickListDataType;
        
        System.debug('pickListDatacurrency==>'+pickListDatacurrency);
        System.debug('pickListDataType==>'+pickListDataType);
        System.debug('dataWrpObj==>'+dataWrpObj);
        return dataWrpObj;
    }
    
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    public class pickListDataWrp {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public Boolean selected;
        public pickListDataWrp(String label, String value,Boolean selected) {
            this.label = label;
            this.value = value;
            this.selected = selected;
        }
    }
    
    public class dataWrp{
         @AuraEnabled public List<pickListDataWrp> pickListDataType;
         @AuraEnabled public List<pickListDataWrp> pickListDatacurrency;
       
    }
    
    
   
    
}