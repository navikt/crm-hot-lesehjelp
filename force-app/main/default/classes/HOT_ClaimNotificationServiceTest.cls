@IsTest
public class HOT_ClaimNotificationServiceTest {
    @TestSetup
    static void setup() {
    }
    @isTest
    static void notifyNAVonNotRegisteredClaimantTest() {
        Account acc = new Account();
        acc.Name = 'Ola Lesehjelp';
        insert acc;

        Account acc2 = new Account();
        acc2.INT_PersonIdent__c = '01010101010';
        acc2.Name = 'Kari Bruker';
        acc2.INT_KrrMobilePhone__c = '12345678';
        insert acc2;

        Account acc3 = new Account();
        acc3.INT_PersonIdent__c = '02020202020';
        acc3.Name = 'Ola Bruker';
        acc3.INT_KrrMobilePhone__c = '87654321';
        insert acc3;

        // HOT_Entitlement__c entitlement = HOT_LesehjelpTestDataFactory.createEntitlement(acc3);
        // insert entitlement;

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

        HOT_Claim__c claim = HOT_LesehjelpTestDataFactory.createClaim(acc2, acc);
        claim.UserPersonNumber__c = '01010101010';
        insert claim;
    }
    @isTest
    static void notifyNAVonNotRegisteredClaimant2Test() {
        Account acc = new Account();
        acc.Name = 'Ola Lesehjelp';
        insert acc;

        Account acc2 = new Account();
        acc2.INT_PersonIdent__c = '01010101010';
        acc2.Name = 'Kari Bruker';
        acc2.INT_KrrMobilePhone__c = '12345678';
        insert acc2;

        HOT_Entitlement__c entitlement = HOT_LesehjelpTestDataFactory.createEntitlement(acc2);
        entitlement.Type__c = 'Dagligliv';
        insert entitlement;

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

        HOT_Claim__c claim = HOT_LesehjelpTestDataFactory.createClaim(acc2, acc);
        claim.UserPersonNumber__c = '01010101010';
        insert claim;
    }
}
