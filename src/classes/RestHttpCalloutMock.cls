/**
 * Created by Alexey Dmytrenko on 19.08.2021.
 */

@IsTest
global with sharing class RestHttpCalloutMock implements HttpCalloutMock {
    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders = null;

    global RestHttpCalloutMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }

    global HttpResponse respond(HttpRequest req) {

        HttpResponse res = new HttpResponse();
        if (responseHeaders != null) {
            for (String key : this.responseHeaders.keySet()) {
                res.setHeader(key, this.responseHeaders.get(key));
            }
        }
        if (this.body != null) {
            res.setBody(this.body);
        }
        if (this.code != null) {
            res.setStatusCode(this.code);
        }
        if (this.status != null) {
            res.setStatus(this.status);
        }
        return res;
    }

}