import { LightningElement, track, wire, api } from 'lwc';
export default class hot_claimFormUser extends LightningElement {
    @track isPersonNumber = true;
    @track fieldValues = {
        UserName__c: '',
        UserPersonNumber__c: '',
        UserPhoneNumber__c: '',
        UserPhoneNumberOrUserPersonNumber__c: ''
    };
    @track componentValues = {
        userPhoneNumberOrUserPersonNumberRadioButtons: [
            { label: 'Fødselsnummer', value: 'personNumber', checked: true },
            { label: 'Telefonnummer', value: 'phoneNumber' }
        ],
        isOptionalFields: false
    };

    @api parentClaimComponentValues;
    @api parentFieldValues;

    handlePhoneNumberogPersonNumberRadioButtons(event) {
        this.componentValues.userPhoneNumberOrUserPersonNumberRadioButtons = event.detail;
        if (event.detail[0].checked) {
            this.isPersonNumber = true;
            this.UserPhoneNumber__c = '';
        } else {
            this.isPersonNumber = false;
            this.UserPersonNumber__c = '';
        }
    }

    @api
    setFieldValues() {
        this.template.querySelectorAll('c-input').forEach((element) => {
            this.fieldValues[element.name] = element.getValue();
        });
    }

    @api
    validateFields() {
        let hasErrors = 0;
        this.template.querySelectorAll('c-input').forEach((element) => {
            if (element.validationHandler()) {
                hasErrors += 1;
            }
        });
        hasErrors += this.isPersonNumber
            ? this.template.querySelectorAll('c-input')[1].validatePersonNumber()
            : this.template
                  .querySelectorAll('c-input')[1]
                  .validatePhoneLength('Telefonnummer må være 8 siffer langt (ingen landskode).');
        return hasErrors;
    }

    @api
    getFieldValues() {
        return this.fieldValues;
    }
    @api getComponentValues() {
        return this.componentValues;
    }

    connectedCallback() {
        this.showDiv = true;
        setTimeout(() => this.template.querySelector('h2').focus());

        for (let field in this.parentFieldValues) {
            if (this.fieldValues[field] != null) {
                this.fieldValues[field] = this.parentFieldValues[field];
            }
        }
        for (let field in this.parentClaimComponentValues) {
            if (this.componentValues[field] != null) {
                this.componentValues[field] = JSON.parse(JSON.stringify(this.parentClaimComponentValues[field]));
            }
        }
        const selectedValue = this.componentValues.userPhoneNumberOrUserPersonNumberRadioButtons.find(
            (option) => option.checked
        );
        if (selectedValue.value === 'personNumber') {
            this.isPersonNumber = true;
        } else {
            this.isPersonNumber = false;
        }
    }
}
