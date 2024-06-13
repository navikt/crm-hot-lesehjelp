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
    @IsTest
    static void getClaimLineItemsNoOverlapTest() {
        Test.startTest();
        HOT_Claim__c claim = [SELECT Id FROM HOT_Claim__c];
        HOT_ClaimLineItem__c cli = HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        insert cli;
        HOT_ClaimLineItem__c cli2 = HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        cli2.StartTime__c = cli2.StartTime__c.addDays(1);
        cli2.EndTime__c = cli2.EndTime__c.addDays(1);
        insert cli2;
        List<HOT_ClaimLineItem__c> cliList = HOT_ClaimLineItemController.checkForOverlapClaimLineItem(claim.Id);
        Test.stopTest();
        for (HOT_ClaimLineItem__c claimlineitem : cliList) {
            System.assertEquals(null, claimlineitem.OverlappingClaimLineItemsIds__c);
        }
    }
    @IsTest
    static void getClaimLineItemsOverlapTest() {
        Test.startTest();
        HOT_Claim__c claim = [SELECT Id FROM HOT_Claim__c];
        HOT_ClaimLineItem__c cli = HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        cli.HasTravelTo__c = true;
        cli.TravelToStartTime__c = cli.StartTime__c.addHours(-1);
        cli.TravelToEndTime__c = cli.StartTime__c;
        cli.HasTravelFrom__c = true;
        cli.TravelFromStartTime__c = cli.EndTime__c;
        cli.TravelFromEndTime__c = cli.EndTime__c.addHours(1);
        insert cli;
        HOT_ClaimLineItem__c cli2 = HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        cli2.EndTime__c = cli2.EndTime__c.addHours(1);
        cli2.HasTravelTo__c = true;
        cli2.TravelToStartTime__c = cli.StartTime__c.addMinutes(20);
        cli2.TravelToEndTime__c = cli.EndTime__c.addMinutes(-20);
        insert cli2;

        HOT_ClaimLineItem__c cli3 = HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        cli3.EndTime__c = cli2.EndTime__c.addHours(1);
        cli3.HasTravelFrom__c = true;
        cli3.TravelFromStartTime__c = cli.StartTime__c.addMinutes(20);
        cli3.TravelFromEndTime__c = cli.EndTime__c.addMinutes(-20);
        insert cli3;

        List<HOT_ClaimLineItem__c> cliList = HOT_ClaimLineItemController.checkForOverlapClaimLineItem(claim.Id);
        Test.stopTest();
        for (HOT_ClaimLineItem__c claimlineitem : cliList) {
            if (claimlineitem.Id == cli.Id) {
                Boolean containOverlapId = false;
                containOverlapId = claimlineitem.OverlappingClaimLineItemsIds__c.contains(cli2.Id);
                System.assertEquals(true, containOverlapId);
            }
            if (claimlineitem.Id == cli.Id) {
                Boolean containOverlapId = false;
                containOverlapId = claimlineitem.OverlappingClaimLineItemsIds__c.contains(cli3.Id);
                System.assertEquals(true, containOverlapId);
            }
        }
    }
    @IsTest
    static void getClaimLineItemsOverlapTravelTest() {
        Test.startTest();
        HOT_Claim__c claim = [SELECT Id FROM HOT_Claim__c];
        HOT_ClaimLineItem__c cli = HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        cli.HasTravelTo__c = true;
        cli.TravelToStartTime__c = cli.StartTime__c.addHours(-1);
        cli.TravelToEndTime__c = cli.StartTime__c;
        insert cli;
        HOT_ClaimLineItem__c cli2 = HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        cli2.HasTravelFrom__c = true;
        cli2.TravelFromStartTime__c = cli.TravelToStartTime__c;
        cli2.TravelFromEndTime__c = cli.TravelToEndTime__c.addHours(2);
        insert cli2;

        List<HOT_ClaimLineItem__c> cliList = HOT_ClaimLineItemController.checkForOverlapClaimLineItem(claim.Id);
        Test.stopTest();
        for (HOT_ClaimLineItem__c claimlineitem : cliList) {
            if (claimlineitem.Id == cli.Id) {
                Boolean containOverlapId = false;
                containOverlapId = claimlineitem.OverlappingClaimLineItemsIds__c.contains(cli2.Id);
                System.assertEquals(true, containOverlapId);
            }
        }
    }
    @IsTest
    static void getClaimLineItemsOverlapTravel2Test() {
        Test.startTest();
        HOT_Claim__c claim = [SELECT Id FROM HOT_Claim__c];
        HOT_ClaimLineItem__c cli = HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        cli.HasTravelFrom__c = true;
        cli.StartTime__c = cli.StartTime__c.addDays(3);
        cli.EndTime__c = cli.EndTime__c.addDays(3);
        cli.TravelFromStartTime__c = cli.StartTime__c.addHours(-2);
        cli.TravelFromEndTime__c = cli.StartTime__c;

        insert cli;
        HOT_ClaimLineItem__c cli2 = HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);
        cli2.HasTravelTo__c = true;
        cli2.TravelToStartTime__c = cli.TravelFromStartTime__c;
        cli2.TravelToEndTime__c = cli.TravelFromStartTime__c.addHours(3);
        insert cli2;
        HOT_ClaimLineItem__c cli3 = HOT_LesehjelpTestDataFactory.createClaimLineItems(claim);

        List<HOT_ClaimLineItem__c> cliList = HOT_ClaimLineItemController.checkForOverlapClaimLineItem(claim.Id);
        Test.stopTest();
        for (HOT_ClaimLineItem__c claimlineitem : cliList) {
            if (claimlineitem.Id == cli.Id) {
                Boolean containOverlapId = false;
                containOverlapId = claimlineitem.OverlappingClaimLineItemsIds__c.contains(cli2.Id);
                System.assertEquals(true, containOverlapId);
            }
        }
    }
}
