import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getMyClaims from '@salesforce/apex/HOT_ClaimController.getMyClaims';
import getClaimLineItems from '@salesforce/apex/HOT_ClaimLineItemController.getClaimLineItems';

export default class Hot_entitlementList extends LightningElement {
    @track showEntitlementlist = true;
    @track noEntitlements = true;
    @track noClaimLineItems = true;
    breadcrumbs = [
        {
            label: 'Lesehjelp',
            href: ''
        },
        {
            label: 'Mine vedtak',
            href: 'mine-vedtak'
        }
    ];

    @track unmappedClaimLineItems;
    @track claimLineItems;
    @track recordName;

    @track record;
    @track isNotCancelable = true;
    connectedCallback() {
        refreshApex(this.wiredAllClaim);
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
            console.log('fant' + this.wiredClaimsResult.length);
            if (this.wiredClaimsResult.length != 0) {
                this.noEntitlements = false;
            }
            this.unmappedClaims = [];
            this.claims = [];
            result.data.forEach((element) => {
                this.unmappedClaims.push(element);
            });
            if (this.unmappedClaims.length != 0) {
                this.noEntitlements = false;
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
    checkIfCancelButtonIsDisabled(status) {
        if (status == 'Sent') {
            return false;
        } else {
            return true;
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
}
