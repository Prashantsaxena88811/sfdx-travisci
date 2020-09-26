/**
 * Created by Krishna on 19-09-2020.
 */

public with sharing class userPreferenceServerController {
    @AuraEnabled(cacheable=true)
    public static List<Asset_Filters__c> getAssetFilters() {
        try {
            List<Asset_Filters__c> assetFilterList = [select id, Name, isactive__c from Asset_Filters__c where createdbyId =:userinfo.getuserid()];
            /*Map<String,Boolean> resMap = new Map<String,Boolean>();
            for(Asset_Filters__c rec : assetFilterList){
                resMap.put('name', rec.name);
                resMap.put('value', rec.isactive__c);
            }*/
            return assetFilterList;

        } catch (Exception ex) {
            System.debug('Message::' + ex.getMessage() + '  ' + 'Line Number::' + ex.getLineNumber());
            return null;
        }
    }
    
    @AuraEnabled
    public static Boolean setAssetFilters(List<Asset_Filters__c> incomingList) {
        system.debug('incomingList::'+incomingList);
        try {
            update incomingList;
            return true;

        } catch (Exception ex) {
            System.debug('Message::' + ex.getMessage() + '  ' + 'Line Number::' + ex.getLineNumber());
            return false;
        }
    }
}