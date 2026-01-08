@IsTest
public class HOT_LesehjelpTestDataFactory {
    public static HOT_Claim__c createClaim(Account account, Account claimaint) {
        HOT_Claim__c claim = new HOT_Claim__c();
        claim.Account__c = account.Id;
        claim.Claimant__c = claimaint.Id;
        claim.Type__c = 'Arbeidsliv';
        return claim;
    }
    public static HOT_ClaimLineItem__c createClaimLineItems(HOT_Claim__c claim) {
        HOT_ClaimLineItem__c cli = new HOT_ClaimLineItem__c();
        cli.Claim__c = claim.Id;
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
    public static HOT_Entitlement__c createEntitlement(Account account) {
        HOT_Entitlement__c entitlement = new HOT_Entitlement__c();
        entitlement.Account__c = account.Id;
        entitlement.Type__c = 'Arbeidsliv';
        entitlement.EntitledHours__c = 120;
        entitlement.FromDate__c = Date.today().addDays(-1);
        entitlement.ToDate__c = Date.today().addDays(3);
        return entitlement;
    }
    public static Account createAccount(boolean isPersonAccount) {
        String personAccountRecordTypeId = Schema.getGlobalDescribe()
            .get('Account')
            .getDescribe()
            .getRecordTypeInfosByDeveloperName()
            .get('PersonAccount')
            .getRecordTypeId();
        Account account = new Account(
            RecordTypeId = personAccountRecordTypeId,
            FirstName = 'Test',
            LastName = 'User',
            PersonEmail = 'HOT_testaccount@nav.hot.no'
        );
        return account;
    }
    public static Person__c createPerson() {
        return createPerson('12015678901');
    }
    public static Person__c createPerson(String ident) {
        Person__c person = new Person__c();
        person.INT_Confidential__c = 'UGRADERT';
        person.INT_MunicipalityNumber__c = '4601';
        person.Name = ident;
        person.INT_LastName__c = 'Last';
        person.INT_FirstName__c = 'First';

        return person;
    }
    public static User createUser(Profile profile, Account account) {
        User user = createUser('User', profile);
        user.ContactId = account.PersonContactId;
        return user;
    }
    public static User createUser(String lastName, Profile profile) {
        User user = new User(
            Username = 'HOT.' + lastName + '@nav.hot.no',
            LastName = lastName,
            Email = 'HOT_testuser@nav.hot.no',
            Alias = lastName,
            CommunityNickname = lastName,
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'no_NO',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'no',
            ProfileId = profile.id
        );

        return user;
    }
}
