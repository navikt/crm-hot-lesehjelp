@isTest
private class HOT_CalculateClaimsPayoutBatchTest {
    @testSetup
    static void setup() {
        myTriggers.disable(PersonAccessHandler.class);
        Person__c person = HOT_LesehjelpTestDataFactory.createPerson();
        person.Name = '12015678999';
        person.INT_BankAccountNumber__c = '122344556';
        insert person;

        Person__c person2 = HOT_LesehjelpTestDataFactory.createPerson();
        person2.Name = '12015678993';
        person2.INT_BankAccountNumber__c = '122344553';
        insert person2;

        Account acc = HOT_LesehjelpTestDataFactory.createAccount(true);
        acc.INT_PersonIdent__c = '12015678993';
        acc.CRM_Person__c = person.Id;
        insert acc;

        Account acc2 = HOT_LesehjelpTestDataFactory.createAccount(true);
        acc2.INT_PersonIdent__c = '12015678999';
        acc2.CRM_Person__c = person.Id;
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
            Account__c = acc.Id,
            Type__c = 'Dagligliv',
            EntitledHours__c = 120,
            FromDate__c = Date.today().addDays(-1),
            ToDate__c = Date.today().addDays(3)
        );
        insert entitlement;

        HOT_Claim__c testClaim = new HOT_Claim__c(
            Account__c = acc.Id,
            Claimant__c = acc2.Id,
            Entitlement__c = entitlement.Id,
            Type__c = 'Dagligliv',
            ApprovedByUser__c = true,
            ApprovedByNAV__c = true,
            Status__c = 'Approved by NAV',
            ProcessedRate__c = false,
            ReProcessedRate__c = false
        );
        insert testClaim;

        DateTime workStartGmt = Datetime.newInstanceGmt(
            Date.today().year(),
            Date.today().month(),
            Date.today().day(),
            7,
            0,
            0
        );
        DateTime workEndGmt = Datetime.newInstanceGmt(
            Date.today().year(),
            Date.today().month(),
            Date.today().day(),
            9,
            0,
            0
        );

        DateTime travelStartGmt = Datetime.newInstanceGmt(
            Date.today().year(),
            Date.today().month(),
            Date.today().day(),
            6,
            30,
            0
        );
        DateTime travelEndGmt = Datetime.newInstanceGmt(
            Date.today().year(),
            Date.today().month(),
            Date.today().day(),
            7,
            0,
            0
        );

        HOT_ClaimLineItem__c testCli = new HOT_ClaimLineItem__c(
            Claim__c = testClaim.Id,
            StartTime__c = workStartGmt,
            EndTime__c = workEndGmt,
            HasTravelFrom__c = true,
            TravelFromStartTime__c = travelStartGmt,
            TravelFromEndTime__c = travelEndGmt,
            DayHours__c = 2.0, // Forventer 2.0 * 100 = 200
            EveningNightAndWeekendHours__c = 0.5, // Forventer 0.5 * 200 = 100
            TravelHours__c = 0.5, // Forventer 0.5 * 50 = 25
            TravelDistance__c = 10,
            TotalUndocumentedExpenses__c = 100,
            Amount__c = null
        );
        insert testCli;
    }

    //-------------------------------------------------------------------------
    @isTest
    static void testSchedulableAndBatchExecution() {
        HOT_ClaimLineItem__c setupCli = [
            SELECT DayHours__c, EveningNightAndWeekendHours__c, TravelHours__c, TravelDistance__c
            FROM HOT_ClaimLineItem__c
            LIMIT 1
        ];

        Decimal expectedAmount =
            (setupCli.DayHours__c * 100) +
            (setupCli.EveningNightAndWeekendHours__c * 200) +
            (setupCli.TravelHours__c * 50) + // 0.5 * 50 = 25
            (setupCli.TravelDistance__c * 3.5) +
            100;

        Test.startTest();
        String cron = '0 0 1 * * ?';
        System.schedule('TestCalculateClaimsPayout', cron, new HOT_CalculateClaimsPayoutBatch());

        HOT_CalculateClaimsPayoutBatch batchJob = new HOT_CalculateClaimsPayoutBatch();
        Database.executeBatch(batchJob, 100);

        Test.stopTest();

        // Verifisering av resultat
        HOT_Claim__c updatedClaim = [SELECT ProcessedRate__c, ReProcessedRate__c FROM HOT_Claim__c LIMIT 1];
        HOT_ClaimLineItem__c updatedCli = [SELECT Amount__c, DeltaAfterAdjustment__c FROM HOT_ClaimLineItem__c LIMIT 1];

        // 1. Kravet skal være markert som behandlet
        System.assertEquals(
            true,
            updatedClaim.ProcessedRate__c,
            'Kravets ProcessedRate__c-flagg skulle vært satt til true etter førstegangsbehandling.'
        );

        // 2. ReProcessedRate__c skal fortsatt være false
        System.assertEquals(
            false,
            updatedClaim.ReProcessedRate__c,
            'Kravets ReProcessedRate__c-flagg skal forbli false.'
        );

        // 3. Beløpet skal være beregnet korrekt
        System.assertEquals(
            expectedAmount,
            updatedCli.Amount__c,
            'Amount__c ble ikke beregnet korrekt under førstegangskjøring.'
        );

        // 4. Delta skal være null (fordi det er en førstegangsberegning)
        System.assertEquals(
            null,
            updatedCli.DeltaAfterAdjustment__c,
            'DeltaAfterAdjustment__c skal være null ved førstegangsberegning.'
        );
    }

    @isTest
    static void testStartMethodQuery() {
        HOT_Entitlement__c ent = [SELECT Id, Account__c FROM HOT_Entitlement__c LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Id = :ent.Account__c];

        // Claim 2: Feil status -> Skal ikke plukkes opp
        // LØSNING: Legg til ApprovedByUser__c = true
        insert new HOT_Claim__c(
            Account__c = acc.Id,
            Claimant__c = acc.Id,
            Entitlement__c = ent.Id,
            Type__c = 'Dagligliv',
            ApprovedByNAV__c = true,
            ApprovedByUser__c = true, // <<-- LAGT TIL
            Status__c = 'Paid out',
            ProcessedRate__c = false,
            ReProcessedRate__c = false
        );

        // Claim 3: Allerede behandlet -> Skal ikke plukkes opp
        // LØSNING: Legg til ApprovedByUser__c = true
        insert new HOT_Claim__c(
            Account__c = acc.Id,
            Claimant__c = acc.Id,
            Entitlement__c = ent.Id,
            Type__c = 'Dagligliv',
            ApprovedByNAV__c = true,
            ApprovedByUser__c = true, // <<-- LAGT TIL
            Status__c = 'Approved by NAV',
            ProcessedRate__c = true,
            ReProcessedRate__c = false
        );

        Test.startTest();
        HOT_CalculateClaimsPayoutBatch batchJob = new HOT_CalculateClaimsPayoutBatch();

        // Sjekk at query'en returnerer riktig antall rader (kun én skal plukkes opp fra setup-metoden)
        Database.QueryLocator queryLocator = batchJob.start(null);
        String queryString = queryLocator.getQuery();

        List<HOT_Claim__c> claims = Database.query(queryString);
        Test.stopTest();

        System.assertEquals(
            1,
            claims.size(),
            'Batch-queryen skal kun hente det ene kravet som er klart for førstegangsbehandling.'
        );
    }
}
