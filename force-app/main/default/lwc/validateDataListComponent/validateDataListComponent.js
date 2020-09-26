import { LightningElement,api,wire,track} from 'lwc';
import fetchLookUpValuesUser from '@salesforce/apex/CustomModalClass.fetchLookUpValuesUser'; 
import fetchLookUpValuesGroup from '@salesforce/apex/CustomModalClass.fetchLookUpValuesGroup';
 export default class ValidateDataListComponent extends LightningElement {  
  @track recordsList;  
  @track searchKey = "";  
  @api selectedValue;  
  @api selectedRecordId;  
  @api objectApiName;  
  @api iconName;  
  @api lookupLabel;  
  @track message;
  @track ifBlank;
    
  get userOrGroup() {
        return this.objectApiName == 'User' ? true : false;
    }
  
  onLeave(event) {  
   setTimeout(() => {  
     
    this.recordsList = null;  
   }, 300);  
  }  
    
  onRecordSelection(event) {  
   this.selectedRecordId = event.target.dataset.key;  
   this.selectedValue = event.target.dataset.name;  
   this.searchKey = "";  
   this.onSeletedRecordUpdate();  
  }  
   
  handleKeyChange(event) {  
   const searchKey = event.target.value;  
   this.searchKey = searchKey;  
   if(this.searchKey.length>2){
     this.getLookupResult();  
   }
  }  
   
  removeRecordOnLookup(event) {  
   this.searchKey = "";  
   this.selectedValue = null;  
   this.selectedRecordId = null;  
   this.recordsList = null;  
   this.onSeletedRecordUpdate();  
 }  



  getLookupResult() {  
    var ans = this.objectApiName.localeCompare('User');
    if(ans == 0){
      fetchLookUpValuesUser({ searchKey: this.searchKey, objectName : this.objectApiName })  
        .then((result) => {  
        if (result.length===0) {  
          this.recordsList = [];  
          this.message = "No Records Found";  
        } else {  
          this.recordsList = result;  
          console.log('recordList--->'+JSON.stringify(result));
          this.message = "";  
        }  
          this.error = undefined;  
        })  
        .catch((error) => {  
        this.error = error;  
        this.recordsList = undefined;  
        });  
    }else{
      fetchLookUpValuesGroup({ searchKey: this.searchKey, objectName : this.objectApiName })  
        .then((result) => {  
        if (result.length===0) {  
          this.recordsList = [];  
          this.message = "No Records Found";  
          } else {  
          this.recordsList = result;  
          this.message = "";  
          }  
          this.error = undefined;  
        })
        .catch((error) => {  
        this.error = error;  
        this.recordsList = undefined;  
        });
    }
  }  
   
  onSeletedRecordUpdate(){  
   const passEventr = new CustomEvent('recordselection', {  
     detail: { selectedRecordId: this.selectedRecordId, selectedValue: this.selectedValue }  
    });  
    this.dispatchEvent(passEventr);  
  }  
 }