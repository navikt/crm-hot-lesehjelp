@IsTest
private class HOT_LosUriEventServiceTest {
    @TestSetup
    static void makeData() {
        Account acc = new Account();
        acc.Name = 'Ola Lesehjelp';
        insert acc;
        Account acc2 = new Account();
        acc2.INT_PersonIdent__c = '01010101010';
        acc2.Name = 'Kari Bruker';
        acc2.INT_KrrMobilePhone__c = '12345678';
        insert acc2;
        HOT_Claim__c claim = HOT_LesehjelpTestDataFactory.createClaim(acc2, acc);
        claim.UserPersonNumber__c = '01010101010';
        insert claim;
        HOT_ClaimLineItem__c cli = HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        insert cli;
        HOT_Entitlement__c entitlement = HOT_LesehjelpTestDataFactory.createEntitlement(acc2);
        insert entitlement;
    }

    @IsTest
    private static void addPersonRelatedRecordsToLog_forHotClaim() {
        HOT_Claim__c claim = [
            SELECT Id, Claimant__c, Claimant__r.CRM_Person__r.Name
            FROM HOT_Claim__c
            LIMIT 1
        ];

        List<UriEvent> uriEvents = new List<UriEvent>();
        uriEvents.add(new UriEvent(claim.Id, DateTime.now(), 'HOT_Claim__c', 'Read', 'user@user.nav.no', 'Standard'));

        Test.startTest();
        HOT_LosUriEventService.addPersonRelatedRecordsToLog(uriEvents);
        Test.stopTest();

        List<Log__c> logs = [
            SELECT CRM_PersonIdent__c
            FROM Log__c
            WHERE CRM_Type__c = 'LightningUriEvent' AND CRM_QueriedEntity__c = 'HOT_Claim__c'
        ];
        System.assertEquals(1, logs.size(), 'One log element is created');
        System.assertEquals(
            claim.Claimant__r.CRM_Person__r.Name,
            logs[0].CRM_PersonIdent__c,
            'Log element should have persons fødselsr / dnr'
        );
    }
    @IsTest
    private static void addPersonRelatedRecordsToLog_forHotClaimLineItem() {
        HOT_ClaimLineItem__c claimLineItem = [
            SELECT Id, Claim__r.Claimant__r.CRM_Person__r.Name
            FROM HOT_ClaimLineItem__c
            LIMIT 1
        ];

        List<UriEvent> uriEvents = new List<UriEvent>();
        uriEvents.add(
            new UriEvent(
                claimLineItem.Id,
                DateTime.now(),
                'HOT_ClaimLineItem__c',
                'Read',
                'user@user.nav.no',
                'Standard'
            )
        );

        Test.startTest();
        HOT_LosUriEventService.addPersonRelatedRecordsToLog(uriEvents);
        Test.stopTest();

        List<Log__c> logs = [
            SELECT CRM_PersonIdent__c
            FROM Log__c
            WHERE CRM_Type__c = 'LightningUriEvent' AND CRM_QueriedEntity__c = 'HOT_ClaimLineItem__c'
        ];
        System.assertEquals(1, logs.size(), 'One log element is created');
        System.assertEquals(
            claimLineItem.Claim__r.Claimant__r.CRM_Person__r.Name,
            logs[0].CRM_PersonIdent__c,
            'Log element should have persons fødselsr / dnr'
        );
    }
    @IsTest
    private static void addPersonRelatedRecordsToLog_forHotEntitlement() {
        HOT_Entitlement__c entitlement = [
            SELECT Id, Account__r.CRM_Person__r.Name
            FROM HOT_Entitlement__c
            LIMIT 1
        ];

        List<UriEvent> uriEvents = new List<UriEvent>();
        uriEvents.add(
            new UriEvent(entitlement.Id, DateTime.now(), 'HOT_Entitlement__c', 'Read', 'user@user.nav.no', 'Standard')
        );

        Test.startTest();
        HOT_LosUriEventService.addPersonRelatedRecordsToLog(uriEvents);
        Test.stopTest();

        List<Log__c> logs = [
            SELECT CRM_PersonIdent__c
            FROM Log__c
            WHERE CRM_Type__c = 'LightningUriEvent' AND CRM_QueriedEntity__c = 'HOT_Entitlement__c'
        ];
        System.assertEquals(1, logs.size(), 'One log element is created');
        System.assertEquals(
            entitlement.Account__r.CRM_Person__r.Name,
            logs[0].CRM_PersonIdent__c,
            'Log element should have persons fødselsr / dnr'
        );
    }
}
