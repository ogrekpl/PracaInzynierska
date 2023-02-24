public with sharing class DeliveryShipmentDMN {

    public static void createName(List<Delivery_Shipment__c> dsList) {
        Set<Id> deliveryOrderIdsSet = new Set<Id>();
        Set<Id> shipmentIdsSet = new Set<Id>();

        for (Delivery_Shipment__c thisDS : dsList) {
            deliveryOrderIdsSet.add(thisDS.Delivery_Order__c);
            shipmentIdsSet.add(thisDS.Shipment__c);
        }

        Map<Id, Shipment__c> shipmentsMap = new Map<Id, Shipment__c>([SELECT Name FROM Shipment__c WHERE Id in: shipmentIdsSet]);
        Map<Id, Delivery_Order__c> deliveryOrdersMap = new Map<Id, Delivery_Order__c>([SELECT Name FROM Delivery_Order__c WHERE Id in: deliveryOrderIdsSet]);

        for (Delivery_Shipment__c thisDS : dsList) {
            thisDS.Name = deliveryOrdersMap.get(thisDS.Delivery_Order__c).Name + '-' + shipmentsMap.get(thisDS.Shipment__c).Name;
        }
    }
}