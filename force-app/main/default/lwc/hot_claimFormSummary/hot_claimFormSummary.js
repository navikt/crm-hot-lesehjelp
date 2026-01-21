import { LightningElement, api } from 'lwc';

export default class Hot_claimFormSummary extends LightningElement {
    @api parentFieldValues;
    @api parentClaimComponentValues;
    @api timeInput; 
    @api claim;
    @api isLos;
    
    timeInputValues = [];
    currentDate; 
    isClaimTypeWork = false;

    fieldValues = {
        userName: '',
        userPersonNumber: '', 
        userPhoneNumber: '', 
        claimType: '',
        employerName: '',
        organizationNumber: '', 
        employerExpensesPerHour: ''
    }


    connectedCallback() { 
        this.handleFieldValueChange();
    }

    handleFieldValueChange() {
        
        console.log('field values username ' + this.parentFieldValues.UserName__c); 
        // User info
        this.fieldValues.userName = this.parentFieldValues.UserName__c;
        this.fieldValues.userPersonNumber = this.parentFieldValues.UserPersonNumber__c;
        this.fieldValues.userPhoneNumber = this.parentFieldValues.UserPhoneNumber__c; 

        // Claim info
        this.fieldValues.claimType = this.parentFieldValues.ClaimType__c; 
        console.log('claim type ' + this.fieldValues.claimType);
        console.log('phone number ' + this.fieldValues.userPhoneNumber);
        
        // Employer info
        this.fieldValues.employerName = this.parentFieldValues.EmployerName__c;
        this.fieldValues.organizationNumber = this.parentFieldValues.EmployerNumber__c;
        console.log('organization number ' + this.parentFieldValues.EmployerNumber__c);
        this.fieldValues.employerExpensesPerHour = this.parentFieldValues.EmployerExpensesPerHour__c;
        this.checkClaimTypeForWork();
        console.log('isClaimTypeWork: ' + this.isClaimTypeWork);
        console.log('employer checkbox' + this.parentFieldValues.OnEmployer__c);
        console.log('ClaimType value:', this.parentFieldValues.ClaimType__c, 'Type:', typeof this.parentFieldValues.ClaimType__c);
        console.log('OnEmployer__c value:', this.parentFieldValues.OnEmployer__c, 'Type:', typeof this.parentFieldValues.OnEmployer__c);


        // Date info
        if (Array.isArray(this.timeInput)) {
            this.timeInputValues = this.timeInput.map(item => ({ ...item }));
        }
        console.log('timeInputValues: ' + this.timeInputValues[0].date);
        console.log('timeInputValues:', JSON.stringify(this.timeInputValues));
        this.currentDate = this.getTodayFormatted();
        console.log('Today is:', this.currentDate);

    }

    getTodayFormatted() {
        const today = new Date();

        const day = String(today.getDate()).padStart(2, '0');
        const month = String(today.getMonth() + 1).padStart(2, '0');
        const year = today.getFullYear();

        return `${day}.${month}.${year}`;
    }

    checkClaimTypeForWork() {
        if(this.fieldValues.claimType === 'Arbeidsliv' && this.parentFieldValues.OnEmployer__c === 'true') {
            this.isClaimTypeWork = true;
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
}