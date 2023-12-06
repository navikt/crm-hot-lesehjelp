import { LightningElement, track } from 'lwc';

export default class Hot_claimFormWrapper extends LightningElement {
    @track claimTypeChosen = false;
    @track fieldValues = {};
    @track componentValues = {};
    @track recordId = null;
    @track spin = false;
    @track isLos = true;
    @track previousPage = 'home';
    @track claimTypeResult = {};
    @track currentPage = '';

    breadcrumbs = [
        {
            label: 'Lesehjelp',
            href: ''
        },
        {
            label: 'Nytt krav',
            href: 'nytt-krav'
        }
    ];

    handleRequestType(event) {
        this.claimTypeResult = event.detail;
        this.claimTypeChosen = true;
        this.fieldValues.Type__c = this.claimTypeResult.type;
        this.currentPage = 'userInfo';
    }
    handleBackButtonClicked() {
        this.getComponentValues();
        this.getFieldValuesFromSubForms();
        if (this.currentPage === 'userInfo') {
            this.claimTypeChosen = false;
        } else {
            this.claimTypeResult.claimForm = false;
            this.currentPage = 'userInfo';
        }
        for (let f in this.fieldValues) {
            console.log(this.fieldValues[f]);
        }
    }
    handleNextButtonClicked() {
        this.getComponentValues();
        this.getFieldValuesFromSubForms();
        this.currentPage = 'claimForm';
        this.claimTypeResult.claimForm = true;
        if (this.handleValidation()) {
            return;
        }
    }
    handleSendButtonClicked() {
        let timeInput = this.template.querySelector('c-hot_claim-form').getTimeInput();
        console.log('timeInput: ' + timeInput[0].startTimeString);
        console.log('timeInput: ' + timeInput[0].task);
        console.log('timeInput: ' + timeInput[1].task);
    }

    handleValidation() {
        let hasErrors = false;
        this.template.querySelectorAll('.subform').forEach((subForm) => {
            hasErrors += subForm.validateFields();
            console.log('feil' + hasErrors);
        });
        return hasErrors;
    }

    getFieldValuesFromSubForms() {
        this.template.querySelectorAll('.subform').forEach((subForm) => {
            subForm.setFieldValues();
            this.setFieldValuesInWrapper(subForm.getFieldValues());
        });
    }
    setFieldValuesInWrapper(fields) {
        for (let k in fields) {
            this.fieldValues[k] = fields[k];
        }
    }
    setComponentValuesInWrapper(fields) {
        for (let k in fields) {
            this.componentValues[k] = fields[k];
        }
    }

    getComponentValues() {
        let reqForm = this.template.querySelector('c-hot_claim-form');
        if (reqForm !== null) {
            this.setComponentValuesInWrapper(reqForm.getComponentValues());
        }
        let reqFormUser = this.template.querySelector('c-hot_claim-form-user');
        if (reqFormUser !== null) {
            this.setComponentValuesInWrapper(reqFormUser.getComponentValues());
        }
    }
    async handleSubmit(event) {
        this.getComponentValues();
        this.getFieldValuesFromSubForms();
        event.preventDefault();
        console.log('submitter');
        this.spin = true;
        // this.getFieldValuesFromSubForms();
        // let status = 'Åpen';
        // if (this.isEditOrCopyMode) {
        //     this.deleteMarkedFiles();
        //     status = await getRequestStatus({ recordId: this.recordId });
        //     if (status !== null && status !== 'Åpen') {
        //         this.showModalOnEditNotAllowed();
        //     }
        // }
        // let hasErrors = this.handleValidation();
        // if (!hasErrors && (status === 'Åpen' || status === null)) {
        this.template.querySelector('[data-id="saveButton"]').disabled = true;
        //     this.promptOverlap().then((overlapOk) => {
        //         if (overlapOk) {
        this.hideFormAndShowLoading();
        this.submitForm();
        //             this.submitForm();
        //         } else {
        //             this.spin = false;
        //         }
        //     });
        // } else {
        //     this.spin = false;
        // }
    }
    handleSuccess() {
        console.log('sucess');
    }
    handleError() {
        console.log('error');
    }
    hideFormAndShowLoading() {
        this.template.querySelector('.submitted-false').classList.add('hidden');
        this.template.querySelector('.submitted-loading').classList.remove('hidden');
        this.template.querySelector('.h2-loadingMessage').focus();
        window.scrollTo(0, 0);
    }

    submitForm() {
        let timeInput = this.template.querySelector('c-hot_claim-form').getTimeInput();
        // FOR DEBUGGING. HENTER UT ALLE FELTENE
        console.log('Antall kravlinjer:' + timeInput.length);
        console.log('Type: ' + this.fieldValues.Type__c);
        console.log('Brukers navn: ' + this.fieldValues.UserName__c);
        const selectedValue = this.componentValues.userPhoneNumberOrUserPersonNumberRadioButtons.find(
            (option) => option.checked
        );
        console.log('Personnummer eller telefonnummer: ' + selectedValue.value);
        console.log('Brukers personnummer: ' + this.fieldValues.UserPersonNumber__c);
        console.log('Brukers telefonnummer: ' + this.fieldValues.UserPhoneNumber__c);
        const selectedValueOnEmployer = this.componentValues.onEmployerRadioButtons.find((option) => option.checked);
        console.log('Sender kravet på vegne av arbeidsgiver?' + selectedValueOnEmployer.value);
        console.log('Arbeidsgiver snavn: ' + this.fieldValues.EmployerName__c);
        console.log('Organisasjonsummer: ' + this.fieldValues.EmployerNumber__c);
        console.log('Organisasjon utgifter per time: ' + this.fieldValues.EmployerExpensesPerHour__c);

        for (let i = 0; i < timeInput.length; i++) {
            console.log('Id/Nr: ' + timeInput[i].Id);
            console.log('Dato: ' + timeInput[i].date);
            console.log('Starttidspunkt: ' + timeInput[i].startTimeString);
            console.log('Slutttidspunkt: ' + timeInput[i].endTimeString);
            console.log('Oppgave: ' + timeInput[i].task);
            console.log('Reisetid til oppdrag?: ' + timeInput[i].hasTravelTo);
            console.log('Reisetid til oppdrag dato: ' + timeInput[i].dateTravelTo);
            console.log('Reisetid til oppdrag fra klokkeslett: ' + timeInput[i].startTimeTravelToString);
            console.log('Reisetid til oppdrag til klokkeslett: ' + timeInput[i].endTimeTravelToString);
            console.log('</br>');
            console.log('Reisetid fra oppdrag?: ' + timeInput[i].hasTravelFrom);
            console.log('Reisetid fra oppdrag dato: ' + timeInput[i].dateTravelFrom);
            console.log('Reisetid fra oppdrag fra klokkeslett: ' + timeInput[i].startTimeTravelFromString);
            console.log('Reisetid fra oppdrag til klokkeslett: ' + timeInput[i].endTimeTravelFromString);
            console.log('-------------------------------------------------');
        }
        //console.log(this.componentValues);
        // test.Status__c = 'Sent';
        // console.log(this.test.Status__c);
        // this.template.querySelector('lightning-record-edit-form').submit(this.test);
    }
    signingClaim() {}
}
