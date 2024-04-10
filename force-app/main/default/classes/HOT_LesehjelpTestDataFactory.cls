@isTest
public class HOT_LesehjelpTestDataFactory {
    public static HOT_Claim__c createClaim(Account account, Account claimaint) {
        HOT_Claim__c claim=new HOT_Claim__c();
        claim.Account__c=account.Id;
        claim.Claimant__c=claimaint.Id;
        claim.Type__c='Arbeidsliv';
        return claim;
    }
    public static HOT_ClaimLineItem__c createClaimLineItems(HOT_Claim__c claim) {
        HOT_ClaimLineItem__c cli = new HOT_ClaimLineItem__c();
        cli.Claim__c=claim.Id;
        Date yesterday = Date.today().addDays(-1);
        cli.Date__c = yesterday;
        // Set start and end times to yesterday from 14:00 to 15:00
        Time startTime = Time.newInstance(14, 0, 0, 0);
        Time endTime = Time.newInstance(15, 0, 0, 0);
        DateTime startDateTime = DateTime.newInstance(yesterday, startTime);
        DateTime endDateTime = DateTime.newInstance(yesterday, endTime);
        cli.StartTime__c = startDateTime;
        cli.EndTime__c = endDateTime;
        return cli;
    }
    public static HOT_Entitlement__c createEntitlement(Account account){
        HOT_Entitlement__c entitlement = new HOT_Entitlement__c();
        entitlement.Account__c=account.Id;
        entitlement.Type__c='Arbeidsliv';
        entitlement.EntitledHours__c=120;
        entitlement.FromDate__c=Date.today().addDays(-1);
        entitlement.ToDate__c=Date.today().addDays(3);
        return entitlement;
    }
}