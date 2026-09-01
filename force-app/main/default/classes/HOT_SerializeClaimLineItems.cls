public without sharing class HOT_SerializeClaimLineItems {
    public class ClaimLineItemsRequest {
        @InvocableVariable(required=true)
        public List<HOT_ClaimLineItem__c> claimLineItems;
    }

    public class Result {
        @InvocableVariable
        public String payloadJSON;
    }

    @InvocableMethod(
        label='Serialize Claim Line Items to JSON'
        description='Serializes a list of HOT_ClaimLineItem__c records into a JSON string'
    )
    public static List<Result> serialize(List<ClaimLineItemsRequest> requests) {
        List<Result> results = new List<Result>();
        for (ClaimLineItemsRequest req : requests) {
            Result res = new Result();
            res.payloadJSON = JSON.serialize(req.claimLineItems);
            results.add(res);
        }
        return results;
    }
}
