trigger HOT_EntitlementTrigger on HOT_Entitlement__c(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    MyTriggers.run();
}
