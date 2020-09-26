import { LightningElement } from 'lwc';

export default class CustomReport extends LightningElement {

    value = ['option1'];

    get options() {
        return [
            { label: 'Ross', value: 'option1' },
          
        ];
    }
    get selectedValues() {
        return this.value.join(',');
    }



}