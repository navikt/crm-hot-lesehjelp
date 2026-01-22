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

        // User info
        this.fieldValues.userName = this.parentFieldValues.UserName__c;
        this.fieldValues.userPersonNumber = this.parentFieldValues.UserPersonNumber__c;
        this.fieldValues.userPhoneNumber = this.parentFieldValues.UserPhoneNumber__c;

        // Claim info
        this.fieldValues.claimType = this.parentFieldValues.ClaimType__c;

        // Employer info
        this.fieldValues.employerName = this.parentFieldValues.EmployerName__c;
        this.fieldValues.organizationNumber = this.parentFieldValues.EmployerNumber__c;
        this.fieldValues.employerExpensesPerHour = this.parentFieldValues.EmployerExpensesPerHour__c;
        this.checkClaimTypeForWork();

        // Time input / Date info
        if (Array.isArray(this.timeInput)) {
            this.timeInputValues = this.timeInput.map(item => ({ ...item }));

            this.timeInputValues.forEach(item => {
                item.hasTravelTo = item.hasTravelTo === true;
                item.hasTravelFrom = item.hasTravelFrom === true;
            });
        }

        this.formatTimeInputDates();

        this.addWeekdayToTimeInputValues();

        console.log('timeInputValues: ' + this.timeInputValues[0].date);
        console.log('hasTravelTo: ' + this.timeInputValues[0].hasTravelTo);
        console.log('hasTravelFrom: ' + this.timeInputValues[0].hasTravelFrom);

        console.log('timeInputValues:', JSON.stringify(this.timeInputValues));
        this.currentDate = this.getTodayFormatted();
    }

    getTodayFormatted() {
        const today = new Date();

        const day = String(today.getDate()).padStart(2, '0');
        const month = String(today.getMonth() + 1).padStart(2, '0');
        const year = today.getFullYear();

        return `${day}.${month}.${year}`;
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
        console.log('Formatted timeInputValues:', JSON.stringify(this.timeInputValues));
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

        console.log('timeInputValues weekday: ', this.timeInputValues);
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