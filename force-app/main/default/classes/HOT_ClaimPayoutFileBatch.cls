public with sharing class HOT_ClaimPayoutFileBatch implements Database.Batchable<SObject>, Schedulable {
    public void execute(SchedulableContext sc) {
        HOT_ClaimPayoutFileBatch batchJob = new HOT_ClaimPayoutFileBatch();
        Database.executeBatch(batchJob, 100);
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query =
            'SELECT ' +
            'Id, ' +
            'Name, ' +
            'Pay__c, ' +
            'DeltaAfterAdjustment__c, ' +
            'Resource_number__c, ' +
            'TotalEveningNightAndWeekendHours__c, ' +
            'TotalDayHours__c, ' +
            'TotalTravelHours__c, ' +
            'Claimant__r.CRM_Person__r.INT_BankAccountNumber__c, ' +
            'ReProcessedRate__c, ' +
            'ApprovedByNAV__c, ' +
            'Status__c, ' +
            'ProcessedRate__c ' +
            'FROM HOT_Claim__c ' +
            'WHERE ' +
            'Claimant__r.CRM_Person__r.INT_BankAccountNumber__c != NULL ' +
            'AND Claimant__r.CRM_Person__r.INT_BankAccountNumber__c != \'\' ' +
            'AND Claimant__r.CRM_Person__r.INT_IsNavEmployee__c = FALSE ' +
            'AND ProcessedRate__c = TRUE ' +
            'AND OnEmployer__c = FALSE ' +
            'AND (' +
            '(' +
            'ReProcessedRate__c = FALSE ' +
            'AND ApprovedByNAV__c = TRUE ' +
            'AND Status__c = \'Approved by NAV\' ' +
            'AND Pay__c != NULL ' +
            ') ' +
            'OR (' +
            'ReProcessedRate__c = TRUE ' +
            'AND Status__c = \'Recalculated\' ' +
            'AND DeltaAfterAdjustment__c != NULL ' +
            ') ' +
            ')';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<SObject> records) {
        if (!records.isEmpty()) {
            try {
                List<HOT_Claim__c> claims = (List<HOT_Claim__c>) records;
                HOT_ClaimFileGenerator.generateFile(claims);
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
