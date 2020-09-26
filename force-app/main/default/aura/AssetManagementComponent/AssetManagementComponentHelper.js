/**
 * Created by awish on 27-08-2020.
 */
({
   
    openNavHelper: function (c, e, h) {
        console.log('Open');
        document.getElementById("mySidenav").style.width = "300px";
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
                            console.log('storedResponse:');
                            //console.log(storedResponse);
                            var objectData = JSON.parse(storedResponse);
                            console.log(objectData);
                            console.log(objectData.totalResults);
                            c.set("v.data",objectData.response.results);
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
        document.getElementById("mySidenav").style.width = "0";
    },
    
    handleClickHelper : function(c, e, h){
        var selectedRodws = c.get("v.selectedRows");
        console.log('selectedRodws>>>');
        console.log(selectedRodws);
        c.set("v.isModalOpen",true);
        c.set("v.ResponseList",selectedRodws);
        
    },
    
    resetFilterDataHelper : function(c, e, h)  {
        var searchFilterObj = {};
        console.log('searchFilterObj>>'+JSON.stringify(searchFilterObj)); 
        searchFilterObj.product_no = "";
        searchFilterObj.serial_no = "";
        searchFilterObj.manufacturer = "";
        searchFilterObj.host_id = "";
        searchFilterObj.last_certificate_no = "";
        console.log('searchFilterObj>>'+JSON.stringify(searchFilterObj));
        c.set("v.filterObj",searchFilterObj);
    }, 
})