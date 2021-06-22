@isTest
public class DQ_Delete_Invocies_Test {
	@isTest 
    public static void deleteInvoices_Test(){
        Sales_Invoice__c siObj1 =  new Sales_Invoice__c();
        siObj1.Name = 'Test SI1';
        siObj1.State__c = 'Closed';
        insert siObj1;
        Test.setCreatedDate(siObj1.Id, DateTime.newInstance(2019,12,31));  
        Test.startTest();
        Database.executeBatch(new DQ_Delete_Invocies ());
        Test.stopTest();
    }
}