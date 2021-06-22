@isTest
public class DQ_Delete_Contact_TEST {
    @isTest
    public static void method1(){
        String org_Account_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='Organization'].Id;
        Account ac = new Account();
        ac.Name = 'Test Account';
        ac.RecordTypeId = org_Account_TypeId;
        insert ac;
        
        Contact con = new Contact();
        con.AccountId =ac.Id;
        con.LastName = 'Test Contact';
        insert con;
        Test.startTest();
        Database.executeBatch(new DQ_Delete_Contact(1));
        Test.stopTest();
    }
    @isTest
    public static void method2(){
        String org_Account_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='Organization'].Id;
        Account ac = new Account();
        ac.Name = 'Test Account';
        ac.RecordTypeId = org_Account_TypeId;
        insert ac;
        
        Contact con = new Contact();
        con.AccountId =ac.Id;
        con.LastName = 'Test Contact';
        insert con;
        Test.startTest();
        Database.executeBatch(new DQ_Delete_Contact());
        Test.stopTest();
    }
}