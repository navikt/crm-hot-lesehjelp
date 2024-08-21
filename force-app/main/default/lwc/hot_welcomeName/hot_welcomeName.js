import { LightningElement, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.FirstName';

export default class Hot_welcomeName extends LightningElement {
    @track name;
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    })
    wireuser({ data }) {
        if (data) {
            this.name = this.formatName(data.fields.FirstName.value);
        }
    }
    formatName(name) {
        return name
            .split(' ')
            .map((word) => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
            .join(' ');
    }
}
