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
    personResult;

    @wire(getPersonDetails)
    wiredResult(result) {
        if (result.data) {
            this.personResult = result.data;
            this.fieldValues.Address__c =
                this.personResult.HOT_Address__c === undefined ? '' : this.personResult.HOT_Address__c;
            this.fieldValues.BankAccount__c =
                this.personResult.INT_BankAccountNumber__c === undefined
                    ? ''
                    : this.personResult.INT_BankAccountNumber__c;
            this.fieldValues.PhoneNumber__c =
                this.personResult.INT_KrrMobilePhone__c === undefined ? '' : this.personResult.INT_KrrMobilePhone__c;
            this.fieldValues.EmailAdress__c =
                this.personResult.INT_KrrEmail__c === undefined ? '' : this.personResult.INT_KrrEmail__c;
        } else {
            this.fieldValues.Address__c = '';
            this.fieldValues.BankAccount__c = '';
            this.fieldValues.PhoneNumber__c = '';
            this.fieldValues.EmailAdress__c = '';
        }
    }

    connectedCallback() {}
}
