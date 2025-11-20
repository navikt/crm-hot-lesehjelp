@IsTest
private class HOT_EntitlementControllerTest {
    @TestSetup
    static void setup() {
        Account acc = TestDataFactory_Community.getPersonAccounts(1)[0];
        acc.LastName = 'Ola Bruker';
        insert acc;
        Person__c person = [SELECT INT_LastName__c, CRM_Account__c FROM Person__c];
        person.CRM_Account__c = acc.Id;
        person.INT_BankAccountNumber__c = '12345678901';
        insert person;

        Account acc2 = TestDataFactory_Community.getPersonAccounts(1)[0];
        acc2.LastName = 'Kari Bruker';
        insert acc2;
        Person__c person2 = [SELECT INT_LastName__c, CRM_Account__c FROM Person__c];
        person2.CRM_Account__c = acc2.Id;
        person2.INT_BankAccountNumber__c = '12345678901';
        insert person2;

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
        claim.Status__c = 'Approved by user';
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
    @IsTest
    static void preventChangingEntitlementPeriodIfApprovedClaimsTest() {
        List<Account> accounts = [SELECT Id FROM Account LIMIT 2];
        HOT_Claim__c claim = HOT_LesehjelpTestDataFactory.createClaim(accounts[0], accounts[1]);
        insert claim;

        HOT_Entitlement__c entitlement = HOT_LesehjelpTestDataFactory.createEntitlement(accounts[1]);
        entitlement.FromDate__c = Date.today().addDays(-40);
        entitlement.ToDate__c = Date.today().addDays(40);
        insert entitlement;

        HOT_ClaimLineItem__c cli = HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        insert cli;

        claim.ApprovedByUser__c = true;
        claim.Status__c = 'Approved by user';
        claim.ApprovedByNAV__c = true;
        claim.Status__c = 'Approved by NAV';
        update claim;

        entitlement.ToDate__c = Date.today().addDays(3);

        Test.startTest();
        Database.SaveResult result = Database.update(entitlement, false);
        Test.stopTest();
        System.assert(
            result.getErrors()[0].getMessage().contains('Du kan ikke endre tidene på dette vedtaket'),
            'Expected error message about not allowed to change entitlement period when there already are approved claims.'
        );
    }
}
