@IsTest
private class HOT_LOS_NotifyOnNewFileTest {
    @TestSetup
    static void setup() {
        ContentVersion cv = new ContentVersion(
            Title = 'LesehjelpLønnskravEksport',
            PathOnClient = 'test.CSV',
            VersionData = Blob.valueOf('masse penga')
        );
        insert cv;
    }

    @IsTest
    static void testPrepareContextsForFile() {
        ContentVersion cv = [
            SELECT Filetype, Title
            FROM ContentVersion
            WHERE (FileType = 'CSV' OR FileType = 'csv') AND Title LIKE 'LesehjelpLønnskrav%'
        ];

        Test.startTest();
        List<HOT_LOS_NotifyOnNewFile.NotificationContext> contexts = HOT_LOS_NotifyOnNewFile.prepareContextsForFile(
            new List<ContentVersion>{ cv }
        );
        Test.stopTest();

        System.assertEquals(1, contexts.size(), 'Should create exactly one context');
        System.assertEquals(cv.Id, contexts[0].cv.Id, 'ContentVersion ID must be mapped');
        System.assertEquals(1, contexts[0].recipients.size(), 'Exactly one group recipient expected');
        System.assertNotEquals(null, contexts[0].notification, 'Notification must be created');
    }

    @IsTest
    static void testNotifyOnNewFile() {
        ContentVersion cv = [
            SELECT Filetype, Title
            FROM ContentVersion
            WHERE (FileType = 'CSV' OR FileType = 'csv') AND Title LIKE 'LesehjelpLønnskrav%'
        ];

        Test.startTest();
        Integer sentNotifications = HOT_LOS_NotifyOnNewFile.notifyOnNewFile(new List<ContentVersion>{ cv });
        Test.stopTest();

        System.assertEquals(1, sentNotifications, 'One notification should be sent');
    }
}
