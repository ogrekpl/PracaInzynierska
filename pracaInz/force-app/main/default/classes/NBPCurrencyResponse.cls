public with sharing class NBPCurrencyResponse {
    public String no {get;set;} 
    public String effectiveDate {get;set;} 
    public String table {get;set;}
    public List<NBPRates> rates {get;set;}

    public class NBPRates {
        public String code {get;set;} 
        public Double mid {get;set;} 
    }

    public static NBPCurrencyResponse wrapper(String json) {
        return (NBPCurrencyResponse)System.JSON.deserialize(json, NBPCurrencyResponse.class);
    }
    public static List<NBPCurrencyResponse> wrapperList(String json) {
        return (List<NBPCurrencyResponse>)System.JSON.deserialize(json, List<NBPCurrencyResponse>.class);
    }
}