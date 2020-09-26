public class ServiceOrderController {
    @AuraEnabled
    public static list <ServiceOrderWrapper> getRecordtList() {
        List<ServiceOrderWrapper> serviceOrderlist = new List<ServiceOrderWrapper>();
        for(Account acc:[SELECT Name,AccountNumber,Phone,BillingAddress,Description FROM Account LIMIT 500]){
            ServiceOrderWrapper serviceOrder = new ServiceOrderWrapper();
            serviceOrder.ServiceOrderNumber = acc.AccountNumber;
            serviceOrder.Product = acc.Name;
            serviceOrder.SerialNumber = acc.Phone;
            serviceOrder.Status = 'In Progress';
            serviceOrder.Comments = acc.Description;
            serviceOrder.ShipDate = Date.today();
            serviceorder.JobType = 'Repair and key site';
            serviceOrderlist.add(serviceOrder);
            
        }
        
        return serviceOrderlist;
    }
    
    public class ServiceOrderWrapper{
        @AuraEnabled
        public String ServiceOrderNumber {get;set;}
        @AuraEnabled
        public String Product {get;set;}
        @AuraEnabled public String SerialNumber {get;set;}
        @AuraEnabled public String JobType {get;set;}
        @AuraEnabled public String Status {get;set;}
        @AuraEnabled public Date ShipDate {get;set;}
        @AuraEnabled public String Comments {get;set;}
    }
}