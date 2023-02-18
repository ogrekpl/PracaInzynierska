public with sharing class OpportunityTRH extends TriggerHandler {

    public override void beforeInsert() {
        OpportunityDMN.CreateName((List<Opportunity>)Trigger.new);
    }

    public override void beforeUpdate() {
        OpportunityDMN.CreateName((List<Opportunity>)Trigger.new);
    }

}