public with sharing class WarehouseTRH extends TriggerHandler {

    public override void afterInsert() {
        for (Warehouse__c thisWarehouse : (List<Warehouse__c>)Trigger.new) {
            if (thisWarehouse.Address__c != null) {
                TomTomCalloutHandler.getGeoCodeValues(thisWarehouse.Id);
            }
        }
    }
}