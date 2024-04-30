public without sharing class HOT_CreateClaimLineItem {
    @InvocableVariable
    public String claimId;
    @InvocableVariable
    public Datetime startDate;
    @InvocableVariable
    public Datetime endDate;
    @InvocableVariable
    public String recurringType;
    @InvocableVariable
    public Boolean monday;
    @InvocableVariable
    public Boolean tuesday;
    @InvocableVariable
    public Boolean wednesday;
    @InvocableVariable
    public Boolean thursday;
    @InvocableVariable
    public Boolean friday;
    @InvocableVariable
    public Boolean saturday;
    @InvocableVariable
    public Boolean sunday;
    @InvocableVariable
    public Date recurringEndDate;
    @InvocableVariable
    public Datetime travelToStartDate;
    @InvocableVariable
    public Datetime travelToEndDate;
    @InvocableVariable
    public Datetime travelFromStartDate;
    @InvocableVariable
    public Datetime travelFromEndDate;
    @InvocableVariable
    public Boolean hasTraveledTo;
    @InvocableVariable
    public Boolean hasTraveledFrom;
    @InvocableVariable
    public Integer distanceTraveled;

    @InvocableMethod
    public static List<String> createClaimLineItems(List<HOT_CreateClaimLineItem> inputVariables) {
        HOT_CreateClaimLineItem input = inputVariables[0];
        Integer maxNumberOfRecurrences = 200;
        List<String> errors = new List<String>();
        LoggerUtility logger = new LoggerUtility();

        HOT_Claim__c claim = new HOT_Claim__c(Id = input.claimId);

        TimeZone tz = UserInfo.getTimeZone();
        Datetime oldStartDate = input.startDate;
        if (input.endDate <= input.startDate) {
            errors.add('Slutt tid må være etter start tid.');
            return errors;
        }

        if (input.recurringType != 'Never' && input.recurringEndDate <= input.startDate.date()) {
            errors.add('Sluttdato må være etter startdato.');
            return errors;
        }

        if (
            (input.recurringType == 'Weekly' ||
            input.recurringType == 'Biweekly') &&
            !input.monday &&
            !input.tuesday &&
            !input.wednesday &&
            !input.thursday &&
            !input.friday &&
            !input.saturday &&
            !input.sunday
        ) {
            errors.add('Må velge minst en dag.');
            return errors;
        }

        if (input.recurringType == 'Never') {
            HOT_ClaimLineItem__c claimLineItem = new HOT_ClaimLineItem__c(
                Claim__c = input.claimId,
                StartTime__c = input.startDate,
                EndTime__c = input.endDate,
                TravelFromEndTime__c = input.travelFromEndDate,
                TravelFromStartTime__c = input.travelFromStartDate,
                TravelToEndTime__c = input.travelToEndDate,
                TravelToStartTime__c = input.travelToStartDate,
                HasTravelTo__c = input.hasTraveledTo,
                HasTravelFrom__c = input.hasTraveledFrom,
                TravelDistance__c = input.distanceTraveled
            );

            try {
                insert claimLineItem;
            } catch (Exception e) {
                errors.add('Opprettelsen av lesekravslinje feilet.');
                logger.exception(e, claim, CRM_ApplicationDomain.Domain.HOT);
                logger.publishSynch();
            }

            return errors;
        } else if (input.recurringType == 'Daily') {
            List<HOT_ClaimLineItem__c> claimLineItems = new List<HOT_ClaimLineItem__c>();
            Integer numberOfRecurrences = input.startDate.date().daysBetween(input.recurringEndDate);

            if (numberOfRecurrences > maxNumberOfRecurrences) {
                errors.add('Kan ikke opprette flere enn 200 lesekravslinjer av gangen');
                return errors;
            }

            for (Integer i = 0; i <= numberOfRecurrences; i++) {
                Datetime startDate = input.startDate.addDays(i);
                Datetime endDate = input.endDate.addDays(i);
                Datetime travelFromStartDate = input.travelFromStartDate?.addDays(i);
                Datetime travelFromEndDate = input.travelFromEndDate?.addDays(i);
                Datetime travelToStartDate = input.travelToStartDate?.addDays(i);
                Datetime travelToEndDate = input.travelToEndDate?.addDays(i);
                Integer os = tz.getOffset(startDate) - tz.getOffset(oldStartDate);
                startDate = startDate.addHours(-os / 3600000);
                endDate = endDate.addHours(-os / 3600000);
                travelFromStartDate = travelFromStartDate?.addHours(-os / 3600000);
                travelFromEndDate = travelFromEndDate?.addHours(-os / 3600000);
                travelToStartDate = travelToStartDate?.addHours(-os / 3600000);
                travelToEndDate = travelToEndDate?.addHours(-os / 3600000);

                HOT_ClaimLineItem__c claimLineItem = new HOT_ClaimLineItem__c(
                    Claim__c = input.claimId,
                    StartTime__c = startDate,
                    EndTime__c = endDate,
                    TravelFromEndTime__c = travelFromEndDate,
                    TravelFromStartTime__c = travelFromStartDate,
                    TravelToEndTime__c = travelToEndDate,
                    TravelToStartTime__c = travelToStartDate,
                    HasTravelTo__c = input.hasTraveledTo,
                    HasTravelFrom__c = input.hasTraveledFrom,
                    TravelDistance__c = input.distanceTraveled
                );
                claimLineItems.add(claimLineItem);
            }

            try {
                insert claimLineItems;
            } catch (Exception e) {
                errors.add('Opprettelsen av arbeidsordrene feilet.');
                logger.exception(e, claim, CRM_ApplicationDomain.Domain.HOT);
                logger.publishSynch();
            }

            return errors;
        } else if (input.recurringType == 'Weekly') {
            List<HOT_ClaimLineItem__c> claimLineItems = new List<HOT_ClaimLineItem__c>();
            Integer numberOfRecurrences = input.startDate.date().daysBetween(input.recurringEndDate);

            for (Integer i = 0; i <= numberOfRecurrences; i++) {
                Datetime startDate = input.startDate.addDays(i);
                Datetime endDate = input.endDate.addDays(i);
                Datetime travelFromStartDate = input.travelFromStartDate?.addDays(i);
                Datetime travelFromEndDate = input.travelFromEndDate?.addDays(i);
                Datetime travelToStartDate = input.travelToStartDate?.addDays(i);
                Datetime travelToEndDate = input.travelToEndDate?.addDays(i);
                String dayOfWeek = startDate.format('EEEE');
                Integer os = tz.getOffset(startDate) - tz.getOffset(oldStartDate);
                startDate = startDate.addHours(-os / 3600000);
                endDate = endDate.addHours(-os / 3600000);
                travelFromStartDate = travelFromStartDate?.addHours(-os / 3600000);
                travelFromEndDate = travelFromEndDate?.addHours(-os / 3600000);
                travelToStartDate = travelToStartDate?.addHours(-os / 3600000);
                travelToEndDate = travelToEndDate?.addHours(-os / 3600000);

                System.debug('dayOfWeek: ' + dayOfWeek);
                if (
                    input.monday && dayOfWeek == 'Monday' ||
                    input.tuesday && dayOfWeek == 'Tuesday' ||
                    input.wednesday && dayOfWeek == 'Wednesday' ||
                    input.thursday && dayOfWeek == 'Thursday' ||
                    input.friday && dayOfWeek == 'Friday' ||
                    input.saturday && dayOfWeek == 'Saturday' ||
                    input.sunday && dayOfWeek == 'Sunday'
                ) {
                    HOT_ClaimLineItem__c claimLineItem = new HOT_ClaimLineItem__c(
                        Claim__c = input.claimId,
                        StartTime__c = startDate,
                        EndTime__c = endDate,
                        TravelFromEndTime__c = travelFromEndDate,
                        TravelFromStartTime__c = travelFromStartDate,
                        TravelToEndTime__c = travelToEndDate,
                        TravelToStartTime__c = travelToStartDate,
                        HasTravelTo__c = input.hasTraveledTo,
                        HasTravelFrom__c = input.hasTraveledFrom,
                        TravelDistance__c = input.distanceTraveled
                    );
                    claimLineItems.add(claimLineItem);
                }
            }

            if (claimLineItems.size() > maxNumberOfRecurrences) {
                errors.add('Kan ikke opprette mer enn 200 lesekravslinjer av gangen');
                return errors;
            }

            try {
                insert claimLineItems;
            } catch (Exception e) {
                errors.add('Opprettelsen av lesekravslinje feilet.');
                logger.exception(e, claim, CRM_ApplicationDomain.Domain.HOT);
                logger.publishSynch();
            }

            return errors;
        } else if (input.recurringType == 'Biweekly') {
            List<HOT_ClaimLineItem__c> claimLineItems = new List<HOT_ClaimLineItem__c>();
            Integer numberOfRecurrences = input.startDate.date().daysBetween(input.recurringEndDate);

            for (Integer i = 0; i <= numberOfRecurrences; i++) {
                Datetime startDate = input.startDate.addDays(i);
                Datetime endDate = input.endDate.addDays(i);
                Datetime travelFromStartDate = input.travelFromStartDate?.addDays(i);
                Datetime travelFromEndDate = input.travelFromEndDate?.addDays(i);
                Datetime travelToStartDate = input.travelToStartDate?.addDays(i);
                Datetime travelToEndDate = input.travelToEndDate?.addDays(i);
                String dayOfWeek = startDate.format('EEEE');
                Integer os = tz.getOffset(startDate) - tz.getOffset(oldStartDate);
                startDate = startDate.addHours(-os / 3600000);
                endDate = endDate.addHours(-os / 3600000);
                travelFromStartDate = travelFromStartDate?.addHours(-os / 3600000);
                travelFromEndDate = travelFromEndDate?.addHours(-os / 3600000);
                travelToStartDate = travelToStartDate?.addHours(-os / 3600000);
                travelToEndDate = travelToEndDate?.addHours(-os / 3600000);

                System.debug('dayOfWeek: ' + dayOfWeek);
                if (
                    input.monday && dayOfWeek == 'Monday' ||
                    input.tuesday && dayOfWeek == 'Tuesday' ||
                    input.wednesday && dayOfWeek == 'Wednesday' ||
                    input.thursday && dayOfWeek == 'Thursday' ||
                    input.friday && dayOfWeek == 'Friday' ||
                    input.saturday && dayOfWeek == 'Saturday' ||
                    input.sunday && dayOfWeek == 'Sunday'
                ) {
                    HOT_ClaimLineItem__c claimLineItem = new HOT_ClaimLineItem__c(
                        Claim__c = input.claimId,
                        StartTime__c = startDate,
                        EndTime__c = endDate,
                        TravelFromEndTime__c = travelFromEndDate,
                        TravelFromStartTime__c = travelFromStartDate,
                        TravelToEndTime__c = travelToEndDate,
                        TravelToStartTime__c = travelToStartDate,
                        HasTravelTo__c = input.hasTraveledTo,
                        HasTravelFrom__c = input.hasTraveledFrom,
                        TravelDistance__c = input.distanceTraveled
                    );
                    claimLineItems.add(claimLineItem);
                }
                if (dayOfWeek == 'Sunday') {
                    i = i + 7;
                }
            }

            if (claimLineItems.size() > maxNumberOfRecurrences) {
                errors.add('Kan ikke opprette mer enn 200 lesekravslinjer av gangen');
                return errors;
            }

            try {
                insert claimLineItems;
            } catch (Exception e) {
                errors.add('Opprettelsen av lesekravslinjer feilet.');
                logger.exception(e, claim, CRM_ApplicationDomain.Domain.HOT);
                logger.publishSynch();
            }

            return errors;
        }
        return errors;
    }
}
