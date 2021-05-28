({
    doInit : function(component, event, helper) {
        helper.addRowHelper(component, event, helper);
    },
    handleClick : function(component, event, helper) {
        console.log(component.get('v.selectedRecord'));
        console.log('**********************************');
        console.log(component.get('v.emmersionProductList'));
    },
    addRows : function(component, event, helper) {
        helper.addRowHelper(component, event, helper);
    },
    /*calculatePrice : function(component, event, helper) {
        helper.fetchEmmerision_helper(component, event, helper,false);
    }, */
    calculateProductPrice : function(component, event, helper) {
        console.log('**calculateProductPrice**');
        helper.calculateProductPrice_helper(component, event, helper,false);
    },
    saveProducts :  function(component, event, helper) {
        helper.saveProducts_helper(component, event, helper);
    }, 
    removeRow : function(component, event, helper) {
        console.log('removeRow->'+event.currentTarget.id);
        let itemRemove = event.currentTarget.id;
        let emmersionProductListVar = component.get("v.emmersionProductList");
        emmersionProductListVar.splice(itemRemove,1);
        component.set("v.emmersionProductList",emmersionProductListVar);
        //helper.fetchEmmerision_helper(component, event, helper);
    },
    showToastMessages : function(component, event, helper){
        helper.showToastMessages_helper(component, event, helper ,'error');
    },
    onChange :  function(component, event, helper){
        //helper.showToastMessages_helper(component, event, helper ,'error');
    },
    
    
    
})