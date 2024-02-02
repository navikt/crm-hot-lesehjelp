import { LightningElement, track, wire, api } from 'lwc';
import getClaim from '@salesforce/apex/HOT_ClaimController.getClaim';

export default class Hot_warningBannerOnClaim extends LightningElement {
    @api recordId;
    @track record;
    @track noEntitlement;
    @track exceedsEntitlementHours = false;
    @track remainingTimeSum;

    wiredResult;
    @wire(getClaim, {
        recordId: '$recordId'
    })
    wiredResult(result) {
        if (result.data) {
            this.record = result.data[0];
            if (this.record.Entitlement__c == '' || this.record.Entitlement__c == undefined) {
                this.noEntitlement = true;
            } else {
                this.noEntitlement = false;

                const entitledHours = this.record.Entitlement__r ? this.record.Entitlement__r.EntitledHours__c : null;
                const entitledHoursUsed = this.record.Entitlement__r
                    ? this.record.Entitlement__r.EntitledHoursUsed__c
                    : null;
                this.remainingTimeSum = entitledHours - entitledHoursUsed;
                if (this.record.TotalHours__c >= this.remainingTimeSum) {
                    this.exceedsEntitlementHours = true;
                } else {
                    this.exceedsEntitlementHours = false;
                }
            }
            console.log(result.data);
        }
    }
}
