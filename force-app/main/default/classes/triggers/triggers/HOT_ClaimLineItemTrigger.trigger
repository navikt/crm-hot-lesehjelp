trigger HOT_ClaimLineItemTrigger on HOT_ClaimLineItem__c(
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
