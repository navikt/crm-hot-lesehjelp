public without sharing class HOT_ClaimHandler extends MyTriggers{
    public override void onAfterUpdate(Map<Id, sObject> triggerOldMap) {
        List<HOT_Claim__c> claimsToNotifyUserOnDeclinedStatus = new List<HOT_Claim__c>();
        for (HOT_Claim__c claim : (List<HOT_Claim__c>) records) {
            if (
                triggerOldMap.get(claim.Id).get('Status__c') == 'Sent' || triggerOldMap.get(claim.Id).get('Status__c') == '	Approved by user' &&
                claim.Status__c == 'Declined'
            ) {
                claimsToNotifyUserOnDeclinedStatus.add(claim);
            }
        }
        if (claimsToNotifyUserOnDeclinedStatus.size() > 0) {
            HOT_SMSService.notifyUserOnDeclinedClaim(claimsToNotifyUserOnDeclinedStatus);
        }
    }
}