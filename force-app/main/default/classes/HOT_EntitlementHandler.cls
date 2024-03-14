public with sharing class HOT_EntitlementHandler extends MyTriggers {
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
    }
}
