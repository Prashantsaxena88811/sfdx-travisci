@isTest
public class CalculatePriceForEmmersionProduct_Test {
    @isTest
    public static void emmersionPricingCal_Test(){
        Product2 p1 = new Product2();
        p1.Name = 'Product Test1';
        p1.isActive = true;
        
        Product2 p2 = new Product2();
        p2.Name = 'Product Test1';
        p2.isActive = true;
        
        List<Product2> prodList = new List<Product2>();
        prodList.add(p1);
        prodList.add(p2);
        insert prodList;
        
        Emmersion_Pricing__c e1p1 = new Emmersion_Pricing__c();
        e1p1.Tier__c = 100;
        e1p1.Product__c = prodList[0].Id;
        e1p1.Annual_Price_Per_Test__c = 9;
        e1p1.Monthly_Price_Per_Test__c = 10;
        
        Emmersion_Pricing__c e2p1 = new Emmersion_Pricing__c();
        e2p1.Tier__c = 250;
        e2p1.Product__c =  prodList[1].Id;
        e2p1.Annual_Price_Per_Test__c = 8.55;
        e2p1.Monthly_Price_Per_Test__c = 9.50;
        
        List<Emmersion_Pricing__c> emmersionPriceList = new List<Emmersion_Pricing__c>();
        emmersionPriceList.add(e1p1);
        emmersionPriceList.add(e2p1);
        insert emmersionPriceList;
        
        Test.startTest();
        CalculatePriceForEmmersionProduct.emmersionPricingCal(new List<String>{String.valueOf(prodList[0].Id),String.valueOf(prodList[1].Id)});
        Test.stopTest();
    }
    @isTest
    public static void insertLineItems_Test(){
        Account ac = new Account();
        ac.Name = 'Test Account1';
        insert ac;
        
        Opportunity op1 = new Opportunity();
        op1.Name ='test op1';
        op1.CloseDate =  date.today();
        op1.AccountId =  ac.Id;
        op1.Type = 'New Logo';
        op1.StageName = 'Discovery';
        insert op1;
        
        Product2 p1 = new Product2();
        p1.Name = 'Product Test1';
        p1.isActive = true;
        
        Product2 p2 = new Product2();
        p2.Name = 'Product Test1';
        p2.isActive = true;
        List<Product2> prodList = new List<Product2>();
        prodList.add(p1);
        prodList.add(p2);
        insert prodList;
        
        Pricebook2 standardPricebook = new Pricebook2(
            
            Id = Test.getStandardPricebookId(),
            
            IsActive = true
            
        );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        
        Update standardPricebook;
        
        List<CalculatePriceForEmmersionProduct.selectedProdWrapper> selectedProdList = new List<CalculatePriceForEmmersionProduct.selectedProdWrapper>();
        for(Product2 prod  : prodList){
            CalculatePriceForEmmersionProduct.selectedProdWrapper OliList =  new CalculatePriceForEmmersionProduct.selectedProdWrapper();
            CalculatePriceForEmmersionProduct.selectedRecordcls selectedProd = new CalculatePriceForEmmersionProduct.selectedRecordcls();
            selectedProd.label = prod.Name;
            selectedProd.value = prod.Id;
            OliList.Price =  20;
            OliList.selectedRecord =  selectedProd;
            OliList.BillingTerm = 'Monthly';
            OliList.Quantity = 200;
            selectedProdList.add(OliList);
        }
        Test.startTest();
        CalculatePriceForEmmersionProduct.insertLineItems(JSON.serialize(selectedProdList) , String.valueOf(op1.Id));
        Test.stopTest();
    }
}