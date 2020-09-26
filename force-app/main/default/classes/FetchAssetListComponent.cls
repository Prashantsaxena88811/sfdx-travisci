public with sharing class FetchAssetListComponent {
    @AuraEnabled(cacheable=true) 
    public static string getAssets() {
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('http://ec2-3-12-31-104.us-east-2.compute.amazonaws.com:8080/searchservice/assets/searchAssets?facets=SiteID.keyword&facets=ContactIDS.keyword&facets=ProductID.keyword&facets=GroupID.keyword&resultPage=1&resultSize=10');
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            HttpResponse response = http.send(request);
            String res = response.getBody();
            /*Map<String,Object> mySitesResponse = (Map<String,object>)JSON.deserializeUntyped(response.getBody());
            Map<String,Object> mySitesResponseResp = (Map<String,object>)JSON.deserializeUntyped(Json.serialize((mySitesResponse.get('resp'))));*/
            return res;

        }
        catch(Exception ex) {
            System.debug('Message::' + ex.getMessage() + '  ' + 'Line Number::' + ex.getLineNumber());
            return null;            
        }
    }
    @AuraEnabled 
    public static string getAssetsByPageNumber(Decimal pageNumber,String dynamicURLApex) {
        try {
            string endpoint;
            //if(String.isEmpty(dynamicURLApex)){
             endpoint ='http://ec2-3-12-31-104.us-east-2.compute.amazonaws.com:8080/searchservice/assets/searchAssets?facets=SiteID.keyword&facets=ContactIDS.keyword&facets=ProductID.keyword&facets=GroupID.keyword&resultPage='+pageNumber+'&resultSize=10';
            /*}else{
                endpoint = 'http://ec2-3-12-31-104.us-east-2.compute.amazonaws.com:8080/searchservice/assets/searchAssets?&resultPage='+pageNumber+'&resultSize=10';
            }*/
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint+dynamicURLApex);
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            HttpResponse response = http.send(request);
            String res = response.getBody();
            /*Map<String,Object> mySitesResponse = (Map<String,object>)JSON.deserializeUntyped(response.getBody());
            Map<String,Object> mySitesResponseResp = (Map<String,object>)JSON.deserializeUntyped(Json.serialize((mySitesResponse.get('resp'))));*/
            return res;

        }
        catch(Exception ex) {
            System.debug('Message::' + ex.getMessage() + '  ' + 'Line Number::' + ex.getLineNumber());
            return null;            
        }
    }
    @AuraEnabled 
    public static string getAssetsByfilters(String dynamicURLApex) {
        try {
            //System.debug('http://ec2-3-12-31-104.us-east-2.compute.amazonaws.com:8080/searchservice/assets/searchAssets?&resultPage=0&resultSize=10'+dynamicURLApex);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('http://ec2-3-12-31-104.us-east-2.compute.amazonaws.com:8080/searchservice/assets/searchAssets?facets=SiteID.keyword&facets=ContactIDS.keyword&facets=ProductID.keyword&facets=GroupID.keyword&resultPage=1&resultSize=10'+dynamicURLApex);
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            HttpResponse response = http.send(request);
            String res = response.getBody();
            /*Map<String,Object> mySitesResponse = (Map<String,object>)JSON.deserializeUntyped(response.getBody());
            Map<String,Object> mySitesResponseResp = (Map<String,object>)JSON.deserializeUntyped(Json.serialize((mySitesResponse.get('resp'))));*/
            return res;

        }
        catch(Exception ex) {
            System.debug('Message::' + ex.getMessage() + '  ' + 'Line Number::' + ex.getLineNumber());
            return null;            
        }
    }
    public static string getAssetsUpgrade() {
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('http://34.209.52.101:8080/dcxservice/asset/search');
            request.setBody('{ "pageNumber": 1, "pageSize": 20, "query": [ { "search": "OUT_OF_TOLERANCE" } ], "filters": [ { "field": "manufacturer.keyword", "value": [ "Keysight Technologies" ] }, { "field": "manuf_model_no.keyword", "value": [ "3458A", "N4694A" ] } ], "fields": [ "manufacturer", "manuf_model_no", "id" ], "sorts": [ { "field": "manuf_model_no.keyword", "order": "DESC" }, { "field": "id", "order": "DESC" } ], "facets": [ { "field": "manufacturer.keyword" } ] }');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            HttpResponse response = http.send(request);
            String res = response.getBody();
            System.debug(res);
            /*Map<String,Object> mySitesResponse = (Map<String,object>)JSON.deserializeUntyped(response.getBody());
            Map<String,Object> mySitesResponseResp = (Map<String,object>)JSON.deserializeUntyped(Json.serialize((mySitesResponse.get('resp'))));*/
            return res;

        }
        catch(Exception ex) {
            System.debug('Message::' + ex.getMessage() + '  ' + 'Line Number::' + ex.getLineNumber());
            return null;
        }
    }

}