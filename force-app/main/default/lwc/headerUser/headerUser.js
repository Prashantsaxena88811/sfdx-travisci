import { LightningElement,wire } from 'lwc';
import DCX_RESOURCE from '@salesforce/resourceUrl/DCXResource';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import FIRST_NAME_FIELD from '@salesforce/schema/User.FirstName';
import LAST_NAME_FIELD from '@salesforce/schema/User.LastName';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import PHONE_FIELD from '@salesforce/schema/User.Phone';

export default class HeaderUser extends LightningElement {
    logokeySight = DCX_RESOURCE + '/DCXResource/images/keysight-logo.png';
    showSearch=false;
    error;
    name;
    isDialogVisible = false;
    originalMessage = 'waiting from Client';
   
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [FIRST_NAME_FIELD, LAST_NAME_FIELD, EMAIL_FIELD, PHONE_FIELD]
    })wireuser({
        error,
        data
    }){
        if (error) {
            this.error = error;
        } else if (data) {
            this.name = data.fields.FirstName.value +' ' +data.fields.LastName.value;       
        }
    };

    showSearchBar(){
        this.showSearch = !this.showSearch;
    }
    get placeHolder(){
       return `Hi ${this.name}, How can we help you?`;
    }

    handleNotificationClick(event) {
        this.isDialogVisible = true;
    } 
    handleClose(event) {
        this.isDialogVisible = false; 
    } 
}