@IsTest
private class HOT_SerializeClaimLineItemsTest {
    @IsTest
    static void serializeTest() {
        Account claimant = HOT_LesehjelpTestDataFactory.createAccount(true);
        insert claimant;
        HOT_Claim__c claim = HOT_LesehjelpTestDataFactory.createClaim(claimant, claimant);
        insert claim;
        HOT_ClaimLineItem__c cli = HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        insert cli;

        HOT_SerializeClaimLineItems.ClaimLineItemsRequest req = new HOT_SerializeClaimLineItems.ClaimLineItemsRequest();
        req.claimLineItems = [SELECT Id, Claim__c, Date__c FROM HOT_ClaimLineItem__c WHERE Claim__c = :claim.Id];

        Test.startTest();
        List<HOT_SerializeClaimLineItems.Result> results = HOT_SerializeClaimLineItems.serialize(
            new List<HOT_SerializeClaimLineItems.ClaimLineItemsRequest>{ req }
        );
        Test.stopTest();

        System.assertEquals(1, results.size());
        List<Object> deserialized = (List<Object>) JSON.deserializeUntyped(results[0].payloadJSON);
        System.assertEquals(1, deserialized.size());
    }
}
