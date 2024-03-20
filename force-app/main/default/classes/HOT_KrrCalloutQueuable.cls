public without sharing class HOT_KrrCalloutQueuable implements Queueable, Database.AllowsCallouts {
    private List<Account> accounts;
    private class KRRException extends Exception {
    }

    public HOT_KrrCalloutQueuable(List<Account> accounts) {
        this.accounts = [
            SELECT Id, CRM_Person__c, CRM_Person__r.Name
            FROM Account
            WHERE Id IN :accounts
        ];
    }

    public void execute(QueueableContext context) {
        Map<String, Id> personIdByPersonalNumber = new Map<String, Id>();
        Map<Id, Person__c> personByPersonId = new Map<Id, Person__c>();
        CRM_DatabaseOperations cdo = new CRM_DatabaseOperations();
        cdo.setDomain(CRM_ApplicationDomain.Domain.HOT);
        for (Account account : accounts) {
            personIdByPersonalNumber.put(String.valueOf(account.CRM_Person__r.Name), account.CRM_Person__c);
            personByPersonId.put(account.CRM_Person__c, account.CRM_Person__r);
        }

        try {
            if (personIdByPersonalNumber.size() == 0) {
                throw new KRRException('(HOT) personIdByPersonalNumber was empty.');
            }
            Map<String, KRRCalloutService.Person> krrResponseByPersonalNumber = new Map<String, KRRCalloutService.Person>();
            List<String> personNumbers = new List<String>(personIdByPersonalNumber.keySet());
            List<KRRCalloutService.Person> personResponse = KrrCalloutService.doPersonOppslag2(
                personNumbers,
                null,
                true
            );

            // KrrCalloutService.doPersonOppslag() fails in 25% of cases. We are rerunning the Callout, to see if there are some irregularities with the integration
            if (personResponse == null) {
                throw new KRRException('(HOT) KrrCalloutService.doPersonOppslag return null.');
            }

            for (KRRCalloutService.Person person : personResponse) {
                krrResponseByPersonalNumber.put(person.personident, person);
            }
            List<Person__c> personsToUpdate = new List<Person__c>();
            for (String personalNumber : personIdByPersonalNumber.keySet()) {
                KRRCalloutService.Person p = krrResponseByPersonalNumber.get(personalNumber);
                if (p != null) {
                    // Initialize related Person record and set audit fields
                    Person__c person = new Person__c();
                    person.Id = personIdByPersonalNumber.get(personalNumber);
                    person.INT_LastUpdatedFromKRR__c = System.now();
                    person.INT_KrrIntegrationStatus__c = 'Completed';

                    // Map contact information fields if they were returned by krr

                    if (p.epostadresse != null)
                        person.INT_KrrEmail__c = p.epostadresse;
                    if (p.mobiltelefonnummer != null)
                        person.INT_KrrMobilePhone__c = p.mobiltelefonnummer;
                    personsToUpdate.add(person);
                }
            }
            cdo.updateRecords(personsToUpdate);
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, accounts[0], CRM_ApplicationDomain.Domain.HOT);
            logger.publish();

            List<Person__c> personsToUpdate = new List<Person__c>();
            for (Id personId : personIdByPersonalNumber.values()) {
                Person__c person = new Person__c();
                person.Id = personId;
                person.INT_LastUpdatedFromKRR__c = System.now();
                person.INT_KrrIntegrationStatus__c = 'Failed';
                personsToUpdate.add(person);
            }
            cdo.updateRecords(personsToUpdate);
        }
    }
}
