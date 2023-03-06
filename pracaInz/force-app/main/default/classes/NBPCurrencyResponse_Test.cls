@isTest
global class NBPCurrencyResponse_Test {

    private static final List<String> CODES = new List<String>{'USD', 'CHF', 'GBP'};

    @isTest
    public static void testNBPCurrencyResponseClassList() {
        String json = '[{"table":"A","no":"044/A/NBP/2023","effectiveDate":"2023-03-03","rates":[{"code":"USD","mid":4.4341},{"code":"CHF","mid":4.7280},{"code":"GBP","mid":5.3147}]}]';
        List<NBPCurrencyResponse> nbpCRList = NBPCurrencyResponse.wrapperList(json);
        Boolean isWrappedCorrect = true;

        for (NBPCurrencyResponse.NBPRates thisRate : nbpCRList[0].rates) {
            if (!CODES.contains(thisRate.code)) {
                isWrappedCorrect = false;
            }
        }
        
        System.assertEquals(true, isWrappedCorrect, 'Wrapper is not working correct');
    }

    @isTest
    public static void testNBPCurrencyResponseClass() {
        String json = '{"table":"A","no":"044/A/NBP/2023","effectiveDate":"2023-03-03","rates":[{"code":"USD","mid":4.4341},{"code":"CHF","mid":4.7280},{"code":"GBP","mid":5.3147}]}';
        NBPCurrencyResponse nbpCRList = NBPCurrencyResponse.wrapper(json);
        Boolean isWrappedCorrect = true;

        for (NBPCurrencyResponse.NBPRates thisRate : nbpCRList.rates) {
            if (!CODES.contains(thisRate.code)) {
                isWrappedCorrect = false;
            }
        }
        
        System.assertEquals(true, isWrappedCorrect, 'Wrapper is not working correct');
    }

    @isTest
    public static void testAllMethodsNBPCurrencyResponseClass() {
        String json = '{"table":"A","no":"044/A/NBP/2023","effectiveDate":"2023-03-03","rates":[{"code":"USD","mid":1},{"code":"CHF","mid":1},{"code":"GBP","mid":1}]}';
        NBPCurrencyResponse nbpCRList = NBPCurrencyResponse.wrapper(json);
        Boolean isWrappedCorrect = true;

        for (NBPCurrencyResponse.NBPRates thisRate : nbpCRList.rates) {
            if (!CODES.contains(thisRate.code) || thisRate.mid != 1) {
                isWrappedCorrect = false;
            }
        }
              
        System.assertEquals(true, isWrappedCorrect, 'Wrapper is not working correct');
        System.assertEquals('2023-03-03', nbpCRList.effectiveDate, 'Wrapper is not working correct');
        System.assertEquals('A', nbpCRList.table, 'Wrapper is not working correct');
        System.assertEquals('044/A/NBP/2023', nbpCRList.no, 'Wrapper is not working correct');
    }
}