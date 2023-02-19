public with sharing class OpportunityTRH extends TriggerHandler {

    public override void beforeInsert() {
        OpportunityDMN.createName((List<Opportunity>)Trigger.new);
        OpportunityDMN.calculateTotalPrice((List<Opportunity>)Trigger.new);
    }

    public override void beforeUpdate() {
        List<Opportunity> oppToCalculateList = new List<Opportunity>();

        OpportunityDMN.verifyName((Map<Id, Opportunity>)Trigger.oldMap, (Map<Id, Opportunity>)Trigger.newMap);

        for (Opportunity thisOpp : (List<Opportunity>)Trigger.new) {
            if (((Map<Id, Opportunity>)Trigger.oldMap).get(thisOpp.Id).Quantity__c != thisOpp.Quantity__c ||
                ((Map<Id, Opportunity>)Trigger.oldMap).get(thisOpp.Id).Package_price__c != thisOpp.Package_price__c)
                oppToCalculateList.add(thisOpp);
        }

        OpportunityDMN.calculateTotalPrice(oppToCalculateList);
    }

}