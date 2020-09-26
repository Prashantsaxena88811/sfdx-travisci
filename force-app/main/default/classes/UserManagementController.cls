/**
* Created by Sandeep-Kumar on 5/9/2020.
*/

public with sharing class UserManagementController {
    
    @AuraEnabled
    public static List<Map<String,Object>> getMySites(String contactId) {
        //contactId = 3229495;
        try {
            List<Map<String,Object>> dataMaps = new List <Map<String,Object>>();
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('http://ec2-3-12-31-104.us-east-2.compute.amazonaws.com:8080/searchservice/user/' + contactId + '/mysites');
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            HttpResponse response = http.send(request);
            
            Map<String,Object> mySitesResponse = (Map<String,object>)JSON.deserializeUntyped(response.getBody());
            Map<String,Object> mySitesResponseResp = (Map<String,object>)JSON.deserializeUntyped(Json.serialize((mySitesResponse.get('resp'))));
            String results = Json.serialize((mySitesResponseResp.get('results')));
            
            if (String.isNotBlank(results)) {
                List<Object> dataObjects = (List<Object>)JSON.deserializeUntyped(results);                
                for (Object obj : dataObjects) {
                    dataMaps.add((Map<String,Object>)obj);
                }
            }
            return dataMaps;
        }
        catch(Exception ex) {
            System.debug('Message:- ' + ex.getMessage() + '  ' + 'Line Number:- ' + ex.getLineNumber());
            return null;            
        }
    }
    
    @AuraEnabled
    public static boolean updatePreference(String contactId, String sites) {
        try {
                Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('http://ec2-3-12-31-104.us-east-2.compute.amazonaws.com:8080/searchservice/user/' + contactId + '/updatePreference');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(sites);
            HttpResponse response = http.send(request);            
            String resBody = response.getBody();
            System.debug(resBody);
                     
            return true;
        } catch (Exception ex) {
            System.debug('Message:- ' + ex.getMessage() + '  ' + 'Line Number:- ' + ex.getLineNumber());
            return false;
        }
    }
}