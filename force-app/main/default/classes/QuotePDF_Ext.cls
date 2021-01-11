public class QuotePDF_Ext {

    public List<quote> qtList{get;set;}
    public string qId{get;set;}
    public list<quotelineitem> qliList{get;set;}
    public string bilAddress{get;set;}
    public quote qt{get;set;}
    
    public QuotePDF_Ext(apexpages.StandardController stdcontroller){
        
        qt = new quote();
        qliList = new list<quotelineitem>();
        //qId = '0Q0Z0000000NEmgKAG';
        //qId = ApexPages.currentPage().getParameters().get('id');
        qId = stdController.getId();
        bilAddress = '';
        qt = [Select Email,BillingName,BillingState,BillingStreet,BillingCity,BillingCountry,BillingPostalCode from quote where Id =: qId];
        if(qt.BillingStreet != null){
           bilAddress += qt.BillingStreet;
        }
        if(qt.BillingCity != null){
           bilAddress += '\n'+qt.BillingCity;
        }
        if(qt.BillingState != null){
           bilAddress += '\n'+qt.BillingState;
        }
        if(qt.BillingCountry != null){
           bilAddress += '\n'+qt.BillingCountry;
        }
         if(qt.BillingPostalCode != null){
           bilAddress += '\n'+qt.BillingPostalCode;
        }
        
        qliList = [Select Product2.name,Id,Quote.opportunity.Name,Quote.ExpirationDate,Quote.createddate,Quote.TotalPrice,Quote.Name,quote.QuoteNumber,quote.Created_Date__c,quote.Description,quantity,TotalPrice,UnitPrice from quotelineitem where quoteId=: qId];
        
    }
    
    
    @AuraEnabled
    public static void SavePDF(string recId) {
        system.debug('recId>>>>>>>>>>'+recId);
        
        try
        {
            PageReference pageRef = new PageReference('/apex/QuotePDF_Page?Id='+recId);
         
            Blob content;
                if(!test.isrunningtest())
                content = pageRef.getContent();
            else
                content = Blob.valueOf( EncodingUtil.urlEncode('abc', 'UTF-8'));
             
            QuoteDocument doc = new QuoteDocument(Document = content, QuoteId = recId);
            insert doc;
        }catch(exception ex){
            system.debug(ex.getMessage());
        }
    }
}