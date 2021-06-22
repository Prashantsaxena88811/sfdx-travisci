global  class DQ_Count_Donation implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id,Name,Donation_Count__c FROM Contact where Donation_Count__c=null';
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext bc, List<Contact> contactChunk){
        List<AggregateResult> aggregateList = [SELECT npsp__Primary_Contact__c, COUNT(Id) FROM Opportunity where npsp__Primary_Contact__c IN :contactChunk GROUP BY npsp__Primary_Contact__c ];
        System.debug(aggregateList);
        System.debug('*******************************');
        
        List<Contact> contactListTo_beUpdated = new List<Contact>();
        for(AggregateResult ar:aggregateList){
            Integer donationCount ;
            System.debug(ar.get('npsp__Primary_Contact__c')+' ------- '+ar.get('expr0'));
            if(ar.get('npsp__Primary_Contact__c') !=null){
                Contact accObj = new Contact();
                accObj.Id = String.valueOf(ar.get('npsp__Primary_Contact__c'));
                if( ar.get('expr0') == null ){
                    System.debug('***********111111111************');
                    accObj.Donation_Count__c = 0;
                }else{
                    System.debug('***********22222222222222************');
                    donationCount = Integer.valueOf(ar.get('expr0'));
                    accObj.Donation_Count__c = donationCount;
                }
                contactListTo_beUpdated.add(accObj); 
            }
        }
        
        if(contactListTo_beUpdated!=null && !contactListTo_beUpdated.isEmpty()){
            System.debug('******update account******');
            update contactListTo_beUpdated;
        }
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}