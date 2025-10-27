public without sharing class HOT_CalculateClaimsPayoutBatch implements Database.Batchable<SObject>, Schedulable {
    public void execute(SchedulableContext sc) {
        HOT_CalculateClaimsPayoutBatch batchJob = new HOT_CalculateClaimsPayoutBatch();
        Database.executeBatch(batchJob, 100);
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, ProcessedRate__c FROM HOT_Claim__c WHERE ProcessedRate__c = false AND ReProcessedRate__c = false AND ApprovedByNAV__c = true AND (Status__c = \'Approved by NAV\')';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<SObject> records) {
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

                HOT_RateController.calculateClaimByRates(claimLineItems, false);
            } catch (Exception e) {
                System.debug('Error processing batch: ' + e.getMessage());
            }
        }
    }

    // Batchable finish
    public void finish(Database.BatchableContext bc) {
        // Optional: Add any post-processing logic here
        System.debug('Batch job finished successfully.');
    }
}
