({
    addRowHelper : function(component ,event , helper) {
        var emmersionProductListVar = component.get("v.emmersionProductList");
        emmersionProductListVar.push({
            'selectedRecord': '',
            'Quantity': ''
        });
        console.log(emmersionProductListVar);
        component.set("v.emmersionProductList", emmersionProductListVar);
    },
    passValueToServer : function(component ,event , helper , emmersionProductList){
        try{
            var action = component.get("c.insertLineItems");
            console.log('send to server-->'+JSON.stringify(emmersionProductList));
            action.setParams(
                { SelectedProdList : JSON.stringify(emmersionProductList) , OpportunityId : component.get('v.recordId')
                }
            );
            action.setCallback(this, function(response) {
                var state = response.getState();
                component.set('v.loaded',false);
                if (state === "SUCCESS") {
                      helper.showToastMessages_helper(component, event, helper ,'success' , 'Opportunity Product Saved Successfully');
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                        $A.get('e.force:refreshView').fire();
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        let errorMsg = '';
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                            errors[0].message);
                                errorMsg = errors[0].message;
                            }
                        } else {
                            console.log("Unknown error");
                            errorMsg ='Unknown error';
                        }
                        helper.showToastMessages_helper(component, event, helper ,'error' , errorMsg);
                    }
            });
            $A.enqueueAction(action);
        }catch(err){
            console.log(err.message);
        }
    },
    saveProducts_helper : function(component ,event , helper){
        //helper.fetchEmmerision_helper(component ,event , helper , true)
        helper.passValueToServer(component ,event , helper , component.get("v.emmersionProductList")); 
    },
    showToastMessages_helper : function(component ,event , helper , msgType , errMsg){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error Message',
            message: errMsg,
            duration:' 5000',
            key: 'info_alt',
            type: msgType,
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    ProductAddRemoveEv_helper : function(component ,event , helper,index){
        let productInfo = component.get('v.emmersionProductList')[index];
        console.log('productInfo=>'+JSON.stringify(productInfo));
        var action = component.get("c.getProductPrices");
        action.setParams({ OpportunityId : component.get('v.recordId'),
                           productId : productInfo.selectedRecord.value });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Add product helper==>'+state);
            if (state === "SUCCESS") {
                alert("From server: " + response.getReturnValue());
                let emmersionProductListVar = component.get('v.emmersionProductList');
                emmersionProductListVar[index].Price = response.getReturnValue();
                component.set('v.emmersionProductList',emmersionProductListVar);
                console.log('emmersionProductListVar new price=> '+JSON.stringify(emmersionProductListVar));
                
            }
            else if (state === "INCOMPLETE") {
                // do something
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
        
    }
})