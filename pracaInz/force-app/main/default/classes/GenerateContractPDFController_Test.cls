@isTest
global class GenerateContractPDFController_Test {

    private final static String ACCOUNT_NAME = 'Test Company';
    private final static String OUR_COMPANY_NAME = 'ABSR sp.z.o.o';
    private static final String SUPPLIER = 'Supplier';
    private static final String PRODUCT_NAME = 'Mozzarella';
    private static final String CPRODUCT_NAME = 'Mozzarella Classic';

    @TestSetup
    public static void setupData() {
        Id supplierRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(SUPPLIER).getRecordTypeId();
        List<Account> accList = TestDataFactory.createSObjectList('Account', new Map<String, Object>{
            'Name' => new List<String>{ACCOUNT_NAME, OUR_COMPANY_NAME},
            'BillingCity' => new List<String>{'Warsaw', 'Warsaw'}, 
            'BillingCountry' => new List<String>{'Poland', 'Poland'},
            'BillingPostalCode' => new List<String>{'03-111', '01-234'},
            'BillingStreet' => new List<String>{'Testowa ulica', 'inna Testowa ulica'}, 
            'NIP__c' => new List<String>{'594847', '124356'}
        }, 2);

        Product2 prod = (Product2)TestDataFactory.createSObject('Product2', new Map<String, Object>{
            'Name' => PRODUCT_NAME
        });

        Company_Product__c cProd = (Company_Product__c)TestDataFactory.createSObject('Company_Product__c', new Map<String, Object>{
            'Name' => CPRODUCT_NAME,
            'Product__c' => prod.Id,
            'Account__c' => accList[0].Id
        });

        Opportunity opp1 = (Opportunity)TestDataFactory.createSObject('Opportunity', new Map<String, Object>{
            'Name' => 'x',
            'AccountId' => accList[0].Id,
            'Company_Product__c' => cProd.Id,
            'StageName' => 'Closed Won',
            'CloseDate' => date.today(),
            'RecordTypeId' => supplierRecordTypeId,
            'Quantity__c' => 1,
            'Package_price__c' => 1
         });
         

         Contract con1 = (Contract)TestDataFactory.createSObject('Contract', new Map<String, Object>{
            'AccountId' => accList[0].Id,
            'Opportunity__c' => opp1.Id,
            'Status' => 'Verification'
         });
    }

    @isTest
    public static void pdfFileFieldsAreHandledCorrect() {

        Contract con = [SELECT Id FROM Contract LIMIT 1];
        Account acc1 = [SELECT Id FROM Account WHERE Name =: OUR_COMPANY_NAME LIMIT 1];
        Account acc2 = [SELECT Id FROM Account WHERE Name =: ACCOUNT_NAME LIMIT 1];

        Test.startTest();
        PageReference pageRef = Page.GenerateContractPDF;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(con.Id));
      
        GenerateContractPDFController controller = new GenerateContractPDFController();     
        Test.stopTest();

        System.assertEquals(acc1.Id, controller.getCompany().Id, 'Our company is not valid.');
        System.assertEquals(acc2.Id, controller.getCustomer().Id, 'Customer is not valid.');
        System.assertEquals(con.Id, controller.getContract().Id, 'Contract is not valid.');
        System.assertEquals(true, controller.getSignedDate() != null, 'Date is not valid.');
    }
}