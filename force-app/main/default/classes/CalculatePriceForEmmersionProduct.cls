public class CalculatePriceForEmmersionProduct {
    @AuraEnabled
    public static Map<Id, List<Emmersion_Pricing__c>> emmersionPricingCal(List<String> selectedProIds){
        try{
            System.debug('selectedProIds-->'+selectedProIds);
            List<Emmersion_Pricing__c> emmersionPricingList = new List<Emmersion_Pricing__c>();
            emmersionPricingList = [Select Annual_Price_Per_Test__c,Monthly_Price_Per_Test__c,Product__c,Tier__c FROM Emmersion_Pricing__c
                                    where Product__c IN : selectedProIds  order by Tier__c asc];
            Map<Id, List<Emmersion_Pricing__c>> productToEmmersionPricingMap =  new Map<Id, List<Emmersion_Pricing__c>>();
            for( Emmersion_Pricing__c tierPrice : emmersionPricingList){
                if(!productToEmmersionPricingMap.containsKey(tierPrice.Product__c)){
                    productToEmmersionPricingMap.put(tierPrice.Product__c, new List<Emmersion_Pricing__c>());
                }
                productToEmmersionPricingMap.get(tierPrice.Product__c).add(tierPrice);
            }
            System.debug('productToEmmersionPricingMap-->'+productToEmmersionPricingMap);
            return productToEmmersionPricingMap;
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber() +' error is-->'+e.getMessage() );
            throw new AuraHandledException('Darn it! Something went wrong: ' + e.getMessage()); 
        }
        
        
    }
    @AuraEnabled
    public static void insertLineItems(String SelectedProdList ,String OpportunityId, String pricingType){
        try{
            List<Opportunity> opportunityRec = new List<Opportunity>();
            opportunityRec = [Select id,Annual_billing__c from Opportunity where Id=:OpportunityId];
            if(opportunityRec.isEmpty()){
                return;
            }
            System.debug('SelectedProdList-->'+SelectedProdList);
            List<selectedProdWrapper> selectedProdWrapperList =  (List<selectedProdWrapper>)JSON.deserialize(SelectedProdList, List<selectedProdWrapper>.class);
            System.debug('selectedProdWrapperList--<>'+selectedProdWrapperList);
            Set<Id> selectedProductIds = new Set<Id>();
            for(selectedProdWrapper selectedProdWrapperObj : selectedProdWrapperList){
                selectedProductIds.add(selectedProdWrapperObj.selectedRecord.value);
            }
            
            List<Pricebook2> idList = new List<Pricebook2>();            
            idList = [select id, name from Pricebook2 where isStandard = true limit 1];
            //fetch alreadt insert PB entries of standard Price book
            List<PricebookEntry> alreadyExistPB_Entries = new List<PricebookEntry>();
            alreadyExistPB_Entries = [Select Id ,isActive,Product2Id ,Pricebook2Id from PricebookEntry where Pricebook2Id=:idList[0].Id AND Product2Id IN : selectedProductIds ];
            List<PricebookEntry> update_InActive_Entries = new List<PricebookEntry>();
            for(PricebookEntry pbObj : alreadyExistPB_Entries){
                if(!pbObj.IsActive){
                    pbObj.IsActive = true;
                    update_InActive_Entries.add(pbObj);
                }
            }
            if(update_InActive_Entries!=null && !update_InActive_Entries.isEmpty()){
                update update_InActive_Entries;
                System.debug('update_InActive_Entries-->'+update_InActive_Entries);
            }
            // product to pricebook entry Id
            Map<Id,PricebookEntry> prod_To_PB_Map = new Map<Id,PricebookEntry>();
            // product alreadt exist in standardPB entries
            for(PricebookEntry pbObj : alreadyExistPB_Entries){
                prod_To_PB_Map.put( pbObj.Product2Id ,pbObj );
            }
            System.debug('prod_To_PB_Map-<>'+prod_To_PB_Map);
            List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
            
            for(selectedProdWrapper selectedProdWrapperObj : selectedProdWrapperList){
                if(!prod_To_PB_Map.keySet().contains(selectedProdWrapperObj.selectedRecord.value)){
                    PricebookEntry pbObj = new PricebookEntry();
                    pbObj.Product2Id = selectedProdWrapperObj.selectedRecord.value;
                    pbObj.Pricebook2Id = idList[0].Id;
                    pbObj.UnitPrice = 10;
                    pbObj.IsActive =  true;
                    pricebookEntryList.add(pbObj);  
                }
                
            }
            if(pricebookEntryList !=null && !pricebookEntryList.isEmpty()){
                insert pricebookEntryList;
                for(PricebookEntry pb_Entry :pricebookEntryList){
                    prod_To_PB_Map.put( pb_Entry.Product2Id ,pb_Entry );
                }
            }
            List<OpportunityLineItem> OpportunityLineItemList = new List<OpportunityLineItem>();
            for(selectedProdWrapper selectProductObj :  selectedProdWrapperList){
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.OpportunityId = OpportunityId;
                oli.PricebookEntryId = prod_To_PB_Map.get(selectProductObj.selectedRecord.value).Id;
                
                if(pricingType == 'Postpaid' || pricingType == 'Bulk Order'){
                    
                    if((double)selectProductObj.Price  == 0){
                        oli.UnitPrice =(double)selectProductObj.Price;
                    }else{
                        oli.UnitPrice = (double)selectProductObj.Price/selectProductObj.Quantity;
                    }
                }else{
                    oli.UnitPrice = selectProductObj.Price;
                    if(pricingType == 'Subscription' && opportunityRec[0].Annual_billing__c){
                        oli.Discount = 10;
                    }
                }
                //oli.Billing_Term__c = selectProductObj.BillingTerm;
                oli.Quantity = selectProductObj.Quantity;
                OpportunityLineItemList.add(oli);
            }
            if(OpportunityLineItemList!=null && !OpportunityLineItemList.isEmpty()){
                insert OpportunityLineItemList;
                System.debug('OpportunityLineItemList-->'+OpportunityLineItemList);
            }
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber() +' error is-->'+e.getMessage() );
            throw new AuraHandledException('Darn it! Something went wrong: '
                                           + e.getMessage()); 
            //return null;
        }
        
        
    }
    
    @AuraEnabled
    public static Map<Id,List<Emmersion_Pricing__c>> getAllPrices(List<String> selectedProIds , String pricingType){
        try{
            System.debug('*********getAllPrices********');
            System.debug('selectedProIds-->'+selectedProIds);
            String ss ='aaaaaaaaaaaaaaaaa';
            System.debug('aaaaaaaaaaaaaaaaa==>'+ss);
            System.debug('pricingType==>'+pricingType);
            //pricingType = pricingType;
            List<Emmersion_Pricing__c> emmersionPricingList = new List<Emmersion_Pricing__c>();
            if(pricingType == 'Postpaid'){
                emmersionPricingList = [Select Flat_Price__c,Monthly_Price_Per_Test__c,Product__c,Tier_From__c,Tier__c FROM Emmersion_Pricing__c
                                        where Product__c IN : selectedProIds AND Pricing_Type__c =:pricingType AND
                                        Flat_Price__c!=null AND Tier_From__c!=null AND Tier__c!=null order by Tier_From__c asc];
            }else{
                emmersionPricingList = [Select Flat_Price__c,Monthly_Price_Per_Test__c,Product__c,Tier_From__c,Tier__c FROM Emmersion_Pricing__c
                                        where Product__c IN : selectedProIds AND Pricing_Type__c =:pricingType AND
                                        Monthly_Price_Per_Test__c!=null AND Tier_From__c!=null AND Tier__c!=null  order by Tier_From__c asc];
            }
            
            
            Map<Id,List<Emmersion_Pricing__c>> productIDTOPricingMap = new Map<Id,List<Emmersion_Pricing__c>>();
            for(Emmersion_Pricing__c priceObj:emmersionPricingList){
                if(!productIDTOPricingMap.containsKey(priceObj.Product__c)){
                   productIDTOPricingMap.put(priceObj.Product__c,new List<Emmersion_Pricing__c>()); 
                }
                productIDTOPricingMap.get(priceObj.Product__c).add(priceObj);
            }
            System.debug('emmersionPricingList-->'+emmersionPricingList);
            return productIDTOPricingMap;
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber() +' error is-->'+e.getMessage() );
            throw new AuraHandledException('Darn it! Something went wrong: ' + e.getMessage()); 
        }
        
        
    }
    
    @AuraEnabled
    public static Map<String,PriceBookEntry> getAllStandardPrices(List<String> selectedProIds , String pricingType){
        try{
            System.debug('*********getAllStandardPrices********');
            List<PriceBookEntry> pb_entries = new List<PriceBookEntry>();
            pb_entries = [Select id,Product2Id,UnitPrice from PriceBookEntry where Product2Id IN:selectedProIds AND  PriceBook2.Name=:'Standard Price Book'  AND isActive=true];
            System.debug('pb_entries==>'+pb_entries);
            Map<String,PriceBookEntry> prodIdTOPrice_Map = new Map<String,PriceBookEntry>();
            for(PriceBookEntry pbEntry:pb_entries){
                prodIdTOPrice_Map.put(String.valueOf(pbEntry.Product2Id),pbEntry);
            }
            return prodIdTOPrice_Map;
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber() +' error is-->'+e.getMessage() );
            throw new AuraHandledException('Darn it! Something went wrong: ' + e.getMessage()); 
        }
    }
    
    public class selectedProdWrapper{
        @AuraEnabled
        public selectedRecordcls selectedRecord;
        @AuraEnabled
        public String BillingTerm;
        @AuraEnabled
        public Integer Quantity;
        @AuraEnabled
        public Decimal Price;
    }
    public class selectedRecordcls{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }
    
}