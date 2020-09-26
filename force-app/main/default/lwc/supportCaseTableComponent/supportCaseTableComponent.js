import { LightningElement, api, wire, track } from 'lwc';
import caseData from '@salesforce/apex/SupportCaseTableComponentController.getCase';

export default class SupportCaseTableComponent extends LightningElement {

    supportCases;
    UnfilteredsupportCases;
    connectedCallback() {

        caseData()
            .then(result => {
                this.supportCases = result;
                this.UnfilteredsupportCases = result;
                console.log(this.supportCases);
            })
            .catch(error => {

            });
    }
    handleKeyUpColumnSearch(event) {
        try {
            let columnName = event.target.name;
            let searchKey = event.target.value;
            console.log('columnName-->>' + columnName);
            console.log('value-->>' + searchKey);
            if (columnName) {
                console.log('-->>>' + columnName);
                this.FilterRecords(columnName, searchKey);

            } else {
                this.supportCases = this.UnfilteredsupportCases;
            }


        } catch (error) {
            console.log('Exception is-->>' + error.message);
        }
    }
    FilterRecords(fieldname, searchKey) {
        try {
            let data = this.supportCases;
            let allData = this.UnfilteredsupportCases;

            if (data || data != undefined || data.length > 0) {
                console.log('-->>>')
                var filtereddata = allData.filter(
                    word => ((!searchKey) || (word[fieldname] && word[fieldname].toLowerCase().indexOf(searchKey.toLowerCase()) > -1))
                );
                console.log('** ' + filtereddata);
                this.supportCases = filtereddata;
            }
        } catch (error) {
            console.log('Exception is-->>' + error.message);
        }


    }
    handleCheckBoxChange(event) {
        try {

        } catch (error) {
            console.log('Exception is-->>' + error.message);
        }
    }
    handleAllCheckChange(event) {
        try {

        } catch (error) {
            console.log('Exception is-->>' + error.message);
        }
    }
}