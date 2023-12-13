public without sharing class hot_ClaimController {
    @AuraEnabled
       public static String createNewClaimFromCommunity(String userName, String userPersonNumber, String userPhoneNumber, String claimType, String onEmployer, String employerName, String organizationNumber, String employerExpensesPerHour, List<Map<String, Object>> claimLineItems ){
            String result='';
            List<String> idents = new List<String>();

             if (!String.isBlank(userPersonNumber)) {
                    idents.add(userPersonNumber.replaceAll(' ', ''));
                }
                if (!String.isBlank(userName)) {
                     idents.add(userName);
                }
                if (!String.isBlank(userPhoneNumber)) {
                    idents = addUserPhoneVariations(idents, userPhoneNumber);
                }
                if (!String.isBlank(organizationNumber)) {
                     idents.add(organizationNumber);
                }
            List<Account> account=getAccount(idents);
            if(account.size()!=1){
                result='no account';
                return result;
            }
            else{
                if(onEmployer=='true'){
                    List<Account> organization=getOrganization(idents);
                    if (onEmployer == 'true' && (organization.isEmpty() || organization[0].INT_OrganizationNumber__c != organizationNumber)) {
                        result = 'no organization';
                        return result;
                    } else {
                        // Check if the organization list is not empty before accessing its elements
                        if (!organization.isEmpty()) {
                            // create organization claim
                            result = createClaimOrganization(account[0], organization[0], claimType, onEmployer, employerName, organizationNumber, employerExpensesPerHour, claimLineItems);
                        } else {
                            result = 'no organization'; // Handle the case where the organization list is empty
                        }
                    }
                }
                else{
                    //create self claim
                    result=createClaimSelf(account[0], claimType, claimLineItems);
                }
            }
        return result;
    }
    private static String createClaimLineItems(HOT_Claim__c claim, List<Map<String, Object>> claimLineItems){
        List<HOT_ClaimLineItem__c> claimLineItemList = new List<HOT_ClaimLineItem__c>();
             for (Map<String, Object> claimLineItem : claimLineItems) {
                HOT_ClaimLineItem__c cli = new HOT_ClaimLineItem__c();
                cli.Claim__c=claim.Id;
                // String dateString = claimLineItem.get('date');
                // Date convertedDate = Date.valueOf(dateString);
                // cli.Date__c =convertedDate;
                // cli.Task__c=String.valueOf(claimLineItem.get('task'));
                // String startTimeString = (String)claimLineItem.get('startTimeString');
                // cli.StartTime__c = DateTime.valueOf(startTimeString);
                // String endTimeString = (String)claimLineItem.get('endTimeString');
                // cli.EndTime__c = DateTime.valueOf(endTimeString);


                String hasTravelToValue = String.valueOf(claimLineItem.get('hasTravelTo'));
                if(hasTravelToValue=='false' ||hasTravelToValue=='null' || hasTravelToValue==null){
                    cli.HasTravelTo__c=false;
                }
                else{
                    cli.HasTravelTo__c=true;
                    //legg inn tider her
                }
                String hasTravelFromValue = String.valueOf(claimLineItem.get('hasTravelFrom'));
                if(hasTravelFromValue=='false' ||hasTravelFromValue=='null' || hasTravelFromValue==null){
                    cli.HasTravelFrom__c=false;
                }
                else{
                    cli.HasTravelFrom__c=true;
                    //legg inn tider her
                }
                claimLineItemList.add(cli);
         }
         try{
            insert claimLineItemList;
            return 'la'+claimLineItemList.size();
        }
        catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
            logger.publishSynch();
            return e.getMessage();
        }
    }
    private static String createClaimSelf(Account account, String claimType, List<Map<String, Object>> claimLineItems ){
        User currentUser = [SELECT Id, AccountId, Account.CRM_Person__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        HOT_Claim__c newClaim = new HOT_Claim__c();
        newClaim.Claimant__c=currentUser.AccountId;
        newclaim.Account__c=account.Id;
        newClaim.onEmployer__c=false;
        newClaim.Type__c=claimType;


         try{
            insert newClaim;
            String he=createClaimLineItems(newClaim, claimLineItems);
            return 'ok'+he;
        }
        catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
            logger.publishSynch();
            return e.getMessage();
        }
    }
    private static String createClaimOrganization(Account account, Account organization, String claimType, String onEmployer, String employerName, String organizationNumber, String employerExpensesPerHour, List<Map<String, Object>> claimLineItems ){
        User currentUser = [SELECT Id, AccountId, Account.CRM_Person__c FROM User WHERE Id = :UserInfo.getUserId()];

        HOT_Claim__c newClaim = new HOT_Claim__c();
        newClaim.Claimant__c=currentUser.AccountId;
        newclaim.Account__c=account.Id;
        newClaim.Organization__c=organization.Id;
        newClaim.onEmployer__c=true;
        newClaim.EmployerName__c=employerName;
        newClaim.OrganizationNumber__c=organizationNumber;
        Decimal strToDec = decimal.valueOf(employerExpensesPerHour);
        newClaim.EmployerExpensesPerHour__c=strToDec;
        newClaim.Type__c=claimType;

        try{
            insert newClaim;
            return 'ok';
        }
        catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
            logger.publishSynch();
            return e.getMessage();
        }
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
    private static List<Account> getOrganization(List<String> idents){
            List<Account> accounts = [
            SELECT
                Id,
                Name,
                INT_OrganizationNumber__c
            FROM Account
            WHERE INT_OrganizationNumber__c IN :idents
        ];
        return accounts;
    }
}