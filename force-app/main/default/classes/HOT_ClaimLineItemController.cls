public without sharing class HOT_ClaimLineItemController {
    @AuraEnabled(cacheable=false)
    public static List<HOT_ClaimLineItem__c> getClaimLineItems(String recordId) {
        User currentUser = [SELECT Id, AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        Set<String> groupNames = new Set<String>();
        for (GroupMember groupmember : [
            SELECT group.name
            FROM GroupMember
            WHERE UserOrGroupId = :currentUser.Id
        ]) {
            groupNames.add(groupmember.group.name);
        }
        if (groupNames.contains('HOT LOS Saksbehandler')) {
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
        } else {
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
                WHERE
                    Claim__c = :recordId
                    AND (Claim__r.Claimant__c = :currentUser.AccountId
                    OR Claim__r.Account__c = :currentUser.AccountId)
                ORDER BY Date__c ASC
            ];
            return claimLineItems;
        }
    }
    @AuraEnabled(cacheable=false)
    public static List<HOT_ClaimLineItem__c> getMyClaimLineItems(String recordId) {
        User currentUser = [SELECT Id, AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        List<HOT_ClaimLineItem__c> claimLineItems = [
            SELECT
                Id,
                Name,
                Date__c,
                StartTime__c,
                EndTime__c,
                HasTravelTo__c,
                HasTravelFrom__c,
                TravelFromEndTime__c,
                TravelFromStartTime__c,
                TravelTo__c,
                TravelToEndTime__c,
                TravelToStartTime__c
            FROM HOT_ClaimLineItem__c
            WHERE
                Claim__r.Claimant__c = :currentUser.AccountId
                AND Claim__r.Status__c != 'Withdrawn'
                AND Claim__r.Id != :recordId
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
                OverlappingClaimLineItemsIds__c,
                DayHours__c,
                EveningNightAndWeekendHours__c,
                TravelHours__c
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
    public static void calculateHoursOnRates(List<HOT_ClaimLineItem__c> claimLineItems) {
        // Hent alle holidays
        List<Holiday> holidayList = [
            SELECT ActivityDate, RecurrenceType
            FROM Holiday
        ];

        for (HOT_ClaimLineItem__c claimLineItem : claimLineItems) {
            Date claimDate = claimLineItem.StartTime__c.date();
            DateTime claimDateTime = claimLineItem.StartTime__c;

            Boolean isSunday = (claimDateTime.format('EEEE') == 'Sunday');
            Boolean isSaturday = (claimDateTime.format('EEEE') == 'Saturday');

            Integer travelToMinutes = 0;
            Integer travelFromMinutes = 0;

            if (claimLineItem.HasTravelTo__c) {
                travelToMinutes += calculateTravelMinutes(
                    claimLineItem.TravelToStartTime__c,
                    claimLineItem.TravelToEndTime__c
                );
            }
            if (claimLineItem.HasTravelFrom__c) {
                travelFromMinutes += calculateTravelMinutes(
                    claimLineItem.TravelFromStartTime__c,
                    claimLineItem.TravelFromEndTime__c
                );
            }

            Integer totalTravelMinutes = travelToMinutes + travelFromMinutes;
            Integer roundedTotalTravelMinutes = roundMinutes(totalTravelMinutes);
            claimLineItem.TravelHours__c = roundedTotalTravelMinutes / 60.0;

            Boolean isHoliday = false;
            Boolean isDayBeforeHoliday = false;

            for (Holiday holiday : holidayList) {
                Date holidayDate = holiday.ActivityDate;

                if (holiday.RecurrenceType == 'RecursYearly') {
                    // Samme dag + måned
                    if (holidayDate.month() == claimDate.month() && holidayDate.day() == claimDate.day()) {
                        isHoliday = true;
                    }

                    // Dagen før recurring holiday
                    Date recurringThisYear = Date.newInstance(claimDate.year(), holidayDate.month(), holidayDate.day());
                    if (recurringThisYear.addDays(-1) == claimDate) {
                        isDayBeforeHoliday = true;
                    }
                } else {
                    // Ikke-recurring holiday
                    if (holidayDate == claimDate) {
                        isHoliday = true;
                    }
                    if (holidayDate.addDays(-1) == claimDate) {
                        isDayBeforeHoliday = true;
                    }
                }
            }
            if (isHoliday || isSunday) {
                calculateHours(claimLineItem, true, false);
            } else if (isSaturday || isDayBeforeHoliday) {
                calculateHours(claimLineItem, false, true);
            } else {
                calculateHours(claimLineItem, false, false);
            }
        }
    }

    public static void calculateHours(
        HOT_ClaimLineItem__c claimLineItem,
        Boolean isHoliday,
        Boolean isSaturdayOrDayBeforeHoliday
    ) {
        if (isHoliday) {
            Time startTime = claimLineItem.StartTime__c.time();
            Time endTime = claimLineItem.EndTime__c.time();

            Integer totalMinutes = ((endTime.hour() * 60 + endTime.minute()) -
            (startTime.hour() * 60 + startTime.minute()));

            Integer roundedMinutes = roundMinutes(totalMinutes);

            Double holidayHours = roundedMinutes / 60.0;

            claimLineItem.EveningNightAndWeekendHours__c = (roundedMinutes > 0) ? holidayHours : 0;
            claimLineItem.DayHours__c = 0;
        } else if (!isHoliday && !isSaturdayOrDayBeforeHoliday) {
            Time startOfWorkHours = Time.newInstance(8, 0, 0, 0);
            Time endOfWorkHours = Time.newInstance(17, 0, 0, 0);

            Time startTime = claimLineItem.StartTime__c.time();
            Time endTime = claimLineItem.EndTime__c.time();

            Integer normalMinutes = 0;
            Integer overtimeMinutes = 0;

            if (startTime < startOfWorkHours) {
                Time overtimeEnd = endTime > startOfWorkHours ? startOfWorkHours : endTime;
                overtimeMinutes += ((overtimeEnd.hour() * 60 + overtimeEnd.minute()) -
                (startTime.hour() * 60 + startTime.minute()));
                startTime = overtimeEnd;
            }

            if (startTime < endOfWorkHours && endTime > startOfWorkHours) {
                Time normalStart = startTime > startOfWorkHours ? startTime : startOfWorkHours;
                Time normalEnd = endTime < endOfWorkHours ? endTime : endOfWorkHours;

                normalMinutes = ((normalEnd.hour() * 60 + normalEnd.minute()) -
                (normalStart.hour() * 60 + normalStart.minute()));
            }

            if (endTime > endOfWorkHours) {
                Time overtimeStart = startTime > endOfWorkHours ? startTime : endOfWorkHours;
                overtimeMinutes += ((endTime.hour() * 60 + endTime.minute()) -
                (overtimeStart.hour() * 60 + overtimeStart.minute()));
            }

            Integer roundedNormalMinutes = roundMinutes(normalMinutes);
            Integer roundedOvertimeMinutes = roundMinutes(overtimeMinutes);

            Double normalHours = roundedNormalMinutes / 60.0;
            Double overtimeHours = roundedOvertimeMinutes / 60.0;

            claimLineItem.DayHours__c = (roundedNormalMinutes > 0) ? normalHours : 0;
            claimLineItem.EveningNightAndWeekendHours__c = (roundedOvertimeMinutes > 0) ? overtimeHours : 0;
        } else if (isSaturdayOrDayBeforeHoliday) {
            Time startOfWorkHours = Time.newInstance(8, 0, 0, 0);
            Time endOfWorkHours = Time.newInstance(14, 0, 0, 0);

            Time startTime = claimLineItem.StartTime__c.time();
            Time endTime = claimLineItem.EndTime__c.time();

            Integer normalMinutes = 0;
            Integer overtimeMinutes = 0;

            if (startTime < endOfWorkHours && endTime > startOfWorkHours) {
                Time normalStart = startTime > startOfWorkHours ? startTime : startOfWorkHours;
                Time normalEnd = endTime < endOfWorkHours ? endTime : endOfWorkHours;

                normalMinutes = ((normalEnd.hour() * 60 + normalEnd.minute()) -
                (normalStart.hour() * 60 + normalStart.minute()));
            }

            if (startTime < startOfWorkHours) {
                Time overtimeEnd = endTime > startOfWorkHours ? startOfWorkHours : endTime;
                overtimeMinutes += ((overtimeEnd.hour() * 60 + overtimeEnd.minute()) -
                (startTime.hour() * 60 + startTime.minute()));
            }
            if (endTime > endOfWorkHours) {
                Time overtimeStart = startTime > endOfWorkHours ? startTime : endOfWorkHours;
                overtimeMinutes += ((endTime.hour() * 60 + endTime.minute()) -
                (overtimeStart.hour() * 60 + overtimeStart.minute()));
            }

            Integer roundedNormalMinutes = roundMinutes(normalMinutes);
            Integer roundedOvertimeMinutes = roundMinutes(overtimeMinutes);

            Double normalHours = roundedNormalMinutes / 60.0;
            Double overtimeHours = roundedOvertimeMinutes / 60.0;

            claimLineItem.DayHours__c = (roundedNormalMinutes > 0) ? normalHours : 0;
            claimLineItem.EveningNightAndWeekendHours__c = (roundedOvertimeMinutes > 0) ? overtimeHours : 0;
        }
    }

    public static Integer roundMinutes(Integer minutes) {
        if (minutes == 0) {
            return 0;
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

    public static Integer calculateTravelMinutes(DateTime startTime, DateTime endTime) {
        Integer travelMinutes = 0;
        if (startTime != null && endTime != null) {
            travelMinutes = ((endTime.hour() * 60 + endTime.minute()) - (startTime.hour() * 60 + startTime.minute()));
        }
        return travelMinutes;
    }
}
