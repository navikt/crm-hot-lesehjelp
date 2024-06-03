import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import getClaimsToApprove from '@salesforce/apex/HOT_ClaimController.getClaimsToApprove';
import getClaimLineItems from '@salesforce/apex/HOT_ClaimLineItemController.getClaimLineItems';
import approveClaim from '@salesforce/apex/HOT_ClaimController.approveClaim';
import declineClaim from '@salesforce/apex/HOT_ClaimController.declineClaim';

export default class Hot_claimList extends NavigationMixin(LightningElement) {
    @track showRecievedClaimslist = true;
    @track noRecievedClaims = true;
    @track noOlderClaims = true;
    @track actionText = '';

    @track fieldValues = {
        CommentFromUser__c: ''
    };

    breadcrumbs = [
        {
            label: 'Hjem',
            href: ''
        },
        {
            label: 'Krav til godkjenning',
            href: 'krav-til-godkjenning'
        }
    ];
    @track unmappedClaims;
    @track unmappedOlderClaims;
    @track claims;
    @track olderClaims;

    connectedCallback() {
        refreshApex(this.wiredAllClaims);
    }
    wiredAllClaims;

    wiredClaimsResult;
    @wire(getClaimsToApprove)
    wiredClaims(result) {
        this.noRecievedClaims = true;
        this.wiredAllClaims = result;
        this.wiredClaimsResult = result.data;
        if (result.data) {
            this.unmappedClaims = [];
            this.unmappedOlderClaims = [];

            this.claims = [];
            this.olderClaims = [];
            result.data.forEach((element) => {
                if (element.Status__c == 'Sent') {
                    this.unmappedClaims.push(element);
                } else {
                    this.unmappedOlderClaims.push(element);
                }
            });
            if (this.unmappedClaims.length != 0) {
                this.noRecievedClaims = false;
            }
            if (this.unmappedOlderClaims.length != 0) {
                this.noOlderClaims = false;
            }

            this.claims = this.unmappedClaims.map((x) => ({
                ...x,
                created: this.formatDateTime(x.CreatedDate),
                isOldClaim: this.isOldClaim(x.Status__c)
            }));
            this.olderClaims = this.unmappedOlderClaims.map((x) => ({
                ...x,
                created: this.formatDateTime(x.CreatedDate),
                isOldClaim: this.isOldClaim(x.Status__c),
                status: this.userStatus(x.ApprovedByUser__c, x.Status__c)
            }));
            this.claims.sort((a, b) => {
                if (b.CreatedDate === a.CreatedDate) {
                    return 0;
                } else {
                    return b.CreatedDate < a.CreatedDate ? -1 : 1;
                }
            });
            this.olderClaims.sort((a, b) => {
                if (b.CreatedDate === a.CreatedDate) {
                    return 0;
                } else {
                    return b.CreatedDate < a.CreatedDate ? -1 : 1;
                }
            });
        }
    }
    @track unmappedClaimLineItems;
    @track claimLineItems;
    @track recordName;
    @track recordType;
    @track recordClaimantName;
    @track isDeclineClaim = false;

    @track record = {};
    @track commentValue = '';
    goToClaim(event) {
        this.isDeclineClaim = false;
        this.notRedClaim = true;
        const clickedButton = event.target;
        const claimElement = clickedButton.closest('[data-id]');

        if (claimElement) {
            const claimId = claimElement.getAttribute('data-id');

            const foundClaim = this.claims.find((element) => element.Id === claimId);
            const foundOlderClaim = this.olderClaims.find((element) => element.Id === claimId);

            if (foundClaim) {
                this.record = foundClaim;
                this.template.querySelector('c-textarea').setTextValue('');
                this.template.querySelector('c-checkbox').clearCheckboxValue();
            }
            if (foundOlderClaim) {
                this.record = foundOlderClaim;
            }

            if (this.record) {
                this.recordName = this.record.Name;
                this.recordType = this.record.Type__c;
                this.recordClaimantName = this.record.Claimant__r.Name;

                getClaimLineItems({
                    recordId: claimId
                })
                    .then((result) => {
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
                            travelFromPeriode: this.formatDateTimePeriod(
                                x.TravelFromStartTime__c,
                                x.TravelFromEndTime__c
                            ),
                            hasTravel: this.hasTravel(x.HasTravelTo__c, x.HasTravelFrom__c)
                        }));
                        const dialog = this.template.querySelector('dialog.details');
                        dialog.showModal();
                        dialog.focus();
                    })
                    .catch((error) => {
                        // Handle error
                    });
            }
        }
    }
    isOldClaim(status) {
        if (status == 'Sent') {
            return false;
        } else {
            return true;
        }
    }
    userStatus(approvedByUser, status) {
        if (status == 'Withdrawn') {
            return 'Kravet ble trukket tilbake.';
        } else if (approvedByUser == false) {
            return 'Avvist av deg.';
        } else if (approvedByUser == true) {
            return 'Godkjent av deg.';
        } else {
            return '';
        }
    }

    closeModal() {
        const dialog = this.template.querySelector('dialog.details');
        dialog.close();
        //this.recordId = undefined;
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

    @track notRedClaim = true;
    approveClaimCheckboxHandle(event) {
        if (event.detail == true) {
            this.notRedClaim = false;
        } else {
            this.notRedClaim = true;
        }
    }
    @track spin = false;
    @track submitSuccessMessage = '';

    approveClaim() {
        this.fieldValues.CommentFromUser__c = this.template.querySelector('c-textarea').getValue();
        this.actionText = 'Godkjenner kravet...';
        this.spin = true;
        this.hideFormAndShowLoading();
        approveClaim({
            recordId: this.record.Id,
            comment: this.fieldValues.CommentFromUser__c
        })
            .then((result) => {
                if (result == 'ok') {
                    this.submitSuccessMessage = 'Kravet ble godkjent av deg';
                    this.hideFormAndShowSuccess();
                } else {
                    this.hideLoading();
                    this.hideFormAndShowError(result);
                }
            })
            .catch((error) => {
                this.hideFormAndShowError(error);
            });
    }

    declineClaimPromptReason() {}
    declineClaim() {
        this.isDeclineClaim = true;
        if (this.handleValidation()) {
            return;
        } else {
            this.fieldValues.CommentFromUser__c = this.template.querySelector('c-textarea').getValue();
            this.actionText = 'Avviser kravet...';
            this.spin = true;
            this.hideFormAndShowLoading();
            declineClaim({
                recordId: this.record.Id,
                comment: this.fieldValues.CommentFromUser__c
            })
                .then((result) => {
                    if (result == 'ok') {
                        this.submitSuccessMessage = 'Kravet ble avvist av deg';
                        this.hideFormAndShowSuccess();
                    } else {
                        this.hideLoading();
                        this.hideFormAndShowError(result);
                    }
                })
                .catch((error) => {
                    this.hideFormAndShowError(error);
                });
        }
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
        this.template.querySelector('.main-content').classList.remove('hidden');
        this.modalHeader = 'Noe gikk galt!';
        this.noCancelButton = true;
        this.modalContent = errorMessage;
        this.template.querySelector('c-alertdialog').showModal();
        this.spin = false;
    }
    goBack() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'krav-til-godkjenning'
            }
        });
    }
    handleAlertDialogClick() {
        window.scrollTo(0, 0);
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'krav-til-godkjenning'
            }
        });
    }
    handleValidation() {
        let hasErrors = false;
        if (this.declineClaim) {
            this.template.querySelectorAll('c-textarea').forEach((input) => {
                hasErrors += input.validationHandler();
            });
        }
        return hasErrors;
    }
    handleKeyDown(event) {
        if (event.code == 'Escape') {
            this.closeModal();
        }
    }
}
