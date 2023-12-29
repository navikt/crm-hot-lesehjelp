import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import createNewClaimFromCommunity from '@salesforce/apex/HOT_ClaimController.createNewClaimFromCommunity';
import checkIsLos from '@salesforce/apex/HOT_UserInfoController.checkIsLos';

export default class Hot_claimFormWrapper extends NavigationMixin(LightningElement) {
    @track claimTypeChosen = false;
    @track fieldValues = {};
    @track componentValues = {};
    @track recordId = null;
    @track spin = false;
    @track isLos = true;
    @track previousPage = 'home';
    @track claimTypeResult = {};
    @track currentPage = '';
    @track submitSuccessMessage = '';

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
    wiredResult;
    @wire(checkIsLos)
    wiredResult(result) {
        this.isLos = result.data;
    }

    handleRequestType(event) {
        this.claimTypeResult = event.detail;
        this.claimTypeChosen = true;
        this.fieldValues.ClaimType__c = this.claimTypeResult.type;
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

        if (this.handleValidation()) {
            return;
        } else {
            this.currentPage = 'claimForm';
            this.claimTypeResult.claimForm = true;
        }
    }
    handleSendButtonClicked() {
        this.getComponentValues();
        this.getFieldValuesFromSubForms();
        this.spin = true;
        this.template.querySelector('[data-id="saveButton"]').disabled = true;

        this.hideFormAndShowLoading();
        this.submitForm();
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

    modalHeader = '';
    modalContent = '';
    noCancelButton = true;

    hideLoading() {
        this.template.querySelector('.submitted-loading').classList.add('hidden');
        window.scrollTo(0, 0);
    }

    hideFormAndShowLoading() {
        this.template.querySelector('.submitted-false').classList.add('hidden');
        this.template.querySelector('.submitted-loading').classList.remove('hidden');
        this.template.querySelector('.h2-loadingMessage').focus();
        window.scrollTo(0, 0);
    }
    hideFormAndShowSuccess() {
        this.template.querySelector('.submitted-loading').classList.add('hidden');
        this.template.querySelector('.submitted-false').classList.add('hidden');
        this.template.querySelector('.submitted-true').classList.remove('hidden');
        this.template.querySelector('.h2-successMessage').focus();
    }
    hideFormAndShowError(errorMessage) {
        this.template.querySelector('[data-id="saveButton"]').disabled = false;
        this.modalHeader = 'Noe gikk galt!';
        this.noCancelButton = true;
        if (errorMessage == 'no account') {
            this.modalContent = 'Kunne ikke finne person basert på informasjonen du skrev inn.';
        } else if (errorMessage == 'no organization') {
            this.modalContent = 'Kunne ikke finne arbeidsgiver basert på informasjonen du skrev inn.';
        } else {
            this.modalContent = errorMessage;
        }

        this.template.querySelector('c-alertdialog').showModal();
        this.spin = false;
    }
    handleAlertDialogClick() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'home'
            }
        });
    }

    submitForm() {
        let timeInput = this.template.querySelector('c-hot_claim-form').getTimeInput();
        // FOR DEBUGGING. HENTER UT ALLE FELTENE
        console.log('Antall kravlinjer:' + timeInput.length);
        console.log('Type: ' + this.fieldValues.ClaimType__c);
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
            console.log('Starttidspunkt: ' + timeInput[i].startTime);
            console.log('Slutttidspunkt: ' + timeInput[i].endTimeString);
            console.log('Oppgave: ' + timeInput[i].task);
            console.log('Har Tillegginformasjon: ' + timeInput[i].hasAdditionalInformation);
            console.log('Tillegginformasjon: ' + timeInput[i].additionalInformation);
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
        if (
            selectedValueOnEmployer.value == 'false' ||
            selectedValueOnEmployer.value == 'null' ||
            selectedValueOnEmployer.value == null
        ) {
            this.fieldValues.OnEmployer__c = 'false';
        } else {
            this.fieldValues.OnEmployer__c = selectedValueOnEmployer;
        }

        const claimLineItems = timeInput.map((item) => {
            return { ...item };
        });

        try {
            createNewClaimFromCommunity({
                userName: this.fieldValues.UserName__c,
                userPersonNumber: this.fieldValues.UserPersonNumber__c,
                userPhoneNumber: this.fieldValues.UserPhoneNumber__c,
                claimType: this.fieldValues.ClaimType__c,
                onEmployer: selectedValueOnEmployer.value,
                employerName: this.fieldValues.EmployerName__c,
                organizationNumber: this.fieldValues.EmployerNumber__c,
                employerExpensesPerHour: this.fieldValues.EmployerExpensesPerHour__c,
                claimLineItems: claimLineItems
            }).then((result) => {
                if (result == 'ok') {
                    this.submitSuccessMessage = 'Kravet ditt ble sendt inn';
                    this.hideFormAndShowSuccess();
                } else {
                    this.hideLoading();
                    this.hideFormAndShowError(result);
                }
            });
        } catch (error) {
            this.hideFormAndShowError(error);
        }
    }
    signingClaim() {}

    goToMyClaims() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'mine-krav'
            }
        });
    }
}
