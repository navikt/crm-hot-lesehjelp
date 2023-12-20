public without sharing class HOT_UserInfoController {
    @AuraEnabled(cacheable=true)
    public static boolean checkIsLos(){
            User currentUser = [SELECT Account.CRM_Person__r.HOT_isLOS__c FROM User WHERE Id = :UserInfo.getUserId()];
            return currentUser.Account.CRM_Person__r.HOT_isLOS__c;
    }
}