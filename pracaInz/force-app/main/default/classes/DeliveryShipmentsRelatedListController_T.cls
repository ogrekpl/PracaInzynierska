@isTest
global class DeliveryShipmentsRelatedListController_T {
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
            'Quantity__c' => 100,
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
            'Pallet_amount__c' => 100
        });

        Shipment__c shipment = (Shipment__c)TestDataFactory.createSObject('Shipment__c', new Map<String, Object>{
            'Destination_Warehouse__c' => wh.Id,
            'Loading_Warehouse__c' => wh2.Id,
            'Max_Pallets__c' => 100,
            'Status__c' => 'Planning'
        });

        List<Delivery_Shipment__c> dsList = TestDataFactory.createSObjectList('Delivery_Shipment__c', new Map<String, Object>{
            'Delivery_Order__c' => deliveryOrder.Id,
            'Shipment__c' => shipment.Id,
            'Pallet_amount__c' => 10,
            'Quantity__c' => 10
        }, 10);
    }

    @isTest
    static void controllerIsWorkingCorrect() {
        Shipment__c shipment = [SELECT Id FROM Shipment__c LIMIT 1];
        Test.startTest();
        List<Object> controllerList = DeliveryShipmentsRelatedListController.getListToDisplay(shipment.Id);
        Test.stopTest();
        System.assertEquals(10, controllerList.size(), 'Controller is not retrieving correct number of rows.');
    }
}