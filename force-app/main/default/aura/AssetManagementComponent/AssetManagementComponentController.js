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
        
        h.getdataFromAPI(c, e, h);
        h.resetFilterDataHelper(c, e, h);
    },
    openNav: function (c, e, h) {
        h.openNavHelper(c, e, h);
    },
    closeNav: function (c, e, h) {
        h.closeNavHelper(c, e, h);
    },
    openNavRight: function (c, e, h) {
        console.log('Open Right');
        document.getElementById("mySidenavRight").style.width = "300px";
        
    },
    closeNavRight: function (c, e, h) {
        console.log('Close Right');
        document.getElementById("mySidenavRight").style.width = "0px";
    },
    handleChange: function (c, e, h) {
        alert(e.getParam('valueofAssets'));
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
        console.log('searchResult');
        var searchJson = JSON.parse('{ "pageNumber": 1, "pageSize": 20, "query": [  ] }')
        var searchedValue = c.get("v.searchedValue");
        searchJson.query.push(JSON.parse('{ "search": "'+searchedValue+'" }'));
        c.set("v.pageCount", 0);
        try {
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
    handleClick : function(c, e, h){
        h.handleClickHelper(c, e, h);
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
            console.log('table data ',JSON.stringify(tableData));
            var filteredData = [];
            if(tableData.length > 0){
                tableData.forEach(function(ele){
                    var matchCount = 0;
                    Object.keys(filterObj).forEach(function(key){
                        console.log('Key ',key);
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
})