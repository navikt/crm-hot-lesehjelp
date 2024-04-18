@IsTest
private class HOT_EntitlementControllerTest {
    @TestSetup
    static void setup() {
        Account acc = new Account();
        acc.Name = 'Ola Lesehjelp';
        insert acc;
        Account acc2 = new Account();
        acc2.Name = 'Kari Bruker';
        insert acc2;
        HOT_Claim__c claim = HOT_LesehjelpTestDataFactory.createClaim(acc2, acc);
        insert claim;

        HOT_Entitlement__c entitlement = HOT_LesehjelpTestDataFactory.createEntitlement(acc2);
        insert entitlement;
    }
    @IsTest
    static void recalculateUsedEntitlementsTest() {
        Test.startTest();
        HOT_Claim__c claim = [SELECT Id FROM HOT_Claim__c];
        HOT_ClaimLineItem__c cli = HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        insert cli;
        claim.ApprovedByUser__c = true;
        claim.ApprovedByNAV__c = true;
        update claim;
        List<HOT_Entitlement__c> entitlements = [
            SELECT Id, EntitledHoursUsed__c, EntitledHoursAlreadyUsed__c
            FROM HOT_Entitlement__c
        ];
        Set<Id> entitlementsId = new Set<Id>();
        for (HOT_Entitlement__c et : entitlements) {
            et.EntitledHoursAlreadyUsed__c = null;
            entitlementsId.add(et.Id);
        }
        update entitlements;
        HOT_EntitlementController.recalculateUsedEntitlements(entitlementsId);
        Test.stopTest();
    }
    @IsTest
    static void checkIfNewEntitlementsWillOverlapTest() {
        Test.startTest();
        Account acc2 = new Account();
        acc2.Name = 'Ola Bruker';
        insert acc2;

        HOT_Entitlement__c entitlement = HOT_LesehjelpTestDataFactory.createEntitlement(acc2);
        insert entitlement;
        try {
            HOT_Entitlement__c entitlement2 = HOT_LesehjelpTestDataFactory.createEntitlement(acc2);
            insert entitlement2;
        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains('overlappende') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }

        Test.stopTest();
    }
}
