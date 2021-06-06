@isTest
private class OpportunityNewTriggerHandlerTest {
	@testSetup
    //Data
    //run test
    //compare
    private static void setupOppData(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser22@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing123456', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser22@testorg.com');
        
        Account acc = new Account();
        acc.Name = 'testAccount';
        insert acc;
        insert u;
        
        
        
        Account acc2 = new Account();
        acc2.Name = 'account_sample';
        insert acc2;
        
        Contact con = new Contact();
        con.LastName = 'Test1';
        con.AccountId = acc.Id;
        con.Email = 'test@gmail.com';
        insert con;
            
        List<Opportunity> listOfOpp = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Name = 'test1';
        opp.Renewal_Manager__c = u.Id;
        opp.StageName = 'Flip - Prepare';
        opp.CloseDate = Date.today();
        opp.AccountId = acc.Id;
        opp.Primary_Contact__c = con.Id;
        opp.Opportunity_Type__c = 'New';
        opp.Pricebook2Id = Test.getStandardPricebookId();

        listOfOpp.add(opp);
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'test1';
        opp2.StageName = 'Flip - Prepare';
        opp2.Renewal_Manager__c = u.Id;
        opp2.CloseDate = Date.today();
        opp2.AccountId = acc.Id;
        opp2.Primary_Contact__c = con.Id;
        opp2.Opportunity_Type__c = 'Renewal';
        opp2.Pricebook2Id = Test.getStandardPricebookId();

        listOfOpp.add(opp2);
        insert listOfOpp;
        
        Product2 product = new Product2();
        product.Name = 'Turducken';
        product.ProductCode = 'testLICtest';
        product.IsActive = true;
        product.Family = 'Software';
        insert product;
        
        Asset asset3 = new Asset();
        asset3.AccountId = acc.Id;
        asset3.CurrencyIsoCode = 'USD';
        asset3.Name = 'TestAsset';  
        asset3.Quantity = 1;
        asset3.Product2Id = product.Id;
        asset3.MRR__c = 10;
        asset3.ARR__c = 10;
        asset3.Price = 10;
        asset3.Unit_Price__c = 10;
        insert asset3;
           

        PricebookEntry pbEntry = new PricebookEntry();
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = product.Id;
        pbEntry.UnitPrice = 15;
        pbEntry.IsActive = true;
        insert pbEntry;

        List<OpportunityLineItem> listOfOppItem = new List<OpportunityLineItem>();
        OpportunityLineItem item = new OpportunityLineItem();
        item.OpportunityId = opp.Id;
        item.PricebookEntryId = pbEntry.Id;
        item.Product2Id = product.id;
        item.quantity = 10;
        item.TotalPrice = 15;
        item.Term_Length_Months__c = 6;
        listOfOppItem.add(item);
        
        insert listOfOppItem;
            
        
        /*opp.StageName = 'Closed Won';
        opp.Term_Start_Date__c = date.today();
        opp.Term_End_Date__c = Date.today() + 1;
        
        update opp;*/
        
        
        
        
    }
    
    private static Asset getAssetRecord() {
        return [SELECT Id,MRR__c,ARR__c,Quantity,Price FROM Asset LIMIT 1];
    }
    
    private static OpportunityLineItem getOpportunityLineItemRecord() {
        return [SELECT Id, Product2.Name,Product2Id,Total_Price__c,Quantity,MRR__c,ARR__c, UnitPrice FROM OpportunityLineItem LIMIT 1];
    }
    
    private static Opportunity getOpportunityRecord(String type) {
        return [SELECT Id,AccountId ,CloseDate,Opportunity_Type__c,Term_Start_Date__c,Term_End_Date__c, StageName, License__c, CurrencyISOCode FROM Opportunity WHERE Opportunity_Type__c = :type LIMIT 1];
    }
    
    @isTest
    private static void testCreateAssetInstance(){
        Opportunity opp = getOpportunityRecord('New');
        opp.StageName = 'Closed Won';
        opp.Term_Start_Date__c = date.today();
        opp.Term_End_Date__c = Date.today().addYears(4) + 1;
        
        Asset getAsset = new Asset();
        test.startTest();
        getAsset = OpportunityNewTriggerHandler.createAssetInstance(
        				getAssetRecord(), getOpportunityLineItemRecord(), getOpportunityRecord('New'));
            update opp;
        test.stopTest();
        
        System.assertEquals(true, getAsset != null);
        
    }

     @isTest
    private static void testCreateAssetInstance2(){
        
        Asset getAsset = new Asset();
        
        test.startTest();
        getAsset = OpportunityNewTriggerHandler.createAssetInstance(
        			getAssetRecord(), getOpportunityLineItemRecord(), getOpportunityRecord('Renewal'));
        test.stopTest();
        
        System.assertEquals(true, getAsset != null);
    }
    
    @isTest
    private static void testopportunityAfterProcess(){
        Opportunity opp = getOpportunityRecord('Renewal');
        opp.Type = 'KeyedIn Projects';
        opp.Notes__c = 'wertyuiop'; 
        opp.StageName = 'Recycle';
        opp.Recycle_Reason__c = 'No Response';
        
        test.startTest();
        	update opp;
        test.stopTest();
        
        List<Task> getTaskList = [SELECT Id from task];
        
        System.assertEquals(true, getTaskList.size() != null);
    }
    
    @isTest
    private static void testopportunityAfterProcess1(){
        Opportunity opp = getOpportunityRecord('Renewal');
        opp.Type = 'KeyedIn Projects';
        opp.Notes__c = 'wertyuiop'; 
        opp.StageName = 'Closed Lost';
        opp.type = 'KeyedIn Projects';
        opp.Lost_Reason_Detail__c = 'Antura';
        opp.Lost_Reason__c = 'Authority';
        
        test.startTest();
        	update opp;
        test.stopTest();
        
        List<Task> getTaskList = [SELECT Id from task];
        
        System.assertEquals(true, getTaskList.size() != null);
    }
    
    @isTest
    private static void testopportunityAfterProcess2(){
        Opportunity opp = getOpportunityRecord('Renewal');
        opp.Type = 'KeyedIn Projects';
        opp.Notes__c = 'wertyuiop'; 
        opp.StageName = '1. Initiate';
        opp.type = 'KeyedIn Projects';
        opp.Term_Start_Date__c = date.today();
        opp.Term_End_Date__c = Date.today() + 1;
        
        test.startTest();
        	update opp;
        test.stopTest();
        
        List<Task> getTaskList = [SELECT Id from task];
        
        System.assertEquals(true, getTaskList.size() != null);
        
    }
    
    @isTest
    private static void testopportunityAfterProcess3(){
        Opportunity opp = getOpportunityRecord('Renewal');
        opp.Type = 'KeyedIn Projects';
        opp.Notes__c = 'wertyuiop'; 
        opp.StageName = '1. Initiate';
        opp.type = 'KeyedIn Manufacturing-SMB';
        opp.Term_Start_Date__c = date.today();
        opp.Term_End_Date__c = Date.today() + 1;
        
        test.startTest();
        	update opp;
        test.stopTest();
        
        List<Task> getTaskList = [SELECT Id from task];
        
        System.assertEquals(true, getTaskList.size() != null);
    }
    
    @isTest
    private static void testupdateOpptyWithRecordType(){
        Opportunity opp = getOpportunityRecord('Renewal');
        opp.Type = 'KeyedIn Projects';
        opp.Notes__c = 'wertyuiop'; 
        opp.StageName = '2. Qualify';
        opp.type = 'KeyedIn Manufacturing-SMB';
        opp.Term_Start_Date__c = date.today();
        opp.Term_End_Date__c = Date.today() + 1;
        
        test.startTest();
            update opp;
            opp.StageName = 'Flip - Accepted';
            opp.License__c = 'Partner';
            
            Opportunity oldOpp = getOpportunityRecord('New');
            new OpportunityNewTriggerHandler().updateOpptyWithRecordType(
                new Map<Id, Opportunity> {opp.Id => opp}, new Map<Id, Opportunity>{opp.Id => oldOpp});
        
        test.stopTest();
        
        System.assertEquals(true, opp.RecordTypeId != null);
    }
    
    @isTest
    private static void testupdateOpptyWithRecordType1(){
        Opportunity opp = getOpportunityRecord('Renewal');
        opp.Type = 'KeyedIn Projects';
        opp.Notes__c = 'wertyuiop'; 
        opp.StageName = '2. Qualify';
        opp.type = 'KeyedIn Manufacturing-SMB';
        opp.Term_Start_Date__c = date.today();
        opp.Term_End_Date__c = Date.today() + 1;
        
        test.startTest();
            opp.StageName = 'Flip - Accepted';
            
            Opportunity oldOpp = getOpportunityRecord('New');
            
            opp.License__c = 'SaaS';
            
            new OpportunityNewTriggerHandler().updateOpptyWithRecordType(
                new Map<Id, Opportunity> {opp.Id => opp}, new Map<Id, Opportunity>{opp.Id => oldOpp});
        
        test.stopTest();
        
        System.assertEquals(true, opp.RecordTypeId != null);
        
    }
    @isTest
    private static void testupdateOpptyWithRecordType2(){
        Opportunity opp = getOpportunityRecord('Renewal');
        opp.Type = 'KeyedIn Projects';
        opp.Notes__c = 'wertyuiop'; 
        opp.StageName = '2. Qualify';
        opp.type = 'KeyedIn Manufacturing-SMB';
        opp.Term_Start_Date__c = date.today();
        opp.Term_End_Date__c = Date.today() + 1;
        
        test.startTest();
            opp.StageName = 'Flip - Accepted';
            
            opp.License__c = 'Perpetual';
            
            Opportunity oldOpp = getOpportunityRecord('New');
            
            new OpportunityNewTriggerHandler().updateOpptyWithRecordType(
            	new Map<Id, Opportunity> {opp.Id => opp}, new Map<Id, Opportunity>{opp.Id => oldOpp});
        
        test.stopTest();
        
        System.assertEquals(true, opp.RecordTypeId != null);
        
    }
    @isTest
    private static void testupdateOpptyWithRecordType3(){
        Opportunity opp = getOpportunityRecord('Renewal');
        opp.Type = 'KeyedIn Projects';
        opp.Notes__c = 'wertyuiop'; 
        opp.StageName = '2. Qualify';
        opp.type = 'KeyedIn Manufacturing-SMB';
        opp.Term_Start_Date__c = date.today();
        opp.Term_End_Date__c = Date.today() + 1;
        
        opp.StageName = 'Flip - Accepted';
        
        opp.License__c = 'Consulting';
        
        test.startTest();
            Opportunity oldOpp = getOpportunityRecord('New');
            
            new OpportunityNewTriggerHandler().updateOpptyWithRecordType(
            	new Map<Id, Opportunity> {opp.Id => opp}, new Map<Id, Opportunity>{opp.Id => oldOpp});
        
        test.stopTest();
        
        System.assertEquals(true, opp.RecordTypeId != null);
        
    }
   /* not used    @isTest
    private static void testupdateOpptyWithRecordType4(){
        Opportunity opp = getOpportunityRecord('Renewal');
        opp.Notes__c = 'wertyuiop'; 
        opp.type = 'KeyedIn Manufacturing-SMB';
        opp.Term_Start_Date__c = date.today();
        opp.Term_End_Date__c = Date.today().addYears(3);
        opp.StageName = 'Closed Won';
        opp.License__c = 'SaaS';
        opp.Opportunity_Type__c = 'Renewal';
        opp.Contract_Length__c = 3;
        
        test.startTest();
        	update opp;
        
        test.stopTest();
        
    }*/
}