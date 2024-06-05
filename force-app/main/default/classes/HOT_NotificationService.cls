public without sharing class HOT_NotificationService {
    @Future
    public static void NotifyNAV(List<Id> claimIds) {
        List<HOT_Claim__c> claims = [
            SELECT Id, Name
            FROM HOT_Claim__c
            WHERE Id IN :claimIds
        ];
        List<User> navUsers =[SELECT Id FROM User WHERE Id in (SELECT userorgroupid from groupmember where group.name = 'HOT LOS Saksbehandler')];
        
        for(HOT_Claim__c claim : claims){
            for(User user : navUsers){
                Set<String> recipients = new Set<String>();
                recipients.add(user.Id);
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setTitle('Lesehjelp uten ressursnummer');
                notification.setBody('Lesehjelp uten ressursnummer har sendt inn et nytt krav');
                notification.setNotificationTypeId(getCustomNotificationType('HOT_NotifyNAV').Id); 
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