@isTest
public class DQ_Count_contacts_On_HouseHold_Test {
    
    @isTest
    public static void test_batch(){
        String accounthouseholdId_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='HH_Account'].Id;
        Account acc1 = new Account();
        acc1.Name = 'test Account';
        acc1.RecordTypeId = accounthouseholdId_TypeId;
        insert acc1;
        
        Contact con1 =  new Contact();
        con1.AccountId = acc1.Id;
        con1.LastName = 'test name';
        insert con1;
        Test.startTest();
        database.executeBatch(new DQ_Count_contacts_On_HouseHold(),400);
		Test.stopTest();
    }
    

}