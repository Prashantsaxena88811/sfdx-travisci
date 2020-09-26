import { LightningElement,track,wire} from 'lwc';
import returnEmailUserCont from '@salesforce/apex/CustomModalClass.returnEmailUserCont';
import matchUser from '@salesforce/apex/CustomModalClass.matchUser';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class CustomModelButton extends LightningElement {
    @track isModalOpen = false;
    @track userID;
    @track contactEmail;
    @track groupId;

    @wire(returnEmailUserCont) userContEmail;

    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    submitDetails() {
        console.log('userContEmail',this.userContEmail);
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        console.log(this.userID);
        if(this.userID == '' || this.userID == undefined || this.groupId == '' || this.groupId == undefined){
            this.showNotSave();
        }else{
            matchUser({UserId: this.userID, ContactEmail:this.userContEmail.data,GroupId:this.groupId})
            .then(result => { console.log(result); if(result == false){this.showNotification()}else{this.showSuccess()} })
            .catch(error => { console.log(error)})
            this.isModalOpen = false;
        }
    }

    showSuccess() {
        const evt = new ShowToastEvent({
            message: 'Group member added successfully',
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    showNotification() {
        const evt = new ShowToastEvent({
            message: 'Domain does not match',
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }

    showNotSave() {
        const evt = new ShowToastEvent({
            message: 'Please select both the field to save',
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }


    onUserSelect(event){
        console.log('onUserSelect'+event.detail.selectedRecordId);
        this.userID = event.detail.selectedRecordId;
    }

    onGroupSelect(event){
        console.log('onGroupSelect'+event.detail.selectedValue);
        this.groupId = event.detail.selectedRecordId;
    }

}