global class ApiCallWithBatch implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts {

    global List<String> siteList;
    global String contactId;

    //constructor
    global ApiCallWithBatch(List<String> siteList, String contactId) {
        this.siteList = siteList;
        this.contactId = contactId;
    }

    public Iterable<String> start(Database.BatchableContext bc) {
        List<String> siteList = siteList;
        
        return siteList;
    }
    global void execute(Database.BatchableContext BC, List<String> siteList) {
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('http://ec2-3-12-31-104.us-east-2.compute.amazonaws.com:8080/searchservice/user/' + contactId + '/updatePreference');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(siteList[0]);
            HttpResponse response = http.send(request);            
            String resBody = response.getBody();
            System.debug(resBody);
        } catch (Exception exp) {
            System.debug('Exception in CommissionTransactionRecordsInsertBatch Message :: ' + exp.getMessage() + ' At line Number :: ' + exp.getLineNumber());
        }
    }

    global void finish(Database.BatchableContext BC) {
        
    }
    
}