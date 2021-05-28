public with sharing class CustomLookupController {
 
    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString, String value,String pricingType) {
        try {
            List<RecordsData> recordsDataList = new List<RecordsData>();
            String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
            if(String.isNotBlank(value)) {
                query += ' WHERE Id = \''+ value + '\' LIMIT 2000';
            } else {
                query += ' WHERE '+filterField+
                		' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\''+' AND Prcing_Type__c includes (\''+pricingType+'\')' + ' AND isActive=true '+' LIMIT 49999';
            }
            System.debug('query=>'+query);
	        for(SObject s : Database.query(query)) {
	            recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
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
 
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}