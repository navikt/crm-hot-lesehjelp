@isTest
private class HOT_LOS_NotificationHandlerTest {
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
