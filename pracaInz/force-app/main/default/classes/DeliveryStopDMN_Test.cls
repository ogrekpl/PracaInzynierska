@isTest
global class DeliveryStopDMN_Test {

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

         Opportunity opp2 = (Opportunity)TestDataFactory.createSObject('Opportunity', new Map<String, Object>{
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

         Contract con2 = (Contract)TestDataFactory.createSObject('Contract', new Map<String, Object>{
            'AccountId' => acc.Id,
            'Opportunity__c' => opp2.Id,
            'Status' => 'Verification'
         });

        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(con1.id);

        Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();
        req2.setComments('Submitting request for approval.');
        req2.setObjectId(con2.id);

        List<Approval.ProcessSubmitRequest> reqList = new List<Approval.ProcessSubmitRequest>{req1, req2};
        Approval.process(reqList);

        con1.Status = 'Signed';
        con2.Status = 'Signed';
        List<Contract> conToUpdate = new List<Contract> {con1, con2};
        update(conToUpdate);

        List<Delivery_Order__c> doList = TestDataFactory.createSObjectList('Delivery_Order__c', new Map<String, Object> {
            'Contract__c' => new List<Id>{con1.Id, con2.Id}
        }, 2);
    }

    @isTest
    public static void nameIsCreatedCorect() {
        Warehouse__c wh = [SELECT Id FROM Warehouse__c WHERE Name = 'Testowy Magazyn' LIMIT 1];
        Delivery_Order__c deliveryOrder = [SELECT Id FROM Delivery_Order__c LIMIT 1];

        List<Delivery_Stop__c> dsList = TestDataFactory.createSObjectList('Delivery_Stop__c', new Map<String,Object>{
            'Name' => 'x',
            'Delivery_Order__c' => deliveryOrder.Id,
            'Warehouse__c' => wh.Id
        }, 50, false);

        Test.startTest();
        insert(dsList);
        Test.stopTest();

        List<Delivery_Stop__c> dsListCreated = [SELECT Name FROM Delivery_Stop__c];
        
        Boolean areNamesCorect = true;

        for (Delivery_Stop__c thisDS : dsListCreated) {
            if (thisDS.Name != 'Testowy Magazyn DS') {
                areNamesCorect = false;
            }
        }

        System.assertEquals(true, areNamesCorect, 'Names are not genereated correct.');
    }

    @isTest
    public static void stopOrderIsSettedCorectForSingleFirstDeliveryStop() {
        Warehouse__c wh = [SELECT Id FROM Warehouse__c LIMIT 1];
        Delivery_Order__c deliveryOrder = [SELECT Id FROM Delivery_Order__c LIMIT 1];

        Delivery_Stop__c deliveryStop = (Delivery_Stop__c)TestDataFactory.createSObject('Delivery_Stop__c', new Map<String,Object>{
            'Name' => 'x',
            'Delivery_Order__c' => deliveryOrder.Id,
            'Warehouse__c' => wh.Id
        }, false);

        Test.startTest();
        insert(deliveryStop);
        Test.stopTest();

        Delivery_Stop__c deliveryStopCreated = [SELECT Name, Stop_Order__c FROM Delivery_Stop__c LIMIT 1];

        System.assertEquals(1, deliveryStopCreated.Stop_Order__c, 'Delivery Stop has wrong Stop Order value.');
    }

    @isTest
    public static void stopOrderIsSettedCorectForSingleDeliveryStop() {
        Warehouse__c wh1 = [SELECT Id FROM Warehouse__c WHERE Name = 'Testowy Magazyn' LIMIT 1];
        Warehouse__c wh2 = [SELECT Id FROM Warehouse__c WHERE Name = 'Testowy2 Magazyn' LIMIT 1];
        Delivery_Order__c deliveryOrder = [SELECT Id FROM Delivery_Order__c LIMIT 1];

        Delivery_Stop__c deliveryStop = (Delivery_Stop__c)TestDataFactory.createSObject('Delivery_Stop__c', new Map<String,Object>{
            'Name' => 'x',
            'Delivery_Order__c' => deliveryOrder.Id,
            'Warehouse__c' => wh1.Id
        }, false);

        List<Delivery_Stop__c> deliveryStopList = TestDataFactory.createSObjectList('Delivery_Stop__c', new Map<String,Object>{
            'Name' => 'x',
            'Delivery_Order__c' => deliveryOrder.Id,
            'Warehouse__c' => wh2.Id
        }, 50);

        Test.startTest();
        insert(deliveryStop);
        Test.stopTest();

        Delivery_Stop__c deliveryStopCreated = [SELECT Name, Stop_Order__c FROM Delivery_Stop__c WHERE Name = 'Testowy Magazyn DS' LIMIT 1];

        System.assertEquals(51, deliveryStopCreated.Stop_Order__c, 'Delivery Stop has wrong Stop Order value.');
    }
}

