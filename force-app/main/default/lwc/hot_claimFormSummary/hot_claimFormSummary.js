import { LightningElement, api } from 'lwc';

export default class Hot_claimFormSummary extends LightningElement {
    @api parentClaimComponentValues;
    @api parentFieldValues;

    timeInputValues = [];
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

    _timeInput;
    @api
    set timeInput(value) {
        this._timeInput = value;
        if (value && Array.isArray(value) && value.length > 0) {
            this.handleFieldValueChange();
        }
    }
    get timeInput() {
        return this._timeInput;
    }


    connectedCallback() {
        const isParentFieldValuesEmpty = !this.parentFieldValues || Object.keys(this.parentFieldValues).length === 0;
        const isTimeInputEmpty = !Array.isArray(this.timeInput) || this.timeInput.length === 0;

        if (isParentFieldValuesEmpty || isTimeInputEmpty) {
            return;
        }

        this.handleFieldValueChange();
    }


    handleFieldValueChange() {

        // User info
        this.fieldValues.userName = this.parentFieldValues.UserName__c;
        this.fieldValues.userPersonNumber = this.parentFieldValues.UserPersonNumber__c;
        this.fieldValues.userPhoneNumber = this.parentFieldValues.UserPhoneNumber__c;

        // Claim type
        this.fieldValues.claimType = this.parentFieldValues.ClaimType__c;

        // Employer info
        this.fieldValues.employerName = this.parentFieldValues.EmployerName__c;
        this.fieldValues.organizationNumber = this.parentFieldValues.EmployerNumber__c;
        this.fieldValues.employerExpensesPerHour = this.parentFieldValues.EmployerExpensesPerHour__c;
        this.checkClaimTypeForWork();

        // Time input / Date info
        if (Array.isArray(this.timeInput)) {
            this.timeInputValues = this.timeInput.map(item => ({
                ...item
            }));

            this.timeInputValues.forEach(item => {
                item.hasTravelTo = item.hasTravelTo === true;
                item.hasTravelFrom = item.hasTravelFrom === true;
            });
        }

        this.formatTimeInputDates();
        this.addWeekdayToTimeInputValues();
    }

    checkClaimTypeForWork() {
        if (this.fieldValues.claimType === 'Arbeidsliv' && this.parentFieldValues.OnEmployer__c === 'true') {
            this.isClaimTypeWork = true;
        }
    }

    formatTimeInputDates() {
        if (!Array.isArray(this.timeInputValues)) return;

        this.timeInputValues = this.timeInputValues.map(item => {
            if (item.date) {
                const [year, month, day] = item.date.split('-');
                item.date = `${day}.${month}.${year}`;
            }

            if (item.dateTravelTo) {
                const [yearT, monthT, dayT] = item.dateTravelTo.split('-');
                item.dateTravelTo = `${dayT}.${monthT}.${yearT}`;
            }
            if (item.dateTravelFrom) {
                const [yearF, monthF, dayF] = item.dateTravelFrom.split('-');
                item.dateTravelFrom = `${dayF}.${monthF}.${yearF}`;
            }

            return item;
        });
    }


    addWeekdayToTimeInputValues() {
        if (!Array.isArray(this.timeInputValues)) return;

        this.timeInputValues = this.timeInputValues.map(item => {
            if (item.date) {
                const [day, month, year] = item.date.split('.');
                const dateObj = new Date(`${year}-${month}-${day}`);
                let weekday = dateObj.toLocaleDateString('no-NO', { weekday: 'long' });

                item.weekday = weekday.charAt(0).toUpperCase() + weekday.slice(1);
            } else {
                item.weekday = null;
            }
            return item;
        });
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

}