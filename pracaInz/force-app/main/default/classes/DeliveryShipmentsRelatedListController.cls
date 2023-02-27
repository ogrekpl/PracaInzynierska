public with sharing class DeliveryShipmentsRelatedListController {

    @AuraEnabled(cacheable=true)
    public static List<Object> getListToDisplay(Id shipmentId) {

        List<Object> objectList = new List<Object>();

        List<Delivery_Shipment__c> dsList = [SELECT Id, Pallet_amount__c, Quantity__c, Delivery_Order__r.Name, Delivery_Order__r.Pallet__c, 
                                             Delivery_Order__r.Contract__r.Opportunity__r.Company_Product__r.Name FROM Delivery_Shipment__c 
                                             WHERE Shipment__c =: shipmentId WITH SECURITY_ENFORCED];

        for (Delivery_Shipment__c thisDS : dsList) {
            Map<String, Object> recordMap = new Map<String, Object>();
            recordMap.put('Id', thisDS.Id);
            recordMap.put('Pallet_amount__c', thisDS.Pallet_amount__c);
            recordMap.put('Quantity__c', thisDS.Quantity__c);
            recordMap.put('DeliveryOrderName', thisDS.Delivery_Order__r.Name);
            recordMap.put('Pallet_Type', thisDS.Delivery_Order__r.Pallet__c);
            recordMap.put('CompanyProduct', thisDS.Delivery_Order__r.Contract__r.Opportunity__r.Company_Product__r.Name);
            objectList.add(recordMap);
        }

        return objectList;
    }

}