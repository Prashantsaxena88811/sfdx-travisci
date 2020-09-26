/**
 * Created by awish on 27-08-2020.
 */
({
   
    openNavHelper: function (c, e, h) {
        console.log('Open');
        //document.getElementById("mySidenav").style.width = "15rem";
        document.getElementById("assetfilter").style.width = "18%";
        document.getElementById("assetbody").style.width = "82%";
        document.getElementById("assetfilterspan").classList.add("displaynone");
        
        
        
    },
    getdataFromAPI: function (c, e, h) {
        try {
            var action = c.get("c.getAssetsUpgrade_APEX");
            action.setParams({
                "bodyData": '{"pageNumber": 1,"pageSize": 20,"facets": [ { "field": "manufacturer.keyword" }, { "field": "groups.location.keyword" }, { "field": "cal_due_date", "type": "DATERANGE", "dateRangeParam": [ { "key": "cal_due_date_in_7_days", "dayRange": 7 }, { "key": "cal_due_date_in_30_days", "dayRange": 30 }, { "key": "cal_due_date_in_90_days", "dayRange": 90 }, { "key": "cal_due_date_done", "dayRange": -9999 }, { "key": "custom_date_range", "range": [ "2017-04-13", "2018-08-16" ] } ] } ]} '
            });
            action
                .setCallback(
                    this,
                    function (r) {
                        if (r.getState() === 'SUCCESS') {
                            var storedResponse = r.getReturnValue();
                            console.info('storedResponse:');
                            //console.log(storedResponse);
                            var objectData = JSON.parse(storedResponse);
                            console.log(objectData);
                            console.log(objectData.totalResults);
                            
                            c.set("v.totalRecordsCount",objectData.totalResults);
                            var datawithCheckbox =[];
                            console.log('objectData.response.results ',objectData.response.results);
                            for (var i=0;i<objectData.response.results.length;i++){
                                objectData.response.results[i].isChecked = false;
                                datawithCheckbox.push(objectData.response.results[i]);
                            }
                            c.set("v.data",datawithCheckbox);
                            c.set("v.dataBackup",datawithCheckbox);
                            c.set("v.NonFilterdata",datawithCheckbox);
                            c.set("v.ResponseData",objectData);
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
    closeNavHelper: function (c, e, h) {
        console.log('Close');
        //document.getElementById("mySidenav").style.width = "0";
        document.getElementById("assetfilter").style.width = "5%";
        document.getElementById("assetbody").style.width = "94%";
        document.getElementById("assetfilterspan").classList.remove("displaynone");
        
    },
    
    handleClickHelper : function(c, e, h){
        var selectedRows = c.get("v.selectedRows"); 
        console.log('selectedRows>>>' +c.get("v.selecteditem"));
        console.log(selectedRows);
        //c.set("v.isModalOpen",true);
        if(c.get("v.selecteditem") === 'ViewEdit_Asset' || c.get("v.selecteditem")==='ServiceSupport_History' || c.get("v.selecteditem")==='View_Saved_Articles'){
            c.set("v.ResponseList",selectedRows);   
            c.set("v.closeViewAssetsection",false);
            document.getElementById("viewassetnavRight").style.width = "45%";
            document.getElementById("viewassetnavRight").classList.remove("displaynone");
        }else if(c.get("v.selecteditem") === 'Manage_Licenses' ){
            console.log('inside manage licenses : ' + JSON.stringify(selectedRows));
            c.set("v.ResponseList",selectedRows);
            c.set("v.closeBuilkAssetsection",false);
            document.getElementById("viewManageLicensenavRight").style.width = "45%";
            document.getElementById("viewManageLicensenavRight").classList.remove("displaynone");
        }else if(c.get("v.selecteditem") === 'Create_Support_Case'){
            c.set("v.showCreateAsset",true);
        }else if(c.get("v.selecteditem") === 'Request_a_Service'){
           
             document.getElementById("requestservice").classList.add("bgcolor");
        }else if(c.get("v.selecteditem") === 'Download_Cetificate'){
            console.log('download');
            var url ='https://service.keysight.com/archivews/streamer.aspx?fileId=56017FAFD2E483C3CC595D970F461D8DMTYwMzY1MjY=';
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": url
            });
            urlEvent.fire();
        }
        else if( c.get("v.selecteditem") == 'Add_to_my_Assets' ) {
            h.getSaveMyAssets(c,e,h,selectedRows,false);
        }
        
        
        
        
    },

    getSaveMyAssets : function(component,e,h, selectedRows, isInit) {
        var listIds = [];
        if( selectedRows ) {
            for( let i of selectedRows ) {
                listIds.push(i.id);
            }
        }

        var action = component.get('c.upsertMyAssets');
        action.setParams({
            "myAssetIds" : listIds.toString(),
            "init" : isInit
        });
        action.setCallback(this, function( response ) {
            if( response.getState() === 'SUCCESS') {
                var returnVal = response.getReturnValue();
                component.set('v.myAssetIds',returnVal.split(','));
                var myAssets = component.get('v.MyAssets');
                myAssets[0].label = 'My Assets '+ '(' +returnVal.split(',').length+')';
                component.set('v.MyAssets',myAssets);
                if(!isInit)
                h.showToast(component,e,h,'Success!', 'success', 'Your My Assets have been updated!');
            }
        });
        $A.enqueueAction(action);
    },
    
    resetFilterDataHelper : function(c, e, h)  {
        var searchFilterObj = {};
        console.log('searchFilterObj>>'+JSON.stringify(searchFilterObj)); 
        searchFilterObj.product_no = "";
        searchFilterObj.serial_no = "";
        searchFilterObj.manufacturer = "";
        searchFilterObj.host_id = "";
        searchFilterObj.last_certificate_no = "";
        searchFilterObj.SiteName = "";
        searchFilterObj.sales_order_no = "";
        searchFilterObj.manuf_model_no = "";
        searchFilterObj.purchase_order_no = "";
        searchFilterObj.serial_no = "";
        searchFilterObj.keysight_care_eligible = "";
        searchFilterObj.keysight_care_coverage = "";
        searchFilterObj.cal_due_date = "";
        searchFilterObj.last_cal_date = "";
        searchFilterObj.last_cal_type = "";
        searchFilterObj.last_cal_result = "";
        searchFilterObj.eos_date = "";
        searchFilterObj.extended_service_period = "";
        searchFilterObj.row_id = "";
        searchFilterObj.id = "";
        
        console.log('searchFilterObj>>'+JSON.stringify(searchFilterObj));
        c.set("v.filterObj",searchFilterObj);
    }, 
    //KDS-31,32
    filterChangeHandler : function(c, e, h){
        try{
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
                            //console.log('tableData['+key+']'+ele[key]+' includes in '+'filterObj['+key+']'+filterObj[key]+' = '+toBeSearchedStr.includes(toSearchStr));
                            
                            if(toBeSearchedStr.includes(toSearchStr)){
                                existVal = true;
                                matchCount++;
                            }
                            else{
                                existVal = false;
                            }
                            
                        }
                    });
                    //console.log('totalFilter '+totalFilter+ ' matchCount '+matchCount);
                    if(totalFilter == matchCount){
                        //console.log('Serached row '+JSON.stringify(ele));
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
    convertArrayOfObjectsToCSV : function(component,objectRecords){
        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
        
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header
        keys = component.get("v.selectedcolumns");
        
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
        
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
            
            for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
                
                // add , [comma] after every String value,. [except first]
                if(counter > 0){ 
                    csvStringResult += columnDivider; 
                }   
                if(objectRecords[i][skey])
               		csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                
                counter++;
                
            } // inner for loop close 
            csvStringResult += lineDivider;
        }// outer main for loop close 
        
        // return the CSV formate String 
        return csvStringResult;        
    },

    submitFilterHelper : function(component,event,helper, filterName, filterfields, isExisting, init){
        var action = component.get("c.saveAssetFilter");
        action.setParams({
            "filterName" : filterName,
            "filterFields" :filterfields,
            "isExisting" : isExisting,
            "init" : init
        });
        action.setCallback(this,function( response ) {
            if( response.getState() === 'SUCCESS') {
                var returnVal = response.getReturnValue();
                console.log(returnVal);
                component.set('v.assetFilters', returnVal);
                var assetObj = {};
                var existingAsset = {};
                var existingFilters = [];
                

                for( let i of returnVal ) {
                    assetObj[i.Id] = i;
                    existingAsset.label = i.Name;
                    existingAsset.value = i.Id;
                    existingFilters.push(existingAsset);
                }

                component.set('v.existingFilters', existingFilters);
                component.set('v.assetFiltersObject', assetObj);
                component.set('v.openFilterModal',false);
                if(!init )
                helper.showToast(component,event,helper, 'Success!', 'success', 'Your Asset Filter is saved!');
            }
        });
        $A.enqueueAction(action);
    },

    showToast : function(component, event, helper, title, type, message ) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        toastEvent.fire();
    },
    
    handleShowSystemsHelper : function(component, event, helper){
        let data = component.get('v.data');
        console.log('show system data : ' + JSON.stringify(data));
        for(var i=0; i<data.length; i++ ){
            
        }
    },
    
})