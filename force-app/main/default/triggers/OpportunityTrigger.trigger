trigger OpportunityTrigger on Opportunity (after insert,after update,before insert ,before update) {
    OpportunityTriggerHelper.opportunityNewList = Trigger.new;
    OpportunityTriggerHelper.opportunityOldList = Trigger.old;
    OpportunityTriggerHelper.opportunityNewMap = Trigger.newMap;
    OpportunityTriggerHelper.opportunityOldMap = Trigger.oldMap;
     
    if(Trigger.IsAfter && (Trigger.IsInsert || Trigger.IsUpdate)){
        OpportunityTriggerHelper.createFollowUpcases();
        if(Trigger.IsUpdate){
           OpportunityTriggerHandler.createDualOpportunitiesBeforeUpdate(Trigger.New , Trigger.OldMap);  
        }
    }
    if(Trigger.IsBefore && (Trigger.IsInsert || Trigger.IsUpdate)){
        OpportunityTriggerHelper.validateOpportunityUpdation();
       /* if(Trigger.IsUpdate){
           OpportunityTriggerHandler.createDualOpportunities(Trigger.New);  
        }*/
    }
    
    if(Trigger.IsBefore && Trigger.IsInsert){
        //OpportunityTriggerHelper.populateSDRFromAccount();
        OpportunityTriggerHandler.populateSDRFromCloseWonOpp(Trigger.New);
         OpportunityTriggerHandler.createDualOpportunitiesBeforeInsert(Trigger.New);  
        
    }    
}