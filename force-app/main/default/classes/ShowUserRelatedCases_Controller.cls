public with sharing class ShowUserRelatedCases_Controller {
    @AuraEnabled//(cacheable=true)
    public static List<Casewrp> getCaseList() {
        List<Case> caseList=  new List<Case>();
        caseList =  [SELECT Id,ClosedDate,CaseNumber, Reason, Priority, Status FROM Case order By LastmodifiedDate DESC limit 2000];
        System.debug('caseList->'+caseList);
        System.debug('caseList-size>'+caseList.size());

        List<Casewrp> casewrList = new List<Casewrp>();
        Casewrp casewrpObj = new Casewrp();
        Date todayDate = date.today();
        Date caseClosedDate ;
        for(Case c:caseList){
            casewrpObj = new Casewrp();
            casewrpObj.caseObj = c;
            casewrpObj.clone = c.Id +'--'+'Clone';
            casewrpObj.view = c.Id +'--'+'View';
            casewrpObj.reOpen = c.Id +'--'+'ReOpen';
            if(  c.Status =='Closed'){
                caseClosedDate = c.ClosedDate.Date();
                casewrpObj.isAllowReopenCaseVisible = true;
                if( c.ClosedDate.Date().daysBetween(todayDate) <= 5){
                    casewrpObj.isAllowReopenCase = true;
                }else{
                    casewrpObj.isAllowReopenCase = false;
                }
            }else{
                casewrpObj.isAllowReopenCase = false;
                casewrpObj.isAllowReopenCaseVisible = false;
            }
            casewrList.add(casewrpObj);
        }
        System.debug('casewrList');
        for(casewrp aa : casewrList){
            System.debug('aa----->'+aa);
        }
        return casewrList;
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

    @AuraEnabled//(cacheable=true)
    public static Boolean changeCaseStatus(String caseId) {
        try{
            Case caseObj = new Case();
            caseObj.Id = caseId;
            caseObj.Status = 'Working';
            update caseObj;
            return true;
        }catch(Exception e){
            System.debug('get Exception on line number-->'+e.getLineNumber()+' error is--->'+e.getMessage());
            return false;

        }
        
    }

    public class casewrp{
        @AuraEnabled
        public Case caseObj;
        @AuraEnabled
        public Boolean isAllowReopenCase;
        @AuraEnabled
        public Boolean isAllowReopenCaseVisible;
        @AuraEnabled
        public String reOpen;
        @AuraEnabled
        public String clone;
        @AuraEnabled
        public String view;
    }
}