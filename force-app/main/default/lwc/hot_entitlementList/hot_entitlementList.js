import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getEntitlements from '@salesforce/apex/HOT_EntitlementController.getEntitlements';
import { loadStyle } from 'lightning/platformResourceLoader';
import Index from '@salesforce/resourceUrl/index';

export default class Hot_entitlementList extends LightningElement {
    @track showEntitlementlist = true;
    @track noEntitlements = true;
    @track noClaimLineItems = true;
    breadcrumbs = [
        {
            label: 'Hjem',
            href: ''
        },
        {
            label: 'Mine vedtak',
            href: 'mine-vedtak'
        }
    ];

    renderedCallback() {
        loadStyle(this, Index);
    }

    @track unmappedClaimLineItems;
    @track claimLineItems;
    @track recordName;

    @track record;
    @track isNotCancelable = true;
    connectedCallback() {}

    @track unmappedEntitlements;
    @track entitlements;

    wiredEntitlementsResult;
    @wire(getEntitlements)
    wiredClaims(result) {
        this.wiredEntitlementsResult = result.data;
        if (result.data) {
            if (this.wiredEntitlementsResult.length != 0) {
                this.noEntitlements = false;
            }
            this.unmappedEntitlements = [];
            this.entitlements = [];
            result.data.forEach((element) => {
                this.unmappedEntitlements.push(element);
            });
            if (this.unmappedEntitlements.length != 0) {
                this.noEntitlements = false;
            }

            this.entitlements = this.unmappedEntitlements.map((x) => ({
                ...x,
                period: this.formatDateTimePeriod(x.FromDate__c, x.ToDate__c),
                isRecurring: this.checkIfRecurring(x.Is_recurring__c, x.HasBeenRecurred__c)
            }));
            // this.entitlements.sort((a, b) => {
            //     if (b.CreatedDate === a.CreatedDate) {
            //         return 0;
            //     } else {
            //         return b.CreatedDate < a.CreatedDate ? -1 : 1;
            //     }
            // });
        }
    }
    checkIfRecurring(isRecurring, hasBeenRecurred) {
        if (isRecurring == true && hasBeenRecurred == false) {
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
            ' - ' +
            ('0' + unformattedTo.getDate()).slice(-2) +
            '.' +
            ('0' + (unformattedTo.getMonth() + 1)).slice(-2) +
            '.' +
            unformattedTo.getFullYear();

        if (formattedTime.includes('NaN')) {
            formattedTime = '';
        }
        return formattedTime;
    }
}
