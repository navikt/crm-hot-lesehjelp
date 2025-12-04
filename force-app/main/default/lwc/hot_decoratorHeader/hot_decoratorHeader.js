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

    connectedCallback() {
        this.fetchHeaderAndFooter();
    }

    get isSalesforceApp() {
        return navigator.userAgent.includes('SalesforceMobile') || navigator.userAgent.includes('Salesforce1');
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
        let URL = envLinks[this.env] + '?context=' + this.context?.toLowerCase();
        if (this.isSalesforceApp) {
            URL =
                URL +
                '&simple=true' +
                '&logoutWarning=false' +
                '&chatbot=false' +
                '&shareScreen=false' +
                '&logoutWarning=false';
        }
        console.log(URL);
        // eslint-disable-next-line @locker/locker/distorted-window-fetch, compat/compat
        fetch(URL)
            .then((res) => {
                return res.text();
            })
            .then((html) => {
                let parser = new DOMParser();
                let doc = parser.parseFromString(html, 'text/html');
                if (this.isSalesforceApp) {
                    const userMenu = doc.getElementsByTagName('user-menu');
                    for (let elem of userMenu) {
                        elem.remove();
                    }
                    const footer = doc.getElementsByTagName('footer');
                    for (let elem of footer) {
                        elem.setAttribute('data-theme', 'dark');
                        elem.setAttribute(
                            'style',
                            'background-color: var(--a-surface-alt-3-strong);color: var(--a-text-on-inverted);'
                        );
                    }
                }
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
                            decoratorData.headAssets = decoratorData.headAssets.filter((asset) => {
                                return asset.attribs.rel !== 'manifest';
                            });
                            window.__DECORATOR_DATA__ = decoratorData;
                            continue;
                        }
                        if (scripter.type == null || scripter.type === '') continue;
                        const script = document.createElement('script');
                        this.setAttributeIfExists(script, scripter, 'type');
                        this.setAttributeIfExists(script, scripter, 'id');
                        this.setBooleanAttribute(script, scripter, 'async');
                        this.setAttributeIfExists(script, scripter, 'src');
                        this.setAttributeIfExists(script, scripter, 'fetchpriority');
                        script.innerHTML = scripter.innerHTML;
                        scriptGroupElement.appendChild(script);
                    }
                    scriptInjection.appendChild(scriptGroupElement);
                    if (!firstLoad && !this.isSalesforceApp) {
                        this.checkAuthentication();
                    }
                }
            });
    }

    setAttributeIfExists(script, scripter, tag) {
        if (scripter[tag] != null && scripter[tag] !== '') {
            // eslint-disable-next-line @locker/locker/distorted-element-set-attribute
            let attribute = scripter[tag];
            script.setAttribute(tag, attribute);
        }
    }
    setBooleanAttribute(script, scripter, tag) {
        if (scripter[tag]) {
            script.toggleAttribute(tag);
        }
    }
}
