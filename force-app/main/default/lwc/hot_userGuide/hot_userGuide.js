import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Hot_userGuide extends NavigationMixin(LightningElement) {
    goBack() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'home'
            }
        });
    }
}
