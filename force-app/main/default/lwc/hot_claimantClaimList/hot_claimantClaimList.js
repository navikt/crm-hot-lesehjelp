import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import getMyClaims from '@salesforce/apex/HOT_ClaimController.getMyClaims';
import cancelClaim from '@salesforce/apex/HOT_ClaimController.cancelClaim';
import getClaimLineItems from '@salesforce/apex/HOT_ClaimLineItemController.getClaimLineItems';
import icons from '@salesforce/resourceUrl/icons';
import { loadStyle } from 'lightning/platformResourceLoader';
import Index from '@salesforce/resourceUrl/index';

export default class Hot_claimantClaimList extends NavigationMixin(LightningElement) {
    warningicon = `${icons}/warningicon.svg`;
    @track accountHasNoPhoneNumber;
    @track showClaimlist = true;
    @track noClaims = true;
    @track noClaimLineItems = true;
    @track noFilterResults = false;
    breadcrumbs = [
        {
            label: 'Hjem',
            href: ''
        },
        {
            label: 'Mine krav',
            href: 'mine-krav'
        }
    ];

    @track unmappedClaimLineItems;
    @track claimLineItems;
    @track recordName;

    @track orgName;

    @track record;
    @track isCancelButtonDisabled = false;
    @track isEditButtonDisabled = false;
    renderedCallback() {
        refreshApex(this.wiredAllClaim);
        loadStyle(this, Index);
    }
    connectedCallback() {
        refreshApex(this.wiredAllClaim);
    }
    handleFilterBtn(event) {
        this.template.querySelectorAll('c-hot_filterbutton').forEach((button) => {
            if (button.value === event.detail) {
                button.setActive();
            } else {
                button.setInactive();
            }
        });
        if (event.detail === 'all') {
            this.claims = this.unmappedClaims.map((x) => ({
                ...x,
                created: this.formatDateTime(x.CreatedDate),
                madeBy: this.setMadeBy(x.OnEmployer__c),
                madeFor: this.setMadeFor(x.UserName__c, x.Account__r.FirstName),
                isYellowStatus: this.checkYellowStatus(x.ExternalStatus__c),
                isGreenStatus: this.checkGreenStatus(x.ExternalStatus__c),
                isRedStatus: this.checkRedStatus(x.ExternalStatus__c)
            }));
            this.noFilterResults = this.claims.length === 0 ? true : false;
            this.claims.sort((a, b) => {
                if (b.CreatedDate === a.CreatedDate) {
                    return 0;
                }
                return b.CreatedDate < a.CreatedDate ? -1 : 1;
            });
        }
        if (event.detail === 'inProgress') {
            this.claims = this.unmappedClaims
                .filter(
                    (claim) =>
                        claim.ExternalStatus__c === 'Innsendt' ||
                        claim.ExternalStatus__c === 'Godkjent av bruker' ||
                        claim.ExternalStatus__c === 'Godkjent av Nav' ||
                        claim.ExternalStatus__c === 'Sendt til utbetaling'
                )
                .map((claim) => ({
                    ...claim,
                    created: this.formatDateTime(claim.CreatedDate),
                    madeBy: this.setMadeBy(claim.OnEmployer__c),
                    madeFor: this.setMadeFor(claim.UserName__c, claim.Account__r.FirstName),
                    isYellowStatus: this.checkYellowStatus(claim.ExternalStatus__c),
                    isGreenStatus: this.checkGreenStatus(claim.ExternalStatus__c),
                    isRedStatus: this.checkRedStatus(claim.ExternalStatus__c)
                }));
            this.noFilterResults = this.claims.length === 0 ? true : false;
            this.claims.sort((a, b) => {
                if (b.CreatedDate === a.CreatedDate) {
                    return 0;
                }
                return b.CreatedDate < a.CreatedDate ? -1 : 1;
            });
        }
        if (event.detail === 'paidOut') {
            this.claims = this.unmappedClaims
                .filter((claim) => claim.ExternalStatus__c === 'Utbetalt')
                .map((claim) => ({
                    ...claim,
                    created: this.formatDateTime(claim.CreatedDate),
                    madeBy: this.setMadeBy(claim.OnEmployer__c),
                    madeFor: this.setMadeFor(claim.UserName__c, claim.Account__r.FirstName),
                    isYellowStatus: this.checkYellowStatus(claim.ExternalStatus__c),
                    isGreenStatus: this.checkGreenStatus(claim.ExternalStatus__c),
                    isRedStatus: this.checkRedStatus(claim.ExternalStatus__c)
                }));
            this.noFilterResults = this.claims.length === 0 ? true : false;
            this.claims.sort((a, b) => {
                if (b.CreatedDate === a.CreatedDate) {
                    return 0;
                }
                return b.CreatedDate < a.CreatedDate ? -1 : 1;
            });
        }
        if (event.detail === 'withdrawn') {
            this.claims = this.unmappedClaims
                .filter((claim) => claim.ExternalStatus__c === 'Tilbaketrukket')
                .map((claim) => ({
                    ...claim,
                    created: this.formatDateTime(claim.CreatedDate),
                    madeBy: this.setMadeBy(claim.OnEmployer__c),
                    madeFor: this.setMadeFor(claim.UserName__c, claim.Account__r.FirstName),
                    isYellowStatus: this.checkYellowStatus(claim.ExternalStatus__c),
                    isGreenStatus: this.checkGreenStatus(claim.ExternalStatus__c),
                    isRedStatus: this.checkRedStatus(claim.ExternalStatus__c)
                }));
            this.noFilterResults = this.claims.length === 0 ? true : false;
            this.claims.sort((a, b) => {
                if (b.CreatedDate === a.CreatedDate) {
                    return 0;
                }
                return b.CreatedDate < a.CreatedDate ? -1 : 1;
            });
        }
        if (event.detail === 'declined') {
            this.claims = this.unmappedClaims
                .filter(
                    (claim) =>
                        claim.ExternalStatus__c === 'Avvist av bruker' || claim.ExternalStatus__c === 'Avslått av Nav'
                )
                .map((claim) => ({
                    ...claim,
                    created: this.formatDateTime(claim.CreatedDate),
                    madeBy: this.setMadeBy(claim.OnEmployer__c),
                    madeFor: this.setMadeFor(claim.UserName__c, claim.Account__r.FirstName),
                    isYellowStatus: this.checkYellowStatus(claim.ExternalStatus__c),
                    isGreenStatus: this.checkGreenStatus(claim.ExternalStatus__c),
                    isRedStatus: this.checkRedStatus(claim.ExternalStatus__c)
                }));
            this.noFilterResults = this.claims.length === 0 ? true : false;
            this.claims.sort((a, b) => {
                if (b.CreatedDate === a.CreatedDate) {
                    return 0;
                }
                return b.CreatedDate < a.CreatedDate ? -1 : 1;
            });
        }
    }
    checkYellowStatus(status) {
        if (
            status === 'Innsendt' ||
            status === 'Godkjent av bruker' ||
            status === 'Godkjent av Nav' ||
            status === 'Sendt til utbetaling'
        ) {
            return true;
        }
        return false;
    }
    checkGreenStatus(status) {
        if (status === 'Utbetalt') {
            return true;
        }
        return false;
    }

    checkRedStatus(status) {
        if (status === 'Avslått av Nav' || status === 'Avvist av bruker' || status === 'Tilbaketrukket') {
            return true;
        }
        return false;
    }
    goToClaim(event) {
        const clickedButton = event.target;
        const claimElement = clickedButton.closest('[data-id]');

        if (claimElement) {
            const claimId = claimElement.getAttribute('data-id');
            getClaimLineItems({
                recordId: claimId
            })
                .then((result) => {
                    this.claims.forEach((element) => {
                        if (element.Id === claimId) {
                            this.record = element;
                            this.record.onEmployer = element.OnEmployer__c;
                            this.recordName = element.Name;
                            this.accountHasNoPhoneNumber = element.accountHasNoPhoneNumber;
                            if (
                                element.ApprovedByNAV__c === true ||
                                element.ExternalStatus__c === 'Tilbaketrukket' ||
                                element.Source__c === 'Manual'
                            ) {
                                this.isCancelButtonDisabled = true;
                                this.isEditButtonDisabled = true;
                            } else {
                                this.isCancelButtonDisabled = false;
                                this.isEditButtonDisabled = false;
                            }
                        }
                    });

                    this.unmappedClaimLineItems = [];
                    this.claimLineItems = [];
                    result.forEach((cli) => {
                        this.unmappedClaimLineItems.push(cli);
                    });
                    if (this.unmappedClaimLineItems.length !== 0) {
                        this.noClaimLineItems = false;
                    }
                    this.claimLineItems = this.unmappedClaimLineItems.map((x) => ({
                        ...x,
                        created: this.formatDateTime(x.CreatedDate),
                        period: this.formatDateTimePeriod(x.StartTime__c, x.EndTime__c),
                        hasTravelTo: this.yesOrNoCalculator(x.HasTravelTo__c),
                        hasTravelFrom: this.yesOrNoCalculator(x.HasTravelFrom__c),
                        travelToPeriode: this.formatDateTimePeriod(x.TravelToStartTime__c, x.TravelToEndTime__c),
                        travelFromPeriode: this.formatDateTimePeriod(x.TravelFromStartTime__c, x.TravelFromEndTime__c),
                        hasTravel: this.hasTravel(x.HasTravelTo__c, x.HasTravelFrom__c)
                    }));
                    const dialog = this.template.querySelector('dialog.details');
                    dialog.showModal();
                    dialog.focus();
                })
                .catch(() => {});
        }
    }
    closeModal() {
        const dialog = this.template.querySelector('dialog.details');
        dialog.close();
    }

    @track unmappedClaims;
    @track claims;

    wiredAllClaim;

    wiredClaimsResult;
    @wire(getMyClaims)
    wiredClaims(result) {
        this.wiredAllClaim = result;
        this.wiredClaimsResult = result.data;
        if (result.data) {
            if (this.wiredClaimsResult.length !== 0) {
                this.noClaims = false;
            }
            this.unmappedClaims = [];
            this.claims = [];
            result.data.forEach((element) => {
                this.unmappedClaims.push(element);
            });
            if (this.unmappedClaims.length !== 0) {
                this.noClaims = false;
            }

            this.claims = this.unmappedClaims.map((x) => ({
                ...x,
                created: this.formatDateTime(x.CreatedDate),
                madeBy: this.setMadeBy(x.OnEmployer__c),
                madeFor: this.setMadeFor(x.UserName__c, x.Account__r.FirstName),
                isYellowStatus: this.checkYellowStatus(x.ExternalStatus__c),
                isGreenStatus: this.checkGreenStatus(x.ExternalStatus__c),
                isRedStatus: this.checkRedStatus(x.ExternalStatus__c),
                accountHasNoPhoneNumber: this.checkAccountHasNoPhoneNumber(
                    x.Account__r.CRM_Person__r.INT_KrrMobilePhone__c
                )
            }));
            this.claims.sort((a, b) => new Date(b.CreatedDate) - new Date(a.CreatedDate));
        }
    }
    checkAccountHasNoPhoneNumber(accountPhoneNumber) {
        return !accountPhoneNumber;
    }
    setMadeBy(onEmployer) {
        return onEmployer ? 'Innsendt på vegne av arbeidsgiver' : 'Innsendt av deg';
    }

    setMadeFor(username, accountName) {
        if (username && username.trim() !== '') {
            return username;
        } else if (accountName && accountName.trim() !== '') {
            return accountName;
        }
        return 'Ukjent mottaker';
    }

    formatDateTime(date) {
        let unformatted = new Date(date);
        let formattedTime =
            ('0' + unformatted.getDate()).slice(-2) +
            '.' +
            ('0' + (unformatted.getMonth() + 1)).slice(-2) +
            '.' +
            unformatted.getFullYear() +
            ', Kl ' +
            ('0' + unformatted.getHours()).slice(-2) +
            ':' +
            ('0' + unformatted.getMinutes()).slice(-2);
        if (formattedTime.includes('NaN')) {
            formattedTime = '';
        }
        return formattedTime;
    }
    yesOrNoCalculator(bool) {
        return bool ? 'Ja' : 'Nei';
    }
    hasTravel(hasTravelTo, hasTravelFrom) {
        return hasTravelTo || hasTravelFrom;
    }
    formatDateTimePeriod(dateFrom, dateTo) {
        let unformattedFrom = new Date(dateFrom);
        let unformattedTo = new Date(dateTo);

        let formattedTime =
            ('0' + unformattedFrom.getDate()).slice(-2) +
            '.' +
            ('0' + (unformattedFrom.getMonth() + 1)).slice(-2) +
            '.' +
            unformattedFrom.getFullYear() +
            ', Kl ' +
            ('0' + unformattedFrom.getHours()).slice(-2) +
            ':' +
            ('0' + unformattedFrom.getMinutes()).slice(-2) +
            ' - ' +
            ('0' + unformattedTo.getHours()).slice(-2) +
            ':' +
            ('0' + unformattedTo.getMinutes()).slice(-2);
        if (formattedTime.includes('NaN')) {
            formattedTime = '';
        }
        return formattedTime;
    }
    isCancel = false;
    noCancelButton = true;
    modalHeader = 'Varsel';
    modalContent = 'Noe gikk galt';
    @track actionText = '';
    @track confirmButtonLabel = '';

    @track spin = false;
    @track submitSuccessMessage = '';

    cancelClaim() {
        this.confirmButtonLabel = 'Ja';
        this.modalContent = `Er du sikker på at du vil trekke kravet ${this.recordName}?`;
        this.noCancelButton = false;
        this.showModal();
    }
    editClaim() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'nytt-krav'
            },
            state: {
                fieldValues: JSON.stringify(this.record),
                edit: true
            }
        });
    }
    showModal() {
        this.template.querySelector('c-alertdialog').showModal();
    }
    handleAlertDialogClick(event) {
        if (event.detail === 'confirm' && this.confirmButtonLabel !== 'OK') {
            this.actionText = 'Trekker kravet';
            this.spin = true;
            this.hideFormAndShowLoading();
            this.isCancel = false;
            cancelClaim({
                recordId: this.record.Id
            })
                .then((result) => {
                    if (result === 'ok') {
                        this.submitSuccessMessage = 'Kravet ble tilbaketrukket.';
                        this.hideFormAndShowSuccess();
                    } else {
                        this.hideLoading();
                        this.hideFormAndShowError(result);
                    }
                    this.closeModal();
                })
                .catch((error) => {
                    this.hideFormAndShowError(error);
                });
        }
    }
    goBack() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'mine-krav'
            }
        });
    }
    //SCREENS

    hideFormAndShowLoading() {
        this.template.querySelector('.details').classList.add('hidden');
        this.template.querySelector('.main-content').classList.add('hidden');
        this.template.querySelector('.submitted-loading').classList.remove('hidden');
        this.template.querySelector('.h2-loadingMessage').focus();
        window.scrollTo(0, 0);
    }
    hideLoading() {
        this.template.querySelector('.submitted-loading').classList.add('hidden');
        window.scrollTo(0, 0);
    }
    hideFormAndShowSuccess() {
        this.template.querySelector('.submitted-loading').classList.add('hidden');
        this.template.querySelector('.submitted-false').classList.add('hidden');
        this.template.querySelector('.submitted-true').classList.remove('hidden');
        this.template.querySelector('.h2-successMessage').focus();
    }
    hideFormAndShowError(errorMessage) {
        this.template.querySelector('.details').classList.remove('hidden');
        this.template.querySelector('.details').focus();
        this.template.querySelector('.main-content').classList.remove('hidden');
        this.modalHeader = 'Noe gikk galt!';
        this.noCancelButton = true;
        this.confirmButtonLabel = 'OK';
        this.modalContent = errorMessage;
        this.showModal();
        this.spin = false;
    }
    handleKeyDown(event) {
        if (event.key === 'Escape') {
            this.closeModal();
        }
    }
}
