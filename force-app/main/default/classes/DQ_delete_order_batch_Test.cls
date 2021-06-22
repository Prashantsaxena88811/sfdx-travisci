@isTest
public class DQ_delete_order_batch_Test {
    
   /** @isTest
    public static void test_batch1(){//for order update
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
        
        Order orderObj = new Order();
        orderObj.EffectiveDate = date.today();
        orderObj.AccountId = accList[0].Id;
        orderObj.status ='draft';
        Insert orderObj;
        Test.setCreatedDate(orderObj.Id,Date.newInstance(2016, 5, 1)); 
        Test.startTest();
        Database.executeBatch(new DQ_delete_order_batch());
        Test.stopTest();
        
    }
   **/ 
    @isTest
    public static void test_batch2(){//for order delete
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
        insert chargentOrder;
        
        Order orderObj = new Order();
        orderObj.EffectiveDate = date.today();
        orderObj.AccountId = accList[0].Id;
        orderObj.status ='draft';
        orderObj.Chargent_Order__c = chargentOrder.Id;
        //orderObj.To_be_deleted__c = true;
        Insert orderObj;
        Test.setCreatedDate(orderObj.Id,Date.newInstance(2016, 5, 1)); 
        Test.startTest();
        Database.executeBatch(new DQ_delete_order_batch_V1(false));
        Test.stopTest();
        
    }
}