export function formatTimeHoursMinutes(hours) {
    const h = Math.floor(hours);
    const m = Math.round((hours % 1) * 60);

    const timerDel = h ? `${h} time${h > 1 ? 'r' : ''}` : '';
    const minutterDel = m ? `${m} minutter` : '';

    if (timerDel && minutterDel) {
        return `${timerDel} og ${minutterDel}`;
    }

    return timerDel || minutterDel || '0 minutter';
}
