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
        Set<Id> entitlementHoursAlreadyUsedChangedIds = new Set<Id>();
        Set<Id> updatedEntitlementIds = new Set<Id>();

        for (HOT_Entitlement__c entitlement : (List<HOT_Entitlement__c>) records) {
            if (
                (triggerOldMap.get(entitlement.Id).get('EntitledHoursAlreadyUsed__c') !=
                entitlement.EntitledHoursAlreadyUsed__c)
            ) {
                entitlementHoursAlreadyUsedChangedIds.add(entitlement.Id);
            }
            updatedEntitlementIds.add(entitlement.Id);
        }
        if (entitlementHoursAlreadyUsedChangedIds.size() > 0) {
            HOT_EntitlementController.recalculateUsedEntitlements(entitlementHoursAlreadyUsedChangedIds);
        }
        if (!updatedEntitlementIds.isEmpty()) {
            HOT_EntitlementController.findClaimsOnNewEntitlement(updatedEntitlementIds);
        }
    }
    public override void onAfterInsert() {
        Set<Id> entitlementIds = new Set<Id>();
        for (HOT_Entitlement__c entitlement : (List<HOT_Entitlement__c>) records) {
            entitlementIds.add(entitlement.Id);
        }
        if (entitlementIds.size() > 0) {
            HOT_EntitlementController.recalculateUsedEntitlements(entitlementIds);
            HOT_EntitlementController.findClaimsOnNewEntitlement(entitlementIds);
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
