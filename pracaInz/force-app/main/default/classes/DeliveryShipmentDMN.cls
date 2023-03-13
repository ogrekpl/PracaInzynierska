public with sharing class DeliveryShipmentDMN {
    @TestVisible
    private static final String ERROR_MSG = 'Each Delivery Shipment may only has one Proof of Delivery record.';

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

    public static void validateMaxNumberProofOfDelivery(List<Proof_of_Delivery__c> inputList) {
        Set<Id> deliveryShipmentId = new Set<Id>();

        for (Proof_of_Delivery__c thisProof : inputList) {
            deliveryShipmentId.add(thisProof.Delivery_Shipment__c);
        }

        Map<Id, Delivery_Shipment__c> dsMap = new Map<Id, Delivery_Shipment__c>(
            [SELECT Id, (SELECT Id FROM Proofs_of_Delivery__r) FROM Delivery_Shipment__c]);

        for (Proof_of_Delivery__c thisProof : inputList) {
            if (dsMap.get(thisProof.Delivery_Shipment__c).Proofs_of_Delivery__r.size() > 0) {
                thisProof.Delivery_Shipment__c.addError(ERROR_MSG);
            }
        }
    }
}