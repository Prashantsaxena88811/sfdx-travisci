@isTest
public class CustomLookupController_Test {
    @isTest 
    public static void fetchRecords_Test(){
        
        Account acObj1 = new Account();
        acObj1.Name = 'test Account';
        insert acObj1;
        
        Contact conObj1 = new Contact();
        conObj1.LastName = 'Test Contact';
        conObj1.AccountId = acObj1.Id;
        conObj1.Role__c = 'Admin';
        conObj1.Email = 'Test@gmail.com';
        conObj1.CurrencyIsoCode = 'USD';
        insert conObj1;
        
        Opportunity opObj1 = new Opportunity();
        opObj1.Name = 'Test Opportunity1';
        opObj1.AccountId = acObj1.Id;
        opObj1.Primary_Contact__c = conObj1.Id;
        opObj1.Region__c = 'US';
        opObj1.Opportunity_Type__c = 'New';
        opObj1.License__c = 'SaaS';
        opObj1.Type = 'KeyedIn Manufacturing-SMB';
        //opObj1.Area_of_Interest__c = 'KeyedIn Projects;KeyedIn Enterprise;KeyedIn Adaptive Portfolio';
        opObj1.StageName = '1. Initiate';
        opObj1.Opportunity_Type__c = 'New';
        opObj1.License__c = 'SaaS';
        opObj1.ForecastCategoryName = 'Omitted';
        opObj1.CloseDate = Date.today().addDays(40);
        insert opObj1;
        
        PriceBook2 pbObj1 = new Pricebook2();
        pbObj1.isActive =true;
        pbObj1.Name ='KeyedIn Projects';
        insert pbObj1;
        Test.startTest();
        CustomLookupController.fetchRecords(String.valueOf(opObj1.id),'Product2', new List<String>{'name'},'','');
        Test.stopTest();
    }
    @isTest 
    public static void fetchRecords_Test2(){
        
        Account acObj1 = new Account();
        acObj1.Name = 'test Account';
        insert acObj1;
        
        Contact conObj1 = new Contact();
        conObj1.LastName = 'Test Contact';
        conObj1.AccountId = acObj1.Id;
        conObj1.Role__c = 'Admin';
        conObj1.Email = 'Test@gmail.com';
        conObj1.CurrencyIsoCode = 'USD';
        insert conObj1;
        
        Opportunity opObj1 = new Opportunity();
        opObj1.Name = 'Test Opportunity1';
        opObj1.AccountId = acObj1.Id;
        opObj1.Primary_Contact__c = conObj1.Id;
        opObj1.Region__c = 'US';
        opObj1.Opportunity_Type__c = 'New';
        opObj1.License__c = 'SaaS';
        opObj1.Type = 'KeyedIn Manufacturing-Sign Edition';
        opObj1.Area_of_Interest__c = 'KeyedIn Projects;KeyedIn Enterprise;KeyedIn Adaptive Portfolio';
        opObj1.StageName = '1. Initiate';
        opObj1.Opportunity_Type__c = 'New';
        opObj1.License__c = 'SaaS';
        opObj1.ForecastCategoryName = 'Omitted';
        opObj1.CloseDate = Date.today().addDays(40);
        insert opObj1;
        
        PriceBook2 pbObj1 = new Pricebook2();
        pbObj1.isActive =true;
        pbObj1.Name ='KeyedIn Sign';
        insert pbObj1;
        Test.startTest();
        CustomLookupController.fetchRecords(String.valueOf(opObj1.id),'Product2', new List<String>{'name'},'','');
        Test.stopTest();
    }
    
    
    @isTest 
    public static void fetchRecords_Test4(){
        
        Account acObj1 = new Account();
        acObj1.Name = 'test Account';
        insert acObj1;
        
        Contact conObj1 = new Contact();
        conObj1.LastName = 'Test Contact';
        conObj1.AccountId = acObj1.Id;
        conObj1.Role__c = 'Admin';
        conObj1.Email = 'Test@gmail.com';
        conObj1.CurrencyIsoCode = 'USD';
        insert conObj1;
        
        Opportunity opObj1 = new Opportunity();
        opObj1.CurrencyIsoCode = 'USD';
        opObj1.Name = 'Test Opportunity1';
        opObj1.AccountId = acObj1.Id;
        opObj1.Primary_Contact__c = conObj1.Id;
        opObj1.Region__c = 'UK';
        opObj1.Opportunity_Type__c = 'New';
        opObj1.License__c = 'SaaS';
        opObj1.Type = 'KeyedIn Projects';
        opObj1.Area_of_Interest__c = 'KeyedIn Projects;KeyedIn Enterprise;KeyedIn Adaptive Portfolio';
        opObj1.StageName = '1. Initiate';
        opObj1.Opportunity_Type__c = 'New';
        opObj1.License__c = 'SaaS';
        opObj1.ForecastCategoryName = 'Omitted';
        opObj1.CloseDate = Date.today().addDays(40);
        insert opObj1;
        
        PriceBook2 pbObj1 = new Pricebook2();
        pbObj1.isActive =true;
        pbObj1.Name ='KeyedIn Projects';
        
        insert pbObj1;
        
        Product2 prodObj1 = new Product2();
        prodObj1.isActive = true;
        prodObj1.Name = 'test Product1';
        prodObj1.ProductCode='KIE-ALL-LIC-STOR';
        prodObj1.Family ='KeyedIn Projects Software';
        insert prodObj1;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PriceBookEntry pbEntry1 = new PriceBookEntry();
        pbEntry1.CurrencyIsoCode = 'USD';
        pbEntry1.isActive = true;
        PbEntry1.Pricebook2Id = pricebookId;
        pbEntry1.Product2Id = prodObj1.Id;
        pbEntry1.UnitPrice = 5;
        insert pbEntry1;
        
        PriceBookEntry pbEntry2 = new PriceBookEntry();
        pbEntry2.CurrencyIsoCode = 'USD';
        pbEntry2.isActive = true;
        PbEntry2.Pricebook2Id = pbObj1.Id;
        pbEntry2.Product2Id = prodObj1.Id;
        pbEntry2.UnitPrice = 5;
        System.debug('pbEntry2==>'+pbEntry2);
        insert pbEntry2;
        
        List<String> productFamilyList =  new List<String>();
        productFamilyList.add('KeyedIn Projects Software');
        productFamilyList.add('Keyedin Projects Services');
        productFamilyList.add('KeyedIn Enterprise Software');
        productFamilyList.add('Keyedin Projects Services');
        productFamilyList.add('KeyedIn Adaptive Portfolios Software');
        productFamilyList.add('Keyedin Projects Services');
        
        List<Product2> plist1 = new List<Product2>();
        plist1 = [SELECT Id,Family,isActive,name FROM Product2 WHERE  name LIKE '%%' ];
        system.debug('plist=1=>'+plist1);       
        
        
        List<Product2> plist2 = new List<Product2>();
        plist2 = [SELECT Id, name FROM Product2 WHERE  name LIKE '%%'  AND (productcode like '%ROW%' or productcode like '%ALL%') ];
        system.debug('plist=2=>'+plist2);
        
        List<Product2> plist4 = new List<Product2>();
        plist4 = [
            SELECT Id, name FROM Product2 WHERE  name LIKE '%%'  AND (productcode like '%ROW%' or productcode like '%ALL%')
            AND Family IN:productFamilyList And isActive=true LIMIT 49999];
        system.debug('plist=4=>'+plist4);
        
        Test.startTest();
        CustomLookupController.fetchRecords(String.valueOf(opObj1.id),'Product2', new List<String>{'name'},'','');
        Test.stopTest();
    }
    
    @isTest 
    public static void insertLineItems_Test(){
        
        Account acObj1 = new Account();
        acObj1.Name = 'test Account';
        insert acObj1;
        
        Contact conObj1 = new Contact();
        conObj1.LastName = 'Test Contact';
        conObj1.AccountId = acObj1.Id;
        conObj1.Role__c = 'Admin';
        conObj1.Email = 'Test@gmail.com';
        conObj1.CurrencyIsoCode = 'USD';
        insert conObj1;
        
        Opportunity opObj1 = new Opportunity();
        opObj1.CurrencyIsoCode = 'USD';
        opObj1.Name = 'Test Opportunity1';
        opObj1.AccountId = acObj1.Id;
        opObj1.Primary_Contact__c = conObj1.Id;
        opObj1.Region__c = 'UK';
        opObj1.Opportunity_Type__c = 'New';
        opObj1.License__c = 'SaaS';
        opObj1.Type = 'KeyedIn Projects';
        opObj1.Area_of_Interest__c = 'KeyedIn Projects;KeyedIn Enterprise;KeyedIn Adaptive Portfolio';
        opObj1.StageName = '1. Initiate';
        opObj1.Opportunity_Type__c = 'New';
        opObj1.License__c = 'SaaS';
        opObj1.ForecastCategoryName = 'Omitted';
        opObj1.CloseDate = Date.today().addDays(40);
        insert opObj1;
        
        PriceBook2 pbObj1 = new Pricebook2();
        pbObj1.isActive =true;
        pbObj1.Name ='KeyedIn Projects';
        
        insert pbObj1;
        
        Product2 prodObj1 = new Product2();
        prodObj1.isActive = true;
        prodObj1.Name = 'test Product1';
        prodObj1.ProductCode='KIE-ALL-LIC-STOR';
        prodObj1.Family ='KeyedIn Projects Software';
        insert prodObj1;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PriceBookEntry pbEntry1 = new PriceBookEntry();
        pbEntry1.CurrencyIsoCode = 'USD';
        pbEntry1.isActive = true;
        PbEntry1.Pricebook2Id = pricebookId;
        pbEntry1.Product2Id = prodObj1.Id;
        pbEntry1.UnitPrice = 5;
        insert pbEntry1;
        
        PriceBookEntry pbEntry2 = new PriceBookEntry();
        pbEntry2.CurrencyIsoCode = 'USD';
        pbEntry2.isActive = true;
        PbEntry2.Pricebook2Id = pbObj1.Id;
        pbEntry2.Product2Id = prodObj1.Id;
        pbEntry2.UnitPrice = 5;
        System.debug('pbEntry2==>'+pbEntry2);
        insert pbEntry2;
        
        //PriceBookEntry PBEntry;
        
        CustomLookupController.selectedProdWrapper wrp1 = new CustomLookupController.selectedProdWrapper();
        CustomLookupController.RecordsData selectedRecord =  new CustomLookupController.RecordsData();
        selectedRecord.label = 'Product test';
        selectedRecord.value = prodObj1.Id;
        selectedRecord.PBEntry = pbEntry2;
        wrp1.selectedRecord = selectedRecord;
        wrp1.Quantity = 4;
        
        Test.startTest();
        String response = '[{"selectedRecord":{"label":"KeyedIn Project Services Managed Service","PBEntry":{"Pricebook2Id":"'+pbObj1.Id+'","UnitPrice":1250,"Id":"'+pbEntry2.Id+'","Product2Id":"'+prodObj1.Id+'","Product2":{"Name":"KeyedIn Project Services Managed Service","Id":"'+prodObj1.Id+'"}},"value":"'+prodObj1.Id+'"},"Quantity":"3"}]';
        CustomLookupController.insertLineItems(response,opObj1.Id);
        Test.stopTest();
        
    }

}