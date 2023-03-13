trigger ProofOfDeliveryTrigger on Proof_of_Delivery__c (before insert, before update) {
    new ProofOfDeliveryTRH().run();
}