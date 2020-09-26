import { LightningElement, api } from 'lwc';

export default class SupportTableFiltercmp extends LightningElement {

    @api isfilterpanel = false;
    activeSections = ['A', 'B', 'C', 'D'];
    activeSectionsMessage = '';

    closeFilterPanel(event) {
        if (this.isfilterpanel) {
            this.isfilterpanel = false;
        } else {
            this.isfilterpanel = tru
        }

    }

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;

        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    }


}