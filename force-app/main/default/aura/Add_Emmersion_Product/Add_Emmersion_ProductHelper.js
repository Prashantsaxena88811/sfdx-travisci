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
    calculateProductPrice_helper : function(component ,event , helper , isProdSave){
        try{
            
            
            console.log('**calculateProductPrice_helper**');
            var action = component.get("c.getAllPrices");
            var productIds = [];
            var  emmersionProductList = component.get("v.emmersionProductList");
            console.log('************22********');
            for(let index=0; index<emmersionProductList.length ; index++){
                productIds.push(emmersionProductList[index].selectedRecord.value);
            }
            console.log(productIds);
            
            action.setParams(
                { selectedProIds : productIds,pricingType :component.get('v.pricingType') });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    //alert("From server: " + response.getReturnValue());
                    console.log('calculateProductPrice_helper');
                    console.log(response.getReturnValue());
                    if(response.getReturnValue() !=null){
                       helper.addPriceToProducts(component ,event , helper ,response.getReturnValue(),isProdSave); 
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
            console.log('calculateProductPrice_helper-->'+err.message);
        }
    },
    addPriceToProducts : function(component ,event , helper , priceList , isProdSave){
        try{ 
            console.clear();
            let prodLength = component.get('v.emmersionProductList').length;
            let productsList = component.get('v.emmersionProductList');
            let priceListLength = priceList.length;
            console.log(productsList);
            console.log(priceList);
            for(let prodIndex=0 ;prodIndex<prodLength;prodIndex++ ){
                for(let priceIndex=0 ;priceIndex<priceListLength;priceIndex++){
                    if( priceList[priceIndex].Tier__c>=productsList[prodIndex].Quantity && productsList[prodIndex].Quantity >= priceList[priceIndex].Tier_From__c ){
                        console.log('****************************'+priceList[priceIndex].Monthly_Price_Per_Test__c);
                        productsList[prodIndex].Price = priceList[priceIndex].Monthly_Price_Per_Test__c;
                        break;
                    }
                }
            }
            component.set('v.emmersionProductList',productsList);
        }catch(err){
            console.log('get exception in addPriceToProducts->'+err.message);
        }
    }, 
    
    /*fetchEmmerision_helper  : function(component ,event , helper , isProdSave){
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
                    helper.calculatePirce_helper(component ,event , helper,response.getReturnValue() , isProdSave); 
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
    },*/
    /*calculatePirce_helper :  function(component ,event , helper , emmersionPriceMapping , isProdSave){
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
                console.log('*************************selectedRecord*********');
                console.log(emmersionProductList[index]['selectedRecord']);
                console.log('*************************Quantity*********');
                console.log(emmersionProductList[index]['Quantity']);
                console.log('*************************BillingTerm*********');
                console.log(emmersionProductList[index]['BillingTerm']);
                if( (emmersionProductList[index]['selectedRecord']['value']== null) || emmersionProductList[index]['Quantity'] =='' ){
                    console.log('*BLANK*');
                    helper.showToastMessages_helper(component, event, helper ,'error' , 'Add Product  name and Quantity in all rows');
                	return;
                }
                if(emmersionProductList[index]['Quantity'] <100 || emmersionProductList[index]['Quantity'] >100000 ){
                    helper.showToastMessages_helper(component, event, helper ,'error' , 'Product Quantity between 100 and 100000');
                	return;
                }
                
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
                            
                        }else if(quantityVal==emmersionPriceList[len].Tier__c){
                            if( emmersionProductList[index]['BillingTerm'] == 'Monthly'){
                                emmersionProductList[index]['Price'] =  emmersionPriceList[len].Monthly_Price_Per_Test__c;  
                            }else{
                                emmersionProductList[index]['Price'] =  emmersionPriceList[len].Annual_Price_Per_Test__c; 
                            }
                            break;
                        }
                    }
                }
            }
            console.log('after prices updated-->'+JSON.stringify(emmersionProductList));
            component.set("v.emmersionProductList",emmersionProductList);
            if(isProdSave){
               helper.passValueToServer(component ,event , helper , emmersionProductList);   
            }
			       
            
            
        }catch(e){
            console.log(e.message);
        }
    },*/
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
    },
    saveProducts_helper : function(component ,event , helper){
        helper.fetchEmmerision_helper(component ,event , helper , true)
        //helper.passValueToServer(component ,event , helper , component.get("v.emmersionProductList")); 
    },
    showToastMessages_helper : function(component ,event , helper , msgType , errMsg){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : msgType,
            message: errMsg,
            duration:' 5000',
            key: 'info_alt',
            type: msgType,
            mode: 'dismissible'
        });
        toastEvent.fire();
    }
})