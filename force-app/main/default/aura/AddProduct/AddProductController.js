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
    calculatePrice : function(component, event, helper) {
        helper.fetchEmmerision_helper(component, event, helper,false);
    }, 
    saveProducts :  function(component, event, helper) {
        let productList = component.get('v.emmersionProductList');
        let prodListLength = productList.length;
        for(let index=0;index<prodListLength;index++){
            if((productList[index]['selectedRecord']['value']== null) ){
                helper.showToastMessages_helper(component, event, helper ,'error' , 'Add Product  name  in all rows');
                return;
            }
            if(productList[index]['Quantity'] ==''){
                helper.showToastMessages_helper(component, event, helper ,'error' , 'Add Quantity in all rows');
                return;
            }
            if(productList[index]['Price'] =='' || productList[index]['Price'] ==null){
                helper.showToastMessages_helper(component, event, helper ,'error' , 'Add Price in all rows');
                return;                
            }
        }
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
    ProductAddRemoveEv : function(component, event, helper){
        alert('ProductAddRemoveEv');
        var message = event.getParam("message"); 
        var index = event.getParam("index");
        console.log(message+'--'+index);
        if(message == 'Item Added'){
            helper.ProductAddRemoveEv_helper(component, event, helper,index);
        }else if(message == 'Item Removed'){
            // set price to null for that index
            let emmersionProductListVar = component.get('v.emmersionProductList');
            emmersionProductListVar[index].Price = '';
            emmersionProductListVar[index].Quantity = '';
            component.set('v.emmersionProductList',emmersionProductListVar);
        }
        
    }
})