public with sharing class DeliveryShipmentTRH extends TriggerHandler {
    
    public override void beforeInsert() {
        DeliveryShipmentDMN.createName((List<Delivery_Shipment__c>)Trigger.new);
    }

    public override void beforeUpdate() {
        verifyName((Map<Id, Delivery_Shipment__c>)Trigger.oldMap, (Map<Id, Delivery_Shipment__c>)Trigger.newMap);
    }

    private static void verifyName(Map<Id, Delivery_Shipment__c> oldDSMap, Map<Id, Delivery_Shipment__c> newDSMap) {
        List<Delivery_Shipment__c> dsListToUpdateName = new List<Delivery_Shipment__c>();

        for (Id dsId : oldDSMap.keySet()) {
            if (oldDSMap.get(dsId).Name != newDSMap.get(dsId).Name) {
                dsListToUpdateName.add(newDSMap.get(dsId));
            }
        }

        if (dsListToUpdateName.size() > 0) {
            DeliveryShipmentDMN.createName(dsListToUpdateName);
        }
    }
}