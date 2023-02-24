trigger DeliveryShipmentTrigger on Delivery_Shipment__c (before insert, before update) {
    new DeliveryShipmentTRH().run();
}