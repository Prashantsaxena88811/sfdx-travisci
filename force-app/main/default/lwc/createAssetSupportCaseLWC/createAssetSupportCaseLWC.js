import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createSupportCaseFromCmp from '@salesforce/apex/AssetManagementComponent_Controller.createSupportCase';
export default class CreateAssetSupportCaseLWC extends LightningElement {

    @api assetInstance;
    @track showArticleSearch;
    @track showChooseCaseType;
    @track showCreateCaseForm;
    @track showSaveButton;
    @track caseTypeOptionList;
    @track caseType;
    @track caseStatus;
    @track caseSubject;

    //Added by Vishwas team
    caseTypeVal;
    caseSeverity;
    caseSubject;
    caseDescription;
    uploadedAttachment;
    @api myRecordId;
    @wire(createSupportCaseFromCmp) wiredCase;
    

    /* end */

    connectedCallback(){
        console.log('asset '+JSON.stringify(this.assetInstance));
        this.caseTypeOptionList = [
            { label: 'Choose one...', value: ''},
            { label: 'Technical Support', value: 'TechnicalSupport' },
            { label: 'Software Licensing', value: 'SoftwareLicensing' },
            { label: 'General Inquiry', value: 'GeneralInquiry' }
          ];
        this.showCreateCaseForm = false;
        this.showSaveButton = false;
        this.showChooseCaseType = false;
        this.showArticleSearch = true;
    }

    opneCaseForm(){
        this.showChooseCaseType = true;
        this.showArticleSearch = false;
    }
    searchArticle(){}
    searchArticleQuickSearchOptionList(){}
    selectCaseType(){
        this.showCreateCaseForm = true;
        this.showChooseCaseType = false;
        this.showSaveButton = true;
    }
    selectionChangeHandler(event) {
        this.caseType = event.target.value;
    }
    createCase(){
        const saveEvent = new CustomEvent("SaveCase", {
            detail: 'Send Case value here'
          });
        this.dispatchEvent(saveEvent);
    }


    //Added by Vishwas team
    //This will be loded accordingly from Case & Org
    get caseTypeOptions() {
        return [
            { label: 'Mechanical', value: 'Mechanical' },
            { label: 'Electrical', value: 'Electrical' },
            { label: 'Electronic', value: 'Electronic' },
            { label: 'Structural', value: 'Structural' },
            { label: 'Other', value: 'Other' },
            { label: 'Repair', value: 'Repair' },
            { label: 'Routine Maintenance', value: 'Routine Maintenance' },
        ];
    }
    //This will be loded accordingly from Case & Org
    get caseSeverityOptions() {
        return [
            { label: 'Low', value: 'Low' },
            { label: 'Medium', value: 'Medium' },
            { label: 'High', value: 'High' },
        ];
    }

    //This will come from External API
    //This will be loded accordingly from Case & Org
    get ArticleData() {
        return [
            { label: 'How can I check shipment status?', value: 'Mechanical' },
            { label: 'Where to find Beginner Getting Started Guide?', value: 'Mechanical 2' },
            { label: 'How can I check shipment status?', value: 'Mechanical 3' },
            { label: 'How can I check Order Summary?', value: 'Mechanical 4' },
            { label: 'How can I check my Previous Orders?', value: 'Mechanical 5' },
        ];
    }

    get acceptedFormats() {
        return ['.pdf', '.png'];
    }
    
    handleCaseTypeValue(event){
        this.caseTypeVal = event.target.value;
    }
    handleCaseSeverityValue(event){
        this.caseSeverity = event.target.value;
    }
    handleCaseSubjectValue(event){
        this.caseSubject = event.target.value;
    }
    handleCaseDescValue(event){
        this.caseDescription = event.target.value;
    }
    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        this.uploadedFiles = event.detail.files;
        let uploadedFileNames = '';
        for(let i = 0; i < uploadedFiles.length; i++) {
            uploadedFileNames += uploadedFiles[i].name + ', ';
        }
    }

    createCase(event) {  
        //alert('Type ' + this.caseTypeVal+'\n'+'Severity ' + this.caseSeverity+'\n'+'Subject ' + this.caseSubject+'\n'+'Description ' + this.caseDescription);
        if(this.uploadedFiles.length==0 || this.caseTypeVal==undefined || this.caseSeverity==undefined || this.caseSubject==undefined || this.caseDescription==undefined){
            
            //some msgs

        }else{
            //alert('File '+this.uploadedFiles[0].name);
            createSupportCaseFromCmp({caseType: this.caseTypeVal.toString(), caseAssest : this.assetInstance.product_no.toString(), casePriority : this.caseSeverity.toString(), caseSubject : this.caseSubject.toString(), caseDescription : this.caseDescription.toString() }, )
            .then(result => {
                const event = new ShowToastEvent({
                    title: 'Support Case Created',
                    message: 'Case submitted sucessfully. ',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);

                const saveEvent = new CustomEvent("closeModalEvent", {
                    detail: 'true'
                  });
                this.dispatchEvent(saveEvent);
            })
            .catch(error => {
                const event = new ShowToastEvent({
                    title: 'Support Case Created',
                    message: 'Error',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                //this.error = error;
            });
        }
        
        
        
    }
}