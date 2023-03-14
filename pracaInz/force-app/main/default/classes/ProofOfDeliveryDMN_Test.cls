@isTest
global class ProofOfDeliveryDMN_Test {

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
            'Status__c' => new List<String>{'Planning', 'Delivered'}
        }, 10);

        List<Id> shipmentListSet = new List<Id>();
        for (Shipment__c thisShipment : shipmentList) {
            shipmentListSet.add(thisShipment.Id);
        }

        List<Delivery_Shipment__c> dsList = TestDataFactory.createSObjectList('Delivery_Shipment__c', new Map<String, Object>{
            'Delivery_Order__c' => deliveryOrder.Id,
            'Shipment__c' => shipmentListSet,
            'Pallet_amount__c' => 1,
            'Quantity__c' => 1
        }, 5);
    }

    @isTest 
    static void proofOfDeliveryIsCreated() {
        List<Shipment__c> shipmentList = [SELECT Id FROM Shipment__c WHERE Status__c = 'Delivered' LIMIT 5];
        Set<Id> shipmentIdSet = new Set<Id>();

        for (Shipment__c thisShipment : shipmentList) {
            shipmentIdSet.add(thisShipment.Id);
        }

        Map<Id, Delivery_Shipment__c> dsMap = new Map<Id, Delivery_Shipment__c>(
            [SELECT Id FROM Delivery_Shipment__c WHERE Shipment__c in: shipmentIdSet]);

        List<Id> dsIdList = new List<Id>(dsMap.keySet());

        Test.startTest();

        List<Proof_of_Delivery__c> proofOfDeliveryListToInsert = TestDataFactory.createSObjectList('Proof_of_Delivery__c', new Map<String, Object> {
            'Delivery_Shipment__c' => dsIdList,
            'Pallet_Delivered_Amount__c' => 1,
            'Delivered_quantity__c' => 1
        }, 5);

        List<Proof_of_Delivery__c> podList = [SELECT Id FROM Proof_of_Delivery__c];

        Test.stopTest();

        System.assertEquals(5, podList.size(), 'Wrong number of Proof of Deliverys are inserted.');
    }

    @isTest 
    static void proofOfDeliveryIsUpdated() {
        List<Shipment__c> shipmentList = [SELECT Id FROM Shipment__c WHERE Status__c = 'Delivered' LIMIT 5];
        Set<Id> shipmentIdSet = new Set<Id>();

        for (Shipment__c thisShipment : shipmentList) {
            shipmentIdSet.add(thisShipment.Id);
        }

        Map<Id, Delivery_Shipment__c> dsMap = new Map<Id, Delivery_Shipment__c>(
            [SELECT Id FROM Delivery_Shipment__c WHERE Shipment__c in: shipmentIdSet]);

        List<Id> dsIdList = new List<Id>(dsMap.keySet());

        List<Proof_of_Delivery__c> proofOfDeliveryListToInsert = TestDataFactory.createSObjectList('Proof_of_Delivery__c', new Map<String, Object> {
            'Delivery_Shipment__c' => dsIdList,
            'Pallet_Delivered_Amount__c' => 0,
            'Delivered_quantity__c' => 1
        }, 5);

        List<Proof_of_Delivery__c> podList = [SELECT Pallet_Delivered_Amount__c FROM Proof_of_Delivery__c];

        for (Proof_of_Delivery__c thisPOD : podList) {
            thisPOD.Pallet_Delivered_Amount__c = 1;
        }

        Test.startTest();

        update podList;

        Test.stopTest();

        List<Proof_of_Delivery__c> podUpdatedList = [SELECT Pallet_Delivered_Amount__c FROM Proof_of_Delivery__c];

        Boolean isCorrectedUpdated = true;

        for (Proof_of_Delivery__c thisPOD : podList) {
            if (thisPOD.Pallet_Delivered_Amount__c != 1) {
                isCorrectedUpdated = false;
            }
        }

        System.assertEquals(true, isCorrectedUpdated, 'Records are not updated correct.');
    }

    @isTest 
    static void proofOfDeliveryIsNotCreatedBadShipmentStatus() {
        List<Shipment__c> shipmentList = [SELECT Id FROM Shipment__c WHERE Status__c = 'Planning' LIMIT 5];
        Set<Id> shipmentIdSet = new Set<Id>();

        for (Shipment__c thisShipment : shipmentList) {
            shipmentIdSet.add(thisShipment.Id);
        }

        Map<Id, Delivery_Shipment__c> dsMap = new Map<Id, Delivery_Shipment__c>(
            [SELECT Id FROM Delivery_Shipment__c WHERE Shipment__c in: shipmentIdSet]);

        List<Id> dsIdList = new List<Id>(dsMap.keySet());

        Test.startTest();

        List<Proof_of_Delivery__c> proofOfDeliveryListToInsert = TestDataFactory.createSObjectList('Proof_of_Delivery__c', new Map<String, Object> {
            'Delivery_Shipment__c' => dsIdList,
            'Pallet_Delivered_Amount__c' => 1,
            'Delivered_quantity__c' => 1
        }, 5, false);

        Boolean gotException = false;

        try {
            insert proofOfDeliveryListToInsert;
        } catch (Exception e) {
            if (e.getMessage().contains(ProofOfDeliveryDMN.ERROR_MSG_3)) {
                gotException = true;
            } 
        }
        
        Test.stopTest();

        System.assertEquals(true, gotException, 'No expected exception recieved.');
    }

    @isTest 
    static void proofOfDeliveryIsNotCreatedBadPalletQuantity() {
        List<Shipment__c> shipmentList = [SELECT Id FROM Shipment__c WHERE Status__c = 'Delivered' LIMIT 5];
        Set<Id> shipmentIdSet = new Set<Id>();

        for (Shipment__c thisShipment : shipmentList) {
            shipmentIdSet.add(thisShipment.Id);
        }

        Map<Id, Delivery_Shipment__c> dsMap = new Map<Id, Delivery_Shipment__c>(
            [SELECT Id FROM Delivery_Shipment__c WHERE Shipment__c in: shipmentIdSet]);

        List<Id> dsIdList = new List<Id>(dsMap.keySet());

        Test.startTest();

        List<Proof_of_Delivery__c> proofOfDeliveryListToInsert = TestDataFactory.createSObjectList('Proof_of_Delivery__c', new Map<String, Object> {
            'Delivery_Shipment__c' => dsIdList,
            'Pallet_Delivered_Amount__c' => 1000,
            'Delivered_quantity__c' => 1
        }, 5, false);

        Boolean gotException = false;

        try {
            insert proofOfDeliveryListToInsert;
        } catch (Exception e) {
            if (e.getMessage().contains(ProofOfDeliveryDMN.ERROR_MSG_2)) {
                gotException = true;
            } 
        }
        
        Test.stopTest();

        System.assertEquals(true, gotException, 'No expected exception recieved.');        
    }

    @isTest 
    static void proofOfDeliveryIsNotCreatedBadTotalQuantity() {
        List<Shipment__c> shipmentList = [SELECT Id FROM Shipment__c WHERE Status__c = 'Delivered' LIMIT 5];
        Set<Id> shipmentIdSet = new Set<Id>();

        for (Shipment__c thisShipment : shipmentList) {
            shipmentIdSet.add(thisShipment.Id);
        }

        Map<Id, Delivery_Shipment__c> dsMap = new Map<Id, Delivery_Shipment__c>(
            [SELECT Id FROM Delivery_Shipment__c WHERE Shipment__c in: shipmentIdSet]);

        List<Id> dsIdList = new List<Id>(dsMap.keySet());

        Test.startTest();

        List<Proof_of_Delivery__c> proofOfDeliveryListToInsert = TestDataFactory.createSObjectList('Proof_of_Delivery__c', new Map<String, Object> {
            'Delivery_Shipment__c' => dsIdList,
            'Pallet_Delivered_Amount__c' => 1,
            'Delivered_quantity__c' => 10000
        }, 5, false);

        Boolean gotException = false;

        try {
            insert proofOfDeliveryListToInsert;
        } catch (Exception e) {
            if (e.getMessage().contains(ProofOfDeliveryDMN.ERROR_MSG_1)) {
                gotException = true;
            } 
        }
        
        Test.stopTest();

        System.assertEquals(true, gotException, 'No expected exception recieved.');           
    }
}