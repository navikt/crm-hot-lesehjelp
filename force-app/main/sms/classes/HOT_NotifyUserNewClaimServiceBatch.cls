public without sharing class HOT_NotifyUserNewClaimServiceBatch implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime now = Datetime.now();
        String query = 'SELECT ';
        query += 'Id, Account__c, Account__r.CRM_Person__r.INT_KrrMobilePhone__c, IsNotificationSent__c ';
        query += 'FROM HOT_Claim__c ';
        query += 'WHERE Status__c = \'Sent\' ';
        query += 'AND (Account__r.CRM_Person__r.INT_KrrMobilePhone__c != null) AND (IsNotificationSent__c= FALSE)';

        return Database.getQueryLocator(query);
    }
     public void execute(Database.BatchableContext bc, List<HOT_Claim__c> records) {
        List<HOT_Claim__c> smsNotifications = new List<HOT_Claim__c>();

        for (HOT_Claim__c claim : records) {
                smsNotifications.add(claim);
                claim.IsNotificationSent__c=true;
        }
        try {
            if (!smsNotifications.isEmpty()) {
                update records;
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