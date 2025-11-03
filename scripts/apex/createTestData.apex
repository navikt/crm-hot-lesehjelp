Date validFrom = Date.newInstance(2025, 5, 1);
Date validTo = Date.newInstance(2025, 4, 30);

Account account1 = new Account();
account1.name = 'Jedi Order';
account1.INT_OrganizationNumber__c = '101010101';
insert account1;

Account account2 = new Account();
account2.name = 'The Empire';
account2.INT_OrganizationNumber__c = '202020202';
insert account2;

Account account3 = new Account();
account3.name = 'The Trade Federation';
account3.INT_OrganizationNumber__c = '303030303';
insert account3;

Account account4 = new Account();
account4.name = 'The Rebels';
account4.INT_OrganizationNumber__c = '404040404';
insert account4;

Account personAccount1 = new Account();
personAccount1.FirstName = 'JarJar';
personAccount1.LastName = 'Binks';
personAccount1.INT_PersonIdent__c = '01010101010';
personAccount1.INT_KrrMobilePhone__c = '00807060';
insert personAccount1;

Account personAccount2 = new Account();
personAccount2.FirstName = 'Darth';
personAccount2.LastName = 'Vader';
personAccount2.INT_PersonIdent__c = '02020202020';
personAccount2.INT_KrrMobilePhone__c = '00203040';
insert personAccount2;

Account personAccount3 = new Account();
personAccount3.FirstName = 'Luke';
personAccount3.LastName = 'Skywalker';
personAccount3.INT_PersonIdent__c = '03030303030';
personAccount3.INT_KrrMobilePhone__c = '87654321';
insert personAccount3;

Account personAccount4 = new Account();
personAccount4.FirstName = 'Han';
personAccount4.LastName = 'Solo';
personAccount4.INT_PersonIdent__c = '04040404040';
personAccount4.INT_KrrMobilePhone__c = '12345678';
insert personAccount4;

List<Account> accountClaimer = [SELECT Id FROM Account WHERE Name = 'Darth Vader'];
List<Account> accountUser = [SELECT Id FROM Account WHERE Name = 'Luke Skywalker'];

List<Account> allAccounts = [SELECT Name, LastName, FirstName, INT_PersonIdent__c FROM Account WHERE INT_PersonIdent__c != '' LIMIT 10];

Map<String, Account> accountByLastName = new Map<String, Account>();
for (Account acc : allAccounts) {
    accountByLastName.put(acc.LastName, acc);
}

Person__c person1 = new Person__c();
person1.Name = allAccounts[0].INT_PersonIdent__c;
person1.INT_Confidential__c = 'UGRADERT';
person1.INT_KrrEmail__c = 'fakeemail@navtest11.no';
person1.INT_BankAccountNumber__c = '10102040100';
person1.INT_ResidentialAddress__c = 'stedveien 12';
person1.INT_ResidentialZipCode__c = '0101';
//person1.INT_ResidentialPlace__c = 'Oslo';
person1.INT_KrrMobilePhone__c = '09010202';
person1.INT_LastUpdatedFromKRR__c = Datetime.now();
person1.INT_KrrIntegrationStatus__c = 'Completed';
person1.INT_LastName__c = allAccounts[0].LastName;
person1.INT_FirstName__c = allAccounts[0].FirstName;
insert person1;

Person__c person2 = new Person__c();
person2.Name = allAccounts[1].INT_PersonIdent__c;
person2.INT_Confidential__c = 'UGRADERT';
person2.INT_KrrEmail__c = 'fakeemail@navtest11.no';
person2.INT_BankAccountNumber__c = '10102040100';
person2.INT_ResidentialAddress__c = 'stedveien 12';
person2.INT_ResidentialZipCode__c = '0101';
//person2.INT_ResidentialPlace__c = 'Oslo';
person2.INT_KrrMobilePhone__c = '09010202';
person2.INT_LastUpdatedFromKRR__c = Datetime.now();
person2.INT_KrrIntegrationStatus__c = 'Completed';
person2.INT_LastName__c = allAccounts[1].LastName;
person2.INT_FirstName__c = allAccounts[1].FirstName;
insert person2;

Person__c person3 = new Person__c();
person3.Name = allAccounts[2].INT_PersonIdent__c;
person3.INT_Confidential__c = 'UGRADERT';
person3.INT_KrrEmail__c = 'fakeemail@navtest11.no';
person3.INT_BankAccountNumber__c = '10102040100';
person3.INT_ResidentialAddress__c = 'stedveien 12';
person3.INT_ResidentialZipCode__c = '0101';
//person3.INT_ResidentialPlace__c = 'Oslo';
person3.INT_KrrMobilePhone__c = '09010202';
person3.INT_LastUpdatedFromKRR__c = Datetime.now();
person3.INT_KrrIntegrationStatus__c = 'Completed';
person3.INT_LastName__c = allAccounts[2].LastName;
person3.INT_FirstName__c = allAccounts[2].FirstName;
person3.HOT_isLOS__c = true;
insert person3;

Person__c person4 = new Person__c();
person4.Name = allAccounts[3].INT_PersonIdent__c;
person4.INT_Confidential__c = 'UGRADERT';
person4.INT_KrrEmail__c = 'fakeemail@navtest11.no';
person4.INT_BankAccountNumber__c = '10102040100';
person4.INT_ResidentialAddress__c = 'stedveien 12';
person4.INT_ResidentialZipCode__c = '0101';
//person4.INT_ResidentialPlace__c = 'Oslo';
person4.INT_KrrMobilePhone__c = '09010202';
person4.INT_LastUpdatedFromKRR__c = Datetime.now();
person4.INT_KrrIntegrationStatus__c = 'Completed';
person4.INT_LastName__c = allAccounts[3].LastName;
person4.INT_FirstName__c = allAccounts[3].FirstName;
person4.HOT_isLOS__c = true;
insert person4;


// Thou shall haveth entitlements
List<HOT_Entitlement__c> entitlements = new List<HOT_Entitlement__c>{
    new HOT_Entitlement__c(Account__c = accountByLastName.get('Skywalker').Id, Type__c = 'Dagligliv', EntitledHours__c = 120, FromDate__c = Date.today(), ToDate__c = Date.today().addMonths(5)),
    new HOT_Entitlement__c(Account__c = accountByLastName.get('Vader').Id, Type__c = 'Dagligliv', EntitledHours__c = 120, FromDate__c = Date.today(), ToDate__c = Date.today().addMonths(5))
};
insert entitlements;

// Rates for the people
List<HOT_Rate__c> oldRates = new List<HOT_Rate__c>{
    new HOT_Rate__c(Name = 'Dagsats - IKKE AKTIV', Type__c = 'Dag', Rate__c = 200.50 * 0.9,
        ValidFrom__c = validFrom.addYears(-1), ValidTo__c = validTo, isActive__c = false),
    new HOT_Rate__c(Name = 'Kveld/helgesats - IKKE AKTIV', Type__c = 'Kveld/helg', Rate__c = 450.50 * 0.9,
        ValidFrom__c = validFrom.addYears(-1), ValidTo__c = validTo, isActive__c = false),
    new HOT_Rate__c(Name = 'Reisetid - IKKE AKTIV', Type__c = 'Reisetid', Rate__c = 50.70 * 0.9,
        ValidFrom__c = validFrom.addYears(-1), ValidTo__c = validTo, isActive__c = false),
    new HOT_Rate__c(Name = 'Kjøregodtgjørelse - IKKE AKTIV', Type__c = 'Kjøregodtgjørelse', Rate__c = 5.00 * 0.9,
        ValidFrom__c = validFrom.addYears(-1), ValidTo__c = validTo, isActive__c = false)
        };

List<HOT_Rate__c> activeRates = new List<HOT_Rate__c>{
    new HOT_Rate__c(Name = 'Dagsats', Type__c = 'Dag', Rate__c = 200.50, ValidFrom__c = validFrom, isActive__c = true),
    new HOT_Rate__c(Name = 'Kveld/helgesats', Type__c = 'Kveld/helg', Rate__c = 450.50, ValidFrom__c = validFrom, isActive__c = true),
    new HOT_Rate__c(Name = 'Reisetid', Type__c = 'Reisetid', Rate__c = 50.70, ValidFrom__c = validFrom, isActive__c = true),
    new HOT_Rate__c(Name = 'Kjøregodtgjørelse', Type__c = 'Kjøregodtgjørelse', Rate__c = 5.00, ValidFrom__c = validFrom, isActive__c = true)
        };

insert oldRates;
insert activeRates;

// Now we needeth thau claimeths
List<HOT_Claim__c> claims = new List<HOT_Claim__c>{
    new HOT_Claim__c(Claimant__c = accountByLastName.get('Solo').Id, Account__c = accountByLastName.get('Skywalker').Id, Entitlement__c = entitlements[0].Id, Type__c = 'Dagligliv', ApprovedByUser__c = true, ApprovedByNAV__c = true, Status__c = 'Approved by NAV'),
    new HOT_Claim__c(Claimant__c = accountByLastName.get('Binks').Id, Account__c = accountByLastName.get('Vader').Id, Entitlement__c= entitlements[1].Id, Type__c = 'Dagligliv', ApprovedByUser__c = true, ApprovedByNAV__c = true, Status__c = 'Approved by NAV')
        };
insert claims;

for(HOT_Claim__c claim : claims) {
    HOT_ClaimLineItem__c cli = new HOT_ClaimLineItem__c(
    Claim__c = claim.Id,
    StartTime__c = Datetime.now(),
    EndTime__c = Datetime.now().addHours(1),
    TravelToStartTime__c = Datetime.now().addHours(-1),
    TravelToEndTime__c= Datetime.now(),
    TravelFromStartTime__c = Datetime.now().addHours(1),
    TravelFromEndTime__c = Datetime.now().addHours(2),
    HasTravelTo__c = true,
    HasTravelFrom__c = true,
    TravelDistance__c = 10
    );
insert cli;
}

//Merge Person__c and Account. Same fix as found in crm-nks-base/dummy-data
Map<String,List<Account>> accMap = new Map<String,List<Account>>();
for(Account acc : [SELECT Id, INT_PersonIdent__c, CRM_Person__r.CRM_Account__c FROM Account]) {
    if(String.isBlank(acc.INT_PersonIdent__c)) {
        continue;
    }

    if(accMap.containsKey(acc.INT_PersonIdent__c) == false) {
        accMap.put(acc.INT_PersonIdent__c, new List<Account>());
    }

    accMap.get(acc.INT_PersonIdent__c).add(acc);
}

for(String ident : accMap.keySet()) {
    if(accMap.get(ident).size() > 1) {
        Account master;
        List<Account> duplicates = new List<Account>();
        for(Account acc : accMap.get(ident)) {
            if(acc.CRM_Person__r.CRM_Account__c == null) {
                duplicates.add(new Account(Id = acc.Id));
            } else {
                master = new Account(Id = acc.Id);
            }
        }

        Database.merge(master, duplicates);
    }
}