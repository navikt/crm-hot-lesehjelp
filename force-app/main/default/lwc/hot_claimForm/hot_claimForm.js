import { LightningElement, api, track } from 'lwc';

export default class Hot_claimForm extends LightningElement {
    @api parentFieldValues;
    @api claimType;
    @api parentClaimComponentValues;
    @track isWorkClaimType = false;

    @track employerClaim;
    @track requestIds = '';

    @track fieldValues = {
        OnEmployer__c: '',
        EmployerNumber__c: '',
        EmployerExpensesPerHour__c: '',
        EmployerName__c: ''
    };
    @track componentValues = {
        onEmployerRadioButtons: [
            { label: 'Ja', value: 'true' },
            { label: 'Nei', value: 'false', checked: true }
        ],
        isOptionalFields: false
    };
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
        const selectedValue = this.componentValues.onEmployerRadioButtons.find((option) => option.checked);
        if (selectedValue.value === 'true') {
            this.employerClaim = true;
        } else {
            this.employerClaim = false;
        }

        if (this.claimType == 'Arbeid') {
            this.isWorkClaimType = true;
        } else {
            this.isWorkClaimType = false;
        }
    }

    handleOnEmployerRadioButtons(event) {
        this.componentValues.onEmployerRadioButtons = event.detail;
        if (event.detail[0].checked) {
            this.employerClaim = true;
        } else {
            this.employerClaim = false;
        }
    }
    @api getComponentValues() {
        return this.componentValues;
    }
    @api
    setFieldValues() {
        this.template.querySelectorAll('c-input').forEach((element) => {
            this.fieldValues[element.name] = element.getValue();
        });
    }
    @api
    getFieldValues() {
        return this.fieldValues;
    }
    @api
    getTimeInput() {
        return this.template.querySelector('c-hot_claim-line-time-input').getTimeInput();
    }
}
