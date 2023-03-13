public with sharing class ShipmentTRH extends TriggerHandler{

    public override void afterInsert() {
        Set<Id> shipmentIdSet = new Set<Id>();
        Map<Id, Shipment__c> shipmentMapToValidateDriver = new Map<Id, Shipment__c>();

        for (Shipment__c thisShipment : (List<Shipment__c>)Trigger.new) {
            if (thisShipment.Driver__c != null) {
                shipmentMapToValidateDriver.put(thisShipment.Id, thisShipment);
            }
        }

        if (shipmentMapToValidateDriver.size() > 0 ) {
            ShipmentDMN.validateRelationWithDriver(shipmentMapToValidateDriver);
        }

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

    public override void afterUpdate() {
        Map<Id, Shipment__c> shipmentMapToValidateDriver = new Map<Id, Shipment__c>();

        for (Shipment__c thisShipment : (List<Shipment__c>)Trigger.new) {
            if (thisShipment.Driver__c != null) {
                shipmentMapToValidateDriver.put(thisShipment.Id, thisShipment);
            }
        }

        if (shipmentMapToValidateDriver.size() > 0 ) {
            ShipmentDMN.validateRelationWithDriver(shipmentMapToValidateDriver);
        }
    }
}