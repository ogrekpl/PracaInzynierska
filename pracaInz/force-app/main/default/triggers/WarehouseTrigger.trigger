trigger WarehouseTrigger on Warehouse__c (after insert) {
    new WarehouseTRH().run();
}