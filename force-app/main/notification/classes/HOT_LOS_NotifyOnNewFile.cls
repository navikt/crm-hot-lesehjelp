public with sharing class HOT_LOS_NotifyOnNewFile {
    @TestVisible
    private class NotificationContext {
        public ContentVersion cv;
        public Set<String> recipients;
        public Messaging.CustomNotification notification;
    }

    public static void notifyOnNewFile(List<ContentVersion> cvs) {
        List<NotificationContext> contexts = prepareContextsForFile(cvs);

        for (NotificationContext context : contexts) {
            HOT_LOS_NotificationHandler.sendNotification(
                context.notification,
                context.recipients,
                (SObject) context.cv
            );
        }
    }

    @TestVisible
    private static List<NotificationContext> prepareContextsForFile(List<ContentVersion> cvs) {
        List<NotificationContext> contextList = new List<NotificationContext>();

        CustomNotificationType notificationType = [
            SELECT Id, DeveloperName
            FROM CustomNotificationType
            WHERE DeveloperName = 'HOT_NotifyLOSSaksbehandler'
            LIMIT 1
        ];

        Id groupId = HOT_LOS_NotificationHandler.getGroupId('HOT_LOS_Saksbehandler');

        for (ContentVersion cv : cvs) {
            NotificationContext context = new NotificationContext();
            context.cv = cv;
            context.recipients = new Set<String>{ (String) groupId };

            String title = 'Ny lønnsfil for Lese- og sekretærhjelp klar';
            String body = 'Klikk her for å laste ned filen';

            context.notification = HOT_LOS_NotificationHandler.prepareNotification(
                title,
                body,
                notificationType.Id,
                context.cv.Id
            );
            contextList.add(context);
        }

        return contextList;
    }
}
