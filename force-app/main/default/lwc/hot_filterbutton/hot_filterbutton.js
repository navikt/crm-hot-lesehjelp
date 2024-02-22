import { LightningElement, api } from 'lwc';
import { setDefaultValue, convertStringToBoolean } from 'c/componentHelperClass';

export default class hot_filterbutton extends LightningElement {
    @api id;
    @api name;
    @api autofocus;
    @api disabled;
    @api value;
    @api title;
    @api buttonLabel;
    @api ariaLabel;
    @api desktopStyle;
    @api mobileStyle;
    isActive = false;

    get buttonClass() {
        let buttonStyle;
        if (this.isActive == true) {
            return 'navds-button ' + buttonStyle + ' active';
        } else {
            return 'navds-button ' + buttonStyle;
        }
    }
    @api setActive() {
        this.isActive = true;
    }
    @api setInactive() {
        this.isActive = false;
    }

    handleClick(event) {
        const eventToSend = new CustomEvent('buttonclick', { detail: event.target.value });
        this.dispatchEvent(eventToSend);
    }

    get ariaLabelValue() {
        return this.ariaLabel === undefined ? this.buttonLabel : this.ariaLabel;
    }

    get setDefaultId() {
        return setDefaultValue(this.id, 'button');
    }

    get setDefaultName() {
        return setDefaultValue(this.name, 'button');
    }

    get setDefaultAutofocus() {
        return convertStringToBoolean(this.autofocus);
    }

    get setDefaultDisabled() {
        return convertStringToBoolean(this.disabled);
    }

    get setDefaultValue() {
        return setDefaultValue(this.value, 'defaultValue');
    }

    get setDefaultStyle() {
        let style = this.desktopStyle;
        if (window.screen.width < 576) {
            style = this.mobileStyle;
        }
        return setDefaultValue(style, '');
    }
}
