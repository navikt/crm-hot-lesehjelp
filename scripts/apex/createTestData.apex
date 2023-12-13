Account account1 = new Account();
account1.name = 'Jedi Order';
insert account1;

Account account2 = new Account();
account2.name = 'The Empire';
insert account2;

Account account3 = new Account();
account3.name = 'The Trade Federation';
insert account3;

Account account4 = new Account();
account4.name = 'The Rebels';
insert account4;

Account personAccount1 = new Account();
personAccount1.FirstName = 'JarJar';
personAccount1.LastName = 'Binks';
insert personAccount1;

Account personAccount2 = new Account();
personAccount2.FirstName = 'Darth';
personAccount2.LastName = 'Vader';
insert personAccount2;

Account personAccount3 = new Account();
personAccount3.FirstName = 'Luke';
personAccount3.LastName = 'Skywalker';
insert personAccount3;

Account personAccount4 = new Account();
personAccount4.FirstName = 'Han';
personAccount4.LastName = 'Solo';
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