({
    scriptsLoaded : function(component, event, helper) {
        console.log('Script loaded..'); 
    },
    
    doInit : function(component,event,helper){
        //call apex class method
        var action = component.get('c.getRecordtList');
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                //set response value in lstOpp attribute on component.
                component.set('v.listOfRecords', response.getReturnValue());
                
                // when response successfully return from server then apply jQuery dataTable after 500 milisecond
                setTimeout(function(){ 
                     // Setup - add a text input to each footer cell
   /* $('#tableId thead th').each( function () {
        var title = $(this).text();
        $(this).html( $(this).html()+'<br/><input type="text" placeholder="Search '+title+'" />' );
    } );*/
 
    // DataTable
    var table = $('#tableId').DataTable({
        initComplete: function () {
            // Apply the search
            this.api().columns().every( function () {
                var that = this;
 
                $( 'input', this.header() ).on( 'keyup change clear', function () {
                    if ( that.search() !== this.value ) {
                        that
                            .search( this.value )
                            .draw();
                    }
                } );
            } );
        }
    });
                    // add lightning class to search filter field with some bottom margin..  
                    $('div.dataTables_filter input').addClass('slds-input');
                    $('div.dataTables_filter input').css("marginBottom", "10px");
                }, 500);          
            }
        });
        $A.enqueueAction(action); 
    },
})