@isTest
private class HOT_LOS_NotificationHandlerTest {
    @TestSetup
    static void setup() {
        ContentVersion cv = new ContentVersion(
            Title = 'LesehjelpLønnskravEksport',
            PathOnClient = 'test.CSV',
            VersionData = Blob.valueOf('masse penga')
        );
        insert cv;
    }

    @isTest
    private static void sendNotificationTest() {
        ContentVersion cv = [
            SELECT Filetype, Title
            FROM ContentVersion
            WHERE (FileType = 'CSV' OR FileType = 'csv') AND Title LIKE 'LesehjelpLønnskrav%'
        ];

        String title = 'Test Title';
        String body = 'Test Body';
        CustomNotificationType notificationType = [
            SELECT Id, DeveloperName
            FROM CustomNotificationType
            WHERE DeveloperName = 'HOT_NotifyLOSSaksbehandler'
        ];
        Id targetId = cv.Id;

        Messaging.CustomNotification notification = HOT_LOS_NotificationHandler.prepareNotification(
            title,
            body,
            notificationType.Id,
            targetId
        );

        Set<String> recipients = new Set<String>{
            (String) HOT_LOS_NotificationHandler.getGroupId('HOT_LOS_Saksbehandler')
        };
        Test.startTest();
        HOT_LOS_NotificationHandler.sendNotification(notification, recipients, cv);
        Test.stopTest();
    }

    @isTest
    private static void prepareNotificationTest() {
        ContentVersion cv = [
            SELECT Filetype, Title
            FROM ContentVersion
            WHERE (FileType = 'CSV' OR FileType = 'csv') AND Title LIKE 'LesehjelpLønnskrav%'
        ];

        String title = 'Test Title';
        String body = 'Test Body';
        CustomNotificationType notificationType = [
            SELECT Id, DeveloperName
            FROM CustomNotificationType
            WHERE DeveloperName = 'HOT_NotifyLOSSaksbehandler'
        ];
        Id targetId = cv.Id;

        Test.startTest();
        Messaging.CustomNotification notification = HOT_LOS_NotificationHandler.prepareNotification(
            title,
            body,
            notificationType.Id,
            targetId
        );
        Test.stopTest();
    }

    @IsTest
    static void getGroupIdTest() {
        List<Group> grpList = [
            SELECT DeveloperName
            FROM Group
            WHERE DeveloperName = 'HOT_LOS_Saksbehandler'
            LIMIT 1
        ];

        Test.startTest();
        Id result = HOT_LOS_NotificationHandler.getGroupId('HOT_LOS_Saksbehandler');
        Test.stopTest();
        System.assertEquals(grpList[0].Id, result);
    }
}
