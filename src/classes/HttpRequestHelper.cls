/**
 * Created by Alexey Dmytrenko on 19.08.2021.
 */

//in fact, service does nothing useful
public with sharing class HttpRequestHelper {

    protected String method = null;
    protected String body = null;
    protected Map<String, String> responseHeaders = null;
    protected String endpoint = null ;
    protected  Credentials__c credentials = null;

//    public HttpRequestHelper(String method, String body, String endpoint, Map<String, String> responseHeaders) {
//        this.method = method;
//        this.body = body;
//        this.endpoint = endpoint;
//        this.responseHeaders = responseHeaders;
//    }
    public HttpRequestHelper(String method, String body, String endpoint,Credentials__c credentials, Map<String, String> responseHeaders) {
        this.method = method;
        this.body = body;
        this.endpoint = endpoint;
        this.responseHeaders = responseHeaders;
    }
    public HttpRequestHelper(String method, String body, String endpoint) {
        this.method = method;
        this.body = body;
        this.endpoint = endpoint;
    }
    public HttpRequestHelper(String method,  String endpoint, Credentials__c credentials, Map<String, String> responseHeaders) {
        this.method = method;
        this.credentials = credentials;
        this.endpoint = endpoint;
        this.responseHeaders = responseHeaders;
    }
    public HttpResponse handleRestCall() {  //makeCall() or call()
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        if (this.responseHeaders != null) {
            for (String key : this.responseHeaders.keySet()) {
                request.setHeader(key, this.responseHeaders.get(key));
            }
        }
        if(this.method != null) {
            request.setMethod(this.method);
        }
        if (this.body != null) {
            request.setBody(this.body);
        }
        if(this.endpoint != null) {
            request.setEndpoint(this.endpoint);
        }
        HttpResponse response = http.send(request);
        return response;
    }
}