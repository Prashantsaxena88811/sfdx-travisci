import { LightningElement, track } from 'lwc';
import getAssets from '@salesforce/apex/FetchAssetListComponent.getAssets';
import getAssetsByPageNumber from '@salesforce/apex/FetchAssetListComponent.getAssetsByPageNumber';
import getAssetsByfilters from '@salesforce/apex/FetchAssetListComponent.getAssetsByfilters';

const columns = [{
        label: 'Product',
        fieldName: 'productID',
        type: 'product2Id',
        sortable: true
    },
    {
        label: 'Img',
        fieldName: '',
        type: 'Image',
        sortable: true
    },
    {
        label: 'S/N',
        fieldName: 'serialNo',
        type: 'text',
        sortable: true

    },
    {
        label: 'Asset No.',
        fieldName: 'assetID',
        type: 'text',
        sortable: true

    },
    {
        label: 'Purchase Order Number',
        fieldName: 'salesOrderNo',
        type: 'text',
        sortable: true

    },
    {
        label: 'Site',
        fieldName: 'SiteName',
        type: 'text',
        sortable: true

    },
    {
        label: 'Type',
        fieldName: 'productType',
        type: 'text',
        sortable: true

    },
    {
        label: 'Service Date',
        fieldName: 'shipDate',
        type: 'Date',
        sortable: true

    },
    {
        label: 'Calibration Due Date',
        fieldName: '',
        type: 'text',
        sortable: true

    },
    {
        label: 'Print Call Due',
        fieldName: '',
        type: 'Checkbox',
        sortable: true

    },
    {
        label: 'Order No.',
        fieldName: 'salesOrderNo',
        type: 'text',
        sortable: true

    },
    {
        label: 'User / Location',
        fieldName: 'contactIDs',
        type: 'Text',
        sortable: true

    },
    {
        label: 'System Name',
        fieldName: 'manufModelNo',
        type: 'Date',
        sortable: true

    },
    {
        label: 'My Assets ?',
        fieldName: '',
        type: 'checkbox',
        sortable: true

    },
    {
        label: 'Upg',
        fieldName: '',
        type: 'Text',
        sortable: true

    }
];
export default class AssetComponent extends LightningElement {
    @track columns = [{
            label: 'Product',
            fieldName: 'productID',
            type: 'product2Id',
            sortable: true
        },
        {
            label: 'Img',
            fieldName: '',
            type: 'Image',
            sortable: true
        },
        {
            label: 'S/N',
            fieldName: 'serialNo',
            type: 'text',
            sortable: true

        },
        {
            label: 'Asset No.',
            fieldName: 'assetID',
            type: 'text',
            sortable: true

        },
        {
            label: 'Purchase Order Number',
            fieldName: 'salesOrderNo',
            type: 'text',
            sortable: true

        },
        {
            label: 'Site',
            fieldName: 'SiteName',
            type: 'text',
            sortable: true

        },
        {
            label: 'Type',
            fieldName: 'productType',
            type: 'text',
            sortable: true

        },
        {
            label: 'Service Date',
            fieldName: 'shipDate',
            type: 'Date',
            sortable: true

        },
        {
            label: 'Calibration Due Date',
            fieldName: '',
            type: 'text',
            sortable: true

        },
        {
            label: 'Print Call Due',
            fieldName: '',
            type: 'Checkbox',
            sortable: true

        },
        {
            label: 'Order No.',
            fieldName: 'salesOrderNo',
            type: 'text',
            sortable: true

        },
        {
            label: 'User / Location',
            fieldName: 'contactIDs',
            type: 'Text',
            sortable: true

        },
        {
            label: 'System Name',
            fieldName: 'manufModelNo',
            type: 'Date',
            sortable: true

        },
        {
            label: 'My Assets ?',
            fieldName: '',
            type: 'checkbox',
            sortable: true

        },
        {
            label: 'Upg',
            fieldName: '',
            type: 'Text',
            sortable: true

        }
    ];
    @track isLoading = false;
    @track setofsites = [];
    @track setofusers = [];
    @track setofProductName = [];
    @track setofGroupName = [];
    @track countOfRecord = 0;
    @track currentPageData = [];
    @track pageNumber = 1;
    @track pageCount = 1;
    @track selectedUser = '';
    @track selectedProduct = '';
    @track selectedGroup = '';
    @track selectedSite = '';
    prevPage(event) {
        --this.pageNumber;
        this.callToServer();
    }
    nextPage(event) {
        ++this.pageNumber;
        this.callToServer();
    }
    goToPage(event) {
        this.callToServer();
    }
    async connectedCallback() {
        this.isLoading = true;
        console.log('connectedCallback called');
        this.data = await getAssets();
        var objectData = JSON.parse(this.data);
        this.countOfRecord = objectData.resp.totalResults;
        this.pageCount = Math.ceil((objectData.resp.totalResults) / 10);
        this.currentPageData = objectData.resp.results;
        window.console.log(objectData);
        //window.console.log(objectData["resp"]);

        this.setofsites = objectData["resp"]["facets"]["SiteID.keyword"]["buckets"];
        this.setofusers = objectData["resp"]["facets"]["ContactIDS.keyword"]["buckets"];
        this.setofProductName = objectData["resp"]["facets"]["ProductID.keyword"]["buckets"];
        this.setofGroupName = objectData["resp"]["facets"]["GroupID.keyword"]["buckets"];
        this.isLoading = false;
    }
    callToServer() {
        this.isLoading = true;
        if (this.pageNumber < 1) {
            this.isLoading = false;
            return;
        }
        if (this.pageCount < this.pageNumber) {
            this.isLoading = false;
            return;
        }
        console.log(this.dynamicURL);
        getAssetsByPageNumber({ pageNumber: this.pageNumber, dynamicURLApex: this.dynamicURL })
            .then(result => {
                console.log('called');
                var objectData = JSON.parse(result);
                this.countOfRecord = objectData.resp.totalResults;
                this.pageCount = Math.ceil((objectData.resp.totalResults) / 10);
                this.currentPageData = objectData.resp.results;
                window.console.log(objectData);
                //window.console.log(objectData["resp"]);
                if (!this.dynamicURL) {
                    this.setofsites = objectData["resp"]["facets"]["SiteID.keyword"]["buckets"];
                    this.setofusers = objectData["resp"]["facets"]["ContactIDS.keyword"]["buckets"];
                    this.setofProductName = objectData["resp"]["facets"]["ProductID.keyword"]["buckets"];
                    this.setofGroupName = objectData["resp"]["facets"]["GroupID.keyword"]["buckets"];
                }
                this.isLoading = false;
            })
            .catch(error => {
                window.console.log(error);
                this.isLoading = false;
            });
    }
    @track reset = true;
    resetData() {

        console.log(this.template.querySelector('#selectionChangesetofusers'));
        this.reset = false;
        this.connectedCallback();
        this.isLoading = true;
        setTimeout(() => {
            this.reset = true;
            this.isLoading = false;
            this.selectedUser = '';
            this.selectedProduct = '';
            this.selectedGroup = '';
            this.selectedSite = '';
            this.pageNumber = 1;
            this.dynamicURL = '';
        }, 500);
    }
    @track dynamicURL = '';
    callToServerWithFilters() {
        this.isLoading = true;
        this.dynamicURL = this.selectedUser + this.selectedProduct + this.selectedGroup + this.selectedSite;
        getAssetsByfilters({ dynamicURLApex: this.dynamicURL })
            .then(result => {
                console.log('called');
                console.log(result);
                var objectData = JSON.parse(result);
                this.countOfRecord = objectData.resp.totalResults;
                this.pageCount = Math.ceil((objectData.resp.totalResults) / 10);
                this.currentPageData = objectData.resp.results;
                window.console.log(objectData);
                //window.console.log(objectData["resp"]);
                setTimeout(() => {
                    this.pageNumber = 1;
                    this.setofsites = objectData["resp"]["facets"]["SiteID.keyword"]["buckets"];
                    console.log(objectData["resp"]["facets"]["SiteID.keyword"]["buckets"]);
                    this.setofusers = objectData["resp"]["facets"]["ContactIDS.keyword"]["buckets"];
                    console.log(objectData["resp"]["facets"]["ContactIDS.keyword"]["buckets"]);
                    this.setofProductName = objectData["resp"]["facets"]["ProductID.keyword"]["buckets"];
                    this.setofGroupName = objectData["resp"]["facets"]["GroupID.keyword"]["buckets"];
                    this.isLoading = false;
                }, 500);
            })
            .catch(error => {
                window.console.log(error);
                this.isLoading = false;
            });
    }
    setPageNumber(event) {
        this.pageNumber = event.target.value;
        //window.console.log(event.target.value);
    }

    selectionChangesetofusers(event) {
        if (String(event.target.value) == "ALL") {
            this.selectedUser = '';
        } else {
            this.selectedUser = '&filter=ContactIDS.keyword%3A' + event.target.value;
        }
        console.log(this.selectedUser);
    }

    selectionChangesetofProductName(event) {
        if (String(event.target.value) == 'ALL') {
            this.selectedProduct = '';
        } else {
            this.selectedProduct = '&filter=ProductID.keyword%3A' + event.target.value;
        }
        console.log(this.selectedProduct);
    }

    selectionChangesetofGroupName(event) {
        if (String(event.target.value) == 'ALL') {
            this.selectedGroup = '';
        } else {
            this.selectedGroup = '&filter=GroupID.keyword%3A' + event.target.value;
        }
        console.log(this.selectedGroup);
    }
    selectionChangesetofsites(event) {
        if (String(event.target.value) == 'ALL') {
            this.selectedSite = '';
        } else {
            this.selectedSite = '&filter=SiteID.keyword%3A' + event.target.value;
        }
        console.log(this.selectedSite);
    }


}