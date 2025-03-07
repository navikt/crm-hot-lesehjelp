public with sharing class HOT_EntitlementHandler extends MyTriggers {
    public override void onBeforeInsert() {
        List<HOT_Entitlement__c> checkNewEntitlements = new List<HOT_Entitlement__c>();
        for (HOT_Entitlement__c entitlement : (List<HOT_Entitlement__c>) records) {
            if (entitlement.Account__c != null) {
                checkNewEntitlements.add(entitlement);
            }
        }
        if (checkNewEntitlements.size() > 0) {
            HOT_EntitlementController.checkIfNewEntitlementsWillOverlap(checkNewEntitlements);
        }
    }
    public override void onAfterUpdate(Map<Id, sObject> triggerOldMap) {
        Set<Id> entitlementIds = new Set<Id>();
        for (HOT_Entitlement__c entitlement : (List<HOT_Entitlement__c>) records) {
            if (
                (triggerOldMap.get(entitlement.Id).get('EntitledHoursAlreadyUsed__c') !=
                entitlement.EntitledHoursAlreadyUsed__c)
            ) {
                entitlementIds.add(entitlement.Id);
            }
        }
        if (entitlementIds.size() > 0) {
            HOT_EntitlementController.recalculateUsedEntitlements(entitlementIds);
        }
        HOT_EntitlementController.findClaimsOnNewEntitlement();
    }
    public override void onAfterInsert() {
        HOT_EntitlementController.findClaimsOnNewEntitlement();
        Set<Id> entitlementIds = new Set<Id>();
        for (HOT_Entitlement__c entitlement : (List<HOT_Entitlement__c>) records) {
            entitlementIds.add(entitlement.Id);
        }
        if (entitlementIds.size() > 0) {
            HOT_EntitlementController.recalculateUsedEntitlements(entitlementIds);
        }
    }
    public override void onBeforeUpdate(Map<Id, sObject> triggerOldMap) {
        List<HOT_Entitlement__c> updatedEntitlements = new List<HOT_Entitlement__c>();
        for (HOT_Entitlement__c entitlement : (List<HOT_Entitlement__c>) records) {
            if (
                (triggerOldMap.get(entitlement.Id).get('FromDate__c') != entitlement.FromDate__c) ||
                (triggerOldMap.get(entitlement.Id).get('ToDate__c') != entitlement.ToDate__c)
            ) {
                updatedEntitlements.add(entitlement);
            }
        }
        HOT_EntitlementController.checkForAlreadyApprovedClaims(updatedEntitlements);
    }
}
