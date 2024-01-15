import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import CLAIMSEND from '@salesforce/resourceUrl/HOT_TasklistSend';
import FIGURE from '@salesforce/resourceUrl/HOT_Figure';
import TASKLIST from '@salesforce/resourceUrl/HOT_TaskList';
import FOLDER from '@salesforce/resourceUrl/HOT_Folder';
import PERSON from '@salesforce/resourceUrl/HOT_Person';
import INFORMATION from '@salesforce/resourceUrl/HOT_Information';
import getEntitlements from '@salesforce/apex/HOT_EntitlementController.getEntitlements';

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

    connectedCallback() {
        sessionStorage.clear(); // Clear session storage when on home
        window.scrollTo(0, 0);
        let baseURLArray = window.location.pathname.split('/');
        baseURLArray.pop();
        let baseURL = baseURLArray.join('/');
        this.pageLinks = {
            newClaim: baseURL + '/nytt-krav',
            myClaimantClaims: baseURL + '/mine-krav',
            myEntitlements: baseURL + '/mine-vedtak',
            myClaimsToReview: baseURL + '/krav-til-godkjenning',
            myPage: baseURL + '/mine-sider',
            veiledning: 'https://www.nav.no/lese-og-sekretaerhjelp'
        };
    }
}
