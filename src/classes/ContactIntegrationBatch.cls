/**
 * Created by Alexey Dmytrenko on 17.08.2021.
 */

public with sharing class ContactIntegrationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    public ContactIntegrationBatch(String mtdObjName) {
        this.mtdObjName = mtdObjName;
    }
    Set<Integer> errorCodes = new Set<Integer>{
        400, 415, 403, 401, 500, 596, 409, 404, 409, 429, 503
    };
    public HttpRequestService reqService = new HttpRequestService();
    public List<String> errorsList = new List <String>();
    private String token;
    private String mtdObjName;
    private IntegrationConfiguration__mdt mtdObj;
    public String query;
    public String endpoint;


    public Database.QueryLocator start(Database.BatchableContext context) {
        mtdObj = [SELECT Object__c, queryCondition__c FROM IntegrationConfiguration__mdt WHERE Object__c = :mtdObjName LIMIT 1];
        query = ContactIntegrationBatchHelper.getQuery(this.mtdObj);
        endpoint = ContactIntegrationBatchHelper.getEndpoint(mtdObj);
        token = ContactIntegrationBatchHelper.getAccessToken();
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext context, List<sObject> records) {
        // change if??
        for (sObject record : records) {
            try {
                Map<String, Object> contactMap = new Map<String, Object>(record.getPopulatedFieldsAsMap());
                contactMap.remove('Id');
                String body = JSON.serialize(contactMap);
                String endpoint = endpoint + record.Id;
                HttpResponse response = reqService.handleRestCallout(token, endpoint, body, 'PATCH');
                if (errorCodes.contains(response.getStatusCode())) {
                    errorsList.add('Body: ' + response.getBody() + ' Status: ' + response.getStatus() +
                        ' Status code: ' + response.getStatusCode() + ' Record id: ' + record.Id);
                }
            } catch (Exception e) {
                errorsList.add(e.getMessage() + e.getCause() + ' Record id: ' + record.Id);
            }
        }

    }

    public void finish(Database.BatchableContext context) {
        if (!errorsList.isEmpty()) {
            sendMail(String.join(errorsList, '.\n'), context);
        }
    }

    public void sendMail(String textBody, Database.BatchableContext context) {
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :context.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{
            a.CreatedBy.Email
        };
        mail.setToAddresses(toAddresses);
        mail.setSubject('Contact Integration Batch ' + a.Status);
        mail.setPlainTextBody('records processed ' + a.TotalJobItems + 'with ' + a.NumberOfErrors + ' failures.\n' + textBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
            mail
        });
    }
    @testVisible public void setToken() {
        token = 'test';
    }

}