({
	closeNav : function(c, e, h) {
		c.set("v.closeBuilkAssetsection",true);
	},
    scrolltoSection : function(c, e, h) {
        c.set('v.columns', [
            {label: 'Product No', fieldName: 'product_no', type: 'text'},
            {label: 'Host Id', fieldName: 'host_id', type: 'text'},
            {label: 'Type', fieldName: 'type', type: 'text'},
            {label: 'Lorem Ipsum', fieldName: 'lorem_ipsum', type: 'text'}
        ]);
        
        c.set('v.defaultColumns', [
            {label: 'Product No', fieldName: 'product_no', type: 'text'},
            {label: 'Host Id', fieldName: 'host_id', type: 'text'},
            {label: 'Type', fieldName: 'type', type: 'text'},
            {label: 'Quantity', fieldName: 'quantity', type: 'text'},
            {label: 'Lorem Ipsum', fieldName: 'lorem_ipsum', type: 'text'}

        ]);
        var jsonString = '[{"product_no":"Prod1","host_id":"2GhDIK4dhS7","type":"Time Base Floating","quantity":"3","lorem_ipsum":"KeySign Software Support"},{"product_no":"Prod2","host_id":"2GhDIK4dhS7","type":"Time Base Floating","quantity":"9","lorem_ipsum":"KeySign Software Support"}]';
        c.set('v.data',JSON.parse(jsonString));
        let selectedAssets = c.get("v.ResponseList");
        console.log('clicked manage license : ' + JSON.stringify(selectedAssets))
        console.log('selected item : ' + c.get("v.selecteditem"));
        for(var i=0; i< selectedAssets.length; i++){
            console.log('Selected Asset : ' + selectedAssets[i]);
        }
        if(c.get("v.selecteditem")==='ViewEdit_Asset')
        	document.getElementById("viewasset").scrollIntoView(); 
        else if(c.get("v.selecteditem")==='View_Saved_Articles')
        	document.getElementById("Saved Articles").scrollIntoView();
        else if(c.get("v.selecteditem")==='ServiceSupport_History')
        	document.getElementById("History").scrollIntoView();
        
    },
    shownavigation : function(c, e, h){ 
        c.set("v.showVerticalNav",true);
    }, 
    selectAllCheckbox:function(c, e, h){
           var selectedHeaderCheck = e.getSource().get("v.value");
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        var data = c.get("v.data");
        var flag = false;
        var selectedRows = [];
        
        for (var i = 0; i < data.length; i++) {
            
            if (selectedHeaderCheck == true) {
                
                data[i].isChecked = true;
              //  selectedRows.push(data[i]);
              //  c.set("v.selectedCount", data.length);
              ///  c.set("v.nobulkactions",data.length);
                // c.set("v.showSearchableRow",true);
            } else {
                data[i].isChecked = false;
                //selectedRows.splice(i, 1); 
                //c.set("v.selectedCount", 0);
                //c.set("v.nobulkactions",0);
                //c.set("v.showSearchableRow",false); 
                //c.set("v.isDisable",true);
            }
           updatedAllRecords.push(data[i]);
        }  
         c.set("v.data", updatedAllRecords);
    },
    handleSelectedNavigation :function(c, e, h){
        console.log('c.get("v.selectedsection") '+c.get("v.selectedsection"));
        if(c.get("v.selectedsection") === 'Close'){
             c.set("v.showVerticalNav",false);
            c.set("v.navigatesection",'Navigation Items');
        }else{
            c.set("v.navigatesection",c.get("v.selectedsection"));
        }
        document.getElementById(c.get("v.selectedsection")).scrollIntoView(); 
        c.set("v.showVerticalNav",false);        
    }    
})