public with sharing class ShipmentTRH extends TriggerHandler{
    public override void afterInsert() {
        Set<Id> shipmentIdSet = new Set<Id>();

        for (Shipment__c thisShipment : (List<Shipment__c>)Trigger.new) {
            shipmentIdSet.add(thisShipment.Id);
        }

        Map<Id, Shipment__c> shipmentMap = new Map<Id, Shipment__c>(
            [SELECT Id, Destination_Warehouse__r.geoLocation__c, Loading_Warehouse__r.geoLocation__c 
            FROM Shipment__c WHERE Id in: shipmentIdSet]);

        for (Id shipmentId : shipmentMap.keySet()) {
            if (shipmentMap.get(shipmentId).Destination_Warehouse__r.geoLocation__c != null && shipmentMap.get(shipmentId).Loading_Warehouse__r.geoLocation__c != null) {
                TomTomCalloutHandler.getRouteDetails(shipmentId);
            }
        }
    }
}