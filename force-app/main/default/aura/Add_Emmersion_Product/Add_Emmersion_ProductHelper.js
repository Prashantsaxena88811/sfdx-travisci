({
    addRowHelper : function(component ,event , helper) {
        var emmersionProductListVar = component.get("v.emmersionProductList");
        emmersionProductListVar.push({
            'selectedRecord': '',
            'BillingTerm': 'Monthly',
            'Quantity': '',
            'Price': ''
        });
        console.log(emmersionProductListVar);
        component.set("v.emmersionProductList", emmersionProductListVar);
    },
    fetchEmmerision_helper  : function(component ,event , helper){
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        console.log('************11********');
        //var productPriceMapping;
        var productIds = [];
        var  emmersionProductList = component.get("v.emmersionProductList");
        console.log('************22********');
        for(let index=0; index<emmersionProductList.length ; index++){
            productIds.push(emmersionProductList[index].selectedRecord.value);
        }
        console.log(productIds);
        var action = component.get("c.emmersionPricingCal");
        action.setParams({ selectedProIds : productIds });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                if(response.getReturnValue() !=null){
                    helper.calculatePirce_helper(component ,event , helper,response.getReturnValue()); 
                }
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
    },
    calculatePirce_helper :  function(component ,event , helper , emmersionPriceMapping){
        try{
            console.log(emmersionPriceMapping);
            console.log('*************');
            var priceVar = emmersionPriceMapping;
            console.log(priceVar) ;
            console.log(Object.keys(priceVar)) ;
            //console.log(priceVar['01t7g000005DFtVAAW']) ;
            let emmersionProductListLength = component.get("v.emmersionProductList").length;
            let emmersionProductList= component.get("v.emmersionProductList");
            let quantityVal;
            let tierVal;
            let emmersionPriceLength;// tier length of product
            let productId;
            let emmersionPriceList;
            for(let index=0;index<emmersionProductListLength;index++){
                productId = emmersionProductList[index]['selectedRecord']['value'];
                console.log(JSON.stringify(emmersionProductList[index]));
                console.log(productId);
                //tierVal = emmersionProductList[index]
                if(priceVar.hasOwnProperty(productId)){
                    console.log('**********44**');
                    emmersionPriceLength = priceVar[productId].length;
                    emmersionPriceList = priceVar[productId];
                    console.log('emmersionPriceLength->'+emmersionPriceLength);
                    console.log('emmersionPriceList->'+JSON.stringify(emmersionPriceList));
                    quantityVal = emmersionProductList[index]['Quantity'];
                    for(let len=0;len<emmersionPriceList.length;len++){
                        if(quantityVal<emmersionPriceList[len].Tier__c){
                            console.log('billing term11 ====>'+JSON.stringify(emmersionProductList[index]));
                            if( emmersionProductList[index]['BillingTerm'] == 'Monthly'){
                                emmersionProductList[index]['Price'] =  emmersionPriceList[len-1].Monthly_Price_Per_Test__c;  
                            }else{
                                emmersionProductList[index]['Price'] =  emmersionPriceList[len-1].Annual_Price_Per_Test__c; 
                            }
                            break;
                            
                        }
                    }
                }
            }
            console.log('after prices updated-->'+JSON.stringify(emmersionProductList));
            component.set("v.emmersionProductList",emmersionProductList);
			helper.passValueToServer(component ,event , helper , emmersionProductList);         
            
            
        }catch(e){
            console.log(e.message);
        }
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
                if (state === "SUCCESS") {
                    console.log(response.getReturnValue());
                    if(response.getReturnValue() !=null){
                        
                    }
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
        }catch(err){
            console.log(err.message);
        }
    }
})