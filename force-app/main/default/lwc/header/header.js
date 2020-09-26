import { LightningElement } from 'lwc';
import isguest from '@salesforce/user/isGuest';


export default class Header extends LightningElement {
    isGuestUser = isguest;
}