import { LightningElement, track, wire, api } from 'lwc';
import getPersonDetails from '@salesforce/apex/HOT_UserInfoController.getPersonDetails';
import updateKrrStatus from '@salesforce/apex/HOT_UserInfoController.updateKrrStatus';
import icons from '@salesforce/resourceUrl/icons';

import LINK from '@salesforce/resourceUrl/HOT_Link';
export default class Hot_newLOSForm extends LightningElement {
    LinkImg = LINK;
    warningicon = icons + '/warningicon.svg';

    @track isKrrQueued;
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
        var personCloned = JSON.parse(JSON.stringify(this.personResult));
        try {
            personCloned.INT_KrrIntegrationStatus__c = 'Queued';
            updateKrrStatus({ person: personCloned });
            this.isKrrQueued = true;
        } catch (error) {
            console.log(error);
        }
    }
}
