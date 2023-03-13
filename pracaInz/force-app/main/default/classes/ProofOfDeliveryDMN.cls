public with sharing class ProofOfDeliveryDMN {
    @TestVisible
    private static final String ERROR_MSG_1 = 'Delivered Quantity is more than quantity on related Delivery Shipment!';
    @TestVisible
    private static final String ERROR_MSG_2 = 'Pallet Pallet Ammount is more than Pallet Ammount on related Delivery Shipment!';
    @TestVisible
    private static final String ERROR_MSG_3 = 'Shipment status related to Delivery Shipment is not "delivered"';
    private static final String DELIVERED_STATUS = 'Delivered';

    public static void validateQuantities(List<Proof_of_Delivery__c> inputList) {
        Set<Id> deliveryShipmentIdSet = new Set<Id>();
        
        for (Proof_of_Delivery__c thisProof : inputList) {
            deliveryShipmentIdSet.add(thisProof.Delivery_Shipment__c);
        }

        Map<Id, Delivery_Shipment__c> dsMap = new Map<Id, Delivery_Shipment__c>(
            [SELECT Pallet_amount__c, Quantity__c FROM Delivery_Shipment__c WHERE Id in: deliveryShipmentIdSet]);

        for (Proof_of_Delivery__c thisProof : inputList) {
            if (thisProof.Delivered_quantity__c > dsMap.get(thisProof.Delivery_Shipment__c).Quantity__c) {
                thisProof.Delivered_quantity__c.addError(ERROR_MSG_1);
            }
            if (thisProof.Pallet_Delivered_Amount__c > dsMap.get(thisProof.Delivery_Shipment__c).Pallet_amount__c) {
                thisProof.Pallet_Delivered_Amount__c.addError(ERROR_MSG_2);
            }
        }
    }

    public static void validateShipmentStatus(List<Proof_of_Delivery__c> inputList) {
        Set<Id> deliveryShipmentIdSet = new Set<Id>();
        
        for (Proof_of_Delivery__c thisProof : inputList) {
            deliveryShipmentIdSet.add(thisProof.Delivery_Shipment__c);
        }

        Map<Id, Delivery_Shipment__c> dsMap = new Map<Id, Delivery_Shipment__c>(
            [SELECT Id, Shipment__r.Status__c FROM Delivery_Shipment__c]);
        
        for (Proof_of_Delivery__c thisProof : inputList) {
            if (dsMap.get(thisProof.Delivery_Shipment__c).Shipment__r.Status__c != DELIVERED_STATUS) {
                thisProof.Delivery_Shipment__c.addError(ERROR_MSG_3);
            }
        }
    }
}