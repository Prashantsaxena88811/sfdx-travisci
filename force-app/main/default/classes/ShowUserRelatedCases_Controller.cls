public with sharing class ShowUserRelatedCases_Controller {
    @AuraEnabled//(cacheable=true)
    public static List<Case> getCaseList() {
        List<Case> caseList=  new List<Case>();
        caseList =  [SELECT Id, CaseNumber, Reason, Priority, Status FROM Case order By LastmodifiedDate DESC];
        System.debug('caseList->'+caseList);
        System.debug('caseList-size>'+caseList.size());
        return caseList;
    }

    @AuraEnabled//(cacheable=true)
    public static Boolean cloneCase(String caseId) {
        System.debug('Clone case with ID::-->'+caseId);
        try{
            List<String> fields = new List<String>();
            fields.addAll(Case.getsObjectType().getDescribe().fields.getMap().keySet());
            String soql = 'SELECT ' + String.join(fields, ',') +
                            ' FROM Case WHERE Id =: caseId ';
            List<Case> lstClone= Database.query(soql).deepclone(false,false,false);
            system.debug(lstClone);
            insert lstClone;
            system.debug('lstClone---->'+lstClone);
            system.debug('lstClone----size>'+lstClone.size());
            return true;
        }catch(Exception e){
            System.debug('get Exception on line number-->'+e.getLineNumber()+' error is--->'+e.getMessage());
            return false;
        }
        
    }
}