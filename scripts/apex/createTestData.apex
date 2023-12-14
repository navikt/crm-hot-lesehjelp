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

HOT_Entitlement__c entitlement1 = new HOT_Entitlement__c();
entitlement1.Name = 'Lesehjelp på Arbeidsplass';
entitlement1.Type__c = 'Arbeidsliv';
entitlement1.EntitledHours__c = 120.00;
entitlement1.FromDate__c = Date.today();
entitlement1.ToDate__c = Date.today().addYears(1);
insert entitlement1;

HOT_Entitlement__c entitlement2 = new HOT_Entitlement__c();
entitlement2.Name = 'Arkivering på jobb';
entitlement2.Type__c = 'Arbeidsliv';
entitlement2.EntitledHours__c = 120.00;
entitlement2.FromDate__c = Date.today();
entitlement2.ToDate__c = Date.today().addYears(1);
insert entitlement2;

HOT_Claim__c claim1 = new HOT_Claim__c();
List<Account> accountClaimer = [SELECT Id FROM Account WHERE Name = 'Darth Vader'];
claim1.Claimant__c = accountClaimer[0].Id;
List<Account> accountUser = [SELECT Id FROM Account WHERE Name = 'Luke Skywalker'];
claim1.Account__c = accountUser[0].Id;
claim1.Type__c = 'Utdanning, opplæring eller arbeidstrening';
claim1.TotalHoursOrgPolSoc__c = 12.00;
insert claim1;

HOT_Claim__c claim2 = new HOT_Claim__c();
claim2.Claimant__c = accountClaimer[0].Id;
claim2.Account__c = accountUser[0].Id;
claim2.Type__c = 'Utdanning, opplæring eller arbeidstrening';
claim2.TotalHoursOrgPolSoc__c = 12.00;
insert claim2;