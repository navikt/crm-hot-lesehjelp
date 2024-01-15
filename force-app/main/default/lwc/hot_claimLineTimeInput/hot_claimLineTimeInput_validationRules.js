let nowDate = new Date();

export function requireInput(input, label) {
    return input === '' || input === undefined || input === null ? label + ' må fylles ut.' : '';
}

export function dateInPast(date) {
    date = new Date(date);
    let today = new Date(nowDate.getFullYear(), nowDate.getMonth(), nowDate.getDate(), 0, 0, 0, 0);
    return date.getTime() > today.getTime() ? 'Du kan ikke sende inn krav for fremtiden.' : '';
}

export function startBeforeEnd(endDate, startDate) {
    startDate = new Date(startDate);
    endDate = new Date(endDate);
    return startDate.getTime() >= endDate.getTime()
        ? 'Start- og sluttid må være ulike, og sluttid kan ikke være før starttid.'
        : '';
}
