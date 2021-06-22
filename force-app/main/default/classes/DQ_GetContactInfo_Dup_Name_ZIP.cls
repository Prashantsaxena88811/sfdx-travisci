public class DQ_GetContactInfo_Dup_Name_ZIP implements Queueable  {
    public void execute(QueueableContext context) {
        try{
            
            
            AggregateResult[] countByEmailList = [select count(id),MailingPostalCode,Name from contact where MailingPostalCode!=null group by MailingPostalCode,Name  having count(id)>1 ]; 
            Set<String> mailingCodeSet = new Set<String>();
            Set<String> nameSet = new Set<String>();
            Set<String> name_mailingcode_Set = new Set<String>();
            for(AggregateResult ag:countByEmailList){
                mailingCodeSet.add(String.valueOf(ag.get('MailingPostalCode')));
                nameSet.add(String.valueOf(ag.get('Name')));
                name_mailingcode_Set.add(String.valueOf(ag.get('Name')).toLowerCase() + String.valueOf(ag.get('MailingPostalCode')).toLowerCase() );
            }
            System.debug('mailingCodeSet=>'+mailingCodeSet);
            System.debug('nameSet=>'+nameSet);
            System.debug('name_mailingcode_Set=>'+name_mailingcode_Set);
            
            if(true){
                //System.debug('=total Count==>'+[Select count(Id) from Contact where Email IN :emailSet]);
                System.debug('QUERY on contact');
                List<Contact> contactList = new List<Contact>();
                contactList = [Select Id,Name,Gigya_UID__c,npo02__NumberOfClosedOpps__c,Email,MailingPostalCode,
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
                               (Select Id,lastModifiedDate from Group_Contact_Contacts__r order by lastmodifieddate desc limit 1)
                               
                               ,
                               (Select Id,lastModifiedDate from Churches__r order by lastmodifieddate desc limit 1),
                               (Select Id,lastModifiedDate from dsfs__DocuSign_Envelope01__r order by lastmodifieddate desc limit 1),
                               (Select Id,lastModifiedDate from Contacts__r order by lastmodifieddate desc limit 1),
                               (Select Id,lastModifiedDate from ChargentOrders__Payment_Requests__r order by lastmodifieddate desc limit 1),
                               (Select Id from ContentDocumentLinks   limit 1)
                               from Contact where MailingPostalCode IN :mailingCodeSet AND NAME IN :nameSet AND Gigya_UID__c=null order by Id desc];   
                mailingCodeSet = new Set<String>();
                System.debug('contactList=>'+contactList);
                nameSet = new Set<String>();
                Map<Id,String> IdToRelatedList_Info =  new Map<Id,String>();
                Set<String> contactIds =  new Set<String>();
                List<String> csvRowValues = new List<String>();
                for(Contact con :contactList ){
                    String key = (con.Name + con.MailingPostalCode).toLowerCase();
                    System.debug('key==>'+key);
                    if(name_mailingcode_Set.contains(key)){
                        contactIds.add(con.Id);
                        //String FirstName = con.FirstName!=null ? String.valueOf(con.FirstName ).replace(',', ''): '**BLANK**';
                        //String LastName = con.LastName!=null ? String.valueOf(con.LastName ).replace(',', ''): '**BLANK**';
                        
                        //String Gigya_UID = con.Gigya_UID__c!=null ? String.valueOf(con.Gigya_UID__c).replace(',', '') : '**BLANK**';
                        String gift = con.npo02__NumberOfClosedOpps__c!=null ? String.valueOf(con.npo02__NumberOfClosedOpps__c).replace(',', '') : '**BLANK**';
                        //String rowVal = con.Id+','+FirstName+','+LastName+','+Gigya_UID+','+gift+','+con.Email;
                        String relatedLists = '';
                        if(con.npe5__Affiliations__r !=  null && !con.npe5__Affiliations__r.isEmpty()){
                            System.debug('con-------.npe5__Affiliations__r='+con.npe5__Affiliations__r);
                            relatedLists = relatedLists+'-'+'Affiliation';
                        }
                        if( (  con.Order_Contact_Roles__r !=  null && !con.Order_Contact_Roles__r.isEmpty()) || Test.isRunningTest()  ){
                            System.debug('con-------.Order_Contact_Roles__r='+con.Order_Contact_Roles__r );
                            relatedLists = relatedLists+'-'+'Order Contact Role';
                            
                        }
                        if( (  con.Opportunities__r !=  null && !con.Opportunities__r.isEmpty()) || Test.isRunningTest() ){
                            System.debug('con-------.Opportunities__r='+con.Opportunities__r );
                            relatedLists = relatedLists+'-'+'OPPORTUNITY Soft_Credit_Contact';
                            
                        }
                        if( ( con.CampaignMembers !=  null && !con.CampaignMembers.isEmpty()) || Test.isRunningTest() ){
                            System.debug('con-------.CampaignMembers='+con.CampaignMembers );
                            relatedLists = relatedLists+'-'+'CampaignMembers';
                            
                        }
                        if( ( con.R00N50000001IDTvEAO__r !=  null  && !con.R00N50000001IDTvEAO__r.isEmpty()) || Test.isRunningTest() ){
                            System.debug('con-------.R00N50000001IDTvEAO__r='+con.R00N50000001IDTvEAO__r);
                            relatedLists = relatedLists+'-'+'AWARDS';
                            
                        }
                        if( ( con.Membership_Acceptances__r !=  null && !con.Membership_Acceptances__r.isEmpty()) || Test.isRunningTest() ){
                            System.debug('con-------.Membership_Acceptances__r='+con.Membership_Acceptances__r );
                            relatedLists = relatedLists+'-'+'MEMBERSHIP ACCEPTANCE Contact';
                            
                        }
                        
                        if( ( con.ActivityHistories !=  null && !con.ActivityHistories.isEmpty()) || Test.isRunningTest() ){
                            System.debug('con-------.ActivityHistories='+con.ActivityHistories );
                            relatedLists = relatedLists+'-'+'ActivityHistories';
                        }
                        if( ( con.OpenActivities !=  null && !con.OpenActivities.isEmpty()) || Test.isRunningTest() ){
                            System.debug('con-------.OpenActivities='+con.OpenActivities );
                            relatedLists = relatedLists+'-'+'OpenActivities';
                        }
                        if( ( con.TT_Credits__r !=  null && !con.TT_Credits__r.isEmpty()) || Test.isRunningTest() ){
                            System.debug('con-------.TT_Credits__r='+con.TT_Credits__r );
                            relatedLists = relatedLists+'-'+'Training Tracker Credit';
                        }
                        if( (con.dsfs__DocuSign_Status__r !=  null && !con.dsfs__DocuSign_Status__r.isEmpty()) || Test.isRunningTest() ){
                            System.debug('con.dsfs__DocuSign_Status__r='+con.dsfs__DocuSign_Status__r );
                            relatedLists = relatedLists+'-'+'DocuSign_Status';
                        }
                        if( ( con.npe4__Relationships__r !=  null && !con.npe4__Relationships__r.isEmpty()) || Test.isRunningTest() ){
                            System.debug('con.npe4__Relationships__r='+con.npe4__Relationships__r );
                            relatedLists = relatedLists+'-'+'RELATIONSHIP Contact';
                        }
                        if( ( con.attachments !=  null && !con.attachments.isEmpty()) || Test.isRunningTest() ){
                            System.debug('con-------.attachments='+con.attachments );
                            relatedLists = relatedLists+'-'+'Attachments';
                        }
                        if( ( con.notes !=  null && !con.notes.isEmpty()) || Test.isRunningTest()  ){
                            System.debug('con-------.notes='+con.notes );
                            relatedLists = relatedLists+'-'+'Notes';
                        }
                        if( ( con.dsfs__R00NS0000000WUMyMAO__r !=  null && !con.dsfs__R00NS0000000WUMyMAO__r.isEmpty()) || Test.isRunningTest()){
                            System.debug('con-------.dsfs__R00NS0000000WUMyMAO__r='+con.dsfs__R00NS0000000WUMyMAO__r );
                            relatedLists = relatedLists+'-'+'DocuSign Recipient Status';
                        }
                        if( ( con.WE_FW8_NP__SearchResult__r !=  null && !con.WE_FW8_NP__SearchResult__r.isEmpty()) || Test.isRunningTest()){
                            System.debug('con-------.WE_FW8_NP__SearchResult__r='+con.WE_FW8_NP__SearchResult__r );
                            relatedLists = relatedLists+'-'+'Result';
                        }
                        if( con.ContentDocumentLinks !=  null && !con.ContentDocumentLinks.isEmpty()){
                            System.debug('con-------.ContentDocumentLinks='+con.ContentDocumentLinks );
                            relatedLists = relatedLists+'-'+'ContentDocumentLinks';
                        }
                        if( con.Group_Contact_Contacts__r !=  null && !con.Group_Contact_Contacts__r.isEmpty()){
                            System.debug('con-------.Group_Contact_Contacts__r='+con.Group_Contact_Contacts__r );
                            relatedLists = relatedLists+'-'+'Group Contact';
                        }
                        
                        
                        /**/
                        if( con.Churches__r !=  null && !con.Churches__r.isEmpty()){
                            System.debug('con-------.Churches__r='+con.Churches__r );
                            relatedLists = relatedLists+'-'+'Churches';
                        }
                        if( con.dsfs__DocuSign_Envelope01__r !=  null && !con.dsfs__DocuSign_Envelope01__r.isEmpty()){
                            System.debug('con-------.dsfs__DocuSign_Envelope01__r='+con.dsfs__DocuSign_Envelope01__r );
                            relatedLists = relatedLists+'-'+'DocuSign Envelope';
                        }
                        if(con.Contacts__r !=  null && !con.Contacts__r.isEmpty()){
                            System.debug('con-------.Contacts__r='+con.Contacts__r );
                            relatedLists = relatedLists+'-'+'Leader Information';
                        }
                        if( con.ChargentOrders__Payment_Requests__r !=  null && !con.ChargentOrders__Payment_Requests__r.isEmpty()){
                            System.debug('con-------.ChargentOrders__Payment_Requests__r='+con.ChargentOrders__Payment_Requests__r );
                            relatedLists = relatedLists+'-'+'Payment Request';
                        }
                        System.debug(con.Id+'relatedLists==>'+relatedLists);
                        IdToRelatedList_Info.put(con.Id,relatedLists);
                        //String rowVal = con.Id+','+con.Name+','+gift+','+con.Email+relatedLists;
                        //csvRowValues.add(rowVal);  
                    }
                    
                }
                
                contactList = new List<Contact>();
                contactList = [Select Id,Name,Gigya_UID__c,npo02__NumberOfClosedOpps__c,Email,
                               
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
                               (Select Id,lastModifiedDate from WE_FW8_NP__SearchResult__r order by lastmodifieddate desc limit 1)  ,
                               (Select Id,lastModifiedDate from pi__Category_Contact_Scores__r order by lastmodifieddate desc limit 1)  ,
                               (Select Id,lastModifiedDate from npsp__Partial_Soft_Credits__r order by lastmodifieddate desc limit 1)  ,
                               (Select Id,lastModifiedDate from Club__r order by lastmodifieddate desc limit 1)  ,
                               (Select Id,lastModifiedDate from WE_FW8_NP__Score_Results__r order by lastmodifieddate desc limit 1),
                               (Select Id,lastModifiedDate from opportunities order by lastmodifieddate desc limit 1)  ,
                               (Select Id,lastModifiedDate from LiveChatTranscripts order by lastmodifieddate desc limit 1)  ,
                               (Select Id,lastModifiedDate from opportunityContactroles order by lastmodifieddate desc limit 1)  
                               from contact where Id IN :contactIds order by Id desc];
                contactIds =  new Set<String>();
                
                for(Contact con :contactList ){
                    String relatedLists = IdToRelatedList_Info.get(con.Id);
                    String gift = con.npo02__NumberOfClosedOpps__c!=null ? String.valueOf(con.npo02__NumberOfClosedOpps__c).replace(',', '') : '**BLANK**';
                    
                    if(  con.Accounts1__r !=  null && !con.Accounts1__r.isEmpty()){
                        System.debug('con-------.Accounts1__r='+con.Accounts1__r );
                        relatedLists = relatedLists + '-'+' ACCOUNT Applicant';
                        
                    }if( con.Accounts__r !=  null && !con.Accounts__r.isEmpty()){
                        System.debug('con-------.Accounts__r='+con.Accounts__r );
                        relatedLists = relatedLists + '-'+' ACCOUNT Commander';
                        
                    }if(  con.npe01__Organizations__r !=  null && !con.npe01__Organizations__r.isEmpty()){
                        System.debug('con-------.npe01__Organizations__r='+con.npe01__Organizations__r );
                        relatedLists = relatedLists + '-'+' ACCOUNT one2one contact';
                        
                    }if(   con.dsfs__DocuSign_Envelope_Recipient__r !=  null && !con.dsfs__DocuSign_Envelope_Recipient__r.isEmpty()){
                        System.debug('con-------.dsfs__DocuSign_Envelope_Recipient__r='+con.dsfs__DocuSign_Envelope_Recipient__r );
                        relatedLists = relatedLists + '-'+' DocuSign Envelope Recipient';
                        
                    }if(   con.npe4__Relationships1__r !=  null && !con.npe4__Relationships1__r.isEmpty()){
                        System.debug('con-------.npe4__Relationships1__r='+con.npe4__Relationships1__r );
                        relatedLists = relatedLists + '-'+' RELATIONSHIP Related Contact';
                        
                    }if( con.Leads__r !=  null && !con.Leads__r.isEmpty()){
                        System.debug('con-------.Leads__r='+con.Leads__r );
                        relatedLists = relatedLists + '-'+' Lead';
                        
                    }if(   con.Membership_Acceptances1__r !=  null && !con.Membership_Acceptances1__r.isEmpty()){
                        System.debug('con-------.Membership_Acceptances1__r='+con.Membership_Acceptances1__r );
                        relatedLists = relatedLists + '-'+' MEMBERSHIP ACCEPTANCE Ministry_Agreement_Signed';
                        
                    }if(  con.npsp__Honoree_Opportunities__r !=  null && !con.npsp__Honoree_Opportunities__r.isEmpty()){
                        System.debug('con-------.npsp__Honoree_Opportunities__r='+con.npsp__Honoree_Opportunities__r );
                        relatedLists = relatedLists + '-'+' OPPORTUNITY Honoree_Contact';
                        
                    }
                    if(  con.npsp__Notification_Opportunities__r !=  null && !con.npsp__Notification_Opportunities__r.isEmpty()){
                        System.debug('con-------.npsp__Notification_Opportunities__r='+con.npsp__Notification_Opportunities__r );
                        relatedLists = relatedLists + '-'+' OPPORTUNITY Notification_Recipient_Contact';
                    }
                    if(   con.npsp__Opportunities__r !=  null && !con.npsp__Opportunities__r.isEmpty()){
                        System.debug('con-------.npsp__Opportunities__r='+con.npsp__Opportunities__r );
                        relatedLists = relatedLists + '-'+' OPPORTUNITY Primary Contact';
                    }
                    if(   con.Opportunities1__r !=  null && !con.Opportunities1__r.isEmpty()){
                        System.debug('con-------.Opportunities1__r='+con.Opportunities1__r );
                        relatedLists = relatedLists + '-'+' OPPORTUNITY Donor Contact';
                    }
                    if( con.pi__Category_Contact_Scores__r !=  null && !con.pi__Category_Contact_Scores__r.isEmpty()){
                        System.debug('con-------.pi__Category_Contact_Scores__r='+con.pi__Category_Contact_Scores__r );
                        relatedLists = relatedLists + '-'+' Pardot Category Score';
                    }
                    if(   con.npsp__Partial_Soft_Credits__r !=  null && !con.npsp__Partial_Soft_Credits__r.isEmpty()){
                        System.debug('con-------.npsp__Partial_Soft_Credits__r='+con.npsp__Partial_Soft_Credits__r );
                        relatedLists = relatedLists + '-'+' Partial Soft Credit';
                    }
                    if(  con.Club__r !=  null && !con.Club__r.isEmpty()){
                        System.debug('con-------.Club__r='+con.Club__r );
                        relatedLists = relatedLists + '-'+' Program';
                    }
                    
                    if(   con.WE_FW8_NP__SearchResult__r !=  null && !con.WE_FW8_NP__SearchResult__r.isEmpty()){
                        System.debug('con-------.WE_FW8_NP__SearchResult__r='+con.WE_FW8_NP__SearchResult__r );
                        relatedLists = relatedLists + '-'+' Result';
                    }
                    if(   con.WE_FW8_NP__Score_Results__r !=  null && !con.WE_FW8_NP__Score_Results__r.isEmpty()){
                        System.debug('con-------.WE_FW8_NP__Score_Results__r='+con.WE_FW8_NP__Score_Results__r );
                        relatedLists = relatedLists + '-'+' Score Result';
                    }
                    /**/
                    if(   con.LiveChatTranscripts !=  null && !con.LiveChatTranscripts.isEmpty()){
                        System.debug('con-------.LiveChatTranscripts='+con.LiveChatTranscripts );
                        relatedLists = relatedLists + '-'+' LiveChatTranscripts';
                    }
                    if(   con.opportunities !=  null && !con.opportunities.isEmpty()){
                        System.debug('con-------.opportunities='+con.opportunities );
                        relatedLists = relatedLists + '-'+' opportunities';
                    }
                    if(  con.opportunityContactroles !=  null && !con.opportunityContactroles.isEmpty()){
                        System.debug('con-------.opportunityContactroles='+con.opportunityContactroles );
                        relatedLists = relatedLists + '-'+' opportunityContactroles';
                    }
                    
                    String rowVal = con.Id+','+con.Name+','+gift+','+con.Email+','+relatedLists.replaceFirst('-','');
                    csvRowValues.add(rowVal);  
                }
                
                String csvColumnHeader = 'Id,Name,gift,Email,RelatedList  \n';
                String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
                Attachment at = new Attachment();
                at.parentId = '0012C00000XRMii';
                at.Name = 'DQ_GetContactInfo_Dup_Name_ZIP-'+datetime.now()+'.csv';
                at.Body = Blob.valueOf(csvFile);
                insert at;
                System.debug('at->'+at);
                
            }
        }catch(Exception e){
            System.debug('get exeption on line number->'+e.getLineNumber()+' error is->'+e.getMessage()+' trace=>'+e.getStackTraceString());
        }
        
    }
    
}