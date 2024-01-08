public without sharing class HOT_ClaimController {
    @AuraEnabled
       public static String createNewClaimFromCommunity(String userName, String userPersonNumber, String userPhoneNumber, String claimType, String onEmployer, String employerName, String organizationNumber, String employerExpensesPerHour, List<Map<String, Object>> claimLineItems ){
            String result='';
            Boolean claimCreatedFromIdent=false;
            List<String> idents = new List<String>();

             if (!String.isBlank(userPersonNumber)) {
                    idents.add(userPersonNumber.replaceAll(' ', ''));
                    claimCreatedFromIdent=true;
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
                        if (!organization.isEmpty()) {
                            result = createClaimOrganization(claimCreatedFromIdent, userPersonNumber, userPhoneNumber, account[0], organization[0], claimType, onEmployer, employerName, organizationNumber, employerExpensesPerHour, claimLineItems);
                        } else {
                            result = 'no organization'; 
                        }
                    }
                }
                else{
                    //create self claim
                    result=createClaimSelf(claimCreatedFromIdent,userPersonNumber, userPhoneNumber, account[0], claimType, claimLineItems);
                }
            }
        return result;
    }
    private static String createClaimLineItems(HOT_Claim__c claim, List<Map<String, Object>> claimLineItems){
        List<HOT_ClaimLineItem__c> claimLineItemList = new List<HOT_ClaimLineItem__c>();
             for (Map<String, Object> claimLineItem : claimLineItems) {
                HOT_ClaimLineItem__c cli = new HOT_ClaimLineItem__c();
                cli.Claim__c=claim.Id;

                String dateClaim = String.valueOf(claimLineItem.get('date'));
                Date convertedDate = Date.valueOf(dateClaim);
                cli.Date__c =convertedDate;
        
                cli.TypeOfTask__c=String.valueOf(claimLineItem.get('task'));
                String startTimeClaim =String.valueOf(claimLineItem.get('startTime'));
                Long timestampMillisStart = Long.valueOf(startTimeClaim);
                Datetime convertedDatetimeStart = Datetime.newInstance(timestampMillisStart);
                cli.StartTime__c = convertedDatetimeStart;

                String endTimeClaim =String.valueOf(claimLineItem.get('endTime'));
                Long timestampMillisEnd = Long.valueOf(endTimeClaim);
                Datetime convertedDatetimeEnd = Datetime.newInstance(timestampMillisEnd);
                cli.EndTime__c = convertedDatetimeEnd;

                cli.AdditionalInformation__c=String.valueOf(claimLineItem.get('additionalInformation'));

                String hasTravelToValue = String.valueOf(claimLineItem.get('hasTravelTo'));
                if(hasTravelToValue=='false' ||hasTravelToValue=='null' || hasTravelToValue==null){
                    cli.HasTravelTo__c=false;
                }
                else{
                    cli.HasTravelTo__c=true;

                    String dateTravelTo = String.valueOf(claimLineItem.get('dateTravelTo'));
                    Date convertedTravelToDate = Date.valueOf(dateTravelTo);
                    cli.TravelTo__c =convertedTravelToDate;

                    String travelToStartTime =String.valueOf(claimLineItem.get('startTimeTravelTo'));
                    Long timestampMillisTravelToStart = Long.valueOf(travelToStartTime);
                    Datetime convertedDatetimeTravelToStart = Datetime.newInstance(timestampMillisTravelToStart);
                    cli.TravelToStartTime__c = convertedDatetimeTravelToStart;

                     String travelToEndTime =String.valueOf(claimLineItem.get('endTimeTravelTo'));
                    Long timestampMillisTravelToEnd = Long.valueOf(travelToEndTime);
                    Datetime convertedDatetimeTravelToEnd = Datetime.newInstance(timestampMillisTravelToEnd);
                    cli.TravelToEndTime__c = convertedDatetimeTravelToEnd;
                }
                String hasTravelFromValue = String.valueOf(claimLineItem.get('hasTravelFrom'));
                if(hasTravelFromValue=='false' ||hasTravelFromValue=='null' || hasTravelFromValue==null){
                    cli.HasTravelFrom__c=false;
                }
                else{
                    cli.HasTravelFrom__c=true;

                    String dateTravelFrom = String.valueOf(claimLineItem.get('dateTravelFrom'));
                    Date convertedTravelFromDate = Date.valueOf(dateTravelFrom);
                    cli.TravelFrom__c =convertedTravelFromDate;

                    String travelFromStartTime =String.valueOf(claimLineItem.get('startTimeTravelFrom'));
                    Long timestampMillisTravelFromStart = Long.valueOf(travelFromStartTime);
                    Datetime convertedDatetimeTravelFromStart = Datetime.newInstance(timestampMillisTravelFromStart);
                    cli.TravelFromStartTime__c = convertedDatetimeTravelFromStart;

                    String travelFromEndTime =String.valueOf(claimLineItem.get('endTimeTravelFrom'));
                    Long timestampMillisTravelFromEnd = Long.valueOf(travelFromEndTime);
                    Datetime convertedDatetimeTravelFromEnd = Datetime.newInstance(timestampMillisTravelFromEnd);
                    cli.TravelFromEndTime__c = convertedDatetimeTravelFromEnd;
                }
                claimLineItemList.add(cli);
         }
         try{
            insert claimLineItemList;
            return '';
        }
        catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
            logger.publishSynch();
            return e.getMessage();
        }
    }
    private static String createClaimSelf(Boolean claimCreatedFromIdent, String userPersonNumber, String userPhoneNumber, Account account, String claimType, List<Map<String, Object>> claimLineItems ){
        User currentUser = [SELECT Id, AccountId, Account.CRM_Person__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        HOT_Claim__c newClaim = new HOT_Claim__c();
        newClaim.Claimant__c=currentUser.AccountId;
        newclaim.Account__c=account.Id;
        newClaim.onEmployer__c=false;
        newClaim.Type__c=claimType;
        newClaim.ClaimCreatedFromIdent__c=claimCreatedFromIdent;
        newClaim.UserPersonNumber__c=userPersonNumber;
        newClaim.UserPhoneNumber__c=userPhoneNumber;

         try{
            insert newClaim;
            String result=createClaimLineItems(newClaim, claimLineItems);
            return 'ok'+result;
        }
        catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
            logger.publishSynch();
            return e.getMessage();
        }
    }
    private static String createClaimOrganization(Boolean claimCreatedFromIdent,String userPersonNumber, String userPhoneNumber, Account account, Account organization, String claimType, String onEmployer, String employerName, String organizationNumber, String employerExpensesPerHour, List<Map<String, Object>> claimLineItems ){
        User currentUser = [SELECT Id, AccountId, Account.CRM_Person__c FROM User WHERE Id = :UserInfo.getUserId()];

        HOT_Claim__c newClaim = new HOT_Claim__c();
        newClaim.UserPersonNumber__c=userPersonNumber;
        newClaim.Claimant__c=currentUser.AccountId;
        newclaim.Account__c=account.Id;
        newClaim.Organization__c=organization.Id;
        newClaim.onEmployer__c=true;
        newClaim.EmployerName__c=employerName;
        newClaim.OrganizationNumber__c=organizationNumber;
        Decimal strToDec = decimal.valueOf(employerExpensesPerHour);
        newClaim.EmployerExpensesPerHour__c=strToDec;
        newClaim.Type__c=claimType;
        newClaim.ClaimCreatedFromIdent__c=claimCreatedFromIdent;
        newClaim.UserPhoneNumber__c=userPhoneNumber;


        try{
            insert newClaim;
            String result=createClaimLineItems(newClaim, claimLineItems);
            return 'ok'+result;
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
       @AuraEnabled(cacheable=true)
    public static List<HOT_Claim__c> getMyClaims(){
            User currentUser = [SELECT Id, AccountId, Account.CRM_Person__c FROM User WHERE Id = :UserInfo.getUserId()];
            List<HOT_Claim__c> claims = [
            SELECT
                Id,
                Name, Claimant__c, ClaimCreatedFromIdent__c, UserPersonNumber__c, UserPhoneNumber__c, CreatedDate, Account__r.Name, Status__c, OnEmployer__c, Organization__r.Name, Type__c, CommentFromNAV__c, CommentFromUser__c, EmployerExpensesPerHour__c, OrganizationNumber__c, EmployerName__c
            FROM HOT_Claim__c
        ];
        return claims;
    }
    @AuraEnabled(cacheable=true)
    public static List<HOT_Claim__c> getClaimsToApprove(){
            User currentUser = [SELECT Id, AccountId, Account.CRM_Person__c FROM User WHERE Id = :UserInfo.getUserId()];
            List<HOT_Claim__c> claims = [
            SELECT
                Id,
                Name, Claimant__c, Account__c, CreatedDate, Account__r.Name, Status__c, OnEmployer__c, Organization__r.Name, Type__c, Claimant__r.Name, ApprovedByUser__c
            FROM HOT_Claim__c WHERE (Claimant__c!= NULL) AND (Status__c='Sent') AND (NumberOfClaimLineItems__c>0) AND (ApprovedByUser__c=FALSE)];
        return claims;
    }
    @AuraEnabled
    public static String approveClaim(String recordId, String comment){
        List<HOT_Claim__c> claims = [SELECT Id, Status__c, ApprovedByUser__c, CommentFromUser__c FROM HOT_Claim__c WHERE Id=:recordId];
        if(claims.size()==1){
            claims[0].ApprovedByUser__c=true;
            claims[0].Status__c='Approved by user';
            claims[0].CommentFromUser__c=comment;
            try{
                update claims;
                return 'ok';
            }
                catch (Exception e) {
                LoggerUtility logger = new LoggerUtility();
                logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
                logger.publishSynch();
                return e.getMessage();
            }
        }else{
            return '';
        }
    }
    @AuraEnabled
    public static String declineClaim(String recordId, String comment){
        List<HOT_Claim__c> claims = [SELECT Id, Status__c, ApprovedByUser__c, CommentFromUser__c FROM HOT_Claim__c WHERE Id=:recordId];
        if(claims.size()==1){
            claims[0].ApprovedByUser__c=false;
            claims[0].Status__c='Declined by user';
            claims[0].CommentFromUser__c=comment;
            try{
                update claims;
                return 'ok';
            }
                catch (Exception e) {
                LoggerUtility logger = new LoggerUtility();
                logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
                logger.publishSynch();
                return e.getMessage();
            }
        }else{
            return '';
        }
    }
     @AuraEnabled
    public static String cancelClaim(String recordId){
        List<HOT_Claim__c> claims = [SELECT Id, Status__c, ApprovedByUser__c FROM HOT_Claim__c WHERE Id=:recordId];
        if(claims.size()==1){
            claims[0].Status__c='Withdrawn';
            try{
                update claims;
                return 'ok';
            }
                catch (Exception e) {
                LoggerUtility logger = new LoggerUtility();
                logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
                logger.publishSynch();
                return e.getMessage();
            }
        }else{
            return '';
        }
    }
     @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getTimes(String claimId) {
        List<Map<String, String>> times = new List<Map<String, String>>();
        List<HOT_ClaimLineItem__c> claimLineItems = [
            SELECT Id, StartTime__c, TravelFromStartTime__c, TravelToStartTime__c,EndTime__c, TravelFromEndTime__c, TravelToEndTime__c, HasTravelFrom__c, HasTravelTo__c, TravelFrom__c, TravelTo__c, TypeOfTask__c, AdditionalInformation__c
            FROM HOT_ClaimLineItem__c
            WHERE Claim__r.Id =:claimId
            ORDER BY StartTime__c ASC
        ];
        for (HOT_ClaimLineItem__c cli : claimLineItems) {
            Map<String, String> timeMap = new Map<String, String>();
            timeMap.put('id', (String) cli.Id);
            Date tempDate = cli.StartTime__c.date();
            timeMap.put('date', Datetime.newInstance(tempDate, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd'));
            timeMap.put('startTime', String.valueOf(cli.StartTime__c.getTime()));
            timeMap.put('endTime', String.valueOf(cli.EndTime__c.getTime()));

            //Date tempDateTravelTo = cli.TravelTo__c.date();
            Date tempDateTravelTo = Date.valueOf(cli.TravelTo__c);
            if(cli.HasTravelTo__c){
                timeMap.put('dateTravelTo', Datetime.newInstance(tempDateTravelTo, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd'));
                timeMap.put('startTimeTravelTo', String.valueOf(cli.TravelToStartTime__c.getTime()));
                timeMap.put('endTimeTravelTo', String.valueOf(cli.TravelToEndTime__c.getTime()));
            }
            if(cli.HasTravelFrom__c){
                Date tempDateTravelFrom = Date.valueOf(cli.TravelFrom__c);
                timeMap.put('dateTravelFrom', Datetime.newInstance(tempDateTravelFrom, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd'));
                timeMap.put('startTimeTravelFrom', String.valueOf(cli.TravelFromStartTime__c.getTime()));
                timeMap.put('endTimeTravelFrom', String.valueOf(cli.TravelFromEndTime__c.getTime()));
            }
            //Date tempDateTravelFrom = cli.TravelFrom__c.date();
            timeMap.put('task', cli.TypeOfTask__c);
            timeMap.put('hasTravelTo', String.valueOf(cli.HasTravelTo__c));
            timeMap.put('hasTravelFrom', String.valueOf(cli.HasTravelFrom__c));
            timeMap.put('additionalInformation', String.valueOf(cli.AdditionalInformation__c));
            


            times.add(timeMap);
        }
        return times;
    }
    @AuraEnabled
    public static String updateClaim(String recordId, String claimType, String employerExpensesPerHour){
        String result='';
        User currentUser = [SELECT Id, AccountId, Account.CRM_Person__c FROM User WHERE Id = :UserInfo.getUserId()];
            List<HOT_Claim__c> claims = [
            SELECT
                Id,
                Name, Claimant__c,OnEmployer__c, Type__c, EmployerExpensesPerHour__c, OrganizationNumber__c,Organization__c, EmployerName__c
            FROM HOT_Claim__c WHERE Id=:recordId
        ];
        for(HOT_Claim__c claim: claims){
            if(claimType == 'Arbeid'){
                Decimal strToDec = decimal.valueOf(employerExpensesPerHour);
                claim.EmployerExpensesPerHour__c=strToDec;
            }
            else{
                claim.EmployerExpensesPerHour__c=NULL;
                claim.OrganizationNumber__c=NULL;
                claim.Organization__c=NULL;
                claim.EmployerName__c=NULL;
                claim.OnEmployer__c=false;
            }
            claim.Type__c=claimType;
        }
         try{
            update claims;
           // String result=createClaimLineItems(newClaim, claimLineItems);
            return 'ok'+result;
        }
        catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
            logger.publishSynch();
            return e.getMessage();
        }

    }
}
