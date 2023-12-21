public without sharing class HOT_UserInfoController {
    @AuraEnabled(cacheable=true)
    public static boolean checkIsLos(){
            User currentUser = [SELECT Account.CRM_Person__r.HOT_isLOS__c FROM User WHERE Id = :UserInfo.getUserId()];
            return currentUser.Account.CRM_Person__r.HOT_isLOS__c;
    }
    @AuraEnabled(cacheable=true)
    public static Person__c getPersonDetails(){
            User currentUser = [SELECT Id, Account.CRM_Person__c FROM User WHERE Id = :UserInfo.getUserId()];
            Person__c person = [
            SELECT Id, INT_KrrEmail__c, INT_BankAccountNumber__c, INT_ResidentialAddress__c,INT_ResidentialZipCode__c, INT_ResidentialPlace__c, INT_KrrMobilePhone__c,INT_LastUpdatedFromKRR__c, INT_KrrIntegrationStatus__c
            FROM Person__c
            WHERE Id = :currentUser.Account.CRM_Person__c
        ];
        return person;
    }
}