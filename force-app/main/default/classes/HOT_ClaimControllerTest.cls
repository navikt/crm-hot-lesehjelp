@IsTest
public class HOT_ClaimControllerTest {
    @TestSetup
    static void setup() {
        User navEmployee = TestDataFactory_Community.getUsers(1, 'System Administrator', true, true)[0];
        System.runAs(navEmployee) {
            Account acc = new Account();
            acc.Name = 'Ola Lesehjelp';
            insert acc;
            Account acc2 = new Account();
            acc2.INT_PersonIdent__c = '01010101010';
            acc2.Name = 'Kari Bruker';
            acc2.INT_KrrMobilePhone__c = '12345678';
            insert acc2;
            Account acc3 = new Account();
            acc3.Name = 'NAV';
            acc3.INT_OrganizationNumber__c = '123456789';
            insert acc3;
            HOT_Claim__c claim = HOT_LesehjelpTestDataFactory.createClaim(acc2, acc);
            claim.UserPersonNumber__c = '01010101010';
            insert claim;

            HOT_Entitlement__c entitlement = HOT_LesehjelpTestDataFactory.createEntitlement(acc2);
            insert entitlement;

            Person__c personAcc2 = HOT_LesehjelpTestDataFactory.createPerson('12345678912');
            personAcc2.CRM_Account__c = acc2.Id;
            update personAcc2;

            // Oppsett portalbruker
            Account personAccount = TestDataFactory_Community.getPersonAccounts(1)[0];
            personAccount.LastName = 'PortalBruker';
            update personAccount;
            Person__c person = [SELECT INT_LastName__c, INT_MunicipalityNumber__c, CRM_Account__c FROM Person__c];
            person.CRM_Account__c = personAccount.Id;
            person.INT_MunicipalityNumber__c = '4601';
            Set<Id> personAccountIds = new Set<Id>();
            personAccountIds.add(personAccount.Id);
            update person;
            List<User> users = TestDataFactory_Community.getEmployerCommunityUser(
                personAccountIds,
                'Trial Customer Portal User',
                true
            );
        }
    }
    @IsTest
    static void checkAccessTest() {
        Account portalBrukerAccount = [
            SELECT Id
            FROM Account
            WHERE LastName = 'PortalBruker'
        ];

        HOT_Claim__c newClaim = HOT_LesehjelpTestDataFactory.createClaim(
            HOT_LesehjelpTestDataFactory.createAccount(true),
            portalBrukerAccount
        );
        insert newClaim;

        User portalBruker = [
            SELECT Id, AccountId
            FROM User
            WHERE AccountId = :portalBrukerAccount.Id
        ];

        System.assertEquals(false, HOT_ClaimController.checkAccess(newClaim.Id), 'Default user should not have access');
        System.runAs(portalBruker) {
            System.assertEquals(true, HOT_ClaimController.checkAccess(newClaim.Id), 'Claimant should have access');
        }
    }
    @IsTest
    static void setEntitlementOnClaimTest() {
        HOT_Claim__c claim = [SELECT Id FROM HOT_Claim__c];
        HOT_ClaimLineItem__c cli = HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        insert cli;
        Test.startTest();
        HOT_Claim__c claimResult = [SELECT Id, Entitlement__c FROM HOT_Claim__c];
        Test.stopTest();
        System.assertNotEquals(null, claimResult.Entitlement__c);
    }

    @IsTest
    static void wantErrorWhenWrongTimePeriodOnEntitlementVSClaimTest() {
        HOT_Claim__c claim = [SELECT Id FROM HOT_Claim__c];
        HOT_ClaimLineItem__c cli = HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        insert cli;
        HOT_Entitlement__c entitlement = [SELECT Id, FromDate__c, ToDate__c FROM HOT_Entitlement__c];
        entitlement.FromDate__c = Date.today().addYears(-2);
        entitlement.ToDate__c = Date.today().addYears(-2);
        update entitlement;
        claim.Entitlement__c = entitlement.Id;
        Test.startTest();
        Database.SaveResult result = Database.update(claim, false);
        Test.stopTest();
        System.assert(
            result.getErrors()[0].getMessage().contains('Du kan ikke legge på dette vedtaket'),
            'Expected error message about invalid entitlement period.'
        );
    }
    @IsTest
    static void getMyClaimsTest() {
        Test.startTest();
        List<HOT_Claim__c> myClaims = HOT_ClaimController.getMyClaims();
        Test.stopTest();
        System.assertEquals(0, myClaims.size());
    }
    @IsTest
    static void notifyUserOnDeclinedClaimTest() {
        Test.startTest();
        HOT_Claim__c claim = [SELECT Id, Account__c FROM HOT_Claim__c];
        claim.Status__c = 'Declined by NAV';
        update claim;
        Test.stopTest();
        List<SMS__c> sms = [SELECT Id, Account__c FROM SMS__c WHERE Account__c = :claim.Account__c];
        System.assertEquals(0, sms.size());
    }
    @IsTest
    static void notifyUserOnNewClaimTest() {
        Test.startTest();
        List<HOT_Claim__c> claims = [
            SELECT Id, Account__c, Account__r.CRM_Person__r.INT_KrrMobilePhone__c
            FROM HOT_Claim__c
        ];
        HOT_SMSService.notifyUserOnNewClaim(claims);
        Test.stopTest();
    }
    @IsTest
    static void notifyUserOnDeclinedClaim2Test() {
        Test.startTest();
        HOT_Claim__c claim = [SELECT Id, Account__c FROM HOT_Claim__c];
        claim.Status__c = 'Approved by user';
        update claim;
        claim.Status__c = 'Declined by NAV';
        update claim;
        Test.stopTest();
        List<SMS__c> sms = [SELECT Id, Account__c FROM SMS__c WHERE Account__c = :claim.Account__c];
        System.assertEquals(0, sms.size());
    }
    @IsTest
    static void updateEntitleHoursAlreadyUsedTest() {
        Test.startTest();
        HOT_Entitlement__c entitlement = [SELECT Id, EntitledHoursAlreadyUsed__c FROM HOT_Entitlement__c];
        entitlement.EntitledHoursAlreadyUsed__c = 12;
        update entitlement;
        HOT_Entitlement__c result = [SELECT Id, EntitledHoursUsed__c FROM HOT_Entitlement__c];

        Test.stopTest();
        System.assertEquals(12, result.EntitledHoursUsed__c);
    }
    @IsTest
    static void getMyEntitlementsTest() {
        Test.startTest();
        List<HOT_Entitlement__c> entitlements = HOT_EntitlementController.getEntitlements();
        Test.stopTest();
        System.assertEquals(0, entitlements.size());
    }
    @IsTest
    static void recalculateEntitlementOnClaimWhenCLIUpdateTest() {
        HOT_Claim__c claim = [SELECT Id FROM HOT_Claim__c];
        HOT_ClaimLineItem__c cli = HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        insert cli;
        HOT_ClaimLineItem__c cliChange = [SELECT Id FROM HOT_ClaimLineItem__c];
        Date twoDaysAgo = Date.today().addDays(-2);
        cliChange.Date__c = twoDaysAgo;
        update cliChange;
    }
    @IsTest
    static void approveClaimTest() {
        User user = [SELECT Id, AccountId FROM User WHERE LastName = 'PortalBruker'];
        HOT_Claim__c claim = [SELECT Id FROM HOT_Claim__c];
        claim.Account__c = User.AccountId;
        update claim;
        HOT_ClaimLineItem__c cli = HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        insert cli;
        Test.startTest();
        System.runAs(user) {
            HOT_ClaimController.approveClaim(claim.Id, 'Takk for fint møte');
        }
        Test.stopTest();

        HOT_Claim__c result = [SELECT Id, ApprovedByUser__c FROM HOT_Claim__c];
        System.assertEquals(true, result.ApprovedByUser__c);
    }
    @IsTest
    static void declineClaimTest() {
        User user = [SELECT Id, AccountId FROM User WHERE LastName = 'PortalBruker'];
        HOT_Claim__c claim = [SELECT Id FROM HOT_Claim__c];
        claim.Account__c = User.AccountId;
        update claim;
        HOT_ClaimLineItem__c cli = HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        insert cli;

        Test.startTest();
        System.runAs(user) {
            HOT_ClaimController.declineClaim(claim.Id, 'Dette stemmer ikke');
        }
        Test.stopTest();
        HOT_Claim__c result = [SELECT Id, ApprovedByUser__c FROM HOT_Claim__c];
        System.assertEquals(false, result.ApprovedByUser__c);
    }
    @IsTest
    static void cancelClaimTest() {
        User user = [SELECT Id, AccountId FROM User WHERE LastName = 'PortalBruker'];
        HOT_Claim__c claim = [SELECT Id FROM HOT_Claim__c];
        claim.Claimant__c = User.AccountId;
        update claim;
        HOT_ClaimLineItem__c cli = HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        insert cli;

        Test.startTest();
        System.runAs(user) {
            HOT_ClaimController.cancelClaim(claim.Id);
        }
        Test.stopTest();
        HOT_Claim__c result = [SELECT Id, Status__c FROM HOT_Claim__c];
        System.assertEquals('Withdrawn', result.Status__c);
    }
    @IsTest
    static void getClaimTest() {
        Test.startTest();

        User navEmployee = [
            SELECT Id
            FROM User
            WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE
            LIMIT 1
        ];
        Group group1 = new Group(Name = 'HOT LOS Saksbehandler', Type = 'Regular');
        insert group1;

        GroupMember gm = new GroupMember(GroupId = group1.Id, UserOrGroupId = navEmployee.Id);
        insert gm;
        System.runAs(navEmployee) {
            Account acc = new Account();
            acc.Name = 'Ola Lesehjelp';
            insert acc;
            Account acc2 = new Account();
            acc2.Name = 'Kari Bruker';
            insert acc2;
            HOT_Claim__c claim = HOT_LesehjelpTestDataFactory.createClaim(acc2, acc);
            insert claim;
            List<HOT_Claim__c> result = HOT_ClaimController.getClaim(claim.Id);
            Test.stopTest();
            System.assertEquals(1, result.size());
        }
    }
    @IsTest
    static void getMyPreviousClaimsTest() {
        Test.startTest();
        List<HOT_Claim__c> result = HOT_ClaimController.getMyPreviousClaims();
        Test.stopTest();
        System.assertEquals(0, result.size());
    }
    @IsTest
    static void CreateNewClaimFromCommunityPersonNumberTest() {
        String userName = 'Test User';
        String userPersonNumber = '01010101010';
        String userPhoneNumber = '';
        String claimType = 'Dagligliv';
        String onEmployer = 'false';
        String employerName = '';
        String organizationNumber = '';
        String employerExpensesPerHour = '';

        List<Map<String, Object>> claimLineItems = new List<Map<String, Object>>();
        Map<String, Object> claimLineItem = new Map<String, Object>{
            'date' => Date.today().addDays(-1),
            'task' => '',
            'startTime' => '100000',
            'endTime' => '120000',
            'hasAdditionalInformation' => 'true',
            'additionalInformation' => 'Additional info',
            'hasTravelTo' => 'true',
            'dateTravelTo' => Date.today().addDays(-1),
            'startTimeTravelTo' => '080000',
            'endTimeTravelTo' => '090000',
            'hasTravelFrom' => 'true',
            'dateTravelFrom' => Date.today().addDays(-1),
            'startTimeTravelFrom' => '170000',
            'endTimeTravelFrom' => '180000',
            'travelDistance' => '10',
            'expensesPublicTransport' => '10',
            'expensesToll' => '10',
            'expensesParking' => '10'
        };
        claimLineItems.add(claimLineItem);

        Test.startTest();
        String result = HOT_ClaimController.createNewClaimFromCommunity(
            userName,
            userPersonNumber,
            userPhoneNumber,
            claimType,
            onEmployer,
            employerName,
            organizationNumber,
            employerExpensesPerHour,
            claimLineItems
        );
        Test.stopTest();
        System.assertEquals('ok', result, 'Claim creation should be successful');
    }
    @IsTest
    static void CreateNewClaimFromCommunityMobileNumberTest() {
        String userName = 'Test User';
        String userPersonNumber = '';
        String userPhoneNumber = '12345678';
        String claimType = 'Dagligliv';
        String onEmployer = 'false';
        String employerName = '';
        String organizationNumber = '';
        String employerExpensesPerHour = '';

        List<Map<String, Object>> claimLineItems = new List<Map<String, Object>>();
        Map<String, Object> claimLineItem = new Map<String, Object>{
            'date' => Date.today().addDays(-1),
            'task' => '',
            'startTime' => '100000',
            'endTime' => '120000',
            'hasAdditionalInformation' => 'true',
            'additionalInformation' => 'Additional info',
            'hasTravelTo' => 'true',
            'dateTravelTo' => Date.today().addDays(-1),
            'startTimeTravelTo' => '080000',
            'endTimeTravelTo' => '090000',
            'hasTravelFrom' => 'true',
            'dateTravelFrom' => Date.today().addDays(-1),
            'startTimeTravelFrom' => '170000',
            'endTimeTravelFrom' => '180000',
            'travelDistance' => '10',
            'expensesPublicTransport' => '10',
            'expensesToll' => '10',
            'expensesParking' => '10'
        };
        claimLineItems.add(claimLineItem);

        Test.startTest();
        String result = HOT_ClaimController.createNewClaimFromCommunity(
            userName,
            userPersonNumber,
            userPhoneNumber,
            claimType,
            onEmployer,
            employerName,
            organizationNumber,
            employerExpensesPerHour,
            claimLineItems
        );
        Test.stopTest();
        System.assertEquals('ok', result, 'Claim creation should be successful');
    }
    @IsTest
    static void CreateNewClaimFromCommunityMobileNumberOnEmployerTest() {
        String userName = 'Test User';
        String userPersonNumber = '';
        String userPhoneNumber = '12345678';
        String claimType = 'Dagligliv';
        String onEmployer = 'true';
        String employerName = 'NAV';
        String organizationNumber = '123456789';
        String employerExpensesPerHour = '120';

        List<Map<String, Object>> claimLineItems = new List<Map<String, Object>>();
        Map<String, Object> claimLineItem = new Map<String, Object>{
            'date' => Date.today().addDays(-1),
            'task' => '',
            'startTime' => '100000',
            'endTime' => '120000',
            'hasAdditionalInformation' => 'true',
            'additionalInformation' => 'Additional info',
            'hasTravelTo' => 'true',
            'dateTravelTo' => Date.today().addDays(-1),
            'startTimeTravelTo' => '080000',
            'endTimeTravelTo' => '090000',
            'hasTravelFrom' => 'true',
            'dateTravelFrom' => Date.today().addDays(-1),
            'startTimeTravelFrom' => '170000',
            'endTimeTravelFrom' => '180000',
            'travelDistance' => '10',
            'expensesPublicTransport' => '10',
            'expensesToll' => '10',
            'expensesParking' => '10'
        };
        claimLineItems.add(claimLineItem);

        Test.startTest();
        String result = HOT_ClaimController.createNewClaimFromCommunity(
            userName,
            userPersonNumber,
            userPhoneNumber,
            claimType,
            onEmployer,
            employerName,
            organizationNumber,
            employerExpensesPerHour,
            claimLineItems
        );
        Test.stopTest();
        System.assertEquals('ok', result, 'Claim creation should be successful');
    }
    @IsTest
    static void CreateNewClaimFromCommunityMobileNumberOnEmployerNoEmployerTest() {
        String userName = 'Test User';
        String userPersonNumber = '';
        String userPhoneNumber = '12345678';
        String claimType = 'Dagligliv';
        String onEmployer = 'true';
        String employerName = 'NAV';
        String organizationNumber = '123456787';
        String employerExpensesPerHour = '120';

        List<Map<String, Object>> claimLineItems = new List<Map<String, Object>>();
        Map<String, Object> claimLineItem = new Map<String, Object>{
            'date' => Date.today().addDays(-1),
            'task' => '',
            'startTime' => '100000',
            'endTime' => '120000',
            'hasAdditionalInformation' => 'true',
            'additionalInformation' => 'Additional info',
            'hasTravelTo' => 'true',
            'dateTravelTo' => Date.today().addDays(-1),
            'startTimeTravelTo' => '080000',
            'endTimeTravelTo' => '090000',
            'hasTravelFrom' => 'true',
            'dateTravelFrom' => Date.today().addDays(-1),
            'startTimeTravelFrom' => '170000',
            'endTimeTravelFrom' => '180000',
            'travelDistance' => '10',
            'expensesPublicTransport' => '10',
            'expensesToll' => '10',
            'expensesParking' => '10'
        };
        claimLineItems.add(claimLineItem);

        Test.startTest();
        String result = HOT_ClaimController.createNewClaimFromCommunity(
            userName,
            userPersonNumber,
            userPhoneNumber,
            claimType,
            onEmployer,
            employerName,
            organizationNumber,
            employerExpensesPerHour,
            claimLineItems
        );
        Test.stopTest();
        System.assertNotEquals('ok', result, 'Should have give an error');
    }
    @IsTest
    static void CreateNewClaimFromCommunityMobileNumberNoAccountTest() {
        String userName = 'Test User';
        String userPersonNumber = '';
        String userPhoneNumber = '12345671';
        String claimType = 'Dagligliv';
        String onEmployer = 'false';
        String employerName = '';
        String organizationNumber = '';
        String employerExpensesPerHour = '';

        List<Map<String, Object>> claimLineItems = new List<Map<String, Object>>();
        Map<String, Object> claimLineItem = new Map<String, Object>{
            'date' => Date.today().addDays(-1),
            'task' => '',
            'startTime' => '100000',
            'endTime' => '120000',
            'hasAdditionalInformation' => 'true',
            'additionalInformation' => 'Additional info',
            'hasTravelTo' => 'true',
            'dateTravelTo' => Date.today().addDays(-1),
            'startTimeTravelTo' => '080000',
            'endTimeTravelTo' => '090000',
            'hasTravelFrom' => 'true',
            'dateTravelFrom' => Date.today().addDays(-1),
            'startTimeTravelFrom' => '170000',
            'endTimeTravelFrom' => '180000',
            'travelDistance' => '10',
            'expensesPublicTransport' => '10',
            'expensesToll' => '10',
            'expensesParking' => '10'
        };
        claimLineItems.add(claimLineItem);

        Test.startTest();
        String result = HOT_ClaimController.createNewClaimFromCommunity(
            userName,
            userPersonNumber,
            userPhoneNumber,
            claimType,
            onEmployer,
            employerName,
            organizationNumber,
            employerExpensesPerHour,
            claimLineItems
        );
        Test.stopTest();
        System.assertNotEquals('ok', result, 'Should have give an error');
    }
    @IsTest
    static void getTimesTest() {
        HOT_Claim__c claim = [SELECT Id FROM HOT_Claim__c];
        Date yesterday = Date.today().addDays(-1);
        HOT_ClaimLineItem__c cli = HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        cli.Date__c = yesterday;
        cli.StartTime__c = DateTime.newInstance(yesterday, Time.newInstance(13, 0, 0, 0));
        cli.EndTime__c = DateTime.newInstance(yesterday, Time.newInstance(17, 0, 0, 0));
        cli.TypeOfTask__c = '';
        cli.HasTravelTo__c = true;
        cli.HasTravelFrom__c = true;
        cli.TravelTo__c = yesterday;
        cli.TravelFrom__c = yesterday;
        cli.TravelToStartTime__c = DateTime.newInstance(yesterday, Time.newInstance(10, 0, 0, 0));
        cli.TravelToEndTime__c = DateTime.newInstance(yesterday, Time.newInstance(11, 0, 0, 0));
        cli.TravelFromStartTime__c = DateTime.newInstance(yesterday, Time.newInstance(13, 0, 0, 0));
        cli.TravelFromEndTime__c = DateTime.newInstance(yesterday, Time.newInstance(14, 0, 0, 0));
        cli.TravelDistance__c = 10;
        cli.ExpensesPublicTransport__c = 10;
        cli.ExpensesParking__c = 10;
        cli.ExpensesToll__c = 0;
        insert cli;
        Test.startTest();
        List<Map<String, String>> times = HOT_ClaimController.getTimes(claim.Id);
        Test.stopTest();
        System.assertEquals(null, times, 'List of times should come back null because no access');
    }
    @IsTest
    static void getTimesAsValidUserTest() {
        Account portalBrukerAccount = [
            SELECT Id
            FROM Account
            WHERE LastName = 'PortalBruker'
        ];

        HOT_Claim__c newClaim = HOT_LesehjelpTestDataFactory.createClaim(
            HOT_LesehjelpTestDataFactory.createAccount(true),
            portalBrukerAccount
        );

        insert newClaim;

        HOT_ClaimLineItem__c cli = HOT_LesehjelpTestDataFactory.createClaimLineItems(newClaim);

        Date yesterday = Date.today().addDays(-1);
        cli.Date__c = yesterday;
        cli.StartTime__c = DateTime.newInstance(yesterday, Time.newInstance(13, 0, 0, 0));
        cli.EndTime__c = DateTime.newInstance(yesterday, Time.newInstance(17, 0, 0, 0));
        cli.TypeOfTask__c = '';
        cli.HasTravelTo__c = true;
        cli.HasTravelFrom__c = true;
        cli.TravelTo__c = yesterday;
        cli.TravelFrom__c = yesterday;
        cli.TravelToStartTime__c = DateTime.newInstance(yesterday, Time.newInstance(10, 0, 0, 0));
        cli.TravelToEndTime__c = DateTime.newInstance(yesterday, Time.newInstance(11, 0, 0, 0));
        cli.TravelFromStartTime__c = DateTime.newInstance(yesterday, Time.newInstance(13, 0, 0, 0));
        cli.TravelFromEndTime__c = DateTime.newInstance(yesterday, Time.newInstance(14, 0, 0, 0));
        cli.TravelDistance__c = 10;
        cli.ExpensesPublicTransport__c = 10;
        cli.ExpensesParking__c = 10;
        cli.ExpensesToll__c = 0;
        insert cli;

        User portalBruker = [
            SELECT Id, AccountId
            FROM User
            WHERE AccountId = :portalBrukerAccount.Id
        ];

        List<Map<String, String>> times = new List<Map<String, String>>();
        Test.startTest();
        System.runAs(portalBruker) {
            times = HOT_ClaimController.getTimes(newClaim.Id);
        }
        Test.stopTest();
        System.assertEquals(1, times.size(), 'Should have 1 time');
    }

    @IsTest
    static void CreateNewClaimFromCommunityAndThenUpdateItTest() {
        String userName = 'Test User';
        String userPersonNumber = '01010101010';
        String userPhoneNumber = '';
        String claimType = 'Dagligliv';
        String onEmployer = 'false';
        String employerName = '';
        String organizationNumber = '';
        String employerExpensesPerHour = '';

        List<Map<String, Object>> claimLineItems = new List<Map<String, Object>>();
        Map<String, Object> claimLineItem = new Map<String, Object>{
            'date' => Date.today().addDays(-1),
            'task' => '',
            'startTime' => '100000',
            'endTime' => '120000',
            'hasAdditionalInformation' => 'true',
            'additionalInformation' => 'Additional info',
            'hasTravelTo' => 'true',
            'dateTravelTo' => Date.today().addDays(-1),
            'startTimeTravelTo' => '080000',
            'endTimeTravelTo' => '090000',
            'hasTravelFrom' => 'true',
            'dateTravelFrom' => Date.today().addDays(-1),
            'startTimeTravelFrom' => '170000',
            'endTimeTravelFrom' => '180000',
            'travelDistance' => '10',
            'expensesPublicTransport' => '10',
            'expensesToll' => '10',
            'expensesParking' => '10'
        };
        claimLineItems.add(claimLineItem);

        Test.startTest();
        String result = HOT_ClaimController.createNewClaimFromCommunity(
            userName,
            userPersonNumber,
            userPhoneNumber,
            claimType,
            onEmployer,
            employerName,
            organizationNumber,
            employerExpensesPerHour,
            claimLineItems
        );
        HOT_Claim__c claimToUpdate = [SELECT Id FROM HOT_Claim__c WHERE Type__c = 'Dagligliv' LIMIT 1];
        List<HOT_ClaimLineItem__c> claimLineItemsList = [
            SELECT Id
            FROM HOT_ClaimLineItem__c
            WHERE Claim__c = :claimToUpdate.Id
        ];
        //
        List<Map<String, Object>> claimLineItemsUpdated = new List<Map<String, Object>>();

        for (HOT_ClaimLineItem__c cli : claimLineItemsList) {
            Map<String, Object> claimLineItemUpdated = new Map<String, Object>{
                'id' => cli.Id,
                'date' => Date.today().addDays(-1),
                'task' => '',
                'startTime' => '100000',
                'endTime' => '120000',
                'hasAdditionalInformation' => 'true',
                'additionalInformation' => 'Additional info',
                'hasTravelTo' => 'true',
                'dateTravelTo' => Date.today().addDays(-1),
                'startTimeTravelTo' => '080000',
                'endTimeTravelTo' => '090000',
                'hasTravelFrom' => 'true',
                'dateTravelFrom' => Date.today().addDays(-1),
                'startTimeTravelFrom' => '170000',
                'endTimeTravelFrom' => '180000',
                'travelDistance' => '10',
                'expensesPublicTransport' => '10',
                'expensesToll' => '10',
                'expensesParking' => '10'
            };
            claimLineItemsUpdated.add(claimLineItemUpdated);
        }
        String resultString = HOT_ClaimController.updateClaim(
            claimToUpdate.Id,
            'Arbeidsliv',
            '',
            'false',
            claimLineItemsUpdated
        );
        Test.stopTest();
        System.assertEquals('ok', resultString, 'Claim should have been updated');
    }

    @IsTest
    static void getOrganizationInfoTest() {
        Account acc = new Account();
        acc.Name = '987654321';
        acc.INT_OrganizationNumber__c = '987654321';
        insert acc;

        Test.startTest();
        List<Account> accounts = HOT_ClaimController.getOrganizationInfo('987654321');
        Test.stopTest();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    static void getClaimsToApproveTest() {
        Test.startTest();
        List<HOT_Claim__c> myClaims = HOT_ClaimController.getClaimsToApprove();
        Test.stopTest();
        System.assertEquals(0, myClaims.size());
    }

    static void testSetKoststed_Municipality() {
        List<Id> claimIds = new List<Id>();
        HOT_Claim__c claim = [
            SELECT Id
            FROM HOT_Claim__c
            WHERE Claimant__r.CRM_Person__r.INT_IsNavEmployee__c = FALSE
            LIMIT 1
        ];

        claimIds.add(claim.Id);

        Test.startTest();
        HOT_ClaimController.setKoststed(claimIds);
        Test.stopTest();

        HOT_Claim__c claimAfterUpdate = [SELECT Koststed__c FROM HOT_Claim__c WHERE Id = :claim.Id];
        System.assertEquals('241299', claimAfterUpdate.Koststed__c, 'Koststed not set correctly');
    }
}
