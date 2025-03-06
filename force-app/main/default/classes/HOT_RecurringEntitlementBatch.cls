public class HOT_RecurringEntitlementBatch implements Database.Batchable<sObject>, Database.Stateful {
    private static String handleException(Exception e) {
        LoggerUtility logger = new LoggerUtility();
        logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
        logger.publishSynch();
        return e.getMessage();
    }
    private Integer totalEntitlementsToBeRecurred = 0;
    private Integer newEntitlementsCount = 0;
    private Integer notCreatedDueToDeathCount = 0;
    private Integer notCreatedDueToOverlapCount = 0;

    @InvocableMethod(
        label='Start Recurring Entitlement Batch Job'
        description='Starts the HOT_RecurringEntitlementBatch job'
    )
    public static void startBatchJob() {
        HOT_RecurringEntitlementBatch batchJob = new HOT_RecurringEntitlementBatch();
        Database.executeBatch(batchJob, 10);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, FromDate__c, ToDate__c, HasBeenRecurred__c, Type__c, Account__c, Account__r.CRM_Person__r.INT_IsDeceased__c FROM HOT_Entitlement__c WHERE HasBeenRecurred__c=false AND Type__c=\'Dagligliv\' AND Is_recurring__c=true AND AboutToExpire__c=true';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<HOT_Entitlement__c> records) {
        totalEntitlementsToBeRecurred += records.size();

        Set<Id> accountIds = new Set<Id>();
        for (HOT_Entitlement__c entitlement : records) {
            accountIds.add(entitlement.Account__c);
        }
        List<HOT_Entitlement__c> existingEntitlements = [
            SELECT
                Id,
                FromDate__c,
                ToDate__c,
                Type__c,
                HasBeenRecurred__c,
                Is_recurring__c,
                Account__c,
                Account__r.CRM_Person__r.INT_IsDeceased__c
            FROM HOT_Entitlement__c
            WHERE Account__c IN :accountIds
        ];
        Map<Id, List<HOT_Entitlement__c>> accountEntitlementMap = new Map<Id, List<HOT_Entitlement__c>>();
        for (HOT_Entitlement__c entitlement : existingEntitlements) {
            if (!accountEntitlementMap.containsKey(entitlement.Account__c)) {
                accountEntitlementMap.put(entitlement.Account__c, new List<HOT_Entitlement__c>());
            }
            accountEntitlementMap.get(entitlement.Account__c).add(entitlement);
        }
        List<HOT_Entitlement__c> newEntitlements = new List<HOT_Entitlement__c>();

        for (HOT_Entitlement__c existingEntitlement : records) {
            if (existingEntitlement.Account__r.CRM_Person__r.INT_IsDeceased__c == true) {
                existingEntitlement.Is_recurring__c = false;
                notCreatedDueToDeathCount++;
            } else {
                Date existingFromDate = existingEntitlement.FromDate__c;
                Integer nextYear = existingFromDate.year() + 1;
                Date newFromDate = Date.newInstance(nextYear, 1, 1);
                Date newToDate = Date.newInstance(nextYear, 12, 31);

                Boolean overlapExists = false;
                if (accountEntitlementMap.containsKey(existingEntitlement.Account__c)) {
                    for (HOT_Entitlement__c entitlement : accountEntitlementMap.get(existingEntitlement.Account__c)) {
                        if (
                            entitlement.Type__c == existingEntitlement.Type__c &&
                            ((newFromDate >= entitlement.FromDate__c &&
                            newFromDate <= entitlement.ToDate__c) ||
                            (newToDate >= entitlement.FromDate__c &&
                            newToDate <= entitlement.ToDate__c) ||
                            (newFromDate <= entitlement.FromDate__c &&
                            newToDate >= entitlement.ToDate__c))
                        ) {
                            overlapExists = true;
                            notCreatedDueToOverlapCount++;
                            break;
                        }
                    }
                }
                if (!overlapExists) {
                    HOT_Entitlement__c newEntitlement = new HOT_Entitlement__c();
                    newEntitlement.FromDate__c = newFromDate;
                    newEntitlement.ToDate__c = newToDate;
                    newEntitlement.EntitledHours__c = 120;
                    newEntitlement.Type__c = existingEntitlement.Type__c;
                    newEntitlement.Account__c = existingEntitlement.Account__c;
                    newEntitlement.Is_recurring__c = true;
                    newEntitlements.add(newEntitlement);
                    existingEntitlement.HasBeenRecurred__c = true;
                }
            }
        }
        try {
            update records;
        } catch (Exception e) {
            handleException(e);
        }

        if (!newEntitlements.isEmpty()) {
            try {
                insert newEntitlements;
                newEntitlementsCount += newEntitlements.size();
            } catch (Exception e) {
                handleException(e);
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        List<User> navUsers = [
            SELECT Id
            FROM User
            WHERE Id IN (SELECT userorgroupid FROM groupmember WHERE group.name = 'HOT LOS Saksbehandler')
        ];
        for (User user : navUsers) {
            Set<String> recipients = new Set<String>();
            recipients.add(user.Id);
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('Batch ferdig');
            notification.setBody(
                'Antall vedtak som skal fornyes: ' +
                    totalEntitlementsToBeRecurred +
                    '\n\nAntall vedtak opprettet: ' +
                    newEntitlementsCount +
                    '\nAntall vedtak ikke opprettet pga dødsfall: ' +
                    notCreatedDueToDeathCount +
                    '\nAntall vedtak ikke opprettet pga overlappende tider: ' +
                    notCreatedDueToOverlapCount
            );
            notification.setNotificationTypeId(getCustomNotificationType('HOT_RecurringEntitlementJob').Id);
            String landingpage =
                '{' +
                '  "type": "standard__objectPage", ' +
                '  "attributes": { ' +
                '    "objectApiName": "HOT_Entitlement__c", ' +
                '    "actionName": "list" ' +
                '  }' +
                '}';
            notification.setTargetPageRef(landingpage);
            sendNotification(notification, recipients, (SObject) user);
        }
    }
    public static CustomNotificationType getCustomNotificationType(String devName) {
        CustomNotificationType notificationType = [
            SELECT Id, DeveloperName
            FROM CustomNotificationType
            WHERE DeveloperName = :devName
        ];
        return notificationType;
    }
    public static void sendNotification(
        Messaging.CustomNotification notification,
        Set<String> recipients,
        SObject record
    ) {
        LoggerUtility logger = new LoggerUtility();

        if (recipients != null && recipients.size() > 0) {
            try {
                notification.send(recipients);
            } catch (Exception e) {
                handleException(e);
            }
        }
    }
}
