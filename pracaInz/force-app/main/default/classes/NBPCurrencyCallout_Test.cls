@isTest
global class NBPCurrencyCallout_Test {
    @isTest
    public static void validateClass() {
        Test.setMock(HttpCalloutMock.class, new NBPCurrencyCalloutMockHttpResponse());
        NBPCurrencyCallout.getNewCurrencies();
    }
}