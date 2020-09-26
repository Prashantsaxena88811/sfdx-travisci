import {
    LightningElement,
    track,
    api
} from 'lwc';
import getMySites from '@salesforce/apex/UserManagementController.getMySites';
import updatePreference from '@salesforce/apex/UserManagementController.updatePreference';

export default class UserManagemntComponent extends LightningElement {
    @track tableData;
    @track showSpinner = false;
    @track showUpdateButton = false;
    @track contactID;
    @track reset = true;

    handleSearch(event) {
        let contactId = this.template.querySelector('lightning-input').value;
        this.reset = false;
        if (contactId != null && contactId != '') {
            this.showSpinner = true;
            this.contactID = contactId;
            if (contactId) {
                getMySites({
                        contactId: this.contactID
                    })
                    .then(result => {
                        if (result.length > 0) {
                            this.tableData = result[0].sites;
                            this.showUpdateButton = true;
                        } else {
                            this.showUpdateButton = false;
                        }
                        setTimeout(() => {
                            this.reset = true;
                            this.showSpinner = false;
                        }, 500);
                    })
                    .catch(error => {
                        console.log('getMySites --> ' + error);
                        this.showSpinner = false;
                    });
            }
        } else {
            alert('Please enter the User Id');
        }
    }

    saveData(event) {
        this.showSpinner = true;
        var data = this.tableData;
        var siteData = '';
        var siteDataList = [];
        if (data.length > 0) {
            for (let i = 0; i < data.length; i++) {
                // if (this.template.querySelector('lightning-input[data-id="' + data[i].siteId + '"]').checked != data[i].preferred) {
                siteData = '{"preferred":' + this.template.querySelector('lightning-input[data-id="' + data[i].siteId + '"]').checked +
                    ',"siteId":"' + data[i].siteId + '"}';
                console.log(siteData);
                siteDataList.push(siteData);
                //}
            }
            console.log(siteDataList);
        }
        for (let i = 0; i < siteDataList.length; i++) {
            setTimeout(() => {
                this.showSpinner = true;
                updatePreference({
                        contactId: this.contactID,
                        sites: siteDataList[i]
                    })
                    .then(() => {
                        this.showSpinner = false;
                    })
                    .catch(error => {
                        console.log(error);
                        this.showSpinner = false;
                    })
            }, 500);
        }
        this.handleSearch(event);

    }


}