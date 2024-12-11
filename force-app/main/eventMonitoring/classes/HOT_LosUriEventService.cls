/* 
convert UriEvent to Log__c record with lookup to Person Ident
Make it possible for NAV's "snokelogg" to get log elemnts
*/
public with sharing class HOT_LosUriEventService {
    public static void addPersonRelatedRecordsToLog(List<UriEvent> uriEvents) {
        List<Log__c> logs = new List<Log__c>();

        Map<Id, UriEvent> uriEventByRecordId = new Map<Id, UriEvent>();

        //record ids for each object we want to log
        Set<Id> hotClaimRecordIds = new Set<Id>();
        Set<Id> hotClaimLineItemsRecordIds = new Set<Id>();
        Set<Id> hotEntitlementRecordIds = new Set<Id>();

        //check if object type should be logged
        for (UriEvent ue : uriEvents) {
            //only standard users are logged
            if (ue.UserType != 'Standard')
                continue;

            switch on ue.QueriedEntities {
                when 'HOT_Claim__c' {
                    uriEventByRecordId.put(ue.RecordId, ue);
                    hotClaimRecordIds.add(ue.RecordId);
                }
                when 'HOT_ClaimLineItem__c' {
                    uriEventByRecordId.put(ue.RecordId, ue);
                    hotClaimLineItemsRecordIds.add(ue.RecordId);
                }
                when 'HOT_Entitlement__c' {
                    uriEventByRecordId.put(ue.RecordId, ue);
                    hotEntitlementRecordIds.add(ue.RecordId);
                }
            }
        }

        //get related person ident for each object
        Map<Id, String> personIdentByRecordId = getPersonIdentsForEachObject(
            hotClaimRecordIds,
            hotClaimLineItemsRecordIds,
            hotEntitlementRecordIds
        );

        //add log elemnt with person ident
        for (Id recordId : personIdentByRecordId.keyset()) {
            logs.add(addLogElement(uriEventByRecordId.get(recordId), personIdentByRecordId.get(recordId)));
        }

        if (logs.size() > 0) {
            insert logs;
        }
    }

    private static Map<Id, String> getPersonIdentsForEachObject(
        Set<Id> hotClaimRecordIds,
        Set<Id> hotClaimLineItemsRecordIds,
        Set<Id> hotEntitlementRecordIds
    ) {
        Map<Id, String> personIdentByRecordId = new Map<Id, String>();

        //HOT Claim
        if (hotClaimRecordIds.size() > 0) {
            for (HOT_Claim__c claim : [
                SELECT Id, Claimant__r.CRM_Person__r.Name
                FROM HOT_Claim__c
                WHERE Id IN :hotClaimRecordIds
            ]) {
                personIdentByRecordId.put(claim.Id, claim.Claimant__r.CRM_Person__r.Name);
            }
        }
        //HOT ClaimLineItem
        if (hotClaimLineItemsRecordIds.size() > 0) {
            for (HOT_ClaimLineItem__c claimLineItem : [
                SELECT Id, Claim__r.Claimant__r.CRM_Person__r.Name
                FROM HOT_ClaimLineItem__c
                WHERE Id IN :hotClaimLineItemsRecordIds
            ]) {
                personIdentByRecordId.put(claimLineItem.Id, claimLineItem.Claim__r.Claimant__r.CRM_Person__r.Name);
            }
        }
        //HOT Entitlement
        if (hotEntitlementRecordIds.size() > 0) {
            for (HOT_Entitlement__c entitlement : [
                SELECT Id, Account__r.CRM_Person__r.Name
                FROM HOT_Entitlement__c
                WHERE Id IN :hotEntitlementRecordIds
            ]) {
                personIdentByRecordId.put(entitlement.Id, entitlement.Account__r.CRM_Person__r.Name);
            }
        }

        return personIdentByRecordId;
    }

    private static Log__c addLogElement(UriEvent ue, String personIdent) {
        return new Log__c(
            CRM_RecordId__c = ue.RecordId,
            CRM_EventDate__c = ue.EventDate,
            CRM_QueriedEntity__c = ue.QueriedEntities,
            CRM_Username__c = ue.Username,
            CRM_Operation__c = ue.Operation,
            CRM_PersonIdent__c = personIdent,
            CRM_Type__c = 'LightningUriEvent',
            CRM_Status__c = 'Completed'
        );
    }
}
