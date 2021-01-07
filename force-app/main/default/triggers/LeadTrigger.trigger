trigger LeadTrigger on Lead (after insert, after update,before insert , before update) {
    LeadTriggerHelper.leadNewList = Trigger.new;
    LeadTriggerHelper.leadOldList = Trigger.old;
    LeadTriggerHelper.leadNewMap = Trigger.newMap;
    LeadTriggerHelper.leadOldMap = Trigger.oldMap;
    
    if(trigger.IsAfter && (trigger.IsInsert  ||  trigger.IsUpdate)){
        LeadTriggerHelper.createCampaignMember();
    }
    
    
    if( trigger.IsBefore &&  (trigger.IsInsert ||trigger.IsUpdate ) ){
        System.debug('*********************************');
       LeadTriggerHandlerRoundRobin.leadRoundRobin(Trigger.new, Trigger.OldMap);
    }    
}