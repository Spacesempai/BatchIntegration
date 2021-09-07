/**
 * Created by Alexey Dmytrenko on 17.08.2021.
 */

public with sharing class ContactIntegrationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    Set<Integer> errorCodes = new Set<Integer>{
        400, 415, 403, 401, 500, 596, 409, 404, 409, 429, 503
    };
    List<String> errorsList = new List <String>();
    private String token = ContactIntegrationBatchHelper.getAccessToken();
    public String query;
    public String StartEndpoint;
    public string tokenError = ContactIntegrationBatchHelper.getTokenError();

    public ContactIntegrationBatch(String query, String endpoint) {
        this.query = query;
        this.StartEndpoint = endpoint;
    }
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext context, List<sObject> source) {
        // change if??
        if (token != null) {
            for (sObject obj : source) {
                try {
                    Map<String, Object> contactMap = new Map<String, Object>(obj.getPopulatedFieldsAsMap());
                    contactMap.remove('Id');
                    String body = JSON.serialize(contactMap);
                    String endpoint = StartEndpoint + obj.Id;
                    HttpRequestHandler reqHandler = new HttpRequestHandler();
                    HttpResponse response = reqHandler.handleRestCallout(token, endpoint, body, 'PATCH');
                    if (errorCodes.contains(response.getStatusCode())) {
                        errorsList.add('Body: ' + response.getBody() + ' Status: ' + response.getStatus() +
                            ' Status code: ' + response.getStatusCode() + ' Record id: ' + obj.Id);
                    }
                } catch (Exception e) {
                    errorsList.add(e.getMessage() + e.getCause() + ' Record id: ' + obj.Id);
                }
            }
        }
    }

    public void finish(Database.BatchableContext context) {
        if (!errorsList.isEmpty()) {
            sendMail(String.join(errorsList, '.\n'), context);
        }
        if (token == null && tokenError != null) {
            sendMail(tokenError, context);
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

}