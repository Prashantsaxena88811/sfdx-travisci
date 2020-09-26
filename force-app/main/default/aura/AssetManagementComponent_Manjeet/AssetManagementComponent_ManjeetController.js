/**
 * Created by awish on 27-08-2020.
 */
({
    init: function (c, e, h) {
        c.set('v.columns', [
            {label: 'product_no', fieldName: 'product_no', type: 'text'},
            {label: 'manufacturer', fieldName: 'manufacturer', type: 'text'},
            {label: 'host_id', fieldName: 'host_id', type: 'text'},
            {label: 'last_certificate_no', fieldName: 'last_certificate_no', type: 'text'}
        ]);
        
        c.set('v.defaultColumns', [
            {label: 'product_no', fieldName: 'product_no', type: 'text'},
            {label: 'manufacturer', fieldName: 'manufacturer', type: 'text'},
            {label: 'host_id', fieldName: 'host_id', type: 'text'},
            {label: 'last_certificate_no', fieldName: 'last_certificate_no', type: 'text'}
        ]);
        var globalsearch = c.find("globalsearch");
        $A.util.addClass(globalsearch, "slds-input slds-input_custom");
        h.getdataFromAPI(c, e, h);
        h.resetFilterDataHelper(c, e, h);
        c.set("v.openRightNav",true);
    },
    openNav: function (c, e, h) {
        h.openNavHelper(c, e, h);
    },
    closeNav: function (c, e, h) {
        h.closeNavHelper(c, e, h);
    },
    openNavRight: function (c, e, h) {
        console.log('Open Right');
        document.getElementById("mySidenavRight").style.width = "15%";
        document.getElementById("mySidenavRight").classList.remove("displaynone");
        
        c.set("v.openRightNav",true);
    },
    closeNavRight: function (c, e, h) {
        console.log('Close Right');
        c.set("v.openRightNav",false);
        document.getElementById("mySidenavRight").style.width = "0px";
        document.getElementById("mySidenavRight").classList.add("displaynone");
        c.set("v.closeViewAssetsection",false);
        
        document.getElementById("viewassetnavRight").style.width = "0px";
        document.getElementById("viewassetnavRight").classList.add("displaynone");
    },
    closeviewasset:function (c, e, h) {
        console.log('Close Right');
        c.set("v.closeViewAssetsection",false);
        
        document.getElementById("viewassetnavRight").style.width = "0px";
        document.getElementById("viewassetnavRight").classList.add("displaynone");
        
    },
    closebulksset:function (c, e, h) {
        console.log('Close Right');
        c.set("v.closeBuilkAssetsection",false);
        
        document.getElementById("viewManageLicensenavRight").style.width = "0px";
        document.getElementById("viewManageLicensenavRight").classList.add("displaynone");
        
    },
    handleChange: function (c, e, h) {
       // alert(e.getParam('valueofAssets'));
    },
    loadMoreData: function (c, e, h) {
        window.setTimeout(
            $A.getCallback(function () {
                
            }), 2000
        );
        console.log('Load More......');
        var pageCount = c.get("v.pageCount");
        pageCount += 1;
        c.set("v.pageCount", pageCount);
        try {
            var action = c.get("c.getAssetsUpgrade_APEX");
            action.setParams({
                "bodyData": '{"pageNumber":' + pageCount + ',"pageSize": 20,"facets": [ { "field": "manufacturer.keyword" }, { "field": "groups.location.keyword" }, { "field": "cal_due_date", "type": "DATERANGE", "dateRangeParam": [ { "key": "cal_due_date_in_7_days", "dayRange": 7 }, { "key": "cal_due_date_in_30_days", "dayRange": 30 }, { "key": "cal_due_date_in_90_days", "dayRange": 90 }, { "key": "cal_due_date_done", "dayRange": -9999 }, { "key": "custom_date_range", "range": [ "2017-04-13", "2018-08-16" ] } ] } ]} '
            });
            action
            .setCallback(
                this,
                function (r) {
                    if (r.getState() === 'SUCCESS') {
                        var storedResponse = r.getReturnValue();
                        console.log('storedResponse:');
                        //console.log(storedResponse);
                        var objectData = JSON.parse(storedResponse);
                        //console.log(objectData);
                        
                        var olddata = c.get("v.data");
                        console.log(olddata.length);
                        var newData = olddata.concat(objectData.response.results);
                        c.set("v.data", newData);
                    } else {
                        console.log('Get State- ' + r.getState());
                        console.log(r.getError());
                    }
                });
            $A.enqueueAction(action);
        } catch (ex) {
            console.log("Exception~~~");
            console.log(ex);
            
        }
    },
    
    searchResult: function (c, e, h) {
        var selectedValue = e.target.closest('li').dataset.value;
        c.set("v.searchedValue", selectedValue);
        c.set("v.openDropDown", false);
        console.log('searchResult');
        var searchJson = JSON.parse('{ "pageNumber": 1, "pageSize": 20, "query": [  ] }')
        var searchedValue = c.get("v.searchedValue");
        searchJson.query.push(JSON.parse('{ "search": "'+searchedValue+'" }'));
        c.set("v.pageCount", 0);
        try {
            if( searchedValue.length > 0 ){
                var action = c.get("c.getAssetsUpgrade_APEX");
                action.setParams({
                    "bodyData": JSON.stringify(searchJson)
                });
                action
                .setCallback(
                    this,
                    function (r) {
                        if (r.getState() === 'SUCCESS') {
                            var storedResponse = r.getReturnValue();
                            console.log('storedResponse:');
                            //console.log(storedResponse);
                            var objectData = JSON.parse(storedResponse);
                            console.log(objectData);
                            c.set("v.data", objectData.response.results);
                            c.set("v.ResponseData", objectData);
                        } else {
                            console.log('Get State- ' + r.getState());
                            console.log(r.getError());
                        }
                    });
                $A.enqueueAction(action);
            }else{
                h.getdataFromAPI(c, e, h);
            }
        } catch (ex) {
            console.log("Exception~~~");
            console.log(ex);
            
        }
    },
    updateSelectedText: function (c, e,h) {
        console.log('selected data');       
        c.set("v.isDisable",false);
        var selectedRows = e.getParam('selectedRows');
        console.log('selectedRows>>'+JSON.stringify(selectedRows)); 
        c.set('v.selectedRows', selectedRows);
        if(selectedRows.length == 0){
            c.set("v.isDisable",true); 
        }
    },
    
    changeColumns: function (c, e,h) {
        var noOfColumns = c.get("v.selectedcolumns").length;
        c.set("v.noOfColumns",noOfColumns+1);
    },
    checkboxSelect : function (c, e,h) {
        var selectedRec = e.getSource().get("v.value");
        var selectedRecText = e.getSource().get("v.text");
        var selectedRows = c.get("v.selectedRows");
        var data = c.get("v.data");
        console.log('selectedRecText '+selectedRecText);
        var getSelectedNumber = c.get("v.selectedCount");
        var flag = false;
        if (selectedRec == true) {
            getSelectedNumber++;
            if(getSelectedNumber > 1){
                c.set("v.bulkactions",true);
            }else{
                c.set("v.bulkactions",false);
            }
            c.set("v.nobulkactions",getSelectedNumber);
            selectedRows.push(data[selectedRecText]);
            //c.set("v.showSearchableRow",true); 
            c.set("v.isDisable",false);
        } else {
            getSelectedNumber--;
            const index = selectedRows.indexOf(selectedRecText);
            if (index > -1) {
                selectedRows.splice(index, 1);
            }
			if(getSelectedNumber > 1){
                c.set("v.bulkactions",true);
            }else{
                c.set("v.bulkactions",false);
            }
             c.set("v.nobulkactions",getSelectedNumber);
            if(getSelectedNumber == 0 ){
                c.find("selectAllId").set("v.value", false);
               // c.set("v.showSearchableRow",false); 
               // 
                c.set("v.isDisable",true);
                
            }
                
        }
        c.set("v.selectedRows", selectedRows); 
        c.set("v.selectedCount", getSelectedNumber);
         
        if (getSelectedNumber == c.get("v.totalRecordsCount")) {
            c.find("selectAllId").set("v.value", true);
        }
        if(flag){
            c.set("v.isDisable",false);
        }
        
    },
    selectAllCheckbox :function (c, e,h) {
        var selectedHeaderCheck = e.getSource().get("v.value");
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        var data = c.get("v.data");
        var flag = false;
        
        
        for (var i = 0; i < data.length; i++) {
            
            if (selectedHeaderCheck == true) {
                
                data[i].isChecked = true;
                selectedRows.push(data[i]);
                c.set("v.selectedCount", data.length);
                c.set("v.nobulkactions",data.length);
               // c.set("v.showSearchableRow",true);
            } else {
                data[i].isChecked = false;
                 selectedRows.splice(i, 1); 
                c.set("v.selectedCount", 0);
                c.set("v.nobulkactions",0);
                //c.set("v.showSearchableRow",false); 
                //c.set("v.isDisable",true);
            }
            updatedAllRecords.push(data[i]);
        }
        if(flag){
            c.set("v.isDisable",false);
            
        }
        c.set("v.bulkactions",true);
        c.set("v.data", updatedAllRecords);
        
    },
    handleClick : function(c, e, h){
        h.handleClickHelper(c, e, h);
    },
    deleteRow : function(c, e, h){
        c.set("v.showSearchableRow",false); 
        h.getdataFromAPI(c, e, h);
    },
    showHideSelectorData: function (c, e, h) {
        console.log('showHideSelector');
        c.set("v.isShowHideSelector",true); 
    },
    
    filterChangeHandler : function(c, e, h){
        try{
            var filterObj = c.get("v.filterObj");
            console.log('filterObj>>'+JSON.stringify(filterObj));
            var tableData = c.get("v.data");
            console.log(tableData);
            var filteredData = [];
            if(tableData.length > 0){
                tableData.forEach(function(ele){
                    var matchCount = 0;
                    Object.keys(filterObj).forEach(function(key){
                        if(filterObj[key]){
                            if(ele[key].includes(filterObj[key])){
                                matchCount++;
                            }
                        }
                    });
                    console.log('matchCount>>'+matchCount);
                    if(matchCount > 0){
                       filteredData.push(ele); 
                    }                                 
                });
            }
            if(filteredData.length > 0){
                c.set("v.data",filteredData);
            }else{
                console.log('Empty');
                h.getdataFromAPI(c, e, h);
            }
        }catch(ex){
            system.debug('Exception occured>>'+ex);
        } 
    },
    
    handleAddAssets : function(component,event,helper){
        component.set('v.showAddAssets',true);
    },
    
    handleShowSystem : function(component,event,helper){
        component.set('v.selectedCheck',component.get('v.selectedCheck') ? false:true);
    },
    handleOnSelect :  function(component,event,helper){
        h.handleClickHelper(c, e, h);
        
    },
    handleSearchClick : function( component,event,helper ) {
        var evt = event.getSource();
        evt.set('v.placeholder','');
    } ,
    handleSearchBlur : function ( component,event,helper ) {
        var evt = event.getSource();
        evt.set('v.placeholder','Search Assets');
        //component.set("v.openDropDown", false);
    },
    searchKeyWord : function ( c,e,h ) {
        var evt = e.getSource();
        if(evt.get('v.value').length >= 3 ) {
            var searchJson = JSON.parse('{ "pageNumber": 1, "pageSize": 20, "query": [  ] }')
            var searchedValue = evt.get('v.value');
            searchJson.query.push(JSON.parse('{ "search": "'+searchedValue+'" }'));
            var action = c.get("c.getAssetsUpgrade_APEX");
                action.setParams({
                    "bodyData": JSON.stringify(searchJson)
                });
                action
                .setCallback(
                    this,
                    function (r) {
                        if (r.getState() === 'SUCCESS') {
                            var storedResponse = r.getReturnValue();
                            console.log('storedResponse:');
                            //console.log(storedResponse);
                            var objectData = JSON.parse(storedResponse);
                            console.log(objectData);
                            c.set("v.data", objectData.response.results);
                            c.set("v.ResponseData", objectData);
                            var options = [];
                            for( let i of objectData.response.results) {
                                var obj = new Object();
                                obj.label = i.product_no;
                                obj.value=i.product_no;
                                options.push(obj);
                            }
                            c.set('v.autoCompleteOptions',options);
                            console.log(c.get('v.autoCompleteOptions'));
                            c.set('v.openDropDown',true);
                        } else {
                            console.log('Get State- ' + r.getState());
                            console.log(r.getError());
                        }
                    });
                $A.enqueueAction(action);
        }
        else {
            c.set('v.openDropDown',false);
            
            h.getdataFromAPI(c, e, h);
           
        }
    },
    clearOption : function (component, event, helper) {
        
        
        component.set("v.autoCompleteOptions", []);
        component.set("v.openDropDown", false);
        component.set("v.searchedValue", "");
        helper.getdataFromAPI(component, event, helper);
        
    },
    
})