({
    init : function(component, event, helper) {
        var p = component.get("v.parent");
        var selectedAssets = p.get("v.data");
        selectedAssets.forEach(element => {
            if (element.isChecked) {
                console.log('found one ');
                component.set("v.selectedAsset", element);
            }
        });
    },
    closeModal : function(component, event, helper) {
        var p = component.get("v.parent");
        p.set('v.showCreateAsset',false)
    },
    createCase : function(component, event, helper) {
        var value = event.getParam('detail');
        console.log('case value '+value);
        var p = component.get("v.parent");
        p.set('v.showCreateAsset',false)
        /* var SupportcaseNumberField = component.find("SupportcaseNumber");
        var SupportcaseNumber =  SupportcaseNumberField.get("v.value");
        
        var ProductField = component.find("product");
        var origin =  ProductField.get("v.value");
        
        var SerialNumberField = component.find("SerialNumber");
        var SerialNumber =  SerialNumberField.get("v.value");
        
        var HostIDField = component.find("HostID");
        var HostID =  HostIDField.get("v.value");
        
        var TypeField = component.find("Type");
        var Type =  TypeField.get("v.value");
        
        var StatusField = component.find("Status");
        var Status =  StatusField.get("v.value");
        
        var SubjectField = component.find("Subject");
        var Subject =  SubjectField.get("v.value");
        
        
        
        
        var newCase = component.get('v.newCase');
        newCase.SupportcaseNumber = SupportcaseNumber;
        newCase.Product = Product;
        newCase.SerialNumber = SerialNumber;  
        newCase.HostID  = HostID ;  
        newCase.Type = Type ;    
        newCase.status = status;
        newCase.subject = subject;  
        
        console.log(newCase);
        helper.createCase(component, newCase);
        console.log('End of createCase'); */
        
    },
    /* doSomething : function(component,event, helper) {
        console.log('Hey There .. the anchor was clicked');
        console.log(event);
        var href = event.srcElement.href;
        console.log(href);
        // var setflag = component.get("v.user.firstName")
        component.set("v.isEnable", true);
    },
    caseSelectcontinue : function(component,event, helper) {
        console.log('Hey There .. the anchor was clicked');
        console.log(event);
        var href = event.srcElement.href;
        console.log(href);
        // var setflag = component.get("v.user.firstName")
        component.set("v.isEnable1", true);
        component.set("v.isEnable", false);
        component.set("v.firstsection", false); 
    },
    back :function(component,event, helper) {
         component.set("v.isEnable1", false);
        component.set("v.isEnable", true);
        component.set("v.firstsection", true); 
    },
    continue1 : function(component,event, helper) {
        console.log('Hey There .. the anchor was clicked');
        console.log(event);
        var href = event.srcElement.href;
        console.log(href);
        // var setflag = component.get("v.user.firstName")
        component.set("v.isEnable2", true);
        component.set("v.isEnable1", false);
    } */
})