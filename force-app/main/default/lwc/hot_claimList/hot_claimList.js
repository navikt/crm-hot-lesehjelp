import { LightningElement, track } from 'lwc';

export default class Hot_claimList extends LightningElement {
    @track showRecievedClaimslist = true;
    @track noRecievedClaims = true;
    breadcrumbs = [
        {
            label: 'Lesehjelp',
            href: ''
        },
        {
            label: 'Krav til godkjenning',
            href: 'mottat-krav'
        }
    ];
}
