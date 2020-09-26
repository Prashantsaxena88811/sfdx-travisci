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
    convertArrayOfObjectsToCSV : function(component,objRecords,columnHead) {
        var csvStringResult,counter,keys,lineDivider,columnDivider;
        let rowEnd = '\n';
        let csvString = '';
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();

        // getting keys from data
        objRecords.forEach(function (record) {
            console.log('record--'+record);
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
                
            });            
        });
        
        // getting keys from data
        objRecords.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(record[key]);
                
                
            });            
        });

        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);
        // splitting using ','
        csvString += rowData.join(',');
        csvString += rowEnd;

        // main for loop to get the data based on key value
        /*for(let i=0; i < this.objRecords.length; i++){
            let colValue = 0;

            // validating keys in data
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    // Key value 
                    // Ex: Id, Name
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if(colValue > 0){
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = this.objRecords[i][rowKey] === undefined ? '' : this.objRecords[i][rowKey];
                    csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }*/
        // splitting using ','
        //csvString += rowData.join(',');
        //csvString += rowEnd;
        return csvString;        
    }
    
})