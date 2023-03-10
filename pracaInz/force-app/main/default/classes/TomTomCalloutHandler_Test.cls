@isTest
global class TomTomCalloutHandler_Test {

    private static final String CUSTOMER = 'Customer';
    private static final String SUPPLIER = 'Supplier';
    private static final String ACCOUNT_NAME = 'ABSR';
    private static final String PRODUCT_NAME = 'Mozzarella';
    private static final String CPRODUCT_NAME = 'Mozzarella Classic';

    @testSetup
    static void dataSetup() {
        Id supplierRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(SUPPLIER).getRecordTypeId();

        Account acc = (Account)TestDataFactory.createSObject('Account', new Map<String, Object>{
            'Name' => ACCOUNT_NAME
        });

        List<Warehouse__c> whList = TestDataFactory.createSObjectList('Warehouse__c', new Map<String, Object>{
            'Account__c' => acc.Id,
            'Name' => new List<String>{'Testowy_Magazyn_A', 'Testowy_Magazyn_B','Testowy_Magazyn_C'}
        }, 3);

        Product2 prod = (Product2)TestDataFactory.createSObject('Product2', new Map<String, Object>{
            'Name' => PRODUCT_NAME
        });

        Company_Product__c cProd = (Company_Product__c)TestDataFactory.createSObject('Company_Product__c', new Map<String, Object>{
            'Name' => CPRODUCT_NAME,
            'Product__c' => prod.Id,
            'Account__c' => acc.Id
        });

        Opportunity opp1 = (Opportunity)TestDataFactory.createSObject('Opportunity', new Map<String, Object>{
            'Name' => 'x',
            'AccountId' => acc.Id,
            'Company_Product__c' => cProd.Id,
            'StageName' => 'Closed Won',
            'CloseDate' => date.today(),
            'RecordTypeId' => supplierRecordTypeId,
            'Quantity__c' => 150,
            'Package_price__c' => 1
         });

        Contract con1 = (Contract)TestDataFactory.createSObject('Contract', new Map<String, Object>{
            'AccountId' => acc.Id,
            'Opportunity__c' => opp1.Id,
            'Status' => 'Verification'
        });

        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(con1.id);
        Approval.process(req1);
        con1.Status = 'Signed';
        update(con1);

        Delivery_Order__c deliveryOrder = (Delivery_Order__c)TestDataFactory.createSObject('Delivery_Order__c', new Map<String, Object> {
            'Contract__c' => con1.Id,
            'Pallet_amount__c' => 150,
            'Pallet__c' => 'EUR'
        });

        List<Delivery_Stop__c> deliveryStopList = TestDataFactory.createSObjectList('Delivery_Stop__c', new Map<String, Object>{
            'Delivery_Order__c' => deliveryOrder.Id,
            'Warehouse__c' => new List<Id>{whList[0].Id, whList[1].Id, whList[2].Id}
        }, 3);

        Shipment__c shipment = (Shipment__c)TestDataFactory.createSObject('Shipment__c', new Map<String, Object>{
            'Destination_Warehouse__c' => whList[1].Id,
            'Loading_Warehouse__c' => whList[0].Id,
            'Max_Pallets__c' => 100,
            'Status__c' => 'Delivered'
        });
    }

    @isTest
    static void geoCodesAreSettedCorrect() {
        Warehouse__c warehouse = [SELECT Address__c FROM Warehouse__c WHERE Name = 'Testowy_Magazyn_A' LIMIT 1];
        
        warehouse.Address__Street__s = 'al Jana Pawła 23';
        warehouse.Address__City__s = 'Warsaw';
        warehouse.Address__PostalCode__s = '00-854';
        warehouse.Address__CountryCode__s = 'PL';

        System.debug('warehouse: ' + warehouse);
        update(warehouse);

        Test.setMock(HttpCalloutMock.class, new TomTomCalloutHandlerMockHttpResponse());
        Test.startTest();
        TomTomCalloutHandler.getGeoCodeValues(warehouse.Id);
        Test.stopTest();

        Warehouse__c warehouseUpdated = [SELECT geoLocation__c FROM Warehouse__c WHERE Name = 'Testowy_Magazyn_A' LIMIT 1];

        System.assertEquals(52.23632, warehouseUpdated.geoLocation__c.getLatitude(), 'Wrong Latitude value.');
        System.assertEquals(20.99649, warehouseUpdated.geoLocation__c.getLongitude(), 'Wrong Latitude value.');
    }

    @isTest
    static void routeDetailsAreSettedCorrect() {
        Warehouse__c warehouseA = [SELECT geoLocation__c FROM Warehouse__c WHERE Name = 'Testowy_Magazyn_A' LIMIT 1];
        Warehouse__c warehouseB = [SELECT geoLocation__c FROM Warehouse__c WHERE Name = 'Testowy_Magazyn_B' LIMIT 1];
        Shipment__c shipment = [SELECT Id FROM Shipment__c LIMIT 1];

        warehouseA.geoLocation__latitude__s = 52.16362;
        warehouseA.geoLocation__longitude__s = 21.0461;
        warehouseB.geoLocation__latitude__s = 51.40247;
        warehouseB.geoLocation__longitude__s = 21.11792;

        List<Warehouse__c> warehouseListToUpdate = new List<Warehouse__c>{warehouseA, warehouseB};
        update(warehouseListToUpdate);

        Test.setMock(HttpCalloutMock.class, new TomTomCalloutHandlerMockHttpResponse());
        Test.startTest();
        TomTomCalloutHandler.getRouteDetails(shipment.Id);
        Test.stopTest();

        Shipment__c shipmentUpdated = [SELECT Hours__c, Minutes__c, Total_distance__c FROM Shipment__c LIMIT 1];

        System.assertEquals(true, shipmentUpdated.Hours__c != null, 'Hours Time is not setted.');
        System.assertEquals(true, shipmentUpdated.Minutes__c != null, 'Minutes Time is not setted.');
        System.assertEquals(true, shipmentUpdated.Total_distance__c != null, 'Total Distance is not setted.');

    }
}