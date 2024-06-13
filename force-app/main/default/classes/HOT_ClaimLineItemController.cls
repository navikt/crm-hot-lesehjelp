public without sharing class HOT_ClaimLineItemController {
    @AuraEnabled(cacheable=false)
    public static List<HOT_ClaimLineItem__c> getClaimLineItems(String recordId) {
        List<HOT_ClaimLineItem__c> claimLineItems = [
            SELECT
                Id,
                Name,
                Date__c,
                StartTime__c,
                EndTime__c,
                HasTravelTo__c,
                HasTravelFrom__c,
                NumberOfHours__c,
                TravelFromEndTime__c,
                TravelFromStartTime__c,
                TravelTo__c,
                TravelToEndTime__c,
                TravelToStartTime__c,
                TypeOfTask__c,
                Weekday__c,
                AdditionalInformation__c,
                TravelDistance__c,
                ExpensesParking__c,
                ExpensesPublicTransport__c,
                ExpensesToll__c,
                PublicTransportRoute__c,
                ParkingAddress__c,
                TravelToFromAddresses__c,
                OverlappingClaimLineItemsIds__c
            FROM HOT_ClaimLineItem__c
            WHERE Claim__c = :recordId
            ORDER BY Date__c ASC
        ];
        return claimLineItems;
    }
    @AuraEnabled(cacheable=false)
    public static List<HOT_ClaimLineItem__c> checkForOverlapClaimLineItem(String recordId) {
        HOT_Claim__c claim = [
            SELECT Id, Claimant__c
            FROM HOT_Claim__c
            WHERE Id = :recordId
        ];
        List<HOT_ClaimLineItem__c> claimLineItemsToReturn = [
            SELECT
                Id,
                Name,
                Date__c,
                StartTime__c,
                EndTime__c,
                HasTravelTo__c,
                HasTravelFrom__c,
                NumberOfHours__c,
                TravelFromEndTime__c,
                TravelFromStartTime__c,
                TravelTo__c,
                TravelToEndTime__c,
                TravelToStartTime__c,
                TypeOfTask__c,
                Weekday__c,
                AdditionalInformation__c,
                TravelDistance__c,
                ExpensesParking__c,
                ExpensesPublicTransport__c,
                ExpensesToll__c,
                PublicTransportRoute__c,
                ParkingAddress__c,
                TravelToFromAddresses__c,
                OverlappingClaimLineItemsIds__c
            FROM HOT_ClaimLineItem__c
            WHERE Claim__c = :claim.Id
        ];

        List<HOT_ClaimLineItem__c> claimLineItemsToCheckForOverlap = [
            SELECT
                Id,
                Name,
                StartTime__c,
                EndTime__c,
                HasTravelTo__c,
                HasTravelFrom__c,
                TravelFromEndTime__c,
                TravelFromStartTime__c,
                TravelTo__c,
                TravelToEndTime__c,
                TravelToStartTime__c,
                OverlappingClaimLineItemsIds__c
            FROM HOT_ClaimLineItem__c
            WHERE Claim__r.Claimant__c = :claim.Claimant__c
        ];

        for (HOT_ClaimLineItem__c cli : claimLineItemsToReturn) {
            for (HOT_ClaimLineItem__c cli2 : claimLineItemsToCheckForOverlap) {
                if (
                    (cli.StartTime__c < cli2.EndTime__c &&
                    cli.EndTime__c > cli2.StartTime__c &&
                    cli.Id != cli2.Id) ||
                    (cli.StartTime__c < cli2.TravelToEndTime__c &&
                    cli.EndTime__c > cli2.TravelToStartTime__c &&
                    cli2.HasTravelTo__c == true &&
                    cli.Id != cli2.Id) ||
                    cli.StartTime__c < cli2.TravelFromEndTime__c &&
                    cli.EndTime__c > cli2.TravelFromStartTime__c &&
                    cli2.HasTravelFrom__c == true && cli.Id != cli2.Id
                ) {
                    if (cli.OverlappingClaimLineItemsIds__c == null || cli.OverlappingClaimLineItemsIds__c == '') {
                        cli.OverlappingClaimLineItemsIds__c = '' + cli2.Id + ',' + cli2.Name;
                    } else if (!cli.OverlappingClaimLineItemsIds__c.contains(cli2.Id)) {
                        cli.OverlappingClaimLineItemsIds__c += ',' + cli2.Id + ',' + cli2.Name;
                    }
                }
                if (
                    (cli.TravelToStartTime__c < cli2.EndTime__c &&
                    cli.TravelToEndTime__c > cli2.StartTime__c &&
                    cli.HasTravelTo__c == true &&
                    cli.Id != cli2.Id) ||
                    (cli.TravelToStartTime__c < cli2.TravelToEndTime__c &&
                    cli.TravelToEndTime__c > cli2.TravelToStartTime__c &&
                    cli.HasTravelTo__c == true &&
                    cli2.HasTravelTo__c == true &&
                    cli.Id != cli2.Id) ||
                    (cli.TravelToStartTime__c < cli2.TravelFromEndTime__c &&
                    cli.TravelToEndTime__c > cli2.TravelFromStartTime__c &&
                    cli.HasTravelTo__c == true &&
                    cli2.HasTravelFrom__c == true &&
                    cli.Id != cli2.Id)
                ) {
                    if (cli.OverlappingClaimLineItemsIds__c == null || cli.OverlappingClaimLineItemsIds__c == '') {
                        cli.OverlappingClaimLineItemsIds__c = '' + cli2.Id + ',' + cli2.Name;
                    } else if (!cli.OverlappingClaimLineItemsIds__c.contains(cli2.Id)) {
                        cli.OverlappingClaimLineItemsIds__c += ',' + cli2.Id + ',' + cli2.Name;
                    }
                }
                if (
                    (cli.TravelFromStartTime__c < cli2.EndTime__c &&
                    cli.TravelFromEndTime__c > cli2.StartTime__c &&
                    cli.HasTravelFrom__c == true &&
                    cli.Id != cli2.Id) ||
                    (cli.TravelFromStartTime__c < cli2.TravelToEndTime__c &&
                    cli.TravelFromEndTime__c > cli2.TravelToStartTime__c &&
                    cli.HasTravelFrom__c == true &&
                    cli2.HasTravelTo__c == true &&
                    cli.Id != cli2.Id) ||
                    (cli.TravelFromStartTime__c < cli2.TravelFromEndTime__c &&
                    cli.TravelFromEndTime__c > cli2.TravelFromStartTime__c &&
                    cli.HasTravelFrom__c == true &&
                    cli2.HasTravelFrom__c == true &&
                    cli.Id != cli2.Id)
                ) {
                    if (cli.OverlappingClaimLineItemsIds__c == null || cli.OverlappingClaimLineItemsIds__c == '') {
                        cli.OverlappingClaimLineItemsIds__c = '' + cli2.Id + ',' + cli2.Name;
                    } else if (!cli.OverlappingClaimLineItemsIds__c.contains(cli2.Id)) {
                        cli.OverlappingClaimLineItemsIds__c += ',' + cli2.Id + ',' + cli2.Name;
                    }
                }
            }
        }
        return claimLineItemsToReturn;
    }
}
