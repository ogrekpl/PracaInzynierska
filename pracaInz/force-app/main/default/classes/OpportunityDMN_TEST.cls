@isTest
global class OpportunityDMN_TEST {
    
    private static final String CUSTOMER = 'Customer';
    private static final String SUPPLIER = 'Supplier';
    private static final String ACCOUNT_NAME = 'ABSR';
    private static final String PRODUCT_NAME = 'Mozzarella';
    private static final String CPRODUCT_NAME = 'Mozzarella Classic';

    @testSetup
    static void dataSetup() {
        Account acc = (Account)TestDataFactory.createSObject('Account', new Map<String, Object>{
            'Name' => ACCOUNT_NAME
        });

        Product2 prod = (Product2)TestDataFactory.createSObject('Product2', new Map<String, Object>{
            'Name' => PRODUCT_NAME
        });

        Company_Product__c cProd = (Company_Product__c)TestDataFactory.createSObject('Company_Product__c', new Map<String, Object>{
            'Name' => CPRODUCT_NAME,
            'Product__c' => prod.Id,
            'Account__c' => acc.Id
        });
    }

    @isTest
    public static void OpportunityNameIsCreatedCorrectSELL() {
        Id supplierRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(SUPPLIER).getRecordTypeId();
        String expectedName = 'SELL Mozzarella Classic - ABSR';

        Account acc = [SELECT Id FROM Account WHERE Name =: ACCOUNT_NAME LIMIT 1];
        Company_Product__c cProd = [SELECT Id FROM Company_Product__c WHERE Name =: CPRODUCT_NAME LIMIT 1];
        Opportunity sellOpp = new Opportunity(Name = 'x', Company_Product__c = cProd.Id, AccountId = acc.Id, StageName = 'Prospecting', CloseDate = date.today(), RecordTypeId = supplierRecordTypeId);

        Test.startTest();
        insert(sellOpp);
        Test.stopTest();
        
        Opportunity opp = [SELECT Name FROM Opportunity LIMIT 1];

        System.debug('expectedName: ' + expectedName);
        System.debug('sellOpp.Name: ' + sellOpp.Name);

        System.assertEquals(expectedName, opp.Name, 'Name is incorect');
    }

    @isTest
    public static void OpportunityNameIsCreatedCorrectBUY() {
        Id customerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(CUSTOMER).getRecordTypeId();
        String expectedName = 'BUY Mozzarella - ABSR';

        Account acc = [SELECT Id FROM Account WHERE Name =: ACCOUNT_NAME LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 WHERE Name =: PRODUCT_NAME LIMIT 1];
        Opportunity buyOpp = new Opportunity(Name = 'x', AccountId = acc.Id, Product__c = prod.Id,  StageName = 'Prospecting', CloseDate = date.today(), RecordTypeId = customerRecordTypeId);

        Test.startTest();
        insert(buyOpp);
        Test.stopTest();

        Opportunity opp = [SELECT Name FROM Opportunity LIMIT 1];

        System.debug('expectedName: ' + expectedName);
        System.debug('sellOpp.Name: ' + buyOpp.Name);

        System.assertEquals(expectedName, opp.Name, 'Name is incorect'); 
    }
}