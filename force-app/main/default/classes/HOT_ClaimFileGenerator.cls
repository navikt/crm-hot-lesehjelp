public without sharing class HOT_ClaimFileGenerator {
    public static final String FIRMAKODE = 'HR';
    public static final String STILLINGSID = '2224';
    public static final String LONNSART = 'L2510';
    public static final String TRANSAKSJONSTYPE = 'LS';
    public static final String CSV_HEADER = 'Firmakode;Ressurs-ID;Stillings-ID;lønnsart;Konto;Dato fra;Dato til;Nummer;Beløp;Fakturanr;Transaksjonstype\n';

    public static void generateFile(List<HOT_Claim__c> claims) {
        if (claims.isEmpty()) {
            System.debug('Ingen lesekrav klare for utbetaling.');
            return;
        }

        Set<Id> claimIds = new Map<Id, HOT_Claim__c>(claims).keySet();
        Map<Id, Map<String, Datetime>> claimTimeStartEnds = getClaimTimeStartEnds(claimIds);

        String fileContent = CSV_HEADER;
        List<HOT_Claim__c> claimsToUpdate = new List<HOT_Claim__c>();

        for (HOT_Claim__c claim : claims) {
            Map<String, Datetime> times = claimTimeStartEnds.get(claim.Id);
            String earliestStart = '';
            String latestEnd = '';

            if (times != null) {
                if (times.get('earliestStart') != null) {
                    earliestStart = DateTime.newInstance(
                            times.get('earliestStart').date(),
                            Time.newInstance(0, 0, 0, 0)
                        )
                        .format('yyyyMMdd');
                }
                if (times.get('latestEnd') != null) {
                    latestEnd = DateTime.newInstance(times.get('latestEnd').date(), Time.newInstance(0, 0, 0, 0))
                        .format('yyyyMMdd');
                }
            }

            Decimal totalHours = 0;
            if (claim.TotalEveningNightAndWeekendHours__c != null)
                totalHours += claim.TotalEveningNightAndWeekendHours__c;
            if (claim.TotalDayHours__c != null)
                totalHours += claim.TotalDayHours__c;
            if (claim.TotalTravelHours__c != null)
                totalHours += claim.TotalTravelHours__c;

            String bankAccount = (claim.Claimant__r != null &&
                claim.Claimant__r.CRM_Person__r != null &&
                claim.Claimant__r.CRM_Person__r.INT_BankAccountNumber__c != null)
                ? claim.Claimant__r.CRM_Person__r.INT_BankAccountNumber__c
                : '';

            Decimal payAmount;
            if (claim.ReProcessedRate__c == true) {
                payAmount = claim.DeltaAfterAdjustment__c;
            } else {
                payAmount = claim.Pay__c;
            }

            // hopp over hvis kritiske felter mangler
            if (
                String.isBlank(claim.Resource_number__c) ||
                String.isBlank(bankAccount) ||
                String.isBlank(earliestStart) ||
                String.isBlank(latestEnd) ||
                claim.Pay__c == null
            ) {
                continue;
            }

            fileContent +=
                FIRMAKODE +
                ';' +
                claim.Resource_number__c +
                ';' +
                STILLINGSID +
                ';' +
                LONNSART +
                ';' +
                bankAccount +
                ';' +
                earliestStart +
                ';' +
                latestEnd +
                ';' +
                totalHours +
                ';' +
                payAmount +
                ';' +
                claim.Name +
                ';' +
                TRANSAKSJONSTYPE +
                '\n';

            if (claim.ReprocessedRate__c == true) {
                claimsToUpdate.add(new HOT_Claim__c(Id = claim.Id, Status__c = 'Sent for payment'));
            } else {
                claimsToUpdate.add(new HOT_Claim__c(Id = claim.Id, Status__c = 'Sent for payment after recalculation'));
            }
        }

        if (fileContent == CSV_HEADER) {
            System.debug('Ingen lesekravble lagt til i filen.');
            return;
        }

        // Sørg for UTF-8 korrekthet
        Blob csvBlob = Blob.valueOf('\uFEFF' + fileContent); //for Excel

        // lagre CSV-fil i Salesforce

        Datetime now = Datetime.now();
        String timestamp = now.format('yyyyMMdd_HHmm'); // 20251028_1532
        String fileTitle = 'LesehjelpLønnskravEksport-' + timestamp;
        String filePath = fileTitle + '.csv';

        ContentVersion cv = new ContentVersion(Title = fileTitle, PathOnClient = filePath, VersionData = csvBlob);
        insert cv;

        // oppdater status på claims
        if (!claimsToUpdate.isEmpty()) {
            update claimsToUpdate;
        }

        System.debug(
            'Fil generert og ' + claimsToUpdate.size() + ' krav satt til "Sent for payment (after recalculation)".'
        );
    }

    public static Map<Id, Map<String, Datetime>> getClaimTimeStartEnds(Set<Id> claimIds) {
        List<HOT_ClaimLineItem__c> claimLineItems = [
            SELECT Id, Claim__c, StartTime__c, EndTime__c
            FROM HOT_ClaimLineItem__c
            WHERE Claim__c IN :claimIds
        ];

        Map<Id, Map<String, Datetime>> claimTimeMap = new Map<Id, Map<String, Datetime>>();

        for (HOT_ClaimLineItem__c item : claimLineItems) {
            if (!claimTimeMap.containsKey(item.Claim__c)) {
                claimTimeMap.put(
                    item.Claim__c,
                    new Map<String, Datetime>{ 'earliestStart' => item.StartTime__c, 'latestEnd' => item.EndTime__c }
                );
            } else {
                Map<String, Datetime> times = claimTimeMap.get(item.Claim__c);
                if (
                    item.StartTime__c != null &&
                    (times.get('earliestStart') == null ||
                    item.StartTime__c < times.get('earliestStart'))
                ) {
                    times.put('earliestStart', item.StartTime__c);
                }
                if (
                    item.EndTime__c != null &&
                    (times.get('latestEnd') == null ||
                    item.EndTime__c > times.get('latestEnd'))
                ) {
                    times.put('latestEnd', item.EndTime__c);
                }
            }
        }

        return claimTimeMap;
    }
}
