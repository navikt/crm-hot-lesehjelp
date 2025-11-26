import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import CLAIMSEND from '@salesforce/resourceUrl/HOT_TasklistSend';
import FIGURE from '@salesforce/resourceUrl/HOT_Figure';
import TASKLIST from '@salesforce/resourceUrl/HOT_TaskList';
import FOLDER from '@salesforce/resourceUrl/HOT_Folder';
import PERSON from '@salesforce/resourceUrl/HOT_Person';
import INFORMATION from '@salesforce/resourceUrl/HOT_Information';
import getEntitlements from '@salesforce/apex/HOT_EntitlementController.getEntitlements';
import { loadStyle } from 'lightning/platformResourceLoader';
import Index from '@salesforce/resourceUrl/index';

export default class hot_lesehjelp_home extends NavigationMixin(LightningElement) {
    nyttKravImg = CLAIMSEND;
    mineVedtakImg = FIGURE;
    mineKravTilGodkjenningImg = TASKLIST;
    mineKravImg = FOLDER;
    mineSiderImg = PERSON;
    veiledningImg = INFORMATION;

    @track pageLinks = {};
    @track waitingClaims = false;
    @track hasDecisions = false;

    wiredEntitlementsResult;
    @wire(getEntitlements)
    wiredClaims(result) {
        this.wiredEntitlementsResult = result.data;
        if (result.data) {
            if (this.wiredEntitlementsResult.length != 0) {
                this.hasDecisions = true;
            }
        }
    }
    renderedCallback() {
        loadStyle(this, Index);
    }

    connectedCallback() {
        sessionStorage.clear(); // Clear session storage when on home
        window.scrollTo(0, 0);
        let baseURL = window.location.origin + '/s';
        this.pageLinks = {
            newClaim: baseURL + '/nytt-krav',
            myClaimantClaims: baseURL + '/mine-krav',
            myEntitlements: baseURL + '/mine-vedtak',
            myClaimsToReview: baseURL + '/krav-til-godkjenning',
            myPage: baseURL + '/mine-sider',
            veiledningLesehjelp: 'https://www.nav.no/samarbeidspartner/lese-og-sekretarhjelp',
            veiledningBruker: baseURL + '/veiledning-til-innbyggere-med-vedtak'
        };
    }
}
