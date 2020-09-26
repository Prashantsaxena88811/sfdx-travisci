/**
 * Created by awish on 27-08-2020.
 */

public with sharing class AssetManagementComponent_Controller {
    @AuraEnabled
    public static string getAssetsUpgrade_APEX(String bodyData) {
        //Asset_Filters__c af = [ SELECT Id, Name, Filter_Fileds__c FROM Asset_Filters__c WHERE OwnerId=: UserInfo.getUserId()];
        //
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('http://34.209.52.101:8080/dcxservice/asset/search');
            request.setBody(bodyData);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            HttpResponse response = http.send(request);
            String res = response.getBody();
            //System.debug(res);
            /*Map<String,Object> mySitesResponse = (Map<String,object>)JSON.deserializeUntyped(response.getBody());
            Map<String,Object> mySitesResponseResp = (Map<String,object>)JSON.deserializeUntyped(Json.serialize((mySitesResponse.get('resp'))));*/
            return res;

        } catch (Exception ex) {
            System.debug('Message::' + ex.getMessage() + '  ' + 'Line Number::' + ex.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static string saveAsset(Map<String,Object> data) {
        return null;
    }


    @auraEnabled
    public static List<Asset_Filters__c> saveAssetFilter( String filterName, String filterFields, Boolean isExisting, Boolean init ) {
        if( !init ) {
            if( !isExisting ) {
                Asset_Filters__c af = new Asset_Filters__c( name = filterName,
                                                            OwnerId = UserInfo.getUserId(),
                                                            Filter_Fileds__c = filterFields
                                                            );
                insert af;
            }
            else {
                Asset_Filters__c af = [ SELECT Id, Name, Filter_Fileds__c FROM Asset_Filters__c WHERE OwnerId=: UserInfo.getUserId() AND Id=: filterName AND RecordType.DeveloperName <> 'My_Asset' LIMIT 1];
                af.Filter_Fileds__c = filterFields;
                update af;
            }
        }

        return [SELECT Id,Filter_Fileds__c, Name FROM Asset_Filters__c WHERE OwnerId =: UserInfo.getUserId() AND RecordType.DeveloperName <> 'My_Asset'];
    }

    @auraEnabled
    public static List<Asset_Filters__c> deleteAssetFilter( String assetFilterId ) {
        if( !String.isBlank(assetFilterId) ) {
            delete [SELECT Id FROM Asset_Filters__c WHERE id =: assetFilterId];
        }
       

        return [SELECT Id,Filter_Fileds__c, Name FROM Asset_Filters__c WHERE OwnerId =: UserInfo.getUserId() AND RecordType.DeveloperName <> 'My_Asset'];
    }

    @auraEnabled
    public static String upsertMyAssets (String myAssetIds, Boolean init ) {
        if( !init ) {
            Asset_Filters__c af = null;
        for( Asset_Filters__c afil : [SELECT Id,My_Asset_Ids__c FROM Asset_Filters__c WHERE OwnerId =: UserInfo.getUserId() AND RecordType.DeveloperName='My_Asset' LIMIT 1]){
            af = afil;
        }
        
        if( af == null) {
            Id rtId = [SELECT Id FROM RecordType WHERE DeveloperName='My_Asset' AND SobjectType='Asset_Filters__c'].Id;
            af = new Asset_Filters__c();
            af.Name = 'My Asset';
            af.OwnerId = UserInfo.getUserId();
            
            af.RecordTypeId = rtId;
        }
        
        af.My_Asset_Ids__c = myAssetIds;
        
        upsert af;
    }
        return [SELECT Id,My_Asset_Ids__c FROM Asset_Filters__c WHERE OwnerId =: UserInfo.getUserId() AND RecordType.DeveloperName='My_Asset' LIMIT 1].My_Asset_Ids__c;
    }

    /*Added by Vishwas Team */
    @auraEnabled
    public static String createSupportCase(String caseType,String caseAssest,String casePriority, String caseSubject, String caseDescription) {
        String flag = 'False';
        if(caseType!=NULL && caseAssest!=NULL && casePriority!=NULL && caseSubject!=NULL && caseDescription!=NULL){
            try{
                Case cs = new Case();
                cs.Subject = caseSubject;
                cs.Description = caseDescription;
                cs.Priority = casePriority;
                cs.Type__c = caseType;
                cs.Asset__c = caseAssest;
                cs.Status = 'New';
                cs.Origin = 'Web';
                insert cs;
                flag = 'Case Created';
            }catch(Exception ex){
                flag = ex.getMessage();
            }

        }else{
            flag = 'Field problem';
        }
        return flag;
    }


}