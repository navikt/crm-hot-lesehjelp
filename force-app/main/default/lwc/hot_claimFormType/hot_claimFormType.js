import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Hot_claimFormType extends NavigationMixin(LightningElement) {
    @api previousPage = 'home';
    @track currentClaimType = 'Dagliglivet';
    @track radiobuttons = [
        { label: 'Dagliglivet', value: 'Dagliglivet', checked: true },
        { label: 'Arbeid', value: 'Arbeid' },
        { label: 'Org.virksomhet/politisk/sos.arb', value: 'Org.virksomhet/politisk/sos.arb' },
        { label: 'Utdanning', value: 'Utdanning' }
    ];
    @track result = {
        type: this.currentClaimType
    };

    handleClaimTypeChange(event) {
        let radiobuttonValues = event.detail;
        radiobuttonValues.forEach((element) => {
            if (element.checked) {
                this.currentClaimType = element.value;
            }
        });
        this.result.type = this.currentClaimType;
    }

    goToPreviousPage() {
        window.scrollTo(0, 0);
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: this.previousPage
            }
        });
    }

    sendResult() {
        const selectedEvent = new CustomEvent('claimformtyperesult', {
            detail: this.result
        });
        this.dispatchEvent(selectedEvent);
    }
}
