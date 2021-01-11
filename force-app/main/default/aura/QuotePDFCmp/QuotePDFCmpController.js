({
    
    doInit : function(component, event, helper) {
        
        //alert(component.get("v.recordId"));;
        
        var recId = component.get("v.recordId");
        
        //get base url 
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        component.set("v.cbaseURL", baseURL); 
        
    },
    
    handleSave: function(component, event, helper) {
        var action = component.get("c.SavePDF");
        
        action.setParams({ recId : component.get("v.recordId")});
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            //alert(state);
            
            if (state === "SUCCESS") {
                
                var toastEvent = $A.get("e.force:showToast");
                
                
                
                toastEvent.setParams({
                    
                    title : 'Success',
                    
                    message: 'PDF save successfully',
                    
                    duration:' 5000',
                    
                    key: 'info_alt',
                    
                    type: 'success',
                    
                    mode: 'pester'
                    
                });
                
                toastEvent.fire();
                
            }
            
            
            
        });
        
        
        
        
        
        $A.enqueueAction(action);
        
        $A.get("e.force:closeQuickAction").fire();
        
    },
    
    
    
    handleClose:function(component, event, helper) {
        
        $A.get("e.force:closeQuickAction").fire();
        
    },
    
})