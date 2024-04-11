@Istest
private class HOT_NotifyUserNewClaimServiceBatchTest {
     @TestSetup
    static void setup(){
        Account acc = new Account();
        acc.Name = 'Ola Lesehjelp';
        insert acc;
        Person__c person = new Person__c();
        person.Name = '12015678995';
        insert person;
        Account personAccount = new Account();
        personAccount.INT_PersonIdent__c = '12015678995';
        personAccount.CRM_Person__c = person.Id;
        personAccount.INT_KrrMobilePhone__c='12345678';
        personAccount.Name='Kari';
        insert personAccount;
        HOT_Claim__c claim = HOT_LesehjelpTestDataFactory.createClaim(personAccount, acc);
        insert claim;
    }
     @Istest
    static void schedulableTest() {
        // Start the batch
        Test.startTest();
        Database.executeBatch(new HOT_NotifyUserNewClaimServiceBatch());
        Test.stopTest();
    }
}