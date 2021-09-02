/**
 * Created by Alexey Dmytrenko on 16.08.2021.
 */

global with sharing class ContactIntegrationBatchHelper {
    global static String getAccessToken() {
        HttpRequestHandler reqHandler = new HttpRequestHandler();
        HttpResponse response = reqHandler.handleGetAccessToken();
        System.debug('response  ' + response);
        System.debug('response body  ' + response.getBody());
        if (response.getStatusCode() == 200) {
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String accessToken = (String) resultMap.get('access_token');
            return accessToken;
        } else {
            return null;
        }

    }
    global static String getQuery(IntegrationConfiguration__mdt obj) {
        List<IntegrationConfigFields__mdt> fields = [Select fieldName__c from IntegrationConfigFields__mdt where IntegrationConfiguration__c = :obj.id];
        System.debug(fields[0].fieldName__c);
        string f = 'Id';
        for (IntegrationConfigFields__mdt field : fields) {
            f += ', ' + field.FieldName__c;
        }
        System.debug(f);
        return 'Select ' + f + ' FROM ' + obj.Object__c;

    }
}