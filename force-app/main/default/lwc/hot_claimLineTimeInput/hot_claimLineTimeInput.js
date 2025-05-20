import { LightningElement, track, wire, api } from 'lwc';
import getTimes from '@salesforce/apex/HOT_ClaimController.getTimes';
import getMyClaimLineItems from '@salesforce/apex/HOT_ClaimLineItemController.getMyClaimLineItems';
import icons from '@salesforce/resourceUrl/icons';

import {
    requireInput,
    requireInputNumbers,
    dateInPast,
    startBeforeEnd,
    dateWithinSixMonths,
    validateInputNumbersOnlyNumbers,
    startBeforeEndAndStartDateTravelTo,
    startBeforeEndAndStartDateTravelFrom
} from './hot_claimLineTimeInput_validationRules';

export default class Hot_claimLineTimeInput extends LightningElement {
    warningicon = icons + '/warningicon.svg';
    @track times = [];
    @track isOnlyOneTime = true;
    uniqueIdCounter = 0;
    randomNumber = 300;
    @track disableAddMoreTimes = false;
    @api claim;
    @api isEdit;
    @track noAccess = false;
    renderedCallback() {
        for (let i = 0; i < this.times.length; i++) {
            console.log('ider: ' + this.times[i].id);
        }
        let travelTimesToInputContainers = this.template.querySelectorAll('.travelTimesToInputContainer');

        let travelTimesFromInputContainers = this.template.querySelectorAll('.travelTimesFromInputContainer');
        let addTravelMinutesToButtonContainer = this.template.querySelectorAll('.addTravelMinutesToButtonContainer');
        let addTravelMinutesFromButtonContainer = this.template.querySelectorAll(
            '.addTravelMinutesFromButtonContainer'
        );
        //let totalDistanceContainer = this.template.querySelectorAll('.totalDistanceContainer');
        let undocumentedExpensesontainer = this.template.querySelectorAll('.undocumentedExpensesontainer');

        if (this.isEdit == true) {
            for (let t of this.times) {
                if (t.hasTravelTo == true && t.editId < travelTimesToInputContainers.length) {
                    travelTimesToInputContainers[t.editId].classList.remove('hidden');
                    addTravelMinutesToButtonContainer[t.editId].classList.remove('hidden');
                } else if (t.editId < travelTimesToInputContainers.length) {
                    travelTimesToInputContainers[t.editId].classList.add('hidden');
                    addTravelMinutesToButtonContainer[t.editId].classList.remove('hidden');
                }
                if (t.hasTravelFrom == true && t.editId < travelTimesFromInputContainers.length) {
                    travelTimesFromInputContainers[t.editId].classList.remove('hidden');
                    addTravelMinutesFromButtonContainer[t.editId].classList.remove('hidden');
                } else if (t.editId < travelTimesFromInputContainers.length) {
                    travelTimesFromInputContainers[t.editId].classList.add('hidden');
                    addTravelMinutesFromButtonContainer[t.editId].classList.remove('hidden');
                }
                if (t.travelDistance == undefined) {
                    t.travelDistance = 0;
                }
                if (t.expensesPublicTransport == undefined) {
                    t.expensesPublicTransport = 0;
                }
                if (t.expensesToll == undefined) {
                    t.expensesToll = 0;
                }
                if (t.expensesParking == undefined) {
                    t.expensesParking = 0;
                }
                if (t.additionalInformation == undefined) {
                    t.additionalInformation = 0;
                }
                if (t.publicTransportRoute == undefined) {
                    t.publicTransportRoute = '';
                }
                if (t.parkingAddress == undefined) {
                    t.parkingAddress = '';
                }
                if (t.travelToFromAddresses == undefined) {
                    t.travelToFromAddresses = '';
                }
                if (t.hasTravelTo || t.hasTravelFrom) {
                    //totalDistanceContainer[t.editId].classList.remove('hidden');
                    undocumentedExpensesontainer[t.editId].classList.remove('hidden');
                } else {
                    //totalDistanceContainer[t.editId].classList.add('hidden');
                    undocumentedExpensesontainer[t.editId].classList.add('hidden');
                }
            }
        } else {
            for (let t of this.times) {
                if (t.hasTravelTo == true && t.id < travelTimesToInputContainers.length) {
                    travelTimesToInputContainers[t.id].classList.remove('hidden');
                    addTravelMinutesToButtonContainer[t.id].classList.remove('hidden');
                } else if (t.id && t.id < travelTimesToInputContainers.length) {
                    travelTimesToInputContainers[t.id].classList.add('hidden');
                    addTravelMinutesToButtonContainer[t.id].classList.remove('hidden');
                }
                if (t.hasTravelFrom == true) {
                    travelTimesFromInputContainers[t.id].classList.remove('hidden');
                    addTravelMinutesFromButtonContainer[t.id].classList.remove('hidden');
                } else if (t.id) {
                    travelTimesFromInputContainers[t.id].classList.add('hidden');
                    addTravelMinutesFromButtonContainer[t.id].classList.remove('hidden');
                }
                if (t.hasTravelTo || t.hasTravelFrom) {
                    // totalDistanceContainer[t.id].classList.remove('hidden');
                    undocumentedExpensesontainer[t.id].classList.remove('hidden');
                } else {
                    //totalDistanceContainer[t.id].classList.add('hidden');
                    undocumentedExpensesontainer[t.id].classList.add('hidden');
                }
            }
        }
    }
    @track myExistingClaimLineItems = [];
    connectedCallback() {
        getMyClaimLineItems({ recordId: this.claim.Id }).then((result) => {
            this.myExistingClaimLineItems = result;
        });
        if (this.claim.Id != '' && this.isEdit == true) {
            this.disableAddMoreTimes = true;
            getTimes({
                claimId: this.claim.Id
            }).then((result) => {
                console.log(result);
                if (result == null) {
                    this.noAccess = true;
                } else {
                    this.times = []; // Empty times
                    for (let timeMap of result) {
                        let timeObject = new Object(this.setTimesValue(timeMap));
                        timeObject.editId = this.uniqueIdCounter;
                        this.uniqueIdCounter += 1;
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
                        timeObject.randomNumber = timeMap.id + 100;

                        if (timeMap.hasTravelTo == 'true') {
                            timeObject.hasTravelTo = true;
                        } else {
                            timeObject.hasTravelTo = false;
                        }
                        if (timeMap.hasTravelFrom == 'true') {
                            timeObject.hasTravelFrom = true;
                        } else {
                            timeObject.hasTravelFrom = false;
                        }

                        this.times.push(timeObject);
                        const index = this.getTimesIndex(timeObject.id);
                        this.times[index].task = timeObject.task;
                        if (timeObject.task == 'Annet (spesifiser i tilleggsinformasjon)') {
                            this.times[index].hasAdditionalInformation = true;
                        } else {
                            this.times[index].hasAdditionalInformation = false;
                        }
                    }
                    this.updateIsOnlyOneTime();
                    this.checkForOverlap();
                }
            });
        } else {
            // Initialize the times array with one time object
            this.times = [this.setTimesValue(null)]; // Assuming you want at least one time initially
            this.times[0].randomNumber = 300;
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
            isClone: timeObject === null ? false : timeObject.isClone,
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
            endTimeTravelFromString: timeObject === null ? null : timeObject.endTimeTravelFromString,
            endTimeTravelFrom: timeObject === null ? null : timeObject.endTimeTravelFrom,
            randomNumber: timeObject === null ? null : timeObject.randomNumber,
            hasAdditionalInformation: timeObject === null ? null : timeObject.hasAdditionalInformation,
            additionalInformation: timeObject === null ? null : timeObject.additionalInformation,
            travelDistance: timeObject === null ? null : timeObject.travelDistance,
            expensesPublicTransport: timeObject === null ? null : timeObject.expensesPublicTransport,
            expensesToll: timeObject === null ? null : timeObject.expensesToll,
            expensesParking: timeObject === null ? null : timeObject.expensesParking,
            travelToFromAddresses: timeObject === null ? null : timeObject.travelToFromAddresses,
            parkingAddress: timeObject === null ? null : timeObject.parkingAddress,
            publicTransportRoute: timeObject === null ? null : timeObject.publicTransportRoute,
            doOverlapOnNewCLI: false,
            doOverlapExistingCLI: false
        };
    }
    handleAdditionalInformation(event) {
        const index = this.getTimesIndex(event.target.name);
        this.times[index].additionalInformation = event.detail;
    }
    handleTravelDistance(event) {
        const index = this.getTimesIndex(event.target.name);
        this.times[index].travelDistance = event.detail;
    }
    handleExpensesPublicTransport(event) {
        const index = this.getTimesIndex(event.target.name);
        this.times[index].expensesPublicTransport = event.detail;
    }
    handleExpensesToll(event) {
        const index = this.getTimesIndex(event.target.name);
        this.times[index].expensesToll = event.detail;
    }
    handleExpensesParking(event) {
        const index = this.getTimesIndex(event.target.name);
        this.times[index].expensesParking = event.detail;
    }
    handleTravelToFromAddresses(event) {
        const index = this.getTimesIndex(event.target.name);
        this.times[index].travelToFromAddresses = event.detail;
    }
    handleParkingAddress(event) {
        const index = this.getTimesIndex(event.target.name);
        this.times[index].parkingAddress = event.detail;
    }
    handlePublicTransportRoute(event) {
        const index = this.getTimesIndex(event.target.name);
        this.times[index].publicTransportRoute = event.detail;
    }
    checkForOverlap() {
        let timeInput = this.getTimeInput();
        let claimLineItems = timeInput.map((item) => ({
            ...item,
            startTime: new Date(item.startTime).getTime(),
            endTime: new Date(item.endTime).getTime(),
            startTimeTravelTo: item.startTimeTravelTo ? new Date(item.startTimeTravelTo).getTime() : null,
            endTimeTravelTo: item.endTimeTravelTo ? new Date(item.endTimeTravelTo).getTime() : null,
            startTimeTravelFrom: item.startTimeTravelFrom ? new Date(item.startTimeTravelFrom).getTime() : null,
            endTimeTravelFrom: item.endTimeTravelFrom ? new Date(item.endTimeTravelFrom).getTime() : null
        }));

        this.times.forEach((time) => {
            time.doOverlapOnNewCLI = false;
            time.doOverlapExistingCLI = false;
        });

        //Sjekker overlapp mot andre kravlinjer bruker oppretter i samme skjemaet
        for (let i = 0; i < claimLineItems.length; i++) {
            let cli1 = claimLineItems[i];

            for (let j = 0; j < claimLineItems.length; j++) {
                if (i !== j) {
                    let cli2 = claimLineItems[j];
                    //Sjekker cli1 starttid og slutt tid mot andre start sluttider + mot reise til og fra
                    if (
                        (cli1.startTime < cli2.endTime && cli1.endTime > cli2.startTime) ||
                        (cli1.startTime < cli2.endTimeTravelTo &&
                            cli1.endTime > cli2.startTimeTravelTo &&
                            cli2.hasTravelTo) ||
                        (cli1.startTime < cli2.endTimeTravelFrom &&
                            cli1.endTime > cli2.startTimeTravelFrom &&
                            cli2.hasTravelFrom)
                    ) {
                        this.times[i].doOverlapOnNewCLI = true;
                        this.times[j].doOverlapOnNewCLI = true;
                    }
                    //Sjekker cli1 reise til start og slutt tid mot andre start sluttider + mot reise til og reise fra
                    if (
                        (cli1.startTimeTravelTo < cli2.endTime &&
                            cli1.endTimeTravelTo > cli2.startTime &&
                            cli1.hasTravelTo) ||
                        (cli1.startTimeTravelTo < cli2.endTimeTravelTo &&
                            cli1.endTimeTravelTo > cli2.startTimeTravelTo &&
                            cli1.hasTravelTo &&
                            cli2.hasTravelTo) ||
                        (cli1.startTimeTravelTo < cli2.endTimeTravelFrom &&
                            cli1.endTimeTravelTo > cli2.startTimeTravelFrom &&
                            cli1.hasTravelTo &&
                            cli2.hasTravelFrom)
                    ) {
                        this.times[i].doOverlapOnNewCLI = true;
                        this.times[j].doOverlapOnNewCLI = true;
                    }
                    //Sjekker cli1 reise fra start og slutt tid mot andre start sluttider + mot reise til og reise fra
                    if (
                        (cli1.startTimeTravelFrom < cli2.endTime &&
                            cli1.endTimeTravelFrom > cli2.startTime &&
                            cli1.hasTravelFrom) ||
                        (cli1.startTimeTravelFrom < cli2.endTimeTravelTo &&
                            cli1.endTimeTravelFrom > cli2.startTimeTravelTo &&
                            cli1.hasTravelFrom &&
                            cli2.hasTravelTo) ||
                        (cli1.startTimeTravelFrom < cli2.endTimeTravelFrom &&
                            cli1.endTimeTravelFrom > cli2.startTimeTravelFrom &&
                            cli1.hasTravelFrom &&
                            cli2.hasTravelFrom)
                    ) {
                        this.times[i].doOverlapOnNewCLI = true;
                        this.times[j].doOverlapOnNewCLI = true;
                    }
                }
            }
        }

        //Sjekker overlapp nye kravlinjer mot andre kravlinjer som allerede er sendt inn
        try {
            claimLineItems.forEach((newCli, index) => {
                this.myExistingClaimLineItems.forEach((existingItem) => {
                    let existingStartTime = new Date(existingItem.StartTime__c).getTime();
                    let existingEndTime = new Date(existingItem.EndTime__c).getTime();
                    let existingTravelToStartTime = existingItem.TravelToStartTime__c
                        ? new Date(existingItem.TravelToStartTime__c).getTime()
                        : null;
                    let existingTravelToEndTime = existingItem.TravelToEndTime__c
                        ? new Date(existingItem.TravelToEndTime__c).getTime()
                        : null;
                    let existingTravelFromStartTime = existingItem.TravelFromStartTime__c
                        ? new Date(existingItem.TravelFromStartTime__c).getTime()
                        : null;
                    let existingTravelFromEndTime = existingItem.TravelFromEndTime__c
                        ? new Date(existingItem.TravelFromEndTime__c).getTime()
                        : null;
                    //Sjekker cli1 starttid og slutt tid mot andre start sluttider + mot reise til og fra
                    if (
                        (newCli.startTime < existingEndTime && newCli.endTime > existingStartTime) ||
                        (newCli.startTime < existingTravelToEndTime &&
                            newCli.endTime > existingTravelToStartTime &&
                            existingItem.HasTravelTo__c) ||
                        (newCli.startTime < existingTravelFromEndTime &&
                            newCli.endTime > existingTravelFromStartTime &&
                            existingItem.HasTravelFrom__c)
                    ) {
                        this.times[index].doOverlapExistingCLI = true;
                    }
                    //Sjekker cli1 reise til start og slutt tid mot andre start sluttider + mot reise til og reise fra
                    if (
                        (newCli.startTimeTravelTo < existingEndTime &&
                            newCli.endTimeTravelTo > existingStartTime &&
                            newCli.hasTravelTo) ||
                        (newCli.startTimeTravelTo < existingTravelToEndTime &&
                            newCli.endTimeTravelTo > existingTravelToStartTime &&
                            newCli.hasTravelTo &&
                            existingItem.HasTravelTo__c) ||
                        (newCli.startTimeTravelTo < existingTravelFromEndTime &&
                            newCli.endTimeTravelTo > existingTravelFromStartTime &&
                            newCli.hasTravelTo &&
                            existingItem.HasTravelFrom__c)
                    ) {
                        this.times[index].doOverlapExistingCLI = true;
                    }
                    //Sjekker cli1 reise fra start og slutt tid mot andre start sluttider + mot reise til og reise fra
                    if (
                        (newCli.startTimeTravelFrom < existingEndTime &&
                            newCli.endTimeTravelFrom > existingStartTime &&
                            newCli.hasTravelFrom) ||
                        (newCli.startTimeTravelFrom < existingTravelToEndTime &&
                            newCli.endTimeTravelFrom > existingTravelToStartTime &&
                            newCli.hasTravelFrom &&
                            existingItem.HasTravelTo__c) ||
                        (newCli.startTimeTravelFrom < existingTravelFromEndTime &&
                            newCli.endTimeTravelFrom > existingTravelFromStartTime &&
                            newCli.hasTravelFrom &&
                            existingItem.HasTravelFrom__c)
                    ) {
                        this.times[index].doOverlapExistingCLI = true;
                    }
                });
            });
        } catch (error) {
            console.log('Error retrieving existing claim line items:', error);
        }
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
        this.updateEndTimeBasedOnDate(index);
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
        this.checkForOverlap();
    }
    handleEndTimeChange(event) {
        const index = this.getTimesIndex(event.target.name);
        this.times[index].endTimeString = event.detail;
        this.times[index].endTime = this.timeStringToDateTime(
            this.times[index].dateMilliseconds +
                (this.times[index].endTimeString < this.times[index].startTimeString ? 86400000 : 0),
            event.detail
        ).getTime();
        this.checkForOverlap();
    }
    setStartTime(index) {
        let dateTime = new Date(this.times[index].startTime);
        let timeString = this.dateTimeToTimeString(dateTime, false);
        let combinedDateTime = this.combineDateTimes(this.times[index].dateMilliseconds, dateTime);
        this.times[index].startTime = combinedDateTime.getTime();
        this.times[index].startTimeString = timeString;
        let startTimeElements = this.template.querySelectorAll('[data-id="startTime"]');
        startTimeElements[index].setValue(this.times[index].startTimeString);
        if (this.times[index].startTimeString === null) {
            this.setEndTimeBasedOnStartTime(index);
        } else {
            this.updateEndTimeBasedOnDate(index);
        }
        this.checkForOverlap();
    }
    setEndTimeBasedOnStartTime(index) {
        const startTime = new Date(this.times[index].startTime);
        const endTime = new Date(this.times[index].endTime);

        const startDate = startTime.toDateString();
        const endDate = endTime.toDateString();

        // Hvis sluttid mangler, eller starttid er etter sluttid på samme dato → sett sluttid = start + 1t
        if (this.times[index].endTimeString === null || (startTime > endTime && startDate === endDate)) {
            let newEndTime = new Date(this.times[index].startTime);
            newEndTime.setHours(newEndTime.getHours() + 1);
            let timeString = this.dateTimeToTimeString(newEndTime, false);
            this.times[index].endTimeString = timeString;
            this.times[index].endTime = newEndTime.getTime();

            let endTimeElements = this.template.querySelectorAll('[data-id="endTime"]');
            endTimeElements[index].setValue(this.times[index].endTimeString);
        }

        this.checkForOverlap();
    }

    updateEndTimeBasedOnDate(index) {
        const date = new Date(this.times[index].dateMilliseconds);
        const end = new Date(this.times[index].endTime);
        date.setHours(end.getHours());
        date.setMinutes(end.getMinutes());
        this.times[index].endTime = date.getTime();
        this.times[index].endTimeString = this.dateTimeToTimeString(date);
        this.checkForOverlap();
    }

    dateTimeToTimeString(dateTime) {
        let hours = dateTime.getHours();
        let minutes = dateTime.getMinutes();
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
        this.uniqueIdCounter -= 1;
        if (this.times.length > 1) {
            const index = this.getTimesIndex(event.target.name);
            if (index !== -1) {
                this.times.splice(index, 1);
                if (this.isEdit != true) {
                    for (let i = index; i < this.times.length; i++) {
                        this.times[i].id = i; // Update ID
                    }
                }
            }
        }
        this.updateIsOnlyOneTime();
        this.checkForOverlap();
    }
    addTime() {
        this.uniqueIdCounter += 1;
        this.randomNumber += 100;
        let newTime = this.setTimesValue(null);
        newTime.id = this.uniqueIdCounter;
        newTime.randomNumber = this.randomNumber;
        this.times.push(newTime);
        this.updateIsOnlyOneTime();
        this.checkForOverlap();
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
        hasErrors += this.validateSameYear();
        hasErrors += this.validateTravelDistance();
        hasErrors += this.validateExpensesParking();
        hasErrors += this.validateExpensesPublicTransport();
        hasErrors += this.validateEexpensesToll();
        console.log('errors: ' + this.hasErrors);
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
    validateTravelDistance() {
        let hasErrors = false;
        const travelDistanceElements = this.template.querySelectorAll('[data-id="travelDistance"]');
        const travelToFromAddressElements = this.template.querySelectorAll('[data-id="travelToFromAddresses"]');

        travelDistanceElements.forEach((element, index) => {
            if (this.times[index].hasTravelTo || this.times[index].hasTravelFrom) {
                let errorMessage = validateInputNumbersOnlyNumbers(element.value, 'Antall km reisevei');
                element.sendErrorMessage(errorMessage);
                hasErrors = hasErrors || errorMessage !== ''; // Using logical OR to accumulate errors

                if (
                    element.value !== '' &&
                    element.value !== '0' &&
                    element.value !== null &&
                    Number(element.value) > 0
                ) {
                    let addressElement = travelToFromAddressElements[index];
                    let addressErrorMessage = requireInput(this.times[index].travelToFromAddresses, 'Feltet');
                    addressElement.sendErrorMessage(addressErrorMessage);
                    hasErrors = hasErrors || addressErrorMessage !== '';
                } else {
                    let addressElement = travelToFromAddressElements[index];
                    addressElement.sendErrorMessage(''); // Clear any previous error messages
                }
            }
        });

        return hasErrors;
    }

    validateExpensesParking() {
        let hasErrors = false;
        const expensesParkingElements = this.template.querySelectorAll('[data-id="expensesParking"]');
        const parkingAddressElements = this.template.querySelectorAll('[data-id="parkingAddress"]');

        expensesParkingElements.forEach((element, index) => {
            if (this.times[index].hasTravelTo || this.times[index].hasTravelFrom) {
                let errorMessage = validateInputNumbersOnlyNumbers(element.value, 'Felt');
                element.sendErrorMessage(errorMessage);
                hasErrors = hasErrors || errorMessage !== ''; // Using logical OR to accumulate errors

                if (
                    element.value !== '' &&
                    element.value !== '0' &&
                    element.value !== null &&
                    Number(element.value) > 0
                ) {
                    let addressElement = parkingAddressElements[index];
                    let addressErrorMessage = requireInput(this.times[index].parkingAddress, 'Feltet');
                    addressElement.sendErrorMessage(addressErrorMessage);
                    hasErrors = hasErrors || addressErrorMessage !== '';
                } else {
                    let addressElement = parkingAddressElements[index];
                    addressElement.sendErrorMessage(''); // Clear any previous error messages
                }
            }
        });

        return hasErrors;
    }

    validateExpensesPublicTransport() {
        let hasErrors = false;
        const expensesPublicTransportElements = this.template.querySelectorAll('[data-id="expensesPublicTransport"]');
        const publicTransportRouteElements = this.template.querySelectorAll('[data-id="publicTransportRoute"]');

        expensesPublicTransportElements.forEach((element, index) => {
            if (this.times[index].hasTravelTo || this.times[index].hasTravelFrom) {
                let errorMessage = validateInputNumbersOnlyNumbers(element.value, 'Felt');
                element.sendErrorMessage(errorMessage);
                hasErrors = hasErrors || errorMessage !== ''; // Using logical OR to accumulate errors

                if (
                    element.value !== '' &&
                    element.value !== '0' &&
                    element.value !== null &&
                    Number(element.value) > 0
                ) {
                    let routeElement = publicTransportRouteElements[index];
                    let addressErrorMessage = requireInput(this.times[index].publicTransportRoute, 'Feltet');
                    routeElement.sendErrorMessage(addressErrorMessage);
                    hasErrors = hasErrors || addressErrorMessage !== '';
                } else {
                    let routeElement = publicTransportRouteElements[index];
                    routeElement.sendErrorMessage(''); // Clear any previous error messages
                }
            }
        });
        return hasErrors;
    }

    validateEexpensesToll() {
        let hasErrors = false;
        this.template.querySelectorAll('[data-id="expensesToll"]').forEach((element, index) => {
            if (this.times[index].hasTravelTo || this.times[index].hasTravelFrom) {
                let errorMessage = validateInputNumbersOnlyNumbers(element.value, 'Felt');
                element.sendErrorMessage(errorMessage);
                hasErrors += errorMessage !== '';
            }
        });
        return hasErrors;
    }
    validateDate() {
        let hasErrors = false;
        this.template.querySelectorAll('[data-id="date"]').forEach((element, index) => {
            let errorMessage = requireInput(element.value, 'Dato');
            if (errorMessage === '') {
                errorMessage = dateInPast(this.times[index].dateMilliseconds);
                errorMessage += dateWithinSixMonths(this.times[index].dateMilliseconds);
            }
            element.sendErrorMessage(errorMessage);
            hasErrors += errorMessage !== '';
        });
        return hasErrors;
    }
    validateSameYear() {
        let hasErrors = false;
        let errorMessage = 'Tidene må være innenfor samme år';
        const years = [];
        this.template.querySelectorAll('[data-id="date"]').forEach((element, index) => {
            const date = new Date(element.value);
            const year = date.getFullYear();
            years.push(year);
        });

        const uniqueYears = Array.from(new Set(years));
        if (uniqueYears.length > 1) {
            hasErrors = true;
            this.template.querySelectorAll('[data-id="date"]').forEach((element, index) => {
                element.sendErrorMessage(errorMessage);
            });
        }
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
                errorMessage = startBeforeEnd(this.times[index].endTime, this.times[index].startTime);
            }
            element.sendErrorMessage(errorMessage);
            hasErrors += errorMessage !== '';
        });
        return hasErrors;
    }
    validateTravelToDate() {
        let hasErrors = false;
        this.template.querySelectorAll('[data-id="dateTravelTo"]').forEach((element, index) => {
            if (this.times[index].hasTravelTo) {
                let errorMessage = requireInput(element.value, 'Dato');
                if (errorMessage === '') {
                    errorMessage = dateInPast(this.times[index].dateTravelToMilliseconds);
                    errorMessage += dateWithinSixMonths(this.times[index].dateTravelToMilliseconds);
                }
                element.sendErrorMessage(errorMessage);
                hasErrors += errorMessage !== '';
            }
        });
        return hasErrors;
    }

    validateTravelToStartTime() {
        let hasErrors = false;
        this.template.querySelectorAll('[data-id="startTimeTravelTo"]').forEach((element, index) => {
            if (this.times[index].hasTravelTo) {
                let errorMessage = requireInput(element.getValue(), 'Starttid');
                element.sendErrorMessage(errorMessage);
                hasErrors += errorMessage !== '';
            }
        });
        return hasErrors;
    }

    validateTravelToEndTime() {
        let hasErrors = false;
        this.template.querySelectorAll('[data-id="endTimeTravelTo"]').forEach((element, index) => {
            if (this.times[index].hasTravelTo) {
                let errorMessage = requireInput(element.getValue(), 'Sluttid');
                if (errorMessage === '') {
                    errorMessage = startBeforeEndAndStartDateTravelTo(
                        this.times[index].startTimeTravelTo,
                        this.times[index].endTimeTravelTo,
                        this.times[index].startTime
                    );
                }
                element.sendErrorMessage(errorMessage);
                hasErrors += errorMessage !== '';
            }
        });
        return hasErrors;
    }

    validateTravelFromDate() {
        let hasErrors = false;
        this.template.querySelectorAll('[data-id="dateTravelFrom"]').forEach((element, index) => {
            if (this.times[index].hasTravelFrom) {
                let errorMessage = requireInput(element.value, 'Dato');
                if (errorMessage === '') {
                    errorMessage = dateInPast(this.times[index].dateTravelFromMilliseconds);
                    errorMessage += dateWithinSixMonths(this.times[index].dateTravelFromMilliseconds);
                }
                element.sendErrorMessage(errorMessage);
                hasErrors += errorMessage !== '';
            }
        });
        return hasErrors;
    }

    validateTravelFromStartTime() {
        let hasErrors = false;
        this.template.querySelectorAll('[data-id="startTimeTravelFrom"]').forEach((element, index) => {
            if (this.times[index].hasTravelFrom) {
                let errorMessage = requireInput(element.getValue(), 'Starttid');
                if (errorMessage === '') {
                    errorMessage = startBeforeEndAndStartDateTravelFrom(
                        this.times[index].endTimeTravelFrom,
                        this.times[index].startTimeTravelFrom,
                        this.times[index].endTime
                    );
                }
                element.sendErrorMessage(errorMessage);
                hasErrors += errorMessage !== '';
            }
        });
        return hasErrors;
    }

    validateTravelFromEndTime() {
        let hasErrors = false;
        this.template.querySelectorAll('[data-id="endTimeTravelFrom"]').forEach((element, index) => {
            if (this.times[index].hasTravelFrom) {
                let errorMessage = requireInput(element.getValue(), 'Sluttid');
                if (errorMessage === '') {
                    errorMessage = startBeforeEnd(
                        this.times[index].endTimeTravelFrom,
                        this.times[index].startTimeTravelFrom
                    );
                }
                element.sendErrorMessage(errorMessage);
                hasErrors += errorMessage !== '';
            }
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
                    this.times[index].dateTravelTo = this.times[index].date;
                    this.times[index].dateTravelToMilliseconds = new Date(this.times[index].date).getTime();
                    let travelTimesToInputContainers = this.template.querySelectorAll('.travelTimesToInputContainer');
                    let addTravelMinutesToButtonContainer = this.template.querySelectorAll(
                        '.addTravelMinutesToButtonContainer'
                    );
                    travelTimesToInputContainers[index].classList.remove('hidden');
                    addTravelMinutesToButtonContainer[index].classList.remove('hidden');
                } else {
                    this.times[index].hasTravelTo = false;
                    let travelTimesToInputContainers = this.template.querySelectorAll('.travelTimesToInputContainer');
                    let addTravelMinutesToButtonContainer = this.template.querySelectorAll(
                        '.addTravelMinutesToButtonContainer'
                    );
                    travelTimesToInputContainers[index].classList.add('hidden');
                    addTravelMinutesToButtonContainer[index].classList.add('hidden');
                }
            }
        });
        this.checkForOverlap();
    }
    handleOnTravelRadioButtonsFrom(event) {
        let radiobuttonValues = event.detail;
        radiobuttonValues.forEach((element) => {
            if (element.checked) {
                const index = this.getTimesIndex(event.target.name);
                if (element.value == 'true') {
                    this.times[index].hasTravelFrom = true;
                    this.times[index].dateTravelFrom = this.times[index].date;
                    this.times[index].dateTravelFromMilliseconds = new Date(this.times[index].date).getTime();
                    let travelTimesFromInputContainers = this.template.querySelectorAll(
                        '.travelTimesFromInputContainer'
                    );
                    let addTravelMinutesFromButtonContainer = this.template.querySelectorAll(
                        '.addTravelMinutesFromButtonContainer'
                    );
                    travelTimesFromInputContainers[index].classList.remove('hidden');
                    addTravelMinutesFromButtonContainer[index].classList.remove('hidden');
                } else {
                    this.times[index].hasTravelFrom = false;
                    let travelTimesFromInputContainers = this.template.querySelectorAll(
                        '.travelTimesFromInputContainer'
                    );
                    let addTravelMinutesFromButtonContainer = this.template.querySelectorAll(
                        '.addTravelMinutesFromButtonContainer'
                    );
                    travelTimesFromInputContainers[index].classList.add('hidden');
                    addTravelMinutesFromButtonContainer[index].classList.add('hidden');
                }
            }
        });
        this.checkForOverlap();
    }
    /* 
    HANDLING TRAVEL TO DATE TIME INPUTS FIELDS
    */
    handleDateTravelToChange(event) {
        const index = this.getTimesIndex(event.target.name);
        this.times[index].dateTravelTo = event.detail;
        this.times[index].dateTravelToMilliseconds = new Date(event.detail).getTime();
        this.setStartTimeTravelTo(index);
        this.checkForOverlap();
    }
    handleStartTimeTravelToChange(event) {
        const index = this.getTimesIndex(event.target.name);
        this.times[index].startTimeTravelToString = event.detail;
        this.times[index].startTimeTravelTo = this.timeStringToDateTime(
            this.times[index].dateTravelToMilliseconds,
            event.detail
        ).getTime();
        this.setEndTimeTravelToBasedOnStartTime(index);
        this.checkForOverlap();
    }
    handleEndTimeTravelToChange(event) {
        const index = this.getTimesIndex(event.target.name);
        this.times[index].endTimeTravelToString = event.detail;
        this.times[index].endTimeTravelTo = this.timeStringToDateTime(
            this.times[index].dateTravelToMilliseconds +
                (this.times[index].endTimeTravelToString < this.times[index].startTimeTravelToString ? 86400000 : 0),
            event.detail
        ).getTime();
        this.checkForOverlap();
    }
    setStartTimeTravelTo(index) {
        let dateTime = new Date(this.times[index].startTimeTravelTo);
        let timeString = this.dateTimeToTimeString(dateTime, false);
        let combinedDateTime = this.combineDateTimes(this.times[index].dateTravelToMilliseconds, dateTime);
        this.times[index].startTimeTravelTo = combinedDateTime.getTime();
        this.times[index].startTimeTravelToString = timeString;
        let startTimeElements = this.template.querySelectorAll('[data-id="startTimeTravelTo"]');
        startTimeElements[index].setValue(this.times[index].startTimeTravelToString);
        if (this.times[index].startTimeTravelToString === null) {
            // this.times[index].startTimeTravelToString = timeString;
            // let startTimeElements = this.template.querySelectorAll('[data-id="startTimeTravelTo"]');
            // startTimeElements[index].setValue(this.times[index].startTimeTravelToString);
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
        this.checkForOverlap();
    }
    handleStartTimeTravelFromChange(event) {
        const index = this.getTimesIndex(event.target.name);
        this.times[index].startTimeTravelFromString = event.detail;
        this.times[index].startTimeTravelFrom = this.timeStringToDateTime(
            this.times[index].dateTravelFromMilliseconds,
            event.detail
        ).getTime();
        this.setEndTimeTravelFromBasedOnStartTime(index);
        this.checkForOverlap();
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
        this.checkForOverlap();
    }
    setStartTimeTravelFrom(index) {
        let dateTime = new Date(this.times[index].startTimeTravelFrom);
        let timeString = this.dateTimeToTimeString(dateTime, false);
        let combinedDateTime = this.combineDateTimes(this.times[index].dateTravelFromMilliseconds, dateTime);
        this.times[index].startTimeTravelFrom = combinedDateTime.getTime();
        this.times[index].startTimeTravelFromString = timeString;
        let startTimeElements = this.template.querySelectorAll('[data-id="startTimeTravelFrom"]');
        startTimeElements[index].setValue(this.times[index].startTimeTravelFromString);

        if (this.times[index].startTimeTravelFromString === null) {
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
    addTravelTime(event) {
        const index = this.getTimesIndex(event.target.name);

        // Date
        this.times[index].dateTravelTo = this.times[index].date;
        this.times[index].dateTravelToMilliseconds = new Date(this.times[index].date).getTime();

        // Start Time Travel To (start time of the appointment - travel duration)
        let startTime = new Date(this.times[index].startTime);
        let dateTimeStart = new Date(startTime.getTime() - event.detail * 60000);
        let timeStringStart = this.dateTimeToTimeString(dateTimeStart, false);
        this.times[index].startTimeTravelToString = timeStringStart;
        this.times[index].startTimeTravelTo = dateTimeStart.getTime();

        let startTimeElements = this.template.querySelectorAll('[data-id="startTimeTravelTo"]');
        startTimeElements[index].setValue(this.times[index].startTimeTravelToString);

        // End Time Travel To (start time of the appointment)
        let dateTime = new Date(this.times[index].startTime);
        let timeString = this.dateTimeToTimeString(dateTime, false);
        this.times[index].endTimeTravelToString = timeString;
        this.times[index].endTimeTravelTo = dateTime.getTime();

        let endTimeElements = this.template.querySelectorAll('[data-id="endTimeTravelTo"]');
        endTimeElements[index].setValue(this.times[index].endTimeTravelToString);
    }

    addTravelTimeFrom(event) {
        const index = this.getTimesIndex(event.target.name);

        // Date
        this.times[index].dateTravelFrom = this.times[index].date;
        this.times[index].dateTravelFromMilliseconds = new Date(this.times[index].date).getTime();

        // Start Time Travel From (end time of the appointment)
        let endTime = new Date(this.times[index].endTime);
        let startTimeTravelFromString = this.dateTimeToTimeString(endTime, false);
        this.times[index].startTimeTravelFromString = startTimeTravelFromString;
        this.times[index].startTimeTravelFrom = endTime.getTime();

        let startTimeElements = this.template.querySelectorAll('[data-id="startTimeTravelFrom"]');
        startTimeElements[index].setValue(this.times[index].startTimeTravelFromString);

        // End Time Travel From (start time of travel + travel duration)
        let endTimeTravelFrom = new Date(this.times[index].endTime);
        endTimeTravelFrom = new Date(endTimeTravelFrom.getTime() + event.detail * 60000);

        let endTimeTravelFromString = this.dateTimeToTimeString(endTimeTravelFrom, false);
        this.times[index].endTimeTravelFromString = endTimeTravelFromString;
        this.times[index].endTimeTravelFrom = endTimeTravelFrom.getTime();

        let endTimeElements = this.template.querySelectorAll('[data-id="endTimeTravelFrom"]');
        endTimeElements[index].setValue(this.times[index].endTimeTravelFromString);
    }

    cloneClaimLineItem(event) {
        let hasErrors = 0;
        hasErrors += this.validateSimpleTimes();
        if (hasErrors == 0) {
            this.uniqueIdCounter += 1;
            this.randomNumber += 300;
            const index = this.getTimesIndex(event.target.name);
            for (let time of this.times) {
                if (time.id == index) {
                    const testTimeObject = {
                        id: this.uniqueIdCounter,
                        date: time.date,
                        startTimeString: time.startTimeString,
                        endTimeString: time.endTimeString,
                        randomNumber: this.randomNumber,
                        dateMilliseconds: time.dateMilliseconds,
                        startTime: time.startTime,
                        endTime: time.endTime,
                        task: time.task,
                        isClone: true,
                        hasTravelTo: time.hasTravelTo,
                        hasTravelFrom: time.hasTravelFrom,
                        startTimeTravelTo: time.startTimeTravelTo,
                        startTimeTravelToString: time.startTimeTravelToString,
                        dateTravelTo: time.dateTravelTo,
                        dateTravelToMilliseconds: time.dateTravelToMilliseconds,
                        endTimeTravelTo: time.endTimeTravelTo,
                        endTimeTravelToString: time.endTimeTravelToString,
                        dateTravelFromMilliseconds: time.dateTravelFromMilliseconds,
                        dateTravelFrom: time.dateTravelFrom,
                        startTimeTravelFrom: time.startTimeTravelFrom,
                        startTimeTravelFromString: time.startTimeTravelFromString,
                        endTimeTravelFromString: time.endTimeTravelFromString,
                        endTimeTravelFrom: time.endTimeTravelFrom,
                        hasAdditionalInformation: time.hasAdditionalInformation,
                        additionalInformation: time.additionalInformation,
                        travelDistance: time.travelDistance,
                        expensesPublicTransport: time.expensesPublicTransport,
                        expensesToll: time.expensesToll,
                        expensesParking: time.expensesParking,
                        travelToFromAddresses: time.travelToFromAddresses,
                        parkingAddress: time.parkingAddress,
                        publicTransportRoute: time.publicTransportRoute,
                        isNew: 0
                    };
                    let clonedTime = this.setTimesValue(testTimeObject);
                    this.times.push(clonedTime);
                    this.updateIsOnlyOneTime();

                    break;
                }
            }
        }
        this.checkForOverlap();
    }
}
