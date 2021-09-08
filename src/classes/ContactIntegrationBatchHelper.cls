/**
 * Created by Alexey Dmytrenko on 16.08.2021.
 */

global with sharing class ContactIntegrationBatchHelper {
    global static String getAccessToken() {
        HttpRequestService reqHandler = new HttpRequestService();
        HttpResponse response = reqHandler.handleGetAccessToken();
        if (response.getStatusCode() == 200) {
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String accessToken = (String) resultMap.get('access_token');
            return accessToken;
        } else {
            throw new AccessTokenException();
        }

    }
    global static String getQuery(IntegrationConfiguration__mdt obj) {
        String fields = getConfidFields(obj);
        String query = 'Select ' + fields + ' FROM ' + obj.Object__c;
        if (String.isNotBlank(obj.queryCondition__c)) {
            return query + ' WHERE ' + String.escapeSingleQuotes(obj.queryCondition__c);
        } else {
            return query;
        }
    }
    global static String getEndpoint(IntegrationConfiguration__mdt obj) {
        Credentials__c credentials = Credentials__c.getInstance();
        String url = credentials.InstanceUrl__c;
        return url + '/services/data/v52.0/sobjects/' + String.escapeSingleQuotes(obj.Object__c) + '/ExtId__c/';
    }
    global static String getConfidFields(IntegrationConfiguration__mdt obj) {
        List<IntegrationConfigFields__mdt> fields = [SELECT fieldName__c FROM IntegrationConfigFields__mdt WHERE IntegrationConfiguration__c = :obj.id];
        String fieldNames = 'Id';
        if (!fields.isEmpty()) {
            for (IntegrationConfigFields__mdt field : fields) {
                fieldNames += ', ' + String.escapeSingleQuotes(field.FieldName__c);
            }
        }
        return fieldNames;
    }
    @testVisible static List<IntegrationConfiguration__mdt> integrationConfiguration{
        get{
            if(integrationConfiguration == NULL){
                integrationConfiguration = [SELECT Object__c, queryCondition__c FROM IntegrationConfiguration__mdt];
            }
            return integrationConfiguration;
        }
        set;
    }
    @testVisible static List<IntegrationConfigFields__mdt> integrationConfigFields{
        get{
            if(integrationConfigFields == NULL){
                integrationConfigFields = [SELECT fieldName__c FROM         IntegrationConfigFields__mdt];
            }
            return integrationConfigFields;
        }
        set;
    }

    public class AccessTokenException extends Exception {
    }
}