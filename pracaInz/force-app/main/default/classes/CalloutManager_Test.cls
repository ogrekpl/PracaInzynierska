@isTest
global class CalloutManager_Test {
    @isTest
    public static void testCalloutManagerGET() {
        CalloutManager cm = new CalloutManager('test.com', 'abc', 'GET');
        Map<String, String> headers = new Map<String, String>{'Authorization' => 'OAuth'};
        cm.createHeader(headers);
        cm.setGetMethod();
        Test.setMock(HttpCalloutMock.class, new CalloutManagerMockHttpResponse());
        cm.makeCallout();
        HttpResponse httpRes = cm.Response();
        Map<String, String> outputMap = (Map<String, String>)JSON.deserialize((String)cm.getBody(), Map<String, String>.class);
        System.assertEquals('test', outputMap.get('test'));
    }

    @isTest
    public static void testCalloutManagerPUT() {
        CalloutManager cm = new CalloutManager('test.com', 'abc', 'PUT');
        Map<String, String> headers = new Map<String, String>{'Authorization' => 'OAuth'};
        cm.createHeader(headers);
        cm.setPutMethod();
        cm.setBody('test123');
        Test.setMock(HttpCalloutMock.class, new CalloutManagerMockHttpResponse());
        cm.makeCallout();
        HttpResponse httpRes = cm.Response();
        Map<String, String> outputMap = (Map<String, String>)JSON.deserialize((String)cm.getBody(), Map<String, String>.class);
        System.assertEquals('test', outputMap.get('test'));
    }

    @isTest
    public static void testCalloutManagerPOST() {
        CalloutManager cm = new CalloutManager('test.com', 'abc', 'POST');
        Map<String, String> headers = new Map<String, String>{'Authorization' => 'OAuth'};
        cm.createHeader(headers);
        cm.setPostMethod();
        Test.setMock(HttpCalloutMock.class, new CalloutManagerMockHttpResponse());
        cm.makeCallout();
        HttpResponse httpRes = cm.Response();
        Map<String, String> outputMap = (Map<String, String>)JSON.deserialize((String)cm.getBody(), Map<String, String>.class);
        System.assertEquals('test', outputMap.get('test'));
    }

    @isTest
    public static void testCalloutManagerNoEndpoint() {
        CalloutManager cm = new CalloutManager('test.com');
        Map<String, String> headers = new Map<String, String>{'Authorization' => 'OAuth'};
        cm.createHeader(headers);
        cm.setPostMethod();
        Test.setMock(HttpCalloutMock.class, new CalloutManagerMockHttpResponse());
        try {
            cm.makeCallout();
        }
        catch(Exception e) {
            System.assertEquals('No endpoint provided.', e.getMessage());
        }
    }

    @isTest
    public static void testCalloutManagerNoMethod() {
        CalloutManager cm = new CalloutManager('test.com', 'abc');
        Map<String, String> headers = new Map<String, String>{'Authorization' => 'OAuth'};
        cm.createHeader(headers);
        Test.setMock(HttpCalloutMock.class, new CalloutManagerMockHttpResponse());
        try {
            cm.makeCallout();
        }
        catch(Exception e) {
            System.assertEquals('No callout method type provided.', e.getMessage());
        }
    }

    @isTest //TODO
    public static void testCalloutManager404StatusCode() {
        CalloutManager cm = new CalloutManager('test.com', 'abc', 'POST');
        Map<String, String> headers = new Map<String, String>{'Authorization' => 'OAuth'};
        cm.createHeader(headers);
        cm.setPostMethod();
        Test.setMock(HttpCalloutMock.class, new CalloutManagerMockHttpResponse404());
        cm.makeCallout();    
        System.assertEquals(false, cm.getBody());
    }
}