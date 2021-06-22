global class DQ_Discovery_CreateHouseHold_Accounts implements Database.Batchable<sObject>,Database.Stateful{
    
    global boolean isOneRecordCreated =  false;
    global boolean isOneConRecordUpdated =  false;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String accounthouseholdId = '012f4000000nLu0';
        String businessUnit = '012f4000000dA7N';
        String internaltionalChurch = '012f4000000dA7T';
        String query = 'SELECT Id,Name FROM contact where AccountId!=null AND Account.recordTypeId!=:accounthouseholdId AND Account.recordTypeId!=:businessUnit AND Account.recordTypeId!=:internaltionalChurch';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> conList) {
        try {
            system.debug(': Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
            List<Account> newHouseHold_AccountList = new List<Account>();
            List<npe5__Affiliation__c> affliaTionList = new List<npe5__Affiliation__c>();
            //List<Contact> contactListChunk = [Select id,AccountId,(Select id from npe5__Affiliations__r where isDirectAccountPresent__c =  true limit 1) from contact where Id IN :conList];
            List<Contact> contactListChunk;

            List<Contact> conTobeUpdated =  new List<Contact>();
            for(Contact conObj : contactListChunk){
                System.debug('conObj==>'+conObj);
                System.debug('isOneConRecordUpdated==>'+isOneConRecordUpdated);
                 System.debug('isOneRecordCreated==>'+isOneRecordCreated);
                if(!isOneConRecordUpdated){
                    isOneConRecordUpdated =  true;
                    Account newHouseHoldObj =  new Account();
                    newHouseHoldObj.Name = 'house holdAccount';
                    newHouseHoldObj.RecordTypeId = '012f4000000nLu0';
                    //newHouseHoldObj.BillingCountry = 'AFGHANISTAN';
                    newHouseHold_AccountList.add(newHouseHoldObj);
                    System.debug('Contact record updated==>'+conObj.Id);
                }
                if( !(conObj.npe5__Affiliations__r !=null && !conObj.npe5__Affiliations__r.isEmpty()) ){
                    System.debug(' create new affliation');
                    if(!isOneRecordCreated){
                        isOneRecordCreated =  true;
                        npe5__Affiliation__c affiliationObj = new npe5__Affiliation__c();
                        affiliationObj.npe5__Contact__c = conObj.Id;
                        affiliationObj.npe5__Organization__c = conObj.AccountId;
                        affiliationObj.npe5__Status__c = 'Current' ;
                        affliaTionList.add(affiliationObj);
                    } 
                }
            }
            system.debug('newHouseHold_AccountList=Size=>'+newHouseHold_AccountList.size());
            if(newHouseHold_AccountList!=null && !newHouseHold_AccountList.isEmpty()){
                insert newHouseHold_AccountList;
                system.debug('newHouseHold_AccountList==>'+newHouseHold_AccountList);
            }
            for(Integer i=0 ; i<contactListChunk.size() ;i++){
                if(i==0){
                    //contactListChunk[i].AccountId = newHouseHold_AccountList[0].Id;
                    System.debug(' contactListChunk[i].AccountId=>'+ contactListChunk[i].Id);
                    contact c = new contact();
                    c.Id = contactListChunk[i].Id;
                    c.AccountId = newHouseHold_AccountList[0].Id;
                    conTobeUpdated.add(c);
                }
            }
            system.debug('affliaTionList=Size=size=>'+affliaTionList.size());
            if(affliaTionList!=null && !affliaTionList.isEmpty()){
                insert affliaTionList;
                system.debug('affliaTionList==>'+affliaTionList);
            }
             system.debug('affliaTionList==>'+affliaTionList);
            System.debug('first condition'+contactListChunk!=null+' second condition'+!contactListChunk.isEmpty());
            if(conTobeUpdated!=null && !conTobeUpdated.isEmpty()){
                update conTobeUpdated;
                system.debug('conTobeUpdated==>'+conTobeUpdated);
            }
            /*if(contactListChunk!=null && !contactListChunk.isEmpty()){
                update contactListChunk;
                system.debug('contactListChunk==>'+contactListChunk);
            }*/
            
            
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber()+' error is=>'+e.getMessage());
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
}