@isTest
global class ShipmentDMN_Test {

    private static final String CUSTOMER = 'Customer';
    private static final String SUPPLIER = 'Supplier';
    private static final String DRIVER = 'Driver';
    private static final String ACCOUNT_NAME = 'ABSR';
    private static final String ACCOUNT_NAME2 = 'XYZ';
    private static final String CONTACT_NAME = 'Testowy';
    private static final String PRODUCT_NAME = 'Mozzarella';
    private static final String CPRODUCT_NAME = 'Mozzarella Classic';

    @testSetup
    static void dataSetup() {
        Id supplierRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(SUPPLIER).getRecordTypeId();
        Id driverRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(DRIVER).getRecordTypeId();

        Account acc = (Account)TestDataFactory.createSObject('Account', new Map<String, Object>{
            'Name' => ACCOUNT_NAME
        });

        Account acc2 = (Account)TestDataFactory.createSObject('Account', new Map<String, Object>{
            'Name' => ACCOUNT_NAME2
        });

        Contact contact1 = (Contact)TestDataFactory.createSObject('Contact', new Map<String, Object>{
            'LastName' => CONTACT_NAME,
            'AccountId' => acc2.Id,
            'RecordTypeId' => driverRecordTypeId
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
    static void relationShipIsApproved() {
        Account customerAcc = [SELECT Id FROM Account WHERE Name =: ACCOUNT_NAME LIMIT 1];
        Account supplierAcc = [SELECT Id FROM Account WHERE Name =: ACCOUNT_NAME2 LIMIT 1];
        Contact driver = [SELECT Id FROM Contact WHERE Name =: CONTACT_NAME LIMIT 1];
        
        Account_Relationship__c ar = (Account_Relationship__c)TestDataFactory.createSObject('Account_Relationship__c', new Map<String, Object>{
            'Customer__c' => customerAcc.Id,
            'Customer_Relationship__c' => 'No information',
            'Supplier__c' => supplierAcc.Id,
            'Supplier_Relationship__c' => 'No information'
        });

        List<Shipment__c> shipmentList = [SELECT Driver__c FROM Shipment__c LIMIT 10];

        for (Shipment__c thisShipment : shipmentList) {
            thisShipment.Driver__c = driver.Id;
        }

        Test.startTest();
        update shipmentList;
        Test.stopTest();

        List<Shipment__c> shipmentUpdatedList = [SELECT Driver__c FROM Shipment__c LIMIT 10];
        Boolean isUpdatedCorrect = true;

        for (Shipment__c thisShipment : shipmentUpdatedList) {
            if (thisShipment.Driver__c != driver.Id) {
                isUpdatedCorrect = false;
            }
        } 

        System.assertEquals(true, isUpdatedCorrect, 'Shipments are not updated correct with driver field');
    }

    @isTest
    static void realationShipIsNotApproved() {
        Account customerAcc = [SELECT Id FROM Account WHERE Name =: ACCOUNT_NAME LIMIT 1];
        Account supplierAcc = [SELECT Id FROM Account WHERE Name =: ACCOUNT_NAME2 LIMIT 1];
        Contact driver = [SELECT Id FROM Contact WHERE Name =: CONTACT_NAME LIMIT 1];

        Account_Relationship__c ar = (Account_Relationship__c)TestDataFactory.createSObject('Account_Relationship__c', new Map<String, Object>{
            'Customer__c' => customerAcc.Id,
            'Customer_Relationship__c' => 'Blacklisted',
            'Supplier__c' => supplierAcc.Id,
            'Supplier_Relationship__c' => 'No information'
        });

        List<Shipment__c> shipmentList = [SELECT Driver__c FROM Shipment__c LIMIT 10];

        for (Shipment__c thisShipment : shipmentList) {
            thisShipment.Driver__c = driver.Id;
        }
        Boolean gotError = false;

        Test.startTest();
        try {
            update shipmentList;
        } catch (Exception e) {
            if (e.getMessage().contains(ShipmentDMN.ERROR_MSG)) {
                gotError = true;
            }
        }
        Test.stopTest();

        System.assertEquals(true, gotError, 'No validation shown regards to Account Relationship.');
    }
}