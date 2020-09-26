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
        h.submitFilterHelper( c,e,h, '', '', false, true );
        h.getSaveMyAssets(c,e,h,[],true);
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
        var evt = e.getSource();
        console.log(evt.get('v.value'));
        var filters = c.get('v.selectedFilters');
        
        for( let j of evt.get('v.options')) {
            if( evt.get('v.value').includes(j.value)) {
                if( !filters.includes( j.value )) {
                    filters.push(j.value);
                }
            }
            else {
                if( filters.includes( j.value ) ) {
                    const index = filters.indexOf(j.value);
                    if (index > -1) {
                        filters.splice(index, 1);
                    }
                }
            }
        }
        //filters.push(evt.get('v.value'));

        c.set('v.selectedFilters',filters);
    },
    clearFilters : function( c, e, h ) {
        c.set('v.selectedFilters',[]);
        c.set('v.valueofMyAssets',[]);
        c.set('v.valueofAssets',[]);
        c.set('v.valueofLocation',[]);
        c.set('v.valueofservice',[]);
        
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
        var selectedRows = [];
        
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
    //KDS-34
    handlecmpEventFilter : function(component, event, helper) {
        console.log('handlecmpEventFilter');
        var value = event.getParam("param");
        //if(value !== null || value !== undefined){
            helper.filterChangeHandler(component, event, helper) ;
        //}
    },
    //KDS-31,32
    filterChangeHandler : function(c, e, h){
        try{
            console.log('filterChangeHandler');
            var filterObj = c.get("v.filterObj");
            //console.log('filterObj>>'+JSON.stringify(filterObj));
            var tableData = c.get("v.NonFilterdata");
            //console.log('table ',JSON.stringify(tableData));
            var filteredData = [];
            if(tableData.length > 0){
                tableData.forEach(function(ele){
                    var matchCount = 0;
                    let existVal = false;
                    let totalFilter = 0;
                    Object.keys(filterObj).forEach(function(key){
                        
                        if(filterObj[key]){
                            totalFilter++;
                            let toBeSearchedStr = ele[key].toLowerCase();
                            let toSearchStr = filterObj[key].toLowerCase();
                            console.log('tableData['+key+']'+ele[key]+' includes in '+'filterObj['+key+']'+filterObj[key]+' = '+toBeSearchedStr.includes(toSearchStr));
                            
                            if(toBeSearchedStr.includes(toSearchStr)){
                                existVal = true;
                                matchCount++;
                            }
                            else{
                                existVal = false;
                            }
                            
                        }
                    });
                    console.log('totalFilter '+totalFilter+ ' matchCount '+matchCount);
                    if(totalFilter == matchCount){
                        console.log('Serached row '+JSON.stringify(ele));
                        filteredData.push(ele); 
                    }                                 
                });
            }
            if(filteredData.length > 0){
                c.set("v.data",filteredData);
                //console.log('FD ** ',JSON.stringify(filteredData));
            }else{
                //console.log('Empty');
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
        let selected = component.get('v.selectedCheck');
        if(!selected){
            helper.handleShowSystemsHelper(component,event,helper);
            component.set('v.selectedCheck', true);
        } else {
            component.set('v.selectedCheck', false);
        }
        //component.set('v.selectedCheck',component.get('v.selectedCheck') ? false:true);
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
	clearColumnSearch : function (component, event, helper) {
        var cmpEvent = $A.get("e.c:cmpClearFilter");
        cmpEvent.setParams({"param": "filter"});
        cmpEvent.fire();
        console.log('clearColumnSearch ****');
        helper.resetFilterDataHelper(component, event, helper) ;
        var action = component.get('c.filterChangeHandler');
        $A.enqueueAction(action);
        console.log('clearColumnSearch------');
        
    },
    // ## function call on Click on the "Download As CSV" Button. 
    downloadDataCSV : function(component,event,helper){
        var stockData = component.get("v.data");
        // call the helper function which "return" the CSV data as a String   
        var csv = helper.convertArrayOfObjectsToCSV(component,stockData);   
        if (csv == null){return;} 
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    }, 

    closeFilterModal : function(component,event,helper){
        component.set('v.openFilterModal',false);
    },
    openSaveFilterModal : function(component,event,helper){
        component.set('v.openFilterModal',true);
    },
    submitFilter : function(component,event,helper){
        var filterName = component.get('v.selectedMyFilter');
        var filterFields = '';
        for( let i of component.get('v.selectedFilters') ) {
            filterFields += i+';'
        }
        filterFields = filterFields.substring(0,filterFields.length -1 );
        var isExisting = component.get('v.isExisting');
        
        helper.submitFilterHelper( component,event,helper, filterName, filterFields, isExisting, false );
    },

    applyThisFilter : function(component,event,helper){
        var assetFiltersObject  = component.get('v.assetFiltersObject');
        var evt = event.getSource().get('v.title');

        if( assetFiltersObject.hasOwnProperty( evt ) ) {
            var putFilter = assetFiltersObject[evt].Filter_Fileds__c;
        }
        component.set('v.selectedFilters', putFilter.split(';'));
    },
    
    deleteFilter : function(component,event,helper){
        var afId = event.getSource().get('v.alternativeText');
        var action = component.get("c.deleteAssetFilter");
        action.setParams({
            "assetFilterId" : afId
            
        });
        action.setCallback(this,function( response ) {
            if( response.getState() === 'SUCCESS') {
                var returnVal = response.getReturnValue();
                console.log(returnVal);
                component.set('v.assetFilters', returnVal);
                var assetObj = {};
                for( let i of returnVal ) {
                    assetObj[i.Id] = i;
                }
                component.set('v.assetFiltersObject', assetObj);
                helper.showToast(component,event,helper, 'Success!', 'error', 'Your Asset Filter is deleted!');
            }
        });
        $A.enqueueAction(action);
    },
    existingfilterNameChange : function(component,event,helper) {
        component.find('existingFilters').set('v.disabled', false);
        component.find('newFilterName').set('v.disabled', true);
        component.set('v.isExisting', true);
        component.set('v.selectedMyFilter', event.getSource().get('v.value'));
    },


    newfilterNameChange : function(component,event,helper) {
        component.find('existingFilters').set('v.disabled', true);
        component.find('newFilterName').set('v.disabled', false);
        component.set('v.isExisting', false);
        component.set('v.selectedMyFilter', event.getSource().get('v.value'));
    },

    showMyAssets : function( component,event,helper ) {
        var myAssetsChecked = event.getSource().get('v.value');
        var dataBackup = component.get('v.dataBackup');
        if( myAssetsChecked.length > 0 ) {
            var assetIds = component.get('v.myAssetIds');
            
            var newData = [];
            
            for( let i of dataBackup) {
                var str = i.id.toString();
                
                if( Object.values(assetIds).includes(str)){
                    i.isChecked = true;
                    newData.push(i);
                }
            }
            component.set('v.data',newData);
        }
        else {
            for( let i of dataBackup) {
                i.isChecked = false;
            }
            component.set('v.data',dataBackup);
        }
    }


})