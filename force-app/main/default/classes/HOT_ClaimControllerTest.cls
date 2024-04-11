@isTest
public class HOT_ClaimControllerTest {
    @TestSetup
    static void setup(){
        Account acc = new Account();
        acc.Name = 'Ola Lesehjelp';
        insert acc;
        Account acc2 = new Account();
        acc2.Name = 'Kari Bruker';
        insert acc2;
        HOT_Claim__c claim = HOT_LesehjelpTestDataFactory.createClaim(acc2, acc);
        insert claim;

        HOT_Entitlement__c entitlement=HOT_LesehjelpTestDataFactory.createEntitlement(acc2);
        insert entitlement;
    }
    @isTest
    static void setEntitlementOnClaimTest(){
        HOT_Claim__c claim=[SELECT Id FROM HOT_Claim__c];
        HOT_ClaimLineItem__c cli=HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        insert cli;
        Test.startTest();
        HOT_Claim__c claimResult=[SELECT Id, Entitlement__c FROM HOT_Claim__c];
        Test.stopTest();
        System.assertNotEquals(null, claimResult.Entitlement__c);

    }
    @isTest
    static void getMyClaimsTest(){
        Test.startTest();
        List<HOT_Claim__c> myClaims=HOT_ClaimController.getMyClaims();
        Test.stopTest();
        System.assertEquals(0, myClaims.size());
    }
    @isTest
    static void notifyUserOnDeclinedClaimTest(){
        Test.startTest();
        HOT_Claim__c claim=[SELECT Id, Account__c FROM HOT_Claim__c];
        claim.Status__c='Declined by NAV';
        update claim;
        Test.stopTest();
        List <SMS__c> sms=[SELECT Id, Account__c FROM SMS__c WHERE Account__c=:claim.Account__c];
        System.assertEquals(0, sms.size()); 
    }
     @isTest
    static void notifyUserOnNewClaimTest(){
        Test.startTest();
        List<HOT_Claim__c> claims=[SELECT Id, Account__c, Account__r.CRM_Person__r.INT_KrrMobilePhone__c FROM HOT_Claim__c];
        HOT_SMSService.notifyUserOnNewClaim(claims);
        Test.stopTest();
    }
     @isTest
    static void notifyUserOnDeclinedClaim2Test(){
        Test.startTest();
        HOT_Claim__c claim=[SELECT Id, Account__c FROM HOT_Claim__c];
        claim.Status__c='Approved by user';
        update claim;
        claim.Status__c='Declined by NAV';
        update claim;
        Test.stopTest();
        List <SMS__c> sms=[SELECT Id, Account__c FROM SMS__c WHERE Account__c=:claim.Account__c];
        System.assertEquals(0, sms.size()); 
    }
     @isTest
    static void updateEntitleHoursAlreadyUsedTest(){
        Test.startTest();
        HOT_Entitlement__c entitlement=[SELECT Id, EntitledHoursAlreadyUsed__c FROM HOT_Entitlement__c];
        entitlement.EntitledHoursAlreadyUsed__c=12;
        update entitlement;
        HOT_Entitlement__c result=[SELECT Id, EntitledHoursUsed__c FROM HOT_Entitlement__c];

        Test.stopTest();
        System.assertEquals(12, result.EntitledHoursUsed__c); 
    }
     @isTest
    static void getMyEntitlementsTest(){
        Test.startTest();
        List<HOT_Entitlement__c> entitlements =HOT_EntitlementController.getEntitlements();
        Test.stopTest();
        System.assertEquals(0, entitlements.size()); 
    }
    @isTest
    static void recalculateEntitlementOnClaimWhenCLIUpdateTest(){
        HOT_Claim__c claim=[SELECT Id FROM HOT_Claim__c];
        HOT_ClaimLineItem__c cli=HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        insert cli;
        HOT_ClaimLineItem__c cliChange=[SELECT Id FROM HOT_ClaimLineItem__c];
        Date twoDaysAgo = Date.today().addDays(-2);
        cliChange.Date__c = twoDaysAgo;
        update cliChange;
    }
    @isTest
    static void approveClaimTest(){
        Test.startTest();
        HOT_Claim__c claim=[SELECT Id FROM HOT_Claim__c];
        HOT_ClaimLineItem__c cli=HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        insert cli;
        HOT_ClaimController.approveClaim(claim.Id, 'Takk for fint møte');
        HOT_Claim__c result=[SELECT Id, ApprovedByUser__c FROM HOT_Claim__c];
        Test.stopTest();
        System.assertEquals(true, result.ApprovedByUser__c); 
    }
    @isTest
    static void declineClaimTest(){
        Test.startTest();
        HOT_Claim__c claim=[SELECT Id FROM HOT_Claim__c];
        HOT_ClaimLineItem__c cli=HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        insert cli;
        HOT_ClaimController.declineClaim(claim.Id, 'Dette stemmer ikke');
        HOT_Claim__c result=[SELECT Id, ApprovedByUser__c FROM HOT_Claim__c];
        Test.stopTest();
        System.assertEquals(false, result.ApprovedByUser__c); 
    }
    @isTest
    static void cancelClaimTest(){
        Test.startTest();
        HOT_Claim__c claim=[SELECT Id FROM HOT_Claim__c];
        HOT_ClaimLineItem__c cli=HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        insert cli;
        HOT_ClaimController.cancelClaim(claim.Id);
        HOT_Claim__c result=[SELECT Id, Status__c FROM HOT_Claim__c];
        Test.stopTest();
        System.assertEquals('Withdrawn', result.Status__c); 
    }
    @isTest
    static void getClaimTest(){
        Test.startTest();
        HOT_Claim__c claim=[SELECT Id FROM HOT_Claim__c];
        List<HOT_Claim__c> result=HOT_ClaimController.getClaim(claim.Id);
        Test.stopTest();
        System.assertEquals(1, result.size()); 
    }
    @isTest
    static void getMyPreviousClaimsTest(){
        Test.startTest();
        List<HOT_Claim__c> result=HOT_ClaimController.getMyPreviousClaims();
        Test.stopTest();
        System.assertEquals(0, result.size()); 
    }
}