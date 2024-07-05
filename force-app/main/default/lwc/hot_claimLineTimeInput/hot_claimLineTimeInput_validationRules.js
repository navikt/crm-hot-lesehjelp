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
