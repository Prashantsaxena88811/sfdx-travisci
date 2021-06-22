public class Discovery_SalesInvoice {
    public static void checkActivityHistory(){
        for(Sales_Invoice__c salesInvObj :[Select id , name ,
                                           (Select Id from ActivityHistories order by lastmodifieddate desc limit 1) from Sales_Invoice__c
                                           order by lastmodifieddate desc limit 10000]){
                                               System.debug('salesInvObjActivityHistories==>'+salesInvObj.ActivityHistories);
                                               if(salesInvObj.ActivityHistories!=null && !salesInvObj.ActivityHistories.isEmpty()){
                                                   System.debug('Activity history avialble');
                                               }
                                               
                                               
                                               
                                           }
    }
    
    public static void checkcontentDocumentLinks(){
        for(Sales_Invoice__c salesInvObj :[Select id , name ,
                                           (Select Id from contentDocumentLinks  limit 1) from Sales_Invoice__c
                                           order by lastmodifieddate desc limit 10000]){
                                               System.debug('salesInvObjcontentDocumentLinks'+salesInvObj.contentDocumentLinks);
                                               if(salesInvObj.contentDocumentLinks!=null && !salesInvObj.contentDocumentLinks.isEmpty()){
                                                   System.debug('contentDocumentLinks avialble');
                                               }
                                           }
    }
    
    public static void checkNotesANDAttachments(){
        for(Sales_Invoice__c salesInvObj :[Select id , name ,
                                           (Select Id from notes  limit 1), (Select Id from attachments  limit 1) from Sales_Invoice__c
                                           order by lastmodifieddate desc limit 10000]){
                                               
                                               System.debug(salesInvObj.attachments+'checkNotesANDAttachments'+salesInvObj.notes);
                                               if(salesInvObj.notes!=null && !salesInvObj.notes.isEmpty()){
                                                   System.debug('notes avialble');
                                               }
                                               if(salesInvObj.attachments!=null && !salesInvObj.attachments.isEmpty()){
                                                   System.debug('attachments avialble');
                                               }
                                           }
    }
    
    public static void checkOpenActivities(){
        for(Sales_Invoice__c salesInvObj :[Select id , name ,
                                           (Select Id from OpenActivities  limit 1) from Sales_Invoice__c
                                           order by lastmodifieddate desc limit 10000]){
                                               System.debug('OpenActivities'+salesInvObj.OpenActivities);
                                               if(salesInvObj.OpenActivities!=null && !salesInvObj.OpenActivities.isEmpty()){
                                                   System.debug('OpenActivities avialble');
                                               }
                                           }
    }
    
    public static void checkApprovalHistory(){
        /*for(Sales_Invoice__c salesInvObj :[Select id , name ,
(Select Id from ContentDeliveries order by lastmodifieddate desc limit 1) from Sales_Invoice__c
order by lastmodifieddate desc limit 10000]){
System.debug('salesInvObjActivityHistories==>'+salesInvObj.ActivityHistories);
if(salesInvObj.ActivityHistories!=null && !salesInvObj.ActivityHistories.isEmpty()){
System.debug('Activity history avialble');
}



}*/
    }
        
        /*Sales Invoice Items Start*/
        public static void checkActivityHistory_SalesInvoiceItems(){
            for(Sales_Invoice_Item__c salesInvObj :[Select id , name ,
                                               (Select Id from ActivityHistories order by lastmodifieddate desc limit 1) from Sales_Invoice_Item__c
                                               order by lastmodifieddate desc limit 10000]){
                                                   System.debug('salesInvObjActivityHistories==>'+salesInvObj.ActivityHistories);
                                                   if(salesInvObj.ActivityHistories!=null && !salesInvObj.ActivityHistories.isEmpty()){
                                                       System.debug('Activity history avialble');
                                                   }
                                                   
                                                   
                                                   
                                               }
        }
        
        public static void checkcontentDocumentLinks_SalesInvoiceItems(){
            for(Sales_Invoice_Item__c salesInvObj :[Select id , name ,
                                               (Select Id from contentDocumentLinks  limit 1) from Sales_Invoice_Item__c
                                               order by lastmodifieddate desc limit 10000]){
                                                   System.debug('salesInvObjcontentDocumentLinks'+salesInvObj.contentDocumentLinks);
                                                   if(salesInvObj.contentDocumentLinks!=null && !salesInvObj.contentDocumentLinks.isEmpty()){
                                                       System.debug('contentDocumentLinks avialble');
                                                   }
                                               }
        }
        
        public static void checkNotesANDAttachments_SalesInvoiceItems(){
            for(Sales_Invoice_Item__c salesInvObj :[Select id , name ,
                                               (Select Id from notes  limit 1), (Select Id from attachments  limit 1) from Sales_Invoice_Item__c
                                               order by lastmodifieddate desc limit 10000]){
                                                   
                                                   System.debug(salesInvObj.attachments+'checkNotesANDAttachments'+salesInvObj.notes);
                                                   if(salesInvObj.notes!=null && !salesInvObj.notes.isEmpty()){
                                                       System.debug('notes avialble');
                                                   }
                                                   if(salesInvObj.attachments!=null && !salesInvObj.attachments.isEmpty()){
                                                       System.debug('attachments avialble');
                                                   }
                                               }
        }
        
        public static void checkOpenActivities_SalesInvoiceItems(){
            for(Sales_Invoice_Item__c salesInvObj :[Select id , name ,
                                               (Select Id from OpenActivities  limit 1) from Sales_Invoice_Item__c
                                               order by lastmodifieddate desc limit 10000]){
                                                   System.debug('OpenActivities'+salesInvObj.OpenActivities);
                                                   if(salesInvObj.OpenActivities!=null && !salesInvObj.OpenActivities.isEmpty()){
                                                       System.debug('OpenActivities avialble');
                                                   }
                                               }
        }
        /*Sales Invoice Items End*/
        
        /*Sales Invoice Totals Start*/
        public static void checkActivityHistory_SalesInvoiceTotals(){
            for(Sales_Invoice_Total__c salesInvObj :[Select id , name ,
                                               (Select Id from ActivityHistories order by lastmodifieddate desc limit 1) from Sales_Invoice_Total__c
                                               order by lastmodifieddate desc limit 10000]){
                                                   System.debug('salesInvObjActivityHistories==>'+salesInvObj.ActivityHistories);
                                                   if(salesInvObj.ActivityHistories!=null && !salesInvObj.ActivityHistories.isEmpty()){
                                                       System.debug('Activity history avialble');
                                                   }
                                                   
                                                   
                                                   
                                               }
        }
        
        public static void checkcontentDocumentLinks_SalesInvoiceTotals(){
            for(Sales_Invoice_Total__c salesInvObj :[Select id , name ,
                                               (Select Id from contentDocumentLinks  limit 1) from Sales_Invoice_Total__c
                                               order by lastmodifieddate desc limit 10000]){
                                                   System.debug('salesInvObjcontentDocumentLinks'+salesInvObj.contentDocumentLinks);
                                                   if(salesInvObj.contentDocumentLinks!=null && !salesInvObj.contentDocumentLinks.isEmpty()){
                                                       System.debug('contentDocumentLinks avialble');
                                                   }
                                               }
        }
        
        public static void checkNotesANDAttachments_SalesInvoiceTotals(){
            for(Sales_Invoice_Total__c salesInvObj :[Select id , name ,
                                               (Select Id from notes  limit 1), (Select Id from attachments  limit 1) from Sales_Invoice_Total__c
                                               order by lastmodifieddate desc limit 10000]){
                                                   
                                                   System.debug(salesInvObj.attachments+'checkNotesANDAttachments'+salesInvObj.notes);
                                                   if(salesInvObj.notes!=null && !salesInvObj.notes.isEmpty()){
                                                       System.debug('notes avialble');
                                                   }
                                                   if(salesInvObj.attachments!=null && !salesInvObj.attachments.isEmpty()){
                                                       System.debug('attachments avialble');
                                                   }
                                               }
        }
        
        public static void checkOpenActivities_SalesInvoiceTotals(){
            for(Sales_Invoice_Total__c salesInvObj :[Select id , name ,
                                               (Select Id from OpenActivities  limit 1) from Sales_Invoice_Total__c
                                               order by lastmodifieddate desc limit 10000]){
                                                   System.debug('OpenActivities'+salesInvObj.OpenActivities);
                                                   if(salesInvObj.OpenActivities!=null && !salesInvObj.OpenActivities.isEmpty()){
                                                       System.debug('OpenActivities avialble');
                                                   }
                                               }
        }
        /*Sales Invoice Totals End*/
        
        /*Sales Invoice Pay Details Start*/
        public static void checkActivityHistory_SalesInvoicePayDetails(){
            for(Sales_Invoice_Payment__c salesInvObj :[Select id , name ,
                                               (Select Id from ActivityHistories order by lastmodifieddate desc limit 1) from Sales_Invoice_Payment__c
                                               order by lastmodifieddate desc limit 10000]){
                                                   System.debug('salesInvObjActivityHistories==>'+salesInvObj.ActivityHistories);
                                                   if(salesInvObj.ActivityHistories!=null && !salesInvObj.ActivityHistories.isEmpty()){
                                                       System.debug('Activity history avialble');
                                                   }
                                                   
                                                   
                                                   
                                               }
        }
        
        public static void checkcontentDocumentLinks_SalesInvoicePayDetails(){
            for(Sales_Invoice_Payment__c salesInvObj :[Select id , name ,
                                               (Select Id from contentDocumentLinks  limit 1) from Sales_Invoice_Payment__c
                                               order by lastmodifieddate desc limit 10000]){
                                                   System.debug('salesInvObjcontentDocumentLinks'+salesInvObj.contentDocumentLinks);
                                                   if(salesInvObj.contentDocumentLinks!=null && !salesInvObj.contentDocumentLinks.isEmpty()){
                                                       System.debug('contentDocumentLinks avialble');
                                                   }
                                               }
        }
        
        public static void checkNotesANDAttachments_SalesInvoicePayDetails(){
            for(Sales_Invoice_Payment__c salesInvObj :[Select id , name ,
                                               (Select Id from notes  limit 1), (Select Id from attachments  limit 1) from Sales_Invoice_Payment__c
                                               order by lastmodifieddate desc limit 10000]){
                                                   
                                                   System.debug(salesInvObj.attachments+'checkNotesANDAttachments'+salesInvObj.notes);
                                                   if(salesInvObj.notes!=null && !salesInvObj.notes.isEmpty()){
                                                       System.debug('notes avialble');
                                                   }
                                                   if(salesInvObj.attachments!=null && !salesInvObj.attachments.isEmpty()){
                                                       System.debug('attachments avialble');
                                                   }
                                               }
        }
        
        public static void checkOpenActivities_SalesInvoicePayDetails(){
            for(Sales_Invoice_Payment__c salesInvObj :[Select id , name ,
                                               (Select Id from OpenActivities  limit 1) from Sales_Invoice_Payment__c
                                               order by lastmodifieddate desc limit 10000]){
                                                   System.debug('OpenActivities'+salesInvObj.OpenActivities);
                                                   if(salesInvObj.OpenActivities!=null && !salesInvObj.OpenActivities.isEmpty()){
                                                       System.debug('OpenActivities avialble');
                                                   }
                                               }
        }
        /*Sales Invoice Pay Details End*/
    
}