/**
 * Created by Awishkar-Kumar on 5/8/2020.
 */

public with sharing class Group_Management_Controller {
    @AuraEnabled
    public static List < Map < String, Object >> getGroupMembers(String groupId) {
        //groupId = '396537';
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('http://ec2-3-12-31-104.us-east-2.compute.amazonaws.com:8080/searchservice/groups/' + groupId + '/searchUser?sort.attribute=ContactID.keyword&sort.order=ASC');
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            System.debug(response.getBody());
            String res = response.getBody();
            System.debug('response::' + response);
            Map < String, Object > groupManagementResponse = (Map < String, object >) JSON.deserializeUntyped(res);
            System.debug('ParserClassForGroupManagementObject::' + groupManagementResponse.get('resp'));
            String resp = Json.serialize((groupManagementResponse.get('resp')));
            Map < String, Object > groupManagementResponseResp = (Map < String, object >) JSON.deserializeUntyped(resp);
            String results = Json.serialize((groupManagementResponseResp.get('results')));
            if (String.isNotBlank(results)) {
                List < Object > dataObjects = (List < Object >) JSON.deserializeUntyped(results);
                List < Map < String, Object >> dataMaps = new List < Map < String, Object >> ();
                for (Object obj : dataObjects) {
                    dataMaps.add((Map < String, Object >) obj);
                }
                System.debug(dataMaps);
                return dataMaps;
            }
        } catch (Exception ex) {
            System.debug('Message::' + ex.getMessage() + '  ' + 'Line Number::' + ex.getLineNumber());
            return null;
        }
        return null;
    }
    @AuraEnabled
    public static List < Map < String, Object >> callOutToAPI(String groupId, String userData, String MethodName) {
        //groupId = '396537' 343586;
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('http://ec2-3-12-31-104.us-east-2.compute.amazonaws.com:8080/searchservice/groups/' + groupId + '/'+ MethodName);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(userData);
            HttpResponse response = http.send(request);
            System.debug(response.getBody());
            String res = response.getBody();
            System.debug('response::' + response);
        } catch (Exception ex) {
            System.debug('Message::' + ex.getMessage() + '  ' + 'Line Number::' + ex.getLineNumber());
            return null;
        }
        return null;
    }
    @AuraEnabled
    public static List < Map < String, Object >> getSearchedResults(String searchKey) {
        //groupId = '396537';
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('http://ec2-3-12-31-104.us-east-2.compute.amazonaws.com:8080/searchservice/cases/search?query='+searchKey+'&sort.order=ASC');
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            System.debug(response.getBody());
            String res = response.getBody();
            System.debug('response::' + response);
            Map < String, Object > groupManagementResponse = (Map < String, object >) JSON.deserializeUntyped(res);
            System.debug('ParserClassForGroupManagementObject::' + groupManagementResponse.get('resp'));
            String resp = Json.serialize((groupManagementResponse.get('resp')));
            Map < String, Object > groupManagementResponseResp = (Map < String, object >) JSON.deserializeUntyped(resp);
            String results = Json.serialize((groupManagementResponseResp.get('results')));
            if (String.isNotBlank(results)) {
                List < Object > dataObjects = (List < Object >) JSON.deserializeUntyped(results);
                List < Map < String, Object >> dataMaps = new List < Map < String, Object >> ();
                for (Object obj : dataObjects) {
                    dataMaps.add((Map < String, Object >) obj);
                }
                System.debug(dataMaps);
                return dataMaps;
            }
        } catch (Exception ex) {
            System.debug('Message::' + ex.getMessage() + '  ' + 'Line Number::' + ex.getLineNumber());
            return null;
        }
        return null;
    }
}