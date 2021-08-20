/**
 * Created by Alexey Dmytrenko on 16.08.2021.
 */

global with sharing class BatchAddContactHelper {
    global static void getAccessToken() {
        Credentials__c credential = [
            SELECT Key__c, Secret__c, Username__c,Password__c, Token__c
            FROM Credentials__c
        ];
        String clientId = credential.Key__c;
        String clientSecret = credential.Secret__c;
        String username = credential.Username__c;
        String password = credential.Password__c + credential.Token__c;
        String requestBody = 'grant_type=password&client_id=' + clientId
            + '&client_secret=' + clientSecret +
            '&username=' + username + '&password=' + password;
        String endpoint = 'https://wise-otter-t8sy56-dev-ed.my.salesforce.com/services/oauth2/token';
        HttpRequestHelper reqHelper = new HttpRequestHelper('GET', requestBody, endpoint);
        HttpResponse response = reqHelper.handleRestCall();
//        HttpResponse response = HttpRequestHelper.createRequestToken(requestBody, 'GET', endpoint);
        System.debug('response  ' + response);
        System.debug('response body  ' + response.getBody());
        if (response.getStatusCode() == 200) {
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String accessToken = (String) resultMap.get('access_token');
            String instanceURL = (String) resultMap.get('instance_url');
            System.debug(accessToken);
            System.debug(instanceURL);
            credential.Access_Token__c = accessToken;
            update credential;
        }
    }
    global static Set<Id> checkContactExistence(Contact contact) {
        Credentials__c credentials = [SELECT Access_Token__c FROM Credentials__c];
        String endpoint = 'https://wise-hawk-4j5lfa-dev-ed.my.salesforce.com/services/data/v52.0/query/' +
            '?q=SELECT+Id+,Name+FROM+Contact+WHERE+lastname=\'' + contact.LastName + '\'AND+firstname=\'' + contact.FirstName + '\'';
        Map<String, String> headers = new Map<String, String>();
        headers.put('Authorization', 'Bearer ' + credentials.Access_Token__c);
        headers.put('Content-Type', 'application/json');
        HttpRequestHelper reqHelper = new HttpRequestHelper('GET', endpoint, credentials,headers);
        HttpResponse response = reqHelper.handleRestCall();
        System.debug(response);
        System.debug(response.getBody());
        System.debug(response.getHeaderKeys());
        if (response.getStatusCode() == 200) {
            ResponseHandler body = (ResponseHandler) JSON.deserialize(response.getBody(), ResponseHandler.class);
            List<Contact> contactList = body.records;
            System.debug('Contact list ' + contactList);
            if (contactList != new List<Contact>()) {
                Set<Id> resultIds = (new Map<Id, Contact>(contactList)).keySet();
                return resultIds;
            } else {
                return null;
            }
        } else {
            return null;
        }
    }
}