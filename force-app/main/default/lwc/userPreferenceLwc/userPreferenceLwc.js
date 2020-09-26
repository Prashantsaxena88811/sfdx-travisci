import { LightningElement, track, wire } from 'lwc';
import getAssetFilters from '@salesforce/apex/userPreferenceServerController.getAssetFilters';
import setAssetFilters from '@salesforce/apex/userPreferenceServerController.setAssetFilters';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class UserPreferenceLwc extends LightningElement {
@track response = [];
@track toUpdate = [];
//columns = columns;
//rowOffset = 0;
error;
name;
activeFlag;


@wire(getAssetFilters) response;
    

//Generic method to handle button clicks
handleClick(event){
    event.stopPropagation();
    if (event.target.name==="cancelButton"){
        console.log('Cancel Button Clicked');
        eval("$A.get('e.force:refreshView').fire();");
    } else if (event.target.name === "saveButton"){
        this.updateRecord();
        console.log('Save Button Clicked');
    } 
}

updateRecord() {
    console.log('inside update');
    console.log('this.toUpdate::'+this.toUpdate);
    console.log('current this.toUpdate::'+JSON.stringify(this.toUpdate));
    setAssetFilters({
        incomingList: this.toUpdate
            })
            .then(result => {
                console.log('::'+result);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Filter & Settings Updated Successfully',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                console.log('::'+error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });

}

toggeled(event) {

    console.log('checked::'+event.target.checked);
    console.log('value::'+event.target.value);
    
    let cont = { 'Id': event.target.value, 'isActive__c' : event.target.checked };
    //cont.Id = event.target.value;
    //cont.isActive__c = event.target.checked;
    console.log('cont::'+cont);

    const IdCheck = this.toUpdate.map(el => el.Id); // returns ['frog', 'monkey', 'gorilla', 'lion']
    console.log(IdCheck.includes(event.target.value)); // returns true

    if(IdCheck.includes(event.target.value)){
        console.log('exists::');

        const index = IdCheck.indexOf(event.target.value);
        this.toUpdate.splice(index,1);

        this.toUpdate.push(cont);

        //replace that element 
    }else{
        console.log('doesnt exist::');
        //push it
        this.toUpdate.push(cont);
    }
    

    console.log('current this.toUpdate::'+this.toUpdate);
    console.log('current this.toUpdate::'+JSON.stringify(this.toUpdate));
}
}