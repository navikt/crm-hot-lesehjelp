import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Hot_claimFormType extends NavigationMixin(LightningElement) {
    @api previousPage = 'home';
    @track currentClaimType = 'Dagliglivet';
    @track hasChanges = false;

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

    @api claim;
    @api isEdit;

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
        this.hasChanges = true;
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
        this.componentValues.radiobuttons.forEach((element) => {
            if (element.checked) {
                this.currentClaimType = element.value;
            }
        });
        this.result.type = this.currentClaimType;
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

        if (this.claim.Id != '' && this.isEdit == true && this.hasChanges == false) {
            this.componentValues.radiobuttons.forEach((element) => {
                if (element.value === this.claim.Type) {
                    element.checked = true;
                } else {
                    element.checked = false;
                }
            });
            for (let field in this.parentClaimComponentValues) {
                if (this.componentValues[field] != null) {
                    this.componentValues[field] = JSON.parse(JSON.stringify(this.parentClaimComponentValues[field]));
                }
            }
        }
    }
}
