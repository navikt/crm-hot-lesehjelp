import { LightningElement, track, wire, api } from 'lwc';

export default class Hot_newLOSForm extends LightningElement {
    @track fieldValues = {
        BankAccount__c: '',
        PostalCode__c: '',
        PostalArea__c: '',
        PhoneNumber__c: '',
        EmailAdress__c: '',
        Address__c: ''
    };

    @api
    validateFields() {
        let hasErrors = 0;
        // this.template.querySelectorAll('c-input').forEach((element) => {
        //     if (element.validationHandler()) {
        //         hasErrors += 1;
        //     }
        // });

        // hasErrors += this.isPersonNumber
        //     ? this.template.querySelectorAll('c-input')[1].validatePersonNumber()
        //     : this.template
        //           .querySelectorAll('c-input')[1]
        //           .validatePhoneLength('Telefonnummer må være 8 siffer langt (ingen landskode).');
        return hasErrors;
    }
    // handleAdditionalInformation(event) {
    //     const index = this.getTimesIndex(event.target.name);
    //     this.times[index].additionalInformation = event.detail;
    // }
    setFieldValue(event) {
        //for (let k in fields) {
        this.fieldValues[event.target.name] = event.detail;
        //}
    }

    @api
    getNewLOSInput() {
        return this.fieldValues;
    }

    connectedCallback() {
        this.fieldValues.PostalCode__c = 'test';
    }
}
