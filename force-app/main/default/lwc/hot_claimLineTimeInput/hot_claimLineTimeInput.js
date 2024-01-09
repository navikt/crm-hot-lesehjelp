import { LightningElement, track, wire, api } from 'lwc';
import getTimes from '@salesforce/apex/HOT_ClaimController.getTimes';
import { requireInput, dateInPast, startBeforeEnd } from './hot_claimLineTimeInput_validationRules';

export default class Hot_claimLineTimeInput extends LightningElement {
    @track times = [];
    @track isOnlyOneTime = true;
    uniqueIdCounter = 0;
    randomNumber = 3;

    @api claim;
    @api isEdit;

    connectedCallback() {
        if (this.claim.Id != '' && this.isEdit == true) {
            console.log('innerst');
            getTimes({
                claimId: this.claim.Id
            }).then((result) => {
                console.log(result);
                if (result.length === 0) {
                    this.times = [this.setTimesValue(null)];
                    this.times[0].randomNumber = 2;
                    this.updateIsOnlyOneTime();
                    console.log('tom');
                } else {
                    console.log('ikke tom');
                    //this.times[0].randomNumber = 2;
                    this.times = []; // Empty times
                    for (let timeMap of result) {
                        let timeObject = new Object(this.setTimesValue(timeMap));
                        console.log(timeMap.id);
                        console.log(timeMap.task);

                        timeObject.task = timeMap.task;
                        //GENERAL TIMES
                        timeObject.dateMilliseconds = new Date(timeMap.date).getTime();
                        timeObject.startTimeString = this.dateTimeToTimeString(
                            new Date(Number(timeMap.startTime)),
                            true
                        );
                        timeObject.startTime = this.timeStringToDateTime(
                            timeObject.dateMilliseconds,
                            timeObject.startTimeString
                        ).getTime();
                        timeObject.endTimeString = this.dateTimeToTimeString(new Date(Number(timeMap.endTime)), true);
                        timeObject.endTime = this.timeStringToDateTime(
                            timeObject.dateMilliseconds +
                                (timeObject.endTimeString < timeObject.startTimeString ? 86400000 : 0),
                            timeObject.endTimeString
                        ).getTime();
                        //TRAVEL TO TIMES
                        timeObject.dateTravelToMilliseconds = new Date(timeMap.dateTravelTo).getTime();
                        timeObject.startTimeTravelToString = this.dateTimeToTimeString(
                            new Date(Number(timeMap.startTimeTravelTo)),
                            true
                        );

                        timeObject.startTimeTravelTo = this.timeStringToDateTime(
                            timeObject.dateTravelToMilliseconds,
                            timeObject.startTimeTravelToString
                        ).getTime();
                        timeObject.endTimeTravelToString = this.dateTimeToTimeString(
                            new Date(Number(timeMap.endTimeTravelTo)),
                            true
                        );
                        timeObject.endTimeTravelTo = this.timeStringToDateTime(
                            timeObject.dateTravelToMilliseconds +
                                (timeObject.endTimeTravelToString < timeObject.startTimeTravelToString ? 86400000 : 0),
                            timeObject.endTimeTravelToString
                        ).getTime();
                        //TRAVEL FROM TIMES
                        timeObject.dateTravelFromMilliseconds = new Date(timeMap.dateTravelFrom).getTime();
                        timeObject.startTimeTravelFromString = this.dateTimeToTimeString(
                            new Date(Number(timeMap.startTimeTravelFrom)),
                            true
                        );

                        timeObject.startTimeTravelFrom = this.timeStringToDateTime(
                            timeObject.dateTravelFromMilliseconds,
                            timeObject.startTimeTravelFromString
                        ).getTime();
                        timeObject.endTimeTravelFromString = this.dateTimeToTimeString(
                            new Date(Number(timeMap.endTimeTravelFrom)),
                            true
                        );
                        timeObject.endTimeTravelFrom = this.timeStringToDateTime(
                            timeObject.dateTravelFromMilliseconds +
                                (timeObject.endTimeTravelFromString < timeObject.startTimeTravelFromString
                                    ? 86400000
                                    : 0),
                            timeObject.endTimeTravelFromString
                        ).getTime();
                        //TASKTYPE AND ADDITIONAL INFORMATION
                        timeObject.additionalInformation = timeMap.additionalInformation;
                        timeObject.task = timeMap.task;

                        this.times.push(timeObject);

                        const index = this.getTimesIndex(timeObject.id);
                        this.times[index].task = timeObject.task;
                        if (timeObject.task == 'Annet (spesifiser i tilleggsinformasjon)') {
                            this.times[index].hasAdditionalInformation = true;
                        } else {
                            this.times[index].hasAdditionalInformation = false;
                        }
                    }
                }
            });
        } else {
            // Initialize the times array with one time object
            this.times = [this.setTimesValue(null)]; // Assuming you want at least one time initially
            this.times[0].randomNumber = 2;
            this.updateIsOnlyOneTime();
        }
    }
    taskOptions = [
        { label: 'Velg oppgave', name: 'Placeholder', selected: true, disabled: true },
        { label: 'Møte', name: 'Møte' },
        { label: 'Arkivering', name: 'Arkivering' },
        { label: 'Lest avis', name: 'Lest avis' },
        { label: 'Lest e-post', name: 'Lest e-post' },
        { label: 'Post', name: 'Post' },
        { label: 'Referat', name: 'Referat' },
        { label: 'Annet (spesifiser i tilleggsinformasjon)', name: 'Annet (spesifiser i tilleggsinformasjon)' }
    ];
    setTimesValue(timeObject) {
        return {
            id: timeObject === null ? 0 : timeObject.id,
            date: timeObject === null ? null : timeObject.date,
            startTimeString: timeObject === null ? null : timeObject.startTimeString,
            endTimeString: timeObject === null ? null : timeObject.endTimeString,
            isNew: timeObject === null ? 1 : 0,
            dateMilliseconds: timeObject === null ? null : timeObject.dateMilliseconds,
            startTime: timeObject === null ? null : timeObject.startTime,
            endTime: timeObject === null ? null : timeObject.endTime,
            task: timeObject === null ? null : timeObject.task,
            hasTravelTo: timeObject === null ? null : timeObject.hasTravelTo,
            hasTravelFrom: timeObject === null ? null : timeObject.hasTravelFrom,
            startTimeTravelTo: timeObject === null ? null : timeObject.startTimeTravelTo,
            startTimeTravelToString: timeObject === null ? null : timeObject.startTimeTravelToString,
            dateTravelTo: timeObject === null ? null : timeObject.dateTravelTo,
            dateTravelToMilliseconds: timeObject === null ? null : timeObject.dateTravelToMilliseconds,
            endTimeTravelToString: timeObject === null ? null : timeObject.endTimeTravelToString,
            endTimeTravelTo: timeObject === null ? null : timeObject.endTimeTravelTo,
            dateTravelFromMilliseconds: timeObject === null ? null : timeObject.dateTravelFromMilliseconds,
            dateTravelFrom: timeObject === null ? null : timeObject.dateTravelFrom,
            startTimeTravelFrom: timeObject === null ? null : timeObject.startTimeTravelFrom,
            startTimeTravelFromString: timeObject === null ? null : timeObject.startTimeTravelFromString,
            endTimeTravelFrom: timeObject === null ? null : timeObject.endTimeTravelFrom,
            randomNumber: timeObject === null ? null : timeObject.randomNumber,
            hasAdditionalInformation: timeObject === null ? null : timeObject.hasAdditionalInformation,
            additionalInformation: timeObject === null ? null : timeObject.additionalInformation
        };
    }
    handleAdditionalInformation(event) {
        const index = this.getTimesIndex(event.target.name);
        this.times[index].additionalInformation = event.detail;
    }

    getTimesIndex(name) {
        let j = -1;
        for (let i = 0; i < this.times.length; i++) {
            if (this.times[i].id === name) {
                j = i;
                break;
            }
        }
        return j;
    }

    handleDateChange(event) {
        const index = this.getTimesIndex(event.target.name);
        this.times[index].date = event.detail;
        this.times[index].dateMilliseconds = new Date(event.detail).getTime();
        this.setStartTime(index);
    }
    handleTaskChoiceMade(event) {
        const index = this.getTimesIndex(event.target.name);
        this.times[index].task = event.detail.name;
        if (event.detail.name == 'Annet (spesifiser i tilleggsinformasjon)') {
            this.times[index].hasAdditionalInformation = true;
        } else {
            this.times[index].hasAdditionalInformation = false;
        }
    }
    handleStartTimeChange(event) {
        const index = this.getTimesIndex(event.target.name);
        this.times[index].startTimeString = event.detail;
        this.times[index].startTime = this.timeStringToDateTime(
            this.times[index].dateMilliseconds,
            event.detail
        ).getTime();
        this.setEndTimeBasedOnStartTime(index);
    }
    handleEndTimeChange(event) {
        const index = this.getTimesIndex(event.target.name);
        this.times[index].endTimeString = event.detail;
        this.times[index].endTime = this.timeStringToDateTime(
            this.times[index].dateMilliseconds +
                (this.times[index].endTimeString < this.times[index].startTimeString ? 86400000 : 0),
            event.detail
        ).getTime();
    }
    setStartTime(index) {
        let dateTime = new Date();
        let timeString = this.dateTimeToTimeString(dateTime, false);
        let combinedDateTime = this.combineDateTimes(this.times[index].dateMilliseconds, dateTime);
        this.times[index].startTime = combinedDateTime.getTime();

        if (this.times[index].startTimeString === null) {
            this.times[index].startTimeString = timeString;
            let startTimeElements = this.template.querySelectorAll('[data-id="startTime"]');
            startTimeElements[index].setValue(this.times[index].startTimeString);
            this.setEndTimeBasedOnStartTime(index);
        } else {
            this.updateEndTimeBasedOnDate(index);
        }
    }
    setEndTimeBasedOnStartTime(index) {
        if (this.times[index].endTimeString === null || this.times[index].startTime > this.times[index].endTime) {
            let dateTime = new Date(this.times[index].startTime);
            dateTime.setHours(dateTime.getHours() + 1);
            let timeString = this.dateTimeToTimeString(dateTime, false);
            this.times[index].endTimeString = timeString;
            this.times[index].endTime = dateTime.getTime();
            let endTimeElements = this.template.querySelectorAll('[data-id="endTime"]');
            endTimeElements[index].setValue(this.times[index].endTimeString);
        }
    }

    updateEndTimeBasedOnDate(index) {
        let combinedDateTime = this.combineDateTimes(
            this.times[index].dateMilliseconds,
            new Date(this.times[index].endTime)
        );
        this.times[index].endTime = combinedDateTime.getTime();
    }

    dateTimeToTimeString(dateTime, isLoadingDatetimes) {
        let hours = dateTime.getHours();
        let minutes = isLoadingDatetimes ? dateTime.getMinutes() : 0;
        return (
            (hours < 10 ? '0' + hours.toString() : hours.toString()) +
            ':' +
            (minutes < 10 ? '0' + minutes.toString() : minutes.toString())
        );
    }
    timeStringToDateTime(dateTime, timeString) {
        let hoursMinutes = timeString.split(':');
        let hours = hoursMinutes[0].valueOf();
        let minutes = hoursMinutes[1].valueOf();
        dateTime = new Date(dateTime);
        dateTime.setHours(hours);
        dateTime.setMinutes(minutes);
        return dateTime;
    }
    combineDateTimes(date, time) {
        let dateTime = new Date(date);
        dateTime.setHours(time.getHours());
        return dateTime;
    }

    removeTime(event) {
        if (this.times.length > 1) {
            const index = this.getTimesIndex(event.target.name);
            if (index !== -1) {
                this.times.splice(index, 1);
            }
        }
        this.updateIsOnlyOneTime();
    }
    addTime() {
        this.uniqueIdCounter += 1;
        this.randomNumber += 100;
        let newTime = this.setTimesValue(null);
        newTime.id = this.uniqueIdCounter;
        newTime.randomNumber = this.randomNumber;
        this.times.push(newTime);
        this.updateIsOnlyOneTime();
    }
    updateIsOnlyOneTime() {
        this.isOnlyOneTime = this.times.length === 1;
    }
    @api
    getTimeInput() {
        let timeInputs = {};
        //timeInputs.times = this.timesListToObject(this.times);
        return this.times;
        //return timeInputs;
        //DENNE FJERNES VEL. SJEKK OM DEN IKKE BRUKES
    }
    @api
    validateFields() {
        let hasErrors = 0;
        hasErrors += this.validateSimpleTimes();
        return hasErrors;
    }

    validateSimpleTimes() {
        let hasErrors = this.validateDate();
        hasErrors += this.validateStartTime();
        hasErrors += this.validateEndTime();
        hasErrors += this.validateType();
        hasErrors += this.validateAdditionalInformation();
        hasErrors += this.validateTravelToDate();
        hasErrors += this.validateTravelToStartTime();
        hasErrors += this.validateTravelToEndTime();
        hasErrors += this.validateTravelFromDate();
        hasErrors += this.validateTravelFromStartTime();
        hasErrors += this.validateTravelFromEndTime();
        return hasErrors;
    }
    validateType() {
        let hasErrors = false;
        this.template.querySelectorAll('[data-id="taskType"]').forEach((checkbox) => {
            hasErrors += checkbox.validationHandler();
        });
        return hasErrors;
    }
    validateAdditionalInformation() {
        let hasErrors = false;
        this.template.querySelectorAll('[data-id="additionalInformation"]').forEach((input) => {
            hasErrors += input.validationHandler();
        });
        return hasErrors;
    }
    validateDate() {
        let hasErrors = false;
        this.template.querySelectorAll('[data-id="date"]').forEach((element, index) => {
            let errorMessage = requireInput(element.value, 'Dato');
            if (errorMessage === '') {
                errorMessage = dateInPast(this.times[index].dateMilliseconds);
            }
            element.sendErrorMessage(errorMessage);
            hasErrors += errorMessage !== '';
        });
        return hasErrors;
    }
    validateStartTime() {
        let hasErrors = false;
        this.template.querySelectorAll('[data-id="startTime"]').forEach((element) => {
            let errorMessage = requireInput(element.getValue(), 'Starttid');
            element.sendErrorMessage(errorMessage);
            hasErrors += errorMessage !== '';
        });
        return hasErrors;
    }
    validateEndTime() {
        let errorMessage = '';
        let hasErrors = false;
        this.template.querySelectorAll('[data-id="endTime"]').forEach((element, index) => {
            errorMessage = requireInput(element.getValue(), 'Sluttid');
            if (errorMessage === '') {
                errorMessage = startBeforeEnd(this.times[0].endTime, this.times[0].startTime);
            }
            element.sendErrorMessage(errorMessage);
            hasErrors += errorMessage !== '';
        });
        return hasErrors;
    }
    validateTravelToDate() {
        let hasErrors = false;
        this.template.querySelectorAll('[data-id="dateTravelTo"]').forEach((element, index) => {
            let errorMessage = requireInput(element.value, 'Dato');
            if (errorMessage === '') {
                errorMessage = dateInPast(this.times[index].dateTravelToMilliseconds);
            }
            element.sendErrorMessage(errorMessage);
            hasErrors += errorMessage !== '';
        });
        return hasErrors;
    }
    validateTravelToStartTime() {
        let hasErrors = false;
        this.template.querySelectorAll('[data-id="startTimeTravelTo"]').forEach((element) => {
            let errorMessage = requireInput(element.getValue(), 'Starttid');
            element.sendErrorMessage(errorMessage);
            hasErrors += errorMessage !== '';
        });
        return hasErrors;
    }
    validateTravelToEndTime() {
        let errorMessage = '';
        let hasErrors = false;
        this.template.querySelectorAll('[data-id="endTimeTravelTo"]').forEach((element, index) => {
            errorMessage = requireInput(element.getValue(), 'Sluttid');
            if (errorMessage === '') {
                errorMessage = startBeforeEnd(this.times[0].endTimeTravelTo, this.times[0].startTimeTravelTo);
            }
            element.sendErrorMessage(errorMessage);
            hasErrors += errorMessage !== '';
        });
        return hasErrors;
    }
    validateTravelFromDate() {
        let hasErrors = false;
        this.template.querySelectorAll('[data-id="dateTravelFrom"]').forEach((element, index) => {
            let errorMessage = requireInput(element.value, 'Dato');
            if (errorMessage === '') {
                errorMessage = dateInPast(this.times[index].dateTravelFromMilliseconds);
            }
            element.sendErrorMessage(errorMessage);
            hasErrors += errorMessage !== '';
        });
        return hasErrors;
    }
    validateTravelFromStartTime() {
        let hasErrors = false;
        this.template.querySelectorAll('[data-id="startTimeTravelFrom"]').forEach((element) => {
            let errorMessage = requireInput(element.getValue(), 'Starttid');
            element.sendErrorMessage(errorMessage);
            hasErrors += errorMessage !== '';
        });
        return hasErrors;
    }
    validateTravelFromEndTime() {
        let errorMessage = '';
        let hasErrors = false;
        this.template.querySelectorAll('[data-id="endTimeTravelFrom"]').forEach((element, index) => {
            errorMessage = requireInput(element.getValue(), 'Sluttid');
            if (errorMessage === '') {
                errorMessage = startBeforeEnd(this.times[0].endTimeTravelFrom, this.times[0].startTimeTravelFrom);
            }
            element.sendErrorMessage(errorMessage);
            hasErrors += errorMessage !== '';
        });
        return hasErrors;
    }

    get dateTimeDesktopStyle() {
        let isDesktop = 'width: 100%;';
        if (window.screen.width > 576) {
            isDesktop = 'width: 30%;';
        }
        return isDesktop;
    }
    @track componentValues = {
        travelToRadioButtons: [
            { label: 'Ja', value: 'true' },
            { label: 'Nei', value: 'false', checked: true }
        ],
        travelFromRadioButtons: [
            { label: 'Ja', value: 'true' },
            { label: 'Nei', value: 'false', checked: true }
        ],
        isOptionalFields: false
    };
    handleOnTravelToRadioButtonsTo(event) {
        let radiobuttonValues = event.detail;
        radiobuttonValues.forEach((element) => {
            if (element.checked) {
                const index = this.getTimesIndex(event.target.name);
                if (element.value == 'true') {
                    this.times[index].hasTravelTo = true;
                } else {
                    this.times[index].hasTravelTo = false;
                }
            }
        });
    }
    handleOnTravelRadioButtonsFrom(event) {
        let radiobuttonValues = event.detail;
        radiobuttonValues.forEach((element) => {
            if (element.checked) {
                const index = this.getTimesIndex(event.target.name);
                if (element.value == 'true') {
                    this.times[index].hasTravelFrom = true;
                } else {
                    this.times[index].hasTravelFrom = false;
                }
            }
        });
    }
    /* 
    HANDLING TRAVEL TO DATE TIME INPUTS FIELDS
    */
    handleDateTravelToChange(event) {
        const index = this.getTimesIndex(event.target.name);
        this.times[index].dateTravelTo = event.detail;
        this.times[index].dateTravelToMilliseconds = new Date(event.detail).getTime();
        this.setStartTimeTravelTo(index);
    }
    handleStartTimeTravelToChange(event) {
        const index = this.getTimesIndex(event.target.name);
        this.times[index].startTimeTravelToString = event.detail;
        this.times[index].startTimeTravelTo = this.timeStringToDateTime(
            this.times[index].dateTravelToMilliseconds,
            event.detail
        ).getTime();
        this.setEndTimeTravelToBasedOnStartTime(index);
    }
    handleEndTimeTravelToChange(event) {
        const index = this.getTimesIndex(event.target.name);
        this.times[index].endTimeTravelToString = event.detail;
        this.times[index].endTimeTravelTo = this.timeStringToDateTime(
            this.times[index].dateTravelToMilliseconds +
                (this.times[index].endTimeTravelToString < this.times[index].startTimeTravelToString ? 86400000 : 0),
            event.detail
        ).getTime();
    }
    setStartTimeTravelTo(index) {
        let dateTime = new Date();
        let timeString = this.dateTimeToTimeString(dateTime, false);
        let combinedDateTime = this.combineDateTimes(this.times[index].dateTravelToMilliseconds, dateTime);
        this.times[index].startTimeTravelTo = combinedDateTime.getTime();

        if (this.times[index].startTimeTravelToString === null) {
            this.times[index].startTimeTravelToString = timeString;
            let startTimeElements = this.template.querySelectorAll('[data-id="startTimeTravelTo"]');
            startTimeElements[index].setValue(this.times[index].startTimeTravelToString);
            this.setEndTimeTravelToBasedOnStartTime(index);
        } else {
            this.updateEndTimeTravelToBasedOnDate(index);
        }
    }
    setEndTimeTravelToBasedOnStartTime(index) {
        if (
            this.times[index].endTimeTravelToString === null ||
            this.times[index].startTimeTravelTo > this.times[index].endTimeTravelTo
        ) {
            let dateTime = new Date(this.times[index].startTimeTravelTo);
            dateTime.setHours(dateTime.getHours() + 1);
            let timeString = this.dateTimeToTimeString(dateTime, false);
            this.times[index].endTimeTravelToString = timeString;
            this.times[index].endTimeTravelTo = dateTime.getTime();
            let endTimeElements = this.template.querySelectorAll('[data-id="endTimeTravelTo"]');
            endTimeElements[index].setValue(this.times[index].endTimeTravelToString);
        }
    }

    updateEndTimeTravelToBasedOnDate(index) {
        let combinedDateTime = this.combineDateTimes(
            this.times[index].dateTravelToMilliseconds,
            new Date(this.times[index].endTimeTravelTo)
        );
        this.times[index].endTimeTravelTo = combinedDateTime.getTime();
    }
    /* 
    HANDLING TRAVEL FROM DATE TIME INPUTS FIELDS
    */
    handleDateTravelFromChange(event) {
        const index = this.getTimesIndex(event.target.name);
        this.times[index].dateTravelFrom = event.detail;
        this.times[index].dateTravelFromMilliseconds = new Date(event.detail).getTime();
        this.setStartTimeTravelFrom(index);
    }
    handleStartTimeTravelFromChange(event) {
        const index = this.getTimesIndex(event.target.name);
        this.times[index].startTimeTravelFromString = event.detail;
        this.times[index].startTimeTravelFrom = this.timeStringToDateTime(
            this.times[index].dateTravelFromMilliseconds,
            event.detail
        ).getTime();
        this.setEndTimeTravelFromBasedOnStartTime(index);
    }
    handleEndTimeTravelFromChange(event) {
        const index = this.getTimesIndex(event.target.name);
        this.times[index].endTimeTravelFromString = event.detail;
        this.times[index].endTimeTravelFrom = this.timeStringToDateTime(
            this.times[index].dateTravelFromMilliseconds +
                (this.times[index].endTimeTravelFromString < this.times[index].startTimeTravelFromString
                    ? 86400000
                    : 0),
            event.detail
        ).getTime();
    }
    setStartTimeTravelFrom(index) {
        let dateTime = new Date();
        let timeString = this.dateTimeToTimeString(dateTime, false);
        let combinedDateTime = this.combineDateTimes(this.times[index].dateTravelFromMilliseconds, dateTime);
        this.times[index].startTimeTravelFrom = combinedDateTime.getTime();

        if (this.times[index].startTimeTravelFromString === null) {
            this.times[index].startTimeTravelFromString = timeString;
            let startTimeElements = this.template.querySelectorAll('[data-id="startTimeTravelFrom"]');
            startTimeElements[index].setValue(this.times[index].startTimeTravelFromString);
            this.setEndTimeTravelFromBasedOnStartTime(index);
        } else {
            this.updateEndTimeTravelFromBasedOnDate(index);
        }
    }
    setEndTimeTravelFromBasedOnStartTime(index) {
        if (
            this.times[index].endTimeTravelFromString === null ||
            this.times[index].startTimeTravelFrom > this.times[index].endTimeTravelFrom
        ) {
            let dateTime = new Date(this.times[index].startTimeTravelFrom);
            dateTime.setHours(dateTime.getHours() + 1);
            let timeString = this.dateTimeToTimeString(dateTime, false);
            this.times[index].endTimeTravelFromString = timeString;
            this.times[index].endTimeTravelFrom = dateTime.getTime();
            let endTimeElements = this.template.querySelectorAll('[data-id="endTimeTravelFrom"]');
            endTimeElements[index].setValue(this.times[index].endTimeTravelFromString);
        }
    }
    updateEndTimeTravelFromBasedOnDate(index) {
        let combinedDateTime = this.combineDateTimes(
            this.times[index].dateTravelFromMilliseconds,
            new Date(this.times[index].endTimeTravelFrom)
        );
        this.times[index].endTimeTravelFrom = combinedDateTime.getTime();
    }
}
