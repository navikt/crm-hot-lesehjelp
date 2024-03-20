public without sharing class HOT_KrrBatch implements Database.Batchable<sObject>, Schedulable {
    public void execute(SchedulableContext sc) {
        HOT_KrrErrorBatch instance = new HOT_KrrErrorBatch();
        database.executebatch(instance, 10);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Person__r.INT_KrrIntegrationStatus__c FROM Account WHERE Person__c != null AND Person__r.INT_KrrIntegrationStatus__c = \'Queued\' OR Person__r.INT_KrrIntegrationStatus__c = \'Failed\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account> records) {
        HOT_KRRCalloutQueuable krr = new HOT_KRRCalloutQueuable(records);
        System.enqueueJob(krr);
    }

    public void finish(Database.BatchableContext bc) {
        if (!Test.isRunningTest()) {
            try {
                System.scheduleBatch(new HOT_KrrErrorBatch(), 'HOT_KrrErrorBatch', 60, 10);
            } catch (Exception e) {
                LoggerUtility logger = new LoggerUtility();
                logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
                logger.publishSynch();
            }
        }
    }
}
