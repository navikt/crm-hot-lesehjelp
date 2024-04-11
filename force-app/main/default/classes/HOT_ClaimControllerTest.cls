@Istest
public class HOT_ClaimControllerTest {
    @TestSetup
    static void setup(){
        Account acc = new Account();
        acc.Name = 'Ola Lesehjelp';
        insert acc;
        Account acc2 = new Account();
        acc2.INT_PersonIdent__c='01010101010';
        acc2.Name = 'Kari Bruker';
        acc2.INT_KrrMobilePhone__c='12345678';
        insert acc2;
        Account acc3 = new Account();
        acc3.Name = 'NAV';
        acc3.INT_OrganizationNumber__c='123456789';
        insert acc3;
        HOT_Claim__c claim = HOT_LesehjelpTestDataFactory.createClaim(acc2, acc);
        claim.UserPersonNumber__c='01010101010';
        insert claim;

        HOT_Entitlement__c entitlement=HOT_LesehjelpTestDataFactory.createEntitlement(acc2);
        insert entitlement;
    }
    @Istest
    static void setEntitlementOnClaimTest(){
        HOT_Claim__c claim=[SELECT Id FROM HOT_Claim__c];
        HOT_ClaimLineItem__c cli=HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        insert cli;
        Test.startTest();
        HOT_Claim__c claimResult=[SELECT Id, Entitlement__c FROM HOT_Claim__c];
        Test.stopTest();
        System.assertNotEquals(null, claimResult.Entitlement__c);

    }
    @Istest
    static void getMyClaimsTest(){
        Test.startTest();
        List<HOT_Claim__c> myClaims=HOT_ClaimController.getMyClaims();
        Test.stopTest();
        System.assertEquals(0, myClaims.size());
    }
    @Istest
    static void notifyUserOnDeclinedClaimTest(){
        Test.startTest();
        HOT_Claim__c claim=[SELECT Id, Account__c FROM HOT_Claim__c];
        claim.Status__c='Declined by NAV';
        update claim;
        Test.stopTest();
        List <SMS__c> sms=[SELECT Id, Account__c FROM SMS__c WHERE Account__c=:claim.Account__c];
        System.assertEquals(0, sms.size()); 
    }
     @Istest
    static void notifyUserOnNewClaimTest(){
        Test.startTest();
        List<HOT_Claim__c> claims=[SELECT Id, Account__c, Account__r.CRM_Person__r.INT_KrrMobilePhone__c FROM HOT_Claim__c];
        HOT_SMSService.notifyUserOnNewClaim(claims);
        Test.stopTest();
    }
     @Istest
    static void notifyUserOnDeclinedClaim2Test(){
        Test.startTest();
        HOT_Claim__c claim=[SELECT Id, Account__c FROM HOT_Claim__c];
        claim.Status__c='Approved by user';
        update claim;
        claim.Status__c='Declined by NAV';
        update claim;
        Test.stopTest();
        List <SMS__c> sms=[SELECT Id, Account__c FROM SMS__c WHERE Account__c=:claim.Account__c];
        System.assertEquals(0, sms.size()); 
    }
     @Istest
    static void updateEntitleHoursAlreadyUsedTest(){
        Test.startTest();
        HOT_Entitlement__c entitlement=[SELECT Id, EntitledHoursAlreadyUsed__c FROM HOT_Entitlement__c];
        entitlement.EntitledHoursAlreadyUsed__c=12;
        update entitlement;
        HOT_Entitlement__c result=[SELECT Id, EntitledHoursUsed__c FROM HOT_Entitlement__c];

        Test.stopTest();
        System.assertEquals(12, result.EntitledHoursUsed__c); 
    }
     @Istest
    static void getMyEntitlementsTest(){
        Test.startTest();
        List<HOT_Entitlement__c> entitlements =HOT_EntitlementController.getEntitlements();
        Test.stopTest();
        System.assertEquals(0, entitlements.size()); 
    }
    @Istest
    static void recalculateEntitlementOnClaimWhenCLIUpdateTest(){
        HOT_Claim__c claim=[SELECT Id FROM HOT_Claim__c];
        HOT_ClaimLineItem__c cli=HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        insert cli;
        HOT_ClaimLineItem__c cliChange=[SELECT Id FROM HOT_ClaimLineItem__c];
        Date twoDaysAgo = Date.today().addDays(-2);
        cliChange.Date__c = twoDaysAgo;
        update cliChange;
    }
    @Istest
    static void approveClaimTest(){
        Test.startTest();
        HOT_Claim__c claim=[SELECT Id FROM HOT_Claim__c];
        HOT_ClaimLineItem__c cli=HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        insert cli;
        HOT_ClaimController.approveClaim(claim.Id, 'Takk for fint møte');
        HOT_Claim__c result=[SELECT Id, ApprovedByUser__c FROM HOT_Claim__c];
        Test.stopTest();
        System.assertEquals(true, result.ApprovedByUser__c); 
    }
    @Istest
    static void declineClaimTest(){
        Test.startTest();
        HOT_Claim__c claim=[SELECT Id FROM HOT_Claim__c];
        HOT_ClaimLineItem__c cli=HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        insert cli;
        HOT_ClaimController.declineClaim(claim.Id, 'Dette stemmer ikke');
        HOT_Claim__c result=[SELECT Id, ApprovedByUser__c FROM HOT_Claim__c];
        Test.stopTest();
        System.assertEquals(false, result.ApprovedByUser__c); 
    }
    @Istest
    static void cancelClaimTest(){
        Test.startTest();
        HOT_Claim__c claim=[SELECT Id FROM HOT_Claim__c];
        HOT_ClaimLineItem__c cli=HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        insert cli;
        HOT_ClaimController.cancelClaim(claim.Id);
        HOT_Claim__c result=[SELECT Id, Status__c FROM HOT_Claim__c];
        Test.stopTest();
        System.assertEquals('Withdrawn', result.Status__c); 
    }
    @Istest
    static void getClaimTest(){
        Test.startTest();
        HOT_Claim__c claim=[SELECT Id FROM HOT_Claim__c];
        List<HOT_Claim__c> result=HOT_ClaimController.getClaim(claim.Id);
        Test.stopTest();
        System.assertEquals(1, result.size()); 
    }
    @Istest
    static void getMyPreviousClaimsTest(){
        Test.startTest();
        List<HOT_Claim__c> result=HOT_ClaimController.getMyPreviousClaims();
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
            'dateTravelFrom' => Date.today().addDays(-1), // Yesterday's date
            'startTimeTravelFrom' => '170000', // Assuming timestamp format
            'endTimeTravelFrom' => '180000', // Assuming timestamp format
            'travelDistance' => 10
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
            'dateTravelFrom' => Date.today().addDays(-1), // Yesterday's date
            'startTimeTravelFrom' => '170000', // Assuming timestamp format
            'endTimeTravelFrom' => '180000', // Assuming timestamp format
            'travelDistance' => 10
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
            'dateTravelFrom' => Date.today().addDays(-1), // Yesterday's date
            'startTimeTravelFrom' => '170000', // Assuming timestamp format
            'endTimeTravelFrom' => '180000', // Assuming timestamp format
            'travelDistance' => 10
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
            'dateTravelFrom' => Date.today().addDays(-1), // Yesterday's date
            'startTimeTravelFrom' => '170000', // Assuming timestamp format
            'endTimeTravelFrom' => '180000', // Assuming timestamp format
            'travelDistance' => 10
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
            'dateTravelFrom' => Date.today().addDays(-1), // Yesterday's date
            'startTimeTravelFrom' => '170000', // Assuming timestamp format
            'endTimeTravelFrom' => '180000', // Assuming timestamp format
            'travelDistance' => 10
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
    static void getTimesTest(){
        HOT_Claim__c claim=[SELECT Id FROM HOT_Claim__c];
        Date yesterday = Date.today().addDays(-1);
        HOT_ClaimLineItem__c cli=HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
            cli.Date__c = yesterday;
            cli.StartTime__c = DateTime.newInstance(yesterday, Time.newInstance(13, 0, 0, 0));
            cli.EndTime__c = DateTime.newInstance(yesterday, Time.newInstance(17, 0, 0, 0));
            cli.TypeOfTask__c = '';
            cli.HasTravelTo__c = true;
            cli.HasTravelFrom__c=true;
            cli.TravelTo__c = yesterday;
            cli.TravelFrom__c = yesterday;
            cli.TravelToStartTime__c = DateTime.newInstance(yesterday, Time.newInstance(10, 0, 0, 0));
            cli.TravelToEndTime__c = DateTime.newInstance(yesterday, Time.newInstance(11, 0, 0, 0));
            cli.TravelFromStartTime__c = DateTime.newInstance(yesterday, Time.newInstance(13, 0, 0, 0));
            cli.TravelFromEndTime__c = DateTime.newInstance(yesterday, Time.newInstance(14, 0, 0, 0));
            cli.TravelDistance__c = 10;
        insert cli;
        Test.startTest();
        List<Map<String, String>> times = HOT_ClaimController.getTimes(claim.Id);
        Test.stopTest();
        System.assertNotEquals(0, times.size(), 'List of times should not be empty');
    }
    
}