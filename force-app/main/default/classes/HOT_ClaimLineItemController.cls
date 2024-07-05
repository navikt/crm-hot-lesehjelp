public without sharing class HOT_ClaimLineItemController {
    @AuraEnabled(cacheable=false)
    public static List<HOT_ClaimLineItem__c> getClaimLineItems(String recordId) {
        List<HOT_ClaimLineItem__c> claimLineItems = [
            SELECT
                Id,
                Name,
                Date__c,
                StartTime__c,
                EndTime__c,
                HasTravelTo__c,
                HasTravelFrom__c,
                NumberOfHours__c,
                TravelFromEndTime__c,
                TravelFromStartTime__c,
                TravelTo__c,
                TravelToEndTime__c,
                TravelToStartTime__c,
                TypeOfTask__c,
                Weekday__c,
                AdditionalInformation__c,
                TravelDistance__c,
                ExpensesParking__c,
                ExpensesPublicTransport__c,
                ExpensesToll__c,
                PublicTransportRoute__c,
                ParkingAddress__c,
                TravelToFromAddresses__c,
                OverlappingClaimLineItemsIds__c
            FROM HOT_ClaimLineItem__c
            WHERE Claim__c = :recordId
            ORDER BY Date__c ASC
        ];
        return claimLineItems;
    }
    @AuraEnabled(cacheable=false)
    public static List<HOT_ClaimLineItem__c> checkForOverlapClaimLineItem(String recordId) {
        List<HOT_ClaimLineItem__c> claimLineItemsToReturn = [
            SELECT
                Id,
                Name,
                Claimant__c,
                Date__c,
                StartTime__c,
                EndTime__c,
                HasTravelTo__c,
                HasTravelFrom__c,
                NumberOfHours__c,
                TravelFromEndTime__c,
                TravelFromStartTime__c,
                TravelTo__c,
                TravelToEndTime__c,
                TravelToStartTime__c,
                TypeOfTask__c,
                Weekday__c,
                AdditionalInformation__c,
                TravelDistance__c,
                ExpensesParking__c,
                ExpensesPublicTransport__c,
                ExpensesToll__c,
                PublicTransportRoute__c,
                ParkingAddress__c,
                TravelToFromAddresses__c,
                OverlappingClaimLineItemsIds__c
            FROM HOT_ClaimLineItem__c
            WHERE Claim__c = :recordId
        ];

        List<HOT_ClaimLineItem__c> claimLineItemsToCheckForOverlap = [
            SELECT
                Id,
                Name,
                StartTime__c,
                EndTime__c,
                HasTravelTo__c,
                HasTravelFrom__c,
                TravelFromEndTime__c,
                TravelFromStartTime__c,
                TravelTo__c,
                TravelToEndTime__c,
                TravelToStartTime__c,
                OverlappingClaimLineItemsIds__c
            FROM HOT_ClaimLineItem__c
            WHERE Claim__r.Claimant__c = :claimLineItemsToReturn[0].Claimant__c AND Claim__r.Status__c != 'Withdrawn'
        ];

        for (HOT_ClaimLineItem__c cli : claimLineItemsToReturn) {
            for (HOT_ClaimLineItem__c cli2 : claimLineItemsToCheckForOverlap) {
                if (
                    (cli.StartTime__c < cli2.EndTime__c &&
                    cli.EndTime__c > cli2.StartTime__c &&
                    cli.Id != cli2.Id) ||
                    (cli.StartTime__c < cli2.TravelToEndTime__c &&
                    cli.EndTime__c > cli2.TravelToStartTime__c &&
                    cli2.HasTravelTo__c == true &&
                    cli.Id != cli2.Id) ||
                    cli.StartTime__c < cli2.TravelFromEndTime__c &&
                    cli.EndTime__c > cli2.TravelFromStartTime__c &&
                    cli2.HasTravelFrom__c == true && cli.Id != cli2.Id
                ) {
                    if (cli.OverlappingClaimLineItemsIds__c == null || cli.OverlappingClaimLineItemsIds__c == '') {
                        cli.OverlappingClaimLineItemsIds__c = '' + cli2.Id + ',' + cli2.Name;
                    } else if (!cli.OverlappingClaimLineItemsIds__c.contains(cli2.Id)) {
                        cli.OverlappingClaimLineItemsIds__c += ',' + cli2.Id + ',' + cli2.Name;
                    }
                }
                if (
                    (cli.TravelToStartTime__c < cli2.EndTime__c &&
                    cli.TravelToEndTime__c > cli2.StartTime__c &&
                    cli.HasTravelTo__c == true &&
                    cli.Id != cli2.Id) ||
                    (cli.TravelToStartTime__c < cli2.TravelToEndTime__c &&
                    cli.TravelToEndTime__c > cli2.TravelToStartTime__c &&
                    cli.HasTravelTo__c == true &&
                    cli2.HasTravelTo__c == true &&
                    cli.Id != cli2.Id) ||
                    (cli.TravelToStartTime__c < cli2.TravelFromEndTime__c &&
                    cli.TravelToEndTime__c > cli2.TravelFromStartTime__c &&
                    cli.HasTravelTo__c == true &&
                    cli2.HasTravelFrom__c == true &&
                    cli.Id != cli2.Id)
                ) {
                    if (cli.OverlappingClaimLineItemsIds__c == null || cli.OverlappingClaimLineItemsIds__c == '') {
                        cli.OverlappingClaimLineItemsIds__c = '' + cli2.Id + ',' + cli2.Name;
                    } else if (!cli.OverlappingClaimLineItemsIds__c.contains(cli2.Id)) {
                        cli.OverlappingClaimLineItemsIds__c += ',' + cli2.Id + ',' + cli2.Name;
                    }
                }
                if (
                    (cli.TravelFromStartTime__c < cli2.EndTime__c &&
                    cli.TravelFromEndTime__c > cli2.StartTime__c &&
                    cli.HasTravelFrom__c == true &&
                    cli.Id != cli2.Id) ||
                    (cli.TravelFromStartTime__c < cli2.TravelToEndTime__c &&
                    cli.TravelFromEndTime__c > cli2.TravelToStartTime__c &&
                    cli.HasTravelFrom__c == true &&
                    cli2.HasTravelTo__c == true &&
                    cli.Id != cli2.Id) ||
                    (cli.TravelFromStartTime__c < cli2.TravelFromEndTime__c &&
                    cli.TravelFromEndTime__c > cli2.TravelFromStartTime__c &&
                    cli.HasTravelFrom__c == true &&
                    cli2.HasTravelFrom__c == true &&
                    cli.Id != cli2.Id)
                ) {
                    if (cli.OverlappingClaimLineItemsIds__c == null || cli.OverlappingClaimLineItemsIds__c == '') {
                        cli.OverlappingClaimLineItemsIds__c = '' + cli2.Id + ',' + cli2.Name;
                    } else if (!cli.OverlappingClaimLineItemsIds__c.contains(cli2.Id)) {
                        cli.OverlappingClaimLineItemsIds__c += ',' + cli2.Id + ',' + cli2.Name;
                    }
                }
            }
        }
        return claimLineItemsToReturn;
    }
    public static void calculateSatses(List<HOT_ClaimLineItem__c> claimLineItems) {
        List<Holiday> holidayList = [SELECT ActivityDate, RecurrenceType FROM Holiday];
        Set<Date> holidayDates = new Set<Date>();
        for (Holiday holiday : holidayList) {
            holidayDates.add(holiday.ActivityDate);
        }

        for (HOT_ClaimLineItem__c claimLineItem : claimLineItems) {
            if (holidayDates.contains(claimLineItem.StartTime__c.date())) {
                // Process for holidays
                calculateHours(claimLineItem, true);
            } else {
                // Process for non-holidays
                calculateHours(claimLineItem, false);
            }
        }
        // Perform DML update on the list of claimLineItems
        update claimLineItems;
    }

    public static void calculateHours(HOT_ClaimLineItem__c claimLineItem, Boolean isHoliday) {
        // Define working hours
        if (!isHoliday) {
            Time startOfWorkHours = Time.newInstance(8, 0, 0, 0);
            Time endOfWorkHours = Time.newInstance(17, 0, 0, 0);

            // Extract start and end times
            Time startTime = claimLineItem.StartTime__c.time();
            Time endTime = claimLineItem.EndTime__c.time();

            Integer normalMinutes = 0;
            Integer overtimeMinutes = 0;

            // Calculate overtime minutes before working hours
            if (startTime < startOfWorkHours) {
                Time overtimeEnd = endTime > startOfWorkHours ? startOfWorkHours : endTime;
                overtimeMinutes += ((overtimeEnd.hour() * 60 + overtimeEnd.minute()) -
                (startTime.hour() * 60 + startTime.minute()));
                startTime = overtimeEnd;
            }

            // Calculate normal working hours minutes
            if (startTime < endOfWorkHours && endTime > startOfWorkHours) {
                Time normalStart = startTime > startOfWorkHours ? startTime : startOfWorkHours;
                Time normalEnd = endTime < endOfWorkHours ? endTime : endOfWorkHours;

                normalMinutes = ((normalEnd.hour() * 60 + normalEnd.minute()) -
                (normalStart.hour() * 60 + normalStart.minute()));
            }

            // Calculate overtime minutes after working hours
            if (endTime > endOfWorkHours) {
                Time overtimeStart = startTime > endOfWorkHours ? startTime : endOfWorkHours;
                overtimeMinutes += ((endTime.hour() * 60 + endTime.minute()) -
                (overtimeStart.hour() * 60 + overtimeStart.minute()));
            }

            // Apply rounding rules
            Integer roundedNormalMinutes = roundMinutes(normalMinutes);
            Integer roundedOvertimeMinutes = roundMinutes(overtimeMinutes);

            // Convert rounded minutes to hours
            Double normalHours = roundedNormalMinutes / 60.0;
            Double overtimeHours = roundedOvertimeMinutes / 60.0;

            // Set the calculated values on the claim line item
            claimLineItem.DayHours__c = (roundedNormalMinutes > 0) ? normalHours : 0;
            claimLineItem.EveningNightAndWeekendHours__c = (roundedOvertimeMinutes > 0) ? overtimeHours : 0;
        } else if (isHoliday) {
            // Extract start and end times
            Time startTime = claimLineItem.StartTime__c.time();
            Time endTime = claimLineItem.EndTime__c.time();

            // Calculate total minutes worked
            Integer totalMinutes = ((endTime.hour() * 60 + endTime.minute()) -
            (startTime.hour() * 60 + startTime.minute()));

            // Apply rounding rules
            Integer roundedMinutes = roundMinutes(totalMinutes);

            // Convert rounded minutes to hours
            Double holidayHours = roundedMinutes / 60.0;

            // Set the calculated values on the claim line item
            claimLineItem.EveningNightAndWeekendHours__c = (roundedMinutes > 0) ? holidayHours : 0;
        }
    }

    public static Integer roundMinutes(Integer minutes) {
        if (minutes == 0) {
            return 0; // No rounding needed if there are zero minutes
        }
        Integer remainder = Math.mod(minutes, 30);
        Integer roundedMinutes;

        if (remainder == 0) {
            roundedMinutes = minutes;
        } else {
            roundedMinutes = minutes + (30 - remainder);
        }

        return roundedMinutes;
    }
}
