
public with sharing class BatchSummaryController {
    private final static Set<String> TANSPORTATION_STATUSES = new Set<String> {'Waiting for loading', 'Loading', 'In transport', 'Awaiting unloading', 'Unloading'};  
    private final static String DELIVERED_STATUS = 'Delivered';
    private final static String WAREHOUSE = 'Warehouse';  
    private final static String SHIPMENT = 'Shipment';  
    private final static String SHIPMENT_STATUS = 'Shipment_Status';  
    private final static String PALLETS_AMOUNT = 'Pallets_Amount';  
    private final static String QUANTITY = 'Quantity';  
    private final static String ID = 'Id';  

    @AuraEnabled(cacheable=true)
    public static List<Object> getListToDisplay(Id deliveryOrderId) {
        List<Object> objectList = new List<Object>();
        Delivery_Order__c deliveryOrder = [SELECT Id, Pallet_amount__c, Contract__r.Opportunity__r.Quantity__c,
            (SELECT Id, Pallet_amount__c, Quantity__c, Shipment__r.Name, Shipment__r.Status__c, Shipment__r.Destination_Warehouse__r.Name, 
            Shipment__r.Loading_Warehouse__r.Name, Shipment__r.Destination_Warehouse__r.Id, Shipment__r.Loading_Warehouse__r.Id 
            FROM Delivery_Shipments__r), (SELECT Warehouse__r.Id, Warehouse__r.Name FROM Delivery_Stops__r WHERE Stop_Order__c = 1 LIMIT 1) FROM Delivery_Order__c WHERE Id =: deliveryOrderId WITH SECURITY_ENFORCED LIMIT 1];

        final Double maxPalletAmount = deliveryOrder.Pallet_amount__c;
        final Double maxQuantity = deliveryOrder.Contract__r.Opportunity__r.Quantity__c;

        Map<Id, Double> palletQuantityAtWarehouse = new Map<Id, Double>{deliveryOrder.Delivery_Stops__r[0].Warehouse__r.Id => maxPalletAmount};
        Map<Id, Double> goodsQuantityAtWarehouse = new Map<Id, Double>{deliveryOrder.Delivery_Stops__r[0].Warehouse__r.Id => maxQuantity};
        Map<Id, String> warehouseIdToNameMap = new Map<Id, String>{deliveryOrder.Delivery_Stops__r[0].Warehouse__r.Id => deliveryOrder.Delivery_Stops__r[0].Warehouse__r.Name};

        if (((List<Delivery_Shipment__c>)deliveryOrder.Delivery_Shipments__r).size() > 0) { 
            for (Delivery_Shipment__c thisDS : (List<Delivery_Shipment__c>)deliveryOrder.Delivery_Shipments__r) { 
                if (TANSPORTATION_STATUSES.contains(thisDS.Shipment__r.Status__c)) {
                    if (!palletQuantityAtWarehouse.containsKey(thisDS.Shipment__r.Loading_Warehouse__r.Id)) {
                        palletQuantityAtWarehouse.put(thisDS.Shipment__r.Loading_Warehouse__r.Id, thisDS.Pallet_amount__c * -1);
                        goodsQuantityAtWarehouse.put(thisDS.Shipment__r.Loading_Warehouse__r.Id, thisDS.Quantity__c * -1);
                        warehouseIdToNameMap.put(thisDS.Shipment__r.Loading_Warehouse__r.Id, thisDS.Shipment__r.Loading_Warehouse__r.Name);
                    } else {
                        Double newPalletQuantity = palletQuantityAtWarehouse.get(thisDS.Shipment__r.Loading_Warehouse__r.Id) - thisDS.Pallet_amount__c;
                        Double newGoodsQuantity = goodsQuantityAtWarehouse.get(thisDS.Shipment__r.Loading_Warehouse__r.Id) - thisDS.Quantity__c;
                        palletQuantityAtWarehouse.put(thisDS.Shipment__r.Loading_Warehouse__r.Id, newPalletQuantity);
                        goodsQuantityAtWarehouse.put(thisDS.Shipment__r.Loading_Warehouse__r.Id, newGoodsQuantity);
                    }

                    Map<String, Object> recordToDisplay = new Map<String, Object>();
                    recordToDisplay.put(SHIPMENT, thisDS.Shipment__r.Name);
                    recordToDisplay.put(SHIPMENT_STATUS, thisDS.Shipment__r.Status__c);
                    recordToDisplay.put(PALLETS_AMOUNT, thisDS.Pallet_amount__c);
                    recordToDisplay.put(QUANTITY, thisDS.Quantity__c);
                    recordToDisplay.put(ID, thisDS.Id);
                    objectList.add(recordToDisplay);
                }
                if (DELIVERED_STATUS.contains(thisDS.Shipment__r.Status__c)) {
                    if (!palletQuantityAtWarehouse.containsKey(thisDS.Shipment__r.Loading_Warehouse__r.Id)) {
                        palletQuantityAtWarehouse.put(thisDS.Shipment__r.Loading_Warehouse__r.Id, thisDS.Pallet_amount__c * -1);
                        goodsQuantityAtWarehouse.put(thisDS.Shipment__r.Loading_Warehouse__r.Id, thisDS.Quantity__c * -1);
                        warehouseIdToNameMap.put(thisDS.Shipment__r.Loading_Warehouse__r.Id, thisDS.Shipment__r.Loading_Warehouse__r.Name);
                    } else {
                        Double newPalletQuantity = palletQuantityAtWarehouse.get(thisDS.Shipment__r.Loading_Warehouse__r.Id) - thisDS.Pallet_amount__c;
                        Double newGoodsQuantity = goodsQuantityAtWarehouse.get(thisDS.Shipment__r.Loading_Warehouse__r.Id) - thisDS.Quantity__c;
                        palletQuantityAtWarehouse.put(thisDS.Shipment__r.Loading_Warehouse__r.Id, newPalletQuantity);
                        goodsQuantityAtWarehouse.put(thisDS.Shipment__r.Loading_Warehouse__r.Id, newGoodsQuantity);
                    }

                    if (!palletQuantityAtWarehouse.containsKey(thisDS.Shipment__r.Destination_Warehouse__r.Id)) {
                        palletQuantityAtWarehouse.put(thisDS.Shipment__r.Destination_Warehouse__r.Id, thisDS.Pallet_amount__c);
                        warehouseIdToNameMap.put(thisDS.Shipment__r.Destination_Warehouse__r.Id, thisDS.Shipment__r.Destination_Warehouse__r.Name);
                        goodsQuantityAtWarehouse.put(thisDS.Shipment__r.Destination_Warehouse__r.Id, thisDS.Quantity__c);
                    } else {
                        Double newPalletQuantity = palletQuantityAtWarehouse.get(thisDS.Shipment__r.Destination_Warehouse__r.Id) + thisDS.Pallet_amount__c;
                        Double newGoodsQuantity = goodsQuantityAtWarehouse.get(thisDS.Shipment__r.Destination_Warehouse__r.Id) + thisDS.Quantity__c;
                        palletQuantityAtWarehouse.put(thisDS.Shipment__r.Destination_Warehouse__r.Id, newPalletQuantity);
                        goodsQuantityAtWarehouse.put(thisDS.Shipment__r.Destination_Warehouse__r.Id, newGoodsQuantity);
                    }
                }
            }

            for (Id warehouseId: palletQuantityAtWarehouse.keySet()) {
                if (palletQuantityAtWarehouse.get(warehouseId) > 0) {
                    Map<String, Object> recordToDisplay = new Map<String, Object>();
                    recordToDisplay.put(WAREHOUSE, warehouseIdToNameMap.get(warehouseId));
                    recordToDisplay.put(PALLETS_AMOUNT, palletQuantityAtWarehouse.get(warehouseId));
                    recordToDisplay.put(QUANTITY, goodsQuantityAtWarehouse.get(warehouseId));
                    recordToDisplay.put(ID, warehouseId);
                    objectList.add(recordToDisplay);
                }
            }
        }
        else {
            Map<String, Object> recordToDisplay = new Map<String, Object>();
            recordToDisplay.put(WAREHOUSE, deliveryOrder.Delivery_Stops__r[0].Warehouse__r.Name);
            recordToDisplay.put(PALLETS_AMOUNT, maxPalletAmount);
            recordToDisplay.put(QUANTITY, maxQuantity);
            objectList.add(recordToDisplay);
        }

        return objectList;
    }
}