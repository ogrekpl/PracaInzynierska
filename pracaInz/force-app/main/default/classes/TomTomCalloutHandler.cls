public with sharing class TomTomCalloutHandler {

    @future(callout=true)
    public static void getRouteDetails(Id shipmentId) {
        Shipment__c shipment = [SELECT Id, Destination_Warehouse__r.geoLocation__c, Loading_Warehouse__r.geoLocation__c, Hours__c, Minutes__c, Total_distance__c FROM Shipment__c WHERE Id =: shipmentId LIMIT 1];
        
        if (shipment.Destination_Warehouse__c == null || shipment.Loading_Warehouse__c == null) {
            throw new TomTomCalloutHandlerException('No Destination or Loading Warehouse.');
        }
        
        TomTomIntegration__mdt tomTomMDT = [SELECT EndPoint__c, Key__c, URL__c FROM TomTomIntegration__mdt WHERE Label ='Calculate Route' LIMIT 1];
        
        String queryString = shipment.Loading_Warehouse__r.geoLocation__c.getLatitude() + ',' + shipment.Loading_Warehouse__r.geoLocation__c.getLongitude() + ':' 
                            + shipment.Destination_Warehouse__r.geoLocation__c.getLatitude() + ',' + shipment.Destination_Warehouse__r.geoLocation__c.getLongitude();
        String encodedQueryString = EncodingUtil.urlEncode(queryString, 'UTF-8');
        String htmlString = tomTomMDT.URL__c + '/' + tomTomMDT.EndPoint__c + encodedQueryString + '/json?routeType=fastest&traffic=false&avoid=unpavedRoads&travelMode=truck&key=' + tomTomMDT.Key__c;

        CalloutManager cm = new CalloutManager();
        cm.setGetMethod();
        cm.makeCallout(htmlString);
        RouteDetailsResponse routeDetailsResponse = RouteDetailsResponse.parse(cm.Response().getBody());

        Integer totalMinutes = routeDetailsResponse.routes[0].summary.travelTimeInSeconds / 60;
        Integer totalHours = totalMinutes / 60;
        Integer minutes = totalMinutes - (totalHours * 60 );

        shipment.Minutes__c = minutes;
        shipment.Hours__c = totalHours;
        shipment.Total_distance__c = routeDetailsResponse.routes[0].summary.lengthInMeters / 1000;

        update(shipment);
    }

    @future(callout=true)
    public static void getGeoCodeValues(Id recordId) {
        Schema.SObjectType sobjectType = recordId.getSObjectType();

        if (sobjectType.getDescribe().getName() != 'Warehouse__c') {
            throw new TomTomCalloutHandlerException('This method is not supported for this type of SObject.');
        }

        Warehouse__c warehouse = [SELECT Address__c, geoLocation__c FROM Warehouse__c WHERE Id =: recordId LIMIT 1];
        TomTomIntegration__mdt tomTomMDT = [SELECT EndPoint__c, Key__c, URL__c FROM TomTomIntegration__mdt WHERE Label ='Geocoding' LIMIT 1];
        
        String queryString = warehouse.Address__c.getStreet() + ' ' + warehouse.Address__c.getCity() + ' ' + warehouse.Address__c.getPostalCode() + ' ' + warehouse.Address__c.getCountry();
        String encodedQueryString = EncodingUtil.urlEncode(queryString, 'UTF-8');
        String htmlString = tomTomMDT.URL__c + '/' + tomTomMDT.EndPoint__c + encodedQueryString + '.json?storeResult=false&lat=37.337&lon=-121.89&view=Unified&key=' + tomTomMDT.Key__c;

        CalloutManager cm = new CalloutManager();
        cm.setGetMethod();
        cm.makeCallout(htmlString);
        GeocodeResponse geocodeResponse = GeocodeResponse.parse(cm.Response().getBody());

        warehouse.geoLocation__latitude__s = geocodeResponse.results[0].position.lat;
        warehouse.geoLocation__longitude__s = geocodeResponse.results[0].position.lon;

        update(warehouse);
    }
    
    public class TomTomCalloutHandlerException extends Exception {}
}