@isTest
global class DeliveryShipmentDMN_Test {

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

        Warehouse__c wh = (Warehouse__c)TestDataFactory.createSObject('Warehouse__c', new Map<String, Object>{
            'Account__c' => acc.Id,
            'Name' => 'Testowy Magazyn'
        });

        Warehouse__c wh2 = (Warehouse__c)TestDataFactory.createSObject('Warehouse__c', new Map<String, Object>{
            'Account__c' => acc.Id,
            'Name' => 'Testowy2 Magazyn'
        });

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
            'Quantity__c' => 1,
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
            'Pallet_amount__c' => 10
        });

        List<Shipment__c> shipmentList = TestDataFactory.createSObjectList('Shipment__c', new Map<String, Object>{
            'Destination_Warehouse__c' => wh.Id,
            'Loading_Warehouse__c' => wh2.Id,
            'Max_Pallets__c' => 100,
            'Status__c' => 'Delivered'
        }, 10);
    }

    @isTest
    public static void namesAreGeneratedCorrect() {
        List<Id> shipmentIdList = new List<Id>();
        Map<Id, Shipment__c> shipmentsMap = new Map<Id, Shipment__c>([SELECT Name FROM Shipment__c LIMIT 10]);
        Delivery_Order__c deliveryOrder = [SELECT Name FROM Delivery_Order__c LIMIT 1];

        for (Shipment__c thisShipment : shipmentsMap.values()) {
            shipmentIdList.add(thisShipment.Id);
        }

        List<Delivery_Shipment__c> deliveryShipmentToCreateList = TestDataFactory.createSObjectList('Delivery_Shipment__c', new Map<String, Object>{
            'Pallet_amount__c' => 1,
            'Delivery_Order__c' => deliveryOrder.Id,
            'Shipment__c' => shipmentIdList
        }, 10, false);

        Test.startTest();
        insert(deliveryShipmentToCreateList);
        Test.stopTest();

        List<Delivery_Shipment__c> deliveryShipmentCreatedList = [SELECT Name, Delivery_Order__c, Shipment__c FROM Delivery_Shipment__c LIMIT 10];
        Boolean areNamesCorrect = true;

        for (Delivery_Shipment__c thisDS : deliveryShipmentCreatedList) {
            String expectedName = deliveryOrder.Name + '-' +shipmentsMap.get(thisDS.Shipment__c).Name;
            if (thisDS.Name != expectedName) {
                areNamesCorrect = false;
            }
        }

        System.assertEquals(true, areNamesCorrect, 'Names are generated incorrect.');
    }

    @isTest
    public static void namesAreValidatedCorrect() {
        List<Id> shipmentIdList = new List<Id>();
        Map<Id, Shipment__c> shipmentsMap = new Map<Id, Shipment__c>([SELECT Name FROM Shipment__c LIMIT 10]);
        Delivery_Order__c deliveryOrder = [SELECT Name FROM Delivery_Order__c LIMIT 1];

        for (Shipment__c thisShipment : shipmentsMap.values()) {
            shipmentIdList.add(thisShipment.Id);
        }

        List<Delivery_Shipment__c> deliveryShipmentToCreateList = TestDataFactory.createSObjectList('Delivery_Shipment__c', new Map<String, Object>{
            'Pallet_amount__c' => 1,
            'Delivery_Order__c' => deliveryOrder.Id,
            'Shipment__c' => shipmentIdList
        }, 10);

        Test.startTest();

        List<Delivery_Shipment__c> deliveryShipmentToUpdateList = [SELECT Name FROM Delivery_Shipment__c LIMIT 10];

        for (Delivery_Shipment__c thisDS : deliveryShipmentToUpdateList) {
            thisDS.Name = 'XXXX';
        }

        update(deliveryShipmentToUpdateList);

        Test.stopTest();

        List<Delivery_Shipment__c> deliveryShipmentCreatedList = [SELECT Name, Delivery_Order__c, Shipment__c FROM Delivery_Shipment__c LIMIT 10];
        Boolean areNamesCorrect = true;

        for (Delivery_Shipment__c thisDS : deliveryShipmentCreatedList) {
            String expectedName = deliveryOrder.Name + '-' +shipmentsMap.get(thisDS.Shipment__c).Name;
            if (thisDS.Name != expectedName) {
                areNamesCorrect = false;
            }
        }

        System.assertEquals(true, areNamesCorrect, 'Names are validated incorrect.');
    }

    @isTest
    public static void toManyProofOfDeliveriesAssignedToDeliveryShipment() {
        List<Id> shipmentIdList = new List<Id>();
        List<Id> dsIdList = new List<Id>();
        Map<Id, Shipment__c> shipmentsMap = new Map<Id, Shipment__c>([SELECT Name FROM Shipment__c LIMIT 10]);
        Delivery_Order__c deliveryOrder = [SELECT Name FROM Delivery_Order__c LIMIT 1];

        for (Shipment__c thisShipment : shipmentsMap.values()) {
            shipmentIdList.add(thisShipment.Id);
        }

        List<Delivery_Shipment__c> deliveryShipmentToCreateList = TestDataFactory.createSObjectList('Delivery_Shipment__c', new Map<String, Object>{
            'Pallet_amount__c' => 1,
            'Quantity__c' => 1,
            'Delivery_Order__c' => deliveryOrder.Id,
            'Shipment__c' => shipmentIdList
        }, 10);

        for (Delivery_Shipment__c thisDS : deliveryShipmentToCreateList) {
            dsIdList.add(thisDS.Id);
        }
        
        List<Proof_of_Delivery__c> proofOfDeliveryListToInsert = TestDataFactory.createSObjectList('Proof_of_Delivery__c', new Map<String, Object> {
            'Delivery_Shipment__c' => dsIdList,
            'Pallet_Delivered_Amount__c' => 1,
            'Delivered_quantity__c' => 1
        }, 10);

        List<Proof_of_Delivery__c> proofOfDeliveryListToInsert2 = TestDataFactory.createSObjectList('Proof_of_Delivery__c', new Map<String, Object> {
            'Delivery_Shipment__c' => dsIdList,
            'Pallet_Delivered_Amount__c' => 1,
            'Delivered_quantity__c' => 1
        }, 10, false);

        Boolean gotError = false;
        Test.startTest();

        try {
            insert proofOfDeliveryListToInsert2;
        } catch (Exception e) {
            if (e.getMessage().contains(DeliveryShipmentDMN.ERROR_MSG)) {
                gotError = true;
            }
        }

        Test.stopTest();

        System.assertEquals(true, gotError, 'No validation appears.');
    }
}