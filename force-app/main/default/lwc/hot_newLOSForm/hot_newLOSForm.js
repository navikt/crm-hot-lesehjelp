import { LightningElement, track, wire, api } from 'lwc';
import getPersonDetails from '@salesforce/apex/HOT_UserInfoController.getPersonDetails';

import LINK from '@salesforce/resourceUrl/HOT_Link';
export default class Hot_newLOSForm extends LightningElement {
    LinkImg = LINK;
    @track fieldValues = {
        BankAccount__c: '',
        PhoneNumber__c: '',
        EmailAdress__c: '',
        Address__c: ''
    };
    @track person;

    // @wire(getPersonDetails)
    // wiredResult(result) {
    //     this.person = result.data;
    //     console.log('id' + this.person.Id);
    // }

    connectedCallback() {
        this.fieldValues.Address__c = 'test';
        this.fieldValues.BankAccount__c = 'test';
        this.fieldValues.PhoneNumber__c = 'test';
        this.fieldValues.EmailAdress__c = 'test';
    }
}
