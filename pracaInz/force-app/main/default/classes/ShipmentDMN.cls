public with sharing class ShipmentDMN {
    @TestVisible
    private static final String ERROR_MSG = 'The driver is from blacklisted company.';
    private static final String BLACKLISTED = 'Blacklisted';

    public static void validateRelationWithDriver(Map<Id, Shipment__c> shipmentMap) {
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> driversIdSet = new Set<Id>();
        Map<String, Id> customerSupplierIdToShipmentIdMap = new Map<String, Id>();

        for (Shipment__c thisShipment : shipmentMap.values()) {
            driversIdSet.add(thisShipment.Driver__c);
        }

        Map<Id, Contact> driverAccountMap = new Map<Id, Contact>([SELECT AccountId FROM Contact WHERE Id in: driversIdSet]);

        Map<Id, Delivery_Shipment__c> dsMap = new Map<Id, Delivery_Shipment__c>(
            [SELECT Delivery_Order__r.Contract__r.AccountId, Shipment__c FROM Delivery_Shipment__c WHERE Shipment__c in: shipmentMap.keySet()]);

        for (Delivery_Shipment__c thisDS : dsMap.values()) {
            String key = thisDS.Delivery_Order__r.Contract__r.AccountId + '_' + driverAccountMap.get(shipmentMap.get(thisDS.Shipment__c).Driver__c).AccountId;
            customerSupplierIdToShipmentIdMap.put(key, thisDS.Shipment__c);
        }
            
        for (Delivery_Shipment__c thisDs : dsMap.values()) {
            accountIdSet.add(thisDs.Delivery_Order__r.Contract__r.AccountId);
        }

        List<Account_Relationship__c> arList = 
            [SELECT Customer__c, Supplier__c FROM Account_Relationship__c WHERE Customer__c in: accountIdSet AND Customer_Relationship__c =: BLACKLISTED];

        if (arList.size() > 0) {
            for (Account_Relationship__c thisAR : arList) {
                String key = thisAR.Customer__c + '_' + thisAR.Supplier__c;
                if (customerSupplierIdToShipmentIdMap.containsKey(key)) {
                    shipmentMap.get(customerSupplierIdToShipmentIdMap.get(key)).addError(ERROR_MSG);
                } 
            }
        }
    }
}