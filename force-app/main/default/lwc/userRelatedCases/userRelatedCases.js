import { LightningElement, wire } from 'lwc';
import getCaseList from '@salesforce/apex/ShowUserRelatedCases_Controller.getCaseList';
import cloneCase from '@salesforce/apex/ShowUserRelatedCases_Controller.cloneCase';
import changeCaseStatus from '@salesforce/apex/ShowUserRelatedCases_Controller.changeCaseStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
export default class UserRelatedCases extends NavigationMixin(LightningElement) {

    cases;
    error;


    connectedCallback() {
        //do something
        this.fetchCaseList();
        //
        var currentDate = new Date();
        console.log('currentDate');
        console.log(currentDate);
    }

    handleOnselect(event) {
        let selectedItem = event.detail.value;
        console.log(selectedItem);
        let selectedVal = selectedItem.split('--');
        console.log('Selected button is1 ' + selectedVal);
        console.log('Selected button is ' + selectedVal[0]);
        console.log('Selected button is ' + selectedVal[1]);
        //return;
        if( selectedVal[1] == 'Clone'){
            cloneCase({ caseId: selectedVal[0] })
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
        else if(selectedVal[1] == 'View'){
                console.log('show comments for this case '+selectedVal[0]);
                this.navigateToRelatedList(selectedVal[0]);
        }
        else if(selectedVal[1] == 'ReOpen'){
            console.log('reopen this case-->'+selectedVal[0]);
            this.reOpenCase(selectedVal[0]);
        }


    }

    reOpenCase(caseId){
        changeCaseStatus({ caseId: caseId })
        .then(result => {
            console.log('Reopen the Case');
            console.log(result);
            if (!result) {
                this.showToast('Error', 'Case not Reopened', 'error', 'dismissable');

            }
            else {
                this.showToast('Success', 'Case Re-open Successfully', 'success', 'dismissable');
                this.fetchCaseList();
                
            }
            
            
        })
        .catch(error => {

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
                // for(let count=0; count <result.length;count++){
                //     result[count].Clone = result[count].Id +'--'+'Clone';
                //     result[count].View = result[count].Id +'--'+'View';
                // }
                console.log(result);
                console.log(this.cases);
            })
            .catch(error => {

            });
    }

    navigateToRelatedList(caseId) {
        // Navigate to the CaseComments related list page
        // for a specific Case record.
        console.log('---->'+caseId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: caseId,
                objectApiName: 'Case',
                relationshipApiName: 'CaseComments',
                actionName: 'view'
            }
        });
    }

}