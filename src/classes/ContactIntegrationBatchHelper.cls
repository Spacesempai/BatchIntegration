/**
 * Created by Alexey Dmytrenko on 16.08.2021.
 */

global with sharing class ContactIntegrationBatchHelper {
    global static string tokenError;
    global static String getTokenError() {
        return tokenError;
    }
    global static void setTokenError(String error) {
        tokenError = error;
    }

    global static String getAccessToken() {
        HttpRequestHandler reqHandler = new HttpRequestHandler();
        HttpResponse response = reqHandler.handleGetAccessToken();
        if (response.getStatusCode() == 200) {
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String accessToken = (String) resultMap.get('access_token');
            return accessToken;
        } else {
            setTokenError('Body: ' + response.getBody() + 'Status code: ' + response.getStatusCode() + 'Status: ' + response.getStatus()); //throw new AccessTokenException()
            return null;
        }

    }
    global static String getQuery(IntegrationConfiguration__mdt obj) {
        String fields = getConfidFields(obj);
        String query = 'Select ' + fields + ' FROM ' + obj.Object__c;
        if (String.isNotBlank(obj.queryCondition__c)) {
            return query + ' WHERE ' + obj.queryCondition__c;   //String.escapeSingleQuotes() for soql injection prevention
        } else {
            return query;
        }
    }
    global static String getEndpoint(IntegrationConfiguration__mdt obj) {
        Credentials__c credentials = Credentials__c.getInstance();
        String url = credentials.InstanceUrl__c;
        return url + '/services/data/v52.0/sobjects/' + obj.Object__c + '/ExtId__c/';
    }
    global static String getConfidFields(IntegrationConfiguration__mdt obj) {
        List<IntegrationConfigFields__mdt> fields = [SELECT fieldName__c FROM IntegrationConfigFields__mdt WHERE IntegrationConfiguration__c = :obj.id];    //fieldConfigs
        String f = 'Id';    // fieldNames
        if (!fields.isEmpty()) {
            for (IntegrationConfigFields__mdt field : fields) {
                f += ', ' + field.FieldName__c;
            }
        }
        return f;
    }

//    public class AccessTokenException extends Exception {}
}