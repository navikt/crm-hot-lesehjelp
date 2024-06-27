public without sharing class HOT_ClaimNotificationService {
    @Future
    public static void NotifyNAVNoEntitlementOnUser(List<Id> claimIds) {
        List<HOT_Claim__c> claims = [
            SELECT Id, Name, Account__c
            FROM HOT_Claim__c
            WHERE Id IN :claimIds
        ];
        Set<Id> accountIds = new Set<Id>();
        Map<Id, HOT_Claim__c> claimMap = new Map<Id, HOT_Claim__c>();
        for (HOT_Claim__c claim : claims) {
            accountIds.add(claim.Account__c);
            claimMap.put(claim.Account__c, claim);
        }
        List<HOT_Entitlement__c> entitlements = [
            SELECT Id, Account__c
            FROM HOT_Entitlement__c
            WHERE Account__c IN :accountIds
        ];

        Set<Id> entitledAccountIds = new Set<Id>();
        for (HOT_Entitlement__c entitlement : entitlements) {
            entitledAccountIds.add(entitlement.Account__c);
        }
        List<User> navUsers = [
            SELECT Id
            FROM User
            WHERE Id IN (SELECT userorgroupid FROM groupmember WHERE group.name = 'HOT LOS Saksbehandler')
        ];

        for (Id accountId : accountIds) {
            if (!entitledAccountIds.contains(accountId)) {
                HOT_Claim__c claim = claimMap.get(accountId);
                if (claim != null) {
                    for (User user : navUsers) {
                        Set<String> recipients = new Set<String>();
                        recipients.add(user.Id);
                        Messaging.CustomNotification notification = new Messaging.CustomNotification();
                        notification.setTitle('Lesehjelp har sendt inn krav på en bruker som ikke har noen vedtak');
                        notification.setBody('Legg på vedtak på brukeren');
                        notification.setNotificationTypeId(getCustomNotificationType('HOT_ClaimNotification').Id);
                        notification.setTargetId(claim.Id);
                        sendNotification(notification, recipients, (SObject) claim);
                    }
                }
            }
        }
    }

    @Future
    public static void NotifyNAVNotRegisteredReader(List<Id> claimIds) {
        List<HOT_Claim__c> claims = [
            SELECT Id, Name
            FROM HOT_Claim__c
            WHERE Id IN :claimIds
        ];
        List<User> navUsers = [
            SELECT Id
            FROM User
            WHERE Id IN (SELECT userorgroupid FROM groupmember WHERE group.name = 'HOT LOS Saksbehandler')
        ];

        for (HOT_Claim__c claim : claims) {
            for (User user : navUsers) {
                Set<String> recipients = new Set<String>();
                recipients.add(user.Id);
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setTitle('Lesehjelp uten ressursnummer');
                notification.setBody('Lesehjelp uten ressursnummer har sendt inn et nytt krav');
                notification.setNotificationTypeId(getCustomNotificationType('HOT_ClaimNotification').Id);
                notification.setTargetId(claim.Id);
                sendNotification(notification, recipients, (SObject) claim);
            }
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
                logger.exception(e, record, CRM_ApplicationDomain.Domain.HOT);
                logger.publishSynch();
            }
        }
    }
}
