public with sharing class NBPCurrencyCallout {
    private static final Set<String> CURRENCY_CODES = new Set<String>{'USD', 'EUR', 'GBP', 'CHF', 'CZK'}; 
    
    public static void getNewCurrencies() {
        createRecords(getCurrencies());
    }

    private static List<NBPCurrencyResponse> getCurrencies() {
        CalloutManager calloutManager = new CalloutManager('https://api.nbp.pl/api/exchangerates', 'tables/a/');
        calloutManager.setGetMethod();
        calloutManager.makeCallout();
        String responseString = (String)calloutManager.getBody();
        return NBPCurrencyResponse.wrapperList(responseString);
    }    

    private static void createRecords(List<NBPCurrencyResponse> nbpCurrencyList) {
        List<DatedConversionRate> dcrList = [SELECT Id, IsoCode, StartDate, ConversionRate FROM DatedConversionRate WHERE StartDate =: Date.today()];
        List<DatedConversionRate> newDcrList = new List<DatedConversionRate>(); 

        if (dcrList.size() == 0) {
            for (NBPCurrencyResponse.NBPRates thisRate : nbpCurrencyList[0].rates) {
                if (CURRENCY_CODES.contains(thisRate.code)) {
                    newDcrList.add(new DatedConversionRate(IsoCode = thisRate.code, ConversionRate = 1/(thisRate.mid), StartDate = Date.today()));
                }
            }
            makeCalloutToUpdateRates(newDcrList);
        }
    }
    
    private static void makeCalloutToUpdateRates(List<DatedConversionRate> dcrList) {
        CalloutManager calloutM = new CalloutManager(URL.getSalesforceBaseUrl().toExternalForm(), 'services/data/v57.0/composite/sobjects');
        calloutM.setPostMethod();
        calloutM.createHeader(new Map<String, String>{'Authorization' => 'OAuth ' + UserInfo.getSessionId()});
        calloutM.setBody('{"records": ' + JSON.serialize(dcrList) + '}');
        calloutM.makeCallout();
    }
}