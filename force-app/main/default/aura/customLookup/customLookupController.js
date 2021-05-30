({
    // To prepopulate the seleted value pill if value attribute is filled
	doInit : function( component, event, helper ) {
    	$A.util.toggleClass(component.find('resultsDiv'),'slds-is-open');
		if( !$A.util.isEmpty(component.get('v.value')) ) {
			helper.searchRecordsHelper( component, event, helper, component.get('v.value') );
		}
	},

    // When a keyword is entered in search box
	searchRecords : function( component, event, helper ) {
        /*if( !$A.util.isEmpty(component.get('v.searchString')) ) {
		    helper.searchRecordsHelper( component, event, helper, '' );
        } else {
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }*/
        console.log('*****searchRecords*******');
        helper.searchRecordsHelper( component, event, helper, '' );
        $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
	},

    // When an item is selected
	selectItem : function( component, event, helper ) {
        if(!$A.util.isEmpty(event.currentTarget.id)) {
    		var recordsList = component.get('v.recordsList');
    		var index = recordsList.findIndex(x => x.value === event.currentTarget.id)
            if(index != -1) {
                var selectedRecord = recordsList[index];
            }
            //alert(selectedRecord + selectedRecord.value);
            component.set('v.selectedRecord',selectedRecord);
            component.set('v.value',selectedRecord.value);
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
            
            /*var cmpEvent = component.getEvent("ProductAddRemoveEvnt"); 
            cmpEvent.setParams({"message" : "Item Added","index" :component.get('v.index') }); 
            cmpEvent.fire(); 
            console.log('*********add*****************');*/
        }
	},
    
    showRecords : function( component, event, helper ) {
        /*if(!$A.util.isEmpty(component.get('v.recordsList')) && !$A.util.isEmpty(component.get('v.searchString'))) {
            $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
        }*/
        console.log('*******show records*****');
        helper.searchRecordsHelper( component, event, helper, '' );
        $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        console.log('recordsList'+JSON.stringify(component.get('v.recordsList')));
        if(!$A.util.isEmpty(component.get('v.recordsList'))) {
            $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
        }
	},

    // To remove the selected item.
	removeItem : function( component, event, helper ){
        //('Item removed');
        component.set('v.selectedRecord','');
        component.set('v.value','');
        component.set('v.searchString','');
        setTimeout( function() {
            component.find( 'inputLookup' ).focus();
        }, 250);
        
        var cmpEvent = component.getEvent("ProductAddRemoveEvnt"); 
        cmpEvent.setParams({"message" : "Item Removed","index" :component.get('v.index')}); 
        cmpEvent.fire(); 
        console.log('*********remove****************');
    },

    // To close the dropdown if clicked outside the dropdown.
    blurEvent : function( component, event, helper ){
    	$A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
    },
})