@isTest
global class BatchSummaryController_Test {
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
    }

    @isTest
    static void controllerWorksForNoDS() {
        Delivery_Order__c deliveryOrder = [SELECT Id FROM Delivery_Order__c LIMIT 1];

        Test.startTest();
        List<Object> returnedList = BatchSummaryController.getListToDisplay(deliveryOrder.Id);
        Test.stopTest();
        
        System.assertEquals(1, returnedList.size(),'Wrong returned list size.');
        System.assertEquals(150, ((Map<String, Object>)returnedList[0]).get('Pallets_Amount'),'Wrong pallet amount.');
        System.assertEquals(150, ((Map<String, Object>)returnedList[0]).get('Quantity'),'Wrong quantity.');
        System.assertEquals('Testowy_Magazyn_A', ((Map<String, Object>)returnedList[0]).get('Warehouse'),'Wrong warehouse name.');
    }

    @isTest
    static void controllerWorks() {
        Delivery_Order__c deliveryOrder = [SELECT Id FROM Delivery_Order__c LIMIT 1];

        setupRecordsForFullyWork(deliveryOrder);

        Test.startTest();
        List<Object> returnedList = BatchSummaryController.getListToDisplay(deliveryOrder.Id);
        Test.stopTest();

        Boolean isReturnedCorrect = true;
        System.assertEquals(5, returnedList.size(), 'Wrong returned list size.');

        for (Object thisObj : returnedList) {
            Map<String, Object> thisMap = (Map<String, Object>)thisObj;
            if (thisMap.get('Warehouse') != null && thisMap.get('Pallets_Amount')!= 40) {
                    isReturnedCorrect = false;
            }
            if (thisMap.get('Shipment') == 'S-100008' && thisMap.get('Pallets_Amount') != 10) {
                isReturnedCorrect = false;
            }

            if (thisMap.get('Shipment') == 'S-100011' && thisMap.get('Pallets_Amount') != 20) {
                isReturnedCorrect = false;
            }
        }

        System.assertEquals(true, isReturnedCorrect, 'Wrong details returned from Controller.');
    }

    private static void setupRecordsForFullyWork(Delivery_Order__c deliveryOrder) {
        List<Warehouse__c> whList = [SELECT Id FROM Warehouse__c ORDER BY Name ASC LIMIT 3];

        List<Shipment__c> shipmentList1 = TestDataFactory.createSObjectList('Shipment__c', new Map<String, Object>{
            'Destination_Warehouse__c' => whList[1].Id,
            'Loading_Warehouse__c' => whList[0].Id,
            'Max_Pallets__c' => 100,
            'Status__c' => 'Delivered'
        }, 2);

        Shipment__c shipment1 = (Shipment__c)TestDataFactory.createSObject('Shipment__c', new Map<String, Object>{
            'Destination_Warehouse__c' => whList[1].Id,
            'Loading_Warehouse__c' => whList[0].Id,
            'Max_Pallets__c' => 100,
            'Status__c' => 'In transport'
        });

        List<Shipment__c> shipmentList2 = TestDataFactory.createSObjectList('Shipment__c', new Map<String, Object>{
            'Destination_Warehouse__c' => whList[2].Id,
            'Loading_Warehouse__c' => whList[1].Id,
            'Max_Pallets__c' => 100,
            'Status__c' => 'Delivered'
        }, 2);

        Shipment__c shipment2 = (Shipment__c)TestDataFactory.createSObject('Shipment__c', new Map<String, Object>{
            'Destination_Warehouse__c' => whList[2].Id,
            'Loading_Warehouse__c' => whList[1].Id,
            'Max_Pallets__c' => 100,
            'Status__c' => 'In transport'
        });

        Delivery_Shipment__c ds1 = (Delivery_Shipment__c)TestDataFactory.createSObject('Delivery_Shipment__c', new Map<String, Object>{
            'Delivery_Order__c' => deliveryOrder.Id,
            'Shipment__c' => shipmentList1[0].Id,
            'Pallet_amount__c' => 50,
            'Quantity__c' => 50
        }, false);

        Delivery_Shipment__c ds2 = (Delivery_Shipment__c)TestDataFactory.createSObject('Delivery_Shipment__c', new Map<String, Object>{
            'Delivery_Order__c' => deliveryOrder.Id,
            'Shipment__c' => shipmentList1[1].Id,
            'Pallet_amount__c' => 50,
            'Quantity__c' => 50
        }, false);

        Delivery_Shipment__c ds3 = (Delivery_Shipment__c)TestDataFactory.createSObject('Delivery_Shipment__c', new Map<String, Object>{
            'Delivery_Order__c' => deliveryOrder.Id,
            'Shipment__c' => shipment1.Id,
            'Pallet_amount__c' => 10,
            'Quantity__c' => 10
        }, false);

        Delivery_Shipment__c ds4 = (Delivery_Shipment__c)TestDataFactory.createSObject('Delivery_Shipment__c', new Map<String, Object>{
            'Delivery_Order__c' => deliveryOrder.Id,
            'Shipment__c' => shipmentList2[0].Id,
            'Pallet_amount__c' => 20,
            'Quantity__c' => 20
        }, false);

        Delivery_Shipment__c ds5 = (Delivery_Shipment__c)TestDataFactory.createSObject('Delivery_Shipment__c', new Map<String, Object>{
            'Delivery_Order__c' => deliveryOrder.Id,
            'Shipment__c' => shipmentList2[1].Id,
            'Pallet_amount__c' => 20,
            'Quantity__c' => 20
        }, false);

        Delivery_Shipment__c ds6 = (Delivery_Shipment__c)TestDataFactory.createSObject('Delivery_Shipment__c', new Map<String, Object>{
            'Delivery_Order__c' => deliveryOrder.Id,
            'Shipment__c' => shipment2.Id,
            'Pallet_amount__c' => 20,
            'Quantity__c' => 20
        }, false);

        List<Delivery_Shipment__c> dsListToInsert = new List<Delivery_Shipment__c>();
        dsListToInsert.add(ds1);
        dsListToInsert.add(ds2);
        dsListToInsert.add(ds3);
        dsListToInsert.add(ds4);
        dsListToInsert.add(ds5);
        dsListToInsert.add(ds6);

        insert(dsListToInsert);
    }
}