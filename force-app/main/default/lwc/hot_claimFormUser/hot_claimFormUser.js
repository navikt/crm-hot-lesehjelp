import { LightningElement, track, wire, api } from 'lwc';
import getMyPreviousClaims from '@salesforce/apex/HOT_ClaimController.getMyPreviousClaims';

export default class Hot_claimFormUser extends LightningElement {
    @track isPersonNumber = true;
    @track previousUsers = [];
    @track noPreviousUsers = false;
    @track isEdit = false;
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
    @api claim;
    @api isEdit;

    @track unmappedPreviousUsers;
    @track mappedPreviousUsers;

    wiredAllPreviousClaimsResult;
    noPreviousUsers = false;

    @wire(getMyPreviousClaims)
    wiredClaims(result) {
        if (result.data) {
            this.wiredAllPreviousClaimsResult = result.data;
            this.noPreviousUsers = this.wiredAllPreviousClaimsResult.length === 0;
            this.mappedPreviousUsers = this.wiredAllPreviousClaimsResult.map((x) => ({
                ...x,
                identification: this.personNumberOrPhoneNumber(x.UserPersonNumber__c, x.UserPhoneNumber__c),
                isPersonNumberIdentification: this.isPersonNumberIdentification(
                    x.UserPersonNumber__c,
                    x.UserPhoneNumber__c
                )
            }));
        }
    }
    isPersonNumberIdentification(personNumber, phoneNumber) {
        let result;
        if (personNumber) {
            result = true;
        } else {
            result = false;
        }
        return result;
    }
    personNumberOrPhoneNumber(personNumber, phoneNumber) {
        let result;
        if (personNumber) {
            result = 'Personnummer: ' + personNumber;
        } else {
            result = 'Telefonnummer: ' + phoneNumber;
        }
        return result;
    }
    insertPreviousUser(event) {
        const clickedButton = event.target;
        const claimElement = clickedButton.closest('[data-id]');

        if (claimElement) {
            const claimId = claimElement.getAttribute('data-id');
            this.mappedPreviousUsers.forEach((element) => {
                if (element.Id == claimId) {
                    console.log('fant');
                    console.log('er personnumer? ' + element.isPersonNumberIdentification);
                    if (element.isPersonNumberIdentification == true) {
                        this.componentValues.userPhoneNumberOrUserPersonNumberRadioButtons[0].checked = true;
                        this.componentValues.userPhoneNumberOrUserPersonNumberRadioButtons[1].checked = false;
                        this.fieldValues.UserPersonNumber__c = element.UserPersonNumber__c;
                        this.fieldValues.UserPhoneNumber__c = '';
                        this.fieldValues.UserName__c = element.UserName__c;
                        this.isPersonNumber = true;
                        this.template.querySelector('.details').classList.add('hidden');
                    } else {
                        this.componentValues.userPhoneNumberOrUserPersonNumberRadioButtons[0].checked = false;
                        this.componentValues.userPhoneNumberOrUserPersonNumberRadioButtons[1].checked = true;
                        this.fieldValues.UserPersonNumber__c = '';
                        this.fieldValues.UserPhoneNumber__c = element.UserPhoneNumber__c;
                        this.fieldValues.UserName__c = element.UserName__c;
                        this.isPersonNumber = false;
                        this.template.querySelector('.details').classList.add('hidden');
                    }
                }
            });
        }
    }

    handlePreviousUsersBtn() {
        this.template.querySelector('.details').classList.remove('hidden');
        this.template.querySelector('.details').focus();
    }
    closeModal() {
        this.template.querySelector('.details').classList.add('hidden');
    }

    handlePhoneNumberogPersonNumberRadioButtons(event) {
        this.componentValues.userPhoneNumberOrUserPersonNumberRadioButtons = event.detail;
        if (this.isEdit == false) {
            this.fieldValues.UserPhoneNumber__c = '';
            this.fieldValues.UserPersonNumber__c = '';
        }
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
        if (this.claim.Id != '' && this.isEdit == true) {
            this.isEdit = true;
            if (this.claim.createdFromIdent == true) {
                this.componentValues.userPhoneNumberOrUserPersonNumberRadioButtons[0].checked = true;
                this.componentValues.userPhoneNumberOrUserPersonNumberRadioButtons[1].checked = false;
            } else {
                this.componentValues.userPhoneNumberOrUserPersonNumberRadioButtons[0].checked = false;
                this.componentValues.userPhoneNumberOrUserPersonNumberRadioButtons[1].checked = true;
            }
            this.fieldValues.UserPersonNumber__c = this.claim.userPersonNumber;
            this.fieldValues.UserPhoneNumber__c = this.claim.userPhoneNumber;
            this.fieldValues.UserName__c = this.claim.userName;
        }
    }
}
