import { LightningElement, api, track } from 'lwc';
import getOrganizationInfo from '@salesforce/apex/HOT_ClaimController.getOrganizationInfo';
import icons from '@salesforce/resourceUrl/icons';

export default class Hot_claimForm extends LightningElement {
    warningicon = icons + '/warningicon.svg';

    @api parentFieldValues;
    @api claimType;
    @api isLos;
    @api claim;
    @api isEdit;
    @track showNewLos = false;
    @api parentClaimComponentValues;
    @track isWorkClaimType = false;
    @track disabledEmployer = false;

    @track employerClaim;

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
        if (this.claim.Id != '' && this.isEdit == true) {
            if (this.claim.onEmployer == true) {
                this.componentValues.onEmployerRadioButtons[0].checked = true;
                this.componentValues.onEmployerRadioButtons[1].checked = false;
                if (this.claimType == 'Arbeidsliv') {
                    this.isWorkClaimType = true;
                } else {
                    this.isWorkClaimType = false;
                }
                this.employerClaim = true;
                this.disabledEmployer = true;
                this.fieldValues.EmployerName__c = this.claim.employerName;
                this.fieldValues.EmployerNumber__c = this.claim.organizationNumber;
                this.fieldValues.EmployerExpensesPerHour__c = this.claim.employerExpensesPerHour;
            }
            //Skal ikke kunne redigere annet enn utgifter når det er arbeid. Skal ikke legge til arbeisgiver under redigering. Må lage nytt krav
            // if (this.claimType == 'Arbeidsliv') {
            //     this.isWorkClaimType = true;
            // } else {
            //     this.isWorkClaimType = false;
            // }
        } else {
            if (this.isLos == false && this.employerClaim != true) {
                this.showNewLos = true;
            }
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
                if (this.isLos == false) {
                    this.showNewLos = false;
                }
            } else {
                this.employerClaim = false;
                if (this.isLos == false) {
                    this.showNewLos = true;
                }
            }

            if (this.claimType == 'Arbeidsliv') {
                this.isWorkClaimType = true;
            } else {
                this.isWorkClaimType = false;
            }
        }
    }
    @track organizationNumberSearch;
    handleOrgInput(event) {
        this.organizationNumberSearch = event.detail;
        if (this.organizationNumberSearch.length == 9) {
            this.fieldValues.EmployerName__c = 'Henter organisasjon...';
            try {
                getOrganizationInfo({
                    organizationNumber: this.organizationNumberSearch
                }).then((result) => {
                    if (result.length == 1) {
                        this.fieldValues.EmployerName__c = result[0].Name;
                    } else {
                        this.fieldValues.EmployerName__c = 'Kunne ikke finne organisasjon';
                    }
                });
            } catch (error) {
                this.fieldValues.EmployerName__c = error;
            }
        } else {
            this.fieldValues.EmployerName__c = '';
        }
    }

    handleOnEmployerRadioButtons(event) {
        this.componentValues.onEmployerRadioButtons = event.detail;
        if (event.detail[0].checked) {
            this.employerClaim = true;
            if (this.isLos == false) {
                this.showNewLos = false;
            }
        } else {
            this.employerClaim = false;
            if (this.isLos == false) {
                this.showNewLos = true;
            }
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
    @api
    getNewLOSInput() {
        return this.template.querySelector('c-hot_new-l-o-s-form').getNewLOSInput();
    }
    @api
    validateFields() {
        let hasErrors = false;
        hasErrors += this.validateOrgName();
        hasErrors += this.validateOrgExpenses();
        hasErrors += this.template.querySelector('c-hot_claim-line-time-input').validateFields();
        return hasErrors;
    }
    validateOrgName() {
        let hasErrors = false;
        this.template.querySelectorAll('[data-id="orgName"]').forEach((element) => {
            if (element.value === '' || element.value === 'Kunne ikke finne organisasjon') {
                hasErrors = true;
                this.showErrorOrgNumber();
            }
        });
        return hasErrors;
    }
    validateOrgExpenses() {
        let hasErrors = false;
        this.template.querySelectorAll('[data-id="orgExpenses"]').forEach((element) => {
            if (element.value === '') {
                element.sendErrorMessage('Utgifter må fylles ut');
                hasErrors = true;
            }
        });
        return hasErrors;
    }
    showErrorOrgNumber() {
        let hasErrors = false;
        this.template.querySelectorAll('[data-id="orgNumber"]').forEach((element) => {
            element.sendErrorMessage('Må ha en organisasjons om finnes');
        });
        return hasErrors;
    }
}
