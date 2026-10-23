@IsTest
private class HOT_SMSServiceTest {
    @TestSetup
    static void setup() {
        Person__c claimantPerson = HOT_LesehjelpTestDataFactory.createPerson('12015678901');
        claimantPerson.INT_KrrMobilePhone__c = '12345678';
        Person__c userPerson = HOT_LesehjelpTestDataFactory.createPerson('12015678902');
        userPerson.INT_KrrMobilePhone__c = '87654321';
        Person__c claimantWithoutPhone = HOT_LesehjelpTestDataFactory.createPerson('12015678903');
        insert new List<Person__c>{ claimantPerson, userPerson, claimantWithoutPhone };

        Account claimant = new Account(Name = 'SMS claimant', CRM_Person__c = claimantPerson.Id);
        Account claimUser = new Account(Name = 'SMS user', CRM_Person__c = userPerson.Id);
        Account claimantNoPhone = new Account(
            Name = 'SMS claimant without phone',
            CRM_Person__c = claimantWithoutPhone.Id
        );
        insert new List<Account>{ claimant, claimUser, claimantNoPhone };

        List<HOT_Claim__c> claims = new List<HOT_Claim__c>{
            HOT_LesehjelpTestDataFactory.createClaim(claimUser, claimant),
            HOT_LesehjelpTestDataFactory.createClaim(claimUser, claimant),
            HOT_LesehjelpTestDataFactory.createClaim(claimUser, claimantNoPhone)
        };
        for (HOT_Claim__c claim : claims) {
            claim.Status__c = 'Sent';
        }
        insert claims;
    }

    @IsTest
    static void changesRequestedCreatesSmsForClaimant() {
        HOT_Claim__c claim = [
            SELECT Id, Claimant__c, Account__c
            FROM HOT_Claim__c
            WHERE Claimant__r.Name = 'SMS claimant'
            LIMIT 1
        ];

        Test.startTest();
        HOT_SMSService.notifyUserOnChangesRequestedClaim(new List<HOT_Claim__c>{ claim });
        Test.stopTest();

        List<SMS__c> messages = [
            SELECT Domain__c, Type__c, Account__c, Recipient__c, Message__c
            FROM SMS__c
            WHERE Type__c = 'Claim Changes Requested'
        ];
        System.assertEquals(1, messages.size(), 'One SMS should be created for the claim.');
        System.assertEquals('HOT', messages[0].Domain__c, 'The SMS should belong to the HOT domain.');
        System.assertEquals(
            'Claim Changes Requested',
            messages[0].Type__c,
            'The SMS should have the changes requested type.'
        );
        System.assertEquals(
            claim.Claimant__c,
            messages[0].Account__c,
            'The recipient should be the claimant, not the user.'
        );
        System.assertEquals('12345678', messages[0].Recipient__c, 'The claimant KRR phone number should be used.');
        System.assertEquals(
            'Et krav du har sendt inn etter å ha vært lesehjelper har fått en kommentar fra saksbehandler.' +
                '\n\nFor mer informasjon, se lesehjelp.nav.no. ' +
                'Du kan ikke svare på denne meldingen. ' +
                '\nMvh Nav',
            messages[0].Message__c,
            'The SMS should contain the expected notification text.'
        );
    }

    @IsTest
    static void changesRequestedSkipsClaimantWithoutPhone() {
        List<HOT_Claim__c> claims = [
            SELECT Id
            FROM HOT_Claim__c
            WHERE Claimant__r.Name = 'SMS claimant without phone'
        ];

        Test.startTest();
        HOT_SMSService.notifyUserOnChangesRequestedClaim(claims);
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM SMS__c],
            'No SMS should be created without a claimant phone number.'
        );
    }

    @IsTest
    static void changesRequestedHandlesEmptyList() {
        Test.startTest();
        HOT_SMSService.notifyUserOnChangesRequestedClaim(new List<HOT_Claim__c>());
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM SMS__c], 'An empty claim list should not create any SMS.');
    }

    @IsTest
    static void changesRequestedHandlesMultipleClaims() {
        List<HOT_Claim__c> claims = [SELECT Id FROM HOT_Claim__c];

        Test.startTest();
        HOT_SMSService.notifyUserOnChangesRequestedClaim(claims);
        Test.stopTest();

        List<SMS__c> messages = [
            SELECT Account__c, Recipient__c
            FROM SMS__c
            WHERE Type__c = 'Claim Changes Requested'
        ];
        Account claimant = [SELECT Id FROM Account WHERE Name = 'SMS claimant'];
        System.assertEquals(2, messages.size(), 'Each claim with a claimant phone number should create an SMS.');
        for (SMS__c message : messages) {
            System.assertEquals(claimant.Id, message.Account__c, 'Only the claimant with a phone should be notified.');
            System.assertEquals('12345678', message.Recipient__c, 'Each SMS should use the claimant KRR phone number.');
        }
    }

    @IsTest
    static void statusChangeNotifiesClaimants() {
        List<HOT_Claim__c> claims = [SELECT Id, Status__c FROM HOT_Claim__c];
        for (HOT_Claim__c claim : claims) {
            claim.Status__c = 'Changes Requested';
        }

        Test.startTest();
        update claims;
        Test.stopTest();

        System.assertEquals(
            2,
            [SELECT COUNT() FROM SMS__c WHERE Type__c = 'Claim Changes Requested'],
            'Changing status should notify claimants with a phone number.'
        );
    }

    @IsTest
    static void unchangedStatusDoesNotSendDuplicateSms() {
        HOT_Claim__c claim = [
            SELECT Id, Status__c, CommentFromNAV__c
            FROM HOT_Claim__c
            WHERE Claimant__r.Name = 'SMS claimant'
            LIMIT 1
        ];
        claim.Status__c = 'Changes Requested';
        update claim;
        System.assertEquals(
            1,
            [SELECT COUNT() FROM SMS__c WHERE Type__c = 'Claim Changes Requested'],
            'Entering changes requested should create one SMS.'
        );

        Test.startTest();
        claim.CommentFromNAV__c = 'Updated comment';
        update claim;
        Test.stopTest();

        System.assertEquals(
            1,
            [SELECT COUNT() FROM SMS__c WHERE Type__c = 'Claim Changes Requested'],
            'Updating a comment without changing status should not send another SMS.'
        );
    }

    @IsTest
    static void otherStatusDoesNotSendChangesRequestedSms() {
        HOT_Claim__c claim = [
            SELECT Id, Status__c
            FROM HOT_Claim__c
            WHERE Claimant__r.Name = 'SMS claimant'
            LIMIT 1
        ];

        Test.startTest();
        claim.Status__c = 'Approved by user';
        update claim;
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM SMS__c WHERE Type__c = 'Claim Changes Requested'],
            'Changing to another status should not send a changes requested SMS.'
        );
    }
}
