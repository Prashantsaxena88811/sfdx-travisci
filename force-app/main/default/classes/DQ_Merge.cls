public class DQ_Merge {
    
    public static void main(){
        try{
            Contact masterAcct = [SELECT Id, FirstName,Awana_Role__c,Birthdate FROM Contact WHERE Id=:'003f400000eqo52' LIMIT 1];
            Contact mergeAcct = [SELECT  Id, FirstName,Awana_Role__c,Birthdate FROM Contact WHERE Id=:'003f400000DpMLH' LIMIT 1];
            
            merge masterAcct mergeAcct;
            
        }catch(Exception e){
            System.debug('Get exception on line number==>'+e.getLineNumber()+' error is=>'+e.getMessage()+' trace=>'+e.getStackTraceString());
        }
    }
}