@isTest
public class DQ_Create_HH_ACCOUNT_Test {
    
    @isTest
    public static void main(){
        String org_Account_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='US_Organization'].Id;
        Account ac = new Account();
        ac.Name = 'Test Account';
        ac.RecordTypeId = org_Account_TypeId;
        insert ac;
        
        Contact con = new Contact();
        con.AccountId =ac.Id;
        con.LastName = 'Test Contact';
        insert con;
        
        List<npe5__Affiliation__c> affliation_rec = new List<npe5__Affiliation__c>();
        affliation_rec = [Select Id from npe5__Affiliation__c Limit 1];
        delete affliation_rec;
        Test.startTest();
        Database.executeBatch(new DQ_Create_HH_ACCOUNT());
        Test.stopTest();
    }
    
}