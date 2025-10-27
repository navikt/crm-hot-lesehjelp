public without sharing class HOT_RateController {
    public static void calculateClaimByRates(List<HOT_ClaimLineItem__c> claimLineItems, Boolean isRecalculating) {
        if (claimLineItems.isEmpty())
            return;
        System.debug(claimLineItems.size());
        // Finn ytterpunkter for å hente relevante satser (kun dato)
        Date earliestStart = null;
        Date latestEnd = null;

        // Finn tidligste startdato og siste sluttdato for alle kravlinjer, inkl. reisetider
        for (HOT_ClaimLineItem__c item : claimLineItems) {
            // Vanlige arbeidstider
            if (item.StartTime__c != null) {
                Date startDate = (item.StartTime__c != null) ? item.StartTime__c.date() : null;
                if (earliestStart == null || startDate < earliestStart)
                    earliestStart = startDate;
            }
            if (item.EndTime__c != null) {
                Date endDate = (item.EndTime__c != null) ? item.EndTime__c.date() : null;
                if (latestEnd == null || endDate > latestEnd)
                    latestEnd = endDate;
            }

            // Reisetider
            if (item.TravelFromStartTime__c != null) {
                Date travelStart = (item.TravelFromStartTime__c != null) ? item.TravelFromStartTime__c.date() : null;

                if (earliestStart == null || travelStart < earliestStart)
                    earliestStart = travelStart;
            }
            if (item.TravelFromEndTime__c != null) {
                Date travelEnd = (item.TravelFromEndTime__c != null) ? item.TravelFromEndTime__c.date() : null;

                if (latestEnd == null || travelEnd > latestEnd)
                    latestEnd = travelEnd;
            }
            if (item.TravelToStartTime__c != null) {
                Date travelStart = (item.TravelToStartTime__c != null) ? item.TravelToStartTime__c.date() : null;

                if (earliestStart == null || travelStart < earliestStart)
                    earliestStart = travelStart;
            }
            if (item.TravelToEndTime__c != null) {
                Date travelEnd = (item.TravelToEndTime__c != null) ? item.TravelToEndTime__c.date() : null;

                if (latestEnd == null || travelEnd > latestEnd)
                    latestEnd = travelEnd;
            }
        }

        // Hent alle relevante satser innenfor ytterpunktene
        List<HOT_Rate__c> rates = [
            SELECT Id, Type__c, Rate__c, ValidFrom__c, ValidTo__c, isActive__c
            FROM HOT_Rate__c
            WHERE isActive__c = TRUE
        ];

        Set<Id> claimIds = new Set<Id>();

        for (HOT_ClaimLineItem__c item : claimLineItems) {
            Decimal totalTravelPayout = 0;
            Decimal totalPayout = 0;
            Decimal totalExpenses = 0;
            Boolean missingRate = false;

            // DAG SATS
            if (
                item.DayHours__c != null &&
                item.DayHours__c > 0 &&
                item.StartTime__c != null &&
                item.EndTime__c != null
            ) {
                HOT_Rate__c rate = findRateForPeriod(rates, item.StartTime__c.date(), item.EndTime__c.date(), 'Dag');
                if (rate != null) {
                    totalPayout += item.DayHours__c * rate.Rate__c;
                } else {
                    missingRate = true;
                }
            }

            // KVELD OG HELG SATS
            if (
                item.EveningNightAndWeekendHours__c != null &&
                item.EveningNightAndWeekendHours__c > 0 &&
                item.StartTime__c != null &&
                item.EndTime__c != null
            ) {
                HOT_Rate__c rate = findRateForPeriod(
                    rates,
                    item.StartTime__c.date(),
                    item.EndTime__c.date(),
                    'Kveld/helg'
                );
                if (rate != null) {
                    totalPayout += item.EveningNightAndWeekendHours__c * rate.Rate__c;
                } else {
                    missingRate = true;
                }
            }

            // REISE SATS FRA
            /* MERKNAD: Ettersom det kun er mulig å ha reise på samme dag som oppdraget, at det 
            ikke er mulig å ha et oppdrag over flere dager, og travelhours allerede er rundet 
            opp og oppsummert, blir det dermed kun 1 reisesats (=, ikke +=) */
            if (item.TravelFromStartTime__c != null && item.TravelFromEndTime__c != null) {
                HOT_Rate__c travelFromRate = findRateForPeriod(
                    rates,
                    item.TravelFromStartTime__c.date(),
                    item.TravelFromEndTime__c.date(),
                    'Reisetid'
                );

                if (travelFromRate != null) {
                    totalTravelPayout = item.TravelHours__c * travelFromRate.Rate__c;
                } else {
                    missingRate = true;
                }
            }
            //KILOMETERGODTGJØRELSE
            Date travelStartDate;
            Date travelEndDate;

            if (item.TravelFromStartTime__c != null && item.TravelFromEndTime__c != null) {
                travelStartDate = item.TravelFromStartTime__c.date();
                travelEndDate = item.TravelFromEndTime__c.date();
            } else if (item.TravelToStartTime__c != null && item.TravelToEndTime__c != null) {
                travelStartDate = item.TravelToStartTime__c.date();
                travelEndDate = item.TravelToEndTime__c.date();
            }

            if (
                travelStartDate != null &&
                travelEndDate != null &&
                item.TravelDistance__c != null &&
                item.TravelDistance__c > 0
            ) {
                HOT_Rate__c travelDistanceRate = findRateForPeriod(
                    rates,
                    travelStartDate,
                    travelEndDate,
                    'Kjøregodtgjørelse'
                );
                if (travelDistanceRate != null) {
                    totalPayout = item.TravelDistance__c * travelDistanceRate.Rate__c;
                } else {
                    missingRate = true;
                }
            }

            // REISE SATS TIL
            if (item.TravelToStartTime__c != null && item.TravelToEndTime__c != null) {
                HOT_Rate__c travelToRate = findRateForPeriod(
                    rates,
                    item.TravelToStartTime__c.date(),
                    item.TravelToEndTime__c.date(),
                    'Reisetid'
                );

                if (travelToRate != null) {
                    totalTravelPayout = item.TravelHours__c * travelToRate.Rate__c;
                } else {
                    missingRate = true;
                }
            }
            if (item.SumUndocumentedExpenses__c != null) {
                totalExpenses = item.SumUndocumentedExpenses__c;
            }
            if (missingRate) {
                LoggerUtility logger = new LoggerUtility();
                logger.error(
                    'Kalkulering sats sum: Sats mangler for periodene til lesekravlinje ' + item,
                    null,
                    CRM_ApplicationDomain.Domain.HOT
                );
                logger.publish();
            }
            if (!missingRate && !isRecalculating) {
                item.Amount__c = totalPayout + totalTravelPayout + totalExpenses;
                claimIds.add(item.Claim__c);
            }
            if (!missingRate && isRecalculating) {
                item.DeltaAfterAdjustment__c = (totalPayout + totalTravelPayout) - item.Amount__c;
                claimIds.add(item.Claim__c);
            }
        }
        // Oppdater kravlinjer
        update claimLineItems;

        // Oppdater Claims
        List<HOT_Claim__c> claimsToUpdate = [
            SELECT Id, ProcessedRate__c, ReProcessedRate__c
            FROM HOT_Claim__c
            WHERE Id IN :claimIds
        ];

        for (HOT_Claim__c claim : claimsToUpdate) {
            if (!isRecalculating) {
                claim.ProcessedRate__c = true;
            } else {
                claim.ReProcessedRate__c = true;
            }
        }

        update claimsToUpdate;
    }

    private static HOT_Rate__c findRateForPeriod(
        List<HOT_Rate__c> allRates,
        Date startDate,
        Date endDate,
        String type
    ) {
        if (startDate == null || endDate == null) {
            return null;
        }

        // Gå gjennom alle satser
        for (HOT_Rate__c rate : allRates) {
            // Sjekk om satsen har riktig type OG at dens gyldighetsperiode
            if (rate.Type__c == type && rate.ValidFrom__c <= startDate && rate.ValidTo__c >= endDate) {
                return rate;
            }
        }
        return null;
    }
}
