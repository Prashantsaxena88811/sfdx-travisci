({
	closeNav : function(c, e, h) {
		c.set("v.closeViewAssetsection",true);
	},
    scrolltoSection : function(c, e, h) {
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
        
    },
    editasset : function(c, e, h) {
        console.log('edit asset');
		var p = c.get("v.parent");
        p.set('v.showEditAssets',true);
                console.log('edit asset2');
	},
    
})