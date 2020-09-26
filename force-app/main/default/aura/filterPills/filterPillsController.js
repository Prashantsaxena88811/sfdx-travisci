({
    handleRemove : function(component, event, helper) {
        var filterList = component.get('v.filterList');
        var evt = event.getSource();
        const index = filterList.indexOf(evt.get('v.label'));
        if (index > -1) {
            filterList.splice(index, 1);
        }
        component.set('v.filterList',filterList);
    }
})