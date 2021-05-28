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
        let functionName ='';
        //console.log('pricingType=>'+)
        if(component.get('v.pricingType').toLowerCase() == 'Bulk Order'.toLowerCase() || component.get('v.pricingType').toLowerCase() == 'Subscription'.toLowerCase() 
           || component.get('v.pricingType').toLowerCase() == 'Postpaid'.toLowerCase()){
            console.log('c.getAllPrices');
            functionName = "c.getAllPrices"; 
        }else{
            console.log('c.getAllStandardPrices');
            functionName = "c.getAllStandardPrices"; 
        }
        
        helper.calculateProductPrice_helper(component, event, helper,false,functionName);
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
        component.set('v.emmersionProductList',[]);
        helper.addRowHelper(component ,event , helper);
    },
    ProductAddRemoveEv : function(component, event, helper){
        try{
            //alert('Item Removed');
            var message = event.getParam("message"); 
            console.log('message=>'+message);
            var index = event.getParam("index");
            console.log('index=>'+index);
            if(message == 'Item Removed'){
                console.log('INNNNNNNNNNNNN');
                // set price to null for that index
                let emmersionProductListVar = component.get('v.emmersionProductList');
                console.log(emmersionProductListVar);
                emmersionProductListVar[index].Price = '';
                emmersionProductListVar[index].Quantity = '';
                component.set('v.emmersionProductList',emmersionProductListVar);
            }
        }catch(err){
            console.log('exception in ProductAddRemoveEv=>'+err.message);
        }
        
    },
    
    
    
})