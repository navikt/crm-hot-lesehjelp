public without sharing class HOT_SMSService {
        public static void notifyUserOnNewClaim(List<HOT_Claim__c> claimList) {
        Map<Id, HOT_Claim__c> claims = new Map<Id, HOT_Claim__c>(claimList);
        List<SMS__c> smsList = new List<SMS__c>();

        for (HOT_Claim__c claim : claims.values()) {
            SMS__c sms = new SMS__c();
            sms.Domain__c = 'HOT';
            sms.Type__c = 'New claim sms';
            sms.Account__c = claim.Account__c;
            sms.Recipient__c = claim.Account__r.CRM_Person__r.INT_KrrMobilePhone__c;
            String message='En lesehjelp har opprettet et krav som du kan godkjenne.';
            message += '\n\nFor mer informasjon, se lesehjelp.nav.no. ';
            message+='Du kan ikke svare på denne meldingen. ';
            message += '\nMvh NAV';
            sms.Message__c = message;
            if (SMS.Recipient__c != null) {
                smsList.add(sms);
            }
        }
        insert smsList;
    }
}