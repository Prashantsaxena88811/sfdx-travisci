global  class DQ_RelatedLIst_Check_On_Household implements Database.Batchable<sObject>,Database.Stateful{
    global Integer AccountTeamMembers = 0;
    global Integer ActivityHistories = 0;
    global Integer attachments = 0;
    global Integer Customer_Balances_by_Entity = 0;
    global Integer Digital = 0;
    global Integer notes = 0;
    global Integer OpenActivities = 0;
    global Integer opportunities = 0;
    global Integer Partial_Soft_Credits = 0;
    global Integer orders = 0;
    global Integer npsp_Opportunities = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String accounthouseholdId_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='HH_Account'].Id;
        //String usOrganization_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='US_Organization'].Id;
        Date purgeBeforeDate = Date.newInstance(2020, 10, 1);
        Set<String> exclude_recordTypeIds =  new set<String>{accounthouseholdId_TypeId};
            String query = 'SELECT Id,Name,AccountId,Account.RecordType.Name FROM contact where  createddate<:purgeBeforeDate AND Account.recordTypeId IN :exclude_recordTypeIds and AccountID!=null AND pi__campaign__c = NUll AND To_be_deleted6__c = true AND Account.All_Contact_to_be_Deleted__c = true  ';
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext bc, List<Contact> contactChunk){
        Set<Id> accountIds =  new Set<Id>();
        for(contact conObj : contactChunk){
            accountIds.add(conObj.AccountId);
        }
        Date ignoreActivityDate = Date.newInstance(2015, 12, 31);
        List<Account> accountList = new List<Account>();
        accountList = [Select Id,NoRelatedList__c,
                       (Select Id from Digital_Curriculum_Expirations__r limit 1),
                       (Select Id from AccountTeamMembers limit 1),
                       (Select Id from OpenActivities limit 1),
                       (Select Id from orders limit 1),
                       (Select Id from opportunities limit 1),
                       (Select Id from notes limit 1),
                       (Select Id from attachments limit 1),
                       (Select Id from Partial_Soft_Credits__r limit 1),
                       (Select Id from npsp__Opportunities__r limit 1),
                       (Select Id from ActivityHistories where createddate >: ignoreActivityDate limit 1),
                       (Select Id from Customer_Balances_by_Entity__r where Balance__c>0 AND Balance__c!=null limit 1)
                       from Account where ID IN :accountIds];
        
        List<Account> accountToBeUpdated =  new List<Account>();
        for(Account accountObj : accountList){
            Boolean isRelatedListPresent = false;
            if(accountObj.Digital_Curriculum_Expirations__r !=  null && !accountObj.Digital_Curriculum_Expirations__r.isEmpty()){
                System.debug('accountObj-------.Digital_Curriculum_Expirations__r='+accountObj.Digital_Curriculum_Expirations__r);
                isRelatedListPresent = true;
                Customer_Balances_by_Entity = Customer_Balances_by_Entity +1;
            }
            if(accountObj.AccountTeamMembers !=  null && !accountObj.AccountTeamMembers.isEmpty()){
                System.debug('accountObj-------.AccountTeamMembers='+accountObj.AccountTeamMembers);
                isRelatedListPresent = true;
                AccountTeamMembers = AccountTeamMembers+1;
            }
            if(accountObj.OpenActivities !=  null && !accountObj.OpenActivities.isEmpty()){
                System.debug('accountObj-------.OpenActivities='+accountObj.OpenActivities);
                isRelatedListPresent = true;
                OpenActivities = OpenActivities +1;
                
            }
            if(accountObj.orders !=  null && !accountObj.orders.isEmpty()){
                System.debug('accountObj-------.orders='+accountObj.orders);
                isRelatedListPresent = true;
                orders =  orders +1;
            }
            if(accountObj.opportunities !=  null && !accountObj.opportunities.isEmpty()){
                System.debug('accountObj-------.opportunities='+accountObj.opportunities);
                isRelatedListPresent = true;
                opportunities =  opportunities +1;
            }
            if(accountObj.notes !=  null && !accountObj.notes.isEmpty()){
                System.debug('accountObj-------.notes='+accountObj.notes);
                isRelatedListPresent = true;
                notes = notes +1;
                
            }
            if(accountObj.attachments !=  null && !accountObj.attachments.isEmpty()){
                System.debug('accountObj-------.attachments='+accountObj.attachments);
                isRelatedListPresent = true;
                attachments =  attachments +1;
                
            }
            if(accountObj.Partial_Soft_Credits__r !=  null && !accountObj.Partial_Soft_Credits__r.isEmpty()){
                System.debug('accountObj-------.Partial_Soft_Credits__r='+accountObj.Partial_Soft_Credits__r);
                isRelatedListPresent = true;
                Partial_Soft_Credits = Partial_Soft_Credits + 1;
                
            }
            if(accountObj.ActivityHistories !=  null && !accountObj.ActivityHistories.isEmpty()){
                System.debug('accountObj-------.ActivityHistories='+accountObj.ActivityHistories);
                isRelatedListPresent = true;
                ActivityHistories =  ActivityHistories +1;
                
            }
            if(accountObj.Customer_Balances_by_Entity__r !=  null && !accountObj.Customer_Balances_by_Entity__r.isEmpty()){
                System.debug('accountObj-------.Customer_Balances_by_Entity__r='+accountObj.Customer_Balances_by_Entity__r);
                isRelatedListPresent = true;
                Customer_Balances_by_Entity = Customer_Balances_by_Entity + 1;
                
            }
            if(accountObj.npsp__Opportunities__r !=  null && !accountObj.npsp__Opportunities__r.isEmpty()){
                System.debug('accountObj-------.npsp_Opportunities__r='+accountObj.npsp__Opportunities__r);
                isRelatedListPresent = true;
                npsp_Opportunities = npsp_Opportunities + 1;
                
            }
            if(!isRelatedListPresent){
                Account acc = new Account();
                acc.Id = accountObj.Id;
                acc.NoRelatedList__c = true;
                accountToBeUpdated.add(acc);
            }
            
            
            
        }
        
        if(accountToBeUpdated !=null && !accountToBeUpdated.isEmpty()){
            update accountToBeUpdated;
        }
    }
    global void finish(Database.BatchableContext bc){
        DQ_Count_Account__c dq =  new DQ_Count_Account__c();
        dq.AccountTeamMembers__c = AccountTeamMembers;
        dq.ActivityHistories__c = ActivityHistories;
        dq.attachments__c = attachments;
        dq.Digital__c = Digital;
        dq.notes__c = notes;
        dq.OpenActivities__c = OpenActivities;
        dq.opportunities__c = opportunities;
        dq.orders__c = orders;
        dq.Partial_Soft_Credits__c = Partial_Soft_Credits;
        dq.Customer_Balances_by_Entity__c = Customer_Balances_by_Entity;
        dq.npsp_Opportunities__c = npsp_Opportunities;
        dq.Name = 'RelatedList Count1';
        insert dq;
    }
}