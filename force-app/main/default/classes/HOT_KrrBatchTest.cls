@isTest
private with sharing class HOT_KrrBatchTest {
    @isTest
    static void schedulableTest() {
        String cron_exp = '0 0 0 3 9 ? 2024';
        Test.startTest();
        String jobId = System.schedule('HOT_KrrBatch', cron_exp, new HOT_KrrBatch());
        Test.stopTest();
        System.assert(jobId != null);
    }
     @isTest
    static void batchableTest() {
        Person__c person = new Person__c();
        person.Name = '12015678999';
        insert person;
        Account personAccount = new Account();
        personAccount.INT_PersonIdent__c = '12015678999';
        personAccount.CRM_Person__c = person.Id;
        personAccount.Name='Kari';
        insert personAccount;

        person.INT_KrrIntegrationStatus__c = 'Failed';
        update person;
    }
}