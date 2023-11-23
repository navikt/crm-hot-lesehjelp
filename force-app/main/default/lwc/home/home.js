import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import CLAIMSEND from '@salesforce/resourceUrl/TasklistSendFill';
import FIGURE from '@salesforce/resourceUrl/FigureFill';
import TASKLIST from '@salesforce/resourceUrl/TaskListFill';
import FOLDER from '@salesforce/resourceUrl/FolderFill';
import PERSON from '@salesforce/resourceUrl/PersonFill';
import INFORMATION from '@salesforce/resourceUrl/InformationFill';

export default class Hot_home extends NavigationMixin(LightningElement) {
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
