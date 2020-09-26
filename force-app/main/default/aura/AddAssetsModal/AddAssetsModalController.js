({
	closeModal : function(component, event, helper) {
        var p = component.get("v.parent");
        p.set('v.showAddAssets',false);
         p.set('v.showEditAssets',false);
	},
    init : function(component,event,helper) {
         var p = component.get("v.parent");
        
        if(p.get("v.showEditAssets") == true){
            component.set('v.header',true);
            component.set('v.createAsset',true);
            component.set('v.toggleHeader',false);
            component.set('v.createAssetSelection',false);
            component.set('v.importMultipleAssets',false);
            component.set('v.assetCreated',false);
            component.set('v.titlename','Edit Asset'); 
            component.set('v.editasset',true);
        }else{
            component.set('v.editasset',false);
              component.set('v.titlename','Create a single asset'); 
        }
    },
    createSingleAsset :function(component,event,helper){
        component.set('v.header',true);
        component.set('v.createAsset',true);
        component.set('v.toggleHeader',false);
        component.set('v.createAssetSelection',false);
        component.set('v.importMultipleAssets',false);
        component.set('v.assetCreated',false);
    },
    
    createMultipleAssets : function(component,event,helper){
        component.set('v.importMultipleAssets',true);
        component.set('v.header',false);
        component.set('v.createAsset',false);
        component.set('v.toggleHeader',false);
        component.set('v.createAssetSelection',false);
    },
    
    showAssetSelection :function(component,event,helper){
        component.set('v.assetCreated',false);
        component.set('v.createAsset',false);
        component.set('v.toggleHeader',true);
        component.set('v.createAssetSelection',true);
    },
    
    createAsset : function(component,event,helper){

        component.set('v.createAsset',false);
        component.set('v.header',false);
        helper.showToast(component,event,helper,'Success!','success','Please give us a few seconds while your asset is being added');
        
        window.setTimeout(
            $A.getCallback(function() {
                
                component.set('v.toggleHeader',true);
                component.set('v.assetCreated',true);
            }), 5000
       );
        
    },
    
    handleNavigation : function(component,event,helper){
        component.set('v.showVerticalNav',true);
    },
    handleSelectedNavigation :function(c, e, h){
        console.log('c.get("v.selectedsection") '+c.get("v.selectedsection"));
        if(c.get("v.selectedsection") === 'Close1'){
            c.set("v.showVerticalNav",false);
            c.set("v.navigatesection",'Select Section List');
        }else{
            var originalString = c.get("v.selectedsection");
            var newString = originalString.replace('1', '');
            c.set("v.navigatesection",newString);
        }
        document.getElementById(c.get("v.selectedsection")).scrollIntoView(); 
        c.set("v.showVerticalNav",false);
        
        
    }
    
})