trigger OpportunityTrigger on Opportunity (before insert, before update) {
    new OpportunityTRH().run();
}