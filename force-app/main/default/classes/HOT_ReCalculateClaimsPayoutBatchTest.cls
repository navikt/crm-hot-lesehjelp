@isTest
private class HOT_ReCalculateClaimsPayoutBatchTest {
    @testSetup
    static void setup() {
        Account acc2 = new Account();
        acc2.Name = 'Ola Bruker';
        insert acc2;

        List<HOT_Rate__c> rates = new List<HOT_Rate__c>{
            new HOT_Rate__c(
                Type__c = 'Dag',
                Rate__c = 100,
                ValidFrom__c = Date.today().addDays(-10),
                ValidTo__c = Date.today().addDays(10),
                isActive__c = true
            ),
            new HOT_Rate__c(
                Type__c = 'Kveld/helg',
                Rate__c = 200,
                ValidFrom__c = Date.today().addDays(-10),
                ValidTo__c = Date.today().addDays(10),
                isActive__c = true
            ),
            new HOT_Rate__c(
                Type__c = 'Reisetid',
                Rate__c = 50,
                ValidFrom__c = Date.today().addDays(-10),
                ValidTo__c = Date.today().addDays(10),
                isActive__c = true
            ),
            new HOT_Rate__c(
                Type__c = 'Kjøregodtgjørelse',
                Rate__c = 3.5, // f.eks. 3,50 kr/km
                ValidFrom__c = Date.today().addDays(-10),
                ValidTo__c = Date.today().addDays(10),
                isActive__c = true
            )
        };
        insert rates;

        HOT_Entitlement__c entitlement = new HOT_Entitlement__c(
            Account__c = acc2.Id,
            Type__c = 'Dagligliv',
            EntitledHours__c = 120,
            FromDate__c = Date.today().addDays(-1),
            ToDate__c = Date.today().addDays(3)
        );
        insert entitlement;

        HOT_Claim__c testClaim = new HOT_Claim__c(
            Account__c = acc2.Id,
            Entitlement__c = entitlement.Id,
            Type__c = 'Dagligliv',
            ApprovedByUser__c = true,
            ProcessedRate__c = true,
            ReProcessedRate__c = false,
            ApprovedByNAV__c = true,
            Status__c = 'Paid Out'
        );
        insert testClaim;

        // Bruker GMT-tid for å minimere tidssone-påvirkning,
        // men timene vil uansett bli satt av din calculateHoursOnRates kode i en trigger.
        DateTime workStartGmt = Datetime.newInstanceGmt(
            Date.today().year(),
            Date.today().month(),
            Date.today().day(),
            7,
            0,
            0
        ); // 07:00
        DateTime workEndGmt = Datetime.newInstanceGmt(
            Date.today().year(),
            Date.today().month(),
            Date.today().day(),
            9,
            0,
            0
        ); // 09:00

        DateTime travelStartGmt = Datetime.newInstanceGmt(
            Date.today().year(),
            Date.today().month(),
            Date.today().day(),
            6,
            30,
            0
        ); // 06:30
        DateTime travelEndGmt = Datetime.newInstanceGmt(
            Date.today().year(),
            Date.today().month(),
            Date.today().day(),
            7,
            0,
            0
        ); // 07:00

        HOT_ClaimLineItem__c testCli = new HOT_ClaimLineItem__c(
            Claim__c = testClaim.Id,
            StartTime__c = workStartGmt,
            EndTime__c = workEndGmt,
            HasTravelFrom__c = true,
            TravelFromStartTime__c = travelStartGmt,
            TravelFromEndTime__c = travelEndGmt,
            Amount__c = 600,
            TravelDistance__c = 10,
            TotalUndocumentedExpenses__c = 100
        );

        // Setter Days/Evening/TravelHours til 0.0 eksplisitt for å unngå forvirring,
        // da de overskrives av en trigger/automatisering i calculateHoursOnRates.

        testCli.DayHours__c = 0.0;
        testCli.EveningNightAndWeekendHours__c = 0.0;
        testCli.TravelHours__c = 0.0;

        insert testCli;
    }

    @isTest
    static void testSchedulableAndBatchExecution() {
        HOT_ClaimLineItem__c setupCli = [
            SELECT DayHours__c, EveningNightAndWeekendHours__c, TravelHours__c, TravelDistance__c
            FROM HOT_ClaimLineItem__c
            LIMIT 1
        ];

        Decimal actualCalculatedAmount =
            (setupCli.DayHours__c * 100) +
            (setupCli.EveningNightAndWeekendHours__c * 200) +
            (setupCli.TravelHours__c * 50) +
            (setupCli.TravelDistance__c * 3.5);

        Decimal expectedDelta = actualCalculatedAmount - 600; // 600 = gammelt beløp

        Test.startTest();
        HOT_ReCalculateClaimsPayoutBatch schedulable = new HOT_ReCalculateClaimsPayoutBatch();
        schedulable.execute(null);
        Test.stopTest();

        // Hent oppdatert krav og linje
        HOT_Claim__c updatedClaim = [SELECT ReProcessedRate__c FROM HOT_Claim__c LIMIT 1];
        HOT_ClaimLineItem__c updatedCli = [
            SELECT DeltaAfterAdjustment__c, Amount__c, TravelDistance__c, TotalUndocumentedExpenses__c
            FROM HOT_ClaimLineItem__c
            LIMIT 1
        ];

        System.assertEquals(
            true,
            updatedClaim.ReProcessedRate__c,
            'Kravets ReProcessedRate__c-flagg skulle vært satt til true.'
        );

        System.assertEquals(
            expectedDelta,
            updatedCli.DeltaAfterAdjustment__c,
            'DeltaAfterAdjustment__c ble ikke beregnet korrekt inkludert kjøregodtgjørelse.'
        );
    }

    /**
     * Tester hva som skjer hvis ingen satser blir funnet.
     */
    @isTest
    static void testRateController_MissingRates() {
        delete [SELECT Id FROM HOT_Rate__c];

        HOT_ClaimLineItem__c cli = [
            SELECT Id, Claim__c, Amount__c, DeltaAfterAdjustment__c
            FROM HOT_ClaimLineItem__c
            LIMIT 1
        ];
        List<HOT_ClaimLineItem__c> cliList = [
            SELECT
                Id,
                Claim__c,
                StartTime__c,
                EndTime__c,
                TravelFromStartTime__c,
                TravelFromEndTime__c,
                TravelToStartTime__c,
                TravelToEndTime__c,
                DayHours__c,
                EveningNightAndWeekendHours__c,
                TravelHours__c,
                Amount__c,
                DeltaAfterAdjustment__c,
                TravelDistance__c
            FROM HOT_ClaimLineItem__c
            WHERE Id = :cli.Id
        ];

        Test.startTest();
        HOT_RateController.calculateClaimByRates(cliList, true);
        Test.stopTest();

        HOT_Claim__c updatedClaim = [SELECT ReProcessedRate__c FROM HOT_Claim__c LIMIT 1];
        HOT_ClaimLineItem__c updatedCli = [SELECT Amount__c, DeltaAfterAdjustment__c FROM HOT_ClaimLineItem__c LIMIT 1];

        System.assertEquals(
            false,
            updatedClaim.ReProcessedRate__c,
            'ReProcessedRate__c skulle IKKE vært oppdatert når satser mangler.'
        );
        System.assertEquals(
            null,
            updatedCli.DeltaAfterAdjustment__c,
            'DeltaAfterAdjustment__c skulle IKKE vært beregnet når satser mangler.'
        );
        System.assertEquals(600, updatedCli.Amount__c, 'Amount__c skulle IKKE vært endret når satser mangler.');
    }
}
