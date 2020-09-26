import { LightningElement} from 'lwc';
import DCX_RESOURCE from '@salesforce/resourceUrl/DCXResource';

export default class HeaderGuest extends LightningElement {
    logokeySight = DCX_RESOURCE + '/DCXResource/images/keysight-logo.png';
    showSearch=false;
    placeHolder = 'How can we help you?';

    showSearchBar(){
        this.showSearch = !this.showSearch;
    }

    showData(event){
        console.log('show data called');
        this.template.querySelector('.showhide').classList.add('slds-is-open'); 
        //this.template.querySelector('.noBtn').classList.remove('dynamicCSS')
	}
	hideData(event){
		//this.template.querySelector('.noBtn').classList.add('dynamicCSS');
        this.template.querySelector('.showhide').classList.remove('slds-is-open');

	}

   
    
    
}