trigger OpportunityTrigger on Opportunity (after insert,after update,before insert ,before update) {
    OpportunityTriggerHelper.opportunityNewList = Trigger.new;
    OpportunityTriggerHelper.opportunityOldList = Trigger.old;
    OpportunityTriggerHelper.opportunityNewMap = Trigger.newMap;
    OpportunityTriggerHelper.opportunityOldMap = Trigger.oldMap;
    
    if(Trigger.IsAfter && (Trigger.IsInsert || Trigger.IsUpdate)){
        OpportunityTriggerHelper.createFollowUpcases();
        //if(Trigger.IsInsert){
            OpportunityTriggerHandlerSPIF.creatSPIFRecord(Trigger.new);
        //}
    }
    if(Trigger.IsBefore && (Trigger.IsInsert || Trigger.IsUpdate)){
        OpportunityTriggerHelper.validateOpportunityUpdation();
        if(Trigger.IsUpdate){
            OpportunityTriggerHandler.createDualOpportunities(Trigger.New,Trigger.OldMap);  
        }
        if(Trigger.IsInsert){
            OpportunityTriggerHandler.populateSDRFromCloseWonOpp(Trigger.New);
            OpportunityTriggerHandler.createDualOpportunities(Trigger.New,Trigger.OldMap);  
            
        } 
        
    }
    
}