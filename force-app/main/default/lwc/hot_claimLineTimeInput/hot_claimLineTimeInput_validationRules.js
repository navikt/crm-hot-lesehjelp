let nowDate = new Date();

export function requireInput(input, label) {
    if (input === '' || input === undefined || input === null) {
        return label + ' må fylles ut.';
    } else if (input.length > 255) {
        return label + ' kan ikke være lengre enn 255 tegn.';
    } else {
        return '';
    }
}

export function requireInputNumbers(input, label) {
    if (input === '' || input === undefined || input === null) {
        return label + ' må fylles ut.';
    } else if (!/^\d+$/.test(input)) {
        return label + ' må kun inneholde tall uten desimaler';
    } else if (input.length > 18) {
        return label + ' kan ikke være lengre enn 18 tegn';
    } else {
        return '';
    }
}

export function validateInputNumbersOnlyNumbers(input, label) {
    if (input !== '' && input !== undefined && input !== null && !/^\d+$/.test(input)) {
        return label + ' må kun inneholde tall uten desimaler';
    } else {
        return '';
    }
}

export function dateInPast(date) {
    date = new Date(date);
    let today = new Date(nowDate.getFullYear(), nowDate.getMonth(), nowDate.getDate(), 0, 0, 0, 0);
    return date.getTime() > today.getTime() ? 'Du kan ikke sende inn krav for fremtiden.' : '';
}
export function dateWithinSixMonths(date) {
    date = new Date(date);
    let sixMonthsAgo = new Date();
    sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);
    return date.getTime() < sixMonthsAgo.getTime() ? 'Datoen kan ikke være eldre enn 6 måneder.' : '';
}
export function startBeforeEndAndStartDateTravelTo(startTimeTravelTo, endTimeTravelTo, startTime) {
    startTimeTravelTo = new Date(startTimeTravelTo);
    endTimeTravelTo = new Date(endTimeTravelTo);
    startTime = new Date(startTime);

    const travelToYear = startTimeTravelTo.getFullYear();
    const travelToMonth = startTimeTravelTo.getMonth();
    const travelToDay = startTimeTravelTo.getDate();

    const endTravelToYear = endTimeTravelTo.getFullYear();
    const endTravelToMonth = endTimeTravelTo.getMonth();
    const endTravelToDay = endTimeTravelTo.getDate();

    const startYear = startTime.getFullYear();
    const startMonth = startTime.getMonth();
    const startDay = startTime.getDate();

    if (
        travelToYear !== endTravelToYear ||
        travelToMonth !== endTravelToMonth ||
        travelToDay !== endTravelToDay ||
        endTravelToYear !== startYear ||
        endTravelToMonth !== startMonth ||
        endTravelToDay !== startDay
    ) {
        return 'Reisen må være på samme dato som oppdraget, og før oppdraget.';
    }

    if (startTimeTravelTo.getTime() >= endTimeTravelTo.getTime()) {
        return 'Start- og sluttid må være ulike, og sluttid kan ikke være før starttid.';
    }

    if (endTimeTravelTo.getTime() > startTime.getTime()) {
        return 'Reise må være før starttid på oppdraget.';
    }

    return '';
}

export function startBeforeEndAndStartDateTravelFrom(endTimeTravelFrom, startTimeTravelFrom, endTime) {
    endTimeTravelFrom = new Date(endTimeTravelFrom);
    startTimeTravelFrom = new Date(startTimeTravelFrom);
    endTime = new Date(endTime);

    const endTravelYear = endTimeTravelFrom.getFullYear();
    const endTravelMonth = endTimeTravelFrom.getMonth();
    const endTravelDay = endTimeTravelFrom.getDate();

    const startTravelYear = startTimeTravelFrom.getFullYear();
    const startTravelMonth = startTimeTravelFrom.getMonth();
    const startTravelDay = startTimeTravelFrom.getDate();

    const endYear = endTime.getFullYear();
    const endMonth = endTime.getMonth();
    const endDay = endTime.getDate();

    if (startTravelYear !== endYear || startTravelMonth !== endMonth || startTravelDay !== endDay) {
        return 'Reisen må være på samme dato som oppdraget, og etter oppdraget.';
    }
    if (startTimeTravelFrom.getTime() >= endTimeTravelFrom.getTime()) {
        return 'Starttid må være før sluttid.';
    }
    if (startTimeTravelFrom.getTime() < endTime.getTime()) {
        return 'Starttid må være etter sluttid på oppdraget.';
    }

    return '';
}

export function startBeforeEnd(endDate, startDate) {
    startDate = new Date(startDate);
    endDate = new Date(endDate);

    const startYear = startDate.getFullYear();
    const startMonth = startDate.getMonth();
    const startDay = startDate.getDate();

    const endYear = endDate.getFullYear();
    const endMonth = endDate.getMonth();
    const endDay = endDate.getDate();

    if (startYear !== endYear || startMonth !== endMonth || startDay !== endDay) {
        return 'Start- og sluttid må være på samme dag.';
    }

    return startDate.getTime() >= endDate.getTime()
        ? 'Start- og sluttid må være ulike, og sluttid kan ikke være før starttid.'
        : '';
}
