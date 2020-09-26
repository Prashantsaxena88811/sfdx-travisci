({
    doInit : function(component, helper) {
        var objectVar = component.get('v.objectVar');
        var FieldName = component.get('v.fieldName');
        var showField = component.get('v.showField');
        var outputText = component.find("outputTextId");

        
        //console.log('filter obj ',component.get('v.filterObj'));
        var placeholder = FieldName.replace("_", " ").replace(/\s(.)/g, function(a) { 
            return a.toUpperCase(); 
        }).replace(/\s/g, '').replace(/^(.)/, function(b) { 
            return b.toLowerCase(); 
        }); 
        component.set('v.placeholder', placeholder);
        component.set('v.showClr',false); 
        if(showField){
            if( FieldName == 'product_no') {
                //component.find("oURL").getElement();
            }
            else
            outputText.set("v.value",objectVar[FieldName]);
        }
        
    },

    filterChangeHandler : function(component,event, helper) {
        console.log('filterChangeHandler **');
        var objectVar = component.get('v.objectVar');
        var FieldName = component.get('v.fieldName');
        var filterValue = component.get('v.filterValue');
        objectVar[FieldName] = filterValue ;
        component.set('v.objectVar' , objectVar) ;
        var cmpEvent = $A.get("e.c:componentEventFilter");
        cmpEvent.setParams({"param": "filter"});
        cmpEvent.fire();
    },
    //KDS-33
    clearColumnSearch : function (component, event, helper) {
        component.set('v.filterValue','');
        component.set('v.showClr',false); 
        var objectVar = component.get('v.objectVar');
        var FieldName = component.get('v.fieldName');
        var filterValue = component.get('v.filterValue');
        objectVar[FieldName] = filterValue ;
        component.set('v.objectVar' , objectVar) ;
        var cmpEvent = $A.get("e.c:componentEventFilter");
        cmpEvent.setParams({"param": "filter"});
        cmpEvent.fire();
        
    },
    showClear: function (component, event, helper) {
        var filterValue = component.get('v.filterValue');
        if(filterValue == null || filterValue == ''){
		     component.set('v.showClr',false);       
        }
        else{
            component.set('v.showClr',true);  
        }
    },
    clearFilterval: function (component, event, helper) {
        component.set('v.filterValue','');
        component.set('v.showClr',false); 
        
        //var action = component.get('c.filterChangeHandler');
        //$A.enqueueAction(action);
    },
    openModalBox : function (component, event, helper) {
        component.set('v.openModal', true);
    },
    closeModal : function (component, event, helper) {
        component.set('v.openModal', false);
    }
})