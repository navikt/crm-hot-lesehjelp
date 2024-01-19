import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getPersonDetails from '@salesforce/apex/HOT_UserInfoController.getPersonDetails';
import LINK from '@salesforce/resourceUrl/HOT_Link';

export default class Hot_userInformation extends LightningElement {
    LinkImg = LINK;

    breadcrumbs = [
        {
            label: 'Lesehjelp',
            href: ''
        },
        {
            label: 'Min side',
            href: 'mine-sider'
        }
    ];

    connectedCallback() {
        refreshApex(this.wiredAllClaim);
    }

    @track mobilenumber;
    @track email;
    @track banknumber;
    @track address;

    personResult;

    @wire(getPersonDetails)
    wiredResult(result) {
        if (result.data) {
            this.personResult = result.data;
            this.mobilenumber = this.personResult.INT_KrrMobilePhone__c;
            this.email = this.personResult.INT_KrrEmail__c;
            this.banknumber = this.personResult.INT_BankAccountNumber__c;
            this.address =
                this.personResult.INT_ResidentialAddress__c +
                ', ' +
                this.personResult.INT_ResidentialZipCode__c +
                ' ' +
                this.personResult.INT_ResidentialPlace__c;

            console.log(this.personResult.INT_KrrMobilePhone__c);
        } else {
            console.log('Fant ingenting');
        }
    }
}
