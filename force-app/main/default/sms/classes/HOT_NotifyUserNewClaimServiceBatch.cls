public without sharing class HOT_NotifyUserNewClaimServiceBatch implements Database.Batchable<sObject>, Schedulable {
    public void execute(SchedulableContext sc) {
        HOT_NotifyUserNewClaimServiceBatch instance = new HOT_NotifyUserNewClaimServiceBatch();
        database.executebatch(instance, 10);
    }

     public Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime now = Datetime.now();
        String query = 'SELECT ';
        query += 'Id, Account__c, Account__r.CRM_Person__r.INT_KrrMobilePhone__c, IsNotificationSent__c';
        query += 'FROM HOT_Claim__c ';
        query += 'WHERE Status__c = \'Sent\' ';
        query += 'AND (Account__r.CRM_Person__r.INT_KrrMobilePhone__c != null) AND (IsNotificationSent__c= FALSE)';

        return Database.getQueryLocator(query);
    }
     public void execute(Database.BatchableContext bc, List<HOT_Claim__c> records) {
        List<HOT_Claim__c> smsNotifications = new List<HOT_Claim__c>();

        for (HOT_Claim__c claim : records) {
                smsNotifications.add(claim);
        }
        try {
            if (!smsNotifications.isEmpty()) {
                HOT_SMSService.notifyUserOnNewClaim(smsNotifications);
            }
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
            logger.publish();
        }
    }
     public void finish(Database.BatchableContext bc) {
        if (!Test.isRunningTest()) {
            try {
                System.scheduleBatch(
                    new HOT_NotifyUserNewClaimServiceBatch(),
                    'HOT_NotifyUserNewClaimServiceBatch',
                    60,
                    10
                );
            } catch (Exception e) {
                LoggerUtility logger = new LoggerUtility();
                logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
                logger.publishSynch();
            }
        }
    }

}