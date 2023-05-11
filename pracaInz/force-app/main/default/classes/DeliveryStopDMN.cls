public with sharing class DeliveryStopDMN {
    public static void setUpStopOrder(Map<Id, List<Delivery_Stop__c>> deliveryOrderIdToDeliveryStopListMap) {

        Map<Id, Delivery_Order__c> deliveryOrderMap = new Map<Id, Delivery_Order__c>(
            [SELECT Id, (SELECT Id FROM Delivery_Stops__r) FROM Delivery_Order__c 
                WHERE Id in: deliveryOrderIdToDeliveryStopListMap.keySet()]);

        for (Id thisDSId : deliveryOrderIdToDeliveryStopListMap.keySet()) {

            Integer stopOrder = deliveryOrderMap.get(thisDSId).Delivery_Stops__r.size();

            for (Delivery_Stop__c thisDS : deliveryOrderIdToDeliveryStopListMap.get(thisDSId)) {
                stopOrder++;
                thisDs.Stop_Order__c = stopOrder;
            }
        }
    }

    public static void createName (List<Delivery_Stop__c> dsList) {
        Set<Id> warehouseIdSet = new Set<Id>();
        
        for (Delivery_Stop__c thisDS : dsList) {
            warehouseIdSet.add(thisDS.Warehouse__c);
        }

        Map<Id, Warehouse__c> warehouseMap = new Map<Id, Warehouse__c>([SELECT Name FROM Warehouse__c WHERE Id in: warehouseIdSet]);

        for (Delivery_Stop__c thisDS : dsList) {
            thisDS.Name = warehouseMap.get(thisDS.Warehouse__c).Name + ' DS';
        }
    } 

    public static void reorderStopOrders(List<Delivery_Stop__c> toDeleteList) {
        List<Delivery_Stop__c> deliveryOrdersToUpdate = new List<Delivery_Stop__c>();
        Set<Id> deliveryOrderIdSet = new Set<Id>();

        for (Delivery_Stop__c thisDS : toDeleteList) {
            deliveryOrderIdSet.add(thisDS.Delivery_Order__c);
        }

        List<Delivery_Order__c> deliveryOrderList = [SELECT Id, (SELECT Id, Stop_Order__c FROM Delivery_Stops__r ORDER BY Stop_Order__c ASC) 
                                                        FROM Delivery_Order__c WHERE Id in: deliveryOrderIdSet];

        for (Delivery_Order__c thisDO : deliveryOrderList) {
            if (thisDO.Delivery_Stops__r.size() > 0) {
                Integer stopOrderCounter = 1;
    
                for (Delivery_Stop__c thisDS : thisDO.Delivery_Stops__r) {
                    thisDS.Stop_Order__c = stopOrderCounter;
                    deliveryOrdersToUpdate.add(thisDS);
                    stopOrderCounter++;
                }
            }
        }

        if (deliveryOrdersToUpdate.size() > 0) {
            update(deliveryOrdersToUpdate);
        }
    }
}