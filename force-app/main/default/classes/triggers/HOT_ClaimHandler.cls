public without sharing class HOT_ClaimHandler extends MyTriggers {
    public override void onAfterUpdate(Map<Id, sObject> triggerOldMap) {
        List<HOT_Claim__c> claimsToNotifyUserOnDeclinedStatus = new List<HOT_Claim__c>();
        Set<Id> entitlements = new Set<Id>();
        List<HOT_Claim__c> updatedClaims = new List<HOT_Claim__c>();
        for (HOT_Claim__c claim : (List<HOT_Claim__c>) records) {
            if (
                triggerOldMap.get(claim.Id).get('Status__c') == 'Sent' ||
                triggerOldMap.get(claim.Id).get('Status__c') == 'Approved by user' &&
                (claim.Status__c == 'Declined' ||
                claim.Status__c == 'Declined by user')
            ) {
                claimsToNotifyUserOnDeclinedStatus.add(claim);
            }
            Id oldEntitlementId = (Id)triggerOldMap.get(claim.Id).get('Entitlement__c');
            if(claim.Entitlement__c != oldEntitlementId){
                entitlements.add(oldEntitlementId);
            }
            entitlements.add(claim.Entitlement__c);
        }
        if (claimsToNotifyUserOnDeclinedStatus.size() > 0) {
            HOT_SMSService.notifyUserOnDeclinedClaim(claimsToNotifyUserOnDeclinedStatus);
        }
        if (entitlements.size() > 0) {
            HOT_EntitlementController.recalculateUsedEntitlements(entitlements);
        }
    }
}
