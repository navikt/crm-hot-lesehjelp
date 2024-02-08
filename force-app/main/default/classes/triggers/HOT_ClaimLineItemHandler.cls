public without sharing class HOT_ClaimLineItemHandler extends MyTriggers {
      public override void onAfterInsert() {
        Set<Id> claimIds = new Set<Id>();
         for (HOT_ClaimLineItem__c claimLineItems : (List<HOT_ClaimLineItem__c>) records) {
            claimIds.add(claimLineItems.Claim__c);
        }
        if(claimIds.size()>0){
            HOT_ClaimController.setEntitlementOnClaimList(claimIds);
        }
    }
    public override void onAfterUpdate(Map<Id, sObject> triggerOldMap) {
        Set<Id> claimIds = new Set<Id>();
         for (HOT_ClaimLineItem__c claimLineItems : (List<HOT_ClaimLineItem__c>) records) {
            claimIds.add(claimLineItems.Claim__c);
        }
        if(claimIds.size()>0){
            HOT_ClaimController.setEntitlementOnClaimList(claimIds);
        }
    }
    
}