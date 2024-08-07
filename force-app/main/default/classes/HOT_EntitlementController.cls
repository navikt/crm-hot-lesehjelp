public without sharing class HOT_EntitlementController {
    public static void checkIfNewEntitlementsWillOverlap(List<HOT_Entitlement__c> entitlements) {
        Set<Id> accountIds = new Set<Id>();
        for (HOT_Entitlement__c entitlement : entitlements) {
            accountIds.add(entitlement.Account__c);
        }
        List<HOT_Entitlement__c> existingEntitlements = [
            SELECT Id, Name, Account__c, FromDate__c, ToDate__c, Type__c
            FROM HOT_Entitlement__c
            WHERE Account__c IN :accountIds
        ];
        if (!existingEntitlements.isEmpty()) {
            for (HOT_Entitlement__c existingEntitlement : existingEntitlements) {
                for (HOT_Entitlement__c insertedEntitlement : entitlements) {
                    if (
                        insertedEntitlement.FromDate__c <= existingEntitlement.ToDate__c &&
                        insertedEntitlement.ToDate__c >= existingEntitlement.FromDate__c &&
                        insertedEntitlement.Type__c == existingEntitlement.Type__c &&
                        existingEntitlement.Account__c == insertedEntitlement.Account__c
                    ) {
                        insertedEntitlement.addError('Vedtaket er overlappende med ' + existingEntitlement.Name);
                    }
                }
            }
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<HOT_Entitlement__c> getEntitlements() {
        User currentUser = [SELECT Id, AccountId, Account.CRM_Person__c FROM User WHERE Id = :UserInfo.getUserId()];
        List<HOT_Entitlement__c> entitlements = [
            SELECT
                Id,
                CreatedDate,
                FromDate__c,
                ToDate__c,
                Type__c,
                Name,
                EntitledHours__c,
                EntitledHoursUsed__c,
                Is_recurring__c,
                HasBeenRecurred__c
            FROM HOT_Entitlement__c
            WHERE Account__c = :currentUser.Account.Id
            ORDER BY ToDate__c DESC
        ];
        return entitlements;
    }
    public static void recalculateUsedEntitlements(Set<Id> entitlementIds) {
        List<HOT_Claim__c> claimList = [
            SELECT Id, Entitlement__c, ApprovedByNAV__c, TotalHours__c
            FROM HOT_Claim__c
            WHERE Entitlement__c IN :entitlementIds AND ApprovedByNAV__c = TRUE
        ];

        List<HOT_Entitlement__c> entitlementList = [
            SELECT Id, EntitledHours__c, EntitledHoursUsed__c, EntitledHoursAlreadyUsed__c
            FROM HOT_Entitlement__c
            WHERE Id IN :entitlementIds
        ];
        for (HOT_Entitlement__c entitlement : entitlementList) {
            if (entitlement.EntitledHoursAlreadyUsed__c == null) {
                entitlement.EntitledHoursUsed__c = 0;
            } else {
                entitlement.EntitledHoursUsed__c = 0 + entitlement.EntitledHoursAlreadyUsed__c;
            }
            for (HOT_Claim__c claim : claimList) {
                if (claim.Entitlement__c == entitlement.Id) {
                    entitlement.EntitledHoursUsed__c += claim.TotalHours__c;
                }
            }
        }
        update entitlementList;
    }
    public static void findClaimsOnNewEntitlement() {
        List<HOT_Claim__c> claims = [SELECT Id FROM HOT_Claim__c WHERE Entitlement__c = NULL];
        Set<Id> claimIds = new Set<Id>();
        if (!claims.isEmpty()) {
            for (HOT_Claim__c claim : claims) {
                claimIds.add(claim.Id);
            }
            HOT_ClaimController.setEntitlementOnClaim(claimIds);
        }
    }
}
