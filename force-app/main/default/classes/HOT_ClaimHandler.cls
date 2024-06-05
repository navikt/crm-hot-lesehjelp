public without sharing class HOT_ClaimHandler extends MyTriggers {
    public override void onAfterInsert() {
        List<Id> notifyNAVNotRegisteredReader = new List<Id>();

        Set<Id> accountIds = new Set<Id>();
        List<Id> claimIds = new List<Id>();
        for (HOT_Claim__c claim : (List<HOT_Claim__c>) records) {
            accountIds.add(claim.Claimant__c);
            if(claim.IsLos__c==false){
                notifyNAVNotRegisteredReader.add(claim.Id);
            }
            claimIds.add(claim.Id);
        }
        if (accountIds.size() > 0) {
            // Call out to KRR through Queuable Apex
            HOT_KRRAccountCalloutQueuable krr = new HOT_KRRAccountCalloutQueuable(accountIds);
            System.enqueueJob(krr);
        }
        if (!claimIds.isEmpty()) {
            HOT_NotificationService.NotifyNAVNotNoEntitlementOnUser(claimIds);
        }
        if (!notifyNAVNotRegisteredReader.isEmpty()) {
            HOT_NotificationService.NotifyNAVNotRegisteredReader(notifyNAVNotRegisteredReader);
        }
    }
    public override void onAfterUpdate(Map<Id, sObject> triggerOldMap) {
        List<HOT_Claim__c> claimsToNotifyUserOnDeclinedStatus = new List<HOT_Claim__c>();
        List<HOT_Claim__c> claimsToNotifyUserOnDeclinedByNAVStatus = new List<HOT_Claim__c>();
        Set<Id> entitlements = new Set<Id>();
        Set<Id> claimIds = new Set<Id>();

        List<HOT_Claim__c> updatedClaims = new List<HOT_Claim__c>();
        for (HOT_Claim__c claim : (List<HOT_Claim__c>) records) {
            if (
                (triggerOldMap.get(claim.Id).get('Status__c') == 'Sent') &&
                (claim.Status__c == 'Declined by user')
            ) {
                claimsToNotifyUserOnDeclinedStatus.add(claim);
            }
            if (
                (triggerOldMap.get(claim.Id).get('Status__c') == 'Approved by user') &&
                (claim.Status__c == 'Declined by NAV')
            ) {
                claimsToNotifyUserOnDeclinedByNAVStatus.add(claim);
            }

            Id oldEntitlementId = (Id) triggerOldMap.get(claim.Id).get('Entitlement__c');
            if (claim.Entitlement__c != oldEntitlementId) {
                entitlements.add(oldEntitlementId);
            }
            entitlements.add(claim.Entitlement__c);
            if (claim.Entitlement__c == null) {
                claimIds.add(claim.Id);
            }
        }
        if (claimIds.size() > 0) {
            System.debug('Går inn her 101');
            HOT_ClaimController.setEntitlementOnClaim(claimIds);
        }
        if (claimsToNotifyUserOnDeclinedStatus.size() > 0) {
            System.debug('Går inn her 102');
            HOT_SMSService.notifyUserOnDeclinedClaim(claimsToNotifyUserOnDeclinedStatus);
        }
        if (claimsToNotifyUserOnDeclinedByNAVStatus.size() > 0) {
            System.debug('Går inn her 102');
            HOT_SMSService.notifyUserOnDeclinedClaimByNAV(claimsToNotifyUserOnDeclinedByNAVStatus);
        }
        if (entitlements.size() > 0) {
            System.debug('Går inn her 103');
            HOT_EntitlementController.recalculateUsedEntitlements(entitlements);
        }
    }
}
