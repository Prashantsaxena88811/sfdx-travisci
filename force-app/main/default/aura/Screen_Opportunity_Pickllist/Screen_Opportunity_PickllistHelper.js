({
    init_helper : function(component, event, helper) {
        try{
            var action = component.get("c.getTypeFieldValue");
            action.setParams(
                { 
                    OpportunityId : component.get("v.recordId") 
                    
                });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    //alert("From server: " + response.getReturnValue());
                    if(response.getReturnValue() !=null ){
                        component.set('v.optionsType',response.getReturnValue().pickListDataType);  
                        component.set('v.optionscurrency',response.getReturnValue().pickListDatacurrency);  
                    }
                }
                else if (state === "INCOMPLETE") {
                    
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                            errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
            });
            
            $A.enqueueAction(action);
        }catch(e){
            console.log('error in init_helper=>'+e.message);
        }
        
    }
})