public without sharing class CustomModalClass {
    
    public class UserDetail{
       @AuraEnabled public String userId {get; set;}
       @AuraEnabled public String userName {get; set;}
   }
    
    public CustomModalClass() {

    }

    @AuraEnabled(cacheable=true)
    public static String returnEmailUserCont(){
        Contact cont = [Select Id, Email from Contact where Id in (Select ContactId from user where id = :UserInfo.getUserId())];
        if(cont!=null){
            system.debug('cont.Email---'+cont.Email);
            return cont.Email;
        }else{
            return null;
        }
        //Contact userContact = [Select Email, Id from Contact where Id = :contactId[0].ContactId];
        
    } 

    /*@AuraEnabled(cacheable=true)
    public static List < sObject > fetchLookUpValues(String searchKey,String fieldName, String ObjectName,String keyField) {
        List < sObject > returnList = new List < sObject > ();
        String sQuery =  'select '+fieldName+','+keyField+ ' from '+ObjectName+' LIMIT 5000' ;
        List < sObject > lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }*/

    @AuraEnabled(cacheable=true)  
    public static List<UserDetail> fetchLookUpValuesUser(String searchKey, String objectName) { 
        List<UserDetail> userDetails = new List<UserDetail>();
        string searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';  
        
        String mainQuery = 'SELECT Id, Name, FirstName, LastName FROM User WHERE Name LIKE '+searchText;
        String whereClaus = ' and Id in (SELECT MemberId FROM NetworkMember where Network.name=\'Group Management\')';
        system.debug(mainQuery+whereClaus);
        List<User> users = Database.query(mainQuery+whereClaus);//[SELECT Id, FirstName, LastName, Name FROM User WHERE Name LIKE :searchText]; 
        if(!users.isEmpty() && users != null){
            for(User u: users){
                UserDetail uObj = new UserDetail();
                uObj.userId = u.Id;
                uObj.userName = u.FirstName + ' ' + u.LastName;
                userDetails.add(uObj);
            }
        }
        system.debug('userDetails-->'+userDetails);
        system.debug('searchText-->'+searchText);
        return userDetails;
    }

    @AuraEnabled(cacheable=true)  
    public static List<sobject> fetchLookUpValuesGroup(String searchKey, String objectName) {
        string searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';  
        //string query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText;  
        return Database.query('SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText);  
    }
    
     @AuraEnabled
    public static boolean matchUser(String UserId, String ContactEmail, String GroupId) {  
       
        Contact cont = [Select Id, Email from Contact where Id in (Select ContactId from user where id = :UserId)];
        if(cont != null && ContactEmail != null){
            String firstEmail = cont.Email.split('@')[1];
            String secondEmail = ContactEmail.split('@')[1];
            System.debug('firstEmail'+firstEmail);
            System.debug('secondEmail'+secondEmail);
            if(firstEmail == secondEmail) {
                createGroupRecord(UserId, GroupId);
                return true;
            }else{
                return false;
            }
        }else{
            return false;
        }
   }
    public static void createGroupRecord(String userId, String GroupId){
        /*GroupMember groupMemberRec=new GroupMember();
        groupMemberRec.GroupId=(Id)GroupId;
        groupMemberRec.UserOrGroupId=(Id)userId;
        system.debug('GroupId---'+GroupId+'---userId---'+userId);
        insert groupMemberRec;*/
        CollaborationGroupMember member = new CollaborationGroupMember();
        member.MemberId = userId ;
        member.CollaborationGroupId = GroupId ;
        insert member;
    }  

}