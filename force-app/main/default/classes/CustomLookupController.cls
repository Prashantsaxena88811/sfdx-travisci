public with sharing class CustomLookupController {
    
    public static void getProductFamilyMapping(){
        
        Map<String,Map<String, List<String> >> type_AreaOfInterestMap = new Map<String,Map<String, List<String> >>();
        
        Map<String,List<String>> AreaOfInterestToFamily_FamilyMap =  new Map<String,List<String>>();
    }
    
    @AuraEnabled
    public static List<RecordsData> fetchRecords(String opportunityId , String objectName, List<String> filterFieldList, String searchString, String value) {
        try {
            List<Opportunity> currentOp = new List<Opportunity>();
            currentOp = [Select Id,Type,Area_of_Interest__c,Region__c,CurrencyIsoCode from Opportunity where Id=:opportunityId];
            System.debug('currentOp==>'+currentOp);
            List<String> productFamilyList = new List<String>();
            String pbName = '';
            String ProductCodeClause = '';
            if(currentOp!=null && !currentOp.isEmpty()){
                if(currentOp[0].Type != null && currentOp[0].Type!=''){
                    List<String> areaOfInterestList  =  new List<String>();
                    if(currentOp[0].Area_of_Interest__c != null && currentOp[0].Area_of_Interest__c!=''){
                       areaOfInterestList =  currentOp[0].Area_of_Interest__c.split(';');
                    }
                    Set<String> areaOfInterestSet = new Set<String>();
                    for(String val :areaOfInterestList ){
                        areaOfInterestSet.add(val.toLowerCase());
                    }
                    if( currentOp[0].Type == 'KeyedIn Projects'){
                        pbName = 'KeyedIn Projects';
                        if(currentOp[0].Area_of_Interest__c != null && currentOp[0].Area_of_Interest__c!=''){
                            if(areaOfInterestSet.contains('KeyedIn Projects'.toLowerCase())){
                                productFamilyList.add('KeyedIn Projects Software');
                                productFamilyList.add('Keyedin Projects Services');
                            }
                            if(areaOfInterestSet.contains('KeyedIn Enterprise'.toLowerCase())){
                                productFamilyList.add('KeyedIn Enterprise Software');
                                productFamilyList.add('Keyedin Projects Services');
                            }
                            if(areaOfInterestSet.contains('KeyedIn Adaptive Portfolio'.toLowerCase())){
                                productFamilyList.add('KeyedIn Adaptive Portfolios Software');
                                productFamilyList.add('Keyedin Projects Services');
                            }
                        }
                        
                    }else if(currentOp[0].Type == 'KeyedIn Manufacturing-SMB'){
                        pbName = 'KeyedIn Manufacturing';
                        productFamilyList.add('KeyedIn Manufacturing Software');
                        productFamilyList.add('KeyedIn Manufacturing Services');
                        
                    }else if(currentOp[0].Type == 'KeyedIn Manufacturing-Sign Edition'){
                        pbName = 'KeyedIn Sign';
                        productFamilyList.add('KeyedIn Sign Services');
                        productFamilyList.add('Keyedin Sign Software');
                        
                    }
                    
                }
                if(currentOp[0].Region__c == 'US'){
                    ProductCodeClause = '(productcode like \'%USA%\' or productcode like \'%ALL%\')';
                }else if(currentOp[0].Region__c == 'UK'){
                    ProductCodeClause = '(productcode like \'%ROW%\' or productcode like \'%ALL%\')';
                }
            }
            System.debug('filterFieldList=>'+filterFieldList);
            List<RecordsData> recordsDataList = new List<RecordsData>();
            String filterField  = String.join( filterFieldList, ', ' ); 
            
            String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
            if(String.isNotBlank(value)) {
                query += ' WHERE Id = \''+ value + '\' LIMIT 49999';
            } else {
                filterField = '';
                for(Integer count = 0 ; count <filterFieldList.size(); count++){
                    if(count < filterFieldList.size()-1){
                        filterField = filterField+' '+filterFieldList[count]+' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' OR ';
                        
                    }else{
                        filterField = filterField+' '+filterFieldList[count]+' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' ';
                        
                    }
                }
                /* query += ' WHERE '+filterField+
' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\' LIMIT 49999';*/
                System.debug('productFamilyList=>'+productFamilyList);
                query += ' WHERE '+filterField+' AND '+ProductCodeClause+' AND Family IN:productFamilyList'+' And isActive=true'+' LIMIT 49999';
                System.debug('Final Query==>'+query);
            }
            List<Sobject> sobjectList  = new List<Sobject>();
            sobjectList = Database.query(query);
            if(objectName == 'Product2'){
                //Set<Set>
                List<PriceBOOk2> pb = new List<PriceBOOk2>();
                pb = [Select Id,(Select Id,Product2.Name,Product2Id from PricebookEntries where 
                                 Product2Id IN :sobjectList AND CurrencyIsoCode=:currentOp[0].CurrencyIsoCode AND isActive=true) from pricebook2 where Name=:pbName];
                System.debug('pb.PricebookEntries=>'+pb[0].PricebookEntries);
                Set<String> productIds = new Set<String>();
                for(PriceBOOk2 pbVal : pb) {
                    if(pbVal.PricebookEntries!=null && !pbVal.PricebookEntries.isEmpty()){
                        for(PricebookEntry pbObj : pbVal.PricebookEntries){
                            productIds.add(pbObj.Product2Id);
                        }
                        
                    }
                    
                }
                for(SObject s : sobjectList) {
                    if(productIds.contains(s.Id)){
                        recordsDataList.add( new RecordsData((String)s.get('Name'), (String)s.get('id')) ); 
                    }
                    
                }
            }
            /*for(SObject s : sobjectList) {
recordsDataList.add( new RecordsData((String)s.get('Name'), (String)s.get('id')) );
}*/
            
            System.debug('recordsDataList==>'+recordsDataList);
            return recordsDataList;
        } catch (Exception err) {
            System.debug('get exception on line number==>'+err.getLInenumber() + ' error is=>'+err.getMessage());
            if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
        }
    }
    @AuraEnabled 
    public static decimal getProductPrices(String OpportunityId,String productId){
        try{
            System.debug('OpportunityId=>'+OpportunityId);
            System.debug('productId=>'+productId);
            List<Opportunity> currentOp = new List<Opportunity>();
            currentOp = [Select Id,Type,Area_of_Interest__c,Region__c,CurrencyIsoCode from Opportunity where Id=:opportunityId];
            System.debug('currentOp==>'+currentOp);
            String pbName = '';
            
            if(currentOp!=null && !currentOp.isEmpty()){
                if(currentOp[0].Type != null && currentOp[0].Type!=''){
                       
                       if( currentOp[0].Type == 'KeyedIn Projects'){
                           pbName = 'KeyedIn Projects';
                       }else if(currentOp[0].Type == 'KeyedIn Manufacturing-SMB'){
                           pbName = 'KeyedIn Manufacturing';
                       }else if(currentOp[0].Type == 'KeyedIn Manufacturing-Sign Edition'){
                           pbName = 'KeyedIn Sign';
                       }
                   }
            }
            
            List<PriceBOOk2> pb = new List<PriceBOOk2>();
            pb = [Select Id,(Select Id,Product2Id,UnitPrice from PricebookEntries where 
                             CurrencyIsoCode=:currentOp[0].CurrencyIsoCode AND Product2Id=:productId AND isActive=true limit 1)
                  from pricebook2 where Name=:pbName];
            System.debug('pb.PricebookEntries=>'+pb[0].PricebookEntries);
            return pb[0].PricebookEntries[0].UnitPrice;
        } catch (Exception err) {
            System.debug('get exception on line number==>'+err.getLInenumber() + ' error is=>'+err.getMessage());
            if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
        }
    }
    @AuraEnabled 
    public static dataWrp getTypeFieldValue(String OpportunityId){
        System.debug('getTypeFieldValue==>'+OpportunityId);
        List<Opportunity> opp =  new List<Opportunity>();
        opp = [Select Id ,type,CurrencyIsoCode from Opportunity where Id=:OpportunityId];
        if(opp.isEmpty()){
            return null;
        }
        dataWrp dataWrpObj = new dataWrp();
        List<pickListDataWrp> pickListDataType = new List<pickListDataWrp>();
        List<pickListDataWrp> pickListDatacurrency = new List<pickListDataWrp>();
        Schema.DescribeFieldResult fieldResult = Opportunity.Type.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            if(opp[0].Type == p.getValue()){
                pickListDataType.add( new pickListDataWrp(p.getLabel(), p.getValue() ,  true) );
            }else{
                pickListDataType.add( new pickListDataWrp(p.getLabel(), p.getValue(),false) );
            }
            
        }
        
        fieldResult = Opportunity.CurrencyIsoCode.getDescribe();
        pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            if(opp[0].CurrencyIsoCode == p.getValue()){
                pickListDatacurrency.add( new pickListDataWrp(p.getLabel(), p.getValue(),true) );
                
            }else{
                pickListDatacurrency.add( new pickListDataWrp(p.getLabel(), p.getValue(),false) );  
            }
        }
        dataWrpObj.pickListDatacurrency = pickListDatacurrency;
        dataWrpObj.pickListDataType = pickListDataType;
        
        System.debug('pickListDatacurrency==>'+pickListDatacurrency);
        System.debug('pickListDataType==>'+pickListDataType);
        System.debug('dataWrpObj==>'+dataWrpObj);
        return dataWrpObj;
    }
    
    @AuraEnabled
    public static void insertLineItems(String SelectedProdList ,String OpportunityId){
        try{
            System.debug('SelectedProdList==>'+SelectedProdList);
            System.debug('OpportunityId==>'+OpportunityId);
            String pbName='';
            List<selectedProdWrapper> selectedProdWrapperList =  (List<selectedProdWrapper>)JSON.deserialize(SelectedProdList, List<selectedProdWrapper>.class);
            System.debug('selectedProdWrapperList--<>'+selectedProdWrapperList);
            Set<Id> selectedProductIds = new Set<Id>();
            for(selectedProdWrapper selectedProdWrapperObj : selectedProdWrapperList){
                selectedProductIds.add(selectedProdWrapperObj.selectedRecord.value);
            }
            
            List<Opportunity> currentOp = new List<Opportunity>();
            currentOp = [Select Id,Type,Area_of_Interest__c,Region__c,CurrencyIsoCode from Opportunity where Id=:opportunityId];
            System.debug('currentOp==>'+currentOp);
            
            if(currentOp[0].Type != null && currentOp[0].Type!=''){
                if( currentOp[0].Type == 'KeyedIn Projects'){
                    pbName = 'KeyedIn Projects';
                }else if(currentOp[0].Type == 'KeyedIn Manufacturing-SMB'){
                    pbName = 'KeyedIn Manufacturing';
                }else if(currentOp[0].Type == 'KeyedIn Manufacturing-Sign Edition'){
                    pbName = 'KeyedIn Sign';
                }
            }
            
            List<PricebookEntry> pbEntry = new  List<PricebookEntry>();
            pbEntry = [Select Id,Product2ID from pricebookEntry  where CurrencyIsoCode=:currentOp[0].CurrencyIsoCode 
                       AND Product2Id IN :selectedProductIds and pricebook2.Name =:pbName];
            Map<String,String> productToPB_EntryMap = new Map<String,String>();
            for(PricebookEntry pbObj : pbEntry ){
                if(!productToPB_EntryMap.containsKey(pbObj.Product2ID)){
                    productToPB_EntryMap.put(pbObj.Product2ID,pbObj.Id);
                }
            }
            System.debug('productToPB_EntryMap==>'+productToPB_EntryMap);
            List<OpportunityLineItem> OpportunityLineItemList = new List<OpportunityLineItem>();
            for(selectedProdWrapper selectProductObj :  selectedProdWrapperList){
                if(productToPB_EntryMap.containsKey(selectProductObj.selectedRecord.value)){
                    OpportunityLineItem oli = new OpportunityLineItem();
                    oli.OpportunityId = OpportunityId;
                    oli.PricebookEntryId = productToPB_EntryMap.get(selectProductObj.selectedRecord.value);
                    oli.UnitPrice = selectProductObj.Price;
                    oli.Quantity = selectProductObj.Quantity;
                    OpportunityLineItemList.add(oli);  
                }
                
            }
            if(OpportunityLineItemList!=null && !OpportunityLineItemList.isEmpty()){
                insert OpportunityLineItemList;
                System.debug('OpportunityLineItemList-->'+OpportunityLineItemList);
            }
        }catch(Exception err){
            System.debug('get exception on line number==>'+err.getLineNumber()+' error is =>'+err.getMessage());
            System.debug('get exception on line number==>'+err.getLInenumber() + ' error is=>'+err.getMessage());
            if ( false && String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                System.debug('**thwor exception**');
                throw new AuraHandledException(err.getMessage());
            }
        }
    }
    
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    public class pickListDataWrp {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public Boolean selected;
        public pickListDataWrp(String label, String value,Boolean selected) {
            this.label = label;
            this.value = value;
            this.selected = selected;
        }
    }
    
    public class dataWrp{
        @AuraEnabled public List<pickListDataWrp> pickListDataType;
        @AuraEnabled public List<pickListDataWrp> pickListDatacurrency;
        
    }
    public class selectedProdWrapper{
        @AuraEnabled
        public selectedRecordcls selectedRecord;
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