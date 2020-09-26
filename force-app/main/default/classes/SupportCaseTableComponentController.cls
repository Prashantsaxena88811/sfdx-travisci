public with sharing class SupportCaseTableComponentController {
    
    @AuraEnabled
    public static List<Case> getCase(){

        List<Case> cases = new List<Case>();
        try {
            cases = [
                SELECT id,
                CaseNumber,
                Product__c,
                Type,
                Status,
                Subject,
                CreatedDate
                FROM case limit 200
            ];
        } catch (Exception ex) {
            
        }
        return cases;
    }
}