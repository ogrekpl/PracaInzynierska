@isTest
global class NBPCurrencyCalloutMockHttpResponse implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        if (req.getEndpoint() == 'https://api.nbp.pl/api/exchangerates/tables/a/') {
            return nbpResponse();
        } 
        else if (req.getEndpoint() == (URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v57.0/composite/sobjects')) {
            return insertResponse();
        } 
        else {
            System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
            return null;
        }
    }

    private HTTPResponse nbpResponse() {
        String body = '[{"table":"A","no":"044/A/NBP/2023","effectiveDate":"2023-03-03","rates":[{"currency":"bat(Tajlandia)","code":"THB","mid":0.1278},{"currency":"dolaramerykański","code":"USD","mid":4.4341},{"currency":"dolaraustralijski","code":"AUD","mid":2.9967},{"currency":"dolarHongkongu","code":"HKD","mid":0.5649},{"currency":"dolarkanadyjski","code":"CAD","mid":3.2695},{"currency":"dolarnowozelandzki","code":"NZD","mid":2.7642},{"currency":"dolarsingapurski","code":"SGD","mid":3.2941},{"currency":"euro","code":"EUR","mid":4.7046},{"currency":"forint(Węgry)","code":"HUF","mid":0.012426},{"currency":"frankszwajcarski","code":"CHF","mid":4.728},{"currency":"funtszterling","code":"GBP","mid":5.3147},{"currency":"hrywna(Ukraina)","code":"UAH","mid":0.1258},{"currency":"jen(Japonia)","code":"JPY","mid":0.032566},{"currency":"koronaczeska","code":"CZK","mid":0.2003},{"currency":"koronaduńska","code":"DKK","mid":0.6322},{"currency":"koronaislandzka","code":"ISK","mid":0.03126},{"currency":"koronanorweska","code":"NOK","mid":0.4253},{"currency":"koronaszwedzka","code":"SEK","mid":0.4222},{"currency":"lejrumuński","code":"RON","mid":0.9558},{"currency":"lew(Bułgaria)","code":"BGN","mid":2.4054},{"currency":"liraturecka","code":"TRY","mid":0.2348},{"currency":"nowyizraelskiszekel","code":"ILS","mid":1.21},{"currency":"pesochilijskie","code":"CLP","mid":0.005459},{"currency":"pesofilipińskie","code":"PHP","mid":0.0809},{"currency":"pesomeksykańskie","code":"MXN","mid":0.2454},{"currency":"rand(RepublikaPołudniowejAfryki)","code":"ZAR","mid":0.2438},{"currency":"real(Brazylia)","code":"BRL","mid":0.8525},{"currency":"ringgit(Malezja)","code":"MYR","mid":0.9906},{"currency":"rupiaindonezyjska","code":"IDR","mid":0.00028981},{"currency":"rupiaindyjska","code":"INR","mid":0.054108},{"currency":"wonpołudniowokoreański","code":"KRW","mid":0.00341},{"currency":"yuanrenminbi(Chiny)","code":"CNY","mid":0.6424},{"currency":"SDR(MFW)","code":"XDR","mid":5.8989}]}]';
        HTTPResponse res = new HTTPResponse();
        res.setBody(body);
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        return res; 
    }

    private HTTPResponse insertResponse() {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Status":"Ok"}');
        res.setStatusCode(200);
        return res;
    }
}