trigger DeliveryStopTrigger on Delivery_Stop__c (before insert) {
    new DeliveryStopTRH().run();
}