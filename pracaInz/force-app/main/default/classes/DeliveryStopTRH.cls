public with sharing class DeliveryStopTRH extends TriggerHandler {
    
    public override void beforeInsert() {
        DeliveryStopDMN.setUpStopOrder(createDeliveryOrderIdToDeliveryStopListMap((List<Delivery_Stop__c>)Trigger.new));
        DeliveryStopDMN.createName((List<Delivery_Stop__c>)Trigger.new);
    }
    
    public override void afterDelete() {
        DeliveryStopDMN.reorderStopOrders((List<Delivery_Stop__c>)Trigger.old);
    }

    private Map<Id, List<Delivery_Stop__c>> createDeliveryOrderIdToDeliveryStopListMap(List<Delivery_Stop__c> inputList) {
        Map<Id, List<Delivery_Stop__c>> outputMap = new Map<Id, List<Delivery_Stop__c>>();
        for (Delivery_Stop__c thisDS : inputList) {

            if (!outputMap.containsKey(thisDS.Delivery_Order__c)) {
                List<Delivery_Stop__c> dsList = new List<Delivery_Stop__c>();
                dsList.add(thisDS);
                outputMap.put(thisDS.Delivery_Order__c, dsList);
            }
            else {
                List<Delivery_Stop__c> dsList = outputMap.get(thisDS.Delivery_Order__c);
                dsList.add(thisDS);
                outputMap.put(thisDS.Delivery_Order__c, dsList);
            }            
        }

        return outputMap;
    }
}