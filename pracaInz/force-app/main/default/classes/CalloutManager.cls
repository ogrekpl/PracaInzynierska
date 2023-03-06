public with sharing class CalloutManager {

    private final String GET = 'GET', PUT = 'PUT', POST = 'POST';
    private final Set<Integer> ERROR_CODES = new Set<Integer>{400, 404};
    private HttpRequest request;
    private HttpResponse response;
    private String methodType;
    private String endpoint;
    private String url;
    private Http http;

    public HttpResponse Response() {
        return response;
    }

    public CalloutManager(String url) {
        this.request = new HttpRequest();
        this.url = url;
        setHeader();
    }

    public CalloutManager(String url, String endpoint) {
        this(url);
        this.endpoint = endpoint;
    }

    public CalloutManager(String url, String endpoint, String method) {
        this(url, endpoint);
        this.methodType = method;
    }

    public void createHeader(Map<String, String> headers) {
        for (String key : headers.keySet()) {
            request.setHeader(key, headers.get(key));
        }
    }

    public void setBody(String body) {
        request.setBody(body);
    }

    public void setGetMethod() {
        methodType = GET;
        request.setMethod(methodType);
    }

    public void setPutMethod() {
        methodType = PUT;
        request.setMethod(methodType);
    }

    public void setPostMethod() {
        methodType = POST;
        request.setMethod(methodType); 
    }

    public void makeCallout() {
        if (endpoint == null) {
            throw new CalloutHandllerException('No endpoint provided.');
        }

        request.setEndpoint(url + '/' + endpoint);
        http = new Http();
        switch on methodType {
            when 'GET' {		
                makeGetCallout();
            }	
            when 'PUT' {		
                makePutCallout();
            }
            when 'POST' {
                makePostCallout();
            }
            when else {		 
                throw new CalloutHandllerException('No callout method type provided.');
            }
        }
    }

    public Object getBody() {
        if (ERROR_CODES.contains(response.getStatusCode())) {
            return false;
        }
        return response.getBody();
    }

    private void setHeader() {
        request.setHeader('Content-Type', 'application/json');
    }

    private void makeGetCallout() {
        request.setMethod(GET);
        response = http.send(request);
    }

    private void makePutCallout() {
        request.setMethod(PUT);
        response = http.send(request);
    }

    private void makePostCallout() {
        request.setMethod(POST);
        response = http.send(request);
    }

    public class CalloutHandllerException extends Exception {}
}