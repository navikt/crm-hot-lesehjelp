public without sharing class HOT_ClaimController {
    @AuraEnabled
    public static String createNewClaimFromCommunity(
        String userName,
        String userPersonNumber,
        String userPhoneNumber,
        String claimType,
        String onEmployer,
        String employerName,
        String organizationNumber,
        String employerExpensesPerHour,
        List<Map<String, Object>> claimLineItems
    ) {
        String result = '';
        Boolean claimCreatedFromIdent = false;
        List<String> idents = new List<String>();

        if (!String.isBlank(userPersonNumber)) {
            idents.add(userPersonNumber.replaceAll(' ', ''));
            claimCreatedFromIdent = true;
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
        List<Account> account = getAccount(idents);
        if (account.size() != 1) {
            result = 'no account';
            return result;
        } else {
            if (onEmployer == 'true') {
                List<Account> organization = getOrganization(idents);
                if (
                    onEmployer == 'true' &&
                    (organization.isEmpty() || organization[0].INT_OrganizationNumber__c != organizationNumber)
                ) {
                    result = 'no organization';
                    return result;
                } else {
                    if (!organization.isEmpty()) {
                        result = createClaimOrganization(
                            claimCreatedFromIdent,
                            userName,
                            userPersonNumber,
                            userPhoneNumber,
                            account[0],
                            organization[0],
                            claimType,
                            onEmployer,
                            employerName,
                            organizationNumber,
                            employerExpensesPerHour,
                            claimLineItems
                        );
                    } else {
                        result = 'no organization';
                    }
                }
            } else {
                //create self claim
                result = createClaimSelf(
                    claimCreatedFromIdent,
                    userName,
                    userPersonNumber,
                    userPhoneNumber,
                    account[0],
                    claimType,
                    claimLineItems
                );
            }
        }
        return result;
    }
    private static String createClaimLineItems(HOT_Claim__c claim, List<Map<String, Object>> claimLineItems) {
        List<HOT_ClaimLineItem__c> claimLineItemList = new List<HOT_ClaimLineItem__c>();
        for (Map<String, Object> claimLineItem : claimLineItems) {
            HOT_ClaimLineItem__c cli = new HOT_ClaimLineItem__c();
            cli.Claim__c = claim.Id;

            String dateClaim = String.valueOf(claimLineItem.get('date'));
            Date convertedDate = Date.valueOf(dateClaim);
            cli.Date__c = convertedDate;

            cli.TypeOfTask__c = String.valueOf(claimLineItem.get('task'));
            String startTimeClaim = String.valueOf(claimLineItem.get('startTime'));
            Long timestampMillisStart = Long.valueOf(startTimeClaim);
            Datetime convertedDatetimeStart = Datetime.newInstance(timestampMillisStart);
            cli.StartTime__c = convertedDatetimeStart;

            String endTimeClaim = String.valueOf(claimLineItem.get('endTime'));
            Long timestampMillisEnd = Long.valueOf(endTimeClaim);
            Datetime convertedDatetimeEnd = Datetime.newInstance(timestampMillisEnd);
            cli.EndTime__c = convertedDatetimeEnd;
            String hasAdditionalInformation = String.valueOf(claimLineItem.get('hasAdditionalInformation'));
            if (hasAdditionalInformation == 'true') {
                cli.AdditionalInformation__c = String.valueOf(claimLineItem.get('additionalInformation'));
            }
            String hasTravelToValue = String.valueOf(claimLineItem.get('hasTravelTo'));
            if (hasTravelToValue == 'false' || hasTravelToValue == 'null' || hasTravelToValue == null) {
                cli.HasTravelTo__c = false;
            } else {
                cli.HasTravelTo__c = true;

                String dateTravelTo = String.valueOf(claimLineItem.get('dateTravelTo'));
                Date convertedTravelToDate = Date.valueOf(dateTravelTo);
                cli.TravelTo__c = convertedTravelToDate;

                String travelToStartTime = String.valueOf(claimLineItem.get('startTimeTravelTo'));
                Long timestampMillisTravelToStart = Long.valueOf(travelToStartTime);
                Datetime convertedDatetimeTravelToStart = Datetime.newInstance(timestampMillisTravelToStart);
                cli.TravelToStartTime__c = convertedDatetimeTravelToStart;

                String travelToEndTime = String.valueOf(claimLineItem.get('endTimeTravelTo'));
                Long timestampMillisTravelToEnd = Long.valueOf(travelToEndTime);
                Datetime convertedDatetimeTravelToEnd = Datetime.newInstance(timestampMillisTravelToEnd);
                cli.TravelToEndTime__c = convertedDatetimeTravelToEnd;
            }
            String hasTravelFromValue = String.valueOf(claimLineItem.get('hasTravelFrom'));
            if (hasTravelFromValue == 'false' || hasTravelFromValue == 'null' || hasTravelFromValue == null) {
                cli.HasTravelFrom__c = false;
            } else {
                cli.HasTravelFrom__c = true;

                String dateTravelFrom = String.valueOf(claimLineItem.get('dateTravelFrom'));
                Date convertedTravelFromDate = Date.valueOf(dateTravelFrom);
                cli.TravelFrom__c = convertedTravelFromDate;

                String travelFromStartTime = String.valueOf(claimLineItem.get('startTimeTravelFrom'));
                Long timestampMillisTravelFromStart = Long.valueOf(travelFromStartTime);
                Datetime convertedDatetimeTravelFromStart = Datetime.newInstance(timestampMillisTravelFromStart);
                cli.TravelFromStartTime__c = convertedDatetimeTravelFromStart;

                String travelFromEndTime = String.valueOf(claimLineItem.get('endTimeTravelFrom'));
                Long timestampMillisTravelFromEnd = Long.valueOf(travelFromEndTime);
                Datetime convertedDatetimeTravelFromEnd = Datetime.newInstance(timestampMillisTravelFromEnd);
                cli.TravelFromEndTime__c = convertedDatetimeTravelFromEnd;
            }
            if (cli.HasTravelFrom__c || cli.HasTravelTo__c) {
                Integer travelDistance = Integer.valueOf(claimLineItem.get('travelDistance'));
                cli.TravelDistance__c = travelDistance;
            }
            else{
                cli.TravelDistance__c=0;
            }
            claimLineItemList.add(cli);
        }
        try {
            insert claimLineItemList;
            return '';
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
            logger.publishSynch();
            return e.getMessage();
        }
    }
    private static String createClaimSelf(
        Boolean claimCreatedFromIdent,
        String userName,
        String userPersonNumber,
        String userPhoneNumber,
        Account account,
        String claimType,
        List<Map<String, Object>> claimLineItems
    ) {
        User currentUser = [SELECT Id, AccountId, Account.CRM_Person__c FROM User WHERE Id = :UserInfo.getUserId()];

        HOT_Claim__c newClaim = new HOT_Claim__c();
        newClaim.Claimant__c = currentUser.AccountId;
        newclaim.Account__c = account.Id;
        newClaim.onEmployer__c = false;
        newClaim.Type__c = claimType;
        newClaim.ClaimCreatedFromIdent__c = claimCreatedFromIdent;
        newClaim.UserName__c = userName;
        newClaim.UserPersonNumber__c = userPersonNumber;
        newClaim.UserPhoneNumber__c = userPhoneNumber;

        try {
            insert newClaim;
            String result = createClaimLineItems(newClaim, claimLineItems);
            return 'ok' + result;
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
            logger.publishSynch();
            return e.getMessage();
        }
    }
    private static String createClaimOrganization(
        Boolean claimCreatedFromIdent,
        String userName,
        String userPersonNumber,
        String userPhoneNumber,
        Account account,
        Account organization,
        String claimType,
        String onEmployer,
        String employerName,
        String organizationNumber,
        String employerExpensesPerHour,
        List<Map<String, Object>> claimLineItems
    ) {
        User currentUser = [SELECT Id, AccountId, Account.CRM_Person__c FROM User WHERE Id = :UserInfo.getUserId()];

        HOT_Claim__c newClaim = new HOT_Claim__c();
        newClaim.UserName__c = userName;
        newClaim.UserPersonNumber__c = userPersonNumber;
        newClaim.UserPhoneNumber__c = userPhoneNumber;
        newClaim.Claimant__c = currentUser.AccountId;
        newclaim.Account__c = account.Id;
        newClaim.Organization__c = organization.Id;
        newClaim.onEmployer__c = true;
        newClaim.EmployerName__c = employerName;
        newClaim.OrganizationNumber__c = organizationNumber;
        Integer strToInt = Integer.valueOf(employerExpensesPerHour);
        newClaim.EmployerExpensesPerHour__c = strToInt;
        newClaim.Type__c = claimType;
        newClaim.ClaimCreatedFromIdent__c = claimCreatedFromIdent;

        try {
            insert newClaim;
            String result = createClaimLineItems(newClaim, claimLineItems);
            return 'ok' + result;
        } catch (Exception e) {
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
    private static List<Account> getAccount(List<String> idents) {
        List<Account> accounts = [
            SELECT Id, Name, INT_PersonIdent__c, CRM_Person__c, INT_KrrMobilePhone__c
            FROM Account
            WHERE INT_PersonIdent__c IN :idents OR INT_KrrMobilePhone__c IN :idents
        ];
        return accounts;
    }
    private static List<Account> getOrganization(List<String> idents) {
        List<Account> accounts = [
            SELECT Id, Name, INT_OrganizationNumber__c
            FROM Account
            WHERE INT_OrganizationNumber__c IN :idents
        ];
        return accounts;
    }
    @AuraEnabled(cacheable=true)
    public static List<Account> getOrganizationInfo(String organizationNumber) {
        List<Account> account = [
            SELECT Id, Name, INT_OrganizationNumber__c
            FROM Account
            WHERE INT_OrganizationNumber__c = :organizationNumber
        ];
        return account;
    }
    @AuraEnabled(cacheable=true)
    public static List<HOT_Claim__c> getMyClaims() {
        User currentUser = [SELECT Id, AccountId, Account.CRM_Person__c FROM User WHERE Id = :UserInfo.getUserId()];
        List<HOT_Claim__c> claims = [
            SELECT
                Id,
                Name,
                Claimant__c,
                ClaimCreatedFromIdent__c,
                UserPersonNumber__c,
                UserPhoneNumber__c,
                CreatedDate,
                UserName__c,
                toLabel(Status__c),
                OnEmployer__c,
                Organization__r.Name,
                Type__c,
                CommentFromNAV__c,
                CommentFromUser__c,
                EmployerExpensesPerHour__c,
                OrganizationNumber__c,
                EmployerName__c,
                ApprovedByNAV__c
            FROM HOT_Claim__c
            WHERE Claimant__c = :currentUser.AccountId
        ];
        return claims;
    }
    @AuraEnabled(cacheable=true)
    public static List<HOT_Claim__c> getClaimsToApprove() {
        User currentUser = [SELECT Id, AccountId, Account.CRM_Person__c FROM User WHERE Id = :UserInfo.getUserId()];
        List<HOT_Claim__c> claims = [
            SELECT
                Id,
                Name,
                Claimant__c,
                Account__c,
                CreatedDate,
                Account__r.Name,
                Status__c,
                OnEmployer__c,
                Organization__r.Name,
                Type__c,
                Claimant__r.Name,
                ApprovedByUser__c,
                CommentFromUser__c
            FROM HOT_Claim__c
            WHERE Claimant__c != NULL AND NumberOfClaimLineItems__c > 0 AND Account__c = :currentUser.AccountId
        ];
        return claims;
    }
    @AuraEnabled
    public static String approveClaim(String recordId, String comment) {
        List<HOT_Claim__c> claims = [
            SELECT Id, Status__c, ApprovedByUser__c, CommentFromUser__c
            FROM HOT_Claim__c
            WHERE Id = :recordId
        ];
        if (claims.size() == 1) {
            claims[0].ApprovedByUser__c = true;
            claims[0].Status__c = 'Approved by user';
            claims[0].CommentFromUser__c = comment;
            try {
                update claims;
                return 'ok';
            } catch (Exception e) {
                LoggerUtility logger = new LoggerUtility();
                logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
                logger.publishSynch();
                return e.getMessage();
            }
        } else {
            return '';
        }
    }
    @AuraEnabled
    public static String declineClaim(String recordId, String comment) {
        List<HOT_Claim__c> claims = [
            SELECT Id, Status__c, ApprovedByUser__c, CommentFromUser__c
            FROM HOT_Claim__c
            WHERE Id = :recordId
        ];
        if (claims.size() == 1) {
            claims[0].ApprovedByUser__c = false;
            claims[0].Status__c = 'Declined by user';
            claims[0].CommentFromUser__c = comment;
            try {
                update claims;
                return 'ok';
            } catch (Exception e) {
                LoggerUtility logger = new LoggerUtility();
                logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
                logger.publishSynch();
                return e.getMessage();
            }
        } else {
            return '';
        }
    }
    @AuraEnabled
    public static String cancelClaim(String recordId) {
        List<HOT_Claim__c> claims = [SELECT Id, Status__c, ApprovedByUser__c FROM HOT_Claim__c WHERE Id = :recordId];
        if (claims.size() == 1) {
            claims[0].Status__c = 'Withdrawn';
            try {
                update claims;
                return 'ok';
            } catch (Exception e) {
                LoggerUtility logger = new LoggerUtility();
                logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
                logger.publishSynch();
                return e.getMessage();
            }
        } else {
            return '';
        }
    }
    @AuraEnabled(cacheable=false)
    public static List<Map<String, String>> getTimes(String claimId) {
        List<Map<String, String>> times = new List<Map<String, String>>();
        List<HOT_ClaimLineItem__c> claimLineItems = [
            SELECT
                Id,
                Date__c,
                StartTime__c,
                TravelFromStartTime__c,
                TravelToStartTime__c,
                EndTime__c,
                TravelFromEndTime__c,
                TravelToEndTime__c,
                HasTravelFrom__c,
                HasTravelTo__c,
                TravelFrom__c,
                TravelTo__c,
                TypeOfTask__c,
                AdditionalInformation__c,
                TravelDistance__c
            FROM HOT_ClaimLineItem__c
            WHERE Claim__r.Id = :claimId
            ORDER BY Date__c ASC
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
            if (cli.HasTravelTo__c) {
                timeMap.put(
                    'dateTravelTo',
                    Datetime.newInstance(tempDateTravelTo, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd')
                );
                timeMap.put('startTimeTravelTo', String.valueOf(cli.TravelToStartTime__c.getTime()));
                timeMap.put('endTimeTravelTo', String.valueOf(cli.TravelToEndTime__c.getTime()));
            }
            if (cli.HasTravelFrom__c) {
                Date tempDateTravelFrom = Date.valueOf(cli.TravelFrom__c);
                timeMap.put(
                    'dateTravelFrom',
                    Datetime.newInstance(tempDateTravelFrom, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd')
                );
                timeMap.put('startTimeTravelFrom', String.valueOf(cli.TravelFromStartTime__c.getTime()));
                timeMap.put('endTimeTravelFrom', String.valueOf(cli.TravelFromEndTime__c.getTime()));
            }
            if (cli.HasTravelFrom__c || cli.HasTravelTo__c) {
                timeMap.put('travelDistance', String.valueOf(cli.TravelDistance__c));
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
    public static String updateClaim(
        String recordId,
        String claimType,
        String employerExpensesPerHour,
        String onEmployer,
        List<Map<String, Object>> claimLineItems
    ) {
        String result = '';
        User currentUser = [SELECT Id, AccountId, Account.CRM_Person__c FROM User WHERE Id = :UserInfo.getUserId()];
        List<HOT_Claim__c> claims = [
            SELECT
                Id,
                Name,
                Claimant__c,
                OnEmployer__c,
                Type__c,
                EmployerExpensesPerHour__c,
                OrganizationNumber__c,
                Organization__c,
                EmployerName__c,
                ApprovedByUser__c,
                ApprovedByNAV__c
            FROM HOT_Claim__c
            WHERE Id = :recordId AND Claimant__c = :currentUser.AccountId
        ];
        for (HOT_Claim__c claim : claims) {
            if (claimType == 'Arbeidsliv' && onEmployer == 'true') {
                Integer strToInt = Integer.valueOf(employerExpensesPerHour);
                claim.EmployerExpensesPerHour__c = strToInt;
            } else {
                claim.EmployerExpensesPerHour__c = null;
                claim.OrganizationNumber__c = null;
                claim.Organization__c = null;
                claim.EmployerName__c = null;
                claim.OnEmployer__c = false;
            }
            claim.Type__c = claimType;
            if (onEmployer == 'false') {
                claim.EmployerExpensesPerHour__c = null;
                claim.OrganizationNumber__c = null;
                claim.Organization__c = null;
                claim.EmployerName__c = null;
                claim.OnEmployer__c = false;
            }
            claim.Status__c = 'Sent';
            claim.ApprovedByNAV__c = false;
            claim.ApprovedByUser__c = false;
            claim.Entitlement__c = null;
            claim.CommentFromNAV__c = null;
            claim.CommentFromUser__c = null;
        }
        try {
            update claims;
            result = updateClaimLineItems(claims[0], claimLineItems);
            return 'ok' + result;
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
            logger.publishSynch();
            return e.getMessage();
        }
    }
    private static String updateClaimLineItems(HOT_Claim__c claim, List<Map<String, Object>> claimLineItems) {
        List<HOT_ClaimLineItem__c> claimLineItemList = [
            SELECT
                Id,
                Claim__c,
                Date__c,
                TypeOfTask__c,
                StartTime__c,
                EndTime__c,
                HasTravelTo__c,
                HasTravelFrom__c,
                TravelTo__c,
                TravelFrom__c,
                TravelToStartTime__c,
                TravelToEndTime__c,
                TravelFromStartTime__c,
                TravelFromEndTime__c,
                TravelDistance__c
            FROM HOT_ClaimLineItem__c
            WHERE Claim__c = :claim.Id
        ];

        //find and update records
        for (Map<String, Object> claimLineItem : claimLineItems) {
            for (HOT_ClaimLineItem__c cli : claimLineItemList) {
                if (cli.Id == claimLineItem.get('id')) {
                    String dateClaim = String.valueOf(claimLineItem.get('date'));
                    Date convertedDate = Date.valueOf(dateClaim);
                    cli.Date__c = convertedDate;

                    cli.TypeOfTask__c = String.valueOf(claimLineItem.get('task'));
                    String startTimeClaim = String.valueOf(claimLineItem.get('startTime'));
                    Long timestampMillisStart = Long.valueOf(startTimeClaim);
                    Datetime convertedDatetimeStart = Datetime.newInstance(timestampMillisStart);
                    cli.StartTime__c = convertedDatetimeStart;

                    String endTimeClaim = String.valueOf(claimLineItem.get('endTime'));
                    Long timestampMillisEnd = Long.valueOf(endTimeClaim);
                    Datetime convertedDatetimeEnd = Datetime.newInstance(timestampMillisEnd);
                    cli.EndTime__c = convertedDatetimeEnd;

                    cli.AdditionalInformation__c = String.valueOf(claimLineItem.get('additionalInformation'));

                    String hasTravelToValue = String.valueOf(claimLineItem.get('hasTravelTo'));
                    if (hasTravelToValue == 'false' || hasTravelToValue == 'null' || hasTravelToValue == null) {
                        cli.HasTravelTo__c = false;
                    } else {
                        cli.HasTravelTo__c = true;

                        String dateTravelTo = String.valueOf(claimLineItem.get('dateTravelTo'));
                        Date convertedTravelToDate = Date.valueOf(dateTravelTo);
                        cli.TravelTo__c = convertedTravelToDate;

                        String travelToStartTime = String.valueOf(claimLineItem.get('startTimeTravelTo'));
                        Long timestampMillisTravelToStart = Long.valueOf(travelToStartTime);
                        Datetime convertedDatetimeTravelToStart = Datetime.newInstance(timestampMillisTravelToStart);
                        cli.TravelToStartTime__c = convertedDatetimeTravelToStart;

                        String travelToEndTime = String.valueOf(claimLineItem.get('endTimeTravelTo'));
                        Long timestampMillisTravelToEnd = Long.valueOf(travelToEndTime);
                        Datetime convertedDatetimeTravelToEnd = Datetime.newInstance(timestampMillisTravelToEnd);
                        cli.TravelToEndTime__c = convertedDatetimeTravelToEnd;
                    }
                    String hasTravelFromValue = String.valueOf(claimLineItem.get('hasTravelFrom'));
                    if (hasTravelFromValue == 'false' || hasTravelFromValue == 'null' || hasTravelFromValue == null) {
                        cli.HasTravelFrom__c = false;
                    } else {
                        cli.HasTravelFrom__c = true;

                        String dateTravelFrom = String.valueOf(claimLineItem.get('dateTravelFrom'));
                        Date convertedTravelFromDate = Date.valueOf(dateTravelFrom);
                        cli.TravelFrom__c = convertedTravelFromDate;

                        String travelFromStartTime = String.valueOf(claimLineItem.get('startTimeTravelFrom'));
                        Long timestampMillisTravelFromStart = Long.valueOf(travelFromStartTime);
                        Datetime convertedDatetimeTravelFromStart = Datetime.newInstance(
                            timestampMillisTravelFromStart
                        );
                        cli.TravelFromStartTime__c = convertedDatetimeTravelFromStart;

                        String travelFromEndTime = String.valueOf(claimLineItem.get('endTimeTravelFrom'));
                        Long timestampMillisTravelFromEnd = Long.valueOf(travelFromEndTime);
                        Datetime convertedDatetimeTravelFromEnd = Datetime.newInstance(timestampMillisTravelFromEnd);
                        cli.TravelFromEndTime__c = convertedDatetimeTravelFromEnd;
                    }
                    if (cli.HasTravelFrom__c || cli.HasTravelTo__c) {
                        Integer travelDistance = Integer.valueOf(claimLineItem.get('travelDistance'));
                        cli.TravelDistance__c = travelDistance;
                    } else {
                        cli.TravelDistance__c = 0;
                    }
                }
            }
        }
        //find and delete records
        List<HOT_ClaimLineItem__c> recordToDelete = new List<HOT_ClaimLineItem__c>();

        for (HOT_ClaimLineItem__c cli : claimLineItemList) {
            Boolean found = false;
            for (Map<String, Object> claimLineItem : claimLineItems) {
                if (cli.Id == claimLineItem.get('id')) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                recordToDelete.add(cli);
            }
        }
        try {
            update claimLineItemList;
            delete recordToDelete;
            return '';
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
            logger.publishSynch();
            return e.getMessage();
        }
    }
    public static void setEntitlementOnClaim(Set<Id> claimIds) {
        List<HOT_Claim__c> claims = [SELECT Id, Account__c, Type__c FROM HOT_Claim__c WHERE Id IN :claimIds];

        Set<Id> accountIds = new Set<Id>();
        for (HOT_Claim__c claim : claims) {
            accountIds.add(claim.Account__c);
        }

        if (!accountIds.isEmpty()) {
            List<HOT_Entitlement__c> entitlements = [
                SELECT Id, FromDate__c, ToDate__c, Account__c, Type__c
                FROM HOT_Entitlement__c
                WHERE Account__c IN :accountIds
            ];

            if (!entitlements.isEmpty()) {
                List<HOT_ClaimLineItem__c> claimLineItems = [
                    SELECT Id, Claim__c, StartTime__c, EndTime__c
                    FROM HOT_ClaimLineItem__c
                    WHERE Claim__c IN :claimIds
                ];

                for (HOT_Claim__c claim : claims) {
                    DateTime earliestStartTime = null;
                    DateTime latestEndTime = null;

                    // Find earliest start time and latest end time for claim
                    for (HOT_ClaimLineItem__c claimLineItem : claimLineItems) {
                        if (claimLineItem.Claim__c == claim.Id) {
                            if (earliestStartTime == null || claimLineItem.StartTime__c < earliestStartTime) {
                                earliestStartTime = claimLineItem.StartTime__c;
                            }
                            if (latestEndTime == null || claimLineItem.EndTime__c > latestEndTime) {
                                latestEndTime = claimLineItem.EndTime__c;
                            }
                        }
                    }
                    claim.Entitlement__c = null;

                    for (HOT_Entitlement__c entitlement : entitlements) {
                        if (claim.Type__c == entitlement.Type__c && claim.Account__c == entitlement.Account__c) {
                            if (
                                entitlement.FromDate__c <= earliestStartTime &&
                                entitlement.ToDate__c >= latestEndTime
                            ) {
                                claim.Entitlement__c = entitlement.Id;
                                break;
                            }
                        }
                    }
                }
                try {
                    update claims;
                } catch (Exception e) {
                    LoggerUtility logger = new LoggerUtility();
                    logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
                    logger.publishSynch();
                }
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<HOT_Claim__c> getClaim(String recordId) {
        List<HOT_Claim__c> claim = [
            SELECT
                Id,
                Status__c,
                Entitlement__c,
                TotalHours__c,
                Entitlement__r.EntitledHours__c,
                Entitlement__r.EntitledHoursUsed__c
            FROM HOT_Claim__c
            WHERE Id = :recordId
        ];
        return claim;
    }
    @AuraEnabled(cacheable=true)
    public static List<HOT_Claim__c> getMyPreviousClaims() {
        User currentUser = [SELECT Id, AccountId, Account.CRM_Person__c FROM User WHERE Id = :UserInfo.getUserId()];
        List<HOT_Claim__c> claims = [
            SELECT Id, UserName__c, Claimant__c, CreatedDate, Account__c, UserPersonNumber__c, UserPhoneNumber__c
            FROM HOT_Claim__c
            WHERE Claimant__c = :currentUser.Account.Id AND (UserPersonNumber__c != NULL OR UserPhoneNumber__c != NULL)
            ORDER BY CreatedDate DESC
        ];
        List<HOT_Claim__c> latestClaims = new List<HOT_Claim__c>();
        Set<String> uniqueKeys = new Set<String>();

        for (HOT_Claim__c claim : claims) {
            String key = claim.UserPersonNumber__c != null ? claim.UserPersonNumber__c : claim.UserPhoneNumber__c;

            if (!uniqueKeys.contains(key)) {
                latestClaims.add(claim);
                uniqueKeys.add(key);
            }
        }

        return latestClaims;
    }
}
