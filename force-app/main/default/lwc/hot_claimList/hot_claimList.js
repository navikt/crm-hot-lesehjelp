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
    @track actionText = '';
    breadcrumbs = [
        {
            label: 'Lesehjelp',
            href: ''
        },
        {
            label: 'Krav til godkjenning',
            href: 'krav-til-godkjenning'
        }
    ];
    @track unmappedClaims;
    @track claims;

    connectedCallback() {
        //refreshApex(this.wiredClaimsResult);
    }
    wiredClaimsResult;
    @wire(getClaimsToApprove)
    wiredClaims(result) {
        this.wiredClaimsResult = result.data;
        if (result.data) {
            console.log('fant' + this.wiredClaimsResult.length);
            if (this.wiredClaimsResult.length != 0) {
                this.noRecievedClaims = false;
            }
            this.unmappedClaims = [];
            this.claims = [];
            result.data.forEach((element) => {
                this.unmappedClaims.push(element);
            });
            if (this.unmappedClaims.length != 0) {
                this.noRecievedClaims = false;
            }

            this.claims = this.unmappedClaims.map((x) => ({
                ...x,
                created: this.formatDateTime(x.CreatedDate)
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
    @track unmappedClaimLineItems;
    @track claimLineItems;
    @track recordName;
    @track recordType;
    @track recordClaimantName;

    @track record = {};

    goToClaim(event) {
        const clickedButton = event.target;
        const claimElement = clickedButton.closest('[data-id]');

        if (claimElement) {
            const claimId = claimElement.getAttribute('data-id');
            console.log(claimId);
            getClaimLineItems({
                recordId: claimId
            })
                .then((result) => {
                    console.log(result);

                    this.claims.forEach((element) => {
                        if (element.Id == claimId) {
                            this.record = element;
                            this.recordName = element.Name;
                            this.recordType = element.Type__c;
                            this.recordClaimantName = element.Claimant__r.Name;
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
                        travelFromPeriode: this.formatDateTimePeriod(x.TravelFromStartTime__c, x.TravelFromEndTime__c)
                    }));
                    this.template.querySelector('.details').classList.remove('hidden');
                    this.template.querySelector('.details').focus();
                })
                .catch((error) => {});
        }
    }
    closeModal() {
        this.template.querySelector('.details').classList.add('hidden');
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
        this.actionText = 'Godkjenner kravet...';
        console.log('approver');
        this.spin = true;
        this.hideFormAndShowLoading();
        approveClaim({
            recordId: this.record.Id
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
    declineClaim() {
        this.actionText = 'Avslår kravet...';
        console.log('approver');
        this.spin = true;
        this.hideFormAndShowLoading();
        declineClaim({
            recordId: this.record.Id
        })
            .then((result) => {
                if (result == 'ok') {
                    this.submitSuccessMessage = 'Kravet ble avslått av deg';
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
    goBack() {
        console.log('tilbake');
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'krav-til-godkjenning'
            }
        });
        console.log('tilbake2');
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
}
