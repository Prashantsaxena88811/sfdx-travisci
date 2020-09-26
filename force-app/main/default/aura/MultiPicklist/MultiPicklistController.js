/**
 * Created by awish on 29-08-2020.
 */
({
    init: function (cmp) {
        var items = [];
        /*for (var i = 0; i < 15; i++) {
            var item = {
                "label": "Option " + i,
                "value": "opt" + i
            };
            items.push(item);
        }*/
        item = {
            "label": "cal_due_date ",
            "value": "cal_due_date"            
        };
        items.push(item);
        
        item = {
            "label": "Description ",
            "value": "Description"            
        };
        items.push(item);
        
        item = {
            "label": "eos_date ",
            "value": "eos_date"            
        };
        items.push(item);
        
        item = {
            "label": "extended_service_period ",
            "value": "extended_service_period"            
        };
        items.push(item);
        
        
        item = {
            "label": "host_id ",
            "value": "host_id"            
        };
        items.push(item);
        
        item = {
            "label": "id ",
            "value": "id"            
        };
        items.push(item);
        
        item = {
            "label": "keysight_care_coverage ",
            "value": "keysight_care_coverage"            
        };
        items.push(item);
        
        
        item = {
            "label": "keysight_care_eligible ",
            "value": "keysight_care_eligible"            
        };
        items.push(item);
        
        
        item = {
            "label": "last_cal_date ",
            "value": "last_cal_date"            
        };
        items.push(item);        
        
        
        item = {
            "label": "last_cal_result ",
            "value": "last_cal_result"            
        };
        items.push(item);
        
        
        item = {
            "label": "last_cal_type ",
            "value": "last_cal_type"            
        };
        items.push(item);
        
        item = {
            "label": "last_certificate_no ",
            "value": "last_certificate_no"            
        };
        items.push(item);
        
        item = {
            "label": "manuf_model_no ",
            "value": "manuf_model_no"            
        };
        items.push(item);
        
        item = {
            "label": "manufacturer ",
            "value": "manufacturer"            
        };
        items.push(item);
        
        item = {
            "label": "product_no ",
            "value": "product_no"            
        };
        items.push(item);
        
        item = {
            "label": "purchase_order_no ",
            "value": "purchase_order_no"            
        };
        items.push(item);
        
        item = {
            "label": "row_id ",
            "value": "row_id"            
        };
        items.push(item);
        
        item = {
            "label": "sales_order_no ",
            "value": "sales_order_no"            
        };
        items.push(item);
        
        item = {
            "label": "serial_no ",
            "value": "serial_no"            
        };
        items.push(item);
        
        item = {
            "label": "sfdc id",
            "value": 'sfdc_id'
        };
        items.push(item);
        
        
        var item = {
            "label": "Site Id ",
            "value": "SiteId"
        };
        
        items.push(item);
        
        item = {
            "label": "SiteName ",
            "value": "SiteName"            
        };
        items.push(item);
        
        
        
        
        
       
       
       
               
        
        
        
            
        cmp.set("v.options", items);
        // "values" must be a subset of values from "options"
        var data = cmp.get("v.columns");
        var value = [];
        for (var i = 0; i < data.length; i++) {
          var valueItem = data[i].fieldName;
            console.log(data[i].fieldName);
            value.push(valueItem);
        }
        value=value.sort();
        cmp.set("v.values", value);
    },
    
    handleChange: function (cmp, event) {
        // This will contain an array of the "value" attribute of the selected options
        var selectedOptionValue = event.getParam("value");
        cmp.set("v.selectedOptionValue",selectedOptionValue);
        console.log( JSON.stringify(cmp.get("v.columns")));
        //alert("Option selected with value: '" + selectedOptionValue.toString() + "'");
        //c.set()
    },
    closeModel : function(c, e, h) {
        c.set("v.isShowHideSelector",false);
    },
    ApplyColoumn : function(c, e, h) {
        
        var data = c.get("v.selectedOptionValue");
        var newColoumn=[];
        var selectedcolumns = [];
         for (var i = 0; i < data.length; i++) {
             var col = {};
             col.label = data[i];
             col.fieldName = data[i];
             col.Type = 'text';
             newColoumn.push(col);
             selectedcolumns.push(data[i]);
        }
        console.log('data ',data); //selectedcolumns
        console.log('newColoumn ',newColoumn);
        c.set("v.columns",newColoumn);
        c.set("v.selectedcolumns",selectedcolumns);
        console.log(c.get("v.columns"));
        console.log('selectedcolumns ',selectedcolumns);
       c.set("v.isShowHideSelector",false);
    },
    ResetDefaultColoumn : function(c, e, h) {
        
        c.set("v.columns",c.get("v.defaultColumns"));
        //console.log(c.get("v.columns"));
        c.set("v.isShowHideSelector",false);
    }
})