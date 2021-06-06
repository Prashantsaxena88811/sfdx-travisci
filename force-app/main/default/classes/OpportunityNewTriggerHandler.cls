public with sharing class OpportunityNewTriggerHandler {
    public static Boolean runTriggerOnce = false;
    public OpportunityNewTriggerHandler() {
    }
    
    public void OnBeforeInsertEventFire(){
        opportunityBeforeProcess();
    }
    
    public void OnBeforeUpdateEventFire(Map<Id,Opportunity> new_oppty_map,Map<Id,Opportunity> old_oppty_map){
        updateOpptyWithRecordType(new_oppty_map,old_oppty_map);
        opportunityBeforeProcess();
    }
    
    public void OnAfterUpdateEventFire(Map<Id,Opportunity> new_oppty_map,Map<Id,Opportunity> old_oppty_map){
        createAssetOnClosedWon(new_oppty_map,old_oppty_map);
        createRenewalOpportunity(new_oppty_map,old_oppty_map);
        createAnniversaryTask(new_oppty_map,old_oppty_map);
        
        if(new_oppty_map.size() == 1){
            for(Opportunity opty : new_oppty_map.values()){
                if(opty.StageName == 'Closed Won' && old_oppty_map.get(opty.Id).StageName != 'Closed Won'){
                    Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                    if(!isSandbox || Test.isRunningTest()){
                        sendOpportunityNotificationToSlack(opty.Id);   
                    }
                }
            }
        }
        opportunityAfterProcess();
    }
    
    public void updateOpptyWithRecordType(Map<Id,Opportunity> new_oppty_map,Map<Id,Opportunity> old_oppty_map){
        Id partner_Recruiting_recordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Partner Recruiting').getRecordTypeId();
        Id software_recordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Software').getRecordTypeId();
        Id service_recordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        
        for(Opportunity opty : new_oppty_map.values()){
            if(opty.StageName != null && (old_oppty_map.get(opty.Id).StageName == 'Flip - Submitted' ||  old_oppty_map.get(opty.Id).StageName == 'Flip - Prepare') && opty.StageName == 'Flip - Accepted'){
                system.debug('StageName and License Name ' +opty.StageName+ '>>>>> ' +opty.License__c);
                if(opty.License__c != null && opty.License__c == 'Partner'){
                    opty.RecordTypeId = partner_Recruiting_recordType;
                }else if(opty.License__c != null && opty.License__c == 'SaaS'){
                    opty.RecordTypeId = software_recordType;
                }else if(opty.License__c != null && opty.License__c == 'Perpetual'){
                    opty.RecordTypeId = software_recordType;
                }else if(opty.License__c != null && opty.License__c == 'Consulting'){
                    opty.RecordTypeId = service_recordType;
                }
            }
        }
    }
     
    public void createAssetOnClosedWon(Map<Id,Opportunity> new_oppty_map,Map<Id,Opportunity> old_oppty_map){
        
        Set<Id> oppIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        List<Asset> upsertAssetList = new List<Asset>();
        Map<String,List<OpportunityLineItem>> oppVsOppLineItemMap = new Map<String,List<OpportunityLineItem>>();
        
        for(Id oppId : new_oppty_map.keySet()){
            if(
                new_oppty_map.get(oppId).StageName != null && 
                new_oppty_map.get(oppId).StageName != old_oppty_map.get(oppId).StageName &&
                new_oppty_map.get(oppId).StageName == 'Closed Won')
            {
                oppIds.add(oppId);
                accountIds.add(new_oppty_map.get(oppId).AccountId);
            }
        }
        System.debug('oppIds==='+oppIds);
        
        if(!oppIds.isEmpty()){
            
            List<Opportunity> applicableOppList = [SELECT Id, AccountId, CloseDate, Opportunity_Type__c, 
                                                   Term_Start_Date__c, Term_End_Date__c, CurrencyISOCode,
                                                   (SELECT Id, MRR__c, ARR__c, OpportunityId, Product2Id, 
                                                    Total_Price__c, Quantity, Product2.Name, UnitPrice 
                                                    FROM OpportunityLineItems
                                                    WHERE Product2.ProductCode like '%LIC%' OR Product2.ProductCode like '%INTG%')
                                                   FROM Opportunity
                                                   WHERE Id = :oppIds];
            
            List<Asset> existingAssetList = [SELECT Id, AccountId, Product2Id, Quantity, MRR__c, 
                                             ARR__c, Price, Unit_Price__c, Subscription_End_Date__c
                                             FROM Asset 
                                             WHERE AccountId =: accountIds
                                             AND Historic__c = False];
            
            System.debug('existingAssetList===****************' + existingAssetList);
            
            Map<String,Map<String, Map<Decimal, Asset>>> accountVsProductVsUnitPriceAssetMap = 
                                      new Map<String,Map<String,Map<Decimal, Asset>>>();
            
            Map<String, List<Asset>> assetByAccountId = new Map<String, List<Asset>>();
            if(!existingAssetList.isEmpty()){
                for(Asset ast :existingAssetList){
                    if(!accountVsProductVsUnitPriceAssetMap.containsKey(ast.AccountId)){
                        accountVsProductVsUnitPriceAssetMap.put(ast.AccountId, new Map<String,Map<Decimal, Asset>>());
                    }
                    if(!accountVsProductVsUnitPriceAssetMap.get(ast.AccountId).containsKey(ast.Product2Id)){
                        accountVsProductVsUnitPriceAssetMap.get(ast.AccountId).put(ast.Product2Id, new Map<Decimal, Asset>());
                    }
                    accountVsProductVsUnitPriceAssetMap.get(ast.AccountId).get(ast.Product2Id).put(ast.Unit_Price__c,ast);   
                    
                    
                    if(!assetByAccountId.containsKey(ast.AccountId)){
                        assetByAccountId.put(ast.AccountId, new List<Asset>());
                    }
                    assetByAccountId.get(ast.AccountId).add(ast);
                }
                System.debug('accountVsProductAssetMap==='+accountVsProductVsUnitPriceAssetMap);
            }
            
            
            List<Asset> assetListToUpsert = new List<Asset>();
            Set<Id> assetAccountIds = new Set<Id>();
            Map<Id, Set<String>> validAssetIdByAccountId = new Map<Id, Set<String>>();
            List<Asset> assetListToReset = new List<Asset>();
            
            Set<Id> oppProdIds = new Set<Id>();
            for(Opportunity opp : applicableOppList){
                oppProdIds = new Set<Id>();
                validAssetIdByAccountId.put(opp.AccountId, new Set<String>());
                
                for(OpportunityLineItem oppLI : opp.OpportunityLineItems){
                    oppProdIds.add(oppLI.Product2Id);
                    if(opp.Opportunity_Type__c == 'Renewal'){
                        assetListToUpsert.add(createAssetInstance(null, oppLI, opp));
                    }else{
                        Asset existingAsset;
                        if(accountVsProductVsUnitPriceAssetMap.containsKey(opp.AccountId) && 
                           accountVsProductVsUnitPriceAssetMap.get(opp.AccountId).containsKey(oppLI.Product2Id) &&
                           accountVsProductVsUnitPriceAssetMap.get(opp.AccountId).get(oppLI.Product2Id).containsKey(oppLI.UnitPrice))
                        {
                            existingAsset = accountVsProductVsUnitPriceAssetMap.get(opp.AccountId).get(oppLI.Product2Id).get(oppLI.UnitPrice);
                            validAssetIdByAccountId.get(opp.AccountId).add(existingAsset.Id);
                        }
                        assetListToUpsert.add(createAssetInstance(existingAsset, oppLI, opp));
                    }
                }
                
                if(opp.Opportunity_Type__c == 'Renewal' 
                   && opp.AccountId != null 
                   && assetByAccountId.containsKey(opp.AccountId))
                {
                    for(Asset ast : assetByAccountId.get(opp.AccountId)){
                        if(oppProdIds.contains(ast.Product2Id) && ast.Subscription_End_Date__c <= opp.Term_End_Date__c){
                            ast.Historic__c = True;
                            assetListToReset.add(ast);    
                        }
                    }
                }
            }
            
            
            /*
            for(String accountId : accountVsProductVsUnitPriceAssetMap.keySet()){
                for(String productId : accountVsProductVsUnitPriceAssetMap.get(accountId).keySet()){
                    for(Asset ast : accountVsProductVsUnitPriceAssetMap.get(accountId).get(productId).values()){
                        if(validAssetIdByAccountId.containsKey(accountId) &&
                           !validAssetIdByAccountId.get(accountId).contains(ast.Id))
                        {
                            ast.Historic__c = True;
                            assetListToReset.add(ast);
                        }
                    }
                }
            }*/
            
            if(assetListToUpsert.size() > 0){
                upsert assetListToUpsert;
            }
            if(assetListToReset.size() > 0){
                update assetListToReset;
            }            
        }
    }
    
    public static Asset createAssetInstance(Asset existingAsset, OpportunityLineItem oppLI, Opportunity opp){
        
        Asset ast = new Asset();
        ast.Name = oppLI.Product2.Name;
        ast.AccountId = opp.AccountId;
        ast.Product2Id = oppLI.Product2Id;
        ast.Status = 'Installed';
        ast.Price = oppLI.Total_Price__c;
        ast.Quantity =  oppLI.Quantity;
        ast.PurchaseDate = opp.CloseDate;
        ast.InstallDate = opp.CloseDate;
        ast.Purchase_Opportunity__c = opp.id;
        ast.MRR__c = oppLI.MRR__c;
        ast.ARR__c = oppLI.ARR__c;
        ast.Unit_Price__c = oppLI.UnitPrice;
        ast.CurrencyISOCode = opp.CurrencyISOCode;
        
        if(existingAsset != null){
            ast.Id = existingAsset.Id;
            if(opp.Opportunity_Type__c != 'Renewal'){
                ast.MRR__c += existingAsset.MRR__c;
                ast.ARR__c += existingAsset.ARR__c;
                ast.Quantity += existingAsset.Quantity;
                ast.Price += existingAsset.Price;    
            }
        }
        if(opp.Opportunity_Type__c == 'New' || opp.Opportunity_Type__c == 'Renewal'){
            ast.Subscription_Start_Date__c = opp.Term_Start_Date__c;
            ast.Subscription_End_Date__c = opp.Term_End_Date__c;
        }
        return ast;
    }

    @future(callout = true)
    public static void sendOpportunityNotificationToSlack(Id oppId){
        Opportunity opp = [SELECT Id, Account.Name, Type, Area_of_Interest__c, convertCurrency(MRR__c), convertCurrency(ARR__c), 
                           convertCurrency(Services_MRR__c), convertCurrency(Services_ARR__c), 
                           convertCurrency(Services_New__c), convertCurrency(TCV__c), 
                           convertCurrency(Contract_Year_Value__c), 
                           Contract_Length__c, Owner.Name,
                           (SELECT Id, Product2.Name from OpportunityLineItems)
                           FROM Opportunity
                           WHERE Id = :oppId];
        
        String messageText = 'OpAll, \\n \\n';
        messageText += 'Please find the attached executed agreement for '+opp.Account.Name + '\\n \\n';
        messageText += '*Here are the deal terms:* \\n \\n';
        messageText += 'Line of Business: '+formatString(opp.Type)+'\\n';
        messageText += 'Area of Interest: '+formatString(opp.Area_of_Interest__c)+'\\n';
        messageText += 'MRR: USD '+numberToString(opp.MRR__c)+'\\n';
        messageText += 'ARR: USD '+numberToString(opp.ARR__c)+'\\n';
        messageText += 'Services MRR: USD '+numberToString(opp.Services_MRR__c)+'\\n';
        messageText += 'Services ARR: USD '+numberToString(opp.Services_ARR__c)+'\\n';
        messageText += 'Total Services: USD '+numberToString(opp.Services_New__c)+'\\n';
        messageText += 'TCV: USD '+numberToString(opp.TCV__c)+'\\n';
        messageText += 'First Year Value: USD '+numberToString(opp.Contract_Year_Value__c)+'\\n';
        messageText += 'Term: '+numberToString(opp.Contract_Length__c)+' Months \\n';
        messageText += 'Sales Rep: '+formatString(opp.Owner.Name)+'\\n';
        messageText += 'Products and Services Sold: \\n';
        
        for(OpportunityLineItem oppLI : opp.OpportunityLineItems){
            messageText += formatString(oppLI.Product2.Name) + '\\n';
        }
        
        messageText += '\\n\\n';
        messageText += URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id;
        
        messageText = messageText.replace('\"', '\\"');
        System.debug(messageText);
        //System.assert(false, messageText);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Label.Slack_EndPoint);
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json');
        request.setBody('{ "text": "'+messageText+'" }');
        if(!Test.isRunningTest()){
            HttpResponse response = http.send(request);
            System.debug(response);
            System.debug(response.getStatus());
            System.debug(response.getBody());
        }
    }
    
    private static String numberToString(Decimal d){
        if(d == null){
            return '';
        }
        List<String> args = new String[]{'0','number','#,###.##'};
        String ds = String.format(d.format(), args);
        return ds;
    }
    
    private static String formatString(String s){
       return String.isBlank(s) ? '' : s;
    }
    
    Public static User userObj = [SELECT Id, Division, UserRole.Name FROM User
                                  WHERE Id = :UserInfo.getUserId()];
    
    public static void opportunityBeforeProcess(){
      
        Map<ID,Schema.RecordTypeInfo> rt_Map = Opportunity.sObjectType.getDescribe().getRecordTypeInfosById();

        Set<Id> accountIds = new Set<Id>();
        for(Opportunity opp : (List<Opportunity>)Trigger.new){
            accountIds.add(opp.AccountId);
        }
        
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name FROM Account
                                                             WHERE Id IN :accountIds]);
        
        for(Opportunity opp : (List<Opportunity>)Trigger.new){
            Account acc = accountMap.get(opp.AccountId);
            Opportunity oldOpp;
            if(Trigger.isUpdate){
               oldOpp = (Opportunity)Trigger.oldMap.get(opp.Id);
            }
            if(Trigger.isInsert){
                if(opp.Opportunity_Type__c != 'Renewal'){
                    opp.CloseDate = opp.CloseDate.addDays(120);
                }
            }
            if(Trigger.isUpdate){
                if(opp.Contract_Length__c != oldOpp.Contract_Length__c ||
                   opp.Implementation_Days__c != oldOpp.Implementation_Days__c ||
                   opp.Services_New__c != oldOpp.Services_New__c ||
                   opp.MRR__c != oldOpp.MRR__c ||
                   opp.Daily_Rate__c != oldOpp.Daily_Rate__c)
                {
                  opp.Cash_On_Delivery__c = (opp.ARR__c != null ? opp.ARR__c : 0) + (opp.Services_New__c != null ? opp.Services_New__c : 0);  
                }
            }
            if(userObj.UserRole.Name == 'BDR' || userObj.UserRole.Name == 'UK'){
                opp.Original_Flip_Date3_New__c = System.now();
            }            
            if(opp.Override_Flip_Date__c == null){
                opp.Override_Flip_Date__c = Date.valueOf(opp.CreatedDate);
            }
            
            if(acc != null && (acc.Name.contains('UK | ABM') || acc.Name.contains('US | ABM'))){
                opp.Account_Name_Shortened__c = acc.Name.SubStringAfter('M |');
            }
            if(opp.Type == 'KeyedIn Manufacturing-Sign Edition'){
                opp.Area_of_Interest_Shortened__c = 'Sign';
            }
            if(acc != null && acc.Name != null && !acc.Name.contains('UK | ABM')){
                opp.Account_Name_Shortened__c = acc.Name.length() > 10 ? acc.Name.SubString(0, 9) : acc.Name;
            }
            if(opp.Name != null){
                opp.Name = opp.Account_Name_Shortened__c + '-';
                if(opp.Opportunity_Type__c != null){
                  opp.Name += opp.Opportunity_Type__c+'-';
                }
                if(opp.Opp_Number__c != null){
                  opp.Name += opp.Opp_Number__c+'-';
                }
                if(opp.RecordTypeId != null){
                  opp.Name += rt_Map.get(opp.RecordTypeId).getName()+'-';
                }
                if(opp.Type != null){
                  opp.Name += opp.Type;
                }
            }
            
            if(Trigger.isUpdate){
                if(opp.OwnerId != oldOpp.OwnerId){
                    opp.Renewal_Manager__c = opp.OwnerId;
                    
                    if(opp.Renewal_Manager__c != Null && opp.Opportunity_Type__c == 'New' && 
                       opp.Override_Renewal_Manager__c == False && opp.StageName != '1. Initiate')
                    {
                        opp.OwnerId = opp.Renewal_Manager__c;
                    }
                }
            }
            
            if( (opp.StageName == '1. Initiate' || 
               opp.StageName == '2. Qualify' ||
               opp.StageName == '3. Pre-Demo' ||
               opp.StageName == '4. SQO' ||
               opp.StageName == '5. De-brief' ||
               opp.StageName == '6. Final Shortlist / Demo #2' ||
               opp.StageName == '7. Chosen Vendor' ||
               opp.StageName == '8. Estimation / Proposal' ||
               opp.StageName == '9. Terms / SOW' ||
               opp.StageName == '10. Contract Sign Off' ) &&
               opp.Override_Renewal_Manager__c == False
              ){
                  opp.Renewal_Manager__c = opp.OwnerId;
              }
            
            if(Trigger.isUpdate){
                if(opp.StageName == 'Warming Queue' && oldOpp.StageName != 'Warming Queue'){
                    opp.Date_of_Flip_Recyc_or_WQ__c = opp.LastModifiedDate;
          opp.Warning_Queue_Date__c = Date.today();
                }
            }
        }
    }
    
    public static void opportunityAfterProcess(){
        
        Map<ID,Schema.RecordTypeInfo> rt_Map = Opportunity.sObjectType.getDescribe().getRecordTypeInfosById();
        
        Set<Id> accountIds = new Set<Id>();
        for(Opportunity opp : (List<Opportunity>)Trigger.new){
            accountIds.add(opp.AccountId);
        }
        
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name, BillingCountry FROM Account
                                                            WHERE Id IN :accountIds]);
        
        List<Task> taskListToInsert = new List<Task>();
        List<Account> accountListToUpdate = new List<Account>();
        for(Opportunity opp : (List<Opportunity>)Trigger.new){
            Account acc = accountMap.get(opp.AccountId);
            Opportunity oldOpp;
            if(Trigger.isUpdate){
                oldOpp = (Opportunity)Trigger.oldMap.get(opp.Id);
                if(opp.OwnerId != oldOpp.OwnerId){
                    acc.OwnerId = opp.OwnerId;
                }
                if(opp.StageName == '1. Initiate' && oldOpp.StageName != '1. Initiate')
                {
                    if(opp.Type == 'KeyedIn Projects' && opp.Notes__c != null || opp.Description != null)
                    {
                        taskListToInsert.add(createTask('New KIP Flip Submitted Alert Email Email Sent',
                                                        opp.OwnerId, 'Completed', Date.today(), opp.Id, null));
                    }else if(opp.Type == 'KeyedIn Manufacturing-SMB' || opp.Type == 'KeyedIn Manufacturing-Sign Edition')
                    {
                        taskListToInsert.add(createTask('Inform Oppty Owner of New Flip_Mfg Email Sent',
                                                        opp.OwnerId, 'Completed', Date.today(), opp.Id, null));
                    } 
                }
                if(opp.StageName == '2. Qualify' && oldOpp.StageName != '2. Qualify')
                {
                    if(opp.Type == 'KeyedIn Projects' && userObj.Division == 'KIP UK')
                    {
                        taskListToInsert.add(createTask('KIP UK Opportunity Approval Email Sent',
                                                        opp.OwnerId, 'Completed', Date.today(), opp.Id, null));
                    }else if(opp.Type == 'KeyedIn Projects' && userObj.Division == 'KIP US')
                    {
                        taskListToInsert.add(createTask('KIP US Opportunity Approval Email Sent',
                                                        opp.OwnerId, 'Completed', Date.today(), opp.Id, null));
                    }
                }
                if(opp.StageName == 'Recycle' && oldOpp.StageName != 'Recycle')
                {
                    taskListToInsert.add(createTask('Create a follow-up plan',
                                                    opp.CreatedById, 'Not Started', Date.today().addDays(1), opp.Id, 'High'));
                    if(opp.Type == 'KeyedIn Projects'){
                        if(acc.BillingCountry == 'United States' ||
                           acc.BillingCountry == 'Canada' ||
                           acc.BillingCountry == 'Mexico' ||
                           acc.BillingCountry == 'Australia' ||
                           acc.BillingCountry == 'New Zealand' )
                        {
                            taskListToInsert.add(createTask('KIP US Recycled Opportunity Email Sent',
                                                            opp.OwnerId, 'Not Started', Date.today(), opp.Id, null));
                        }else{
                            taskListToInsert.add(createTask('KIP UK Recycled Opportunity Email Sent',
                                                            opp.OwnerId, 'Not Started', Date.today(), opp.Id, null));
                        }
                    }
                }
                if(opp.StageName == 'Closed Lost' && oldOpp.StageName != 'Closed Lost'){
                    if(opp.Opportunity_Type__c == 'Renewal')
                    {
                        acc.Active_Customer__c = false;
                        acc.Type = 'Former Customer';
                    }
                    if(opp.Type == 'KeyedIn Projects')
                    {
                        taskListToInsert.add(createTask('Opportunity Closed Email Sent',
                                                        opp.OwnerId, 'Not Started', Date.today(), opp.Id, null));
                    }
                }
                if(opp.StageName == 'Closed Won' && oldOpp.StageName != 'Closed Won'){
                    if(acc.Name.contains('test')){
                        // Do nothing
                    }else if(acc.Name.contains('keyed')){
                        // Do nothing
                    }else{
                        taskListToInsert.add(createTask('Closed Won Email Email Sent',
                                                        opp.OwnerId, 'Not Started', Date.today(), opp.Id, null));
                        acc.Deployment_Method__c = 'SaaS';
                        acc.Product_Most_Recently_Purchased__c = opp.Type;
                        acc.Active_Customer__c = True;
                        //acc.Customer_Renewal_Date__c = opp.Term_End_Date__c;
                        acc.Type = 'Customer';
                    }
                }
                
                accountListToUpdate.add(acc);
            }
        }
        if(accountListToUpdate.size() > 0){
            update accountListToUpdate;
        }
        if(taskListToInsert.size() > 0){
            insert taskListToInsert;
        }
    }
    
    public static Task createTask(String subject, String ownerId, String status, 
                                  Date activityDate, String whatId, String priority)
    {
        Task t = new Task();
        t.Subject = subject;
        t.OwnerId = ownerId;
        t.Status = status;
        t.ActivityDate = activityDate;
        t.WhatId = whatId;
        if(String.isNotBlank(priority)) t.Priority = priority;
        return t;
    }
    

    public static void createRenewalOpportunity(Map<Id,Opportunity> new_oppty_map, Map<Id,Opportunity> old_oppty_map){
        List<Opportunity> validOpportunities = new List<Opportunity>();
        Set<Id> accountIds = new Set<Id>();
        for(Opportunity opp : (List<Opportunity>)Trigger.new){
            Opportunity oldOpp = (Opportunity)Trigger.oldMap.get(opp.Id);
            if((opp.StageName != oldOpp.StageName || 
                opp.License__c != oldOpp.License__c ||  
                 opp.Opportunity_Type__c != oldOpp.Opportunity_Type__c)
                && opp.StageName == 'Closed Won' && opp.License__c == 'SaaS' && 
                 (opp.Opportunity_Type__c == 'New' || opp.Opportunity_Type__c == 'Renewal'))
            {
                validOpportunities.add(opp);
                accountIds.add(opp.AccountId);
            }
        }
        
        if(validOpportunities.size() > 0){
            
            List<Opportunity> newOppList = new List<Opportunity>();
            for(Opportunity opp : validOpportunities){
                Opportunity newOpp = new Opportunity();
                newOpp.CloseDate = opp.Term_End_Date__c;
                newOpp.Name = opp.Account_Name_Shortened__c + '-Renewal';
                newOpp.StageName = '1. Initiate';
                newOpp.AccountId = opp.AccountId;
                newOpp.License__c = 'SaaS';
                newOpp.Opportunity_Type__c = 'Renewal';
                newOpp.OwnerId = opp.Renewal_Manager__c;
                newOpp.Primary_Contact__c = opp.Primary_Contact__c;
                newOpp.Region__c = opp.Region__c;
                newOpp.Renewal_Manager__c = opp.Renewal_Manager__c;
                newOpp.Term_Start_Date__c = opp.Term_End_Date__c.addDays(1);
                newOpp.Traffic_Medium__c  = 'Other';
                newOpp.Traffic_Source__c = 'Other';
                newOpp.Pricebook2Id = opp.Pricebook2Id;
                newOpp.Type = opp.Type;
                newOpp.Area_of_Interest__c = opp.Area_of_Interest__c;
                newOpp.Billing_Contact__c = opp.Billing_Contact__c;
                newOpp.Contract_Length__c = opp.Contract_Length__c;
                newOpp.CurrencyISOCode = opp.CurrencyISOCode;
                if(opp.Contract_Length__c != null){
                  newOpp.Term_End_Date__c = newOpp.Term_Start_Date__c.addMonths(Integer.valueOf(opp.Contract_Length__c)).addDays(-1);    
                }
                newOppList.add(newOpp);
            }
            if(newOppList.size() > 0){
                insert newOppList;
            }
            
            Map<Id, Account> accountById = new Map<Id, Account>([SELECT Id, Active_Customer__c,
                                                                 (SELECT Id, Product2Id, Quantity, Price, 
                                                                  Term__c, Unit_Price__c, Subscription_Start_Date__c,
                                                                  Subscription_End_Date__c
                                                                  FROM Assets
                                                                  WHERE Historic__c = False)
                                                                 FROM Account
                                                                 WHERE Id IN :accountIds]);
            
            Set<Id> productIds =  new Set<Id>();
            List<Account> accListToUpdate = new List<Account>();
            for(Account acc : accountById.values()){
                if(acc.Active_Customer__c == False){
                    acc.Active_Customer__c = True;
                    accListToUpdate.add(acc);
                }
                for(Asset ast : acc.Assets){
                   productIds.add(ast.Product2Id); 
                }
            }
            if(accListToUpdate.size() > 0){
                update accListToUpdate;
            }
            
            List<PricebookEntry> pbeList = [SELECT Id, Name, CurrencyIsoCode, Pricebook2Id, Product2Id 
                                            FROM PriceBookEntry 
                                            WHERE Product2Id in: productIds];
            
            Map<Id, Map<String, Map<Id, PricebookEntry>>> pbeMap = new Map<Id, Map<String, Map<Id, PricebookEntry>>>();
            for(PricebookEntry pbe : pbeList){
                if(!pbeMap.containsKey(pbe.Pricebook2Id)){
                    pbeMap.put(pbe.Pricebook2Id, new Map<String, Map<Id, PricebookEntry>>());
                }
                if(!pbeMap.get(pbe.Pricebook2Id).containsKey(pbe.CurrencyIsoCode)){
                    pbeMap.get(pbe.Pricebook2Id).put(pbe.CurrencyIsoCode, new Map<Id, PricebookEntry>());
                }
                pbeMap.get(pbe.Pricebook2Id).get(pbe.CurrencyIsoCode).put(pbe.Product2Id, pbe);
            }
            
            
            List<OpportunityLineItem> oppLIs = new List<OpportunityLineItem>();
            OpportunityLineItem oppLI;
            for(Opportunity opp : newOppList){
                Account acc = accountById.get(opp.AccountId);
                if(acc != null && acc.Assets != null && acc.Assets.size() > 0){
                    for(Asset ast : acc.Assets){
                        oppLI = new OpportunityLineItem();
                        oppLI.Quantity = ast.Quantity;
                        oppLI.Product2Id = ast.Product2Id;
                        oppLI.UnitPrice = ast.Unit_Price__c;
                        oppLI.Term_Length_Months__c = ast.Term__c;
                        oppLI.Term_Start_Date__c = ast.Subscription_Start_Date__c;
                        oppLI.Term_End_Date__c = ast.Subscription_End_Date__c;
                        oppLI.OpportunityId = opp.Id;
                        oppLI.Renewal_Asset__c = ast.Id;
                        if(pbeMap.containsKey(opp.Pricebook2Id) && pbeMap.get(opp.Pricebook2Id).containsKey(opp.CurrencyISOCode)
                           && pbeMap.get(opp.Pricebook2Id).get(opp.CurrencyISOCode).containsKey(ast.Product2Id)){
                            oppLI.PricebookEntryId = pbeMap.get(opp.Pricebook2Id).get(opp.CurrencyISOCode).get(ast.Product2Id).Id;
                        }
                        oppLIs.add(oppLI);
                    }
                }
            }
            //System.assert(false, oppLIs);
            if(oppLIs.size() > 0){
                insert oppLIs;
            }
        }
    }
    
    public static void createAnniversaryTask(Map<Id,Opportunity> new_oppty_map, Map<Id,Opportunity> old_oppty_map){
        //List to hold the opportunity
        List<Opportunity> oppList = new List<Opportunity>();
        
        for(Opportunity opp : (List<Opportunity>)Trigger.new){
            Opportunity oldOpp = (Opportunity)Trigger.oldMap.get(opp.Id);
            if(opp.StageName != oldOpp.StageName && opp.StageName == 'Closed Won'
               && (opp.Opportunity_Type__c == 'New' || opp.Opportunity_Type__c == 'Renewal') ){
                oppList.add(opp);
            }
        }
        
        //Size check for the Opp
        if(oppList.size() > 0){
            List<Task> taskToBeInsert = new List<Task>();
            for(Opportunity opp : [Select ID, OwnerId, Primary_Contact__c, Term_Start_Date__c, Term_End_Date__c, AccountId,
                                   Account.Name, Account.OwnerId From Opportunity Where ID IN: oppList]){
                Integer noOfYear = 1;
                Date anniversaryDate;
                do{ 
                    anniversaryDate = opp.Term_Start_Date__c.addYears(noOfYear);
                    if(anniversaryDate > opp.Term_End_Date__c)
                        break;
                    Task annTask = new Task();
                    annTask.Subject = 'Engage with '+opp.Account.Name+' for multi-year deal anniversary';
                    annTask.WhoId = Opp.Primary_Contact__c;
                    annTask.Status = 'Not Started';
                    annTask.Type = 'Multi-Year Anniversary';
                    annTask.Priority = 'Normal';
                    annTask.WhatId = Opp.Id;
                    annTask.OwnerID = opp.Account.OwnerId;
                    annTask.ActivityDate = anniversaryDate;
                    annTask.ReminderDateTime = DateTime.newInstance(anniversaryDate.year(),
                                                                    anniversaryDate.month(),
                                                                    anniversaryDate.day(), 08, 00, 00);
                    annTask.IsReminderSet = true;
                    taskToBeInsert.add(annTask);
                    noOfYear++;
                }while(anniversaryDate != opp.Term_End_Date__c.addDays(1));
            }
            
            //Check for the taskToBeInsert
            if(taskToBeInsert.size() > 0){
                TaskUtil.stopTrigger = true;
                insert taskToBeInsert;
            }
        }
    }
}