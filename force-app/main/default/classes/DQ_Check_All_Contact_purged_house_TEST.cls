//DQ_Check_All_Contact_purged_houseHold
@isTest
public class DQ_Check_All_Contact_purged_house_TEST {
    @isTest
    public static void batchTest1(){
        String org_Account_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='HH_Account'].Id;
        Account ac = new Account();
        ac.Name = 'Test Account';
        ac.RecordTypeId = org_Account_TypeId;
        ac.Registration_Level__c =  'R0';
        insert ac;
        
        Contact con = new Contact();
        con.AccountId =ac.Id;
        con.LastName = 'Test Contact';
        con.To_be_deleted__c = true;
        insert con;
        Test.setCreatedDate(con.Id, DateTime.newInstance(2019,12,31));  
        
        Test.startTest();
        Database.executeBatch(new DQ_Check_All_Contact_purged_houseHold());
        Test.stopTest();
    }
}