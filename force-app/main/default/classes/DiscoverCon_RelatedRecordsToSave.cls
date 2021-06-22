global class DiscoverCon_RelatedRecordsToSave implements Database.Batchable<sObject>,Database.Stateful{
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String accounthouseholdId_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='HH_Account'].Id;
        String businessUnit_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='Business_Unit'].Id;
        String internaltionalChurch_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='International_Church'].Id;
        String canadaChurch_TypeId = [Select Id,name,developername from Recordtype where SobjectType='Account'  and developername='Canada_Church'].Id;
        
        Set<String> exclude_recordTypeIds =  new set<String>{accounthouseholdId_TypeId,businessUnit_TypeId,internaltionalChurch_TypeId,canadaChurch_TypeId};
            //String query = 'SELECT Id,Name FROM contact where Account.recordTypeId!=:accounthouseholdId AND Account.recordTypeId!=:businessUnit AND Account.recordTypeId!=:internaltionalChurch limit 10';
            String query = 'SELECT Id,Name,Account.RecordType.Name FROM contact where Account.recordTypeId NOT IN :exclude_recordTypeIds and AccountID!=null AND pi__campaign__c = NUll AND In_Keycloak__c = NULL limit 10';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> contactListChunk) {
       system.debug(': Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
        
        List<Contact> contactList = new List<Contact>();
        contactList = [Select id , name ,Email,Gigya_UID__c,Constituent_Id__c,Account.CreatedDate,Account.lastModifiedDate,Account.RecordType.name,CreatedDate,lastModifiedDate,
                       (Select id,lastModifiedDate from ActivityHistories order by lastmodifieddate desc limit 1),
                       (Select id,lastModifiedDate from OpenActivities order by lastmodifieddate desc limit 1),
                       (Select id,lastModifiedDate from TT_Credits__r order by lastmodifieddate desc limit 1),
                       (Select id,lastModifiedDate from dsfs__DocuSign_Status__r order by lastmodifieddate desc limit 1),
                       (Select id,lastModifiedDate from npe4__Relationships__r order by lastmodifieddate desc limit 1),
                       (Select id,lastModifiedDate from attachments order by lastmodifieddate desc limit 1),
                       (Select id,lastModifiedDate from notes order by lastmodifieddate desc limit 1),
                       (Select Id,lastModifiedDate from Order_Contact_Roles__r order by lastmodifieddate desc limit 1),
                       (Select Id,lastModifiedDate from npe5__Affiliations__r order by lastmodifieddate desc limit 1),
                       (Select Id,lastModifiedDate from Opportunities__r order by lastmodifieddate desc limit 1),
                       (Select Id,lastModifiedDate from CampaignMembers order by lastmodifieddate desc limit 1),
                       (Select Id,lastModifiedDate from R00N50000001IDTvEAO__r order by lastmodifieddate desc limit 1),
                       (Select Id,lastModifiedDate from Membership_Acceptances__r order by lastmodifieddate desc limit 1),
                       
                       (Select Id,lastModifiedDate from dsfs__R00NS0000000WUMyMAO__r order by lastmodifieddate desc limit 1),
                       /*(Select Id,lastModifiedDate from WE_FW8_NP__SearchResult__r order by lastmodifieddate desc limit 1) ,*/
                       (Select Id,lastModifiedDate from Group_Contact_Contacts__r order by lastmodifieddate desc limit 1)
                       
                        ,
                       (Select Id,lastModifiedDate from Accounts1__r order by lastmodifieddate desc limit 1)  ,
                       (Select Id,lastModifiedDate from Accounts__r order by lastmodifieddate desc limit 1)  ,
                       (Select Id,lastModifiedDate from npe01__Organizations__r order by lastmodifieddate desc limit 1)  ,
                       (Select Id,lastModifiedDate from dsfs__DocuSign_Envelope_Recipient__r order by lastmodifieddate desc limit 1)  ,
                       (Select Id,lastModifiedDate from npe4__Relationships1__r order by lastmodifieddate desc limit 1)  ,
                       (Select Id,lastModifiedDate from Leads__r order by lastmodifieddate desc limit 1)  ,
                       (Select Id,lastModifiedDate from Membership_Acceptances1__r order by lastmodifieddate desc limit 1)  ,
                       (Select Id,lastModifiedDate from npsp__Honoree_Opportunities__r order by lastmodifieddate desc limit 1)  ,
                       (Select Id,lastModifiedDate from npsp__Notification_Opportunities__r order by lastmodifieddate desc limit 1)  ,
                       (Select Id,lastModifiedDate from npsp__Opportunities__r order by lastmodifieddate desc limit 1)  ,
                       (Select Id,lastModifiedDate from Opportunities1__r order by lastmodifieddate desc limit 1)
                         ,
                       (Select Id,lastModifiedDate from pi__Category_Contact_Scores__r order by lastmodifieddate desc limit 1)   ,
                       (Select Id,lastModifiedDate from npsp__Partial_Soft_Credits__r order by lastmodifieddate desc limit 1)   ,
                       (Select Id,lastModifiedDate from Club__r order by lastmodifieddate desc limit 1)
                       
                       from contact where Id IN :contactListChunk];
        System.debug('contactList-->'+contactList);
        Boolean isRelatedListPresent = false;
        
        List<TEST_OBJ__c> testObjList = new List<TEST_OBJ__c>();
        for(contact con : contactList){
           
            TEST_OBJ__c testObj = new TEST_OBJ__c();
            isRelatedListPresent = false;
            if(con.npe5__Affiliations__r !=  null && !con.npe5__Affiliations__r.isEmpty()){
                System.debug('con-------.npe5__Affiliations__r='+con.npe5__Affiliations__r);
                isRelatedListPresent = true;
                testObj.Affiliations__c = con.npe5__Affiliations__r[0].LastmodifiedDate;
                
            }
            if( con.Order_Contact_Roles__r !=  null && !con.Order_Contact_Roles__r.isEmpty()){
                System.debug('con-------.Order_Contact_Roles__r='+con.Order_Contact_Roles__r );
                isRelatedListPresent = true;
                testObj.Order_Contact_Roles__c = con.Order_Contact_Roles__r[0].LastmodifiedDate;
                
            }
            if( con.Opportunities__r !=  null && !con.Opportunities__r.isEmpty()){
                System.debug('con-------.Opportunities__r='+con.Opportunities__r );
                isRelatedListPresent = true;
                testObj.Opportunities__c = con.Opportunities__r[0].LastmodifiedDate;
                
            }
            if( con.CampaignMembers !=  null && !con.CampaignMembers.isEmpty()){
                System.debug('con-------.CampaignMembers='+con.CampaignMembers );
                isRelatedListPresent = true;
                testObj.CampaignMembers__c = con.CampaignMembers[0].LastmodifiedDate;
                
            }
            if( con.R00N50000001IDTvEAO__r !=  null  && !con.R00N50000001IDTvEAO__r.isEmpty()){
                System.debug('con-------.R00N50000001IDTvEAO__r='+con.R00N50000001IDTvEAO__r);
                isRelatedListPresent = true;
                testObj.Awards__c  =con.R00N50000001IDTvEAO__r[0].LastmodifiedDate;
                
            }
            if(con.Membership_Acceptances__r !=  null && !con.Membership_Acceptances__r.isEmpty()){
                System.debug('con-------.Membership_Acceptances__r='+con.Membership_Acceptances__r );
                isRelatedListPresent = true;
                testObj.Membership_Acceptances__c = con.Membership_Acceptances__r[0].LastmodifiedDate;
                
            }
           
            if( con.ActivityHistories !=  null && !con.ActivityHistories.isEmpty()){
                System.debug('con-------.ActivityHistories='+con.ActivityHistories );
                isRelatedListPresent = true;
                testObj.ActivityHistories__c =con.ActivityHistories[0].LastmodifiedDate;
                
                
            }
            if(con.OpenActivities !=  null && !con.OpenActivities.isEmpty()){
                System.debug('con-------.OpenActivities='+con.OpenActivities );
                isRelatedListPresent = true;
                testObj.OpenActivities__c = con.OpenActivities[0].LastmodifiedDate;
                
            }
            if( con.TT_Credits__r !=  null && !con.TT_Credits__r.isEmpty()){
                System.debug('con-------.TT_Credits__r='+con.TT_Credits__r );
                isRelatedListPresent = true;
                testObj.TT_Credits__c = con.TT_Credits__r[0].LastmodifiedDate;
                
            }
            if( con.dsfs__DocuSign_Status__r !=  null && !con.dsfs__DocuSign_Status__r.isEmpty()){
                System.debug('con.dsfs__DocuSign_Status__r='+con.dsfs__DocuSign_Status__r );
                isRelatedListPresent = true;
                testObj.DocuSign_Status__c = con.dsfs__DocuSign_Status__r[0].LastmodifiedDate;
                
            }
            if( con.npe4__Relationships__r !=  null && !con.npe4__Relationships__r.isEmpty()){
                System.debug('con.npe4__Relationships__r='+con.npe4__Relationships__r );
                isRelatedListPresent = true;
                testObj.Relationships__c = con.npe4__Relationships__r[0].LastmodifiedDate;
                
            }
            if( con.attachments !=  null && !con.attachments.isEmpty()){
                System.debug('con-------.attachments='+con.attachments );
                isRelatedListPresent = true;
                testObj.attachments__c  = con.attachments[0].LastmodifiedDate;
                
            }
            if( con.notes !=  null && !con.notes.isEmpty()){
                System.debug('con-------.notes='+con.notes );
                isRelatedListPresent = true;
                testObj.notes__c  =con.notes[0].LastmodifiedDate;
                
            }
            //
            /*if( con.WE_FW8_NP__SearchResult__r !=  null && !con.WE_FW8_NP__SearchResult__r.isEmpty()){
                System.debug('con.WE_FW8_NP__SearchResult__r='+con.WE_FW8_NP__SearchResult__r );
                isRelatedListPresent = true;
                testObj.SearchResult__c = con.WE_FW8_NP__SearchResult__r[0].LastmodifiedDate;
                
            }*/
            if( con.dsfs__R00NS0000000WUMyMAO__r !=  null && !con.dsfs__R00NS0000000WUMyMAO__r.isEmpty()){
                System.debug('con-------.dsfs__R00NS0000000WUMyMAO__r='+con.dsfs__R00NS0000000WUMyMAO__r );
                isRelatedListPresent = true;
                testObj.Docusign_Recepient_Status__c  = con.dsfs__R00NS0000000WUMyMAO__r[0].LastmodifiedDate;
                
            }
            if( con.Group_Contact_Contacts__r !=  null && !con.Group_Contact_Contacts__r.isEmpty()){
                System.debug('con-------.Group_Contact_Contacts__r='+con.Group_Contact_Contacts__r );
                isRelatedListPresent = true;
                testObj.Group_Contact_Contacts__c =con.Group_Contact_Contacts__r[0].LastmodifiedDate;
                
            }
            /**/
            if( con.Accounts1__r !=  null && !con.Accounts1__r.isEmpty()){
                System.debug('con-------.Accounts1__r='+con.Accounts1__r );
                isRelatedListPresent = true;
                testObj.Account_Applicant__c =con.Accounts1__r[0].LastmodifiedDate;
                
            }if( con.Accounts__r !=  null && !con.Accounts__r.isEmpty()){
                System.debug('con-------.Accounts__r='+con.Accounts__r );
                isRelatedListPresent = true;
                testObj.Account_Commander__c =con.Accounts__r[0].LastmodifiedDate;
                
            }if( con.npe01__Organizations__r !=  null && !con.npe01__Organizations__r.isEmpty()){
                System.debug('con-------.npe01__Organizations__r='+con.npe01__Organizations__r );
                isRelatedListPresent = true;
                testObj.Account_one2oneContact__c =con.npe01__Organizations__r[0].LastmodifiedDate;
                
            }if( con.dsfs__DocuSign_Envelope_Recipient__r !=  null && !con.dsfs__DocuSign_Envelope_Recipient__r.isEmpty()){
                System.debug('con-------.dsfs__DocuSign_Envelope_Recipient__r='+con.dsfs__DocuSign_Envelope_Recipient__r );
                isRelatedListPresent = true;
                testObj.DocuSign_Envelope_Recipient__c = con.dsfs__DocuSign_Envelope_Recipient__r[0].LastmodifiedDate;
                
            }if( con.npe4__Relationships1__r !=  null && !con.npe4__Relationships1__r.isEmpty()){
                System.debug('con-------.npe4__Relationships1__r='+con.npe4__Relationships1__r );
                isRelatedListPresent = true;
                testObj.Relationship_relatedContact__c =con.npe4__Relationships1__r[0].LastmodifiedDate;
                
            }if( con.Leads__r !=  null && !con.Leads__r.isEmpty()){
                System.debug('con-------.Leads__r='+con.Leads__r );
                isRelatedListPresent = true;
                testObj.Lead__c =con.Leads__r[0].LastmodifiedDate;
                
            }if( con.Membership_Acceptances1__r !=  null && !con.Membership_Acceptances1__r.isEmpty()){
                System.debug('con-------.Membership_Acceptances1__r='+con.Membership_Acceptances1__r );
                isRelatedListPresent = true;
                testObj.Membership_Acceptance_Ministry_Agreement__c = con.Membership_Acceptances1__r[0].LastmodifiedDate;
                
            }if( con.npsp__Honoree_Opportunities__r !=  null && !con.npsp__Honoree_Opportunities__r.isEmpty()){
                System.debug('con-------.npsp__Honoree_Opportunities__r='+con.npsp__Honoree_Opportunities__r );
                isRelatedListPresent = true;
                testObj.Opportunity_Honoree_Contact__c =con.npsp__Honoree_Opportunities__r[0].LastmodifiedDate;
                
            }if( con.npsp__Notification_Opportunities__r !=  null && !con.npsp__Notification_Opportunities__r.isEmpty()){
                System.debug('con-------.npsp__Notification_Opportunities__r='+con.npsp__Notification_Opportunities__r );
                isRelatedListPresent = true;
                testObj.Opportunity_Notification_Recipient__c =con.npsp__Notification_Opportunities__r[0].LastmodifiedDate;
                
            }if( con.npsp__Opportunities__r !=  null && !con.npsp__Opportunities__r.isEmpty()){
                System.debug('con-------.npsp__Opportunities__r='+con.npsp__Opportunities__r );
                isRelatedListPresent = true;
                testObj.Opportunity_primary_Contact__c =con.npsp__Opportunities__r[0].LastmodifiedDate;
                
            }if( con.Opportunities1__r !=  null && !con.Opportunities1__r.isEmpty()){
                System.debug('con-------.Opportunities1__r='+con.Opportunities1__r );
                isRelatedListPresent = true;
                testObj.Opportunity_Donor_Contact__c =con.Opportunities1__r[0].LastmodifiedDate;
                
            }
             if( con.pi__Category_Contact_Scores__r !=  null && !con.pi__Category_Contact_Scores__r.isEmpty()){
                System.debug('con-------.pi__Category_Contact_Scores__r='+con.pi__Category_Contact_Scores__r );
                isRelatedListPresent = true;
                testObj.Pardot_Category_Score__c =con.pi__Category_Contact_Scores__r[0].LastmodifiedDate;
                
            }
             if( con.npsp__Partial_Soft_Credits__r !=  null && !con.npsp__Partial_Soft_Credits__r.isEmpty()){
                System.debug('con-------.npsp__Partial_Soft_Credits__r='+con.npsp__Partial_Soft_Credits__r );
                isRelatedListPresent = true;
                testObj.Partial_Soft_Credit__c =con.npsp__Partial_Soft_Credits__r[0].LastmodifiedDate;
                
            }
             if( con.Club__r !=  null && !con.Club__r.isEmpty()){
                System.debug('con-------.Club__r='+con.Club__r );
                isRelatedListPresent = true;
                testObj.Program__c =con.Club__r[0].LastmodifiedDate;
                
            }
            
            /**/
            if(isRelatedListPresent){
                
                testObj.bucket__c = 'Have Related Records';
                if(con.Account!=null){
                    testObj.Account_Created_Date__c = con.Account.createdDate;
                    testObj.Account_Lastmodified_Date__c = con.Account.LastModifiedDate;
                    testObj.Account_RecordTypeName__c = con.Account.RecordType.Name; 
                }
                testObj.Contact_created_date__c = con.CreatedDate;
                testObj.Contact_Id__c = con.Id;
                testObj.Contact_Lastmodifed_date__c = con.LastModifiedDate;
                testObj.Contact_Name__c = con.Name;
                testObj.Email__c = con.Email;
                testObj.Gigya_Id__c = con.Gigya_UID__c;
                testObj.Constituent__c = con.Constituent_Id__c;
                
                
                testObjList.add(testObj);
            }
            
        }
        if(testObjList!=null && !testObjList.isEmpty()){
            insert testObjList;
        }
        try {
            
        }catch(Exception e){
            System.debug('get exception on line number-->'+e.getLineNumber()+' error is=>'+e.getMessage());
        }
   
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
}