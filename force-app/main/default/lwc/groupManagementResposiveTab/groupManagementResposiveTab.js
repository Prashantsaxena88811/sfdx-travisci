import {
    LightningElement,
    track,
    api
} from 'lwc';

export default class GroupManagementResposiveTab extends LightningElement {
    @track groupManagementTab = true
    @track groupManagementTabCss = "slds-vertical-tabs__nav-item slds-is-active";

    @track mySitesTab = false;
    @track mySitesTabCss = "slds-vertical-tabs__nav-item";
    @track assetsTab = false;
    @track assetsTabCss = "slds-vertical-tabs__nav-item";
    @track searchTab = false;
    @track searchTabCss = "slds-vertical-tabs__nav-item";
    /*@track assetsTab = false;
    @track assetsTabCss = "slds-vertical-tabs__nav-item";*/
    groupManagement() {
        this.groupManagementTab = true;
        this.groupManagementTabCss = "slds-vertical-tabs__nav-item  slds-is-active";
        this.mySitesTab = false;
        this.mySitesTabCss = "slds-vertical-tabs__nav-item";
        this.assetsTab = false;
        this.assetsTabCss = "slds-vertical-tabs__nav-item";
        this.searchTab = false;
        this.searchTabCss = "slds-vertical-tabs__nav-item";
    }
    mySites() {
        this.groupManagementTab = false;
        this.groupManagementTabCss = "slds-vertical-tabs__nav-item";
        this.mySitesTab = true;
        this.mySitesTabCss = "slds-vertical-tabs__nav-item slds-is-active";
        this.assetsTab = false;
        this.assetsTabCss = "slds-vertical-tabs__nav-item";
        this.searchTab = false;
        this.searchTabCss = "slds-vertical-tabs__nav-item";
    }
    assets() {
        this.groupManagementTab = false;
        this.groupManagementTabCss = "slds-vertical-tabs__nav-item";
        this.mySitesTab = false;
        this.mySitesTabCss = "slds-vertical-tabs__nav-item";
        this.assetsTab = true;
        this.assetsTabCss = "slds-vertical-tabs__nav-item slds-is-active";
        this.searchTab = false;
        this.searchTabCss = "slds-vertical-tabs__nav-item";
    }
    search() {
        this.groupManagementTab = false;
        this.groupManagementTabCss = "slds-vertical-tabs__nav-item";
        this.mySitesTab = false;
        this.mySitesTabCss = "slds-vertical-tabs__nav-item";
        this.assetsTab = false;
        this.assetsTabCss = "slds-vertical-tabs__nav-item";
        this.searchTab = true;
        this.searchTabCss = "slds-vertical-tabs__nav-item slds-is-active";
    }
}