@isTest
public class DQ_Delete_Contact_V4_Test {
    @isTest
    public static void deleteContactTest(){
        String org_Account_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='US_Organization'].Id;
        Account ac = new Account();
        ac.Name = 'Test Account';
        ac.RecordTypeId = org_Account_TypeId;
        ac.Registration_Level__c =  'R0';
        insert ac;
        
        Contact con = new Contact();
        con.AccountId =ac.Id;
        con.LastName = 'Test Contact';
        insert con;
        Test.setCreatedDate(con.Id, DateTime.newInstance(2019,12,31));  
        
        Test.startTest();
        Database.executeBatch(new DQ_Delete_Contact_V4(1));
        Test.stopTest();
        
    }
}