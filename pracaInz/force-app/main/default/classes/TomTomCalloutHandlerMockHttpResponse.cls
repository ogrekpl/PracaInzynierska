@isTest
global class TomTomCalloutHandlerMockHttpResponse implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        if (req.getEndpoint().contains('https://api.tomtom.com/search/2/geocode')) {
            return geoCodeResposne();
        } 
        else if (req.getEndpoint().contains('https://api.tomtom.com/routing/1/calculateRoute')) {
            return calculateRoutesResponse();
        } 
        else {
            System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
            return null;
        }
    }

    private HTTPResponse geoCodeResposne() {
        String body = '{"summary":{"query":"aljanapawła23warszawapolska","queryType":"NON_NEAR","queryTime":111,"numResults":1,"offset":0,"totalResults":1,"fuzzyLevel":1,"geoBias":{"lat":37.337,"lon":-121.89}},"results":[{"type":"PointAddress","id":"YO-ANHwy8Ax-CoGloPbQrg","score":12.0066423416,"dist":9425831.792675218,"matchConfidence":{"score":0.9869853795473089},"address":{"streetNumber":"23","streetName":"AlejaJanaPawłaII","municipalitySubdivision":"Wola","municipality":"Warszawa","countrySecondarySubdivision":"Warszawa","countrySubdivision":"Mazowieckie","postalCode":"00-854","countryCode":"PL","country":"Polska","countryCodeISO3":"POL","freeformAddress":"AlejaJanaPawłaII23,00-854Warszawa","localName":"Warszawa"},"position":{"lat":52.23632,"lon":20.99649},"viewport":{"topLeftPoint":{"lat":52.23722,"lon":20.99502},"btmRightPoint":{"lat":52.23542,"lon":20.99796}},"entryPoints":[{"type":"main","position":{"lat":52.23638,"lon":20.99683}}]}]}';
        HTTPResponse res = new HTTPResponse();
        res.setBody(body);
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        return res; 
    }

    private HTTPResponse calculateRoutesResponse() {
        String body = '{"formatVersion":"0.0.12","routes":[{"summary":{"lengthInMeters":108830,"travelTimeInSeconds":6025,"trafficDelayInSeconds":0,"trafficLengthInMeters":0,"departureTime":"2023-03-10T10:59:23+01:00","arrivalTime":"2023-03-10T12:39:48+01:00"},"legs":[{"summary":{"lengthInMeters":108830,"travelTimeInSeconds":6025,"trafficDelayInSeconds":0,"trafficLengthInMeters":0,"departureTime":"2023-03-10T10:59:23+01:00","arrivalTime":"2023-03-10T12:39:48+01:00"},"points":[{"latitude":52.16379,"longitude":21.04657},{"latitude":51.40277,"longitude":21.11801}]}],"sections":[{"startPointIndex":0,"endPointIndex":1374,"sectionType":"TRAVEL_MODE","travelMode":"truck"}]}]}';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
}