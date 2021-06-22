@isTest//(SeeAllData=true)
public class DQ_Update_transaction_Status_DATE_Test {
    @isTest
    public static void main(){
        String accounthouseholdId_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='HH_Account'].Id;
        
        String US_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='US_Organization'].Id;
        
        Account HH_account =  new Account();
        HH_account.Name ='TEST account1';
        HH_account.RecordTypeId =accounthouseholdId_TypeId;
        
        Account US_account =  new Account();
        US_account.Name ='TEST account2';
        US_account.RecordTypeId =US_TypeId;
        
        List<Account> accList = new List<Account>{HH_account,US_account};
            insert accList;
        System.debug('accList-->'+accList);
        
        ChargentOrders__ChargentOrder__c chargentOrder = new ChargentOrders__ChargentOrder__c();
        chargentOrder.ChargentOrders__Payment_Received__c	 = 'Full';
        insert chargentOrder;
        
        Order orderObj = new Order();
        orderObj.EffectiveDate = date.today();
        orderObj.AccountId = accList[0].Id;
        orderObj.status ='draft';
        orderObj.Chargent_Order__c = chargentOrder.Id;
        Insert orderObj;
        
        ChargentOrders__Transaction__c chargentTransactionObj1 = new ChargentOrders__Transaction__c();
        chargentTransactionObj1.ChargentOrders__Type__c = 'Charge';
        chargentTransactionObj1.ChargentOrders__Order__c = chargentOrder.Id;
        chargentTransactionObj1.ChargentOrders__Billing_Country__c = 'United States';
        //Insert chargentTransactionObj1;
        
            
        //orderObj.To_be_deleted__c = true;
        
        Test.setCreatedDate(orderObj.Id,Date.newInstance(2016, 5, 1)); 
        Test.startTest();
        Database.executeBatch(new DQ_Update_transaction_Status_AND_Date(false),1);
        Test.stopTest();
    }
    
}