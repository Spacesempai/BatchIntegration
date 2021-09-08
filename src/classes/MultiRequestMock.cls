/**
 * Created by Alexey Dmytrenko on 08.09.2021.
 */

@IsTest
public class MultiRequestMock implements HttpCalloutMock {
    Map<String, HttpCalloutMock> requests;

    public MultiRequestMock(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpCalloutMock mock = requests.get(req.getEndpoint());
        System.debug(requests.keySet());
        System.debug(req.getEndpoint());
        System.debug(requests.get(req.getEndpoint()));



        if (mock != null) {
            return mock.respond(req);
        } else {
            throw new MockRequestException('HTTP callout not supported for test methods');
        }
    }

    public void addRequestMock(String url, HttpCalloutMock mock) {
        requests.put(url, mock);
    }
    public class MockRequestException extends Exception {
    }
}