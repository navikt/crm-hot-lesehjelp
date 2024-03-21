public without sharing class HOT_KrrBatch implements Database.Batchable<sObject>, Schedulable {
    public void execute(SchedulableContext sc) {
        HOT_KrrBatch instance = new HOT_KrrBatch();
        database.executebatch(instance, 10);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Person__r.INT_KrrIntegrationStatus__c FROM Account WHERE Person__c != null AND Person__r.LastModifiedDate = LAST_N_DAYS:3 AND (Person__r.INT_KrrIntegrationStatus__c = \'Queued\' OR Person__r.INT_KrrIntegrationStatus__c = \'Failed\')';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account> records) {
        Set<Id> accountIds = new Set<Id>();
        for (Account account : records) {
            accountIds.add(account.Id);
        }
        HOT_KRRCalloutQueuable2 krr = new HOT_KRRCalloutQueuable2(accountIds);
        System.enqueueJob(krr);
    }

    public void finish(Database.BatchableContext bc) {
        if (!Test.isRunningTest()) {
            try {
                System.scheduleBatch(new HOT_KrrBatch(), 'HOT_KrrBatch', 60, 10);
            } catch (Exception e) {
                LoggerUtility logger = new LoggerUtility();
                logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
                logger.publishSynch();
            }
        }
    }
}
