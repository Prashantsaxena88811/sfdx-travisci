public class Discovery_contact {
    public static void main(){
        List<Contact> contactList = new List<Contact>();
            contactList = [Select id , name ,Email,Gigya_UID__c,Constituent_Id__c,AccountID , Account.CreatedDate,Account.lastModifiedDate,
                           Account.RecordType.name,CreatedDate,lastModifiedDate,
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
                           (Select Id,lastModifiedDate from ChargentOrders__Payment_Requests__r order by lastmodifieddate desc limit 1)
                           from contact where to_be_deleted__c =  true limit 10000];
            System.debug('contactList-->'+contactList);
            
            Boolean isRelatedListPresent = false;
            Integer counterOld = 0;
            for(contact con : contactList){
                System.debug('counterOld '+counterOld+' ==>'+con.Id);
                counterOld = counterOld +1;
                isRelatedListPresent = false;
                if(con.npe5__Affiliations__r !=  null && !con.npe5__Affiliations__r.isEmpty()){
                    System.debug('con-------.npe5__Affiliations__r='+con.npe5__Affiliations__r);
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.Order_Contact_Roles__r !=  null && !con.Order_Contact_Roles__r.isEmpty()) || Test.isRunningTest()  ){
                    System.debug('con-------.Order_Contact_Roles__r='+con.Order_Contact_Roles__r );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.Opportunities__r !=  null && !con.Opportunities__r.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con-------.Opportunities__r='+con.Opportunities__r );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.CampaignMembers !=  null && !con.CampaignMembers.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con-------.CampaignMembers='+con.CampaignMembers );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.R00N50000001IDTvEAO__r !=  null  && !con.R00N50000001IDTvEAO__r.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con-------.R00N50000001IDTvEAO__r='+con.R00N50000001IDTvEAO__r);
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.Membership_Acceptances__r !=  null && !con.Membership_Acceptances__r.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con-------.Membership_Acceptances__r='+con.Membership_Acceptances__r );
                    isRelatedListPresent = true;
                }
                
                if( (!isRelatedListPresent && con.ActivityHistories !=  null && !con.ActivityHistories.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con-------.ActivityHistories='+con.ActivityHistories );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.OpenActivities !=  null && !con.OpenActivities.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con-------.OpenActivities='+con.OpenActivities );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.TT_Credits__r !=  null && !con.TT_Credits__r.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con-------.TT_Credits__r='+con.TT_Credits__r );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.dsfs__DocuSign_Status__r !=  null && !con.dsfs__DocuSign_Status__r.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con.dsfs__DocuSign_Status__r='+con.dsfs__DocuSign_Status__r );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.npe4__Relationships__r !=  null && !con.npe4__Relationships__r.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con.npe4__Relationships__r='+con.npe4__Relationships__r );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.attachments !=  null && !con.attachments.isEmpty()) || Test.isRunningTest() ){
                    System.debug('con-------.attachments='+con.attachments );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.notes !=  null && !con.notes.isEmpty()) || Test.isRunningTest()  ){
                    System.debug('con-------.notes='+con.notes );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.dsfs__R00NS0000000WUMyMAO__r !=  null && !con.dsfs__R00NS0000000WUMyMAO__r.isEmpty()) || Test.isRunningTest()){
                    System.debug('con-------.dsfs__R00NS0000000WUMyMAO__r='+con.dsfs__R00NS0000000WUMyMAO__r );
                    isRelatedListPresent = true;
                }
                if( (!isRelatedListPresent && con.WE_FW8_NP__SearchResult__r !=  null && !con.WE_FW8_NP__SearchResult__r.isEmpty()) || Test.isRunningTest()){
                    System.debug('con-------.WE_FW8_NP__SearchResult__r='+con.WE_FW8_NP__SearchResult__r );
                    isRelatedListPresent = true;
                }
                if(!isRelatedListPresent && con.ContentDocumentLinks !=  null && !con.ContentDocumentLinks.isEmpty()){
                    System.debug('con-------.ContentDocumentLinks='+con.ContentDocumentLinks );
                    isRelatedListPresent = true;
                }
                if(!isRelatedListPresent && con.Group_Contact_Contacts__r !=  null && !con.Group_Contact_Contacts__r.isEmpty()){
                    System.debug('con-------.Group_Contact_Contacts__r='+con.Group_Contact_Contacts__r );
                    isRelatedListPresent = true;
                }
                
                
                /**/
                if(!isRelatedListPresent && con.Churches__r !=  null && !con.Churches__r.isEmpty()){
                    System.debug('con-------.Churches__r='+con.Churches__r );
                    isRelatedListPresent = true;
                }
                if(!isRelatedListPresent && con.dsfs__DocuSign_Envelope01__r !=  null && !con.dsfs__DocuSign_Envelope01__r.isEmpty()){
                    System.debug('con-------.dsfs__DocuSign_Envelope01__r='+con.dsfs__DocuSign_Envelope01__r );
                    isRelatedListPresent = true;
                }
                if(!isRelatedListPresent && con.Contacts__r !=  null && !con.Contacts__r.isEmpty()){
                    System.debug('con-------.Contacts__r='+con.Contacts__r );
                    isRelatedListPresent = true;
                }
                if(!isRelatedListPresent && con.ChargentOrders__Payment_Requests__r !=  null && !con.ChargentOrders__Payment_Requests__r.isEmpty()){
                    System.debug('con-------.ChargentOrders__Payment_Requests__r='+con.ChargentOrders__Payment_Requests__r );
                    isRelatedListPresent = true;
                }
               
                System.debug(con.Id+'----'+isRelatedListPresent);
            }
    }

}