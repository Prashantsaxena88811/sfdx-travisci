trigger LeadTrigger on Lead (after insert, after update,before insert) {
    LeadTriggerHelper.leadNewList = Trigger.new;
    LeadTriggerHelper.leadOldList = Trigger.old;
    LeadTriggerHelper.leadNewMap = Trigger.newMap;
    LeadTriggerHelper.leadOldMap = Trigger.oldMap;
    
    if(trigger.IsAfter && (trigger.IsInsert  ||  trigger.IsUpdate)){
        LeadTriggerHelper.createCampaignMember();
    }
    
    if(trigger.IsAfter &&  trigger.IsUpdate){
        LeadTriggerHelper.populateSDRonAccountonLeadConvert();
    }
    System.debug(trigger.IsBefore+'*********************************'+trigger.IsInsert+'--'+trigger.IsUpdate);
    if( trigger.IsBefore &&  (trigger.IsInsert ||trigger.IsUpdate ) ){
        System.debug('*********************************');
       LeadTriggerHandler.leadRoundRobin(Trigger.new, Trigger.OldMap);
    }    
}