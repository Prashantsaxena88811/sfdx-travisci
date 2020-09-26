import { LightningElement,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { createRecord } from 'lightning/uiRecordApi';

import USER_ID from '@salesforce/user/Id';
import FIRST_NAME_FIELD from '@salesforce/schema/User.FirstName';
import LAST_NAME_FIELD from '@salesforce/schema/User.LastName';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import PHONE_FIELD from '@salesforce/schema/User.Phone';
import ADDRESS_FIELD from '@salesforce/schema/User.Street';
import CITY_FIELD from '@salesforce/schema/User.City';
import TITLE_FIELD from '@salesforce/schema/User.Title';
import DEPARTMENT_FIELD from '@salesforce/schema/User.Department';
import ID_FIELD from '@salesforce/schema/User.Id';


import CASE_OBJECT from '@salesforce/schema/Case';
import SUBJECT_FIELD from '@salesforce/schema/Case.Subject';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import ORIGIN_FIELD from '@salesforce/schema/Case.Origin';
import REASON_FIELD from '@salesforce/schema/Case.Reason';

export default class UserProfileLwc extends LightningElement { 
    @track error;
    email;
    firstName;
    lastName;
    phoneNumber;
    address;
    city;
    title;
    department;
    caseId;

    
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [FIRST_NAME_FIELD, LAST_NAME_FIELD, EMAIL_FIELD, ADDRESS_FIELD, PHONE_FIELD, CITY_FIELD, TITLE_FIELD, DEPARTMENT_FIELD]
    })wireuser({
        error,
        data
    }){
        if (error) {
            this.error = error;
        } else if (data) {
            this.firstName = data.fields.FirstName.value;
            this.lastName = data.fields.LastName.value;
            this.email = data.fields.Email.value;
            this.phoneNumber = data.fields.Phone.value;
            this.city = data.fields.City.value;
            this.address = data.fields.Street.value;
            this.title = data.fields.Title.value;
            this.department = data.fields.Department.value;
        }
    };

    //Generic method to handle button clicks
    handleClick(event){
        event.stopPropagation();
        if (event.target.name==="cancelButton"){
            console.log('Cancel Button Clicked');
            eval("$A.get('e.force:refreshView').fire();");
        } else if (event.target.name === "saveButton"){
            this.updateUser();
            console.log('Save Button Clicked');
        } else if (event.target.name === "resetButton"){
            console.log('Reset Password Button Clicked');
        }
    }


    handleResetPassword(){

        const fields = {};
        fields[SUBJECT_FIELD.fieldApiName] = 'Reset My Password for me' +USER_ID +' ';
        fields[STATUS_FIELD.fieldApiName] ='New';
        fields[ORIGIN_FIELD.fieldApiName] = 'Web';
        fields[REASON_FIELD.fieldApiName] = 'Password Reset';

        const recordInput = { apiName: CASE_OBJECT.objectApiName, fields };        
        
        createRecord(recordInput)
           .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Case created',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: reduceErrors(error).join(', '),
                        variant: 'error'
                    })
                );
            });

    }

    updateUser() {
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputFields) => {
                inputFields.reportValidity();
                return validSoFar && inputFields.checkValidity();
            }, true);

        if (allValid) {
            // Create the recordInput object
            const fields = {};
            fields[ID_FIELD.fieldApiName] = USER_ID;
            fields[FIRST_NAME_FIELD.fieldApiName] = this.template.querySelector("[data-field='FirstName']").value;
            fields[LAST_NAME_FIELD.fieldApiName] = this.template.querySelector("[data-field='LastName']").value;
            fields[PHONE_FIELD.fieldApiName] = this.template.querySelector("[data-field='phone']").value;
            fields[CITY_FIELD.fieldApiName] = this.template.querySelector("[data-field='city']").value; 
            fields[TITLE_FIELD.fieldApiName] = this.template.querySelector("[data-field='title']").value;
            fields[DEPARTMENT_FIELD.fieldApiName] = this.template.querySelector("[data-field='department']").value;
            fields[EMAIL_FIELD.fieldApiName] = this.template.querySelector("[data-field='email']").value;
            fields[ADDRESS_FIELD.fieldApiName] = this.template.querySelector("[data-field='address']").value;
            

            const recordInput = { fields };

            updateRecord(recordInput)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'User Information Updated Successfully',
                            variant: 'success'
                        })
                    );
                    // Display fresh data in the form
                    return refreshApex(this.data);
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
            }
        else {
            // The form is not valid
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Something is wrong',
                    message: 'Check your input and try again.',
                    variant: 'error'
                })
             );
        }
    }
}