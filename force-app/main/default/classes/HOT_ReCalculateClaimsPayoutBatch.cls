public without sharing class HOT_ReCalculateClaimsPayoutBatch implements Database.Batchable<SObject>, Schedulable {
    @InvocableMethod(
        label='Start recalculation of lesekrav'
        description='Starts the HOT_ReCalculateClaimsPayoutBatch job'
    )
    public static void startBatchJob() {
        HOT_ReCalculateClaimsPayoutBatch batchJob = new HOT_ReCalculateClaimsPayoutBatch();
        Database.executeBatch(batchJob, 10);
    }
    public void execute(SchedulableContext sc) {
        HOT_ReCalculateClaimsPayoutBatch batchJob = new HOT_ReCalculateClaimsPayoutBatch();
        Database.executeBatch(batchJob, 100);
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, ProcessedRate__c, ReProcessedRate__c, Status__c FROM HOT_Claim__c WHERE ProcessedRate__c = true AND ReProcessedRate__c = false AND ApprovedByNAV__c = true AND (Status__c = \'Paid out\')';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<SObject> records) {
        System.debug('records: ' + records);
        if (!records.isEmpty()) {
            try {
                Set<Id> claimIds = new Set<Id>();
                for (SObject sObj : records) {
                    HOT_Claim__c claim = (HOT_Claim__c) sObj;
                    claimIds.add(claim.Id);
                }
                List<HOT_ClaimLineItem__c> claimLineItems = [
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
                        TravelDistance__c,
                        TotalUndocumentedExpenses__c
                    FROM HOT_ClaimLineItem__c
                    WHERE Claim__c IN :claimIds
                ];

                System.debug('calculateClaimByRates: ' + claimLineItems);
                HOT_RateController.calculateClaimByRates(claimLineItems, true);
            } catch (Exception e) {
                System.debug('Error processing batch: ' + e.getMessage());
                LoggerUtility logger = new LoggerUtility();
                logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
                logger.publishSynch();
            }
        }
    }

    // Batchable finish
    public void finish(Database.BatchableContext bc) {
        // Optional: Add any post-processing logic here
        System.debug('Batch job finished successfully.');
    }
}
