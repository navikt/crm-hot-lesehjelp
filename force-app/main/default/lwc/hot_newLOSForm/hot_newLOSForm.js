import { LightningElement, track, wire, api } from 'lwc';
import getPersonDetails from '@salesforce/apex/HOT_UserInfoController.getPersonDetails';
import updateKrrStatus from '@salesforce/apex/HOT_UserInfoController.updateKrrStatus';

import LINK from '@salesforce/resourceUrl/HOT_Link';
export default class Hot_newLOSForm extends LightningElement {
    LinkImg = LINK;

    @track isKrrQueued;
    @track fieldValues = {
        BankAccount__c: '',
        PhoneNumber__c: '',
        EmailAdress__c: '',
        Address__c: ''
    };
    personResult;

    @api validateFields() {
        let hasErrors = false;
        const fields = [
            { name: 'BankAccount__c', label: 'Kontonummer' },
            { name: 'EmailAdress__c', label: 'Epost' }
        ];
        fields.forEach((field) => {
            const input = this.template.querySelector(`c-input[data-name="${field.name}"]`);
            if (!input) return;
            const value = input.value;
            const isMissing = typeof value !== 'string' || value.trim() === '';
            input.sendErrorMessage(isMissing ? `${field.label} må fylles ut.` : '');
            hasErrors = hasErrors || isMissing;
        });
        return hasErrors;
    }

    @wire(getPersonDetails)
    wiredResult(result) {
        if (result.data) {
            this.personResult = result.data;
            this.fieldValues.Address__c =
                this.personResult.INT_ResidentialAddress__c === undefined
                    ? ''
                    : this.personResult.INT_ResidentialAddress__c;
            this.fieldValues.Address__c +=
                this.personResult.INT_ResidentialZipCode__c == undefined
                    ? ''
                    : ', ' + this.personResult.INT_ResidentialZipCode__c;
            this.fieldValues.Address__c +=
                this.personResult.INT_ResidentialPlace__c == undefined
                    ? ''
                    : ' ' + this.personResult.INT_ResidentialPlace__c;

            this.fieldValues.BankAccount__c =
                this.personResult.INT_BankAccountNumber__c === undefined
                    ? ''
                    : this.personResult.INT_BankAccountNumber__c;
            this.fieldValues.PhoneNumber__c =
                this.personResult.INT_KrrMobilePhone__c === undefined ? '' : this.personResult.INT_KrrMobilePhone__c;
            this.fieldValues.EmailAdress__c =
                this.personResult.INT_KrrEmail__c === undefined ? '' : this.personResult.INT_KrrEmail__c;
            this.isKrrQueued = this.personResult.INT_KrrIntegrationStatus__c == 'Queued' ? true : false;
        } else {
            this.fieldValues.Address__c = '';
            this.fieldValues.BankAccount__c = '';
            this.fieldValues.PhoneNumber__c = '';
            this.fieldValues.EmailAdress__c = '';
        }
    }
    setKrrIntegrationStatusToQueued() {
        if (!this.personResult) return;
        const personCloned = { ...this.personResult, INT_KrrIntegrationStatus__c: 'Queued' };
        updateKrrStatus({ person: personCloned })
            .then(() => {
                this.isKrrQueued = true;
            })
            .catch((error) => {
                console.error(error);
            });
    }
}
