public with sharing class ProofOfDeliveryTRH extends TriggerHandler {

    public override void beforeInsert() {
        ProofOfDeliveryDMN.validateShipmentStatus((List<Proof_of_Delivery__c>)Trigger.new);
        DeliveryShipmentDMN.validateMaxNumberProofOfDelivery((List<Proof_of_Delivery__c>)Trigger.new);
        ProofOfDeliveryDMN.validateQuantities((List<Proof_of_Delivery__c>)Trigger.new);
    }

    public override void beforeUpdate() {
        ProofOfDeliveryDMN.validateShipmentStatus((List<Proof_of_Delivery__c>)Trigger.new);
        ProofOfDeliveryDMN.validateQuantities((List<Proof_of_Delivery__c>)Trigger.new);
    }
}