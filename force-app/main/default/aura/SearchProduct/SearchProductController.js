({
	next : function(component, event, helper) {
      // get the current selected tab value
        var currentTab = component.get("v.selTabId");
        
        if(currentTab == '1'){
          component.set("v.selTabId" , '2');   
        }else if(currentTab == '2'){
          component.set("v.selTabId" , '3');     
        }else if(currentTab == '3'){
           alert('Complete !');             
        }else if(currentTab == '4'){
             alert('Complete !');  
        } 
	},
    
    back : function(component, event, helper) {
     // get the current selected tab value  
       var currentTab = component.get("v.selTabId");
        
        if(currentTab == '2'){
          component.set("v.selTabId" , '1');     
        } else if(currentTab == '3'){
          component.set("v.selTabId" , '2');     
        }else if(currentTab == '4'){
          component.set("v.selTabId" , '3');     
        } 
	}
})