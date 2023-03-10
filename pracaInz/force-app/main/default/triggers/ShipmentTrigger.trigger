trigger ShipmentTrigger on Shipment__c (after insert) {
    new ShipmentTRH().run();
}