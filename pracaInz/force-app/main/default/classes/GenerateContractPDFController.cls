public class GenerateContractPDFController {
	private final Account customer;
    private final Account company;
    private final Contract contract;
    private final String signedDate; 

    public GenerateContractPDFController() {
        contract = [SELECT Id, ContractNumber, Opportunity_Price__c, AccountId FROM Contract 
                   WHERE Id =: ApexPages.currentPage().getParameters().get('id') LIMIT 1];
        customer = [SELECT Id, Name, BillingCity, BillingCountry, BillingPostalCode, BillingStreet, NIP__c
                    FROM Account WHERE Id =: contract.AccountId LIMIT 1];
        company = [SELECT Id, Name, BillingCity, BillingCountry, BillingPostalCode, BillingStreet, NIP__c
                    FROM Account WHERE Name = 'ABSR sp.z.o.o' LIMIT 1];
        signedDate = generateSignedDate();
    }

    public Account getCustomer() {
        return customer;
    }
    
    public Account getCompany() {
        return company;
    }

    public Contract getContract() {
        return contract;
    }
    
    public String getSignedDate() {
        return signedDate;
    }
    
    private String generateSignedDate() {
        String sgnDate = '';
        Date todayDate = Date.today();

        if (todayDate.day() < 10) {
            sgnDate = sgnDate + '0' + todayDate.day() + '.';
        }
        else {
            sgnDate = sgnDate + todayDate.day() + '.';
        }

        if (todayDate.month() < 10) {
            sgnDate = sgnDate + '0' + todayDate.month() + '.';
        }
        else {
            sgnDate = sgnDate + todayDate.month() + '.';
        }

        sgnDate += todayDate.year();

        return sgnDate;
    }
}