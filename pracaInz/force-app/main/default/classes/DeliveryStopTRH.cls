public with sharing class DeliveryStopTRH extends TriggerHandler{
    
    public override void beforeInsert() {
        Map<Id, List<Delivery_Stop__c>> deliveryOrderToDeliveryStopListMap = new Map<Id, List<Delivery_Stop__c>>();

        for (Delivery_Stop__c thisDS : (List<Delivery_Stop__c>)Trigger.new) {

            if (!deliveryOrderToDeliveryStopListMap.containsKey(thisDS.Delivery_Order__c)) {
                List<Delivery_Stop__c> dsList = new List<Delivery_Stop__c>();
                dsList.add(thisDS);
                deliveryOrderToDeliveryStopListMap.put(thisDS.Delivery_Order__c, dsList);
            }
            else {
                List<Delivery_Stop__c> dsList = deliveryOrderToDeliveryStopListMap.get(thisDS.Delivery_Order__c);
                dsList.add(thisDS);
                deliveryOrderToDeliveryStopListMap.put(thisDS.Delivery_Order__c, dsList);
            }            
        }

        DeliveryStopDMN.setUpStopOrder(deliveryOrderToDeliveryStopListMap);
        DeliveryStopDMN.createName((List<Delivery_Stop__c>)Trigger.new);
    } 
}