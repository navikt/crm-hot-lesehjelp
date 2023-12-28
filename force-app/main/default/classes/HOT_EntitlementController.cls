public without sharing class HOT_EntitlementController {
    @AuraEnabled(cacheable=true)
    public static List<HOT_Entitlement__c> getEntitlements(){
            User currentUser = [SELECT Id, AccountId FROM User WHERE Id = :UserInfo.getUserId()];
            List<HOT_Entitlement__c> entitlements = [
            SELECT Id,CreatedDate, FromDate__c, ToDate__c, Type__c
            FROM HOT_Entitlement__c
        ];
        return entitlements;
    }
}