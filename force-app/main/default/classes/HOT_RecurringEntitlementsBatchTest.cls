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
        entitlement.EntitledHoursAlreadyUsed__c = 12;
        entitlement.Is_recurring__c = true;
        insert entitlement;
    }
    @IsTest
    static void recurringEntitlementBatchJobTest() {
        Test.startTest();
        User sysAdminUser = [
            SELECT Id
            FROM User
            WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE
            LIMIT 1
        ];

        System.runAs(sysAdminUser) {
            Group group1 = new Group(Name = 'HOT LOS Saksbehandler', Type = 'Regular');
            insert group1;

            GroupMember gm = new GroupMember(GroupId = group1.Id, UserOrGroupId = sysAdminUser.Id);
            insert gm;
        }
        HOT_RecurringEntitlementBatch batchJob = new HOT_RecurringEntitlementBatch();
        Database.executeBatch(batchJob, 10);
        Test.stopTest();
        Date today = Date.today();
        Date firstDayJanuaryNextYear = Date.newInstance(today.year() + 1, 1, 1);
        Date lastDayDecemberNextYear = Date.newInstance(today.year() + 1, 12, 31);
        List<HOT_Entitlement__c> allEntitlements = [
            SELECT Id, Name, ToDate__c, FromDate__c, HasBeenRecurred__c, EntitledHoursAlreadyUsed__c
            FROM HOT_Entitlement__c
        ];

        System.assertEquals(2, allEntitlements.size(), 'Entitlement did not get recurred');
        for (HOT_Entitlement__c entitlement : allEntitlements) {
            if (entitlement.EntitledHoursAlreadyUsed__c != 12) {
                System.assertEquals(
                    firstDayJanuaryNextYear,
                    entitlement.FromDate__c,
                    'New entitlement did not get correct date'
                );
                System.assertEquals(
                    lastDayDecemberNextYear,
                    entitlement.ToDate__c,
                    'New entitlement did not get correct date'
                );
            }
            if (entitlement.EntitledHoursAlreadyUsed__c == 12) {
                System.assertEquals(true, entitlement.HasBeenRecurred__c, 'Old entitlement dit not get updated');
            }
        }
    }
    @IsTest
    static void runBatchJobTest() {
        Test.startTest();
        HOT_RecurringEntitlementBatch.startBatchJob();
        Test.stopTest();
    }
}
