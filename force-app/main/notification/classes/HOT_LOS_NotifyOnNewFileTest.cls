@IsTest
private class HOT_LOS_NotifyOnNewFileTest {
    // private class NotificationHandlerMock {
    //     public static List<Messaging.CustomNotification> notifications = new List<Messaging.CustomNotification>();
    //     public static List<Set<String>> recipientSets = new List<Set<String>>();
    //     public static List<SObject> attachedObjects = new List<SObject>();

    //     public static Messaging.CustomNotification prepareNotification(
    //         String title,
    //         String body,
    //         Id typeId,
    //         Id relatedRecordId
    //     ) {
    //         Messaging.CustomNotification notif = new Messaging.CustomNotification();
    //         notif.setTitle(title);
    //         notif.setBody(body);
    //         notif.setNotificationTypeId(typeId);
    //         notif.setTargetId(relatedRecordId);
    //         return notif;
    //     }

    //     public static void sendNotification(
    //         Messaging.CustomNotification notif,
    //         Set<String> recipients,
    //         SObject target
    //     ) {
    //         notifications.«add(notif);
    //         recipientSets.add(recipients);
    //         attachedObjects.add(target);
    //     }

    //     public static Id getGroupId(String devName) {
    //         Group g = [SELECT Id FROM Group WHERE DeveloperName = :devName LIMIT 1];
    //         return g.Id;
    //     }
    // }

    // @TestSetup
    // static void setup() {
    //     insert new CustomNotificationType(
    //         DeveloperName = 'HOT_NotifyLOSCaseworker',
    //         MasterLabel = 'HOT_NotifyLOSCaseworker'
    //     );

    //     insert new Group(Name = 'HOT LOS Saksbehandler', DeveloperName = 'HOT_LOS_Saksbehandler', Type = 'Regular');
    // }

    // @IsTest
    // static void testPrepareContextsForFile() {
    //     ContentVersion cv = new ContentVersion(
    //         Title = 'LesehjelpLønnskravEksport',
    //         PathOnClient = 'test.txt',
    //         VersionData = Blob.valueOf('masse penga')
    //     );
    //     insert cv;

    //     Test.setMock(Test.CalloutMock.class, null);

    //     HOT_LOS_NotificationHandler.prepareNotification = NotificationHandlerMock.prepareNotification;
    //     HOT_LOS_NotificationHandler.sendNotification = NotificationHandlerMock.sendNotification;
    //     HOT_LOS_NotificationHandler.getGroupId = NotificationHandlerMock.getGroupId;

    //     Test.startTest();
    //     List<HOT_LOS_NotifyOnNewFile.NotificationContext> contexts = HOT_LOS_NotifyOnNewFile.prepareContextsForFile(
    //         new List<ContentVersion>{ cv }
    //     );
    //     Test.stopTest();

    //     System.assertEquals(1, contexts.size(), 'Should create exactly one context');
    //     System.assertEquals(cv.Id, contexts[0].cv.Id, 'ContentVersion ID must be mapped');
    //     System.assertEquals(1, contexts[0].recipients.size(), 'Exactly one group recipient expected');
    //     System.assertNotEquals(null, contexts[0].notification, 'Notification must be created');

    //     Messaging.CustomNotification notif = contexts[0].notification;
    //     System.assertEquals(cv.Id, notif.getTargetId(), 'Notification target must match CV Id');
    // }

    // @IsTest
    // static void testNotifyOnNewFile() {
    //     ContentVersion cv = new ContentVersion(
    //         Title = 'LesehjelpLønnskravEksport',
    //         PathOnClient = 'test.txt',
    //         VersionData = Blob.valueOf('masse penga')
    //     );
    //     insert cv;

    //     HOT_LOS_NotificationHandler.prepareNotification = NotificationHandlerMock.prepareNotification;
    //     HOT_LOS_NotificationHandler.sendNotification = NotificationHandlerMock.sendNotification;
    //     HOT_LOS_NotificationHandler.getGroupId = NotificationHandlerMock.getGroupId;

    //     Test.startTest();
    //     HOT_LOS_NotifyOnNewFile.notifyOnNewFile(new List<ContentVersion>{ cv });
    //     Test.stopTest();

    //     System.assertEquals(1, NotificationHandlerMock.notifications.size(), 'One notification should be sent');

    //     Messaging.CustomNotification sent = NotificationHandlerMock.notifications[0];

    //     System.assertEquals(cv.Id, sent.getTargetId(), 'Notification must target the CV Id');
    //     System.assertEquals(
    //         1,
    //         NotificationHandlerMock.recipientSets[0].size(),
    //         'Recipients must contain exactly one group'
    //     );

    //     System.assertEquals(
    //         cv.Id,
    //         NotificationHandlerMock.attachedObjects[0].get('Id'),
    //         'Attached SObject must match the CV'
    //     );
    // }
}
