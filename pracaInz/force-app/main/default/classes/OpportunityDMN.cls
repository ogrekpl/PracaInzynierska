public with sharing class OpportunityDMN {

    private static final String CUSTOMER = 'Customer';
    private static final String SUPPLIER = 'Supplier';

    public static void createName(List<Opportunity> oppToUpdate) {

        Set<String> accountcsIdSet = new Set<String>();
        Set<String> productsIdSet = new Set<String>();
        Set<String> companyProductsIdSet = new Set<String>();
        Map<String, Product2> productMap;
        Map<String, Company_Product__c> companyProductMap;

        Id customerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(CUSTOMER).getRecordTypeId();
        Id supplierRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(SUPPLIER).getRecordTypeId();

        for (Opportunity thisOpp : oppToUpdate) {
            accountcsIdSet.add(thisOpp.AccountId);

            if (thisOpp.RecordTypeId == customerRecordTypeId) {
                productsIdSet.add(thisOpp.Product__c);
            }

            if (thisOpp.RecordTypeId == supplierRecordTypeId) {
                companyProductsIdSet.add(thisOpp.Company_Product__c);
            }
        }

        Map<String, Account> accountMap = new Map<String, Account>([SELECT Name FROM Account WHERE Id in: accountcsIdSet]);
        
        if (!productsIdSet.isEmpty()) {
            productMap = new Map<String, Product2>([SELECT Name FROM Product2 WHERE Id in: productsIdSet]);
        }

        if (!accountcsIdSet.isEmpty()) {
            companyProductMap = new Map<String, Company_Product__c>([SELECT Name FROM Company_Product__c WHERE Id in: companyProductsIdSet]);
        }

        for (Opportunity thisOpp : oppToUpdate) {
            String oppName;

            if (thisOpp.RecordTypeId == customerRecordTypeId) {
                oppName = 'BUY ' + productMap.get(thisOpp.Product__c).Name + ' - ' + accountMap.get(thisOpp.AccountId).Name;
            }

            if (thisOpp.RecordTypeId == supplierRecordTypeId) {
                oppName = 'SELL ' + companyProductMap.get(thisOpp.Company_Product__c).Name + ' - ' + accountMap.get(thisOpp.AccountId).Name;
            }

            thisOpp.Name = oppName;
        } 
    }

    public static void verifyName(Map<Id, Opportunity> oldOppMap, Map<Id, Opportunity> newOppMap) {

        List<Opportunity> oppToUpdateNameList = new List<Opportunity>();

        for (Opportunity thisOpp : newOppMap.values()) {
            if (thisOpp.Name != oldOppMap.get(thisOpp.Id).Name) {
                oppToUpdateNameList.add(thisOpp);
            }
        }

        createName(oppToUpdateNameList);
    }

    public static void calculateTotalPrice(List<Opportunity> oppList) {
        for (Opportunity thisOpp : oppList) {
            if (thisOpp.Quantity__c != null && thisOpp.Package_price__c != null)
                thisOpp.Amount = thisOpp.Quantity__c * thisOpp.Package_price__c;
        }
    }
}