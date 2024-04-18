@IsTest
public class HOT_ClaimLineItemControllerTest {
    @TestSetup
    static void setup() {
        Account acc = new Account();
        acc.Name = 'Ola Lesehjelp';
        insert acc;
        Account acc2 = new Account();
        acc2.Name = 'Kari Bruker';
        insert acc2;
        HOT_Claim__c claim = HOT_LesehjelpTestDataFactory.createClaim(acc2, acc);
        insert claim;
    }
    @IsTest
    static void getClaimLineItemsTest() {
        Test.startTest();
        HOT_Claim__c claim = [SELECT Id FROM HOT_Claim__c];
        HOT_ClaimLineItem__c cli = HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        insert cli;
        List<HOT_ClaimLineItem__c> cliList = HOT_ClaimLineItemController.getClaimLineItems(claim.Id);
        Test.stopTest();
        System.assertEquals(1, cliList.size());
    }
}
