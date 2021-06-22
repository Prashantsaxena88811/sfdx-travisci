//DQ_RelatedLIst_Check_On_Household_V2
@isTest
public class DQ_RelatedLIst_Check_On_House_test {
    @isTest
    public static void batchTest(){
        String org_Account_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='HH_Account'].Id;
        Account ac = new Account();
        ac.Name = 'Test Account';
        ac.RecordTypeId = org_Account_TypeId;
        ac.Registration_Level__c =  'R0';
        ac.All_Contact_to_be_Deleted__c =  true;
        insert ac;
        
        Contact con = new Contact();
        con.AccountId =ac.Id;
        con.LastName = 'Test Contact';
        con.To_be_deleted__c = true;
        insert con;
        Test.setCreatedDate(con.Id, DateTime.newInstance(2019,12,31));  
        
        Test.startTest();
        Database.executeBatch(new DQ_RelatedLIst_Check_On_Household_V2());
        Test.stopTest();
    }
    
}