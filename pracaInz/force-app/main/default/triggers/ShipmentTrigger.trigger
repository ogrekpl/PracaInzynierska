trigger ShipmentTrigger on Shipment__c (after insert, after update) {
    new ShipmentTRH().run();
}