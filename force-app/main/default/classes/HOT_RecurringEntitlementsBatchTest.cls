@IsTest
public class HOT_RecurringEntitlementsBatchTest {
    @TestSetup
    static void setup() {
        Account acc2 = new Account();
        acc2.INT_PersonIdent__c = '01010101010';
        acc2.Name = 'Kari Bruker';
        acc2.INT_KrrMobilePhone__c = '12345678';
        insert acc2;

        HOT_Entitlement__c entitlement = HOT_LesehjelpTestDataFactory.createEntitlement(acc2);
        entitlement.Type__c = 'Dagligliv';
        entitlement.Is_recurring__c = true;
        insert entitlement;
    }
    @IsTest
    static void recurringEntitlementBatchJobTest() {
        Test.startTest();
        HOT_RecurringEntitlementBatch batchJob = new HOT_RecurringEntitlementBatch();
        Database.executeBatch(batchJob, 10);
        Test.stopTest();
        List<HOT_Entitlement__c> allEntitlements = [SELECT Id FROM HOT_Entitlement__c];
        List<HOT_Entitlement__c> oldEntitlement = [SELECT Id FROM HOT_Entitlement__c WHERE HasBeenRecurred__c = TRUE];

        System.assertEquals(2, allEntitlements.size(), 'Entitlement did not get recurred');
        System.assertEquals(1, oldEntitlement.size(), 'Old entitlement dit not get updated');
    }
}
