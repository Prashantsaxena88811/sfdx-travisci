import {
    LightningElement,
    track,
    api
} from 'lwc';
import getSearchedResults from '@salesforce/apex/Group_Management_Controller.getSearchedResults';

export default class GroupManagemntComponent extends LightningElement {
    @track caseResult;
    @api searchKey;
    @track isLoading = false;
    @track showHideButton = false;
    @track countOfRecord = 0;

    handleClick() {
        this.isLoading = true;
        getSearchedResults({
                searchKey: this.searchKey
            })
            .then(result => {
                window.console.log(result);
                this.caseResult = result;
                if ((this.caseResult).length > 0) {
                    this.countOfRecord = (this.caseResult).length;
                } else {
                    this.countOfRecord = 0;
                }
                this.isLoading = false;
            })
            .catch(error => {
                window.console.log(error);
            });
    }
    setValueOfGroupId(event) {
        this.searchKey = event.target.value;
        if (this.searchKey) {
            this.showHideButton = true;
        } else {
            this.showHideButton = false;
        }
        window.console.log(event.target.value);
    }

}