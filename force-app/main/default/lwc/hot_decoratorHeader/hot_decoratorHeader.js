/* eslint-disable @lwc/lwc/no-inner-html */
/* eslint-disable @locker/locker/distorted-element-inner-html-setter */
/* eslint-disable @lwc/lwc/no-document-query */
import { LightningElement, api } from 'lwc';
import navLogo from '@salesforce/resourceUrl/HOT_Decorator_Logo';

const envLinks = {
    Prod: 'https://www.nav.no/dekoratoren',
    Dev: 'https://dekoratoren.ekstern.dev.nav.no/'
};
const authPath = {
    Prod: 'https://www.nav.no/dekoratoren/auth',
    Dev: 'https://dekoratoren.ekstern.dev.nav.no/auth'
};

export default class DecoratorHeader extends LightningElement {
    static renderMode = 'light'; // the default is 'shadow'
    @api env;
    @api context;

    navLogoImg = navLogo; 

    isSalesforceApp = false; 

    get userAgentTest() {
        return navigator.userAgent;
    }

    connectedCallback() {
        const ua = navigator.userAgent;
        if (ua.includes('SalesforceMobile') || ua.includes('Salesforce1')) {
            this.isSalesforceApp = true;
        } else {
            this.isSalesforceApp = false
            this.fetchHeaderAndFooter();
        }
    }

    //Available parameter key value pairs can be viewed at https://github.com/navikt/nav-dekoratoren#parametere
    changeParameter(key, value) {
        window.postMessage(
            {
                source: 'decoratorClient',
                event: 'params',
                payload: { [key]: value }
            },
            window.location.origin
        );
    }
    checkAuthentication() {
        fetch(authPath[this.env], {
            signal: AbortSignal.timeout(60000),
            credentials: 'include'
        })
            .then((res) => {
                res.json()
                    .then((authResponse) => {
                        dispatchEvent(new CustomEvent('authupdated', { detail: authResponse }));
                    })
                    .catch((error) => {
                        console.log('Error on parsing authResponse. ' + error);
                    });
            })
            .catch((error) => {
                console.log('Error fetching authdetails' + error);
            });
    }

    fetchHeaderAndFooter() {
        const URL = envLinks[this.env] + '?context=' + this.context?.toLowerCase();// + '&logoutWarning=false'; /*&chatbot=false&shareScreen=false'*/
        console.log(URL);
        // eslint-disable-next-line @locker/locker/distorted-window-fetch, compat/compat
        fetch(URL)
            .then((res) => {
                return res.text();
            })
            .then((html) => {
                let parser = new DOMParser();
                let doc = parser.parseFromString(html, 'text/html');
                // Header
                const headerInjection = document.querySelector('#header-injection');
                if (headerInjection) {
                    const header = doc.getElementById('header-withmenu')?.innerHTML;
                    headerInjection.innerHTML = header;
                }

                // Footer
                const footerInjection = document.querySelector('#footer-injection');
                if (footerInjection) {
                    const footer = doc.getElementById('footer-withmenu')?.innerHTML;
                    footerInjection.innerHTML = footer;
                }

                // Style
                const styleInjection = document.querySelector('#style-injection');
                if (styleInjection) {
                    const style = doc.getElementById('styles')?.innerHTML;
                    styleInjection.innerHTML = style;
                }

                // Script
                const scriptInjection = document.querySelector('#script-injection');
                if (scriptInjection) {
                    const scriptContainer = doc.getElementById('scripts');

                    const scriptElement = scriptContainer.getElementsByTagName('script');
                    const scriptGroupElement = document.createDocumentFragment();
                    const firstLoad = window.__DECORATOR_DATA__ === undefined;
                    for (let scripter of scriptElement) {
                        if (firstLoad && scripter.id === '__DECORATOR_DATA__') {
                            const decoratorData = JSON.parse(scripter.innerHTML ?? '');
                            decoratorData.headAssets.pop();
                            window.__DECORATOR_DATA__ = decoratorData;
                            continue;
                        }
                        if (scripter.type == null || scripter.type === '') continue;
                        const script = document.createElement('script');
                        this.setAttributeIfExists(script, scripter, 'type');
                        this.setAttributeIfExists(script, scripter, 'id');
                        this.setBooleanAttribute(script, scripter, 'async');
                        this.setAttributeIfExists(script, scripter, 'src', true);
                        this.setAttributeIfExists(script, scripter, 'fetchpriority');
                        script.innerHTML = scripter.innerHTML;
                        scriptGroupElement.appendChild(script);
                    }
                    scriptInjection.appendChild(scriptGroupElement);
                    if (!firstLoad) {
                        this.checkAuthentication();
                    }
                }
            });
    }

    setAttributeIfExists(script, scripter, tag, forceRefetch) {
        if (scripter[tag] != null && scripter[tag] !== '') {
            // eslint-disable-next-line @locker/locker/distorted-element-set-attribute
            let attribute = scripter[tag];
            /*
                        if (forceRefetch) {
            //                attribute = attribute + '?fauxquery=' + crypto.randomUUID().toString();
            script.setAttribute('randomtag', crypto.randomUUID().toString());
                        }
            */
            script.setAttribute(tag, attribute);
        }
    }
    setBooleanAttribute(script, scripter, tag) {
        if (scripter[tag]) {
            script.toggleAttribute(tag);
        }
    }
}
