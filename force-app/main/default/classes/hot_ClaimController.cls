public without sharing class hot_ClaimController {
    @AuraEnabled
    public static String createNewClaimFromCommunity(String userName, String userPersonNumber, String userPhoneNumber, String claimType, String onEmployer, String employerName, String organizationNumber, String employerExpensesPerHour, List<Map<String, Object>> claimLineItems ){
           String result='';
           HOT_Claim__c newClaim = new HOT_Claim__c();
           newClaim.UserPersonNumber__c=userPersonNumber;
           newClaim.UserPhoneNumber__c=userPhoneNumber;
           newclaim.UserName__c=userName;
           if(onEmployer=='true'){
                newClaim.onEmployer__c=true;
                newClaim.EmployerName__c=employerName;
                newClaim.OrganizationNumber__c=organizationNumber;
                Decimal strToDec = decimal.valueOf(employerExpensesPerHour);
                newClaim.EmployerExpensesPerHour__c=strToDec;
           }
           else{
                newClaim.onEmployer__c=false;
           }
           newClaim.ClaimType__c=claimType;

           insert newClaim;

           //insert her


           //lag claim line items her
        //     for (Map<String, Object> claimLineItem : claimLineItems) {
        //         String hasTravelToValue = String.valueOf(claimLineItem.get('hasTravelTo'));
        //         result+=hasTravelToValue;
        // }
        return result;
    }
}