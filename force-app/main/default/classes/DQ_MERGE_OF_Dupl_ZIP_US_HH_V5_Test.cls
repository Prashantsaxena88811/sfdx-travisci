@isTest
public class DQ_MERGE_OF_Dupl_ZIP_US_HH_V5_Test {
  @isTest
    public static void testBatch_Merge(){
        
        
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
        
        Contact con1 = new Contact();
        con1.AccountId = accList[0].Id;
        con1.LastName = 'test contact 1';
        
        Contact con2 = new Contact();
        con2.AccountId = accList[1].Id;
        con2.LastName = 'test contact 2';
        con2.OtherStreet = ' test Street';
        con2.OtherCity = 'test city';
        con2.OtherState = 'test state';
        con2.OtherPostalCode = 'test code';
        con2.OtherCountry = 'test country';
        
        List<Contact> conList = new List<Contact>{con1,con2};
            insert conList;
        System.debug('conList-->'+conList);
        
        Id duplicateRuleID = [Select Id,DeveloperName,isActive from duplicaterule limit 1].Id;
        DuplicateRecordSet duplicateRec1 = new DuplicateRecordSet();
        duplicateRec1.duplicateRuleID = duplicateRuleID;
        insert duplicateRec1;
        
        DuplicateRecordItem itemRec1 = new DuplicateRecordItem();
        itemRec1.RecordId = conList[0].Id;
        itemRec1.DuplicateRecordSetId = duplicateRec1.Id;
        
        DuplicateRecordItem itemRec2 = new DuplicateRecordItem();
        itemRec2.RecordId = conList[1].Id;
        itemRec2.DuplicateRecordSetId = duplicateRec1.Id;
       
        List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
        affiliationList = [Select id from npe5__Affiliation__c];
        delete affiliationList;
        List<DuplicateRecordItem> DuplicateRecordItemList = new List<DuplicateRecordItem>{itemRec1,itemRec2};
            insert DuplicateRecordItemList;
        System.debug('DuplicateRecordItemList-->'+DuplicateRecordItemList);
        
        Test.startTest();
        Database.executeBatch(new DQ_MERGE_OF_Dupl_ZIP_US_HH_V5(String.valueOf(duplicateRec1.Id),'',true));
        
        Test.stopTest();
    }
    
     @isTest
    public static void testBatch_notMerge(){
        
        
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
        
        Contact con1 = new Contact();
        con1.AccountId = accList[0].Id;
        con1.LastName = 'test contact 1';
        
        Contact con2 = new Contact();
        con2.AccountId = accList[1].Id;
        con2.LastName = 'test contact 2';
        con2.OtherStreet = ' test Street';
        con2.OtherCity = 'test city';
        con2.OtherState = 'test state';
        con2.OtherPostalCode = 'test code';
        con2.OtherCountry = 'test country';
        
        List<Contact> conList = new List<Contact>{con1,con2};
            insert conList;
        System.debug('conList-->'+conList);
        
        Id duplicateRuleID = [Select Id,DeveloperName,isActive from duplicaterule limit 1].Id;
        DuplicateRecordSet duplicateRec1 = new DuplicateRecordSet();
        duplicateRec1.duplicateRuleID = duplicateRuleID;
        insert duplicateRec1;
        
        DuplicateRecordItem itemRec1 = new DuplicateRecordItem();
        itemRec1.RecordId = conList[0].Id;
        itemRec1.DuplicateRecordSetId = duplicateRec1.Id;
        
        DuplicateRecordItem itemRec2 = new DuplicateRecordItem();
        itemRec2.RecordId = conList[1].Id;
        itemRec2.DuplicateRecordSetId = duplicateRec1.Id;
       
        List<npe5__Affiliation__c> affiliationList = new List<npe5__Affiliation__c>();
        affiliationList = [Select id from npe5__Affiliation__c];
        delete affiliationList;
        List<DuplicateRecordItem> DuplicateRecordItemList = new List<DuplicateRecordItem>{itemRec1,itemRec2};
            insert DuplicateRecordItemList;
        System.debug('DuplicateRecordItemList-->'+DuplicateRecordItemList);
        
        Test.startTest();
        Database.executeBatch(new DQ_MERGE_OF_Dupl_ZIP_US_HH_V5(String.valueOf(duplicateRec1.Id),'',false));
        
        Test.stopTest();
    }


}