public with sharing class DeliveryStopsListController {
    @AuraEnabled(cacheable=true)
    public static List<Delivery_Stop__c> getDeliveryStopIdsList(Id deliveryOrderId) {
        return [SELECT Id FROM Delivery_Stop__c WHERE Delivery_Order__c =: deliveryOrderId WITH SECURITY_ENFORCED];
    }
}