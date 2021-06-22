global class DQ_Create_HH_ACCOUNT implements Database.Batchable<sObject>,Database.Stateful{
    
    // Create household Account for each contact associated with US account AND create affiliation Record
    global String HH_Account_recordTypeId = '';
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String US_Org_Account_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='US_Organization'].Id;
        HH_Account_recordTypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='HH_Account'].Id;
        //String query = 'SELECT Id,Name FROM contact where AccountId!=null AND Account.recordTypeId=:org_Account_TypeId';
        //String query = 'SELECT Id,Name,AccountId FROM Contact where AccountId!=NUll AND Account.RecordTypeId=:US_Org_Account_TypeId AND (AccountId=\'001f400000DCNSk\' OR AccountId=\'001f400000DCVjb\')';
        String query ='';
        if(test.isRunningTest()){
            query = 'SELECT Id,Name,AccountId FROM Contact where AccountId!=NUll AND Account.RecordTypeId=:US_Org_Account_TypeId ';
        }else{
            query = 'SELECT Id,Name,AccountId FROM Contact where AccountId!=NUll AND Account.RecordTypeId=:US_Org_Account_TypeId Limit 1';
        } 
        
            
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> conChunk) {
        try {
            List<npe5__Affiliation__c> new_AffliationList = new List<npe5__Affiliation__c>();
            List<Account> new_HH_AccountList = new List<Account>();
            List<Contact> conList = new List<Contact>();
            conList = [Select Id,Name,AccountId,(Select Id from npe5__Affiliations__r where isAccountSame__c = true Limit 1 ) from contact where Id IN :conChunk];
            //List<Contact> contactToBeUpdated = new List<>();
            System.debug('conList==>'+conList);
            for(Contact con:conList){
                //create household account for each contact
                Account accObj = new Account();
                accObj.Name = con.Name + ' Household';
                accObj.RecordTypeId  = HH_Account_recordTypeId;
                new_HH_AccountList.add(accObj);
                
                //create affiliation with the old US Account , 
                //only if there is no affiliation already with the same US account
                if(con.npe5__Affiliations__r.isEmpty()){
                    npe5__Affiliation__c affliationObj = new npe5__Affiliation__c();
                    affliationObj.npe5__Organization__c = con.AccountId;
                    affliationObj.npe5__Contact__c = con.Id;
                    new_AffliationList.add(affliationObj);   
                }
                
            }
            // insert newly create household
            insert new_HH_AccountList;
            System.debug('new_HH_AccountList==>'+new_HH_AccountList);
            
            
            for(Integer count=0;count<conList.size();count++){
                // assign the new HH Account Id to Contact
                conList[count].AccountId = new_HH_AccountList[count].Id;
            }
            
            
            update conList;
            System.debug('conList-updated->'+conList);
            if(!new_AffliationList.isEmpty()){
                Insert new_AffliationList;  
                System.debug('new_AffliationList==>'+new_AffliationList);
            }
            
            
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber()+' error is=>'+e.getMessage());
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
}