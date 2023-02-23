trigger DeliveryStopTrigger on Delivery_Stop__c (before insert, after delete) {
    new DeliveryStopTRH().run();
}