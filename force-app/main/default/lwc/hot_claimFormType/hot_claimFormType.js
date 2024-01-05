import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Hot_claimFormType extends NavigationMixin(LightningElement) {
    @api previousPage = 'home';
    @track currentClaimType = 'Dagliglivet';

    @track componentValues = {
        radiobuttons: [
            { label: 'Dagliglivet', value: 'Dagliglivet', checked: true },
            { label: 'Arbeid', value: 'Arbeid' },
            { label: 'Organisasjon', value: 'Organisasjon' },
            { label: 'Utdanning, opplæring eller arbeidstrening', value: 'Utdanning, opplæring eller arbeidstrening' }
        ],
        isOptionalFields: false
    };

    @api parentClaimComponentValues;

    @track result = {
        type: this.currentClaimType
    };
    @api getComponentValues() {
        return this.componentValues;
    }

    handleClaimTypeChange(event) {
        this.componentValues.radiobuttons = event.detail;
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
    connectedCallback() {
        for (let field in this.parentClaimComponentValues) {
            if (this.componentValues[field] != null) {
                this.componentValues[field] = JSON.parse(JSON.stringify(this.parentClaimComponentValues[field]));
            }
        }
        const selectedValue = this.componentValues.radiobuttons.find((option) => option.checked);
    }
}
