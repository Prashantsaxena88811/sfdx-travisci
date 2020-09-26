import { LightningElement, track, api } from 'lwc';

export default class ComboboxBasic extends LightningElement {
    caseTypeVal;
    caseSeverity;
    caseSubject;
    caseDescription;
    uploadedAttachment;
    @api myRecordId;
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
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: uploadedFiles.length + ' Files uploaded Successfully: ' + uploadedFileNames,
                variant: 'success',
            }),
            
        );
    }

    createCase(event) {  
        alert('Type ' + this.caseTypeVal+'\n'+'Severity ' + this.caseSeverity+'\n'+'Subject ' + this.caseSubject+'\n'+'Description ' + this.caseDescription + 'File '+this.uploadedFiles[0].name);
        //var v = this.template.querySelector('caseType').value;
        //alert(v);
    }

}