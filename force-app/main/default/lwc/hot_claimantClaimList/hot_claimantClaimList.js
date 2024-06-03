import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import getMyClaims from '@salesforce/apex/HOT_ClaimController.getMyClaims';
import cancelClaim from '@salesforce/apex/HOT_ClaimController.cancelClaim';
import getClaimLineItems from '@salesforce/apex/HOT_ClaimLineItemController.getClaimLineItems';

export default class Hot_claimantClaimList extends NavigationMixin(LightningElement) {
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
    }
    connectedCallback() {
        refreshApex(this.wiredAllClaim);
    }
    handleFilterBtn(event) {
        this.template.querySelectorAll('c-hot_filterbutton').forEach((button) => {
            if (button.value == event.detail) {
                button.setActive();
            } else {
                button.setInactive();
            }
        });
        if (event.detail == 'all') {
            this.claims = this.unmappedClaims.map((x) => ({
                ...x,
                created: this.formatDateTime(x.CreatedDate),
                madeBy: this.setMadeBy(x.OnEmployer__c),
                isYellowStatus: this.checkYellowStatus(x.ExternalStatus__c),
                isGreenStatus: this.checkGreenStatus(x.ExternalStatus__c),
                isRedStatus: this.checkRedStatus(x.ExternalStatus__c)
            }));
            this.noFilterResults = this.claims.length == 0 ? true : false;
            this.claims.sort((a, b) => {
                if (b.CreatedDate === a.CreatedDate) {
                    return 0;
                } else {
                    return b.CreatedDate < a.CreatedDate ? -1 : 1;
                }
            });
        }
        if (event.detail == 'inProgress') {
            this.claims = this.unmappedClaims
                .filter(
                    (claim) =>
                        claim.ExternalStatus__c === 'Innsendt' ||
                        claim.ExternalStatus__c === 'Godkjent av bruker' ||
                        claim.ExternalStatus__c === 'Godkjent av NAV' ||
                        claim.ExternalStatus__c === 'Sendt til utbetaling'
                )
                .map((claim) => ({
                    ...claim,
                    created: this.formatDateTime(claim.CreatedDate),
                    madeBy: this.setMadeBy(claim.OnEmployer__c),
                    isYellowStatus: this.checkYellowStatus(claim.ExternalStatus__c),
                    isGreenStatus: this.checkGreenStatus(claim.ExternalStatus__c),
                    isRedStatus: this.checkRedStatus(claim.ExternalStatus__c)
                }));
            this.noFilterResults = this.claims.length == 0 ? true : false;
            this.claims.sort((a, b) => {
                if (b.CreatedDate === a.CreatedDate) {
                    return 0;
                } else {
                    return b.CreatedDate < a.CreatedDate ? -1 : 1;
                }
            });
        }
        if (event.detail == 'paidOut') {
            this.claims = this.unmappedClaims
                .filter((claim) => claim.ExternalStatus__c === 'Utbetalt')
                .map((claim) => ({
                    ...claim,
                    created: this.formatDateTime(claim.CreatedDate),
                    madeBy: this.setMadeBy(claim.OnEmployer__c),
                    isYellowStatus: this.checkYellowStatus(claim.ExternalStatus__c),
                    isGreenStatus: this.checkGreenStatus(claim.ExternalStatus__c),
                    isRedStatus: this.checkRedStatus(claim.ExternalStatus__c)
                }));
            this.noFilterResults = this.claims.length == 0 ? true : false;
            this.claims.sort((a, b) => {
                if (b.CreatedDate === a.CreatedDate) {
                    return 0;
                } else {
                    return b.CreatedDate < a.CreatedDate ? -1 : 1;
                }
            });
        }
        if (event.detail == 'withdrawn') {
            this.claims = this.unmappedClaims
                .filter((claim) => claim.ExternalStatus__c === 'Tilbaketrukket')
                .map((claim) => ({
                    ...claim,
                    created: this.formatDateTime(claim.CreatedDate),
                    madeBy: this.setMadeBy(claim.OnEmployer__c),
                    isYellowStatus: this.checkYellowStatus(claim.ExternalStatus__c),
                    isGreenStatus: this.checkGreenStatus(claim.ExternalStatus__c),
                    isRedStatus: this.checkRedStatus(claim.ExternalStatus__c)
                }));
            this.noFilterResults = this.claims.length == 0 ? true : false;
            this.claims.sort((a, b) => {
                if (b.CreatedDate === a.CreatedDate) {
                    return 0;
                } else {
                    return b.CreatedDate < a.CreatedDate ? -1 : 1;
                }
            });
        }
        if (event.detail == 'declined') {
            this.claims = this.unmappedClaims
                .filter(
                    (claim) =>
                        claim.ExternalStatus__c === 'Avvist av bruker' || claim.ExternalStatus__c === 'Avslått av NAV'
                )
                .map((claim) => ({
                    ...claim,
                    created: this.formatDateTime(claim.CreatedDate),
                    madeBy: this.setMadeBy(claim.OnEmployer__c),
                    isYellowStatus: this.checkYellowStatus(claim.ExternalStatus__c),
                    isGreenStatus: this.checkGreenStatus(claim.ExternalStatus__c),
                    isRedStatus: this.checkRedStatus(claim.ExternalStatus__c)
                }));
            this.noFilterResults = this.claims.length == 0 ? true : false;
            this.claims.sort((a, b) => {
                if (b.CreatedDate === a.CreatedDate) {
                    return 0;
                } else {
                    return b.CreatedDate < a.CreatedDate ? -1 : 1;
                }
            });
        }
    }
    checkYellowStatus(status) {
        if (
            status == 'Innsendt' ||
            status == 'Godkjent av bruker' ||
            status == 'Godkjent av NAV' ||
            status == 'Sendt til utbetaling'
        ) {
            return true;
        } else {
            return false;
        }
    }
    checkGreenStatus(status) {
        if (status == 'Utbetalt') {
            return true;
        } else {
            return false;
        }
    }
    checkRedStatus(status) {
        if (status == 'Avslått av NAV' || status == 'Avvist av bruker' || status == 'Tilbaketrukket') {
            return true;
        } else {
            return false;
        }
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
                        if (element.Id == claimId) {
                            this.record = element;
                            this.record.onEmployer = element.OnEmployer__c;
                            this.recordName = element.Name;
                            if (element.ExternalStatus__c) {
                            }
                            if (element.ApprovedByNAV__c == true || element.ExternalStatus__c == 'Tilbaketrukket') {
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
                    if (this.unmappedClaimLineItems.length != 0) {
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
                .catch((error) => {});
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
            if (this.wiredClaimsResult.length != 0) {
                this.noClaims = false;
            }
            this.unmappedClaims = [];
            this.claims = [];
            result.data.forEach((element) => {
                this.unmappedClaims.push(element);
            });
            if (this.unmappedClaims.length != 0) {
                this.noClaims = false;
            }

            this.claims = this.unmappedClaims.map((x) => ({
                ...x,
                created: this.formatDateTime(x.CreatedDate),
                madeBy: this.setMadeBy(x.OnEmployer__c),
                isYellowStatus: this.checkYellowStatus(x.ExternalStatus__c),
                isGreenStatus: this.checkGreenStatus(x.ExternalStatus__c),
                isRedStatus: this.checkRedStatus(x.ExternalStatus__c)
            }));
            this.claims.sort((a, b) => {
                if (b.CreatedDate === a.CreatedDate) {
                    return 0;
                } else {
                    return b.CreatedDate < a.CreatedDate ? -1 : 1;
                }
            });
        }
    }
    setMadeBy(onEmployer) {
        if (onEmployer == true) {
            return 'Innsendt på vegne av arbeidsgiver';
        } else {
            return 'Innsendt av deg';
        }
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
    yesOrNoCalculator(string) {
        if (string == true) {
            return 'Ja';
        } else {
            return 'Nei';
        }
    }
    hasTravel(hasTravelTo, hasTravelFrom) {
        if (hasTravelTo || hasTravelFrom) {
            return true;
        } else {
            return false;
        }
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
        this.modalContent = 'Er du sikker på at du vil trekke kravet ' + this.recordName + '?';
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
        if (event.detail === 'confirm' && this.confirmButtonLabel != 'OK') {
            this.actionText = 'Trekker kravet';
            this.spin = true;
            this.hideFormAndShowLoading();
            this.isCancel = false;
            cancelClaim({
                recordId: this.record.Id
            })
                .then((result) => {
                    if (result == 'ok') {
                        this.submitSuccessMessage = 'Kravet ble tilbaketrukket.';
                        this.hideFormAndShowSuccess();
                    } else {
                        this.hideLoading();
                        this.hideFormAndShowError(result);
                    }
                })
                .catch((error) => {
                    this.hideFormAndShowError(error);
                });
        } else {
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

    modalHeader = '';
    modalContent = '';
    noCancelButton = true;

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
        if (event.code == 'Escape') {
            this.closeModal();
        }
    }
}
