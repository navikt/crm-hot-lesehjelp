import { LightningElement, track, wire, api } from 'lwc';
import getClaim from '@salesforce/apex/HOT_ClaimController.getClaim';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

export default class Hot_warningBannerOnClaim extends LightningElement {
    @api recordId;
    @track record;
    @track noEntitlement;

    wiredResult;
    @wire(getClaim, {
        recordId: '$recordId'
    })
    wiredResult(result) {
        if (result.data) {
            console.log(result.data[0].Entitlement__c);
            if (result.data[0].Entitlement__c == '' || result.data[0].Entitlement__c == undefined) {
                this.noEntitlement = true;
            } else {
                this.noEntitlement = false;
            }
        }
    }
}
