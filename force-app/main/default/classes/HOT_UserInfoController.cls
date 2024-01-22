public without sharing class HOT_UserInfoController {
    @AuraEnabled(cacheable=true)
    public static boolean checkIsLos(){
            User currentUser = [SELECT Account.CRM_Person__r.HOT_isLOS__c FROM User WHERE Id = :UserInfo.getUserId()];
            return currentUser.Account.CRM_Person__r.HOT_isLOS__c;
    }
    @AuraEnabled(cacheable=true)
    public static boolean checkAccountExist(String userPersonNumber, String userPhoneNumber){
        Boolean accountExist=false;
            List<String> idents = new List<String>();
                if (!String.isBlank(userPersonNumber)) {
                    idents.add(userPersonNumber.replaceAll(' ', ''));
                }
                if (!String.isBlank(userPhoneNumber)) {
                    idents = addUserPhoneVariations(idents, userPhoneNumber);
                }
                List<Account> account=getAccount(idents); 
                if(account.size()==1){
                        accountExist=true;
                } 
                return accountExist;        
                
    }
    private static List<String> addUserPhoneVariations(List<String> idents, String phoneNumber) {
        idents.add(phoneNumber);
        idents.add('+47' + phoneNumber);
        idents.add('0047' + phoneNumber);
        return idents;
    }
    private static List<Account> getAccount(List<String> idents){
            List<Account> accounts = [
            SELECT
                Id,
                Name,
                INT_PersonIdent__c,
                CRM_Person__c,
                INT_KrrMobilePhone__c
            FROM Account
            WHERE
                INT_PersonIdent__c IN :idents
                OR INT_KrrMobilePhone__c IN :idents
        ];
        return accounts;
    }
    @AuraEnabled(cacheable=true)
    public static Person__c getPersonDetails(){
            User currentUser = [SELECT Id, Account.CRM_Person__c FROM User WHERE Id = :UserInfo.getUserId()];
            Person__c person = [
            SELECT Id, INT_KrrEmail__c, INT_BankAccountNumber__c, INT_ResidentialAddress__c, INT_ResidentialZipCode__c, INT_ResidentialZip__c, INT_KrrMobilePhone__c,INT_LastUpdatedFromKRR__c, INT_KrrIntegrationStatus__c
            FROM Person__c
            WHERE Id = :currentUser.Account.CRM_Person__c
        ];
        return person;
    }
}