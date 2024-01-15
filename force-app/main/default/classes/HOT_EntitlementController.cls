public without sharing class HOT_EntitlementController {
    @AuraEnabled(cacheable=true)
    public static List<HOT_Entitlement__c> getEntitlements(){
            User currentUser = [SELECT Id, AccountId, Account.CRM_Person__c FROM User WHERE Id = :UserInfo.getUserId()];
            List<HOT_Entitlement__c> entitlements = [
            SELECT Id,CreatedDate, FromDate__c, ToDate__c, Type__c, Name
            FROM HOT_Entitlement__c WHERE Person__c=:currentUser.Account.CRM_Person__c
        ];
        return entitlements;
    }
}