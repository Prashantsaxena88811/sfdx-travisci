public class LeadTriggerHandler {
    
    public Static void leadRoundRobin(List<Lead> newLeadList , Map<Id,Lead> oldLeadMap){
        try{
            // get the users from custom setting.
            List<Lead_Round_Robin__c> userList = new List<Lead_Round_Robin__c>();
            userList = [SELECT Id,SetupOwnerId , date__c FROM Lead_Round_Robin__c order by date__c asc];
            System.debug('userList-->'+userList);
            // sort the userIds based upon the date.
            User userObj = [Select Id from user where Username =:'contact@emmersionlearning.com.dev1'];// store username in custom label
            Integer count = 0;
            for(Lead leadObj : newLeadList){
                System.debug(leadObj.ownerId+'--leadObj.ownerId-->'+userObj.Id);
                if(leadObj.ownerId == userObj.Id){
                    
                    leadObj.ownerId = userList[count].SetupOwnerId;
                    userList[count].date__c = Datetime.now();
                    count =count +1;
                    if( count == userList.size() ){
                        System.debug('before reseeting the value---->'+count);
                        count =0;
                    }
                }
            }
            
            update userList;
        }catch(Exception e){
            System.debug('Exception on Line number-->'+e.getMessage()+'-error is line number-->'+e.getLineNumber());
        }
        
        
    }
    
}