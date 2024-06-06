import { LightningElement, api, track, wire } from 'lwc';
import getClaimLineItems from '@salesforce/apex/HOT_ClaimLineItemController.getClaimLineItems';
import { refreshApex } from '@salesforce/apex';

export default class Hot_claimLineItemTable extends LightningElement {
    @api recordId;
    @track unmappedClaimLineItems;
    @track claimLineItems;
    @track noClaimLineItems = false;
    @track error = false;
    @track errorMessage;

    connectedCallback() {
        getClaimLineItems({
            recordId: this.recordId
        })
            .then((result) => {
                this.unmappedClaimLineItems = [];
                this.claimLineItems = [];

                result.forEach((cli) => {
                    this.unmappedClaimLineItems.push(cli);
                });

                if (this.unmappedClaimLineItems.length != 0) {
                    this.noClaimLineItems = false;
                } else {
                    this.noClaimLineItems = true;
                }

                this.claimLineItems = this.unmappedClaimLineItems.map((x) => ({
                    ...x,
                    period: this.formatDateTimePeriod(x.StartTime__c, x.EndTime__c),
                    travelToPeriode: this.formatDateTimePeriod(x.TravelToStartTime__c, x.TravelToEndTime__c),
                    travelFromPeriode: this.formatDateTimePeriod(x.TravelFromStartTime__c, x.TravelFromEndTime__c),
                    link: this.createLink(x.Id),
                    hasOverlap: this.checkHasOverlap(x.OverlappingClaimLineItemsIds__c),
                    overlappingLinks: x.OverlappingClaimLineItemsIds__c
                        ? x.OverlappingClaimLineItemsIds__c.split(',').map((id) => {
                              const trimmedId = id.trim();
                              return {
                                  id: trimmedId,
                                  link: this.createLink(trimmedId)
                              };
                          })
                        : []
                }));
            })
            .catch((error) => {
                this.error = true;
                this.errorMessage = error;
            });
    }
    createLink(Id) {
        return '/lightning/r/' + Id + '/view';
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
    checkHasOverlap(overlapIds) {
        if (overlapIds && overlapIds.length !== 0) {
            return true;
        } else {
            return false;
        }
    }
}
