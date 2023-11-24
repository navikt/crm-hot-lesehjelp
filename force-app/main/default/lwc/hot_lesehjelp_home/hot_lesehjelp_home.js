import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import CLAIMSEND from '@salesforce/resourceUrl/TasklistSendIcon';
import FIGURE from '@salesforce/resourceUrl/Figure';
import TASKLIST from '@salesforce/resourceUrl/TaskList';
import FOLDER from '@salesforce/resourceUrl/Folder';
import PERSON from '@salesforce/resourceUrl/Person';
import INFORMATION from '@salesforce/resourceUrl/Information';

export default class hot_lesehjelp_home extends NavigationMixin(LightningElement) {
    nyttKravImg = CLAIMSEND;
    mineVedtakImg = FIGURE;
    mineKravTilGodkjenningImg = TASKLIST;
    mineKravImg = FOLDER;
    mineSiderImg = PERSON;
    veiledningImg = INFORMATION;

    @track pageLinks = {};
    @track waitingClaims = true;

    connectedCallback() {
        sessionStorage.clear(); // Clear session storage when on home
        window.scrollTo(0, 0);
        let baseURLArray = window.location.pathname.split('/');
        baseURLArray.pop();
        let baseURL = baseURLArray.join('/');
        this.pageLinks = {
            newClaim: baseURL + '/nytt-krav',
            myRequests: baseURL + '/innsendte-krav',
            myRequestsOther: baseURL + '/mine-vedtak',
            myPage: baseURL + '/mien-krav',
            myThreads: baseURL + '/mine-sider',
            veiledning: 'https://www.nav.no/lese-og-sekretaerhjelp'
        };
    }
}
