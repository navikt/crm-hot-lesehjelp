@Istest
private class HOT_UserInfoControllerTest {
    @TestSetup
    static void setup(){
        Person__c person = new Person__c();
        person.Name = '12015678995';
        insert person;
        Account personAccount = new Account();
        personAccount.INT_PersonIdent__c = '12015678995';
        personAccount.CRM_Person__c = person.Id;
        personAccount.INT_KrrMobilePhone__c='12345678';
        personAccount.Name='Kari';
        insert personAccount;
    }
    @Istest
    static void checkIsLosTest(){
        Test.startTest();
        Boolean isLos=HOT_UserInfoController.checkIsLos();
        Test.stopTest();
        System.assertEquals(false, isLos);

    }
    @Istest
    static void checkAccountExistWithFnrFalseTest(){
        Test.startTest();
        Boolean accountExist=HOT_UserInfoController.checkAccountExist('01010100095','');
        Test.stopTest();
        System.assertEquals(false, accountExist);
    }
    @Istest
    static void checkAccountExistWithTlfFalseTest(){
        Test.startTest();
        Boolean accountExist=HOT_UserInfoController.checkAccountExist('','12345677');
        Test.stopTest();
        System.assertEquals(false, accountExist);
    }
    @Istest
    static void checkAccountExistWithTlfTrueTest(){
        Test.startTest();
        Boolean accountExist=HOT_UserInfoController.checkAccountExist('','12345678');
        Test.stopTest();
        System.assertEquals(true, accountExist);
    }
    @Istest
    static void updateKrrStatusTest(){
        Test.startTest();
        Person__c person =[SELECT Id FROM Person__c];
        person.INT_KrrIntegrationStatus__c = 'Queued';
        HOT_UserInfoController.updateKrrStatus(person);
        Test.stopTest();
        Person__c personResult =[SELECT Id, INT_KrrIntegrationStatus__c FROM Person__c];
        System.assertEquals('Queued', personResult.INT_KrrIntegrationStatus__c);

    }
      @Istest
    static void getPersonDetailsTest(){
        // Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' OR Name = 'Standardbruker' LIMIT 1];

        // Test.startTest();
        // Account account=[SELECT Id,PersonContactId FROM Account LIMIT 1];
        // User user = HOT_LesehjelpTestDataFactory.createUser(profile, account);
        // insert user;

        // System.runAs(user) {
        //     Person__c personResult = HOT_UserInfoController.getPersonDetails();
        //     System.assertEquals('12345678', personResult.INT_KrrMobilePhone__c);
        // }
        // Test.stopTest();

    }
}