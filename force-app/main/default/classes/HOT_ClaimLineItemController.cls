public without sharing class HOT_ClaimLineItemController {
    @AuraEnabled(cacheable=true)
    public static List<HOT_ClaimLineItem__c> getClaimLineItems(String recordId){
            List<HOT_ClaimLineItem__c> claimLineItems = [
            SELECT
                Id, Date__c, StartTime__c, EndTime__c, HasTravelTo__c,HasTravelFrom__c, NormalRate__c, NumberOfHours__c, Task__c, TravelFromEndTime__c, TravelFromStartTime__c, TravelTo__c, TravelRate__c, TravelToEndTime__c, TravelToStartTime__c, TypeOfTask__c, Weekday__c, AdditionalInformation__c
            FROM HOT_ClaimLineItem__c
            WHERE Claim__c=:recordId
        ];
        return claimLineItems;
    }
}