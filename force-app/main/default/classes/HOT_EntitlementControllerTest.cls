@IsTest
private class HOT_EntitlementControllerTest {
    @TestSetup
    static void setup() {
        Person__c person = HOT_LesehjelpTestDataFactory.createPerson();
        person.Name = '12015678999';
        person.INT_BankAccountNumber__c = '122344556';
        insert person;

        Person__c person2 = HOT_LesehjelpTestDataFactory.createPerson();
        person2.Name = '12015678993';
        person2.INT_BankAccountNumber__c = '122344553';
        insert person2;

        Account acc = HOT_LesehjelpTestDataFactory.createAccount(true);
        acc.INT_PersonIdent__c = '12015678993';
        acc.CRM_Person__c = person.Id;
        insert acc;

        Account acc2 = HOT_LesehjelpTestDataFactory.createAccount(true);
        acc2.INT_PersonIdent__c = '12015678999';
        acc2.CRM_Person__c = person.Id;
        insert acc2;

        HOT_Claim__c claim = HOT_LesehjelpTestDataFactory.createClaim(acc, acc2);
        insert claim;

        HOT_Entitlement__c entitlement = HOT_LesehjelpTestDataFactory.createEntitlement(acc);
        insert entitlement;
    }
    @IsTest
    static void recalculateUsedEntitlementsTest() {
        Test.startTest();
        HOT_Claim__c claim = [SELECT Id, Claimant__r.CRM_Person__r.INT_BankAccountNumber__c FROM HOT_Claim__c];
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
        Account acc2 = HOT_LesehjelpTestDataFactory.createAccount(true);
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
        Test.startTest();
        Person__c person = HOT_LesehjelpTestDataFactory.createPerson();
        person.Name = '12015678994';
        person.INT_BankAccountNumber__c = '122344553';
        insert person;

        Account acc = HOT_LesehjelpTestDataFactory.createAccount(true);
        acc.INT_PersonIdent__c = '12015678994';
        acc.CRM_Person__c = person.Id;
        insert acc;

        Account acc2 = new Account();
        acc2.Name = 'Ola Bruker';
        insert acc2;

        HOT_Claim__c claim = HOT_LesehjelpTestDataFactory.createClaim(acc2, acc);
        insert claim;

        HOT_Entitlement__c entitlement = HOT_LesehjelpTestDataFactory.createEntitlement(acc2);
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

        Database.SaveResult result = Database.update(entitlement, false);
        Test.stopTest();
        System.assert(
            result.getErrors()[0].getMessage().contains('Du kan ikke endre tidene på dette vedtaket'),
            'Expected error message about not allowed to change entitlement period when there already are approved claims.'
        );
    }
}
