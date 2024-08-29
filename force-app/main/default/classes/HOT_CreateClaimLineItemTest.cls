@IsTest
private class HOT_CreateClaimLineItemTest {
    @TestSetup
    static void setup() {
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
    }
    @IsTest
    private static void createClaimNever() {
        HOT_Claim__c claim = [SELECT Id FROM HOT_Claim__c];

        HOT_CreateClaimLineItem inputVariable = new HOT_CreateClaimLineItem();
        inputVariable.claimId = claim.Id;
        inputVariable.startDate = Datetime.now();
        inputVariable.endDate = Datetime.now().addHours(1);
        inputVariable.recurringType = 'Never';
        inputVariable.travelToStartDate = Datetime.now().addHours(-1);
        inputVariable.travelToEndDate = Datetime.now();
        inputVariable.travelFromStartDate = Datetime.now().addHours(1);
        inputVariable.travelFromEndDate = Datetime.now().addHours(2);
        inputVariable.hasTraveledTo = true;
        inputVariable.hasTraveledFrom = true;
        inputVariable.distanceTraveled = 10;

        List<HOT_CreateClaimLineItem> inputVariables = new List<HOT_CreateClaimLineItem>();
        inputVariables.add(inputVariable);

        Test.startTest();
        HOT_CreateClaimLineItem.createClaimLineItems(inputVariables);
        Test.stopTest();

        List<HOT_ClaimLineItem__c> claimLines = [
            SELECT Id, Claim__c, StartTime__c, EndTime__c
            FROM HOT_ClaimLineItem__c
        ];
        System.assertEquals(1, claimLines.size(), 'Det ble ikke opprettet korrekt antall linjer');
        System.assertEquals(claim.Id, claimLines[0].Claim__c, 'Arbeidsordre ble ikke knyttet til riktig krav');
        System.assertEquals(
            inputVariable.startDate,
            claimLines[0].StartTime__c,
            'Arbeidsordre ble ikke knyttet til riktig krav'
        );
        System.assertEquals(
            inputVariable.endDate,
            claimLines[0].EndTime__c,
            'Arbeidsordre ble ikke knyttet til riktig krav'
        );
    }

    @IsTest
    private static void createClaimDaily() {
        HOT_Claim__c claim = [SELECT Id FROM HOT_Claim__c];

        HOT_CreateClaimLineItem inputVariable = new HOT_CreateClaimLineItem();
        inputVariable.claimId = claim.Id;
        inputVariable.startDate = Datetime.now();
        inputVariable.endDate = Datetime.now().addHours(1);
        inputVariable.recurringType = 'Daily';
        inputVariable.recurringEndDate = Date.today().addDays(10);
        inputVariable.travelToStartDate = Datetime.now().addHours(-1);
        inputVariable.travelToEndDate = Datetime.now();
        inputVariable.travelFromStartDate = Datetime.now().addHours(1);
        inputVariable.travelFromEndDate = Datetime.now().addHours(2);
        inputVariable.hasTraveledTo = true;
        inputVariable.hasTraveledFrom = true;
        inputVariable.distanceTraveled = 10;

        List<HOT_CreateClaimLineItem> inputVariables = new List<HOT_CreateClaimLineItem>();
        inputVariables.add(inputVariable);

        Test.startTest();
        HOT_CreateClaimLineItem.createClaimLineItems(inputVariables);
        Test.stopTest();

        List<HOT_ClaimLineItem__c> claimLines = [
            SELECT Id, Claim__c, StartTime__c, EndTime__c
            FROM HOT_ClaimLineItem__c
        ];
        System.assertEquals(11, claimLines.size(), 'Det ble ikke opprettet korrekt antall linjer');
    }

    @IsTest
    private static void createClaimWeekly() {
        HOT_Claim__c claim = [SELECT Id FROM HOT_Claim__c];

        HOT_CreateClaimLineItem inputVariable = new HOT_CreateClaimLineItem();
        inputVariable.claimId = claim.Id;
        inputVariable.startDate = Datetime.now();
        inputVariable.endDate = Datetime.now().addHours(1);
        inputVariable.recurringType = 'Weekly';
        inputVariable.recurringEndDate = Date.today().addDays(13);
        inputVariable.monday = true;
        inputVariable.tuesday = true;
        inputVariable.wednesday = true;
        inputVariable.thursday = true;
        inputVariable.friday = true;
        inputVariable.saturday = true;
        inputVariable.sunday = true;
        inputVariable.travelToStartDate = Datetime.now().addHours(-1);
        inputVariable.travelToEndDate = Datetime.now();
        inputVariable.travelFromStartDate = Datetime.now().addHours(1);
        inputVariable.travelFromEndDate = Datetime.now().addHours(2);
        inputVariable.hasTraveledTo = true;
        inputVariable.hasTraveledFrom = true;
        inputVariable.distanceTraveled = 10;

        List<HOT_CreateClaimLineItem> inputVariables = new List<HOT_CreateClaimLineItem>();
        inputVariables.add(inputVariable);

        Test.startTest();
        HOT_CreateClaimLineItem.createClaimLineItems(inputVariables);
        Test.stopTest();

        List<HOT_ClaimLineItem__c> claimLines = [
            SELECT Id, Claim__c, StartTime__c, EndTime__c
            FROM HOT_ClaimLineItem__c
        ];
        System.assertEquals(14, claimLines.size(), 'Det ble ikke opprettet korrekt antall linjer');
    }

    @IsTest
    private static void createClaimBiweekly() {
        HOT_Claim__c claim = [SELECT Id FROM HOT_Claim__c];

        HOT_CreateClaimLineItem inputVariable = new HOT_CreateClaimLineItem();
        inputVariable.claimId = claim.Id;
        inputVariable.startDate = Datetime.now();
        inputVariable.endDate = Datetime.now().addHours(1);
        inputVariable.recurringType = 'Biweekly';
        inputVariable.recurringEndDate = Date.today().addDays(27);
        inputVariable.monday = true;
        inputVariable.tuesday = true;
        inputVariable.wednesday = true;
        inputVariable.thursday = true;
        inputVariable.friday = true;
        inputVariable.saturday = true;
        inputVariable.sunday = true;
        inputVariable.travelToStartDate = Datetime.now().addHours(-1);
        inputVariable.travelToEndDate = Datetime.now();
        inputVariable.travelFromStartDate = Datetime.now().addHours(1);
        inputVariable.travelFromEndDate = Datetime.now().addHours(2);
        inputVariable.hasTraveledTo = true;
        inputVariable.hasTraveledFrom = true;
        inputVariable.distanceTraveled = 10;

        List<HOT_CreateClaimLineItem> inputVariables = new List<HOT_CreateClaimLineItem>();
        inputVariables.add(inputVariable);

        Test.startTest();
        HOT_CreateClaimLineItem.createClaimLineItems(inputVariables);
        Test.stopTest();

        List<HOT_ClaimLineItem__c> claimLines = [
            SELECT Id, Claim__c, StartTime__c, EndTime__c
            FROM HOT_ClaimLineItem__c
        ];
        System.assertEquals(14, claimLines.size(), 'Det ble ikke opprettet korrekt antall linjer');
    }
    @IsTest
    private static void createClaimInvalidStartEndTime() {
        HOT_Claim__c claim =  [SELECT Id FROM HOT_Claim__c];
        HOT_CreateClaimLineItem inputVariable = new HOT_CreateClaimLineItem();
        inputVariable.claimId = claim.Id;
        inputVariable.endDate = Datetime.now();
        inputVariable.startDate = Datetime.now().addHours(1);

        Test.startTest();
        List<String> errors = 
            HOT_CreateClaimLineItem.createClaimLineItems(new List<HOT_CreateClaimLineItem>{inputVariable});
        Test.stopTest();

        System.assert(
            errors.contains( HOT_CreateClaimLineItem.ERROR_ENDDATE_BEFORE_STARTDATE), 
            'Errors should include enddate before startdate error'
            );
    }
    @IsTest
    private static void createClaimInvalidRecurringStartEndTime() {
        HOT_Claim__c claim =  [SELECT Id FROM HOT_Claim__c];
        HOT_CreateClaimLineItem inputVariable = new HOT_CreateClaimLineItem();
        inputVariable.claimId = claim.Id;
        inputVariable.recurringType = 'Weekly';
        inputVariable.recurringEndDate = Date.today();
        inputVariable.startDate = DateTime.now().addDays(1);

        Test.startTest();
        List<String> errors = 
            HOT_CreateClaimLineItem.createClaimLineItems(new List<HOT_CreateClaimLineItem>{inputVariable});
        Test.stopTest();

        System.assert(
            errors.contains(HOT_CreateClaimLineItem.ERROR_RECURRING_ENDDATE_BEFORE_STARTDATE),
            'Errors should include recurring enddate before startdate error'
        );
    }
    @IsTest 
    private static void createClaimNoDaySelected() {
        HOT_Claim__c claim =  [SELECT Id FROM HOT_Claim__c];
        HOT_CreateClaimLineItem inputVariable = new HOT_CreateClaimLineItem();
        inputVariable.claimId = claim.Id;
        inputVariable.startDate = Datetime.now();
        inputVariable.endDate = Datetime.now().addHours(1);
        inputVariable.recurringType = 'Weekly';
        inputVariable.travelToStartDate = Datetime.now().addHours(-1);
        inputVariable.travelToEndDate = Datetime.now();
        inputVariable.travelFromStartDate = Datetime.now().addHours(1);
        inputVariable.travelFromEndDate = Datetime.now().addHours(2);
        inputVariable.monday = false;
        inputVariable.tuesday = false;
        inputVariable.wednesday = false;
        inputVariable.thursday = false;
        inputVariable.friday = false;
        inputVariable.saturday = false;
        inputVariable.sunday = false;

        Test.startTest();
        List<String> errors = 
            HOT_CreateClaimLineItem.createClaimLineItems(new List<HOT_CreateClaimLineItem>{inputVariable});
        Test.stopTest();

        System.assert(
            errors.contains(HOT_CreateClaimLineItem.ERROR_NO_DAY_SELECTED),
            'Errors should include no selected day error'
        );
    }
    @IsTest
    private static void createClaimTooManyDays() {
        HOT_Claim__c claim =  [SELECT Id FROM HOT_Claim__c];
        HOT_CreateClaimLineItem inputVariable = new HOT_CreateClaimLineItem();
        inputVariable.claimId = claim.Id;
        inputVariable.startDate = Datetime.now();
        inputVariable.endDate = Datetime.now().addHours(1);
        inputVariable.recurringType = 'Weekly';
        inputVariable.travelToStartDate = Datetime.now().addHours(-1);
        inputVariable.travelToEndDate = Datetime.now();
        inputVariable.travelFromStartDate = Datetime.now().addHours(1);
        inputVariable.travelFromEndDate = Datetime.now().addHours(2);
        inputVariable.recurringEndDate = Date.today().addYears(10);
        inputVariable.monday = true;
        inputVariable.tuesday = true;
        inputVariable.wednesday = true;
        inputVariable.thursday = true;
        inputVariable.friday = true;
        inputVariable.saturday = true;
        inputVariable.sunday = true;

        Test.startTest();
        List<String> errorsWhenWeekly = 
            HOT_CreateClaimLineItem.createClaimLineItems(new List<HOT_CreateClaimLineItem>{inputVariable});


        inputVariable.recurringType = 'Biweekly';
        List<String> errorsWhenBiweekly = 
            HOT_CreateClaimLineItem.createClaimLineItems(new List<HOT_CreateClaimLineItem>{inputVariable});

        inputVariable.recurringType = 'Daily';
        List<String> errorsWhenDaily = 
            HOT_CreateClaimLineItem.createClaimLineItems(new List<HOT_CreateClaimLineItem>{inputVariable});


        Test.stopTest();

        System.assert(
            errorsWhenWeekly.contains(HOT_CreateClaimLineItem.ERROR_EXCEEDED_MAX_ITEMS),
            'Errors should include too many items error when weekly'
        );
        System.assert(
            errorsWhenBiweekly.contains(HOT_CreateCLaimLineItem.ERROR_EXCEEDED_MAX_ITEMS),
            'Erros should include too many items error when biweekly'
        );
        System.assert(
            errorsWhenDaily.contains(HOT_CreateCLaimLineItem.ERROR_EXCEEDED_MAX_ITEMS),
            'Erros should include too many items error when daily'
        );
    }
}
