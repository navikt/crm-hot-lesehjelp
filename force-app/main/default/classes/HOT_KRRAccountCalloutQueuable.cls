public without sharing class HOT_KRRAccountCalloutQueuable implements Queueable, Database.AllowsCallouts {
    private List<Account> accounts;
    private class KRRException extends Exception {
    }

    public HOT_KRRAccountCalloutQueuable(Set<Id> accounts) {
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
            if (personIdByPersonalNumber.isEmpty()) {
                throw new KRRException('(HOT) personIdByPersonalNumber was empty.');
            }

            List<String> personNumbers = new List<String>(personIdByPersonalNumber.keySet());

            KrrCalloutService krrService = new KrrCalloutService();
            KrrCalloutService.KrrResponse response = krrService.getPersons(personNumbers, true);

            // Line #34 might be irrelevant after we switced to getPersons.
            // KrrCalloutService.doPersonOppslag() fails in 25% of cases. We are rerunning the Callout, to see if there are some irregularities with the integration
            if (response == null || response.personer == null) {
                throw new KRRException('(HOT) KrrCalloutService.getPersons returned null or empty.');
            }

            Map<String, KrrCalloutService.Person> krrResponseByPersonalNumber = response.personer;

            List<Person__c> personsToUpdate = new List<Person__c>();
            for (String personalNumber : personIdByPersonalNumber.keySet()) {
                KrrCalloutService.Person p = krrResponseByPersonalNumber.get(personalNumber);
                if (p != null) {
                    Person__c person = new Person__c();
                    person.Id = personIdByPersonalNumber.get(personalNumber);
                    person.INT_LastUpdatedFromKRR__c = System.now();
                    person.INT_KrrIntegrationStatus__c = 'Completed';
                    person.HOT_KrrIntegrationErrorCounter__c = 0;

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
            if (!accounts.isEmpty()) {
                logger.exception(e, accounts[0], CRM_ApplicationDomain.Domain.HOT);
            } else {
                logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
            }
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
