public without sharing class HOT_SMSService {
    public static void notifyUserOnNewClaim(List<HOT_Claim__c> claimList) {
        Map<Id, HOT_Claim__c> claims = new Map<Id, HOT_Claim__c>(claimList);
        List<SMS__c> smsList = new List<SMS__c>();

        for (HOT_Claim__c claim : claims.values()) {
            SMS__c sms = new SMS__c();
            sms.Domain__c = 'HOT';
            sms.Type__c = 'New Claim';
            sms.Account__c = claim.Account__c;
            sms.Recipient__c = claim.Account__r.CRM_Person__r.INT_KrrMobilePhone__c;
            String message = 'En lesehjelper har meldt inn et krav som du må behandle.';
            message += '\n\nFor mer informasjon, se lesehjelp.nav.no. ';
            message += 'Du kan ikke svare på denne meldingen. ';
            message += '\nMvh NAV';
            sms.Message__c = message;
            if (SMS.Recipient__c != null) {
                smsList.add(sms);
            }
        }
        insert smsList;
    }
    public static void notifyUserOnDeclinedClaim(List<HOT_Claim__c> claimList) {
        List<HOT_Claim__c> claims = [
            SELECT Id, Claimant__c, Claimant__r.CRM_Person__r.INT_KrrMobilePhone__c
            FROM HOT_Claim__c
            WHERE Id IN :claimList
        ];
        List<SMS__c> smsList = new List<SMS__c>();

        for (HOT_Claim__c claim : claims) {
            SMS__c sms = new SMS__c();
            sms.Domain__c = 'HOT';
            sms.Type__c = 'Claim Declined By User';
            sms.Account__c = claim.Claimant__c;
            sms.Recipient__c = claim.Claimant__r.CRM_Person__r.INT_KrrMobilePhone__c;
            String message = 'Et krav du har sendt inn etter å ha vært lesehjelper er avvist.';
            message += '\n\nFor mer informasjon, se lesehjelp.nav.no. ';
            message += 'Du kan ikke svare på denne meldingen. ';
            message += '\nMvh NAV';
            sms.Message__c = message;
            if (SMS.Recipient__c != null) {
                smsList.add(sms);
            }
        }
        insert smsList;
    }
    public static void notifyUserOnDeclinedClaimByNAV(List<HOT_Claim__c> claimList) {
        List<HOT_Claim__c> claims = [
            SELECT Id, Claimant__c, Claimant__r.CRM_Person__r.INT_KrrMobilePhone__c
            FROM HOT_Claim__c
            WHERE Id IN :claimList
        ];
        List<SMS__c> smsList = new List<SMS__c>();

        for (HOT_Claim__c claim : claims) {
            SMS__c sms = new SMS__c();
            sms.Domain__c = 'HOT';
            sms.Type__c = 'Claim Declined By NAV';
            sms.Account__c = claim.Claimant__c;
            sms.Recipient__c = claim.Claimant__r.CRM_Person__r.INT_KrrMobilePhone__c;
            String message = 'Et krav du har sendt inn etter å ha vært lesehjelper er avslått av NAV.';
            message += '\n\nFor mer informasjon, se lesehjelp.nav.no. ';
            message += 'Du kan ikke svare på denne meldingen. ';
            message += '\nMvh NAV';
            sms.Message__c = message;
            if (SMS.Recipient__c != null) {
                smsList.add(sms);
            }
        }
        insert smsList;
    }
}
