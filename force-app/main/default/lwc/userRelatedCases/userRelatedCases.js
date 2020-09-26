import { LightningElement, wire } from 'lwc';
import getCaseList from '@salesforce/apex/ShowUserRelatedCases_Controller.getCaseList';
import cloneCase from '@salesforce/apex/ShowUserRelatedCases_Controller.cloneCase';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class UserRelatedCases extends LightningElement {

    cases;
    error;


    connectedCallback() {
        //do something
        this.fetchCaseList();
    }

    handleOnselect(event) {

        let selectedVal = event.detail.value;
        console.log('Selected button is ' + selectedVal);
        cloneCase({ caseId: selectedVal })
            .then(result => {
                console.log('success result--->' + result);
                console.log(result);
                //this.showToast('Error','Case not Created','error','dismissable');
                if (!result) {
                    this.showToast('Error', 'Case not Created', 'error', 'dismissable');

                }
                else {
                    this.showToast('Success', 'Case Created Successfully', 'success', 'dismissable');
                    console.log('call apex method');
                    this.fetchCaseList();
                }
            })
            .catch(error => {
                console.log('error result--->' + error);
                console.log(error);
                this.showToast('Error', 'Error While Creating the case', 'error', 'dismissable');
            });


    }

    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    fetchCaseList() {
        getCaseList()
            .then(result => {
                console.log('updating case List');
                console.log(result);
                this.cases = result;
                console.log(this.cases);
            })
            .catch(error => {

            });
    }

}