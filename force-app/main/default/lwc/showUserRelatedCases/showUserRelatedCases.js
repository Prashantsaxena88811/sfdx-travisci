import { LightningElement , wire} from 'lwc';
import getCaseList from '@salesforce/apex/ShowUserRelatedCases_Controller.getCaseList';
export default class ShowUserRelatedCases extends LightningElement {

    @wire(getCaseList) caseList;
}