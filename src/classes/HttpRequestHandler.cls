/**
 * Created by Alexey Dmytrenko on 19.08.2021.
 */

public with sharing class HttpRequestHandler {
//System.debug(Credentials__c.getInstance());
    protected String method = null;
    protected String body = null;
    protected Map<String, String> responseHeaders = null;
    protected String endpoint = null ;
    public HttpResponse handleGetAccessToken() {
        Credentials__c credential = Credentials__c.getInstance();
        String clientId = credential.Key__c;
        String clientSecret = credential.Secret__c;
        String username = credential.Username__c;
        String password = credential.Password__c + credential.Token__c;
        String requestBody = 'grant_type=password&client_id=' + clientId
            + '&client_secret=' + clientSecret +
            '&username=' + username + '&password=' + password;
        String endpoint = 'https://wise-otter-t8sy56-dev-ed.my.salesforce.com/services/oauth2/token';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setBody(requestBody);
        request.setEndpoint(endpoint);
        HttpResponse response = http.send(request);
        return response;
    }
    public HttpResponse handleRestCallout(String token, String endpoint, String body, String method) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setBody(body);
        request.setEndpoint(endpoint);
        request.setHeader ('Authorization', 'Bearer ' + token);
        request.setHeader ('Content-Type', 'application/json');
        request.setHeader ('accept', 'application/json');
        request.setHeader ('X-HTTP-Method-Override', 'PATCH');
        HttpResponse response = http.send(request);
        return response;
    }
}