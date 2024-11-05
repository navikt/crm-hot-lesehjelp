import { LightningElement, api } from 'lwc';

export default class Hot_decoratorEventEmitter extends LightningElement {
    @api delayInMilliseconds;
    @api context;

    connectedCallback() {
        // trigger en authupdate i dekorator for å bli kvitt "Laster...".
        setTimeout(() => {
            dispatchEvent(new CustomEvent('paramsupdated', { detail: { params: { context: this.context } } }));
        }, this.delayInMilliseconds ?? 100);
    }
}
