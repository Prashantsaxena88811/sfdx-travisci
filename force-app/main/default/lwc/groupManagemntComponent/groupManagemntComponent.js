import {
    LightningElement,
    track,
    api
} from 'lwc';
import getGroupMembers from '@salesforce/apex/Group_Management_Controller.getGroupMembers';
import callOutToAPI from '@salesforce/apex/Group_Management_Controller.callOutToAPI';

export default class GroupManagemntComponent extends LightningElement {
    @track groupUsers;
    @track permanentGroupUsers;
    @api groupId;
    @api user;
    @api originalUserData;
    @track showHideAddButton = false;
    @track isLoading = false;
    @track bShowModal = false;
    @api ContactID;

    openModal() {
        // to open modal window set 'bShowModal' tarck value as true
        this.bShowModal = true;
    }

    closeModal() {
        // to close modal window set 'bShowModal' tarck value as false
        this.bShowModal = false;
    }
    setValueOfContactId(event) {
        this.ContactID = event.target.value;
        window.console.log(event.target.value);
    }
    addUser() {
        this.isLoading = true;
        const contactToAdd = '{"contactID": "' + this.ContactID + '"}';
        window.console.log(contactToAdd);
        callOutToAPI({ groupId: this.groupId, userData: contactToAdd, MethodName: 'addUser' })
            .then(result => {
                window.console.log(result);
                this.handleClick();
                this.ContactID = '';
                this.closeModal();
            })
            .catch(error => {
                window.console.log(error);
            });
    }

    handleClick() {

        this.isLoading = true;
        setTimeout(() => {
            //this.handleClick();

            getGroupMembers({
                    groupId: this.groupId
                })
                .then(result => {
                    window.console.log(result);
                    this.groupUsers = result;
                    this.permanentGroupUsers = result;
                    for (let index = 0; index < (this.groupUsers).length; index++) {
                        if (result[index].GroupAccountAdmin == '0') {
                            result[index].statusOfAdmin = false;
                        } else {
                            result[index].statusOfAdmin = true;
                        }
                    }
                    this.groupUsers = this.groupUsers;
                    if ((this.groupUsers).length > 0) {
                        this.showHideAddButton = true;
                    }
                    this.isLoading = false;
                })
                .catch(error => {
                    window.console.log(error);
                });
        }, 1000);
    }
    handleClickRemoveAdmin(event) {
        this.isLoading = true;
        window.console.log("handleClickRemoveAdmin");
        const userdata = event.target.name;
        window.console.log(userdata);
        const contactToAdd = '{"contactID": "' + userdata + '"}';
        /*for (let index = 0; index < (this.permanentGroupUsers).length; index++) {
            //window.console.log(this.permanentGroupUsers[index].ContactID);
            if (this.permanentGroupUsers[index].ContactID == userdata) {
                this.originalUserData = this.permanentGroupUsers[index];
                this.originalUserData.status = "1";
            }
        }*/
        callOutToAPI({
                groupId: this.groupId,
                userData: contactToAdd,
                MethodName: 'removeAdmin'
            })
            .then(result => {
                window.console.log(result);
                /*setTimeout(() => {
                    this.handleClick();
                }, 3000);*/
                this.handleClick();

            })
            .catch(error => {
                window.console.log(error);
            });
    }
    handleClickAddAdmin(event) {
        this.isLoading = true;
        window.console.log("handleClickAddAdmin");
        const userdata = event.target.name;
        window.console.log(userdata);
        const contactToAdd = '{"contactID": "' + userdata + '"}';
        /*for (let index = 0; index < (this.permanentGroupUsers).length; index++) {
            if (this.permanentGroupUsers[index].ContactID == userdata) {
                this.originalUserData = this.permanentGroupUsers[index];
                this.originalUserData.status = "0";
            }
        }*/
        callOutToAPI({
                groupId: this.groupId,
                userData: contactToAdd,
                MethodName: 'makeAdmin'
            })
            .then(result => {
                window.console.log(result);
                /*setTimeout(() => {
                    this.handleClick();
                }, 3000);*/
                this.handleClick();


            })
            .catch(error => {
                window.console.log(error);
            });
    }
    removeUser(event) {
        this.isLoading = true;
        window.console.log("removeUser");
        callOutToAPI({
                groupId: this.groupId,
                userData: JSON.stringify(this.originalUserData),
                MethodName: 'removeUser'
            })
            .then(result => {
                window.console.log(result);
                this.handleClick();

            })
            .catch(error => {
                window.console.log(error);
            });
    }
    setValueOfGroupId(event) {
        this.groupId = event.target.value;
        window.console.log(event.target.value);
    }
    handleClickRemoveFromGroup(event) {
        const userdata = event.target.name;
        for (let index = 0; index < (this.permanentGroupUsers).length; index++) {
            //window.console.log(this.permanentGroupUsers[index].ContactID);
            if (this.permanentGroupUsers[index].ContactID == userdata) {
                this.originalUserData = this.permanentGroupUsers[index];
            }
        }
        this.removeUser(event);

    }

}