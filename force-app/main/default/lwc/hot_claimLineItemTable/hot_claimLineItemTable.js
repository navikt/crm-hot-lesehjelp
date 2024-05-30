import { LightningElement, api, track, wire } from 'lwc';
import getClaimLineItems from '@salesforce/apex/HOT_ClaimLineItemController.getClaimLineItems';
import { refreshApex } from '@salesforce/apex';

export default class Hot_claimLineItemTable extends LightningElement {
    @api recordId;
    @track unmappedClaimLineItems;
    @track claimLineItems;

    connectedCallback() {
        // refreshApex(this.wiredAllClaims);
        console.log(this.recordId);
        getClaimLineItems({
            recordId: this.recordId
        })
            .then((result) => {
                console.log('res');
                this.unmappedClaimLineItems = [];
                this.claimLineItems = [];

                result.forEach((cli) => {
                    this.unmappedClaimLineItems.push(cli);
                    console.log('pusher');
                });

                if (this.unmappedClaimLineItems.length != 0) {
                    this.noClaimLineItems = false;
                    console.log('ikke null');
                }

                this.claimLineItems = this.unmappedClaimLineItems.map((x) => ({
                    ...x
                }));
                console.log(this.claimLineItems);
            })
            .catch((error) => {
                // Handle error
            });
    }
}
